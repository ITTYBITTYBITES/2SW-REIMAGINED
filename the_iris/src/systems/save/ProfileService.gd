extends Node
## ProfileService - Player profile, progress, stats
## Built on SaveService, independent, observable

signal profile_loaded(profile: Dictionary)
signal profile_saved(profile: Dictionary)
signal profile_updated(field: String, value: Variant)
signal experience_progress_updated(exp_id: String, progress: Dictionary)
signal stats_updated(stats: Dictionary)

var profile: Dictionary = {}
var _initialized: bool = false

const DEFAULT_PROFILE := {
	"version": 2,
	"id": "",
	"display_name": "Witness",
	"created_at": "",
	"last_seen": "",
	"level": 1,
	"xp": 0,
	"xp_to_next": 100,
	"total_sessions": 0,
	"total_play_time_ms": 0,
	"experiences_unlocked": ["flashword"],
	"experiences_progress": {
		# exp_id -> {played, best_score, last_played, mastery}
	},
	"stats": {
		"observations_made": 0,
		"correct_observations": 0,
		"fastest_reaction_ms": 9999,
		"streak_current": 0,
		"streak_best": 0
	},
	"achievements": [],
	"achievement_progress": {},
	"favorite_challenge_types": [],
	"program_progress": {},
	"active_program_id": "",
	"preferences": {
		"onboarding_completed": false,
		"privacy_acknowledged": false,
		"privacy_policy_version": ""
	}
}

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return

	var loaded := SaveService.load_profile() if SaveService else {}
	if loaded.is_empty():
		profile = DEFAULT_PROFILE.duplicate(true)
		profile["id"] = _generate_id()
		profile["created_at"] = Time.get_datetime_string_from_system()
	else:
		profile = _merge_default(loaded)

	profile["last_seen"] = Time.get_datetime_string_from_system()
	profile["total_sessions"] = int(profile.get("total_sessions", 0)) + 1

	save()

	_initialized = true
	profile_loaded.emit(profile)
	EventBus.publish_profile_updated(profile)

func _merge_default(loaded: Dictionary) -> Dictionary:
	var merged := _merge_dictionary(DEFAULT_PROFILE, loaded)
	merged["version"] = int(DEFAULT_PROFILE.get("version", 2))
	if str(merged.get("id", "")).is_empty():
		merged["id"] = _generate_id()
	if str(merged.get("created_at", "")).is_empty():
		merged["created_at"] = Time.get_datetime_string_from_system()
	return merged

func _merge_dictionary(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var merged := defaults.duplicate(true)
	for key: Variant in loaded.keys():
		var incoming: Variant = loaded[key]
		if merged.has(key) and merged[key] is Dictionary and incoming is Dictionary:
			merged[key] = _merge_dictionary(merged[key] as Dictionary, incoming as Dictionary)
		else:
			merged[key] = incoming
	return merged

func save() -> bool:
	if not SaveService:
		return false
	profile["last_seen"] = Time.get_datetime_string_from_system()
	var ok := SaveService.save_profile(profile)
	if ok:
		profile_saved.emit(profile)
		EventBus.publish_profile_updated(profile)
	return ok

func get_value(key: String, default: Variant = null) -> Variant:
	return profile.get(key, default)

func set_value(key: String, value: Variant) -> bool:
	profile[key] = value
	profile_updated.emit(key, value)
	return save()

func add_xp(amount: int) -> void:
	var current_xp: int = profile.get("xp", 0)
	var level: int = profile.get("level", 1)
	var xp_to_next: int = profile.get("xp_to_next", 100)

	current_xp += amount

	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * 1.25)
		if AnalyticsService:
			AnalyticsService.log_event("level_up", {"level": level})

	profile["level"] = level
	profile["xp"] = current_xp
	profile["xp_to_next"] = xp_to_next
	profile_updated.emit("level", level)
	profile_updated.emit("xp", current_xp)
	save()

func record_experience_play(exp_id: String, result: Dictionary) -> void:
	var progress: Dictionary = profile.get("experiences_progress", {})
	if not progress.has(exp_id):
		progress[exp_id] = {"played": 0, "best_score": 0, "last_played": "", "total_score": 0}

	var entry: Dictionary = progress[exp_id]
	entry["played"] = int(entry.get("played", 0)) + 1
	entry["last_played"] = Time.get_datetime_string_from_system()

	var score: int = result.get("score", 0)
	entry["total_score"] = int(entry.get("total_score", 0)) + score
	if score > int(entry.get("best_score", 0)):
		entry["best_score"] = score

	progress[exp_id] = entry
	profile["experiences_progress"] = progress

	# Update stats
	var stats: Dictionary = profile.get("stats", {})
	stats["observations_made"] = int(stats.get("observations_made", 0)) + 1
	if result.get("correct", false):
		stats["correct_observations"] = int(stats.get("correct_observations", 0)) + 1
		stats["streak_current"] = int(stats.get("streak_current", 0)) + 1
		if stats["streak_current"] > int(stats.get("streak_best", 0)):
			stats["streak_best"] = stats["streak_current"]
	else:
		stats["streak_current"] = 0

	var reaction: int = result.get("reaction_ms", 9999)
	if reaction < int(stats.get("fastest_reaction_ms", 9999)):
		stats["fastest_reaction_ms"] = reaction

	profile["stats"] = stats

	experience_progress_updated.emit(exp_id, entry)
	stats_updated.emit(stats)
	EventBus.publish_experience_completed(exp_id, result)
	save()

	if AnalyticsService:
		AnalyticsService.log_event("experience_completed", {"exp_id": exp_id, "score": score})

func unlock_experience(exp_id: String) -> bool:
	var unlocked: Array = profile.get("experiences_unlocked", [])
	if unlocked.has(exp_id):
		return false
	unlocked.append(exp_id)
	profile["experiences_unlocked"] = unlocked
	save()
	EventBus.publish_experience_unlocked(exp_id)
	return true

func is_experience_unlocked(exp_id: String) -> bool:
	var unlocked: Array = profile.get("experiences_unlocked", [])
	return unlocked.has(exp_id)

func get_experience_progress(exp_id: String) -> Dictionary:
	var progress: Dictionary = profile.get("experiences_progress", {})
	return progress.get(exp_id, {"played": 0, "best_score": 0, "last_played": "", "total_score": 0})

func get_stats() -> Dictionary:
	return profile.get("stats", {})

func _generate_id() -> String:
	var t := Time.get_ticks_msec()
	var r := randi() % 1000000
	return "witness_%d_%d" % [t, r]

func reset_profile() -> void:
	profile = DEFAULT_PROFILE.duplicate(true)
	profile["id"] = _generate_id()
	profile["created_at"] = Time.get_datetime_string_from_system()
	save()
	profile_loaded.emit(profile)

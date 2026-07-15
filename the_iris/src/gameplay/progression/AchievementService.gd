extends Node
## Data-driven game achievement evaluation over persisted Witness Progress.

signal achievement_unlocked(achievement_id: String, definition: Dictionary)
signal achievement_progress_updated(statuses: Array[Dictionary])

const DEFINITIONS_PATH: String = "res://src/gameplay/progression/achievements.json"

var _initialized: bool = false
var _definitions: Array[Dictionary] = []

func _ready() -> void:
	pass

func _play_unlock_sound() -> void:
	if AudioService:
		AudioService.play_sfx("ui_achievement", 0.85)
		AudioService.duck_bgm(-6.0, 0.1)
		var tree: SceneTree = get_tree()
		if tree:
			tree.create_timer(0.6).timeout.connect(func() -> void:
				if AudioService:
					AudioService.unduck_bgm(0.4)
			)

func initialize() -> void:
	if _initialized:
		return
	_load_definitions()
	_ensure_profile_fields()
	_initialized = true

func get_definitions() -> Array[Dictionary]:
	_ensure_initialized()
	return _definitions.duplicate(true)

func get_statuses() -> Array[Dictionary]:
	_ensure_initialized()
	_ensure_profile_fields()
	var unlocked: Array = ProfileService.profile.get("achievements", []) if ProfileService else []
	var progress: Dictionary = ProfileService.profile.get("achievement_progress", {}) if ProfileService else {}
	var statuses: Array[Dictionary] = []
	var order: int = 0
	for definition: Dictionary in _definitions:
		var achievement_id: String = str(definition.get("id", ""))
		var current: float = float(progress.get(achievement_id, 0.0))
		var target: float = float(definition.get("target", 1.0))
		var status: Dictionary = definition.duplicate(true)
		status["current"] = current
		status["target"] = target
		status["unlocked"] = unlocked.has(achievement_id)
		status["ratio"] = clampf(current / maxf(target, 0.001), 0.0, 1.0)
		status["order"] = order
		statuses.append(status)
		order += 1
	return statuses

func get_featured_statuses(limit: int = 3) -> Array[Dictionary]:
	var locked: Array[Dictionary] = []
	for status: Dictionary in get_statuses():
		if not bool(status.get("unlocked", false)):
			locked.append(status)
	locked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_ratio: float = float(a.get("ratio", 0.0))
		var b_ratio: float = float(b.get("ratio", 0.0))
		if is_equal_approx(a_ratio, b_ratio):
			return int(a.get("order", 0)) < int(b.get("order", 0))
		return a_ratio > b_ratio
	)
	var output: Array[Dictionary] = []
	for index: int in range(mini(maxi(limit, 0), locked.size())):
		output.append(locked[index].duplicate(true))
	return output

func evaluate_after_result(result: ChallengeResult) -> Array[String]:
	_ensure_initialized()
	if result == null or not ProfileService:
		return []
	_ensure_profile_fields()
	var unlocked: Array = ProfileService.profile.get("achievements", [])
	var progress: Dictionary = ProfileService.profile.get("achievement_progress", {})
	var newly_unlocked: Array[String] = []
	for definition: Dictionary in _definitions:
		var achievement_id: String = str(definition.get("id", ""))
		var value: float = _criterion_value(definition, result)
		var previous: float = float(progress.get(achievement_id, 0.0))
		var retained_value: float = maxf(previous, value)
		progress[achievement_id] = retained_value
		if retained_value >= float(definition.get("target", 1.0)) and not unlocked.has(achievement_id):
			unlocked.append(achievement_id)
			newly_unlocked.append(achievement_id)
			achievement_unlocked.emit(achievement_id, definition.duplicate(true))
			_play_unlock_sound()
			if AnalyticsService:
				AnalyticsService.log_event("achievement_unlocked", {"achievement_id": achievement_id})
	ProfileService.profile["achievements"] = unlocked
	ProfileService.profile["achievement_progress"] = progress
	if ProfileService.has_method("save"):
		ProfileService.save()
	achievement_progress_updated.emit(get_statuses())
	return newly_unlocked

func evaluate_profile_progress() -> Array[String]:
	var incomplete_result := ChallengeResult.new()
	incomplete_result.outcome = "incomplete"
	incomplete_result.reaction_ms = 999999
	return evaluate_after_result(incomplete_result)

func get_unlocked_count() -> int:
	_ensure_initialized()
	_ensure_profile_fields()
	if not ProfileService:
		return 0
	var unlocked: Variant = ProfileService.profile.get("achievements", [])
	return (unlocked as Array).size() if unlocked is Array else 0

func _criterion_value(definition: Dictionary, result: ChallengeResult) -> float:
	var witness: Dictionary = ProfileService.profile.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	var criterion: String = str(definition.get("criterion", ""))
	var family_id: String = str(definition.get("family_id", ""))
	match criterion:
		"total_plays":
			var total: int = 0
			for family_progress: Variant in families.values():
				if family_progress is Dictionary:
					total += int((family_progress as Dictionary).get("plays", 0))
			return float(total)
		"family_correct":
			var correct_progress: Variant = families.get(family_id, {})
			return float((correct_progress as Dictionary).get("correct", 0)) if correct_progress is Dictionary else 0.0
		"family_mastery":
			var mastery_progress: Variant = families.get(family_id, {})
			return float((mastery_progress as Dictionary).get("mastery", 0.0)) if mastery_progress is Dictionary else 0.0
		"unique_families_played":
			var played_families: int = 0
			for family_progress: Variant in families.values():
				if family_progress is Dictionary and int((family_progress as Dictionary).get("plays", 0)) > 0:
					played_families += 1
			return float(played_families)
		"favorites_count":
			var favorites_value: Variant = ProfileService.profile.get("favorite_challenge_types", [])
			return float((favorites_value as Array).size()) if favorites_value is Array else 0.0
		"program_runs":
			var completed_runs: int = 0
			var program_progress_value: Variant = ProfileService.profile.get("program_progress", {})
			if program_progress_value is Dictionary:
				for program_value: Variant in (program_progress_value as Dictionary).values():
					if program_value is Dictionary:
						completed_runs += int((program_value as Dictionary).get("completed_runs", 0))
			return float(completed_runs)
		"families_mastery_at_least":
			var mastered_families: int = 0
			var threshold: float = float(definition.get("mastery_threshold", 10.0))
			for family_progress: Variant in families.values():
				if family_progress is Dictionary and float((family_progress as Dictionary).get("mastery", 0.0)) >= threshold:
					mastered_families += 1
			return float(mastered_families)
		"best_streak":
			var best: int = 0
			for family_progress: Variant in families.values():
				if family_progress is Dictionary:
					best = maxi(best, int((family_progress as Dictionary).get("best_streak", 0)))
			return float(best)
		"fast_response":
			var threshold_ms: int = int(definition.get("threshold_ms", 1000))
			return 1.0 if result.is_correct() and result.reaction_ms <= threshold_ms else 0.0
		"comeback":
			return 1.0 if _has_comeback(families) else 0.0
	return 0.0

func _has_comeback(families: Dictionary) -> bool:
	for family_progress: Variant in families.values():
		if family_progress is Dictionary:
			var history_value: Variant = (family_progress as Dictionary).get("history", [])
			if history_value is Array:
				var history: Array = history_value
				if history.size() >= 2:
					var previous_value: Variant = history[-2]
					var latest_value: Variant = history[-1]
					if previous_value is Dictionary and latest_value is Dictionary:
						var previous: Dictionary = previous_value
						var latest: Dictionary = latest_value
						if str(previous.get("outcome", "")) != "correct" and str(latest.get("outcome", "")) == "correct":
							return true
	return false

func _load_definitions() -> void:
	_definitions.clear()
	if not FileAccess.file_exists(DEFINITIONS_PATH):
		return
	var file: FileAccess = FileAccess.open(DEFINITIONS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var values: Variant = (parsed as Dictionary).get("achievements", [])
		if values is Array:
			for value: Variant in values:
				if value is Dictionary:
					var definition: Dictionary = (value as Dictionary).duplicate(true)
					if not str(definition.get("id", "")).is_empty():
						_definitions.append(definition)

func _ensure_initialized() -> void:
	if not _initialized:
		initialize()

func _ensure_profile_fields() -> void:
	if not ProfileService:
		return
	if not ProfileService.profile.has("achievements") or not (ProfileService.profile["achievements"] is Array):
		ProfileService.profile["achievements"] = []
	if not ProfileService.profile.has("achievement_progress") or not (ProfileService.profile["achievement_progress"] is Dictionary):
		ProfileService.profile["achievement_progress"] = {}

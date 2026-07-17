extends Node
## Runtime-facing adapter over the validated ProfileService.
## It does not replace save/profile infrastructure.

signal progress_recorded(family_id: String, progress: Dictionary)
signal witness_result_recorded(result: Dictionary, progress: Dictionary)

const WITNESS_PROGRESS_VERSION: int = 1
const MAX_HISTORY: int = 50
const MAX_RECENT_SEEDS: int = 20

var _initialized: bool = false

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_ensure_witness_progress()
	_initialized = true

func get_player_state() -> Dictionary:
	_ensure_witness_progress()
	if ProfileService and ProfileService.profile is Dictionary:
		var state: Dictionary = ProfileService.profile.duplicate(true)
		var preferences: Dictionary = state.get("preferences", {})
		if SettingsService:
			preferences["comfortable_timing"] = bool(SettingsService.get_value("comfortable_timing", false))
			preferences["reading_comfort_mode"] = bool(SettingsService.get_value("reading_comfort_mode", false))
			preferences["color_assist_mode"] = bool(SettingsService.get_value("color_assist_mode", false))
		state["preferences"] = preferences
		return state
	return {}

func get_observation_record() -> Dictionary:
	var player_state: Dictionary = get_player_state()
	var witness: Dictionary = player_state.get("witness_progress", {})
	var stats: Dictionary = player_state.get("stats", {})
	var total: int = int(stats.get("observations_made", 0))
	var correct: int = int(stats.get("correct_observations", 0))
	var witness_history_value: Variant = witness.get("history", [])
	if witness_history_value is Array:
		var witness_history: Array = witness_history_value
		total = maxi(total, witness_history.size())
		var completed_count := 0
		for history_item: Variant in witness_history:
			if history_item is Dictionary and str((history_item as Dictionary).get("completion_status", "")) == "completed":
				completed_count += 1
		correct = maxi(correct, completed_count)
	var fastest: int = int(stats.get("fastest_reaction_ms", 9999))
	var level: int = int(witness.get("witness_level", 1))
	var next_rank: Dictionary = _next_rank_for_level(level)
	return {
		"total_plays": total,
		"correct": correct,
		"accuracy": float(correct) / maxf(float(total), 1.0),
		"fastest_response_ms": -1 if fastest >= 9999 else fastest,
		"current_streak": int(stats.get("streak_current", 0)),
		"best_streak": int(stats.get("streak_best", 0)),
		"witness_level": level,
		"witness_rank": str(witness.get("witness_rank", "Observer")),
		"next_rank": str(next_rank.get("rank", "Top Rank")),
		"next_rank_level": int(next_rank.get("level", level)),
		"total_progress": int(witness.get("total_progress", 0))
	}

func get_recent_history(limit: int = 20) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var player_state: Dictionary = get_player_state()
	var witness: Dictionary = player_state.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	for family_id_value: Variant in families.keys():
		var family_id: String = str(family_id_value)
		var progress_value: Variant = families.get(family_id, {})
		if not (progress_value is Dictionary):
			continue
		var history_value: Variant = (progress_value as Dictionary).get("history", [])
		if not (history_value is Array):
			continue
		var family_title: String = family_id.capitalize()
		var family: ChallengeFamily = ChallengeFamilyRegistry.get_family(family_id) if ChallengeFamilyRegistry else null
		if family != null:
			family_title = family.title
		for history_item: Variant in history_value:
			if history_item is Dictionary:
				var entry: Dictionary = (history_item as Dictionary).duplicate(true)
				entry["family_id"] = family_id
				entry["family_title"] = family_title
				output.append(entry)
	var witness_history_value: Variant = witness.get("history", [])
	if witness_history_value is Array:
		for history_item: Variant in witness_history_value:
			if history_item is Dictionary:
				var entry: Dictionary = (history_item as Dictionary).duplicate(true)
				entry["family_id"] = "witness_runtime"
				entry["family_title"] = str(entry.get("title", entry.get("moment_id", "Witness Moment")))
				entry["outcome"] = str(entry.get("completion_status", "completed"))
				output.append(entry)
	output.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("timestamp", "")) > str(b.get("timestamp", ""))
	)
	if limit >= 0 and output.size() > limit:
		output.resize(limit)
	return output

func get_family_progress(family_id: String) -> Dictionary:
	if not ProfileService:
		return {}
	var witness: Dictionary = ProfileService.profile.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	return (families.get(family_id, {}) as Dictionary).duplicate(true)

func get_favorite_family_ids() -> Array[String]:
	var output: Array[String] = []
	if not ProfileService:
		return output
	var value: Variant = ProfileService.profile.get("favorite_challenge_types", [])
	if value is Array:
		for family_id_value: Variant in value:
			output.append(str(family_id_value))
	return output

func set_family_favorite(family_id: String, favorite: bool) -> bool:
	if not ProfileService or family_id.is_empty():
		return false
	if not ChallengeFamilyRegistry or not ChallengeFamilyRegistry.get_visible_family_ids().has(family_id):
		return false
	var favorites: Array[String] = get_favorite_family_ids()
	if favorite and not favorites.has(family_id):
		favorites.append(family_id)
	elif not favorite:
		favorites.erase(family_id)
	ProfileService.profile["favorite_challenge_types"] = favorites
	if AchievementService:
		AchievementService.evaluate_profile_progress()
	ProfileService.save()
	return true

func get_recent_family_summaries(limit: int = 5) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var seen: Dictionary = {}
	for entry: Dictionary in get_recent_history(MAX_HISTORY):
		var family_id: String = str(entry.get("family_id", ""))
		if family_id.is_empty() or seen.has(family_id):
			continue
		seen[family_id] = true
		output.append({
			"family_id": family_id,
			"family_title": entry.get("family_title", family_id.capitalize()),
			"timestamp": entry.get("timestamp", ""),
			"outcome": entry.get("outcome", ""),
			"template_id": entry.get("template_id", "")
		})
		if output.size() >= limit:
			break
	return output

func has_recent_signature(family_id: String, signature: String) -> bool:
	if signature.is_empty():
		return false
	var progress := get_family_progress(family_id)
	var signatures: Variant = progress.get("recent_signatures", [])
	return signatures is Array and (signatures as Array).has(signature)

func record_result(result: ChallengeResult) -> Dictionary:
	if result == null:
		return {}
	_ensure_witness_progress()
	var declared := result.progress_earned.duplicate(true)
	var progress_key := str(declared.get("record_key", result.replay_metadata.get("progress_key", result.family_id)))
	if ProfileService:
		ProfileService.record_experience_play(progress_key, {
			"score": result.score,
			"correct": result.is_correct(),
			"reaction_ms": result.reaction_ms
		})
	var legacy_progress: Dictionary = ProfileService.get_experience_progress(progress_key) if ProfileService else {}
	var family_progress := _update_witness_progress(result, declared)
	var earned := declared.duplicate(true)
	earned["record_key"] = progress_key
	earned["plays"] = int(legacy_progress.get("played", 0))
	earned["best_score"] = int(legacy_progress.get("best_score", 0))
	earned["score"] = result.score
	earned["family_progress"] = family_progress.duplicate(true)
	result.progress_earned = earned.duplicate(true)
	if AchievementService:
		earned["achievements_unlocked"] = AchievementService.evaluate_after_result(result)
		result.progress_earned = earned.duplicate(true)
	if ProfileService:
		ProfileService.save()
	progress_recorded.emit(result.family_id, earned)
	return earned

func record_witness_runtime_result(result: Dictionary) -> Dictionary:
	if result.is_empty():
		return {}
	_ensure_witness_progress()
	if not ProfileService or not (ProfileService.profile is Dictionary):
		return {}
	var witness: Dictionary = ProfileService.profile.get("witness_progress", {})
	var history: Array = witness.get("history", [])
	var archive_entries: Array = witness.get("archive_entries", [])
	var completed_moment_ids: Array = witness.get("completed_moment_ids", [])
	var completed_incident_ids: Array = witness.get("completed_incident_ids", [])
	var moment_id := str(result.get("moment_id", ""))
	var incident_id := str(result.get("incident_id", ""))
	var completion_status := str(result.get("completion_status", "completed"))
	var progress_points := int(result.get("insight_score", result.get("progress_points", 0)))
	if completion_status == "completed":
		if not moment_id.is_empty() and not completed_moment_ids.has(moment_id):
			completed_moment_ids.append(moment_id)
		if not incident_id.is_empty() and not completed_incident_ids.has(incident_id):
			completed_incident_ids.append(incident_id)
		witness["current_streak"] = int(witness.get("current_streak", 0)) + 1
		witness["best_streak"] = maxi(int(witness.get("best_streak", 0)), int(witness.get("current_streak", 0)))
	else:
		witness["current_streak"] = 0
	witness["completed_moment_ids"] = completed_moment_ids
	witness["completed_incident_ids"] = completed_incident_ids
	witness["total_progress"] = int(witness.get("total_progress", 0)) + maxi(progress_points, 0)
	witness["witness_level"] = 1 + int(float(witness["total_progress"]) / 100.0)
	witness["witness_rank"] = _rank_for_level(int(witness["witness_level"]))
	witness["last_played_moment_id"] = moment_id
	witness["last_played_incident_id"] = incident_id
	witness["last_played_at"] = Time.get_datetime_string_from_system()
	var mastery: Dictionary = witness.get("mastery", {})
	var mastery_delta_value: Variant = result.get("mastery_delta", {})
	if mastery_delta_value is Dictionary:
		for key: Variant in (mastery_delta_value as Dictionary).keys():
			var name := str(key)
			mastery[name] = clampf(float(mastery.get(name, 0.0)) + float((mastery_delta_value as Dictionary).get(key, 0.0)), 0.0, 100.0)
	witness["mastery"] = mastery
	var history_entry := result.duplicate(true)
	history_entry["timestamp"] = Time.get_datetime_string_from_system()
	history_entry["score"] = int(result.get("accuracy_score", 0))
	history.append(history_entry)
	while history.size() > MAX_HISTORY:
		history.pop_front()
	witness["history"] = history
	var archive_payload_value: Variant = result.get("archive_payload", {})
	if archive_payload_value is Dictionary and not (archive_payload_value as Dictionary).is_empty():
		var archive_entry: Dictionary = (archive_payload_value as Dictionary).duplicate(true)
		archive_entry["incident_id"] = incident_id
		archive_entry["moment_id"] = moment_id
		archive_entry["completed_at"] = history_entry["timestamp"]
		archive_entries.append(archive_entry)
		while archive_entries.size() > MAX_HISTORY:
			archive_entries.pop_front()
	witness["archive_entries"] = archive_entries
	witness["iris_evolution_state"] = {
		"witness_level": int(witness.get("witness_level", 1)),
		"witness_rank": str(witness.get("witness_rank", "Observer")),
		"total_progress": int(witness.get("total_progress", 0)),
		"completed_incident_count": completed_incident_ids.size(),
		"completed_moment_count": completed_moment_ids.size(),
		"mastery": mastery.duplicate(true)
	}
	var achievement_ids_value: Variant = result.get("achievement_ids", result.get("achievements", []))
	if achievement_ids_value is Array:
		var achievements: Array = ProfileService.profile.get("achievements", [])
		for achievement_id: Variant in achievement_ids_value:
			if not achievements.has(achievement_id):
				achievements.append(achievement_id)
		ProfileService.profile["achievements"] = achievements
	ProfileService.profile["witness_progress"] = witness
	# Compatibility projection for existing archive/profile readers. PlayerProgressService remains the writer.
	ProfileService.profile["witness_archive"] = archive_entries.duplicate(true)
	ProfileService.profile["witness_moments_completed"] = completed_moment_ids.size()
	ProfileService.save()
	witness_result_recorded.emit(result.duplicate(true), witness.duplicate(true))
	progress_recorded.emit("witness_runtime", witness.duplicate(true))
	return witness.duplicate(true)

func _ensure_witness_progress() -> void:
	if not ProfileService or not (ProfileService.profile is Dictionary):
		return
	if not ProfileService.profile.has("witness_progress") or not (ProfileService.profile["witness_progress"] is Dictionary):
		ProfileService.profile["witness_progress"] = {
			"version": WITNESS_PROGRESS_VERSION,
			"total_progress": 0,
			"witness_level": 1,
			"witness_rank": "Observer",
			"families": {}
		}
	var witness: Dictionary = ProfileService.profile.get("witness_progress", {})
	if not witness.has("families") or not (witness["families"] is Dictionary):
		witness["families"] = {}
	if not witness.has("history") or not (witness["history"] is Array):
		witness["history"] = []
	if not witness.has("archive_entries") or not (witness["archive_entries"] is Array):
		witness["archive_entries"] = []
	if not witness.has("completed_moment_ids") or not (witness["completed_moment_ids"] is Array):
		witness["completed_moment_ids"] = []
	if not witness.has("completed_incident_ids") or not (witness["completed_incident_ids"] is Array):
		witness["completed_incident_ids"] = []
	if not witness.has("mastery") or not (witness["mastery"] is Dictionary):
		witness["mastery"] = {}
	if not witness.has("iris_evolution_state") or not (witness["iris_evolution_state"] is Dictionary):
		witness["iris_evolution_state"] = {}
	ProfileService.profile["witness_progress"] = witness

func _update_witness_progress(result: ChallengeResult, declared: Dictionary) -> Dictionary:
	if not ProfileService:
		return {}
	var witness: Dictionary = ProfileService.profile.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	var entry: Dictionary = families.get(result.family_id, {
		"plays": 0,
		"correct": 0,
		"accuracy": 0.0,
		"mastery": 0.0,
		"confidence": 0.0,
		"current_streak": 0,
		"best_streak": 0,
		"incorrect_streak": 0,
		"progress_points": 0,
		"recent_templates": [],
		"recent_seeds": [],
		"recent_signatures": [],
		"question_history": {},
		"history": []
	})
	entry["plays"] = int(entry.get("plays", 0)) + 1
	if result.is_correct():
		entry["correct"] = int(entry.get("correct", 0)) + 1
		entry["current_streak"] = int(entry.get("current_streak", 0)) + 1
		entry["best_streak"] = maxi(int(entry.get("best_streak", 0)), int(entry["current_streak"]))
		entry["incorrect_streak"] = 0
	else:
		entry["current_streak"] = 0
		entry["incorrect_streak"] = int(entry.get("incorrect_streak", 0)) + 1
	entry["accuracy"] = float(entry.get("correct", 0)) / maxf(float(entry.get("plays", 1)), 1.0)
	var progress_points := int(declared.get("progress_points", 0))
	entry["progress_points"] = int(entry.get("progress_points", 0)) + progress_points

	var mastery_value: Variant = declared.get("mastery_change", {})
	if mastery_value is Dictionary:
		entry["mastery"] = clampf(float((mastery_value as Dictionary).get("new_mastery", entry.get("mastery", 0.0))), 0.0, 100.0)
		entry["confidence"] = clampf(float((mastery_value as Dictionary).get("confidence", entry.get("confidence", 0.0))), 0.0, 1.0)

	var recent_templates: Array = entry.get("recent_templates", [])
	recent_templates.append(result.template_id)
	while recent_templates.size() > 10:
		recent_templates.pop_front()
	entry["recent_templates"] = recent_templates

	var recent_seeds: Array = entry.get("recent_seeds", [])
	recent_seeds.append(int(result.replay_metadata.get("seed", 0)))
	while recent_seeds.size() > MAX_RECENT_SEEDS:
		recent_seeds.pop_front()
	entry["recent_seeds"] = recent_seeds

	var recent_signatures: Array = entry.get("recent_signatures", [])
	var scene_signature := str(result.metadata.get("scene_signature", ""))
	if not scene_signature.is_empty():
		recent_signatures.append(scene_signature)
	while recent_signatures.size() > MAX_RECENT_SEEDS:
		recent_signatures.pop_front()
	entry["recent_signatures"] = recent_signatures

	var history_entry: Dictionary = declared.get("history_entry", {}).duplicate(true)
	history_entry["template_id"] = result.template_id
	history_entry["outcome"] = result.outcome
	history_entry["score"] = result.score
	history_entry["seed"] = int(result.replay_metadata.get("seed", 0))
	history_entry["scene_signature"] = scene_signature
	history_entry["difficulty"] = result.difficulty_performance.duplicate(true)
	history_entry["timestamp"] = Time.get_datetime_string_from_system()
	var history: Array = entry.get("history", [])
	history.append(history_entry)
	while history.size() > MAX_HISTORY:
		history.pop_front()
	entry["history"] = history

	var question_type := str(history_entry.get("question_type", "unknown"))
	var question_history: Dictionary = entry.get("question_history", {})
	var question_entry: Dictionary = question_history.get(question_type, {"plays": 0, "correct": 0})
	question_entry["plays"] = int(question_entry.get("plays", 0)) + 1
	if result.is_correct():
		question_entry["correct"] = int(question_entry.get("correct", 0)) + 1
	question_history[question_type] = question_entry
	entry["question_history"] = question_history

	families[result.family_id] = entry
	witness["families"] = families
	witness["total_progress"] = int(witness.get("total_progress", 0)) + progress_points
	witness["witness_level"] = 1 + int(float(witness["total_progress"]) / 100.0)
	witness["witness_rank"] = _rank_for_level(int(witness["witness_level"]))
	witness["last_played_family_id"] = result.family_id
	witness["last_played_template_id"] = result.template_id
	witness["last_played_at"] = Time.get_datetime_string_from_system()
	witness["version"] = WITNESS_PROGRESS_VERSION
	ProfileService.profile["witness_progress"] = witness
	return entry

func _next_rank_for_level(level: int) -> Dictionary:
	if level < 3:
		return {"rank": "Noticer", "level": 3}
	if level < 6:
		return {"rank": "Attentive Witness", "level": 6}
	if level < 12:
		return {"rank": "Sharp Witness", "level": 12}
	if level < 20:
		return {"rank": "Master Witness", "level": 20}
	return {"rank": "Top Rank", "level": level}

func _rank_for_level(level: int) -> String:
	if level >= 20:
		return "Master Witness"
	if level >= 12:
		return "Sharp Witness"
	if level >= 6:
		return "Attentive Witness"
	if level >= 3:
		return "Noticer"
	return "Observer"

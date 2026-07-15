extends Node
## Data-driven curated challenge journeys. Programs select registered runtime
## content; they never generate, score, present, or navigate challenges.

signal program_started(program_id: String)
signal program_progress_updated(program_id: String, progress: Dictionary)
signal program_completed(program_id: String, completed_runs: int)

const DEFINITIONS_PATH: String = "res://src/gameplay/programs/programs.json"

var _initialized: bool = false
var _definitions: Array[Dictionary] = []

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_load_definitions()
	_ensure_profile_fields()
	_initialized = true

func get_definitions() -> Array[Dictionary]:
	_ensure_initialized()
	return _definitions.duplicate(true)

func get_programs(player_state: Dictionary) -> Array[Dictionary]:
	_ensure_initialized()
	var output: Array[Dictionary] = []
	var witness: Dictionary = player_state.get("witness_progress", {})
	var level: int = int(witness.get("witness_level", 1))
	var progress_by_program: Dictionary = player_state.get("program_progress", {})
	for definition: Dictionary in _definitions:
		var program_id: String = str(definition.get("id", ""))
		var status: Dictionary = definition.duplicate(true)
		var progress_value: Variant = progress_by_program.get(program_id, {})
		var progress: Dictionary = _normalized_progress(
			(progress_value as Dictionary) if progress_value is Dictionary else {},
			int(definition.get("round_count", 1))
		)
		var scheduled: bool = _is_scheduled_now(str(definition.get("schedule", "always")))
		var required_level: int = int(definition.get("required_level", 1))
		status["progress"] = progress
		status["scheduled"] = scheduled
		status["locked"] = level < required_level
		status["available"] = scheduled and level >= required_level
		status["action_label"] = "RESUME" if int(progress.get("current_run_round", 0)) > 0 else "START RUN"
		output.append(status)
	return output

func get_program(program_id: String, player_state: Dictionary = {}) -> Dictionary:
	for status: Dictionary in get_programs(player_state if not player_state.is_empty() else _player_state()):
		if str(status.get("id", "")) == program_id:
			return status
	return {}

func get_featured_program(player_state: Dictionary) -> Dictionary:
	var available: Array[Dictionary] = []
	for program: Dictionary in get_programs(player_state):
		if bool(program.get("available", false)):
			available.append(program)
	if available.is_empty():
		return {}
	var day_key: String = Time.get_date_string_from_system()
	return available[absi(day_key.hash()) % available.size()].duplicate(true)

func begin_program(program_id: String) -> bool:
	_ensure_initialized()
	var status: Dictionary = get_program(program_id)
	if status.is_empty() or not bool(status.get("available", false)) or not ProfileService:
		return false
	ProfileService.profile["active_program_id"] = program_id
	ProfileService.save()
	program_started.emit(program_id)
	if AnalyticsService:
		AnalyticsService.log_event("program_started", {"program_id": program_id})
	return true

func get_resume_program_id(player_state: Dictionary) -> String:
	var program_id: String = str(player_state.get("active_program_id", ""))
	if program_id.is_empty():
		return ""
	var status: Dictionary = get_program(program_id, player_state)
	if status.is_empty() or not bool(status.get("available", false)):
		return ""
	var progress: Dictionary = status.get("progress", {})
	return program_id if int(progress.get("current_run_round", 0)) > 0 else ""

func recommend_continue(player_state: Dictionary) -> Dictionary:
	var program_id: String = get_resume_program_id(player_state)
	return recommend_for_program(program_id, player_state) if not program_id.is_empty() else {}

func recommend_for_program(program_id: String, player_state: Dictionary) -> Dictionary:
	var status: Dictionary = get_program(program_id, player_state)
	if status.is_empty() or not bool(status.get("available", false)):
		return {}
	var catalog: Array[Dictionary] = RecommendationService.get_available_challenge_types(player_state) if RecommendationService else []
	var candidates: Array[Dictionary] = []
	for item: Dictionary in catalog:
		if not bool(item.get("locked", false)):
			candidates.append(item)
	if candidates.is_empty():
		return {}
	var policy: String = str(status.get("selection_policy", "mixed_rotation"))
	var used_fallback: bool = false
	if policy == "focus_tags":
		var focused: Array[Dictionary] = _filter_by_focus(candidates, status.get("focus_tags", []))
		if not focused.is_empty():
			candidates = focused
		else:
			used_fallback = true
	elif policy == "favorites":
		var favorites: Array[Dictionary] = _filter_by_favorites(candidates, player_state)
		if not favorites.is_empty():
			candidates = favorites
		else:
			used_fallback = true
	var progress: Dictionary = status.get("progress", {})
	var round_index: int = int(progress.get("current_run_round", 0))
	var selected: Dictionary
	if policy == "daily_rotation":
		var day_key: String = Time.get_date_string_from_system()
		selected = candidates[(absi(day_key.hash()) + round_index) % candidates.size()]
	else:
		selected = _least_used_candidate(candidates, progress, round_index)
	var family_id: String = str(selected.get("family_id", ""))
	var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module(family_id) if ChallengeFamilyRegistry else null
	if module == null:
		return {}
	var templates: Array[ChallengeTemplate] = module.get_templates()
	if templates.is_empty():
		return {}
	var template_index: int = (round_index + absi(program_id.hash())) % templates.size()
	return {
		"program_id": program_id,
		"program_title": status.get("title", "Program"),
		"family_id": family_id,
		"template_id": templates[template_index].template_id,
		"title": selected.get("title", "Challenge"),
		"reason": "program_selection",
		"reason_text": (
			"Using your available Challenge Types until you choose favorites"
			if used_fallback and policy == "favorites"
			else "Round %d of %d in %s" % [
				round_index + 1,
				int(status.get("round_count", 1)),
				str(status.get("title", "Program"))
			]
		),
		"program_round": round_index + 1,
		"program_round_count": int(status.get("round_count", 1))
	}

func record_result(program_id: String, result: ChallengeResult) -> Dictionary:
	_ensure_initialized()
	if program_id.is_empty() or result == null or not ProfileService:
		return {}
	var definition: Dictionary = _definition(program_id)
	if definition.is_empty():
		return {}
	var progress_by_program: Dictionary = ProfileService.profile.get("program_progress", {})
	var entry_value: Variant = progress_by_program.get(program_id, {})
	var entry: Dictionary = _normalized_progress(
		(entry_value as Dictionary) if entry_value is Dictionary else {},
		int(definition.get("round_count", 1))
	)
	entry["rounds_completed"] = int(entry.get("rounds_completed", 0)) + 1
	entry["current_run_round"] = int(entry.get("current_run_round", 0)) + 1
	if result.is_correct():
		entry["correct"] = int(entry.get("correct", 0)) + 1
		entry["current_run_correct"] = int(entry.get("current_run_correct", 0)) + 1
	entry["accuracy"] = float(entry.get("correct", 0)) / maxf(float(entry.get("rounds_completed", 1)), 1.0)
	entry["last_played"] = Time.get_datetime_string_from_system()
	var family_counts: Dictionary = entry.get("family_counts", {})
	family_counts[result.family_id] = int(family_counts.get(result.family_id, 0)) + 1
	entry["family_counts"] = family_counts
	entry["last_family_id"] = result.family_id
	var run_completed: bool = int(entry["current_run_round"]) >= int(definition.get("round_count", 1))
	var completed_rounds: int = int(entry["current_run_round"])
	if run_completed:
		entry["completed_runs"] = int(entry.get("completed_runs", 0)) + 1
		var run_accuracy: float = float(entry.get("current_run_correct", 0)) / maxf(float(completed_rounds), 1.0)
		entry["best_run_accuracy"] = maxf(float(entry.get("best_run_accuracy", 0.0)), run_accuracy)
		entry["last_run_accuracy"] = run_accuracy
		entry["current_run_round"] = 0
		entry["current_run_correct"] = 0
		ProfileService.profile["active_program_id"] = ""
	program_progress_updated.emit(program_id, entry.duplicate(true))
	if run_completed:
		program_completed.emit(program_id, int(entry.get("completed_runs", 0)))
	progress_by_program[program_id] = entry
	ProfileService.profile["program_progress"] = progress_by_program
	ProfileService.save()
	if AnalyticsService:
		AnalyticsService.log_event("program_round_completed", {
			"program_id": program_id,
			"round": completed_rounds,
			"run_completed": run_completed,
			"outcome": result.outcome
		})
	return {
		"program_id": program_id,
		"program_title": definition.get("title", "Program"),
		"round": completed_rounds,
		"round_count": int(definition.get("round_count", 1)),
		"run_completed": run_completed,
		"completed_runs": int(entry.get("completed_runs", 0)),
		"progress": entry.duplicate(true)
	}

func get_completed_run_count() -> int:
	if not ProfileService:
		return 0
	var total: int = 0
	var progress_by_program: Dictionary = ProfileService.profile.get("program_progress", {})
	for value: Variant in progress_by_program.values():
		if value is Dictionary:
			total += int((value as Dictionary).get("completed_runs", 0))
	return total

func _least_used_candidate(candidates: Array[Dictionary], progress: Dictionary, round_index: int) -> Dictionary:
	var family_counts: Dictionary = progress.get("family_counts", {})
	var recent_family: String = str(progress.get("last_family_id", ""))
	var sorted: Array[Dictionary] = candidates.duplicate(true)
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_id: String = str(a.get("family_id", ""))
		var b_id: String = str(b.get("family_id", ""))
		var a_score: int = int(family_counts.get(a_id, 0)) * 10 + (5 if a_id == recent_family and sorted.size() > 1 else 0)
		var b_score: int = int(family_counts.get(b_id, 0)) * 10 + (5 if b_id == recent_family and sorted.size() > 1 else 0)
		if a_score == b_score:
			return (absi(a_id.hash()) + round_index) < (absi(b_id.hash()) + round_index)
		return a_score < b_score
	)
	var selected: Dictionary = sorted[0]
	progress["last_family_id"] = selected.get("family_id", "")
	return selected

func _filter_by_focus(candidates: Array[Dictionary], tags_value: Variant) -> Array[Dictionary]:
	var tags: Array = tags_value if tags_value is Array else []
	var output: Array[Dictionary] = []
	for item: Dictionary in candidates:
		var focus_value: Variant = item.get("gameplay_focus", [])
		var focus: Array = focus_value if focus_value is Array else []
		var matches: bool = false
		for tag_value: Variant in tags:
			for focus_value_item: Variant in focus:
				if str(tag_value).to_lower() == str(focus_value_item).to_lower():
					matches = true
					break
			if matches:
				break
		if matches:
			output.append(item)
	return output

func _filter_by_favorites(candidates: Array[Dictionary], player_state: Dictionary) -> Array[Dictionary]:
	var favorites_value: Variant = player_state.get("favorite_challenge_types", [])
	var favorites: Array = favorites_value if favorites_value is Array else []
	var output: Array[Dictionary] = []
	for item: Dictionary in candidates:
		if favorites.has(str(item.get("family_id", ""))):
			output.append(item)
	return output

func _normalized_progress(source: Dictionary, round_count: int) -> Dictionary:
	return {
		"rounds_completed": int(source.get("rounds_completed", 0)),
		"correct": int(source.get("correct", 0)),
		"accuracy": float(source.get("accuracy", 0.0)),
		"current_run_round": clampi(int(source.get("current_run_round", 0)), 0, maxi(round_count - 1, 0)),
		"current_run_correct": int(source.get("current_run_correct", 0)),
		"completed_runs": int(source.get("completed_runs", 0)),
		"best_run_accuracy": float(source.get("best_run_accuracy", 0.0)),
		"last_run_accuracy": float(source.get("last_run_accuracy", 0.0)),
		"last_played": str(source.get("last_played", "")),
		"last_family_id": str(source.get("last_family_id", "")),
		"family_counts": (source.get("family_counts", {}) as Dictionary).duplicate(true)
	}

func _is_scheduled_now(schedule: String) -> bool:
	if schedule != "weekend":
		return true
	var date: Dictionary = Time.get_datetime_dict_from_system()
	var weekday: int = int(date.get("weekday", -1))
	return weekday == Time.WEEKDAY_SUNDAY or weekday == Time.WEEKDAY_SATURDAY

func _definition(program_id: String) -> Dictionary:
	for definition: Dictionary in _definitions:
		if str(definition.get("id", "")) == program_id:
			return definition
	return {}

func _player_state() -> Dictionary:
	return PlayerProgressService.get_player_state() if PlayerProgressService else (ProfileService.profile.duplicate(true) if ProfileService else {})

func _load_definitions() -> void:
	_definitions.clear()
	if not FileAccess.file_exists(DEFINITIONS_PATH):
		return
	var file: FileAccess = FileAccess.open(DEFINITIONS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	var programs_value: Variant = (parsed as Dictionary).get("programs", [])
	if not (programs_value is Array):
		return
	for value: Variant in programs_value:
		if value is Dictionary and not str((value as Dictionary).get("id", "")).is_empty():
			_definitions.append((value as Dictionary).duplicate(true))

func _ensure_profile_fields() -> void:
	if not ProfileService:
		return
	if not ProfileService.profile.has("program_progress") or not (ProfileService.profile["program_progress"] is Dictionary):
		ProfileService.profile["program_progress"] = {}
	if not ProfileService.profile.has("active_program_id"):
		ProfileService.profile["active_program_id"] = ""

func _ensure_initialized() -> void:
	if not _initialized:
		initialize()

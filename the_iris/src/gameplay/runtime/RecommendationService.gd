extends Node
## Data-driven product recommendations across visible registered Challenge Types.
## Home and the Challenge Library consume this service instead of naming families.

signal recommendation_created(recommendation: Dictionary)

var _initialized: bool = false

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_initialized = true

func recommend_start(player_state: Dictionary) -> Dictionary:
	var available: Array[Dictionary] = get_available_challenge_types(player_state)
	if available.is_empty():
		return {}
	var witness: Dictionary = player_state.get("witness_progress", {})
	var last_family: String = str(witness.get("last_played_family_id", ""))
	# Introduce every available type before balancing mastery and play count.
	for item: Dictionary in available:
		var progress: Dictionary = item.get("progress", {})
		if not bool(item.get("locked", false)) and int(progress.get("plays", 0)) == 0:
			return _emit(_recommendation_for_item(
				item,
				"unplayed_challenge_type",
				"Try a Challenge Type you have not played yet"
			))
	var candidates: Array[Dictionary] = []
	for item: Dictionary in available:
		if not bool(item.get("locked", false)):
			candidates.append(item)
	if candidates.is_empty():
		return {}
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_progress: Dictionary = a.get("progress", {})
		var b_progress: Dictionary = b.get("progress", {})
		var a_repeat_penalty: float = 25.0 if str(a.get("family_id", "")) == last_family and candidates.size() > 1 else 0.0
		var b_repeat_penalty: float = 25.0 if str(b.get("family_id", "")) == last_family and candidates.size() > 1 else 0.0
		var a_weight_bonus: float = float(a.get("recommendation_weight", 1.0)) * 2.0
		var b_weight_bonus: float = float(b.get("recommendation_weight", 1.0)) * 2.0
		var a_score: float = float(a_progress.get("mastery", 0.0)) + float(a_progress.get("plays", 0)) * 0.5 + a_repeat_penalty - a_weight_bonus
		var b_score: float = float(b_progress.get("mastery", 0.0)) + float(b_progress.get("plays", 0)) * 0.5 + b_repeat_penalty - b_weight_bonus
		return a_score < b_score
	)
	return _emit(_recommendation_for_item(
		candidates[0],
		"balanced_witness_progress",
		"Chosen to balance your Witness Progress"
	))

func recommend_continue(player_state: Dictionary) -> Dictionary:
	if ProgramService:
		var program_recommendation: Dictionary = ProgramService.recommend_continue(player_state)
		if not program_recommendation.is_empty():
			program_recommendation["reason"] = "continue_program"
			program_recommendation["reason_text"] = "Resume %s" % str(program_recommendation.get("program_title", "your curated run"))
			program_recommendation["is_fallback"] = false
			return _emit(program_recommendation)
	var witness: Dictionary = player_state.get("witness_progress", {})
	var family_id: String = str(witness.get("last_played_family_id", ""))
	var template_id: String = str(witness.get("last_played_template_id", ""))
	var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module(family_id) if ChallengeFamilyRegistry else null
	if module != null and _is_unlocked(module.get_family(), player_state):
		if template_id.is_empty() or module.get_template(template_id) == null:
			template_id = module.get_default_template_id()
		var item: Dictionary = _find_available_item(family_id, player_state)
		var recommendation: Dictionary = _recommendation_for_item(
			item,
			"continue_recent_type",
			"Continue your most recently played Challenge Type"
		)
		recommendation["template_id"] = template_id
		recommendation["is_fallback"] = false
		return _emit(recommendation)
	var fallback: Dictionary = recommend_start(player_state)
	if not fallback.is_empty():
		fallback["reason"] = "continue_fallback"
		fallback["reason_text"] = "No recent round yet — starting your recommendation"
		fallback["is_fallback"] = true
	return fallback

func recommend_featured(player_state: Dictionary) -> Dictionary:
	var available: Array[Dictionary] = get_available_challenge_types(player_state)
	var unlocked: Array[Dictionary] = []
	for item: Dictionary in available:
		if not bool(item.get("locked", false)):
			unlocked.append(item)
	if unlocked.is_empty():
		return {}
	var day_key: String = Time.get_date_string_from_system()
	var index: int = absi(day_key.hash()) % unlocked.size()
	return _emit(_recommendation_for_item(
		unlocked[index],
		"daily_featured_rotation",
		"Today’s featured Challenge Type"
	))

func get_available_challenge_types(player_state: Dictionary) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	if not ChallengeFamilyRegistry:
		return output
	var witness: Dictionary = player_state.get("witness_progress", {})
	var progress_by_family: Dictionary = witness.get("families", {})
	var level: int = int(witness.get("witness_level", 1))
	var favorites_value: Variant = player_state.get("favorite_challenge_types", [])
	var favorites: Array = favorites_value if favorites_value is Array else []
	for family_id: String in ChallengeFamilyRegistry.get_visible_family_ids():
		var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module(family_id)
		if module == null:
			continue
		var family: ChallengeFamily = module.get_family()
		var required_level: int = int(family.metadata.get("witness_level_required", 1))
		var progress_value: Variant = progress_by_family.get(family_id, {})
		var progress: Dictionary = _normalized_progress(
			(progress_value as Dictionary) if progress_value is Dictionary else {}
		)
		var default_template_id: String = module.get_default_template_id()
		var preview_image: String = str(family.metadata.get("preview_image", ""))
		output.append({
			"family_id": family_id,
			"id": default_template_id,
			"template_id": default_template_id,
			"default_template_id": default_template_id,
			"title": family.title,
			"description": family.description,
			"short_description": family.description,
			"gameplay_focus": family.gameplay_focus.duplicate(),
			"recommendation_weight": float(family.metadata.get("recommendation_weight", 1.0)),
			"favorite": favorites.has(family_id),
			"preview_image": preview_image,
			"image_path": preview_image,
			"required_level": required_level,
			"locked": level < required_level,
			"is_locked": level < required_level,
			"coming_soon": false,
			"category": "Challenge Type",
			"estimated_duration_sec": int(family.metadata.get("estimated_round_seconds", 15)),
			"progress": progress,
			"tutorial_profile": module.get_tutorial_profile().to_dictionary()
		})
	return output

func get_home_snapshot(player_state: Dictionary) -> Dictionary:
	var available: Array[Dictionary] = get_available_challenge_types(player_state)
	var witness: Dictionary = player_state.get("witness_progress", {})
	var stats: Dictionary = player_state.get("stats", {})
	var recent_family_id: String = str(witness.get("last_played_family_id", ""))
	var recent: Dictionary = _find_item_in_list(recent_family_id, available)
	var achievements: Array[Dictionary] = []
	if AchievementService:
		achievements = AchievementService.get_featured_statuses(3)
	var featured_program: Dictionary = ProgramService.get_featured_program(player_state) if ProgramService else {}
	return {
		"play_now": recommend_start(player_state),
		"continue": recommend_continue(player_state),
		"featured": recommend_featured(player_state),
		"available_challenge_types": available,
		"recent": recent,
		"has_recent": not recent.is_empty(),
		"achievements_in_progress": achievements,
		"featured_program": featured_program,
		"program_count": ProgramService.get_definitions().size() if ProgramService else 0,
		"witness_summary": {
			"level": int(witness.get("witness_level", 1)),
			"rank": str(witness.get("witness_rank", "Observer")),
			"progress_points": int(witness.get("total_progress", 0)),
			"current_streak": int(stats.get("streak_current", 0)),
			"best_streak": int(stats.get("streak_best", 0))
		}
	}

func recommend_next(
	player_state: Dictionary,
	family_id: String,
	current_template_id: String,
	_result: ChallengeResult
) -> Dictionary:
	var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module(family_id) if ChallengeFamilyRegistry else null
	if module == null:
		return recommend_start(player_state)
	var templates: Array[ChallengeTemplate] = module.get_templates()
	if templates.is_empty():
		return {}
	var current_index: int = -1
	for index: int in range(templates.size()):
		if templates[index].template_id == current_template_id:
			current_index = index
			break
	var next_index: int = 0 if current_index < 0 else (current_index + 1) % templates.size()
	var item: Dictionary = _find_available_item(family_id, player_state)
	var recommendation: Dictionary = _recommendation_for_item(
		item,
		"continue_current_type",
		"Keep your current Challenge Type moving"
	)
	# Hidden regression/test families still participate in the generic session
	# pipeline even though they are intentionally absent from the product catalog.
	if recommendation.is_empty():
		var family: ChallengeFamily = module.get_family()
		recommendation = {
			"family_id": family_id,
			"title": family.title,
			"reason": "continue_current_type",
			"reason_text": "Keep your current Challenge Type moving"
		}
	recommendation["template_id"] = templates[next_index].template_id
	return _emit(recommendation)

func is_family_unlocked(family_id: String, player_state: Dictionary) -> bool:
	var family: ChallengeFamily = ChallengeFamilyRegistry.get_family(family_id) if ChallengeFamilyRegistry else null
	return family != null and _is_unlocked(family, player_state)

func _normalized_progress(source: Dictionary) -> Dictionary:
	var plays: int = int(source.get("plays", 0))
	var correct: int = int(source.get("correct", 0))
	return {
		"plays": plays,
		"correct": correct,
		"accuracy": float(source.get("accuracy", float(correct) / maxf(float(plays), 1.0))),
		"mastery": clampf(float(source.get("mastery", 0.0)), 0.0, 100.0),
		"confidence": clampf(float(source.get("confidence", 0.0)), 0.0, 1.0),
		"current_streak": int(source.get("current_streak", 0)),
		"best_streak": int(source.get("best_streak", 0)),
		"progress_points": int(source.get("progress_points", 0))
	}

func _find_available_item(family_id: String, player_state: Dictionary) -> Dictionary:
	return _find_item_in_list(family_id, get_available_challenge_types(player_state))

func _find_item_in_list(family_id: String, items: Array[Dictionary]) -> Dictionary:
	for item: Dictionary in items:
		if str(item.get("family_id", "")) == family_id:
			return item.duplicate(true)
	return {}

func _recommendation_for_item(item: Dictionary, reason: String, reason_text: String) -> Dictionary:
	if item.is_empty():
		return {}
	return {
		"family_id": item.get("family_id", ""),
		"template_id": item.get("default_template_id", ""),
		"title": item.get("title", "Challenge"),
		"description": item.get("description", ""),
		"preview_image": item.get("preview_image", ""),
		"reason": reason,
		"reason_text": reason_text
	}

func _is_unlocked(family: ChallengeFamily, player_state: Dictionary) -> bool:
	var witness: Dictionary = player_state.get("witness_progress", {})
	return int(witness.get("witness_level", 1)) >= int(family.metadata.get("witness_level_required", 1))

func _emit(recommendation: Dictionary) -> Dictionary:
	var copy: Dictionary = recommendation.duplicate(true)
	recommendation_created.emit(copy)
	return copy

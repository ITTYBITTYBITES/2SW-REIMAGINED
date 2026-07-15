extends ScoringPolicy
class_name SceneInvestigationScoringPolicy
## Production family-owned scoring and Witness Progress declaration.

const VERSION: String = "1"
const BASE_CORRECT_SCORE: int = 800
const MAX_DIFFICULTY_BONUS: int = 150

func get_version() -> String:
	return VERSION

func calculate_result(
	instance: ChallengeInstance,
	player_response: Variant,
	response_context: Dictionary
) -> Dictionary:
	var accepted := str(player_response) == str(instance.correct_answer)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accuracy": 1.0 if accepted else 0.0,
		"accepted": accepted,
		"correct_answer": instance.correct_answer,
		"player_response": player_response,
		"response_mode": "single_choice",
		"question_type": str(instance.metadata.get("question_type", "unknown")),
		"difficulty_label": instance.difficulty_label,
		"difficulty_axes": instance.difficulty_axes.duplicate(true),
		"reaction_ms": int(response_context.get("reaction_ms", 0))
	}

func calculate_score(resolved_result: Dictionary, _template: ChallengeTemplate) -> int:
	if not bool(resolved_result.get("accepted", false)):
		return 0
	var axes_value: Variant = resolved_result.get("difficulty_axes", {})
	var axes: Dictionary = axes_value if axes_value is Dictionary else {}
	var object_factor := clampf((float(axes.get("object_count_max", 8)) - 8.0) / 10.0, 0.0, 1.0)
	var similarity := clampf(float(axes.get("similarity", 0.0)), 0.0, 1.0)
	var question_complexity := clampf(float(axes.get("question_complexity", 0.0)), 0.0, 1.0)
	var scene_complexity := clampf(float(axes.get("scene_complexity", 0.0)), 0.0, 1.0)
	var resolved_complexity := (object_factor + similarity + question_complexity + scene_complexity) / 4.0
	var difficulty_bonus := int(round(resolved_complexity * float(MAX_DIFFICULTY_BONUS)))
	return mini(BASE_CORRECT_SCORE + difficulty_bonus, 1000)

func calculate_progress(
	resolved_result: Dictionary,
	score: int,
	_player_state: Dictionary
) -> Dictionary:
	var accepted := bool(resolved_result.get("accepted", false))
	var progress_points := 12 if accepted else 2
	return {
		"record_key": "scene_investigation",
		"progress_points": progress_points,
		"accuracy_delta": float(resolved_result.get("accuracy", 0.0)),
		"streak_action": "increase" if accepted else "reset",
		"history_entry": {
			"question_type": resolved_result.get("question_type", "unknown"),
			"score": score
		}
	}

func calculate_mastery_change(
	resolved_result: Dictionary,
	_score: int,
	player_state: Dictionary
) -> Dictionary:
	var previous := _current_mastery(player_state)
	var accepted := bool(resolved_result.get("accepted", false))
	var delta := 1.5 if accepted else -0.25
	delta = clampf(delta, -0.5, 3.0)
	var next := clampf(previous + delta, 0.0, 100.0)
	var plays := _current_plays(player_state)
	return {
		"family_id": "scene_investigation",
		"previous_mastery": previous,
		"new_mastery": next,
		"delta": next - previous,
		"confidence": clampf(float(plays + 1) / 20.0, 0.05, 1.0)
	}

func explain_outcome(
	instance: ChallengeInstance,
	_player_response: Variant,
	resolved_result: Dictionary
) -> Dictionary:
	var accepted := bool(resolved_result.get("accepted", false))
	return {
		"summary": "Sharp observation" if accepted else "Easy detail to miss",
		"explanation": instance.explanation,
		"where_to_look": str(instance.metadata.get("where_to_look", "the highlighted area")),
		"reveal_data": {
			"generated_scene": instance.generated_scene.duplicate(true),
			"question": instance.question.duplicate(true),
			"highlight_ids": instance.metadata.get("highlight_ids", [])
		}
	}

func _current_mastery(player_state: Dictionary) -> float:
	return float(_family_progress(player_state).get("mastery", 0.0))

func _current_plays(player_state: Dictionary) -> int:
	return int(_family_progress(player_state).get("plays", 0))

func _family_progress(player_state: Dictionary) -> Dictionary:
	var witness: Variant = player_state.get("witness_progress", {})
	if not (witness is Dictionary):
		return {}
	var families: Variant = (witness as Dictionary).get("families", {})
	if not (families is Dictionary):
		return {}
	var progress: Variant = (families as Dictionary).get("scene_investigation", {})
	return (progress as Dictionary) if progress is Dictionary else {}

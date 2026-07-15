extends RefCounted
class_name ScoringPolicy
## Family-owned response interpretation and progress declaration contract.
## Shared runtime code executes this policy without understanding the mechanic.

func get_version() -> String:
	return "0"

func calculate_result(
	instance: ChallengeInstance,
	player_response: Variant,
	_response_context: Dictionary
) -> Dictionary:
	var accepted := str(player_response) == str(instance.correct_answer)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accuracy": 1.0 if accepted else 0.0,
		"accepted": accepted,
		"correct_answer": instance.correct_answer,
		"player_response": player_response,
		"response_mode": str(instance.question.get("type", "unknown"))
	}

func calculate_score(
	resolved_result: Dictionary,
	template: ChallengeTemplate
) -> int:
	return int(template.scoring_modifiers.get("correct_score", 100)) if bool(resolved_result.get("accepted", false)) else int(template.scoring_modifiers.get("incorrect_score", 0))

func calculate_progress(
	resolved_result: Dictionary,
	score: int,
	_player_state: Dictionary
) -> Dictionary:
	return {
		"record_key": "",
		"progress_points": score,
		"accuracy_delta": float(resolved_result.get("accuracy", 0.0)),
		"streak_action": "increase" if bool(resolved_result.get("accepted", false)) else "reset",
		"history_entry": {}
	}

func calculate_mastery_change(
	_resolved_result: Dictionary,
	_score: int,
	_player_state: Dictionary
) -> Dictionary:
	return {
		"previous_mastery": 0.0,
		"new_mastery": 0.0,
		"delta": 0.0,
		"confidence": 0.0
	}

func explain_outcome(
	instance: ChallengeInstance,
	_player_response: Variant,
	_resolved_result: Dictionary
) -> Dictionary:
	return {
		"summary": "",
		"explanation": instance.explanation,
		"where_to_look": "",
		"reveal_data": {
			"generated_scene": instance.generated_scene.duplicate(true),
			"question": instance.question.duplicate(true)
		}
	}

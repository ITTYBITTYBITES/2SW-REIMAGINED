extends ScoringPolicy
class_name FixtureSceneInvestigationScoringPolicy
## Family-owned scoring for deterministic regression fixtures.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

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
		"response_mode": "single_choice"
	}

func calculate_score(resolved_result: Dictionary, template: ChallengeTemplate) -> int:
	return int(template.scoring_modifiers.get("correct_score", 100)) if bool(resolved_result.get("accepted", false)) else 0

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
		"history_entry": {"fixture": true}
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
	resolved_result: Dictionary
) -> Dictionary:
	return {
		"summary": "Correct" if bool(resolved_result.get("accepted", false)) else "Not quite",
		"explanation": instance.explanation,
		"where_to_look": str(instance.generated_scene.get("title", "the scene")),
		"reveal_data": {
			"generated_scene": instance.generated_scene.duplicate(true),
			"question": instance.question.duplicate(true),
			"highlight_ids": instance.metadata.get("highlight_ids", [])
		}
	}

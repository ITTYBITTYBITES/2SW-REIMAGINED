extends ScoringPolicy
class_name SpotDifferenceScoringPolicy

func get_version() -> String:
	return "2"

func calculate_result(instance: ChallengeInstance, player_response: Variant, _context: Dictionary) -> Dictionary:
	var accepted: bool = false
	if player_response is Dictionary:
		var x: float = float((player_response as Dictionary).get("x", -1.0))
		var y: float = float((player_response as Dictionary).get("y", -1.0))
		for value: Variant in instance.metadata.get("target_regions", []):
			if value is Dictionary:
				var region: Dictionary = value
				if (
					x >= float(region.get("x", 0.0))
					and x <= float(region.get("x", 0.0)) + float(region.get("w", 0.0))
					and y >= float(region.get("y", 0.0))
					and y <= float(region.get("y", 0.0)) + float(region.get("h", 0.0))
				):
					accepted = true
					break
	else:
		accepted = str(player_response) in [
			str(instance.correct_answer),
			str(instance.metadata.get("target_name", "")),
			str(instance.metadata.get("target_name", "")).capitalize()
		]
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accepted": accepted,
		"accuracy": 1.0 if accepted else 0.0,
		"player_response": player_response,
		"correct_answer": instance.correct_answer,
		"difficulty_axes": instance.difficulty_axes,
		"question_type": instance.metadata.get("question_type", "change")
	}

func calculate_score(resolved_result: Dictionary, _template: ChallengeTemplate) -> int:
	if not bool(resolved_result.get("accepted", false)):
		return 0
	var axes: Dictionary = resolved_result.get("difficulty_axes", {})
	var complexity: float = clampf((float(axes.get("object_count_max", 7)) - 5.0) / 9.0, 0.0, 1.0)
	return mini(800 + int(round(complexity * 150.0)), 950)

func calculate_progress(resolved_result: Dictionary, score: int, _player_state: Dictionary) -> Dictionary:
	var accepted: bool = bool(resolved_result.get("accepted", false))
	return {
		"record_key": "spot_the_difference",
		"progress_points": 12 if accepted else 2,
		"accuracy_delta": 1.0 if accepted else 0.0,
		"streak_action": "increase" if accepted else "reset",
		"history_entry": {"question_type": resolved_result.get("question_type", "change"), "score": score}
	}

func calculate_mastery_change(resolved_result: Dictionary, _score: int, player_state: Dictionary) -> Dictionary:
	var progress := _progress(player_state)
	var previous: float = float(progress.get("mastery", 0.0))
	var delta: float = 1.5 if bool(resolved_result.get("accepted", false)) else -0.25
	var next: float = clampf(previous + delta, 0.0, 100.0)
	return {
		"previous_mastery": previous,
		"new_mastery": next,
		"delta": next - previous,
		"confidence": clampf(float(int(progress.get("plays", 0)) + 1) / 20.0, 0.05, 1.0)
	}

func explain_outcome(instance: ChallengeInstance, _response: Variant, resolved_result: Dictionary) -> Dictionary:
	var reveal_scene: Dictionary = instance.generated_scene.duplicate(true)
	reveal_scene["reveal_mode"] = true
	return {
		"summary": "Change spotted" if bool(resolved_result.get("accepted", false)) else "I missed it.",
		"explanation": instance.explanation,
		"where_to_look": str(instance.metadata.get("where_to_look", "the highlighted detail")),
		"reveal_data": {
			"generated_scene": reveal_scene,
			"highlight_ids": [instance.metadata.get("target_id", "")]
		}
	}

func _progress(state: Dictionary) -> Dictionary:
	var witness: Dictionary = state.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	return (families.get("spot_the_difference", {}) as Dictionary).duplicate(true)

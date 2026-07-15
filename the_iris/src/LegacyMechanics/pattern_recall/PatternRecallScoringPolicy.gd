extends ScoringPolicy
class_name PatternRecallScoringPolicy

func get_version() -> String:
	return "2"

func calculate_result(instance: ChallengeInstance, response: Variant, _context: Dictionary) -> Dictionary:
	var selected: Array = response if response is Array else []
	var accepted: bool = selected == instance.correct_answer
	var matching_prefix: int = 0
	for index: int in range(mini(selected.size(), (instance.correct_answer as Array).size())):
		if str(selected[index]) != str((instance.correct_answer as Array)[index]):
			break
		matching_prefix += 1
	var partial_accuracy := float(matching_prefix) / maxf(float((instance.correct_answer as Array).size()), 1.0)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accepted": accepted,
		"accuracy": 1.0 if accepted else partial_accuracy,
		"player_response": response,
		"correct_answer": instance.correct_answer,
		"difficulty_axes": instance.difficulty_axes,
		"question_type": instance.metadata.get("question_type", "pattern"),
		"matching_prefix": matching_prefix
	}

func calculate_score(resolved: Dictionary, _template: ChallengeTemplate) -> int:
	if not bool(resolved.get("accepted", false)):
		return 0
	var length := int((resolved.get("difficulty_axes", {}) as Dictionary).get("sequence_length", 3))
	return mini(800 + length * 25, 950)

func calculate_progress(resolved: Dictionary, score: int, _state: Dictionary) -> Dictionary:
	var accepted: bool = bool(resolved.get("accepted", false))
	return {
		"record_key": "pattern_recall",
		"progress_points": 12 if accepted else 2,
		"history_entry": {"question_type": resolved.get("question_type", "pattern"), "score": score}
	}

func calculate_mastery_change(resolved: Dictionary, _score: int, state: Dictionary) -> Dictionary:
	var families: Dictionary = (state.get("witness_progress", {}) as Dictionary).get("families", {})
	var progress: Dictionary = families.get("pattern_recall", {})
	var previous: float = float(progress.get("mastery", 0.0))
	var next: float = clampf(previous + (1.5 if bool(resolved.get("accepted", false)) else -0.25), 0.0, 100.0)
	return {
		"previous_mastery": previous,
		"new_mastery": next,
		"delta": next - previous,
		"confidence": clampf(float(int(progress.get("plays", 0)) + 1) / 20.0, 0.05, 1.0)
	}

func explain_outcome(instance: ChallengeInstance, _response: Variant, resolved: Dictionary) -> Dictionary:
	var explanation := instance.explanation
	if not bool(resolved.get("accepted", false)):
		var prefix := int(resolved.get("matching_prefix", 0))
		if prefix > 0:
			explanation += " The first %d step%s matched before the sequence changed." % [prefix, "" if prefix == 1 else "s"]
		else:
			explanation += " The numbered reveal shows where the sequence began."
	var reveal_scene: Dictionary = instance.generated_scene.duplicate(true)
	reveal_scene["reveal_mode"] = true
	return {
		"summary": "Pattern repeated" if bool(resolved.get("accepted", false)) else "I missed it.",
		"explanation": explanation,
		"where_to_look": "the numbered sequence evidence",
		"reveal_data": {
			"generated_scene": reveal_scene,
			"highlight_ids": instance.correct_answer
		}
	}

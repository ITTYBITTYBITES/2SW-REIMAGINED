extends ScoringPolicy
class_name ObjectRecallScoringPolicy

func get_version() -> String:
	return "2"

func calculate_result(instance: ChallengeInstance, response: Variant, _context: Dictionary) -> Dictionary:
	var expected := _string_array(instance.correct_answer)
	expected.sort()
	var selected: Array[String] = []
	if response is Array:
		selected = _string_array(response as Array)
	selected.sort()
	var accepted: bool = selected == expected
	var matches: int = 0
	for value: String in selected:
		if expected.has(value):
			matches += 1
	var union_size: int = expected.size()
	for value: String in selected:
		if not expected.has(value):
			union_size += 1
	var partial_accuracy: float = float(matches) / maxf(float(union_size), 1.0)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accepted": accepted,
		"accuracy": 1.0 if accepted else partial_accuracy,
		"player_response": response,
		"correct_answer": instance.correct_answer,
		"difficulty_axes": instance.difficulty_axes,
		"question_type": instance.metadata.get("question_type", "set")
	}

func calculate_score(resolved: Dictionary, _template: ChallengeTemplate) -> int:
	if not bool(resolved.get("accepted", false)):
		return 0
	var axes: Dictionary = resolved.get("difficulty_axes", {})
	return mini(800 + int(axes.get("shown_count", 3)) * 25, 950)

func calculate_progress(resolved: Dictionary, score: int, _state: Dictionary) -> Dictionary:
	var accepted: bool = bool(resolved.get("accepted", false))
	return {
		"record_key": "object_recall",
		"progress_points": 12 if accepted else 2,
		"history_entry": {"question_type": resolved.get("question_type", "set"), "score": score}
	}

func calculate_mastery_change(resolved: Dictionary, _score: int, state: Dictionary) -> Dictionary:
	var families: Dictionary = (state.get("witness_progress", {}) as Dictionary).get("families", {})
	var progress: Dictionary = families.get("object_recall", {})
	var previous: float = float(progress.get("mastery", 0.0))
	var next: float = clampf(previous + (1.5 if bool(resolved.get("accepted", false)) else -0.25), 0.0, 100.0)
	return {
		"previous_mastery": previous,
		"new_mastery": next,
		"delta": next - previous,
		"confidence": clampf(float(int(progress.get("plays", 0)) + 1) / 20.0, 0.05, 1.0)
	}

func explain_outcome(instance: ChallengeInstance, response: Variant, resolved: Dictionary) -> Dictionary:
	var explanation := instance.explanation
	if not bool(resolved.get("accepted", false)):
		var expected := _string_array(instance.correct_answer)
		var selected: Array[String] = _string_array(response as Array) if response is Array else []
		var missed: Array[String] = []
		var extras: Array[String] = []
		for value: String in expected:
			if not selected.has(value):
				missed.append(value)
		for value: String in selected:
			if not expected.has(value):
				extras.append(value)
		if not missed.is_empty():
			explanation += " Missed: %s." % ", ".join(missed)
		if not extras.is_empty():
			explanation += " Added: %s." % ", ".join(extras)
	var reveal_scene: Dictionary = instance.generated_scene.duplicate(true)
	reveal_scene["reveal_mode"] = true
	return {
		"summary": "Set remembered" if bool(resolved.get("accepted", false)) else "I missed it.",
		"explanation": explanation,
		"where_to_look": str(instance.metadata.get("where_to_look", "the highlighted remembered objects")),
		"reveal_data": {
			"generated_scene": reveal_scene,
			"highlight_ids": instance.correct_answer
		}
	}

func _string_array(values: Array) -> Array[String]:
	var output: Array[String] = []
	for value: Variant in values:
		output.append(str(value))
	return output

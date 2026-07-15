extends ScoringPolicy
class_name FlashWordsScoringPolicy
## Family-owned Flash Words scoring and comparison explanation.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func calculate_result(instance: ChallengeInstance, player_response: Variant, _context: Dictionary) -> Dictionary:
	var accepted := str(player_response) == str(instance.correct_answer)
	return {
		"outcome": "correct" if accepted else "incorrect",
		"accuracy": 1.0 if accepted else 0.0,
		"accepted": accepted,
		"correct_answer": instance.correct_answer,
		"player_response": player_response,
		"response_mode": "single_choice",
		"mode": instance.metadata.get("mode", "single"),
		"presented_words": instance.metadata.get("presented_words", []),
		"difficulty_axes": instance.difficulty_axes.duplicate(true)
	}

func calculate_score(resolved_result: Dictionary, _template: ChallengeTemplate) -> int:
	if not bool(resolved_result.get("accepted", false)):
		return 0
	var axes: Dictionary = resolved_result.get("difficulty_axes", {})
	var length_factor := clampf((float(axes.get("word_length_max", 5)) - 3.0) / 7.0, 0.0, 1.0)
	var similarity := clampf(float(axes.get("similarity", 0.0)), 0.0, 1.0)
	var sequence_factor := clampf((float(axes.get("sequence_length", 1)) - 1.0) / 4.0, 0.0, 1.0)
	return mini(800 + int(round((length_factor + similarity + sequence_factor) / 3.0 * 150.0)), 1000)

func calculate_progress(resolved_result: Dictionary, score: int, _player_state: Dictionary) -> Dictionary:
	var accepted := bool(resolved_result.get("accepted", false))
	return {
		"record_key": "flash_words",
		"progress_points": 12 if accepted else 2,
		"accuracy_delta": float(resolved_result.get("accuracy", 0.0)),
		"streak_action": "increase" if accepted else "reset",
		"history_entry": {
			"mode": resolved_result.get("mode", "single"),
			"score": score,
			"presented_words": resolved_result.get("presented_words", [])
		}
	}

func calculate_mastery_change(resolved_result: Dictionary, _score: int, player_state: Dictionary) -> Dictionary:
	var previous := _current_mastery(player_state)
	var delta := 1.5 if bool(resolved_result.get("accepted", false)) else -0.25
	var next := clampf(previous + delta, 0.0, 100.0)
	return {
		"family_id": "flash_words",
		"previous_mastery": previous,
		"new_mastery": next,
		"delta": next - previous,
		"confidence": clampf(float(_current_plays(player_state) + 1) / 20.0, 0.05, 1.0)
	}

func explain_outcome(instance: ChallengeInstance, player_response: Variant, resolved_result: Dictionary) -> Dictionary:
	var correct := str(instance.correct_answer)
	var selected := str(player_response)
	var difference := _difference(selected, correct, str(instance.metadata.get("mode", "single")), instance.metadata)
	var reveal_scene := instance.generated_scene.duplicate(true)
	reveal_scene["reveal_mode"] = true
	reveal_scene["player_display"] = selected
	reveal_scene["correct_display"] = correct
	reveal_scene["difference"] = difference
	reveal_scene["outcome"] = str(resolved_result.get("outcome", "incorrect"))
	return {
		"summary": "Signal caught" if bool(resolved_result.get("accepted", false)) else "One detail slipped past",
		"explanation": "You selected: %s. The correct response was: %s. Difference: %s" % [selected, correct, difference],
		"where_to_look": "the word and letter comparison",
		"reveal_data": {"generated_scene": reveal_scene, "highlight_ids": []}
	}

func _difference(selected: String, correct: String, mode: String, metadata: Dictionary) -> String:
	if selected == correct:
		return "Exact match"
	if mode == "pair":
		return "The word order or one word changed"
	if mode in ["stream", "position"]:
		return "%s appeared at position %d" % [correct, int(metadata.get("target_position", 0)) + 1]
	var changes: Array[String] = []
	var max_length := maxi(selected.length(), correct.length())
	for index: int in range(max_length):
		var from_char := selected.substr(index, 1) if index < selected.length() else "∅"
		var to_char := correct.substr(index, 1) if index < correct.length() else "∅"
		if from_char != to_char:
			changes.append("%d: %s→%s" % [index + 1, from_char, to_char])
	return ", ".join(changes) if not changes.is_empty() else "Different word"

func _family_progress(player_state: Dictionary) -> Dictionary:
	var witness: Variant = player_state.get("witness_progress", {})
	var families: Variant = (witness as Dictionary).get("families", {}) if witness is Dictionary else {}
	var progress: Variant = (families as Dictionary).get("flash_words", {}) if families is Dictionary else {}
	return (progress as Dictionary) if progress is Dictionary else {}

func _current_mastery(player_state: Dictionary) -> float:
	return float(_family_progress(player_state).get("mastery", 0.0))

func _current_plays(player_state: Dictionary) -> int:
	return int(_family_progress(player_state).get("plays", 0))

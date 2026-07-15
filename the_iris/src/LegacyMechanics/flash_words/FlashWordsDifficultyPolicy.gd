extends DifficultyPolicy
class_name FlashWordsDifficultyPolicy
## Multi-axis Flash Words difficulty policy.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func resolve_difficulty(
	player_state: Dictionary,
	_family: ChallengeFamily,
	template: ChallengeTemplate
) -> Dictionary:
	var progress := _family_progress(player_state)
	var plays := int(progress.get("plays", 0))
	var accuracy := float(progress.get("accuracy", 0.0))
	var mastery := float(progress.get("mastery", 0.0))
	var incorrect_streak := int(progress.get("incorrect_streak", 0))
	var tier := _resolve_tier(plays, accuracy, mastery, incorrect_streak)
	var mode := str(template.metadata.get("mode", "single"))
	var axes := _axes_for(tier, mode)
	axes["reading_comfort_mode"] = bool(SettingsService.get_value("reading_comfort_mode", false)) if SettingsService else false
	axes["recent_words"] = _recent_words(progress)
	return {"label": tier, "axes": axes, "policy_version": VERSION}

func _resolve_tier(plays: int, accuracy: float, mastery: float, incorrect_streak: int) -> String:
	if plays < 3:
		return "beginner"
	if incorrect_streak >= 2:
		return "beginner" if plays < 8 else "standard"
	if plays < 8 or accuracy < 0.60:
		return "standard"
	if mastery >= 75.0 and accuracy >= 0.80:
		return "expert"
	if mastery >= 35.0 and accuracy >= 0.70:
		return "advanced"
	return "standard"

func _axes_for(tier: String, mode: String) -> Dictionary:
	var axes: Dictionary
	match tier:
		"expert":
			axes = {"word_length_min": 6, "word_length_max": 9, "similarity": 0.90, "distractor_categories": ["substitution", "transposition", "orthographic"], "sequence_length": 5}
		"advanced":
			axes = {"word_length_min": 5, "word_length_max": 8, "similarity": 0.70, "distractor_categories": ["substitution", "transposition", "orthographic", "semantic"], "sequence_length": 4}
		"standard":
			axes = {"word_length_min": 4, "word_length_max": 7, "similarity": 0.45, "distractor_categories": ["orthographic", "similar_length", "semantic"], "sequence_length": 3}
		_:
			axes = {"word_length_min": 3, "word_length_max": 6, "similarity": 0.15, "distractor_categories": ["similar_length", "semantic"], "sequence_length": 3}
	if mode == "pair":
		axes["sequence_length"] = 2
	elif mode == "single":
		axes["sequence_length"] = 1
	axes["mode"] = mode
	return axes

func _family_progress(player_state: Dictionary) -> Dictionary:
	var witness: Variant = player_state.get("witness_progress", {})
	if not (witness is Dictionary):
		return {}
	var families: Variant = (witness as Dictionary).get("families", {})
	if not (families is Dictionary):
		return {}
	var progress: Variant = (families as Dictionary).get("flash_words", {})
	return (progress as Dictionary) if progress is Dictionary else {}

func _recent_words(progress: Dictionary) -> Array[String]:
	var words: Array[String] = []
	var history_value: Variant = progress.get("history", [])
	if not (history_value is Array):
		return words
	for entry_value: Variant in (history_value as Array).slice(-12):
		if entry_value is Dictionary:
			var presented: Variant = (entry_value as Dictionary).get("presented_words", [])
			if presented is Array:
				for word: Variant in presented:
					if not words.has(str(word)):
						words.append(str(word))
	return words

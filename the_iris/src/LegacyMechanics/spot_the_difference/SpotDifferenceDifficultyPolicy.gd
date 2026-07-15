extends DifficultyPolicy
class_name SpotDifferenceDifficultyPolicy
## Adaptive density, target size, and one-pass state timing.

const VERSION := "2"

func get_version() -> String:
	return VERSION

func resolve_difficulty(
	player_state: Dictionary,
	family: ChallengeFamily,
	_template: ChallengeTemplate
) -> Dictionary:
	var progress := _family_progress(player_state, family.family_id)
	var plays := int(progress.get("plays", 0))
	var accuracy := float(progress.get("accuracy", 0.0))
	var mastery := float(progress.get("mastery", 0.0))
	var misses := int(progress.get("incorrect_streak", 0))
	var tier := "beginner"
	if plays >= 20 and mastery >= 70.0 and accuracy >= 0.78 and misses == 0:
		tier = "expert"
	elif plays >= 10 and mastery >= 35.0 and accuracy >= 0.62 and misses < 2:
		tier = "advanced"
	elif plays >= 3:
		tier = "standard"
	if misses >= 2:
		tier = "beginner" if plays < 10 else "standard"
	var axes: Dictionary = {
		"beginner": {"object_count_min": 5, "object_count_max": 7, "target_size": 0.18, "similarity": 0.15, "state_duration": 4.8},
		"standard": {"object_count_min": 7, "object_count_max": 10, "target_size": 0.16, "similarity": 0.35, "state_duration": 3.8},
		"advanced": {"object_count_min": 9, "object_count_max": 12, "target_size": 0.14, "similarity": 0.55, "state_duration": 3.0},
		"expert": {"object_count_min": 11, "object_count_max": 14, "target_size": 0.12, "similarity": 0.72, "state_duration": 2.4}
	}.get(tier, {})
	axes["color_assist_mode"] = bool((player_state.get("preferences", {}) as Dictionary).get("color_assist_mode", false))
	return {"label": tier, "policy_version": VERSION, "axes": axes}

func _family_progress(state: Dictionary, family_id: String) -> Dictionary:
	var witness: Dictionary = state.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	return families.get(family_id, {}) as Dictionary

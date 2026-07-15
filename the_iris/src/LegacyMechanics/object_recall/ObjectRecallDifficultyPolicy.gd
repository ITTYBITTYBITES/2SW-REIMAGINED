extends DifficultyPolicy
class_name ObjectRecallDifficultyPolicy
## Adaptive set-size policy with recovery after repeated misses.

const VERSION := "2"

func get_version() -> String:
	return VERSION

func resolve_difficulty(
	player_state: Dictionary,
	family: ChallengeFamily,
	_template: ChallengeTemplate
) -> Dictionary:
	var witness: Dictionary = player_state.get("witness_progress", {})
	var families: Dictionary = witness.get("families", {})
	var progress: Dictionary = families.get(family.family_id, {})
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
		"beginner": {"shown_count": 3, "option_count": 6},
		"standard": {"shown_count": 4, "option_count": 7},
		"advanced": {"shown_count": 5, "option_count": 8},
		"expert": {"shown_count": 6, "option_count": 9}
	}.get(tier, {})
	return {"label": tier, "policy_version": VERSION, "axes": axes}

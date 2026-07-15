extends DifficultyPolicy
class_name PatternRecallDifficultyPolicy
## Adaptive sequence policy with readable discrete timing at every tier.

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
		"beginner": {"grid_size": 3, "sequence_length": 3, "interval": 1.05, "final_hold": 0.40},
		"standard": {"grid_size": 3, "sequence_length": 4, "interval": 0.86, "final_hold": 0.38},
		"advanced": {"grid_size": 4, "sequence_length": 5, "interval": 0.72, "final_hold": 0.34},
		"expert": {"grid_size": 4, "sequence_length": 6, "interval": 0.60, "final_hold": 0.30}
	}.get(tier, {})
	return {"label": tier, "policy_version": VERSION, "axes": axes}

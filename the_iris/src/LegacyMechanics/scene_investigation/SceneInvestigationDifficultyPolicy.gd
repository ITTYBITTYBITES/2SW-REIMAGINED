extends DifficultyPolicy
class_name SceneInvestigationDifficultyPolicy
## Multi-axis production difficulty policy for Scene Investigation.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func resolve_difficulty(
	player_state: Dictionary,
	_family: ChallengeFamily,
	_template: ChallengeTemplate
) -> Dictionary:
	var family_progress: Dictionary = _get_family_progress(player_state)
	var plays := int(family_progress.get("plays", 0))
	var accuracy := float(family_progress.get("accuracy", 0.0))
	var mastery := float(family_progress.get("mastery", 0.0))
	var incorrect_streak := int(family_progress.get("incorrect_streak", 0))
	var tier := _resolve_tier(plays, accuracy, mastery, incorrect_streak)
	var axes := _axes_for_tier(tier)
	var preferences_value: Variant = player_state.get("preferences", {})
	var preferences: Dictionary = preferences_value if preferences_value is Dictionary else {}
	axes["color_assist_mode"] = bool(preferences.get("color_assist_mode", false))
	return {
		"label": tier,
		"axes": axes,
		"policy_version": VERSION
	}

func _get_family_progress(player_state: Dictionary) -> Dictionary:
	var witness_progress: Variant = player_state.get("witness_progress", {})
	if not (witness_progress is Dictionary):
		return {}
	var families: Variant = (witness_progress as Dictionary).get("families", {})
	if not (families is Dictionary):
		return {}
	var family: Variant = (families as Dictionary).get("scene_investigation", {})
	return (family as Dictionary).duplicate(true) if family is Dictionary else {}

func _resolve_tier(plays: int, accuracy: float, mastery: float, incorrect_streak: int) -> String:
	if plays < 3:
		return "beginner"
	if incorrect_streak >= 2:
		return "beginner" if plays < 8 else "standard"
	if plays < 8 or accuracy < 0.60:
		return "standard"
	if mastery >= 75.0 and accuracy >= 0.78:
		return "expert"
	if mastery >= 35.0 and accuracy >= 0.68:
		return "advanced"
	return "standard"

func _axes_for_tier(tier: String) -> Dictionary:
	match tier:
		"expert":
			return {
				"object_count_min": 15,
				"object_count_max": 18,
				"decorative_count": 5,
				"similarity": 0.78,
				"target_scale": 0.82,
				"distractor_similarity": 0.85,
				"question_complexity": 0.90,
				"scene_complexity": 0.88
			}
		"advanced":
			return {
				"object_count_min": 13,
				"object_count_max": 16,
				"decorative_count": 4,
				"similarity": 0.58,
				"target_scale": 0.90,
				"distractor_similarity": 0.65,
				"question_complexity": 0.70,
				"scene_complexity": 0.68
			}
		"standard":
			return {
				"object_count_min": 10,
				"object_count_max": 13,
				"decorative_count": 3,
				"similarity": 0.35,
				"target_scale": 1.0,
				"distractor_similarity": 0.42,
				"question_complexity": 0.45,
				"scene_complexity": 0.45
			}
		_:
			return {
				"object_count_min": 8,
				"object_count_max": 10,
				"decorative_count": 1,
				"similarity": 0.12,
				"target_scale": 1.10,
				"distractor_similarity": 0.15,
				"question_complexity": 0.20,
				"scene_complexity": 0.20
			}

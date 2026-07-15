extends ExposurePolicy
class_name ObjectRecallExposurePolicy
## Keeps set exposure fair as the visible object count grows.

const VERSION := "2"

func get_version() -> String:
	return VERSION

func resolve_exposure(
	_template: ChallengeTemplate,
	difficulty: Dictionary,
	player_state: Dictionary
) -> float:
	var tier := str(difficulty.get("label", "beginner"))
	var value: float = {
		"beginner": 5.8,
		"standard": 4.9,
		"advanced": 4.1,
		"expert": 3.4
	}.get(tier, 5.8)
	var preferences: Dictionary = player_state.get("preferences", {})
	if bool(preferences.get("comfortable_timing", false)):
		value *= 1.30
	return clampf(value, 3.3, 8.0)

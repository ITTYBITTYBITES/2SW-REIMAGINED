extends ExposurePolicy
class_name SpotDifferenceExposurePolicy
## Sequential comparison now shows A once, then B once, with enough time for both.

const VERSION := "2"

func get_version() -> String:
	return VERSION

func resolve_exposure(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	player_state: Dictionary
) -> float:
	var axes: Dictionary = difficulty.get("axes", {})
	var state_duration: float = float(axes.get("state_duration", 3.5))
	var mode := str(template.metadata.get("mode", ""))
	var duration := state_duration + 1.4
	if mode == "sequential":
		duration = state_duration * 2.0 + 0.25
	var preferences: Dictionary = player_state.get("preferences", {})
	if bool(preferences.get("comfortable_timing", false)):
		duration *= 1.25
	return clampf(duration, 4.5, 12.0)

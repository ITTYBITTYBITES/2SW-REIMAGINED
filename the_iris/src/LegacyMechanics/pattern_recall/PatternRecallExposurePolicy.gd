extends ExposurePolicy
class_name PatternRecallExposurePolicy

const VERSION := "2"

func get_version() -> String:
	return VERSION

func resolve_exposure(
	_template: ChallengeTemplate,
	difficulty: Dictionary,
	player_state: Dictionary
) -> float:
	var axes: Dictionary = difficulty.get("axes", {})
	var interval: float = float(axes.get("interval", 1.0))
	var final_hold: float = float(axes.get("final_hold", 0.35))
	if bool((player_state.get("preferences", {}) as Dictionary).get("comfortable_timing", false)):
		interval *= 1.25
		final_hold *= 1.25
	axes["interval"] = interval
	axes["final_hold"] = final_hold
	return float(axes.get("sequence_length", 3)) * interval + final_hold

extends ExposurePolicy
class_name FlashWordsExposurePolicy
## Resolves display duration, interval, and total sequence timing.

const VERSION: String = "1"
const COMFORTABLE_TIMING_MULTIPLIER: float = 1.30

func get_version() -> String:
	return VERSION

func resolve_exposure(
	_template: ChallengeTemplate,
	difficulty: Dictionary,
	_player_state: Dictionary
) -> float:
	var tier := str(difficulty.get("label", "beginner"))
	var axes: Dictionary = difficulty.get("axes", {})
	var mode := str(axes.get("mode", "single"))
	var timing := _timing_for(tier, mode)
	var reading_comfort := bool(axes.get("reading_comfort_mode", false))
	var display := float(timing.get("display", 3.5))
	var interval := float(timing.get("interval", 0.0))
	if reading_comfort:
		display *= 1.20
		interval *= 1.25
	if _uses_timing_accommodation(_player_state):
		display *= COMFORTABLE_TIMING_MULTIPLIER
		interval *= COMFORTABLE_TIMING_MULTIPLIER
	axes["display_duration"] = display
	axes["inter_word_interval"] = interval
	var sequence_length := int(axes.get("sequence_length", 1))
	return display * sequence_length + interval * maxi(sequence_length - 1, 0)

func _uses_timing_accommodation(player_state: Dictionary) -> bool:
	var preferences: Variant = player_state.get("preferences", {})
	if preferences is Dictionary:
		return bool((preferences as Dictionary).get("comfortable_timing", false))
	return false

func _timing_for(tier: String, mode: String) -> Dictionary:
	if mode == "single":
		return {
			"beginner": {"display": 5.0, "interval": 0.0},
			"standard": {"display": 3.5, "interval": 0.0},
			"advanced": {"display": 2.4, "interval": 0.0},
			"expert": {"display": 1.6, "interval": 0.0}
		}.get(tier, {"display": 5.0, "interval": 0.0})
	return {
		"beginner": {"display": 4.2, "interval": 1.0},
		"standard": {"display": 3.0, "interval": 0.8},
		"advanced": {"display": 2.0, "interval": 0.6},
		"expert": {"display": 1.4, "interval": 0.5}
	}.get(tier, {"display": 4.2, "interval": 1.0})

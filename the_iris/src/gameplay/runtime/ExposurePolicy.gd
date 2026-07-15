extends RefCounted
class_name ExposurePolicy
## Family-supplied exposure strategy. It has no UI responsibilities.
## Exposure is resolved before generation so the complete instance can be
## validated before presentation.

func get_version() -> String:
	return "0"

func resolve_exposure(
	_template: ChallengeTemplate,
	_difficulty: Dictionary,
	_player_state: Dictionary
) -> float:
	return 0.0

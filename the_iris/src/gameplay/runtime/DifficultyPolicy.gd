extends RefCounted
class_name DifficultyPolicy
## Family-supplied difficulty strategy. It has no UI responsibilities.

func get_version() -> String:
	return "0"

func resolve_difficulty(
	_player_state: Dictionary,
	_family: ChallengeFamily,
	_template: ChallengeTemplate
) -> Dictionary:
	return {
		"label": "default",
		"axes": {},
		"policy_version": get_version()
	}

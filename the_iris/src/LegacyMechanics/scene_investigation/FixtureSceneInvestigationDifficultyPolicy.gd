extends DifficultyPolicy
class_name FixtureSceneInvestigationDifficultyPolicy
## Fixed policy used by deterministic regression templates in Gate 1.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func resolve_difficulty(
	_player_state: Dictionary,
	_family: ChallengeFamily,
	template: ChallengeTemplate
) -> Dictionary:
	var configured_axes: Dictionary = template.difficulty_ranges.get("fixture_axes", {})
	return {
		"label": "fixture",
		"axes": configured_axes.duplicate(true),
		"policy_version": VERSION
	}

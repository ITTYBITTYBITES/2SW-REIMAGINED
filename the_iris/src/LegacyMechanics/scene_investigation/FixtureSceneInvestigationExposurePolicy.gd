extends ExposurePolicy
class_name FixtureSceneInvestigationExposurePolicy
## Fixed exposure policy used by deterministic regression templates in Gate 1.

const VERSION: String = "1"
const DEFAULT_DURATION_SEC: float = 2.0

func get_version() -> String:
	return VERSION

func resolve_exposure(
	template: ChallengeTemplate,
	_difficulty: Dictionary,
	_player_state: Dictionary
) -> float:
	return maxf(float(template.exposure_ranges.get("default_sec", DEFAULT_DURATION_SEC)), 0.1)

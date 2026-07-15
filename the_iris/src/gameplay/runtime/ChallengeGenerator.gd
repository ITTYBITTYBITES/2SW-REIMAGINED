extends RefCounted
class_name ChallengeGenerator
## Family-supplied generation strategy.
## Implementations must be deterministic for the same template, settings, and seed.

func get_version() -> String:
	return "0"

func generate(
	_template: ChallengeTemplate,
	_difficulty: Dictionary,
	_exposure_duration_sec: float,
	_seed_value: int
) -> ChallengeInstance:
	push_error("ChallengeGenerator.generate must be implemented by a family generator")
	return null

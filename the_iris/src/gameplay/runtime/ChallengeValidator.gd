extends RefCounted
class_name ChallengeValidator
## Family-supplied fairness-validation strategy.

func get_version() -> String:
	return "0"

func validate(_instance: ChallengeInstance) -> ChallengeValidationResult:
	return ChallengeValidationResult.rejected(
		"ChallengeValidator.validate must be implemented by a family validator",
		"validator.not_implemented"
	)

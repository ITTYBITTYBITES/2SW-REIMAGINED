extends ChallengeValidator
class_name FixtureSceneInvestigationValidator
## Fairness validator for deterministic Scene Investigation fixtures.

const VERSION: String = "1"

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return ChallengeValidationResult.rejected("Generator returned no instance", "instance.missing")

	var contract_errors := instance.get_contract_errors()
	if not contract_errors.is_empty():
		return ChallengeValidationResult.rejected(
			"Instance contract is incomplete",
			"instance.contract",
			{"errors": contract_errors}
		)

	var prompt := str(instance.question.get("prompt", "")).strip_edges()
	if prompt.is_empty():
		return ChallengeValidationResult.rejected("Question prompt is empty", "question.prompt")

	var correct_matches: int = 0
	for option: Variant in instance.answer_options:
		if str(option) == str(instance.correct_answer):
			correct_matches += 1
	if correct_matches != 1:
		return ChallengeValidationResult.rejected(
			"A single-choice challenge must contain exactly one correct option",
			"answer.unique",
			{"correct_matches": correct_matches}
		)

	var image_path := str(instance.generated_scene.get("image_path", ""))
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		return ChallengeValidationResult.rejected(
			"Required scene image is unavailable",
			"presentation.asset",
			{"image_path": image_path}
		)

	if instance.exposure_duration_sec <= 0.0:
		return ChallengeValidationResult.rejected(
			"Exposure duration must be achievable and greater than zero",
			"exposure.duration"
		)

	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": [
			"instance.contract",
			"question.prompt",
			"answer.unique",
			"presentation.asset",
			"exposure.duration"
		]
	})

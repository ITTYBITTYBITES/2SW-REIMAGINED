extends ChallengeValidator
class_name ObjectRecallValidator

const VERSION := "2"

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return ChallengeValidationResult.rejected("Null instance", "instance.null")
	var errors: Array[String] = instance.get_contract_errors()
	if not errors.is_empty():
		return ChallengeValidationResult.rejected(str(errors), "instance.contract")
	if not (instance.correct_answer is Array) or (instance.correct_answer as Array).is_empty():
		return ChallengeValidationResult.rejected("Correct set missing", "answer.set")
	var unique_options: Dictionary = {}
	for option: Variant in instance.answer_options:
		var option_text := str(option)
		if option_text.is_empty():
			return ChallengeValidationResult.rejected("Option label missing", "options.label")
		unique_options[option_text] = true
	if unique_options.size() != instance.answer_options.size():
		return ChallengeValidationResult.rejected("Options repeat", "options.unique")
	var unique_answers: Dictionary = {}
	for answer: Variant in instance.correct_answer:
		var answer_text := str(answer)
		unique_answers[answer_text] = true
		if not instance.answer_options.has(answer):
			return ChallengeValidationResult.rejected("Answer absent from options", "answer.present")
	if unique_answers.size() != (instance.correct_answer as Array).size():
		return ChallengeValidationResult.rejected("Correct set repeats", "answer.unique")
	var objects_value: Variant = instance.generated_scene.get("objects", [])
	if not (objects_value is Array) or (objects_value as Array).size() < 3:
		return ChallengeValidationResult.rejected("Presentation set is incomplete", "scene.objects")
	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": ["instance.contract", "options.unique", "answer.present", "answer.unique", "scene.objects"]
	})

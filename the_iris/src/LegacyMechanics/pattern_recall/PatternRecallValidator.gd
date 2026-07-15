extends ChallengeValidator
class_name PatternRecallValidator

const VERSION := "2"

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return ChallengeValidationResult.rejected("Null instance", "instance.null")
	var errors: Array[String] = instance.get_contract_errors()
	if not errors.is_empty():
		return ChallengeValidationResult.rejected(str(errors), "instance.contract")
	if not (instance.correct_answer is Array) or (instance.correct_answer as Array).size() < 3:
		return ChallengeValidationResult.rejected("Sequence too short", "sequence.length")
	var previous := ""
	for token: Variant in instance.correct_answer:
		var token_text := str(token)
		if not instance.answer_options.has(token):
			return ChallengeValidationResult.rejected("Sequence token unavailable", "sequence.token")
		if token_text == previous:
			return ChallengeValidationResult.rejected("Immediate token repeat", "sequence.repeat")
		previous = token_text
	var signature := str(instance.metadata.get("scene_signature", ""))
	if signature.is_empty():
		return ChallengeValidationResult.rejected("Sequence signature missing", "sequence.signature")
	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": ["instance.contract", "sequence.length", "sequence.token", "sequence.repeat", "sequence.signature"]
	})

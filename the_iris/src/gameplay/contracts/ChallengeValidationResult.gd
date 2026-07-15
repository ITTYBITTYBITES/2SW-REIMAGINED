extends RefCounted
class_name ChallengeValidationResult
## Result returned by every ChallengeValidator.

const CONTRACT_VERSION: int = 1

var is_valid: bool = false
var reason: String = ""
var rule_id: String = ""
var details: Dictionary = {}

static func accepted(metadata: Dictionary = {}) -> ChallengeValidationResult:
	var result := ChallengeValidationResult.new()
	result.is_valid = true
	result.details = metadata.duplicate(true)
	return result

static func rejected(failure_reason: String, failed_rule_id: String = "", metadata: Dictionary = {}) -> ChallengeValidationResult:
	var result := ChallengeValidationResult.new()
	result.is_valid = false
	result.reason = failure_reason
	result.rule_id = failed_rule_id
	result.details = metadata.duplicate(true)
	return result

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"is_valid": is_valid,
		"reason": reason,
		"rule_id": rule_id,
		"details": details.duplicate(true)
	}

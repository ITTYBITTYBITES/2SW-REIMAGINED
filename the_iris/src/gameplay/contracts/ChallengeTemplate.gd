extends RefCounted
class_name ChallengeTemplate
## Balancing contract for a repeatable gameplay pattern within a ChallengeFamily.
##
## Templates describe constraints and ranges. They do not generate or present a
## challenge in Phase 1. Shared runtimes will consume this contract in Phase 2.

const CONTRACT_VERSION: int = 1

var template_id: String = ""
var template_version: String = "1"
var family_id: String = ""
var title: String = ""
var rules: Dictionary = {}
var layout: Dictionary = {}
var variables: Dictionary = {}
var constraints: Dictionary = {}
var question_types: Array[String] = []
var distractor_rules: Dictionary = {}
var difficulty_ranges: Dictionary = {}
var exposure_ranges: Dictionary = {}
var accessibility_requirements: Dictionary = {}
var scoring_modifiers: Dictionary = {}
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	template_id = str(definition.get("template_id", definition.get("id", template_id)))
	template_version = str(definition.get("template_version", definition.get("version", template_version)))
	family_id = str(definition.get("family_id", family_id))
	title = str(definition.get("title", title))
	rules = _copy_dictionary(definition.get("rules", {}))
	layout = _copy_dictionary(definition.get("layout", {}))
	variables = _copy_dictionary(definition.get("variables", {}))
	constraints = _copy_dictionary(definition.get("constraints", {}))
	question_types = _to_string_array(definition.get("question_types", []))
	distractor_rules = _copy_dictionary(definition.get("distractor_rules", {}))
	difficulty_ranges = _copy_dictionary(definition.get("difficulty_ranges", {}))
	exposure_ranges = _copy_dictionary(definition.get("exposure_ranges", {}))
	accessibility_requirements = _copy_dictionary(definition.get("accessibility_requirements", {}))
	scoring_modifiers = _copy_dictionary(definition.get("scoring_modifiers", {}))
	metadata = _copy_dictionary(definition.get("metadata", {}))

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if template_id.strip_edges().is_empty():
		errors.append("template_id is required")
	if template_version.strip_edges().is_empty():
		errors.append("template_version is required")
	if family_id.strip_edges().is_empty():
		errors.append("family_id is required")
	if title.strip_edges().is_empty():
		errors.append("title is required")
	if question_types.is_empty():
		errors.append("at least one question_type is required")
	if difficulty_ranges.is_empty():
		errors.append("difficulty_ranges are required")
	if exposure_ranges.is_empty():
		errors.append("exposure_ranges are required")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"template_id": template_id,
		"template_version": template_version,
		"family_id": family_id,
		"title": title,
		"rules": rules.duplicate(true),
		"layout": layout.duplicate(true),
		"variables": variables.duplicate(true),
		"constraints": constraints.duplicate(true),
		"question_types": question_types.duplicate(),
		"distractor_rules": distractor_rules.duplicate(true),
		"difficulty_ranges": difficulty_ranges.duplicate(true),
		"exposure_ranges": exposure_ranges.duplicate(true),
		"accessibility_requirements": accessibility_requirements.duplicate(true),
		"scoring_modifiers": scoring_modifiers.duplicate(true),
		"metadata": metadata.duplicate(true)
	}

static func _to_string_array(value: Variant) -> Array[String]:
	var output: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			output.append(str(entry))
	return output

static func _copy_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}

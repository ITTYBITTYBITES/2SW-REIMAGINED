extends RefCounted
class_name ChallengeInstance
## Fully resolved, reproducible challenge data contract.
##
## Challenge truth must be resolved before presentation. Dynamic rendering,
## animation, motion, or audio playback may occur during play, but must follow
## the validated data stored by this instance. This class is not connected to
## the current five-challenge flow during Product Development Phase 1.

const CONTRACT_VERSION: int = 1

var instance_id: String = ""
var family_id: String = ""
var family_version: String = ""
var template_id: String = ""
var template_version: String = ""
var generator_version: String = ""
var validator_version: String = ""
var difficulty_policy_version: String = ""
var exposure_policy_version: String = ""
var content_version: String = ""
@warning_ignore("shadowed_global_identifier")
var seed: int = 0
var difficulty_label: String = ""
var difficulty_axes: Dictionary = {}
var exposure_duration_sec: float = 0.0
var generated_scene: Dictionary = {}
var question: Dictionary = {}
var answer_options: Array = []
var correct_answer: Variant = null
var explanation: String = ""
var validation_metadata: Dictionary = {}
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	instance_id = str(definition.get("instance_id", instance_id))
	family_id = str(definition.get("family_id", family_id))
	family_version = str(definition.get("family_version", family_version))
	template_id = str(definition.get("template_id", template_id))
	template_version = str(definition.get("template_version", template_version))
	generator_version = str(definition.get("generator_version", generator_version))
	validator_version = str(definition.get("validator_version", validator_version))
	difficulty_policy_version = str(definition.get("difficulty_policy_version", difficulty_policy_version))
	exposure_policy_version = str(definition.get("exposure_policy_version", exposure_policy_version))
	content_version = str(definition.get("content_version", content_version))
	seed = int(definition.get("seed", seed))
	difficulty_label = str(definition.get("difficulty_label", definition.get("difficulty", difficulty_label)))
	difficulty_axes = _copy_dictionary(definition.get("difficulty_axes", {}))
	exposure_duration_sec = float(definition.get("exposure_duration_sec", definition.get("exposure_duration", exposure_duration_sec)))
	generated_scene = _copy_dictionary(definition.get("generated_scene", {}))
	question = _copy_dictionary(definition.get("question", {}))
	answer_options = _copy_array(definition.get("answer_options", []))
	correct_answer = definition.get("correct_answer", null)
	explanation = str(definition.get("explanation", explanation))
	validation_metadata = _copy_dictionary(definition.get("validation_metadata", {}))
	metadata = _copy_dictionary(definition.get("metadata", {}))

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if instance_id.strip_edges().is_empty():
		errors.append("instance_id is required")
	if family_id.strip_edges().is_empty():
		errors.append("family_id is required")
	if family_version.strip_edges().is_empty():
		errors.append("family_version is required")
	if template_id.strip_edges().is_empty():
		errors.append("template_id is required")
	if template_version.strip_edges().is_empty():
		errors.append("template_version is required")
	if generator_version.strip_edges().is_empty():
		errors.append("generator_version is required")
	if validator_version.strip_edges().is_empty():
		errors.append("validator_version is required")
	if content_version.strip_edges().is_empty():
		errors.append("content_version is required")
	if exposure_duration_sec < 0.0:
		errors.append("exposure_duration_sec cannot be negative")
	if generated_scene.is_empty():
		errors.append("generated_scene must be resolved before presentation")
	if question.is_empty():
		errors.append("question must be resolved before presentation")
	if answer_options.is_empty():
		errors.append("answer_options must be resolved before presentation")
	if correct_answer == null:
		errors.append("correct_answer must be resolved before presentation")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"instance_id": instance_id,
		"family_id": family_id,
		"family_version": family_version,
		"template_id": template_id,
		"template_version": template_version,
		"generator_version": generator_version,
		"validator_version": validator_version,
		"difficulty_policy_version": difficulty_policy_version,
		"exposure_policy_version": exposure_policy_version,
		"content_version": content_version,
		"seed": seed,
		"difficulty_label": difficulty_label,
		"difficulty_axes": difficulty_axes.duplicate(true),
		"exposure_duration_sec": exposure_duration_sec,
		"generated_scene": generated_scene.duplicate(true),
		"question": question.duplicate(true),
		"answer_options": answer_options.duplicate(true),
		"correct_answer": correct_answer,
		"explanation": explanation,
		"validation_metadata": validation_metadata.duplicate(true),
		"metadata": metadata.duplicate(true)
	}

static func _copy_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}

static func _copy_array(value: Variant) -> Array:
	if value is Array:
		return (value as Array).duplicate(true)
	return []

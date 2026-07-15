extends RefCounted
class_name ChallengeFamily
## Architecture contract for one internally named ChallengeFamily.
##
## Player-facing UI calls these modules "Challenge Types". This class is a
## behavior-neutral data contract for Product Development Phase 1. Shared
## runtimes are introduced in Phase 2; the current game does not use this class.

const CONTRACT_VERSION: int = 1

var family_id: String = ""
var family_version: String = "1"
var title: String = ""
var description: String = ""
var gameplay_focus: Array[String] = []
var tutorial_id: String = ""
var tutorial_version: String = "1"
var artwork_profile: Dictionary = {}
var music_profile: Dictionary = {}
var sound_profile: Dictionary = {}
var animation_profile: Dictionary = {}
var presentation_profile_id: String = ""
var template_ids: Array[String] = []
var generator_id: String = ""
var validator_id: String = ""
var difficulty_policy_id: String = ""
var exposure_policy_id: String = ""
var accessibility_requirements: Dictionary = {}
var progress_rules_id: String = ""
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	family_id = str(definition.get("family_id", definition.get("id", family_id)))
	family_version = str(definition.get("family_version", definition.get("version", family_version)))
	title = str(definition.get("title", title))
	description = str(definition.get("description", description))
	gameplay_focus = _to_string_array(definition.get("gameplay_focus", []))
	tutorial_id = str(definition.get("tutorial_id", tutorial_id))
	tutorial_version = str(definition.get("tutorial_version", tutorial_version))
	artwork_profile = _copy_dictionary(definition.get("artwork_profile", {}))
	music_profile = _copy_dictionary(definition.get("music_profile", {}))
	sound_profile = _copy_dictionary(definition.get("sound_profile", {}))
	animation_profile = _copy_dictionary(definition.get("animation_profile", {}))
	presentation_profile_id = str(definition.get("presentation_profile_id", presentation_profile_id))
	template_ids = _to_string_array(definition.get("template_ids", []))
	generator_id = str(definition.get("generator_id", generator_id))
	validator_id = str(definition.get("validator_id", validator_id))
	difficulty_policy_id = str(definition.get("difficulty_policy_id", difficulty_policy_id))
	exposure_policy_id = str(definition.get("exposure_policy_id", exposure_policy_id))
	accessibility_requirements = _copy_dictionary(definition.get("accessibility_requirements", {}))
	progress_rules_id = str(definition.get("progress_rules_id", progress_rules_id))
	metadata = _copy_dictionary(definition.get("metadata", {}))

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if family_id.strip_edges().is_empty():
		errors.append("family_id is required")
	if family_version.strip_edges().is_empty():
		errors.append("family_version is required")
	if title.strip_edges().is_empty():
		errors.append("title is required")
	if presentation_profile_id.strip_edges().is_empty():
		errors.append("presentation_profile_id is required")
	if template_ids.is_empty():
		errors.append("at least one template_id is required")
	if generator_id.strip_edges().is_empty():
		errors.append("generator_id is required")
	if validator_id.strip_edges().is_empty():
		errors.append("validator_id is required")
	if difficulty_policy_id.strip_edges().is_empty():
		errors.append("difficulty_policy_id is required")
	if exposure_policy_id.strip_edges().is_empty():
		errors.append("exposure_policy_id is required")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"family_id": family_id,
		"family_version": family_version,
		"title": title,
		"description": description,
		"gameplay_focus": gameplay_focus.duplicate(),
		"tutorial_id": tutorial_id,
		"tutorial_version": tutorial_version,
		"artwork_profile": artwork_profile.duplicate(true),
		"music_profile": music_profile.duplicate(true),
		"sound_profile": sound_profile.duplicate(true),
		"animation_profile": animation_profile.duplicate(true),
		"presentation_profile_id": presentation_profile_id,
		"template_ids": template_ids.duplicate(),
		"generator_id": generator_id,
		"validator_id": validator_id,
		"difficulty_policy_id": difficulty_policy_id,
		"exposure_policy_id": exposure_policy_id,
		"accessibility_requirements": accessibility_requirements.duplicate(true),
		"progress_rules_id": progress_rules_id,
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

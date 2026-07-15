extends RefCounted
class_name PresentationProfile
## Route and presentation contract selected by a ChallengeFamily module.
## The shared runtime reads this profile without branching on family identity.

const CONTRACT_VERSION: int = 1

var profile_id: String = ""
var profile_version: String = "1"
var presentation_route: String = ""
var response_route: String = ""
var result_route: String = "result"
var presentation_mode: String = ""
var response_mode: String = "single_choice" # Compatibility mirror of InteractionProfile.mode.
var interaction_profile_id: String = "interaction.single_choice.v1"
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	profile_id = str(definition.get("profile_id", definition.get("id", profile_id)))
	profile_version = str(definition.get("profile_version", definition.get("version", profile_version)))
	presentation_route = str(definition.get("presentation_route", presentation_route))
	response_route = str(definition.get("response_route", response_route))
	result_route = str(definition.get("result_route", result_route))
	presentation_mode = str(definition.get("presentation_mode", presentation_mode))
	response_mode = str(definition.get("response_mode", response_mode))
	interaction_profile_id = str(definition.get("interaction_profile_id", interaction_profile_id))
	var raw_metadata: Variant = definition.get("metadata", {})
	metadata = (raw_metadata as Dictionary).duplicate(true) if raw_metadata is Dictionary else {}

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if profile_id.strip_edges().is_empty():
		errors.append("profile_id is required")
	if profile_version.strip_edges().is_empty():
		errors.append("profile_version is required")
	if presentation_route.strip_edges().is_empty():
		errors.append("presentation_route is required")
	if response_route.strip_edges().is_empty():
		errors.append("response_route is required")
	if result_route.strip_edges().is_empty():
		errors.append("result_route is required")
	if interaction_profile_id.strip_edges().is_empty():
		errors.append("interaction_profile_id is required")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"profile_id": profile_id,
		"profile_version": profile_version,
		"presentation_route": presentation_route,
		"response_route": response_route,
		"result_route": result_route,
		"presentation_mode": presentation_mode,
		"response_mode": response_mode,
		"interaction_profile_id": interaction_profile_id,
		"metadata": metadata.duplicate(true)
	}

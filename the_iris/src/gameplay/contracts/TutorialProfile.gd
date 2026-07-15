extends RefCounted
class_name TutorialProfile
## Family-owned tutorial declaration consumed by the generic TutorialScreen host.

const CONTRACT_VERSION: int = 1

var family_id: String = ""
var tutorial_id: String = ""
var tutorial_version: String = "1"
var scene_path: String = ""
var replay_label: String = "Replay Tutorial"
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	family_id = str(definition.get("family_id", family_id))
	tutorial_id = str(definition.get("tutorial_id", tutorial_id))
	tutorial_version = str(definition.get("tutorial_version", definition.get("version", tutorial_version)))
	scene_path = str(definition.get("scene_path", scene_path))
	replay_label = str(definition.get("replay_label", replay_label))
	var metadata_value: Variant = definition.get("metadata", {})
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if family_id.strip_edges().is_empty():
		errors.append("family_id is required")
	if tutorial_id.strip_edges().is_empty():
		errors.append("tutorial_id is required")
	if tutorial_version.strip_edges().is_empty():
		errors.append("tutorial_version is required")
	if scene_path.strip_edges().is_empty():
		errors.append("scene_path is required")
	if replay_label.strip_edges().is_empty():
		errors.append("replay_label is required")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"family_id": family_id,
		"tutorial_id": tutorial_id,
		"tutorial_version": tutorial_version,
		"scene_path": scene_path,
		"replay_label": replay_label,
		"metadata": metadata.duplicate(true)
	}

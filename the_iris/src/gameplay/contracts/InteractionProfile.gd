extends RefCounted
class_name InteractionProfile
## Family-declared interaction contract. Shared code collects payloads through a
## registered adapter and never interprets family meaning or correctness.

const CONTRACT_VERSION: int = 1

var profile_id: String = ""
var profile_version: String = "1"
var mode: String = "single_choice"
var adapter_id: String = "single_choice"
var accessible_adapter_id: String = ""
var payload_schema: Dictionary = {}
var metadata: Dictionary = {}

func _init(definition: Dictionary = {}) -> void:
	if not definition.is_empty():
		apply_definition(definition)

func apply_definition(definition: Dictionary) -> void:
	profile_id = str(definition.get("profile_id", definition.get("id", profile_id)))
	profile_version = str(definition.get("profile_version", definition.get("version", profile_version)))
	mode = str(definition.get("mode", mode))
	adapter_id = str(definition.get("adapter_id", mode))
	accessible_adapter_id = str(definition.get("accessible_adapter_id", accessible_adapter_id))
	payload_schema = _copy_dictionary(definition.get("payload_schema", {}))
	metadata = _copy_dictionary(definition.get("metadata", {}))

func get_contract_errors() -> Array[String]:
	var errors: Array[String] = []
	if profile_id.strip_edges().is_empty():
		errors.append("profile_id is required")
	if profile_version.strip_edges().is_empty():
		errors.append("profile_version is required")
	if mode.strip_edges().is_empty():
		errors.append("mode is required")
	if adapter_id.strip_edges().is_empty():
		errors.append("adapter_id is required")
	return errors

func is_contract_valid() -> bool:
	return get_contract_errors().is_empty()

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"profile_id": profile_id,
		"profile_version": profile_version,
		"mode": mode,
		"adapter_id": adapter_id,
		"accessible_adapter_id": accessible_adapter_id,
		"payload_schema": payload_schema.duplicate(true),
		"metadata": metadata.duplicate(true)
	}

static func default_single_choice() -> InteractionProfile:
	return InteractionProfile.new({
		"profile_id": "interaction.single_choice.v1",
		"profile_version": "1",
		"mode": "single_choice",
		"adapter_id": "single_choice",
		"payload_schema": {"type": "String"}
	})

static func _copy_dictionary(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

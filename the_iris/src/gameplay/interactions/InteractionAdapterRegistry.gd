extends Node
## Data-driven registry for generic interaction collectors.

signal adapter_registered(adapter_id: String)
signal adapter_registration_failed(adapter_id: String, reason: String)

const MANIFEST_PATH: String = "res://src/gameplay/interactions/manifest.json"

var _initialized: bool = false
var _scripts: Dictionary = {}
var _future_modes: Array[String] = []

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_load_manifest()
	_initialized = true

func register_adapter(adapter_id: String, script: Script) -> bool:
	if adapter_id.is_empty() or script == null or _scripts.has(adapter_id):
		adapter_registration_failed.emit(adapter_id, "Invalid or duplicate adapter")
		return false
	var value: Variant = script.new()
	if not (value is InteractionAdapter) or (value as InteractionAdapter).get_adapter_id() != adapter_id:
		adapter_registration_failed.emit(adapter_id, "Script must create the declared InteractionAdapter")
		return false
	_scripts[adapter_id] = script
	adapter_registered.emit(adapter_id)
	return true

func create_adapter(adapter_id: String) -> InteractionAdapter:
	if not _initialized:
		initialize()
	var script: Script = _scripts.get(adapter_id) as Script
	return script.new() as InteractionAdapter if script else null

func has_adapter(adapter_id: String) -> bool:
	return _scripts.has(adapter_id)

func get_adapter_ids() -> Array[String]:
	var output: Array[String] = []
	for value: Variant in _scripts.keys():
		output.append(str(value))
	output.sort()
	return output

func get_future_modes() -> Array[String]:
	return _future_modes.duplicate()

func _load_manifest() -> void:
	_scripts.clear()
	_future_modes.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var file: FileAccess = FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
	if not (parsed is Dictionary):
		return
	var adapters_value: Variant = (parsed as Dictionary).get("adapters", [])
	if adapters_value is Array:
		for value: Variant in adapters_value:
			if value is Dictionary:
				var adapter_id: String = str((value as Dictionary).get("id", ""))
				var path: String = str((value as Dictionary).get("script", ""))
				if ResourceLoader.exists(path):
					register_adapter(adapter_id, load(path) as Script)
	var future_value: Variant = (parsed as Dictionary).get("future_modes", [])
	if future_value is Array:
		for value: Variant in future_value:
			_future_modes.append(str(value))

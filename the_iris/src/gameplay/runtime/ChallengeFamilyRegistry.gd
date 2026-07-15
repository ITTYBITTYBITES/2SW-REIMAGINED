extends Node
## Generic registry for ChallengeFamilyModule implementations declared by content.
## It loads module paths from a manifest and contains no family-specific logic.

signal family_registered(family_id: String)
signal family_unregistered(family_id: String)
signal registry_ready(family_ids: Array[String])
signal registration_failed(source: String, reason: String)

const MANIFEST_PATH: String = "res://src/LegacyMechanics/manifest.json"

var _initialized: bool = false
var _modules: Dictionary = {}
var _ordered_ids: Array[String] = []

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	if InteractionAdapterRegistry:
		InteractionAdapterRegistry.initialize()
	_load_manifest()
	_initialized = true
	registry_ready.emit(get_family_ids())

func _load_manifest() -> void:
	_modules.clear()
	_ordered_ids.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		_reject(MANIFEST_PATH, "Family manifest not found")
		return
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if not file:
		_reject(MANIFEST_PATH, "Family manifest could not be opened")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_reject(MANIFEST_PATH, "Family manifest is not a dictionary")
		return
	var entries: Variant = (parsed as Dictionary).get("families", [])
	if not (entries is Array):
		_reject(MANIFEST_PATH, "families must be an array")
		return
	for raw_entry: Variant in entries:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		if not bool(entry.get("enabled", true)):
			continue
		_register_module_path(str(entry.get("module_script", "")))

func _register_module_path(module_path: String) -> bool:
	if module_path.is_empty() or not ResourceLoader.exists(module_path):
		return _reject(module_path, "Module script does not exist")
	var module_script: Script = load(module_path)
	if not module_script:
		return _reject(module_path, "Module script could not be loaded")
	var module_value: Variant = module_script.new()
	if not (module_value is ChallengeFamilyModule):
		return _reject(module_path, "Module must extend ChallengeFamilyModule")
	return register_module(module_value as ChallengeFamilyModule, module_path)

func register_module(module: ChallengeFamilyModule, source: String = "runtime") -> bool:
	if module == null:
		return _reject(source, "Module is null")
	var family := module.get_family()
	if family == null:
		return _reject(source, "Module returned no family definition")
	var family_errors := family.get_contract_errors()
	if not family_errors.is_empty():
		return _reject(source, "Invalid family: %s" % str(family_errors))
	if _modules.has(family.family_id):
		return _reject(source, "Duplicate family_id: %s" % family.family_id)

	var presentation := module.get_presentation_profile()
	if presentation == null:
		return _reject(source, "Module returned no presentation profile")
	var presentation_errors := presentation.get_contract_errors()
	if not presentation_errors.is_empty():
		return _reject(source, "Invalid presentation profile: %s" % str(presentation_errors))
	if presentation.profile_id != family.presentation_profile_id:
		return _reject(source, "Family presentation_profile_id does not match supplied profile")
	var interaction := module.get_interaction_profile()
	if interaction == null:
		return _reject(source, "Module returned no interaction profile")
	var interaction_errors := interaction.get_contract_errors()
	if not interaction_errors.is_empty():
		return _reject(source, "Invalid interaction profile: %s" % str(interaction_errors))
	if presentation.interaction_profile_id != interaction.profile_id:
		return _reject(source, "Presentation and InteractionProfile IDs do not match")
	if InteractionAdapterRegistry and not InteractionAdapterRegistry.has_adapter(interaction.adapter_id):
		return _reject(source, "Interaction adapter is not registered: %s" % interaction.adapter_id)
	if not interaction.accessible_adapter_id.is_empty() and InteractionAdapterRegistry and not InteractionAdapterRegistry.has_adapter(interaction.accessible_adapter_id):
		return _reject(source, "Accessible interaction adapter is not registered")

	var tutorial := module.get_tutorial_profile()
	if tutorial == null:
		return _reject(source, "Module returned no tutorial profile")
	var tutorial_errors := tutorial.get_contract_errors()
	if not tutorial_errors.is_empty():
		return _reject(source, "Invalid tutorial profile: %s" % str(tutorial_errors))
	if tutorial.family_id != family.family_id:
		return _reject(source, "Tutorial profile belongs to a different family")
	if tutorial.tutorial_id != family.tutorial_id or tutorial.tutorial_version != family.tutorial_version:
		return _reject(source, "Family tutorial identity does not match supplied profile")
	if not ResourceLoader.exists(tutorial.scene_path):
		return _reject(source, "Tutorial scene does not exist: %s" % tutorial.scene_path)

	var templates := module.get_templates()
	if templates.is_empty():
		return _reject(source, "Family must provide at least one template")
	var seen_template_ids: Dictionary = {}
	for template: ChallengeTemplate in templates:
		var template_errors := template.get_contract_errors()
		if not template_errors.is_empty():
			return _reject(source, "Invalid template %s: %s" % [template.template_id, str(template_errors)])
		if template.family_id != family.family_id:
			return _reject(source, "Template %s belongs to a different family" % template.template_id)
		if seen_template_ids.has(template.template_id):
			return _reject(source, "Duplicate template_id: %s" % template.template_id)
		seen_template_ids[template.template_id] = true
	if seen_template_ids.size() != family.template_ids.size():
		return _reject(source, "Family template_ids do not match supplied templates")
	for template_id: String in family.template_ids:
		if not seen_template_ids.has(template_id):
			return _reject(source, "Family references missing template: %s" % template_id)

	if module.get_generator() == null:
		return _reject(source, "Family must provide a ChallengeGenerator")
	if module.get_validator() == null:
		return _reject(source, "Family must provide a ChallengeValidator")
	if module.get_difficulty_policy() == null:
		return _reject(source, "Family must provide a DifficultyPolicy")
	if module.get_exposure_policy() == null:
		return _reject(source, "Family must provide an ExposurePolicy")
	if module.get_scoring_policy() == null:
		return _reject(source, "Family must provide a ScoringPolicy")

	_modules[family.family_id] = module
	_ordered_ids.append(family.family_id)
	family_registered.emit(family.family_id)
	return true

func unregister_family(family_id: String) -> bool:
	if not _modules.has(family_id):
		return false
	_modules.erase(family_id)
	_ordered_ids.erase(family_id)
	family_unregistered.emit(family_id)
	return true

func _reject(source: String, reason: String) -> bool:
	registration_failed.emit(source, reason)
	return false

func is_initialized() -> bool:
	return _initialized

func get_family_ids() -> Array[String]:
	return _ordered_ids.duplicate()

func get_default_family_id() -> String:
	return _ordered_ids[0] if not _ordered_ids.is_empty() else ""

func get_visible_family_ids() -> Array[String]:
	var visible: Array[String] = []
	for family_id: String in _ordered_ids:
		var family := get_family(family_id)
		if family and bool(family.metadata.get("player_visible", true)):
			visible.append(family_id)
	return visible

func has_family(family_id: String) -> bool:
	return _modules.has(family_id)

func get_module(family_id: String) -> ChallengeFamilyModule:
	return _modules.get(family_id) as ChallengeFamilyModule

func get_family(family_id: String) -> ChallengeFamily:
	var module := get_module(family_id)
	return module.get_family() if module else null

func find_family_id_for_template(template_id: String) -> String:
	for family_id: String in _ordered_ids:
		var module := get_module(family_id)
		if module and module.get_template(template_id) != null:
			return family_id
	return ""

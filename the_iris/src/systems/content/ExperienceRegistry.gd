extends Node
## ExperienceRegistry - Registers and manages experiences as independent modules
## Core principle: New experiences added without rewriting core app

signal experience_registered(exp_id: String, manifest: Dictionary)
signal experience_unregistered(exp_id: String)
signal registry_updated(experiences: Array)

var _experiences: Dictionary = {} # id -> manifest + runtime info
var _initialized: bool = false

const EXPERIENCE_BASE_PATH := "res://src/experiences/"

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return

	_scan_and_register()

	_initialized = true
	registry_updated.emit(get_all_experiences())

func _scan_and_register() -> void:
	# Scan known experiences
	var known_ids := ["flashword"] # seed with known

	# Also try to read manifest list
	if ContentService:
		var list: Array = ContentService.get_content_list()
		for id in list:
			if not known_ids.has(id):
				known_ids.append(id)

	# Important: do not scan res:// directories at runtime on Android exports.
	# In exported mobile builds, DirAccess on res:// can fail during boot and stall startup.
	# Rely on the manifest + known IDs for runtime; only perform directory scans in editor.
	if OS.has_feature("editor"):
		var dir := DirAccess.open(EXPERIENCE_BASE_PATH)
		if dir:
			dir.list_dir_begin()
			var fname := dir.get_next()
			while fname != "":
				if dir.current_is_dir() and not fname.begins_with("_") and not fname.begins_with("."):
					if not known_ids.has(fname):
						known_ids.append(fname)
				fname = dir.get_next()
			dir.list_dir_end()

	for exp_id in known_ids:
		_register_from_path(exp_id)

func _register_from_path(exp_id: String) -> bool:
	var manifest_paths := [
		"%s%s/manifest.json" % [EXPERIENCE_BASE_PATH, exp_id],
		"%s%s/%s_manifest.json" % [EXPERIENCE_BASE_PATH, exp_id, exp_id.capitalize()],
		"%s%s/FlashwordManifest.json" % [EXPERIENCE_BASE_PATH, exp_id] if exp_id == "flashword" else "",
	]
	# Also try hardcoded defaults
	var manifest: Dictionary = {}
	var found := false

	for p in manifest_paths:
		if p == "":
			continue
		if FileAccess.file_exists(p):
			var file := FileAccess.open(p, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					manifest = parsed
					found = true
					break

	if not found:
		# Create a safe fallback manifest for legacy experience modules.
		manifest = _create_default_manifest(exp_id)

	if manifest.is_empty():
		return false

	# Ensure required fields
	if not manifest.has("id"):
		manifest["id"] = exp_id
	if not manifest.has("title"):
		manifest["title"] = exp_id.capitalize()

	_experiences[exp_id] = {
		"manifest": manifest,
		"registered_at": Time.get_ticks_msec(),
		"is_locked": manifest.get("is_locked", false),
		"is_coming_soon": manifest.get("coming_soon", false)
	}

	experience_registered.emit(exp_id, manifest)
	return true

func _create_default_manifest(exp_id: String) -> Dictionary:
	match exp_id:
		"flashword":
			return {
				"id": "flashword",
				"title": "Flashword",
				"short_description": "Observe. Remember. Recall.",
				"description": "A 2-second glance at a word, then recall from memory under pressure.",
				"category": "memory",
				"tags": ["memory", "observation", "quick"],
				"version": "1.0.0-foundation",
				"difficulty": ["easy", "medium", "hard"],
				"estimated_duration_sec": 15,
				"icon": "flashword",
				"preview_color": "#7C5CFF",
				"is_locked": false,
				"coming_soon": false,
				"author": "Two Second Witness Team"
			}
		_:
			return {
				"id": exp_id,
				"title": exp_id.capitalize(),
				"short_description": "A quick observation experience",
				"description": "A locked legacy experience module.",
				"category": "observation",
				"tags": ["observation"],
				"version": "0.1.0-legacy",
				"difficulty": ["easy"],
				"estimated_duration_sec": 10,
				"icon": "generic",
				"preview_color": "#2EE6A6",
				"is_locked": true,
				"coming_soon": true
			}

func register_experience(exp_id: String, manifest: Dictionary) -> bool:
	if _experiences.has(exp_id):
		pass
	_experiences[exp_id] = {
		"manifest": manifest,
		"registered_at": Time.get_ticks_msec(),
		"is_locked": manifest.get("is_locked", false),
		"is_coming_soon": manifest.get("coming_soon", false)
	}
	experience_registered.emit(exp_id, manifest)
	registry_updated.emit(get_all_experiences())
	return true

func unregister_experience(exp_id: String) -> bool:
	if not _experiences.has(exp_id):
		return false
	_experiences.erase(exp_id)
	experience_unregistered.emit(exp_id)
	registry_updated.emit(get_all_experiences())
	return true

func get_experience(exp_id: String) -> Dictionary:
	return _experiences.get(exp_id, {})

func get_manifest(exp_id: String) -> Dictionary:
	var entry: Dictionary = _experiences.get(exp_id, {})
	return entry.get("manifest", {})

func get_all_experiences() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for id in _experiences.keys():
		var entry: Dictionary = _experiences[id]
		var manifest: Dictionary = entry.get("manifest", {})
		# Merge runtime data
		var combined := manifest.duplicate(true)
		combined["runtime"] = {
			"is_locked": entry.get("is_locked", false),
			"is_coming_soon": entry.get("is_coming_soon", false),
			"is_unlocked": ProfileService.is_experience_unlocked(id) if ProfileService else true
		}
		list.append(combined)
	# Sort by title without relying on an inline lambda. This keeps the registry
	# compatible with older Godot 4.x parser versions used by Android builds.
	list.sort_custom(_sort_experiences_by_title)
	return list

func _sort_experiences_by_title(a: Dictionary, b: Dictionary) -> bool:
	return str(a.get("title", "")) < str(b.get("title", ""))

func get_unlocked_experiences() -> Array[Dictionary]:
	var all := get_all_experiences()
	var unlocked: Array[Dictionary] = []
	for item in all:
		var runtime: Dictionary = item.get("runtime", {})
		if runtime.get("is_unlocked", true) and not runtime.get("is_coming_soon", false):
			unlocked.append(item)
	return unlocked

func is_registered(exp_id: String) -> bool:
	return _experiences.has(exp_id)

func count() -> int:
	return _experiences.size()

extends Node
## ContentService - Content loading, caching, versioning
## Future-proof for OTA updates, offline-first

signal content_loaded(content_id: String, data: Dictionary)
signal content_load_failed(content_id: String, reason: String)
signal content_cache_cleared()

var _cache: Dictionary = {} # id -> data
var _manifest: Dictionary = {}
var _initialized: bool = false

const CONTENT_MANIFEST_PATH := "res://src/experiences/manifest.json"
const USER_CONTENT_DIR := "user://content/"

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return

	if not DirAccess.dir_exists_absolute(USER_CONTENT_DIR):
		DirAccess.make_dir_recursive_absolute(USER_CONTENT_DIR)

	_load_manifest()

	_initialized = true

func _load_manifest() -> void:
	var paths := [
		CONTENT_MANIFEST_PATH,
		"user://content_manifest.json"
	]

	for p in paths:
		if FileAccess.file_exists(p) or ResourceLoader.exists(p):
			var data := _load_json(p)
			if not data.is_empty():
				_manifest = data
				return

	# Fallback default manifest
	_manifest = {
		"version": 1,
		"experiences": ["flashword"],
		"last_updated": Time.get_datetime_string_from_system()
	}

func _load_json(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var text := file.get_as_text()
			var parsed = JSON.parse_string(text)
			if parsed is Dictionary:
				return parsed
	elif ResourceLoader.exists(path):
		var res = ResourceLoader.load(path)
		if res is JSON:
			return (res as JSON).data as Dictionary
	return {}

func get_content(content_id: String) -> Dictionary:
	if _cache.has(content_id):
		return _cache[content_id]

	# Try load from disk
	var paths := [
		"res://src/experiences/%s/%s.json" % [content_id, content_id],
		"res://src/experiences/%s/manifest.json" % content_id,
		USER_CONTENT_DIR.path_join("%s.json" % content_id)
	]

	for p in paths:
		if FileAccess.file_exists(p):
			var data := _load_json(p)
			if not data.is_empty():
				_cache[content_id] = data
				content_loaded.emit(content_id, data)
				return data

	content_load_failed.emit(content_id, "Not found")
	return {}

func preload_content(content_id: String) -> bool:
	var data := get_content(content_id)
	return not data.is_empty()

func cache_content(content_id: String, data: Dictionary) -> void:
	_cache[content_id] = data
	content_loaded.emit(content_id, data)
	# Persist to user
	var path := USER_CONTENT_DIR.path_join("%s.json" % content_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func clear_cache() -> void:
	_cache.clear()
	content_cache_cleared.emit()

func get_manifest() -> Dictionary:
	return _manifest.duplicate(true)

func get_content_list() -> Array:
	return _manifest.get("experiences", [])

func is_content_available(content_id: String) -> bool:
	if _cache.has(content_id):
		return true
	var paths := [
		"res://src/experiences/%s/%s.json" % [content_id, content_id],
		"res://src/experiences/%s/manifest.json" % content_id,
		USER_CONTENT_DIR.path_join("%s.json" % content_id)
	]
	for p in paths:
		if FileAccess.file_exists(p):
			return true
	return false

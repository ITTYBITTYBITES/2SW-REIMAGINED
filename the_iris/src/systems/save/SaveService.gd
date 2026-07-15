extends Node
## Low-level, versioned JSON persistence with atomic replacement and recovery.

signal save_completed(slot: String)
signal save_failed(slot: String, reason: String)
signal save_loaded(slot: String, data: Dictionary)

const SAVE_VERSION := 2
const SAVE_DIR := "user://saves/"
const PROFILE_FILE := "user://profile_v2.json"
const SETTINGS_FILE := "user://settings_v2.json"
const TEMP_SUFFIX := ".tmp"
const BACKUP_SUFFIX := ".bak"

var _initialized: bool = false

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_cleanup_stale_temporary(PROFILE_FILE)
	_cleanup_stale_temporary(SETTINGS_FILE)
	_initialized = true

func save_json(path: String, data: Dictionary, _encrypt: bool = false) -> bool:
	var directory := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory):
		var make_error := DirAccess.make_dir_recursive_absolute(directory)
		if make_error != OK:
			return _save_error(path, "Failed to create save directory: %s" % error_string(make_error))
	var wrapper := {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"ticks": Time.get_ticks_msec(),
		"data": data
	}
	var json_text := JSON.stringify(wrapper, "\t")
	var temporary_path := path + TEMP_SUFFIX
	var backup_path := path + BACKUP_SUFFIX
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _save_error(path, "Failed to open temporary save for writing: %s" % error_string(FileAccess.get_open_error()))
	file.store_string(json_text)
	file.flush()
	file.close()
	var verification := _read_wrapper(temporary_path)
	if not bool(verification.get("valid", false)):
		DirAccess.remove_absolute(temporary_path)
		return _save_error(path, "Temporary save verification failed")
	var had_primary := FileAccess.file_exists(path)
	if had_primary and FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	if had_primary:
		var backup_error := DirAccess.rename_absolute(path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temporary_path)
			return _save_error(path, "Could not preserve previous save: %s" % error_string(backup_error))
	var replace_error := DirAccess.rename_absolute(temporary_path, path)
	if replace_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, path)
		DirAccess.remove_absolute(temporary_path)
		return _save_error(path, "Could not replace save atomically: %s" % error_string(replace_error))
	save_completed.emit(path)
	return true

func load_json(path: String, default_data: Dictionary = {}) -> Dictionary:
	if not FileAccess.file_exists(path):
		var missing_backup := path + BACKUP_SUFFIX
		if FileAccess.file_exists(missing_backup):
			return _recover_backup(path, missing_backup, default_data)
		return default_data.duplicate(true)
	var result := _read_wrapper(path)
	if not bool(result.get("valid", false)):
		var backup_path := path + BACKUP_SUFFIX
		if FileAccess.file_exists(backup_path):
			return _recover_backup(path, backup_path, default_data)
		ErrorHandler.handle(
			"SAVE_PARSE_FAILED",
			"Saved data could not be read and no recovery copy was available.",
			{"path": path},
			ErrorHandler.Severity.ERROR
		)
		return default_data.duplicate(true)
	var version := int(result.get("version", 1))
	var data: Dictionary = (result.get("data", {}) as Dictionary).duplicate(true)
	if version < SAVE_VERSION:
		data = _migrate(data, version, SAVE_VERSION)
	save_loaded.emit(path, data)
	return data

func delete_save(path: String) -> bool:
	var success := true
	for candidate: String in [path, path + TEMP_SUFFIX, path + BACKUP_SUFFIX]:
		if FileAccess.file_exists(candidate):
			var remove_error := DirAccess.remove_absolute(candidate)
			if remove_error != OK:
				success = false
				ErrorHandler.handle("SAVE_DELETE_FAILED", "Delete failed", {"path": candidate, "err": remove_error})
	return success

func has_save(path: String) -> bool:
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + BACKUP_SUFFIX)

func list_saves(dir_path: String = SAVE_DIR) -> Array[String]:
	var saves: Array[String] = []
	if not DirAccess.dir_exists_absolute(dir_path):
		return saves
	var directory := DirAccess.open(dir_path)
	if directory == null:
		return saves
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.ends_with(".json"):
			saves.append(dir_path.path_join(file_name))
		file_name = directory.get_next()
	directory.list_dir_end()
	saves.sort()
	return saves

func _read_wrapper(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"valid": false, "reason": "open"}
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {"valid": false, "reason": "parse"}
	var parsed: Variant = parser.data
	if not (parsed is Dictionary):
		return {"valid": false, "reason": "parse"}
	var wrapper: Dictionary = parsed
	var data_value: Variant = wrapper.get("data", {})
	if not (data_value is Dictionary):
		return {"valid": false, "reason": "data"}
	return {
		"valid": true,
		"version": int(wrapper.get("version", 1)),
		"data": (data_value as Dictionary).duplicate(true)
	}

func _recover_backup(path: String, backup_path: String, default_data: Dictionary) -> Dictionary:
	var recovered := _read_wrapper(backup_path)
	if not bool(recovered.get("valid", false)):
		ErrorHandler.handle(
			"SAVE_RECOVERY_FAILED",
			"Saved data and its recovery copy could not be read.",
			{"path": path},
			ErrorHandler.Severity.ERROR
		)
		return default_data.duplicate(true)
	var data: Dictionary = (recovered.get("data", {}) as Dictionary).duplicate(true)
	var version := int(recovered.get("version", 1))
	if version < SAVE_VERSION:
		data = _migrate(data, version, SAVE_VERSION)
	# Restore through the same verified atomic writer. The existing corrupt file
	# becomes disposable once the recovered data is safely written.
	DirAccess.remove_absolute(path)
	save_json(path, data)
	ErrorHandler.handle(
		"SAVE_RECOVERED",
		"Recovered saved progress from the local safety copy.",
		{"path": path},
		ErrorHandler.Severity.INFO
	)
	save_loaded.emit(path, data)
	return data

func _migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	var migrated := data.duplicate(true)
	if from_version <= 1 and to_version >= 2:
		if migrated.has("player_name") and not migrated.has("display_name"):
			migrated["display_name"] = migrated["player_name"]
		migrated.erase("player_name")
		if migrated.has("profile_name") and not migrated.has("display_name"):
			migrated["display_name"] = migrated["profile_name"]
		migrated.erase("profile_name")
	migrated["version"] = to_version
	return migrated

func _cleanup_stale_temporary(path: String) -> void:
	var temporary_path := path + TEMP_SUFFIX
	if FileAccess.file_exists(temporary_path):
		DirAccess.remove_absolute(temporary_path)

func _save_error(path: String, reason: String) -> bool:
	ErrorHandler.handle("SAVE_WRITE_FAILED", reason, {"path": path})
	save_failed.emit(path, reason)
	return false

func save_profile(data: Dictionary) -> bool:
	return save_json(PROFILE_FILE, data)

func load_profile() -> Dictionary:
	return load_json(PROFILE_FILE, {})

func save_settings(data: Dictionary) -> bool:
	return save_json(SETTINGS_FILE, data)

func load_settings() -> Dictionary:
	return load_json(SETTINGS_FILE, {})

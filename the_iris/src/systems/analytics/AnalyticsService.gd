extends Node
## AnalyticsService - Decoupled analytics / telemetry
## Buffers locally, ready for remote endpoint injection
## No hard dependencies, privacy-respecting

signal event_logged(event_name: String, params: Dictionary)
signal screen_view_logged(screen_name: String)

var _event_buffer: Array[Dictionary] = []
var _session_id: String = ""
var _is_enabled: bool = true
var _initialized: bool = false
const MAX_BUFFER := 200
const MAX_BUFFER_FILE_BYTES := 1048576
const BUFFER_FILE := "user://analytics_buffer.jsonl"
const ANALYTICS_VERSION := 1

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_session_id = _generate_session_id()
	_is_enabled = true
	if SettingsService:
		_is_enabled = SettingsService.get_value("analytics_enabled", true)
		SettingsService.setting_changed.connect(_on_setting_changed)

	_initialized = true

	if _is_enabled:
		log_event("session_start", {
			"app_version": ConfigService.get_value("app_version", "unknown") if ConfigService else "unknown",
			"platform": OS.get_name(),
			"session_id": _session_id
		})

func _on_setting_changed(key: String, value: Variant) -> void:
	if key == "analytics_enabled":
		_is_enabled = bool(value)
		if not _is_enabled:
			clear_buffer()

func log_event(event_name: String, params: Dictionary = {}) -> void:
	if not _is_enabled:
		return

	var entry := {
		"v": ANALYTICS_VERSION,
		"event": event_name,
		"params": params,
		"timestamp": Time.get_datetime_string_from_system(true),
		"ticks_ms": Time.get_ticks_msec(),
		"session_id": _session_id,
		"phase": str(AppState.current_phase) if AppState else "unknown"
	}

	_event_buffer.append(entry)
	if _event_buffer.size() > MAX_BUFFER:
		_event_buffer.pop_front()

	event_logged.emit(event_name, params)

	# Local buffer persistence (JSONL)
	_append_to_file(entry)

	# Debug print in dev
	if ConfigService and ConfigService.get_value("environment") == "development":
		pass

func log_screen_view(screen_name: String, params: Dictionary = {}) -> void:
	var merged := {"screen": screen_name}
	merged.merge(params)
	log_event("screen_view", merged)
	screen_view_logged.emit(screen_name)

func log_error(code: String, message: String, context: Dictionary = {}, severity: int = 2) -> void:
	log_event("error_logged", {
		"code": code,
		"message": message,
		"context": context,
		"severity": severity
	})

func log_experience_event(exp_id: String, action: String, data: Dictionary = {}) -> void:
	var p := {"exp_id": exp_id, "action": action}
	p.merge(data)
	log_event("experience_event", p)

func _append_to_file(entry: Dictionary) -> void:
	var line := JSON.stringify(entry) + "\n"
	if _buffer_file_size() + line.to_utf8_buffer().size() > MAX_BUFFER_FILE_BYTES:
		if FileAccess.file_exists(BUFFER_FILE):
			DirAccess.remove_absolute(BUFFER_FILE)
	var file := FileAccess.open(BUFFER_FILE, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(BUFFER_FILE, FileAccess.WRITE)
		if file == null:
			return
	file.seek_end()
	file.store_string(line)
	file.close()

func _buffer_file_size() -> int:
	if not FileAccess.file_exists(BUFFER_FILE):
		return 0
	var file := FileAccess.open(BUFFER_FILE, FileAccess.READ)
	if file == null:
		return 0
	var length := file.get_length()
	file.close()
	return length

func _generate_session_id() -> String:
	return "sess_%d_%d" % [Time.get_ticks_msec(), randi() % 100000]

func get_buffered_events() -> Array[Dictionary]:
	return _event_buffer.duplicate()

func clear_buffer() -> void:
	_event_buffer.clear()
	if FileAccess.file_exists(BUFFER_FILE):
		DirAccess.remove_absolute(BUFFER_FILE)

func set_enabled(enabled: bool) -> void:
	_is_enabled = enabled
	if SettingsService:
		SettingsService.set_value("analytics_enabled", enabled)

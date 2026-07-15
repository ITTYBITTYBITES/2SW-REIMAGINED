extends Node
## AppState - Single source of truth for app-level state
## Machine: SPLASH -> BOOT -> HOME -> LIBRARY/PROFILE/ACHIEVEMENTS/SETTINGS etc

enum AppPhase { BOOT, SPLASH, HOME, EXPERIENCES, PROFILE, SETTINGS, ACHIEVEMENTS, PROGRAMS, EXPERIENCE_PLAYING }

signal phase_changed(new_phase: int, old_phase: int)
signal state_updated(key: String, value: Variant)
signal loading_changed(is_loading: bool, message: String)

var current_phase: int = AppPhase.BOOT
var previous_phase: int = AppPhase.BOOT
var is_initialized: bool = false
var is_loading: bool = false
var loading_message: String = ""
var session_start_time: int = 0
var active_experience_id: String = ""

# Transient data store for passing between screens
var transient_data: Dictionary = {}
var _state: Dictionary = {}

func _ready() -> void:
	session_start_time = Time.get_ticks_msec()
	EventBus.app_initialized.connect(_on_app_initialized)

func _on_app_initialized() -> void:
	is_initialized = true

func set_phase(new_phase: int) -> void:
	if new_phase == current_phase:
		return
	var old := current_phase
	previous_phase = old
	current_phase = new_phase
	phase_changed.emit(new_phase, old)

func set_loading(loading: bool, msg: String = "") -> void:
	is_loading = loading
	loading_message = msg
	loading_changed.emit(loading, msg)

func set_value(key: String, value: Variant) -> void:
	_state[key] = value
	state_updated.emit(key, value)

func get_value(key: String, default: Variant = null) -> Variant:
	return _state.get(key, default)

func set_transient(key: String, value: Variant) -> void:
	transient_data[key] = value

func get_transient(key: String, default: Variant = null) -> Variant:
	return transient_data.get(key, default)

func clear_transient(key: String) -> void:
	transient_data.erase(key)

func get_session_duration_ms() -> int:
	return Time.get_ticks_msec() - session_start_time

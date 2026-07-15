extends Node
## EventBus - Decoupled messaging
## Global signal bus to keep systems independent.

@warning_ignore("unused_signal")
signal app_initialized()
@warning_ignore("unused_signal")
signal navigation_requested(route: String, params: Dictionary)
@warning_ignore("unused_signal")
signal navigation_changed(route: String, params: Dictionary)
@warning_ignore("unused_signal")
signal setting_changed(key: String, value: Variant)
@warning_ignore("unused_signal")
signal theme_changed(theme_name: String)
@warning_ignore("unused_signal")
signal audio_requested(bus: String, sound_id: String, params: Dictionary)
@warning_ignore("unused_signal")
signal profile_updated(profile_data: Dictionary)
@warning_ignore("unused_signal")
signal experience_unlocked(exp_id: String)
@warning_ignore("unused_signal")
signal experience_completed(exp_id: String, result: Dictionary)
@warning_ignore("unused_signal")
signal error_occurred(code: String, message: String, context: Dictionary)
@warning_ignore("unused_signal")
signal accessibility_changed(settings: Dictionary)

var _event_log: Array[Dictionary] = []
const MAX_LOG_SIZE := 200

func _ready() -> void:
	pass

func emit_routed(signal_name: String, args: Array = []) -> void:
	_log_event(signal_name, args)

func _log_event(event_name: String, args: Array) -> void:
	var entry := {
		"name": event_name,
		"args": args,
		"timestamp": Time.get_ticks_msec()
	}
	_event_log.append(entry)
	if _event_log.size() > MAX_LOG_SIZE:
		_event_log.pop_front()

func get_recent_events(count: int = 20) -> Array:
	return _event_log.slice(-count)

func publish_navigation(route: String, params: Dictionary = {}) -> void:
	_log_event("navigation_requested", [route, params])
	navigation_requested.emit(route, params)

func publish_app_initialized() -> void:
	_log_event("app_initialized", [])
	app_initialized.emit()

func publish_navigation_changed(route: String, params: Dictionary = {}) -> void:
	_log_event("navigation_changed", [route, params])
	navigation_changed.emit(route, params)

func publish_setting_changed(key: String, value: Variant) -> void:
	_log_event("setting_changed", [key, value])
	setting_changed.emit(key, value)

func publish_theme_changed(theme_name: String) -> void:
	_log_event("theme_changed", [theme_name])
	theme_changed.emit(theme_name)

func request_audio(bus: String, sound_id: String, params: Dictionary = {}) -> void:
	_log_event("audio_requested", [bus, sound_id, params])
	audio_requested.emit(bus, sound_id, params)

func publish_profile_updated(profile_data: Dictionary) -> void:
	_log_event("profile_updated", [profile_data])
	profile_updated.emit(profile_data)

func publish_experience_unlocked(exp_id: String) -> void:
	_log_event("experience_unlocked", [exp_id])
	experience_unlocked.emit(exp_id)

func publish_experience_completed(exp_id: String, result: Dictionary = {}) -> void:
	_log_event("experience_completed", [exp_id, result])
	experience_completed.emit(exp_id, result)

func publish_accessibility_changed(settings: Dictionary) -> void:
	_log_event("accessibility_changed", [settings])
	accessibility_changed.emit(settings)

func publish_error(code: String, message: String, context: Dictionary = {}) -> void:
	_log_event("error_occurred", [code, message, context])
	error_occurred.emit(code, message, context)

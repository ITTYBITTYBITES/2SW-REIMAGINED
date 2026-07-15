extends Node
## ErrorHandler - Centralized error handling and recovery
## Provides safe boundaries, logging, and user-friendly feedback

enum Severity { INFO, WARNING, ERROR, CRITICAL }

signal error_logged(entry: Dictionary)
signal user_message_requested(message: String, severity: int)

var _error_history: Array[Dictionary] = []
const MAX_HISTORY := 100
var _crash_count_today: int = 0

func _ready() -> void:
	EventBus.error_occurred.connect(_on_error_occurred)

func _on_error_occurred(code: String, message: String, context: Dictionary) -> void:
	handle(code, message, context, Severity.ERROR)

func handle(
	code: String,
	message: String,
	context: Dictionary = {},
	severity: int = Severity.ERROR
) -> void:
	var entry := {
		"code": code,
		"message": message,
		"context": context,
		"severity": severity,
		"timestamp": Time.get_datetime_string_from_system(),
		"ticks": Time.get_ticks_msec(),
		"phase": str(AppState.current_phase) if AppState else "unknown"
	}
	_error_history.append(entry)
	if _error_history.size() > MAX_HISTORY:
		_error_history.pop_front()

	error_logged.emit(entry)

	match severity:
		Severity.CRITICAL:
			push_error("[CRITICAL] %s: %s %s" % [code, message, str(context)])
			user_message_requested.emit("A critical error occurred. Restarting safely...", severity)
			_attempt_safe_recovery()
		Severity.ERROR:
			push_error("[ERROR] %s: %s %s" % [code, message, str(context)])
			user_message_requested.emit(_friendly_message(code), severity)
		Severity.WARNING:
			push_warning("[WARN] %s: %s" % [code, message])
		_:
			pass

	# Also forward to Analytics if available
	if AnalyticsService:
		AnalyticsService.log_error(code, message, context, severity)

func handle_exception(code: String, context: Dictionary = {}) -> void:
	handle(code, "Exception caught", context, Severity.ERROR)

func get_history() -> Array[Dictionary]:
	return _error_history.duplicate()

func clear_history() -> void:
	_error_history.clear()

func _friendly_message(code: String) -> String:
	if code.begins_with("SAVE_"):
		return "Progress could not be saved safely. Your current screen can continue."
	if code.begins_with("NAV_") or code.begins_with("SCREEN_"):
		return "That screen could not be opened. Please try again."
	if code.begins_with("TUTORIAL_"):
		return "The tutorial could not be opened. Please choose another challenge."
	if code.begins_with("INTERACTION_") or code.begins_with("RUNTIME_"):
		return "That round could not continue. Please start another challenge."
	return "Something went wrong. Please try again."

func _attempt_safe_recovery() -> void:
	_crash_count_today += 1
	AppState.set_loading(false)
	NavigationService.navigate_to("home")

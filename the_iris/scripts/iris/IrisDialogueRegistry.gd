extends RefCounted
class_name IrisDialogueRegistry

## Data-driven dialogue registry for Living Iris authored presence events.
## Mission 054A keeps voice/text/audio/haptic hooks in one content file so
## personality responses can grow without scattering copy through UI scripts.

const DIALOGUE_PATH := "res://content/iris/iris_dialogue_events.json"

const FALLBACK_EVENTS := {
	"iris_welcome": {
		"text": "I remember your perspective.",
		"accessibility_text": "The Iris awakens and recognizes your perspective.",
		"expression_mode": "INTRODUCING",
		"audio": "res://assets/audio/iris/iris_focus.ogg",
		"haptic": "iris_welcome_pulse",
		"voice": "voice_placeholder_iris_welcome"
	},
	"iris_idle": {
		"text": "I am still here.",
		"accessibility_text": "The Iris remains present and attentive.",
		"expression_mode": "IDLE",
		"audio": "res://assets/audio/iris/iris_presence.ogg",
		"haptic": "iris_idle_breath",
		"voice": "voice_placeholder_iris_idle"
	},
	"iris_ready": {
		"text": "A memory is waiting.",
		"accessibility_text": "The Iris is ready. A memory is waiting.",
		"expression_mode": "GUIDING",
		"audio": "res://assets/audio/iris/iris_confirm.ogg",
		"haptic": "iris_ready_pulse",
		"voice": "voice_placeholder_iris_ready"
	},
	"iris_return": {
		"text": "You came back with more of the pattern.",
		"accessibility_text": "The Iris acknowledges your return from the memory field.",
		"expression_mode": "REFLECTIVE",
		"audio": "res://assets/audio/iris/iris_presence.ogg",
		"haptic": "iris_return_pulse",
		"voice": "voice_placeholder_iris_return"
	}
}

static var _events_cache: Dictionary = {}
static var _loaded := false

static func has_event(event_name: String) -> bool:
	_ensure_loaded()
	return _events_cache.has(event_name)

static func event_data(event_name: String) -> Dictionary:
	_ensure_loaded()
	return _events_cache.get(event_name, {}).duplicate(true)

static func text_for_event(event_name: String) -> String:
	return str(event_data(event_name).get("text", ""))

static func accessibility_text_for_event(event_name: String) -> String:
	return str(event_data(event_name).get("accessibility_text", text_for_event(event_name)))

static func expression_for_event(event_name: String, fallback: String) -> String:
	return str(event_data(event_name).get("expression_mode", fallback))

static func audio_for_event(event_name: String) -> String:
	return str(event_data(event_name).get("audio", ""))

static func haptic_for_event(event_name: String) -> String:
	return str(event_data(event_name).get("haptic", ""))

static func voice_for_event(event_name: String) -> String:
	return str(event_data(event_name).get("voice", ""))

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_events_cache = FALLBACK_EVENTS.duplicate(true)
	if not FileAccess.file_exists(DIALOGUE_PATH):
		return
	var text := FileAccess.get_file_as_string(DIALOGUE_PATH)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_warning("⚠️ [IrisDialogueRegistry] Could not parse %s" % DIALOGUE_PATH)
		return
	var loaded_events: Dictionary = parsed.get("events", {})
	for event_name in loaded_events.keys():
		if loaded_events[event_name] is Dictionary:
			_events_cache[event_name] = loaded_events[event_name]

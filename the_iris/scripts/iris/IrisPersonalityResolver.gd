extends Node
class_name IrisPersonalityResolver

## Interprets authoritative IrisCore state plus an experience event.
## It never transitions IrisCore or owns a lifecycle of its own.
enum ExpressionMode { INTRODUCING, IDLE, CURIOUS, ATTENTIVE, GUIDING, REFLECTIVE }

signal response_intent_emitted(intent: IrisResponseIntent)

var latest_intent: IrisResponseIntent

func resolve(core_state: int, experience_event: String) -> IrisResponseIntent:
	var mode := _resolve_mode(core_state, experience_event)
	var mode_name: String = str(ExpressionMode.keys()[int(mode)])
	var mode_key: String = mode_name.to_lower()
	var intent := IrisResponseIntent.new(
		mode_name,
		"iris_%s_visual" % mode_key,
		"iris_%s_text" % mode_key,
		"iris_%s_audio" % mode_key,
		"iris_%s_haptic" % mode_key,
		"iris_%s_voice" % mode_key,
		experience_event,
		core_state
	)
	latest_intent = intent
	response_intent_emitted.emit(intent)
	return intent

func _resolve_mode(core_state: int, experience_event: String) -> ExpressionMode:
	match experience_event:
		"boot_complete":
			return ExpressionMode.INTRODUCING
		"memory_focus":
			if core_state == IrisCore.State.FOCUSED:
				return ExpressionMode.ATTENTIVE
			return ExpressionMode.CURIOUS
		"memory_selected", "witness_entered":
			return ExpressionMode.GUIDING
		"witness_completed":
			return ExpressionMode.REFLECTIVE
		"hub_return":
			return ExpressionMode.IDLE
		"evolution_detected", "new_aperture_reached", "iris_pattern_changed":
			return ExpressionMode.ATTENTIVE
		"chapter_restored":
			return ExpressionMode.REFLECTIVE

	if core_state == IrisCore.State.REFLECTIVE:
		return ExpressionMode.REFLECTIVE
	if core_state == IrisCore.State.ATTENDING or core_state == IrisCore.State.FOCUSED:
		return ExpressionMode.ATTENTIVE
	return ExpressionMode.IDLE

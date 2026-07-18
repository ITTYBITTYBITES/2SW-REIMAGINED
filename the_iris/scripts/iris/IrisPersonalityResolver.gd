extends Node
class_name IrisPersonalityResolver

## Interprets authoritative IrisCore state plus an experience event.
## It never transitions IrisCore or owns a lifecycle of its own.
enum ExpressionMode { INTRODUCING, IDLE, CURIOUS, ATTENTIVE, GUIDING, REFLECTIVE }

signal response_intent_emitted(intent: IrisResponseIntent)

var latest_intent: IrisResponseIntent

func resolve(core_state: int, experience_event: String) -> IrisResponseIntent:
	var mode := _resolve_mode(core_state, experience_event)
	var fallback_mode_name: String = str(ExpressionMode.keys()[int(mode)])
	var mode_name := IrisDialogueRegistry.expression_for_event(experience_event, fallback_mode_name)
	var mode_key := mode_name.to_lower()
	var text_key := "dialogue:%s" % experience_event if IrisDialogueRegistry.has_event(experience_event) else "iris_%s_text" % mode_key
	var audio_key := IrisDialogueRegistry.audio_for_event(experience_event) if IrisDialogueRegistry.has_event(experience_event) else "iris_%s_audio" % mode_key
	var haptic_key := IrisDialogueRegistry.haptic_for_event(experience_event) if IrisDialogueRegistry.has_event(experience_event) else "iris_%s_haptic" % mode_key
	var voice_key := IrisDialogueRegistry.voice_for_event(experience_event) if IrisDialogueRegistry.has_event(experience_event) else "iris_%s_voice" % mode_key
	var intent := IrisResponseIntent.new(
		mode_name,
		"iris_%s_visual" % mode_key,
		text_key,
		audio_key,
		haptic_key,
		voice_key,
		experience_event,
		core_state
	)
	latest_intent = intent
	response_intent_emitted.emit(intent)
	return intent

func _resolve_mode(core_state: int, experience_event: String) -> ExpressionMode:
	match experience_event:
		"boot_complete", "iris_welcome":
			return ExpressionMode.INTRODUCING
		"iris_ready":
			return ExpressionMode.GUIDING
		"iris_return":
			return ExpressionMode.REFLECTIVE
		"iris_idle":
			return ExpressionMode.IDLE
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

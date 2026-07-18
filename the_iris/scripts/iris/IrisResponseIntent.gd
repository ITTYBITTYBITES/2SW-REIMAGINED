extends RefCounted
class_name IrisResponseIntent

## A derived response contract. It carries no lifecycle control and has no side effects.
var expression_mode := "IDLE"
var visual_cue_key := ""
var text_key := ""
var audio_key := ""
var haptic_key := ""
var voice_key := ""
var source_event := ""
var core_state := -1

func _init(mode := "IDLE", visual := "", text := "", audio := "", haptic := "", voice := "", event_key := "", state_value := -1) -> void:
	expression_mode = mode
	visual_cue_key = visual
	text_key = text
	audio_key = audio
	haptic_key = haptic
	voice_key = voice
	source_event = event_key
	core_state = state_value

func to_dictionary() -> Dictionary:
	return {
		"expression_mode": expression_mode,
		"visual_cue_key": visual_cue_key,
		"text_key": text_key,
		"audio_key": audio_key,
		"haptic_key": haptic_key,
		"voice_key": voice_key,
		"source_event": source_event,
		"core_state": core_state
	}

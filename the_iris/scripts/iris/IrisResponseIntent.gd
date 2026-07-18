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

## =====================================================================
## SENSORY CONSUMER CONTRACT INTERFACES (Mission 031 Pass)
## =====================================================================
## Native audio, haptics, and accessibility systems subscribe to these contracts.

static func consume_audio(intent: IrisResponseIntent) -> void:
	# Virtual Hook: Audio triggers based on intent.audio_key or intent.voice_key
	pass

static func consume_haptics(intent: IrisResponseIntent) -> void:
	# Virtual Hook: Haptic triggers based on intent.haptic_key or core_state
	pass

static func consume_accessibility(intent: IrisResponseIntent) -> void:
	# Virtual Hook: Narration engine announces description text mapped to intent.text_key
	pass

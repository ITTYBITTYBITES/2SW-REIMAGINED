extends RefCounted
class_name IrisAccessibilityConsumer

## Lightweight Accessibility Consumer Foundation for 2SW.
## Manages text narration narration contracts, screen reader compatibility, and 
## reduced-motion visual constraints.

## User configuration parameters
static var reduced_motion_enabled := false
static var screen_reader_active := false

## Announce an experience description or state change.
static func announce(text_to_speak: String) -> void:
	if text_to_speak.is_empty():
		return
		
	print("🗣️ [IrisAccessibilityConsumer TTS] Narration: '%s'" % text_to_speak)
	
	# Future Hook: Integrate native mobile Screen Reader / TTS APIs:
	# e.g., Display as closed captions on screen, or call VoiceOver / TalkBack bridges.

## Entry point for parsing dynamic response intent data.
static func consume(intent: IrisResponseIntent) -> void:
	if intent == null:
		return
		
	# Text alternatives translation
	var speech_text := ""
	if IrisDialogueRegistry.has_event(intent.source_event):
		speech_text = IrisDialogueRegistry.accessibility_text_for_event(intent.source_event)
	match intent.text_key:
		"iris_introducing_text":
			speech_text = "The Iris has emerged. It is here."
		"iris_idle_text":
			speech_text = "The Iris is quiet."
		"iris_curious_text":
			speech_text = "The Iris notices a detail in the memory."
		"iris_attentive_text":
			speech_text = "The Iris has locked attention onto your focus."
		"iris_guiding_text":
			speech_text = "The Iris is guiding your reconstruction."
		"iris_reflective_text":
			speech_text = "The Iris is reflecting on the restored memory."
			
	if not speech_text.is_empty():
		announce(speech_text)
		
	# Describe active events for non-visual players
	match intent.source_event:
		"boot_complete":
			announce("Calibration sequence concluded successfully.")
		"memory_focus":
			announce("Memory shard selection is focused.")
		"witness_entered":
			announce("Entered Witness Moment. Gathering observations.")
		"evolution_detected":
			announce("Progression wave detected. The Iris pattern is evolving.")
		"new_aperture_reached":
			announce("Your Aperture Rank has increased.")

## Query whether animations, screen-shakes, or fast strobe flashes should be skipped.
static func is_reduced_motion() -> bool:
	# On native platforms, this checks OS-level settings (such as iOS Reduced Motion or Android Remove Animations)
	return reduced_motion_enabled

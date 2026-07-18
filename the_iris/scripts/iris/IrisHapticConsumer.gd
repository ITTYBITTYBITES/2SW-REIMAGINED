extends RefCounted
class_name IrisHapticConsumer

## Lightweight Haptic Consumer Foundation for 2SW.
## Integrates platform-safe tactile motor vibration triggers.

## Standardized haptic patterns mapping to mobile haptic motors (such as iOS Taptic or Android HapticFeedback)
enum Pattern { LIGHT, MEDIUM, HEAVY, SUCCESS, FAILURE, RESONANCE }

static func consume(intent: IrisResponseIntent) -> void:
	if intent == null:
		return
		
	var haptic_key := intent.haptic_key
	var event := intent.source_event
	
	# Resolve event-based haptic triggers
	match event:
		"memory_focus":
			trigger_pattern(Pattern.LIGHT, "Awareness Pulse")
		"anomaly_found":
			trigger_pattern(Pattern.MEDIUM, "Discovery Pulse")
		"capture_succeeded":
			trigger_pattern(Pattern.SUCCESS, "Capture Confirmation")
		"witness_completed":
			trigger_pattern(Pattern.RESONANCE, "Completion Resonance")
		"evolution_detected":
			trigger_pattern(Pattern.HEAVY, "Evolution Shockwave")
		_:
			# Fallback based on expression mode
			if intent.expression_mode == "ATTENTIVE":
				trigger_pattern(Pattern.MEDIUM, haptic_key)
			else:
				trigger_pattern(Pattern.LIGHT, haptic_key)

## Safe haptic motor caller. On mobile platforms, this invokes OS-level feedback.
static func trigger_pattern(pattern: Pattern, debug_label: String) -> void:
	match pattern:
		Pattern.LIGHT:
			print("📳 [IrisHapticConsumer] Light Taptic Pulse triggered: %s" % debug_label)
			_os_vibrate(10)
		Pattern.MEDIUM:
			print("📳 [IrisHapticConsumer] Medium Taptic Pulse triggered: %s" % debug_label)
			_os_vibrate(25)
		Pattern.HEAVY:
			print("📳 [IrisHapticConsumer] Heavy Taptic Pulse triggered: %s" % debug_label)
			_os_vibrate(50)
		Pattern.SUCCESS:
			print("📳 [IrisHapticConsumer] Double Success Pulse triggered: %s" % debug_label)
			_os_vibrate(20)
			# Small delay for double pulse
			_os_vibrate(20)
		Pattern.FAILURE:
			print("📳 [IrisHapticConsumer] Triple Failure Rumble triggered: %s" % debug_label)
			_os_vibrate(40)
		Pattern.RESONANCE:
			print("📳 [IrisHapticConsumer] Sweeping Resonance Vibration triggered: %s" % debug_label)
			_os_vibrate(80)

static func _os_vibrate(duration_ms: int) -> void:
	# Platform-safe call: vibrates handheld if supported (e.g. mobile), ignored on desktop
	Input.vibrate_handheld(duration_ms)

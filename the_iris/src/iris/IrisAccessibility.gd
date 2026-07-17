extends Node
class_name IrisAccessibility

## IrisAccessibility.gd — Handles captions, haptics, and sensory adaptation for Living Iris 4.0.

func trigger_haptic(intensity_ms: int = 20) -> void:
	if AccessibilityService and AccessibilityService.has_method("vibrate"):
		AccessibilityService.vibrate(intensity_ms)
	elif Input.has_method("vibrate_handheld"):
		Input.vibrate_handheld(intensity_ms, 0.1)

func announce_state(message: String) -> void:
	if AccessibilityService and AccessibilityService.has_method("announce"):
		AccessibilityService.announce(message)

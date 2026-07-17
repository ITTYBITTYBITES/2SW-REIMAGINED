extends Node
class_name IrisHapticController

## IrisHapticController.gd — Handles device haptics for Living Iris 4.0.
## Currently provides integration hooks for tri-modal feedback.

var haptics_enabled := true

func trigger_haptic_pulse(intensity: float, duration: float) -> void:
	if not haptics_enabled:
		return
	if Input.has_method("vibrate_handheld"):
		Input.vibrate_handheld(int(duration * 1000.0), intensity)

func play_awaken_haptic() -> void:
	# Hook: Soft building rumble
	trigger_haptic_pulse(0.4, 0.6)

func play_focus_haptic() -> void:
	# Hook: Sharp, immediate click
	trigger_haptic_pulse(0.8, 0.08)

func play_settling_haptic() -> void:
	# Hook: Long, decaying sigh
	trigger_haptic_pulse(0.3, 0.8)

func play_destination_haptic(key: String) -> void:
	# Hook: Unique rhythms per destination
	trigger_haptic_pulse(0.5, 0.15)

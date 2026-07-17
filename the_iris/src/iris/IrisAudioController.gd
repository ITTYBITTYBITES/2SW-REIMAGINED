extends Node
class_name IrisAudioController

## IrisAudioController.gd — Handles audio responses for Living Iris 4.0.

var procedural_sound: ProceduralIrisSound

func set_sound_service(service: ProceduralIrisSound) -> void:
	procedural_sound = service

func play_awaken_tone() -> void:
	if procedural_sound and procedural_sound.has_method("awakening_tone"):
		procedural_sound.awakening_tone()
	elif AudioService:
		AudioService.play_ui("ui_unlock")

func play_focus_tone() -> void:
	if procedural_sound and procedural_sound.has_method("focus_notice_tone"):
		procedural_sound.focus_notice_tone()
	elif AudioService:
		AudioService.play_ui("ui_click")

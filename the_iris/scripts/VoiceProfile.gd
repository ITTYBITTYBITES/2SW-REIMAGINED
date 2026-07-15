extends Resource
class_name VoiceProfile

@export var voice_name := ""
@export_range(0, 100) var volume := 58
@export_range(0.5, 2.0) var pitch := 0.92
@export_range(0.5, 2.0) var rate := 0.78
@export var tone_description := "calm, slow, minimal"

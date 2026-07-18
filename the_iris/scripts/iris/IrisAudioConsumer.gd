extends RefCounted
class_name IrisAudioConsumer

## Lightweight Audio Consumer Foundation for 2SW.
## Plays dynamic sensory cues matching IrisResponseIntent specifications.

## Virtual Sound FX contract database (for future asset loading)
const AUDIO_ASSETS := {
	"iris_introducing_audio": "res://assets/audio/iris_intro.ogg",
	"iris_curious_audio": "res://assets/audio/iris_curious.ogg",
	"iris_attentive_audio": "res://assets/audio/iris_attentive.ogg",
	"iris_guiding_audio": "res://assets/audio/iris_guiding.ogg",
	"iris_reflective_audio": "res://assets/audio/iris_reflective.ogg"
}

## Entry point for audio playback consumption.
static func consume(intent: IrisResponseIntent) -> void:
	if intent == null:
		return
		
	var audio_key := intent.audio_key
	var mode := intent.expression_mode
	
	match mode:
		"INTRODUCING":
			_play_introduction_tone(audio_key)
		"CURIOUS":
			_play_curious_tone(audio_key)
		"ATTENTIVE":
			_play_attentive_tone(audio_key)
		"GUIDING":
			_play_guiding_tone(audio_key)
		"REFLECTIVE":
			_play_reflective_tone(audio_key)
		_:
			_play_fallback_tone(audio_key)

static func _play_introduction_tone(key: String) -> void:
	print("🔊 [IrisAudioConsumer] Play Introduction Tone (Key: %s) — Soft, swelling harmonic chime." % key)

static func _play_curious_tone(key: String) -> void:
	print("🔊 [IrisAudioConsumer] Play Curiosity Tone (Key: %s) — Low-frequency organic hum." % key)

static func _play_attentive_tone(key: String) -> void:
	print("🔊 [IrisAudioConsumer] Play Attention Tone (Key: %s) — Crisp, centered focus chime." % key)

static func _play_guiding_tone(key: String) -> void:
	print("🔊 [IrisAudioConsumer] Play Guidance Tone (Key: %s) — Pulsing, rhythmic guiding drone." % key)

static func _play_reflective_tone(key: String) -> void:
	print("🔊 [IrisAudioConsumer] Play Reflection Tone (Key: %s) — Warm, resonant, sustained feedback wave." % key)

static func _play_fallback_tone(key: String) -> void:
	if not key.is_empty():
		print("🔊 [IrisAudioConsumer] Play Fallback Tone (Key: %s) — Soft neutral feedback click." % key)

## Play a subtle, tactile feedback click or sound based on system-wide progression events.
static func play_presence_sound(event_name: String) -> void:
	match event_name:
		"hub_return", "idle":
			print("🔊 [IrisAudioConsumer] Subtle presence background loop triggered: %s" % event_name)
		"evolution_detected":
			print("🔊 [IrisAudioConsumer] Evolution feedback tone sweep triggered!")
		"new_aperture_reached":
			print("🔊 [IrisAudioConsumer] Progression rank acknowledgment cue triggered!")

## Dynamically play a sound from an asset manifest path safely.
static func play_manifest_sound(path: String) -> void:
	var clean_path := path.strip_edges()
	if clean_path.is_empty():
		return
		
	if not FileAccess.file_exists(clean_path):
		print("🔊 [IrisAudioConsumer] Manifest audio asset is missing: '%s'. Framework is configured and ready." % clean_path)
		return
		
	var stream = load(clean_path)
	if stream is AudioStream:
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.name = "DynamicManifestSound"
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			main_loop.root.add_child(player)
			player.play()
			player.finished.connect(func(): player.queue_free())

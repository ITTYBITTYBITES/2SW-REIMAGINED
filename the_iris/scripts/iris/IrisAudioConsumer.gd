extends RefCounted
class_name IrisAudioConsumer

## Audio Consumer for 2SW.
## Plays dynamic sensory cues matching IrisResponseIntent specifications.
## Supports one-shot playback and persistent ambient looping.
## All methods are safe when audio assets are missing — no crashes, no nulls.

## Map of Iris presence events to audio file paths.
const PRESENCE_AUDIO := {
	"iris_awaken": "res://assets/audio/iris/iris_awaken.ogg",
	"hub_return": "res://assets/audio/iris/iris_presence.ogg",
	"idle": "res://assets/audio/iris/iris_breath_loop.ogg",
	"evolution_detected": "res://assets/audio/iris/iris_transition.ogg",
	"new_aperture_reached": "res://assets/audio/iris/iris_confirm.ogg",
}

## Persistent ambient loop player — survives across phases within a single moment.
static var _ambient_player: AudioStreamPlayer = null

## ---------------------------------------------------------------------------
## ENTRY POINT: IrisResponseIntent dispatch
## ---------------------------------------------------------------------------

## Entry point for audio playback consumption.
## Resolves the intent's audio_key. If the key is a valid audio path, plays it.
## Otherwise maps expression_mode to a known path. Falls back to console log.
static func consume(intent: IrisResponseIntent) -> void:
	if intent == null:
		return

	var audio_key := intent.audio_key
	var mode := intent.expression_mode

	# If audio_key contains a real file path, play it directly.
	if not audio_key.is_empty() and FileAccess.file_exists(audio_key):
		_play_oneshot(audio_key)
		return

	# Otherwise map expression mode to a known asset path.
	var mode_path := _resolve_mode_path(mode)
	if not mode_path.is_empty() and FileAccess.file_exists(mode_path):
		_play_oneshot(mode_path)
		return

	# Final fallback: log descriptive information to console.
	_log_mode_fallback(mode, audio_key)

## ---------------------------------------------------------------------------
## PRESENCE EVENTS
## ---------------------------------------------------------------------------

## Play a presence sound by event name. Resolves from PRESENCE_AUDIO mapping.
## Plays as a one-shot cue. Maintains safe fallback when asset is missing.
static func play_presence_sound(event_name: String) -> void:
	var path: String = PRESENCE_AUDIO.get(event_name, "")
	if path.is_empty():
		print("🔊 [IrisAudioConsumer] Unknown presence event: '%s'. No audio path defined." % event_name)
		return
	_play_oneshot(path)

## ---------------------------------------------------------------------------
## MANIFEST SOUND (one-shot)
## ---------------------------------------------------------------------------

## Dynamically play a sound from an asset manifest path safely.
## One-shot: plays once, frees the AudioStreamPlayer on completion.
static func play_manifest_sound(path: String) -> void:
	_play_oneshot(path)

## ---------------------------------------------------------------------------
## AMBIENT LOOP (persistent)
## ---------------------------------------------------------------------------

## Play an ambient audio track on a persistent, looping AudioStreamPlayer.
## Only one ambient loop plays at a time. Starting a new one stops the previous.
## The loop continues until stop_ambient_loop() is called or a new loop starts.
static func play_ambient_loop(path: String) -> void:
	var clean_path := path.strip_edges()
	if clean_path.is_empty():
		return

	# Always stop existing ambient before starting a new one.
	stop_ambient_loop()

	if not FileAccess.file_exists(clean_path):
		print("🔊 [IrisAudioConsumer] Ambient asset missing: '%s'. No loop started." % clean_path)
		return

	var stream = load(clean_path)
	if not stream is AudioStream:
		push_warning("⚠️ [IrisAudioConsumer] Could not load ambient stream: '%s'" % clean_path)
		return

	# Enable loop on the stream if possible.
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.stream = stream
	_ambient_player.name = "AmbientLoopPlayer"
	_ambient_player.bus = "Master"

	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		main_loop.root.add_child(_ambient_player)
		_ambient_player.play()

## Stop the persistent ambient loop if one is playing.
static func stop_ambient_loop() -> void:
	if _ambient_player == null:
		return
	if _ambient_player.playing:
		_ambient_player.stop()
	if _ambient_player.is_inside_tree():
		_ambient_player.get_parent().remove_child(_ambient_player)
	_ambient_player.queue_free()
	_ambient_player = null

## ---------------------------------------------------------------------------
## INTERNAL HELPERS
## ---------------------------------------------------------------------------

## Play a one-shot sound. Creates a temporary AudioStreamPlayer that self-frees.
static func _play_oneshot(path: String) -> void:
	var clean_path := path.strip_edges()
	if clean_path.is_empty():
		return

	if not FileAccess.file_exists(clean_path):
		print("🔊 [IrisAudioConsumer] Audio asset missing: '%s'. Fallback active." % clean_path)
		return

	var stream = load(clean_path)
	if not stream is AudioStream:
		push_warning("⚠️ [IrisAudioConsumer] Could not load audio stream: '%s'" % clean_path)
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.name = "OneShotAudio"
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		main_loop.root.add_child(player)
		player.play()
		player.finished.connect(func(): player.queue_free())

## Map expression modes to known audio asset paths.
static func _resolve_mode_path(mode: String) -> String:
	match mode:
		"INTRODUCING":
			return "res://assets/audio/iris/iris_focus.ogg"
		"IDLE":
			return "res://assets/audio/iris/iris_breath_loop.ogg"
		"CURIOUS":
			return "res://assets/audio/iris/iris_attention.ogg"
		"ATTENTIVE":
			return "res://assets/audio/iris/iris_attention.ogg"
		"GUIDING":
			return "res://assets/audio/iris/iris_focus.ogg"
		"REFLECTIVE":
			return "res://assets/audio/iris/iris_presence.ogg"
		_:
			return ""

## Console fallback for expression modes with no audio available.
static func _log_mode_fallback(mode: String, key: String) -> void:
	match mode:
		"INTRODUCING":
			print("🔊 [IrisAudioConsumer] Introduction tone (key: %s) — no audio asset." % key)
		"CURIOUS":
			print("🔊 [IrisAudioConsumer] Curiosity tone (key: %s) — no audio asset." % key)
		"ATTENTIVE":
			print("🔊 [IrisAudioConsumer] Attention tone (key: %s) — no audio asset." % key)
		"GUIDING":
			print("🔊 [IrisAudioConsumer] Guidance tone (key: %s) — no audio asset." % key)
		"REFLECTIVE":
			print("🔊 [IrisAudioConsumer] Reflection tone (key: %s) — no audio asset." % key)
		_:
			if not key.is_empty():
				print("🔊 [IrisAudioConsumer] Fallback tone (key: %s, mode: %s) — no audio asset." % [key, mode])

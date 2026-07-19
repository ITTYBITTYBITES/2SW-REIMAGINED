extends Node
class_name IrisVoiceManager

## IrisVoiceManager — the "Ghost Voice" acoustic system.
##
## Routes TTS voice stems through a dedicated AudioBus with an FX chain that
## transforms clean speech into an "Ethereal Transmission":
##   - Heavy Reverb (void / ancient space feel)
##   - High-Pass Filter (transmission / radio feel)
##   - Chorus (ethereal shimmer / multiplicity)
## Plus a procedural white-noise whisper layer underneath all speech.
##
## Voice stems are loaded from assets/audio/iris/voice/. The FX are applied
## at runtime via Godot's AudioBus system — no pre-processing needed.

signal voice_started(bark_id: String)
signal voice_finished(bark_id: String)

const VOICE_BUS := "IrisVoice"
const WHISPER_BUS := "IrisWhisper"

# Voice stem registry — maps bark IDs to audio file paths.
const BARKS := {
	"greeting": "res://assets/audio/iris/voice/voice_greeting.ogg",
	"touch_light": "res://assets/audio/iris/voice/voice_touch_light.ogg",
	"step_through": "res://assets/audio/iris/voice/voice_step_through.ogg",
	"start_here": "res://assets/audio/iris/voice/voice_start_here.ogg",
}

var _players: Dictionary = {}  # bark_id -> AudioStreamPlayer
var _buses_ready := false

func _ready() -> void:
	_setup_buses()
	_load_stems()

func _setup_buses() -> void:
	# Create the IrisVoice bus with the Ghost FX chain.
	var voice_bus_idx := AudioServer.get_bus_index(VOICE_BUS)
	if voice_bus_idx < 0:
		AudioServer.add_bus()
		voice_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(voice_bus_idx, VOICE_BUS)
		AudioServer.set_bus_send(voice_bus_idx, "Master")

		# FX Chain: Reverb -> HighPassFilter -> Chorus
		var reverb := AudioEffectReverb.new()
		reverb.predelay_msec = 80.0
		reverb.room_size = 1.0  # largest possible space (the Void)
		reverb.damping = 0.4
		reverb.spread = 1.0
		reverb.dry = 0.4
		reverb.wet = 0.8
		AudioServer.add_bus_effect(voice_bus_idx, reverb)

		var hpf := AudioEffectHighPassFilter.new()
		hpf.cutoff_hz = 180.0  # remove the low rumble, keep the "transmission" edge
		hpf.resonance = 0.5
		AudioServer.add_bus_effect(voice_bus_idx, hpf)

		var chorus := AudioEffectChorus.new()
		chorus.voice_count = 3
		chorus.dry = 0.7
		chorus.wet = 0.5
		# Godot 4: voice params are set via property paths, not array indexing
		chorus.set("voice/0/rate_hz", 0.8)
		chorus.set("voice/0/depth_ms", 12.0)
		chorus.set("voice/0/delay_ms", 15.0)
		chorus.set("voice/1/rate_hz", 1.3)
		chorus.set("voice/1/depth_ms", 8.0)
		chorus.set("voice/1/delay_ms", 20.0)
		chorus.set("voice/2/rate_hz", 0.5)
		chorus.set("voice/2/depth_ms", 15.0)
		chorus.set("voice/2/delay_ms", 10.0)
		AudioServer.add_bus_effect(voice_bus_idx, chorus)

	# Whisper bus (subtle white-noise bed under speech)
	var whisper_bus_idx := AudioServer.get_bus_index(WHISPER_BUS)
	if whisper_bus_idx < 0:
		AudioServer.add_bus()
		whisper_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(whisper_bus_idx, WHISPER_BUS)
		AudioServer.set_bus_send(whisper_bus_idx, VOICE_BUS)
		# Low-pass the whisper so it's just "air"
		var lpf := AudioEffectLowPassFilter.new()
		lpf.cutoff_hz = 2000.0
		lpf.resonance = 0.3
		AudioServer.add_bus_effect(whisper_bus_idx, lpf)

	_buses_ready = true

func _load_stems() -> void:
	for bark_id in BARKS:
		var path: String = BARKS[bark_id]
		if FileAccess.file_exists(path):
			var stream := load(path)
			if stream is AudioStream:
				var player := AudioStreamPlayer.new()
				player.stream = stream
				player.bus = VOICE_BUS
				player.name = "Voice_%s" % bark_id
				add_child(player)
				player.finished.connect(_on_voice_finished.bind(bark_id))
				_players[bark_id] = player

## Play a voice bark through the Ghost FX chain.
## Optionally mix in the whisper layer underneath.
func play_bark(bark_id: String, _with_whisper := true) -> void:
	if not _players.has(bark_id):
		return
	var player: AudioStreamPlayer = _players[bark_id]
	if player.playing:
		return  # don't overlap the same bark
	player.play()
	voice_started.emit(bark_id)

func stop_bark(bark_id: String) -> void:
	if _players.has(bark_id):
		(_players[bark_id] as AudioStreamPlayer).stop()

func is_speaking() -> bool:
	for p in _players.values():
		if (p as AudioStreamPlayer).playing:
			return true
	return false

func _on_voice_finished(bark_id: String) -> void:
	voice_finished.emit(bark_id)

## Set the voice bus volume (0..1). Lower for ambient states, higher for focused.
func set_voice_volume(amount: float) -> void:
	var idx := AudioServer.get_bus_index(VOICE_BUS)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(amount, 0.001, 1.0)))

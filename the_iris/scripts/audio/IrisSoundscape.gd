extends Node
class_name IrisSoundscape

## IrisSoundscape — the three-layer acoustic nervous system.
##
##   Stem A (Neural Hum): A continuous low-frequency drone that pitch-shifts
##     based on the Iris's Focus state. Uses the existing iris_breath_loop.ogg
##     pitched down + a synthesized sub-bass oscillator.
##   Stem B (Saccadic Tinks): Crystalline musical "tinks" triggered exactly
##     when IrisCore performs a saccadic gaze-flick.
##   Stem C (The Blink): A soft organic "wet" whirr on each blink.
##
## Driven by IrisCore behavior — not independent. Reads the behavior dict each
## frame and reacts to gaze/blink/focus changes.

const AMBIENT_BUS := "IrisAmbient"
const SFX_BUS := "IrisSFX"


var _prev_gaze: Vector2 = Vector2.ZERO
var _prev_blink: float = 0.0
var _saccade_threshold := 0.02  # minimum gaze delta to trigger a tink
var _blink_threshold := 0.3     # blink amount to trigger the blink sound
var _tink_cooldown: float = 0.0
var _blink_sound_cooldown: float = 0.0

func _ready() -> void:
	_setup_buses()
	_load_drone()

func _setup_buses() -> void:
	# Ambient bus for the drone
	if AudioServer.get_bus_index(AMBIENT_BUS) < 0:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, AMBIENT_BUS)
		AudioServer.set_bus_send(idx, "Master")
		# Slight reverb on the ambient for spatial depth
		var rev := AudioEffectReverb.new()
		rev.room_size = 0.8
		rev.wet = 0.3
		rev.dry = 0.7
		AudioServer.add_bus_effect(idx, rev)

	# SFX bus for tinks and blinks
	if AudioServer.get_bus_index(SFX_BUS) < 0:
		AudioServer.add_bus()
		var idx2 := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx2, SFX_BUS)
		AudioServer.set_bus_send(idx2, "Master")

func _load_drone() -> void:
	pass  # V4.0: no persistent hum. The Iris is silent until it speaks.

## Called every frame from IrisController with the IrisCore's live state.
func update_from_core(core: IrisCore, delta: float) -> void:
	_tink_cooldown = maxf(_tink_cooldown - delta, 0.0)
	_blink_sound_cooldown = maxf(_blink_sound_cooldown - delta, 0.0)

	var gaze: Vector2 = core.gaze
	var blink := core.blink_amount
	var focus := core.focus_amount
	var presence := core.presence

	# --- Stem B: Saccadic Tinks ---
	var gaze_delta := (gaze - _prev_gaze).length()
	if gaze_delta > _saccade_threshold and _tink_cooldown <= 0.0 and presence > 0.3:
		_play_tink(focus)
		_tink_cooldown = 0.15  # max ~6 tinks per second
	_prev_gaze = gaze

	# --- Stem C: Blink Sound ---
	if blink > _blink_threshold and _prev_blink <= _blink_threshold and _blink_sound_cooldown <= 0.0:
		_play_blink_sound()
		_blink_sound_cooldown = 0.5
	_prev_blink = blink

## Play the "glass chime" — a soft crystalline sound when the eye is touched.
func play_glass_chime() -> void:
	var chime_path := "res://assets/audio/iris/iris_focus.ogg"
	if not FileAccess.file_exists(chime_path):
		return
	var stream := load(chime_path)
	if not stream is AudioStream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	player.pitch_scale = 1.2
	player.volume_db = -6.0
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

## Play a crystalline tink (saccadic click).
## Uses the iris_attention.ogg cue pitched up + through the SFX bus.
func _play_tink(focus: float) -> void:
	var tink_path := "res://assets/audio/iris/iris_attention.ogg"
	if not FileAccess.file_exists(tink_path):
		return
	var stream := load(tink_path)
	if not stream is AudioStream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	player.pitch_scale = 1.8 + focus * 0.4  # higher pitch = more crystalline
	player.volume_db = -10.0 - (1.0 - focus) * 6.0  # louder when focused
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

## Play the blink "wet whirr" sound.
## Uses the iris_transition.ogg filtered + pitched down.
func _play_blink_sound() -> void:
	var blink_path := "res://assets/audio/iris/iris_transition.ogg"
	if not FileAccess.file_exists(blink_path):
		return
	var stream := load(blink_path)
	if not stream is AudioStream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	player.pitch_scale = 0.7  # lower for the "wet" feel
	player.volume_db = -14.0
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

func stop_all() -> void:
	pass  # V4.0: no persistent drone to stop.

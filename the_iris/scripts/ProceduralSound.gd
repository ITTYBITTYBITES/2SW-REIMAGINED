extends Node
class_name ProceduralIrisSound

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var enabled := true
var tone := 0.0
var tone_decay := 0.0
var phase := 0.0
const SAMPLE_RATE := 22050.0

func _ready() -> void:
    set_process(true)
    if DisplayServer.get_name() == "headless":
        return
    player = AudioStreamPlayer.new()
    var stream := AudioStreamGenerator.new()
    stream.mix_rate = SAMPLE_RATE
    stream.buffer_length = 0.25
    player.stream = stream
    player.volume_db = -30.0
    add_child(player)
    player.play()
    playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func _process(_delta: float) -> void:
    if not playback:
        return
    var frames := playback.get_frames_available()
    for i in frames:
        var breath := sin(phase * TAU * 67.0) * 0.013
        var focus := sin(phase * TAU * 184.0) * tone * 0.040
        var sample := (breath + focus) if enabled else 0.0
        playback.push_frame(Vector2(sample, sample))
        phase = fmod(phase + 1.0 / SAMPLE_RATE, 1.0)
    tone = lerpf(tone, 0.0, 0.02)

func _exit_tree() -> void:
    var old_player := player
    playback = null
    player = null
    if is_instance_valid(old_player):
        old_player.stop()
        old_player.stream = null
        old_player.free()

func set_enabled(value: bool) -> void:
    enabled = value

func focus_pulse() -> void:
    tone = 1.0

func discovery_tone() -> void:
    tone = 1.35

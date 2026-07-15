extends Node
class_name ProceduralIrisSound

# Biomimetic Acoustic Synthesis Engine for Two Second Witness 4.0 Living Lens
# Replaces legacy arcade jingles with continuous sub-bass respiration, crystalline
# optical recognition bells, threshold frequency sweeps, and harmonic reflection resonance.

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var enabled := true

# Voice 1: Respiration & Awakening Sub-Bass
var breath_phase := 0.0
var breath_freq := 48.0
var breath_amp := 0.015
var awakening_timer := 0.0

# Voice 2: Destination Recognition & Focus Bell
var bell_phase := 0.0
var bell_freq := 432.0
var bell_amp := 0.0
var bell_decay_rate := 3.8

# Voice 3: Threshold Sweep & Reflection Chord
var sweep_phase := 0.0
var sweep_freq := 120.0
var sweep_target_freq := 120.0
var sweep_amp := 0.0
var sweep_decay_rate := 2.2
var is_chord_mode := false

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
    player.volume_db = -24.0
    add_child(player)
    player.play()
    playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func _process(delta: float) -> void:
    if not playback:
        return
    var frames := playback.get_frames_available()
    if frames <= 0:
        return

    # Update macro envelopes and frequency targets
    if awakening_timer > 0.0:
        awakening_timer -= delta
        breath_freq = lerpf(breath_freq, 48.0, minf(1.0, delta * 1.5))
        breath_amp = lerpf(breath_amp, 0.015, minf(1.0, delta * 1.5))
    else:
        breath_amp = lerpf(breath_amp, 0.012, minf(1.0, delta * 2.0))

    bell_amp = lerpf(bell_amp, 0.0, minf(1.0, delta * bell_decay_rate))
    sweep_freq = lerpf(sweep_freq, sweep_target_freq, minf(1.0, delta * 4.5))
    sweep_amp = lerpf(sweep_amp, 0.0, minf(1.0, delta * sweep_decay_rate))

    # Push synthesized frames into audio buffer
    for i in frames:
        # Respiration sub-bass sine wave with subtle harmonic
        var s1 := sin(breath_phase * TAU * breath_freq) * breath_amp
        s1 += sin(breath_phase * TAU * breath_freq * 1.5) * (breath_amp * 0.25)
        breath_phase = fmod(breath_phase + 1.0 / SAMPLE_RATE, 1.0)

        # Crystalline destination recognition bell
        var s2 := sin(bell_phase * TAU * bell_freq) * bell_amp
        s2 += sin(bell_phase * TAU * bell_freq * 2.0) * (bell_amp * 0.3) # Octave shimmer
        bell_phase = fmod(bell_phase + 1.0 / SAMPLE_RATE, 1.0)

        # Threshold sweep or Atmospheric Phase Lock reflection chord
        var s3 := 0.0
        if is_chord_mode:
            # 256 Hz (C) + 384 Hz (G) + 512 Hz (C octave) pure harmonic chord
            s3 += sin(sweep_phase * TAU * 256.0) * (sweep_amp * 0.4)
            s3 += sin(sweep_phase * TAU * 384.0) * (sweep_amp * 0.35)
            s3 += sin(sweep_phase * TAU * 512.0) * (sweep_amp * 0.25)
        else:
            s3 = sin(sweep_phase * TAU * sweep_freq) * sweep_amp
            s3 += sin(sweep_phase * TAU * sweep_freq * 0.5) * (sweep_amp * 0.4) # Sub impact
        sweep_phase = fmod(sweep_phase + 1.0 / SAMPLE_RATE, 1.0)

        var total_sample := (s1 + s2 + s3) if enabled else 0.0
        total_sample = clampf(total_sample, -0.95, 0.95)
        playback.push_frame(Vector2(total_sample, total_sample))

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

func awakening_tone() -> void:
    if not enabled:
        return
    awakening_timer = 2.6
    breath_freq = 144.0 # Emerges higher and settles to 48 Hz sub-bass
    breath_amp = 0.12
    bell_freq = 528.0
    bell_amp = 0.08
    bell_decay_rate = 1.2

func focus_notice_tone() -> void:
    if not enabled:
        return
    bell_freq = 256.0
    bell_amp = 0.06
    bell_decay_rate = 5.0

func emit_destination_recognition(destination_key: String) -> void:
    if not enabled:
        return
    match destination_key:
        "story_mode":
            bell_freq = 432.0 # Warm quartz bell
            bell_amp = 0.09
            bell_decay_rate = 3.6
        "archive":
            bell_freq = 144.0 # Resonant cello fundamental
            bell_amp = 0.11
            bell_decay_rate = 2.8
        "discovery", "daily_witness":
            bell_freq = 864.0 # Shimmering prism harmonic
            bell_amp = 0.075
            bell_decay_rate = 4.2
        "profile", "your_iris":
            bell_freq = 528.0 # Golden metallic chime
            bell_amp = 0.085
            bell_decay_rate = 3.2
        "settings", "calibration":
            bell_freq = 216.0 # Diagnostic calibration hum
            bell_amp = 0.08
            bell_decay_rate = 4.8
        _:
            bell_freq = 330.0
            bell_amp = 0.06
            bell_decay_rate = 4.0

func threshold_transition_tone(is_enter: bool) -> void:
    if not enabled:
        return
    is_chord_mode = false
    if is_enter:
        # Sweeping suction anticipation filter and low-end impact during threshold entry
        sweep_freq = 60.0
        sweep_target_freq = 780.0
        sweep_amp = 0.16
        sweep_decay_rate = 1.4
    else:
        # Contracting closure tone when blinking back to Iris
        sweep_freq = 440.0
        sweep_target_freq = 80.0
        sweep_amp = 0.12
        sweep_decay_rate = 2.4

func reflection_tone() -> void:
    if not enabled:
        return
    # Atmospheric Phase Lock (C-G-E harmonic chord) upon returning from Witness Moment
    is_chord_mode = true
    sweep_amp = 0.18
    sweep_decay_rate = 1.6
    # Also pulse focus bell softly
    bell_freq = 512.0
    bell_amp = 0.08
    bell_decay_rate = 2.0

# Legacy compatibility methods
func focus_pulse() -> void:
    focus_notice_tone()

func discovery_tone() -> void:
    reflection_tone()

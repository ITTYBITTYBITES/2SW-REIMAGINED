extends Node
class_name VoiceGuide

signal voice_started(key: String)
signal voice_finished(key: String)
signal caption_changed(text: String, visible: bool)

enum GuideState {
    FIRST_AWAKENING,
    FIRST_TOUCH,
    FIRST_WITNESS,
    FIRST_RETURN,
    FIRST_DISCOVERY,
    CALIBRATION,
    RETURNING_USER
}

const SAVE_PATH := "user://the_iris_voice.cfg"
const ONBOARDING_GAP := 1.8
const RETURNING_COOLDOWN := 180.0

@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var voice_profile := VoiceProfile.new()
var state_manager: IrisStateManager
var iris: IrisController
var current_state := GuideState.RETURNING_USER
var current_key := ""
var last_spoken_at := -10000.0
var interaction_active := false
var voice_enabled := true
var captions_enabled := false
var onboarding_session := false
var awakening_timer_started := false
var pending_lines: Array[Dictionary] = []
var spoken_lines: Dictionary = {}
var first_awakened := false
var first_touch := false
var first_witness := false
var first_return := false
var first_discovery := false
var calibration_guided := false

var clips := {
    "initializing": preload("res://audio/initializing.mp3"),
    "touch_center": preload("res://audio/touch_center.mp3"),
    "first_touch": preload("res://audio/first_touch.mp3"),
    "hold_attention": preload("res://audio/hold_attention.mp3"),
    "hidden_detail": preload("res://audio/hidden_detail.mp3"),
    "remember": preload("res://audio/remember.mp3"),
    "more_to_explore": preload("res://audio/more_to_explore.mp3")
}

func _ready() -> void:
    voice_profile = VoiceProfile.new()
    voice_player.volume_db = -9.0
    voice_player.finished.connect(_on_voice_finished)
    load_progress()

func set_state_manager(value: IrisStateManager) -> void:
    state_manager = value
    captions_enabled = value.captions_enabled

func set_captions_enabled(value: bool) -> void:
    captions_enabled = value
    if not captions_enabled:
        caption_changed.emit("", false)

func set_iris(value: IrisController) -> void:
    iris = value

func begin_session() -> void:
    onboarding_session = not first_awakened
    if onboarding_session:
        current_state = GuideState.FIRST_AWAKENING
        _schedule_first_awakening()
    else:
        current_state = GuideState.RETURNING_USER

func set_interaction_active(active: bool) -> void:
    interaction_active = active
    if not active and not pending_lines.is_empty():
        _flush_pending()

func set_enabled(enabled: bool) -> void:
    voice_enabled = enabled
    if not enabled:
        voice_player.stop()
        pending_lines.clear()

func _schedule_first_awakening() -> void:
    if awakening_timer_started or first_awakened:
        return
    awakening_timer_started = true
    get_tree().create_timer(2.8).timeout.connect(_on_awakening_timer)

func _on_awakening_timer() -> void:
    if first_awakened:
        return
    if is_instance_valid(iris):
        iris.start_awakening()
    _request_line("initializing", "Initializing.")

func on_first_touch() -> void:
    if first_touch:
        return
    first_touch = true
    first_awakened = true
    onboarding_session = true
    current_state = GuideState.FIRST_TOUCH
    spoken_lines["touch_center"] = true
    save_progress()
    # If the user found the pupil before the voice finished its invitation,
    # the confirmation waits for the current phrase to finish.
    _request_line("first_touch", "Good. You found the focus point.")

func on_witness_entered() -> void:
    if first_witness:
        return
    first_witness = true
    current_state = GuideState.FIRST_WITNESS
    save_progress()
    _request_line("hold_attention", "Hold your attention.")

func on_witness_completed() -> void:
    _request_line("hidden_detail", "You noticed something hidden.")

func on_return_from_witness() -> void:
    if not first_return:
        first_return = true
        current_state = GuideState.FIRST_RETURN
        save_progress()
    _request_line("remember", "I remember what you found.")
    if not first_discovery:
        get_tree().create_timer(3.0).timeout.connect(_on_discovery_reveal_timer)

func _on_discovery_reveal_timer() -> void:
    if first_discovery:
        return
    first_discovery = true
    current_state = GuideState.FIRST_DISCOVERY
    save_progress()
    _request_line("more_to_explore", "There is more to explore.")

func on_calibration_opened() -> void:
    if calibration_guided:
        return
    calibration_guided = true
    current_state = GuideState.CALIBRATION
    save_progress()
    _request_line("calibration", "Take your time.")

func _request_line(key: String, text: String) -> void:
    if spoken_lines.has(key):
        return
    if not voice_enabled and not captions_enabled:
        return
    if interaction_active or voice_player.playing:
        _enqueue_line(key, text, 0.35)
        return
    if not _cooldown_allows():
        _enqueue_line(key, text, _cooldown_remaining())
        return
    _speak(key, text)

func _enqueue_line(key: String, text: String, delay: float) -> void:
    for line in pending_lines:
        if str(line.get("key", "")) == key:
            return
    pending_lines.append({"key": key, "text": text, "delay": delay})

func _cooldown_gap() -> float:
    return ONBOARDING_GAP if onboarding_session and not first_discovery else RETURNING_COOLDOWN

func _cooldown_remaining() -> float:
    var now := Time.get_ticks_msec() / 1000.0
    return maxf(0.2, _cooldown_gap() - (now - last_spoken_at))

func _cooldown_allows() -> bool:
    return _cooldown_remaining() <= 0.2

func _speak(key: String, text: String) -> void:
    if not voice_enabled and not captions_enabled:
        return
    current_key = key
    last_spoken_at = Time.get_ticks_msec() / 1000.0
    spoken_lines[key] = true
    save_progress()
    voice_started.emit(key)
    if captions_enabled:
        caption_changed.emit(text, true)
    if voice_enabled and clips.has(key) and clips[key] is AudioStream:
        voice_player.stream = clips[key]
        voice_player.play()
    elif voice_enabled:
        _speak_with_tts(text)
        # TTS has no reliable finished signal across Android providers.
        get_tree().create_timer(maxf(1.4, text.length() * 0.055)).timeout.connect(_on_tts_finished)
    else:
        # Captions-only mode still gets a short visual reading window.
        get_tree().create_timer(maxf(1.4, text.length() * 0.055)).timeout.connect(_on_tts_finished)

func _speak_with_tts(text: String) -> void:
    if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
        DisplayServer.tts_speak(text, voice_profile.voice_name, voice_profile.volume, voice_profile.pitch, voice_profile.rate)

func _on_tts_finished() -> void:
    _finish_line()

func _on_voice_finished() -> void:
    var finished_key := current_key
    _finish_line()
    if finished_key == "initializing" and not first_touch:
        get_tree().create_timer(0.75).timeout.connect(_on_touch_prompt_timer)

func _on_touch_prompt_timer() -> void:
    if first_touch:
        return
    _request_line("touch_center", "Touch the center.")

func _finish_line() -> void:
    if current_key == "":
        return
    var finished_key := current_key
    current_key = ""
    if captions_enabled:
        caption_changed.emit("", false)
    voice_finished.emit(finished_key)
    _flush_pending()

func _flush_pending() -> void:
    if pending_lines.is_empty() or interaction_active or voice_player.playing:
        return
    var line: Dictionary = pending_lines.pop_front()
    var next_key := str(line.get("key", ""))
    var next_text := str(line.get("text", ""))
    var delay := float(line.get("delay", 0.0))
    if delay > 0.0:
        get_tree().create_timer(delay).timeout.connect(func(): _request_line(next_key, next_text))
    else:
        _request_line(next_key, next_text)

func save_progress() -> void:
    var config := ConfigFile.new()
    config.set_value("guide", "first_awakened", first_awakened)
    config.set_value("guide", "first_touch", first_touch)
    config.set_value("guide", "first_witness", first_witness)
    config.set_value("guide", "first_return", first_return)
    config.set_value("guide", "first_discovery", first_discovery)
    config.set_value("guide", "calibration_guided", calibration_guided)
    config.set_value("guide", "spoken_lines", spoken_lines)
    config.save(SAVE_PATH)

func load_progress() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    first_awakened = bool(config.get_value("guide", "first_awakened", false))
    first_touch = bool(config.get_value("guide", "first_touch", false))
    first_witness = bool(config.get_value("guide", "first_witness", false))
    first_return = bool(config.get_value("guide", "first_return", false))
    first_discovery = bool(config.get_value("guide", "first_discovery", false))
    calibration_guided = bool(config.get_value("guide", "calibration_guided", false))
    spoken_lines = config.get_value("guide", "spoken_lines", {})

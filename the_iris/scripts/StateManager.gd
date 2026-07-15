extends Node
class_name IrisStateManager

signal state_changed(new_state: int)
signal progress_changed
signal preferences_changed

enum LivingState { IDLE, CURIOUS, FOCUS, MEMORY }
const IDLE: int = LivingState.IDLE
const CURIOUS: int = LivingState.CURIOUS
const FOCUS: int = LivingState.FOCUS
const MEMORY: int = LivingState.MEMORY

var current_state: int = LivingState.IDLE
var completed_observations: int = 0
var attention_score: int = 0
var discovery_count: int = 0
var sound_enabled: bool = true
var animation_intensity: float = 1.0
var high_contrast: bool = false
var reduced_motion: bool = false
var accessible_navigation: bool = false
var captions_enabled: bool = false
var orientation_lock: bool = false
var parallax_enabled: bool = true
var first_launch: bool = true
var onboarding_tutorial_completed: bool = false

const SAVE_PATH := "user://the_iris_state.cfg"

func _ready() -> void:
    load_state()

func set_living_state(next_state: int) -> void:
    if current_state == next_state:
        return
    current_state = next_state
    state_changed.emit(current_state)

func complete_observation() -> void:
    completed_observations += 1
    attention_score = mini(100, attention_score + 12)
    discovery_count += 1
    progress_changed.emit()
    save_state()

func complete_onboarding_tutorial() -> void:
    onboarding_tutorial_completed = true
    first_launch = false
    save_state()
    progress_changed.emit()

func mark_first_launch_seen() -> void:
    if first_launch:
        first_launch = false
        save_state()

func update_preferences() -> void:
    save_state()
    preferences_changed.emit()

func reset_progress() -> void:
    completed_observations = 0
    attention_score = 0
    discovery_count = 0
    onboarding_tutorial_completed = false
    progress_changed.emit()
    save_state()

func save_state() -> void:
    var config := ConfigFile.new()
    config.set_value("progress", "completed_observations", completed_observations)
    config.set_value("progress", "attention_score", attention_score)
    config.set_value("progress", "discovery_count", discovery_count)
    config.set_value("progress", "onboarding_tutorial_completed", onboarding_tutorial_completed)
    config.set_value("preferences", "sound_enabled", sound_enabled)
    config.set_value("preferences", "animation_intensity", animation_intensity)
    config.set_value("preferences", "high_contrast", high_contrast)
    config.set_value("preferences", "reduced_motion", reduced_motion)
    config.set_value("preferences", "accessible_navigation", accessible_navigation)
    config.set_value("preferences", "captions_enabled", captions_enabled)
    config.set_value("preferences", "orientation_lock", orientation_lock)
    config.set_value("preferences", "parallax_enabled", parallax_enabled)
    config.set_value("preferences", "first_launch", first_launch)
    config.save(SAVE_PATH)

func load_state() -> void:
    var config := ConfigFile.new()
    if config.load(SAVE_PATH) != OK:
        return
    completed_observations = int(config.get_value("progress", "completed_observations", 0))
    attention_score = int(config.get_value("progress", "attention_score", 0))
    discovery_count = int(config.get_value("progress", "discovery_count", 0))
    onboarding_tutorial_completed = bool(config.get_value("progress", "onboarding_tutorial_completed", false))
    sound_enabled = bool(config.get_value("preferences", "sound_enabled", true))
    animation_intensity = float(config.get_value("preferences", "animation_intensity", 1.0))
    high_contrast = bool(config.get_value("preferences", "high_contrast", false))
    reduced_motion = bool(config.get_value("preferences", "reduced_motion", false))
    accessible_navigation = bool(config.get_value("preferences", "accessible_navigation", false))
    captions_enabled = bool(config.get_value("preferences", "captions_enabled", false))
    orientation_lock = bool(config.get_value("preferences", "orientation_lock", false))
    parallax_enabled = bool(config.get_value("preferences", "parallax_enabled", true))
    first_launch = bool(config.get_value("preferences", "first_launch", true))

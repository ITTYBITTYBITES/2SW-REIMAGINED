extends WitnessMomentPhase
class_name WitnessObservationScreen

## Witness Observation Phase - The 2-second cinematic moment
## No HUD, no countdown, no player input. Pure observation.

signal observation_complete

@onready var viewport: SubViewport = $MomentViewport
@onready var moment_scene: Sprite2D = $MomentViewport/MomentContainer/MomentScene
@onready var shader_overlay: ColorRect = $MomentViewport/MomentContainer/ShaderOverlay
@onready var viewport_rect: TextureRect = $ViewportTextureRect
@onready var attunement_prompt: Label = $AttunementPrompt
@onready var iris_voice_container: Control = $IrisVoiceContainer

var _moment_data: Dictionary = {}
var _duration: float = 2.0
var _elapsed: float = 0.0
var _shader_material: ShaderMaterial
var _phase_state: int = 0  # 0=intro, 1=observing, 2=transition
var _intro_duration: float = 1.5
var _transition_duration: float = 0.15
var _dust_mote_base_phase: float = 0.0

func _ready() -> void:
    super._ready()
    phase_name = "observing"
    
    # Connect viewport texture
    viewport_rect.texture = viewport.get_texture()
    
    # Get shader material
    _shader_material = shader_overlay.material as ShaderMaterial
    if _shader_material:
        _shader_material.set_shader_parameter("time", 0.0)
        _shader_material.set_shader_parameter("progress", 0.0)
        _shader_material.set_shader_parameter("dust_mote_phase", 0.0)
        _shader_material.set_shader_parameter("steam_intensity", 1.0)
        _shader_material.set_shader_parameter("viewport_size", get_viewport_rect().size)
    
    # Setup attunement prompt style
    if ThemeService:
        ThemeService.apply_label_style(attunement_prompt, "label_small", "primary_variant")
    attunement_prompt.add_theme_font_size_override("font_size", 14)
    attunement_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    attunement_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    
    # Hide initially
    attunement_prompt.visible = false
    attunement_prompt.modulate.a = 0.0
    
    set_process(true)
    set_physics_process(false)

func _on_configure() -> void:
    if moment_definition:
        _moment_data = moment_definition.to_blueprint()
        var env = _moment_data.get("environment", {})
        _duration = float(env.get("observation", {})).get("duration_seconds", 2.0) if env.get("observation", {}) else 2.0
        
        # Load moment-specific background if available
        var bg_path = env.get("background_image", "")
        if bg_path and ResourceLoader.exists(bg_path):
            moment_scene.texture = load(bg_path) as Texture2D

func _on_begin() -> void:
    _phase_state = 0
    _elapsed = 0.0
    _dust_mote_base_phase = randf_range(0.0, TAU)
    
    # Iris introduction voice
    if moment_definition and moment_definition.narrative_introduction != "":
        _speak(moment_definition.narrative_introduction)
    
    # Attunement prompt appears after intro
    var intro_text = "Stay with it. Do not name what you see. Only notice."
    _show_attunement_prompt(intro_text, _intro_duration * 0.6)

func _process(delta: float) -> void:
    _elapsed += delta
    
    if _shader_material:
        _shader_material.set_shader_parameter("time", _elapsed)
        _shader_material.set_shader_parameter("dust_mote_phase", _dust_mote_base_phase + _elapsed * 0.5)
    
    match _phase_state:
        0: # Intro/Attunement
            if _elapsed >= _intro_duration:
                _begin_observation()
        1: # Observing - the 2 second moment
            var progress = clampf(_elapsed - _intro_duration, 0.0, _duration) / _duration
            if _shader_material:
                _shader_material.set_shader_parameter("progress", progress)
            
            # Steam stops during hover (approx 0.3 to 0.9 of moment)
            var moment_progress = progress
            if moment_progress > 0.3 and moment_progress < 0.9:
                if _shader_material:
                    _shader_material.set_shader_parameter("steam_intensity", lerpf(1.0, 0.0, (moment_progress - 0.3) / 0.3))
            elif moment_progress >= 0.9:
                if _shader_material:
                    _shader_material.set_shader_parameter("steam_intensity", lerpf(0.0, 1.0, (moment_progress - 0.9) / 0.1))
            
            if _elapsed >= _intro_duration + _duration:
                _begin_transition()
        2: # Transition to black
            var trans_progress = (_elapsed - _intro_duration - _duration) / _transition_duration
            modulate.a = 1.0 - clampf(trans_progress, 0.0, 1.0)
            if trans_progress >= 1.0:
                _complete_observation()

func _begin_observation() -> void:
    _phase_state = 1
    _elapsed = _intro_duration  # Reset for observation timing
    _hide_attunement_prompt()
    _vibrate(30)
    _play_sfx("observation_start", 0.5)

func _begin_transition() -> void:
    _phase_state = 2
    _play_sfx("conceal", 0.4)
    if AudioService:
        AudioService.duck_bgm(-6.0, 0.15)

func _complete_observation() -> void:
    set_process(false)
    observation_complete.emit()
    complete({"observation_duration": _duration, "moment_id": moment_definition.moment_id if moment_definition else ""})

func _show_attunement_prompt(text: String, hold_duration: float) -> void:
    attunement_prompt.text = text
    attunement_prompt.visible = true
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(attunement_prompt, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
        tween.tween_callback(_hide_attunement_prompt).set_delay(hold_duration)
    else:
        attunement_prompt.modulate.a = 1.0
        get_tree().create_timer(hold_duration).timeout.connect(_hide_attunement_prompt)

func _hide_attunement_prompt() -> void:
    if not is_instance_valid(attunement_prompt):
        return
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(attunement_prompt, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
        tween.finished.connect(func(): attunement_prompt.visible = false)
    else:
        attunement_prompt.visible = false
        attunement_prompt.modulate.a = 0.0

func _on_viewport_resized(size: Vector2) -> void:
    if _shader_material:
        _shader_material.set_shader_parameter("viewport_size", size)
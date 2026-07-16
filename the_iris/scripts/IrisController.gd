extends Control
class_name IrisController

# Exposed adjustable parameters for Two Second Witness 4.0 Living Iris
@export var pupil_dilation: float = 0.105:
    set(val):
        pupil_dilation = val
        _apply_shader_params()

@export var fiber_speed: float = 1.0:
    set(val):
        fiber_speed = val
        _apply_shader_params()

@export var glow_strength: float = 0.5:
    set(val):
        glow_strength = val
        _apply_shader_params()

@export var memory_visibility: float = 0.0:
    set(val):
        memory_visibility = val
        _update_portal_shader()

@export var focus_target: Vector2 = Vector2(0.5, 0.495):
    set(val):
        focus_target = val
        gaze_target = val

@export var progression_level: int = 0:
    set(val):
        progression_level = val
        _apply_shader_params()
        _update_memory_fragments()

@onready var visual: ColorRect = $Visual
@onready var particles: CPUParticles2D = $Particles
@onready var outer_energy_layer: TextureRect = $OuterEnergyLayer
@onready var pupil_portal_layer: Control = $PupilPortalLayer
@onready var portal_container: Control = $PupilPortalLayer/PortalContainer
@onready var destination_preview: TextureRect = $PupilPortalLayer/PortalContainer/DestinationPreview
@onready var destination_title: Label = $PupilPortalLayer/DestinationTitle
@onready var destination_prompt: Label = $PupilPortalLayer/DestinationPrompt
@onready var cornea_layer: TextureRect = $CorneaLayer
@onready var memory_fragments_container: Node2D = $MemoryFragmentsContainer

const PREVIEW_STORY := preload("res://assets/iris/reflections/story_mode.png")
const PREVIEW_ARCHIVE := preload("res://assets/iris/reflections/archive.png")
const PREVIEW_PROFILE := preload("res://assets/iris/reflections/profile.png")
const PREVIEW_DAILY := preload("res://assets/iris/reflections/daily_witness.png")
const PREVIEW_CALIBRATION := preload("res://assets/iris/reflections/calibration.png")

var elapsed := 0.0
var target_energy := 0.0
var current_energy := 0.0
var state_mode := 0.0
var pulse := 0.0
var intensity := 1.0
var desktop_mode := false
var orientation_motion := 0.0
var orientation_motion_target := 0.0
var parallax_enabled := true
var sensor_offset_target := Vector2.ZERO
var sensor_offset := Vector2.ZERO
var transition_open := 0.0
var awakening_level := 0.0
var awakening_timer := 0.0

# Living-eye biological saccadic responses
var neutral_gaze := Vector2(0.5, 0.495)
var gaze_target := neutral_gaze
var gaze_current := neutral_gaze
var gaze_release_at := 0.0
var interaction_active := false
var anticipation_target := Vector2.ZERO
var anticipation_current := Vector2.ZERO
var micro_target := Vector2.ZERO
var micro_current := Vector2.ZERO
var next_saccade_at := 3.2
var saccade_in_progress := false
var blink_amount := 0.0
var blink_target := 0.0
var blink_active := false
var blink_elapsed := 0.0
var next_blink_at := 11.0
var recent_alert_timer := 0.0
var recent_alert := 0.0

# Quiet invitation before first touch
var invitation_amount := 0.0
var invitation_target := 0.0
var invitation_elapsed := -1.0
var next_invitation_at := 1.8

# Hold becomes a distinct deep-focus/calibration moment
var deep_focus_level := 0.0
var deep_focus_timer := 0.0

# Destination perception state
var active_destination_key := "story_mode"
var memory_visibility_current := 0.0
var memory_visibility_target := 0.0
var title_alpha_current := 0.0

# After a successful Witness return, the Iris teaches its four destinations
var learning_active := false
var learning_elapsed := 0.0
var learning_focus := Vector2.ZERO
var learning_focus_target := Vector2.ZERO
var learning_amount := 0.0
var learning_amount_target := 0.0

var random := RandomNumberGenerator.new()

var sound_service: ProceduralIrisSound = null
var voice_guide_ref: VoiceGuide = null

func set_sensory_services(s: ProceduralIrisSound, v: VoiceGuide) -> void:
    sound_service = s
    voice_guide_ref = v

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    random.randomize()
    next_saccade_at = random.randf_range(2.2, 4.3)
    next_blink_at = random.randf_range(9.0, 15.0)
    next_invitation_at = random.randf_range(1.4, 2.8)
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("aspect", get_viewport_rect().size.x / max(get_viewport_rect().size.y, 1.0))
        shader_material.set_shader_parameter("has_textures", 1.0)
    particles.emitting = true
    _sync_progression()

func _sync_progression() -> void:
    if get_tree() and get_tree().root.has_node("StateManager"):
        var sm = get_tree().root.get_node("StateManager")
        var obs: int = sm.get("completed_observations")
        var tutorial_done := bool(sm.get("onboarding_tutorial_completed"))
        if not tutorial_done and obs == 0:
            progression_level = 0
        else:
            progression_level = clampi(obs, 1, 5)
        glow_strength = clampf(0.40 + float(progression_level) * 0.12, 0.40, 1.0)
    _apply_shader_params()
    _update_memory_fragments()

func _process(delta: float) -> void:
    elapsed += delta * intensity
    _update_gaze(delta)
    _update_micro_saccades(delta)
    _update_blink(delta)
    _update_recent_alert(delta)
    _update_invitation(delta)
    _update_deep_focus(delta)
    _update_learning(delta)
    _update_awakening(delta)
    _update_destination_lens(delta)
    _update_visual_layers(delta)
    
    orientation_motion = lerpf(orientation_motion, orientation_motion_target, minf(1.0, delta * 5.0))
    sensor_offset = sensor_offset.lerp(sensor_offset_target if parallax_enabled else Vector2.ZERO, minf(1.0, delta * 2.8))
    current_energy = lerpf(current_energy, maxf(target_energy * (1.0 - deep_focus_level * 0.50), recent_alert * 0.42), minf(1.0, delta * 3.0))
    pulse = maxf(0.0, pulse - delta * 0.55)
    
    var viewport_size := get_viewport_rect().size
    particles.position = viewport_size * 0.5
    _apply_shader_params()
    particles.amount = 18 if intensity > 0.25 else 8
    particles.speed_scale = 0.5 + intensity * 0.5 * fiber_speed

func _apply_shader_params() -> void:
    if not is_instance_valid(visual):
        return
    var shader_material := visual.material as ShaderMaterial
    if not shader_material:
        return
    var viewport_size := get_viewport_rect().size
    var effective_pupil := pupil_dilation if pupil_dilation != 0.105 else (0.105 if state_mode != 2.0 else 0.078)
    shader_material.set_shader_parameter("aspect", viewport_size.x / max(viewport_size.y, 1.0))
    shader_material.set_shader_parameter("time", elapsed)
    shader_material.set_shader_parameter("energy", current_energy + pulse)
    shader_material.set_shader_parameter("state_mode", state_mode)
    shader_material.set_shader_parameter("pupil_open", effective_pupil)
    shader_material.set_shader_parameter("transition_open", transition_open)
    shader_material.set_shader_parameter("recent_alert", recent_alert)
    shader_material.set_shader_parameter("blink_amount", blink_amount)
    shader_material.set_shader_parameter("gaze_target", gaze_current)
    shader_material.set_shader_parameter("micro_offset", micro_current)
    shader_material.set_shader_parameter("anticipation", anticipation_current)
    shader_material.set_shader_parameter("invitation", invitation_amount)
    shader_material.set_shader_parameter("deep_focus", deep_focus_level)
    shader_material.set_shader_parameter("learning_focus", learning_focus)
    shader_material.set_shader_parameter("learning_amount", learning_amount)
    shader_material.set_shader_parameter("awakening", awakening_level)
    shader_material.set_shader_parameter("breath_rate", lerpf(1.15, 0.58, awakening_level))
    shader_material.set_shader_parameter("orientation_motion", orientation_motion)
    shader_material.set_shader_parameter("sensor_offset", sensor_offset)
    shader_material.set_shader_parameter("progression_level", float(progression_level))
    shader_material.set_shader_parameter("fiber_speed", fiber_speed)
    shader_material.set_shader_parameter("glow_strength", glow_strength)

func _update_gaze(delta: float) -> void:
    if not interaction_active and elapsed >= gaze_release_at:
        gaze_target = neutral_gaze
    
    # Saccadic biological ballistic eye movement
    var dist := gaze_current.distance_to(gaze_target)
    if dist > 0.04 and not saccade_in_progress:
        saccade_in_progress = true
    if saccade_in_progress:
        gaze_current = gaze_current.lerp(gaze_target, minf(1.0, delta * 14.0 * intensity))
        if dist < 0.012:
            saccade_in_progress = false
    else:
        gaze_current = gaze_current.lerp(gaze_target, minf(1.0, delta * 4.2 * intensity))
    
    anticipation_current = anticipation_current.lerp(anticipation_target, minf(1.0, delta * 5.0 * intensity))

func _update_micro_saccades(delta: float) -> void:
    if interaction_active:
        micro_target = Vector2.ZERO
    elif elapsed >= next_saccade_at:
        micro_target = Vector2(random.randf_range(-0.012, 0.012), random.randf_range(-0.009, 0.009))
        next_saccade_at = elapsed + random.randf_range(2.6, 5.2)
    micro_current = micro_current.lerp(micro_target, minf(1.0, delta * 5.0 * intensity))
    if not interaction_active and micro_current.length() < 0.0015:
        micro_target = Vector2.ZERO

func _update_destination_lens(delta: float) -> void:
    var next_key := "story_mode"
    var dist_to_center := gaze_current.distance_to(neutral_gaze)
    if dist_to_center < 0.14:
        next_key = "story_mode"
        memory_visibility_target = 0.92 if interaction_active else (0.85 if state_mode == 0.0 else 0.80)
    elif gaze_current.x < 0.38:
        next_key = "archive"
        memory_visibility_target = 0.95
    elif gaze_current.x > 0.62:
        next_key = "daily_witness"
        memory_visibility_target = 0.95
    elif gaze_current.y < 0.38:
        next_key = "profile"
        memory_visibility_target = 0.95
    elif gaze_current.y > 0.62:
        next_key = "calibration"
        memory_visibility_target = 0.95
    else:
        memory_visibility_target = 0.65

    if transition_open > 0.05:
        memory_visibility_target = 1.0
        next_key = active_destination_key

    if next_key != active_destination_key:
        active_destination_key = next_key
        _apply_destination_preview(active_destination_key)
        if is_instance_valid(sound_service):
            sound_service.emit_destination_recognition(active_destination_key)
        if is_instance_valid(voice_guide_ref) and active_destination_key != "story_mode":
            voice_guide_ref.trigger_iris_expression("FOCUS", active_destination_key)

    memory_visibility_current = lerpf(memory_visibility_current, maxf(memory_visibility_target, memory_visibility), minf(1.0, delta * 4.5 * intensity))
    var title_target := 1.0 if (dist_to_center > 0.14 and interaction_active) or (interaction_active and active_destination_key == "story_mode") else 0.0
    title_alpha_current = lerpf(title_alpha_current, title_target, minf(1.0, delta * 5.0 * intensity))
    
    if is_instance_valid(destination_title) and is_instance_valid(destination_prompt):
        destination_title.modulate.a = title_alpha_current
        destination_prompt.modulate.a = title_alpha_current * 0.85
    _update_portal_shader()

func _apply_destination_preview(key: String) -> void:
    if not is_instance_valid(destination_preview):
        return
    var sm = get_tree().root.get_node_or_null("StateManager") if get_tree() and get_tree().root.has_node("StateManager") else null
    var tutorial_done := bool(sm.get("onboarding_tutorial_completed")) if sm else (progression_level > 0)
    var obs := int(sm.get("completed_observations")) if sm else clampi(progression_level, 0, 5)
    match key:
        "story_mode":
            if not tutorial_done and obs == 0:
                destination_preview.texture = PREVIEW_STORY
                if is_instance_valid(destination_title): destination_title.text = "THE AWAKENING"
                if is_instance_valid(destination_prompt): destination_prompt.text = "TOUCH TO ENTER FIRST OBSERVATION"
            elif obs == 0 or obs == 1:
                destination_preview.texture = SHARD_TEXTURES[0]
                if is_instance_valid(destination_title): destination_title.text = "CHAPTER 1 : THE UNFINISHED CANVAS"
                if is_instance_valid(destination_prompt): destination_prompt.text = "TOUCH TO ENTER WITNESS MOMENT 001"
            elif obs == 2:
                destination_preview.texture = SHARD_TEXTURES[1]
                if is_instance_valid(destination_title): destination_title.text = "CHAPTER 1 : THE FORGOTTEN MUSEUM"
                if is_instance_valid(destination_prompt): destination_prompt.text = "TOUCH TO ENTER WITNESS MOMENT 002"
            elif obs == 3:
                destination_preview.texture = SHARD_TEXTURES[2]
                if is_instance_valid(destination_title): destination_title.text = "CHAPTER 1 : THE LAST PERFORMANCE"
                if is_instance_valid(destination_prompt): destination_prompt.text = "TOUCH TO ENTER WITNESS MOMENT 003"
            elif obs == 4:
                destination_preview.texture = SHARD_TEXTURES[3]
                if is_instance_valid(destination_title): destination_title.text = "CHAPTER 1 : THE FAULTY REACTOR"
                if is_instance_valid(destination_prompt): destination_prompt.text = "TOUCH TO ENTER WITNESS MOMENT 004"
            else:
                destination_preview.texture = SHARD_TEXTURES[4]
                if is_instance_valid(destination_title): destination_title.text = "RANK 2 : THE WITNESS UNLOCKED"
                if is_instance_valid(destination_prompt): destination_prompt.text = "PRESERVED MOMENTS & DAILY ATTUNEMENT"
        "archive":
            destination_preview.texture = PREVIEW_ARCHIVE
            if is_instance_valid(destination_title): destination_title.text = "MEMORY ARCHIVE"
            if is_instance_valid(destination_prompt): destination_prompt.text = "PAST WITNESSED MOMENTS"
        "profile":
            destination_preview.texture = PREVIEW_PROFILE
            if is_instance_valid(destination_title): destination_title.text = "YOUR IRIS & PROFILE"
            if is_instance_valid(destination_prompt): destination_prompt.text = "EVOLUTION & RANK"
        "daily_witness":
            destination_preview.texture = PREVIEW_DAILY
            if is_instance_valid(destination_title): destination_title.text = "DAILY WITNESS"
            if is_instance_valid(destination_prompt): destination_prompt.text = "TODAY'S UNKNOWN MOMENT"
        "calibration":
            destination_preview.texture = PREVIEW_CALIBRATION
            if is_instance_valid(destination_title): destination_title.text = "INSTRUMENT CALIBRATION"
            if is_instance_valid(destination_prompt): destination_prompt.text = "DIAGNOSTICS & SETTINGS"

func _update_portal_shader() -> void:
    if not is_instance_valid(destination_preview):
        return
    var mat := destination_preview.material as ShaderMaterial
    if not mat:
        return
    var effective_pupil := pupil_dilation if pupil_dilation != 0.105 else (0.105 if state_mode != 2.0 else 0.078)
    mat.set_shader_parameter("time", elapsed)
    mat.set_shader_parameter("aperture", effective_pupil + recent_alert * 0.02 + pulse * 0.03 + (state_mode == 1.0 ? 0.014 : 0.0))
    mat.set_shader_parameter("memory_visibility", memory_visibility_current)
    mat.set_shader_parameter("gaze_offset", (gaze_current - neutral_gaze) * Vector2(1.5, 1.5))
    mat.set_shader_parameter("aspect", 1.0)

func _update_visual_layers(delta: float) -> void:
    if is_instance_valid(outer_energy_layer):
        outer_energy_layer.rotation = sin(elapsed * 0.18 * fiber_speed) * 0.08 + orientation_motion * 0.15
        var glow_scale := 1.0 + sin(elapsed * 0.6 * fiber_speed) * 0.03 + pulse * 0.12 + (float(progression_level) * 0.05)
        outer_energy_layer.scale = Vector2(glow_scale, glow_scale)
        outer_energy_layer.modulate.a = clampf(0.35 + glow_strength * 0.25 + recent_alert * 0.2, 0.2, 0.85)
    
    if is_instance_valid(cornea_layer):
        var parallax_pos := Vector2(110, 384) + sensor_offset * -320.0 + (gaze_current - neutral_gaze) * -85.0
        cornea_layer.position = cornea_layer.position.lerp(parallax_pos, minf(1.0, delta * 5.0 * intensity))
        cornea_layer.modulate.a = clampf(0.32 + glow_strength * 0.15 + awakening_level * 0.15, 0.2, 0.65)
    
    if is_instance_valid(portal_container):
        var aspect_ratio := get_viewport_rect().size.x / max(get_viewport_rect().size.y, 1.0)
        var gaze_delta := gaze_current - neutral_gaze
        gaze_delta.x *= aspect_ratio
        var optical_focus := gaze_delta + learning_focus * learning_amount * 0.045
        var delta_q := optical_focus * 0.024 + micro_current + anticipation_current * 0.022 + sensor_offset
        var pupil_screen_pos := Vector2(360, 634) + delta_q * -1280.0
        portal_container.position = portal_container.position.lerp(pupil_screen_pos, minf(1.0, delta * 12.0 * intensity))
        
        var scale_val: float = 1.0 + pow(transition_open, 1.5) * 2.8 + pulse * 0.08
        portal_container.scale = portal_container.scale.lerp(Vector2(scale_val, scale_val), minf(1.0, delta * 8.0 * intensity))
    
    if is_instance_valid(memory_fragments_container) and memory_fragments_container.get_child_count() > 0:
        for i: int in range(memory_fragments_container.get_child_count()):
            var frag: Node = memory_fragments_container.get_child(i)
            if frag is Node2D:
                var ang: float = elapsed * 0.3 * fiber_speed + float(i) * (TAU / max(float(memory_fragments_container.get_child_count()), 1.0))
                var radius: float = 162.0 + sin(elapsed * 0.5 + float(i)) * 12.0 + (pulse * 25.0)
                frag.position = Vector2(cos(ang), sin(ang)) * radius
                frag.rotation = ang + PI * 0.5

const SHARD_TEXTURES := [
    preload("res://assets/gameplay/wm_001_studio_background.png"),
    preload("res://assets/gameplay/wm_002_museum_corridor.png"),
    preload("res://assets/gameplay/wm_003_dressing_room.png"),
    preload("res://assets/gameplay/wm_004_cleanroom_console.png"),
    preload("res://assets/gameplay/wm_005_internal_stroma.png")
]

func _update_memory_fragments() -> void:
    if not is_instance_valid(memory_fragments_container):
        return
    var target_count: int = clampi(progression_level, 0, 5)
    var current_count: int = memory_fragments_container.get_child_count()
    if current_count == target_count:
        return
    while memory_fragments_container.get_child_count() > target_count:
        var child: Node = memory_fragments_container.get_child(memory_fragments_container.get_child_count() - 1)
        child.queue_free()
        memory_fragments_container.remove_child(child)
    while memory_fragments_container.get_child_count() < target_count:
        var idx: int = memory_fragments_container.get_child_count()
        var frag: Node2D = Node2D.new()
        frag.name = "MemoryFragment_%d" % idx
        var sprite: Sprite2D = Sprite2D.new()
        var tex_idx: int = idx % SHARD_TEXTURES.size()
        sprite.texture = SHARD_TEXTURES[tex_idx]
        sprite.scale = Vector2(0.08, 0.08)
        sprite.modulate = Color(0.88, 0.96, 0.92, 0.72)
        frag.add_child(sprite)
        memory_fragments_container.add_child(frag)

func _update_blink(delta: float) -> void:
    if interaction_active or deep_focus_timer > 0.0:
        blink_active = false
        blink_elapsed = 0.0
        blink_target = 0.0
    else:
        if not blink_active and elapsed >= next_blink_at:
            blink_active = true
            blink_elapsed = 0.0
        if blink_active:
            blink_elapsed += delta
            if blink_elapsed < 0.12:
                blink_target = 0.72 * (blink_elapsed / 0.12)
            elif blink_elapsed < 0.22:
                blink_target = 0.72
            elif blink_elapsed < 0.46:
                blink_target = 0.72 * (1.0 - (blink_elapsed - 0.22) / 0.24)
            else:
                blink_active = false
                blink_target = 0.0
                next_blink_at = elapsed + random.randf_range(10.0, 18.0)
    blink_amount = lerpf(blink_amount, blink_target, minf(1.0, delta * 18.0 * intensity))

func _update_recent_alert(delta: float) -> void:
    if recent_alert_timer > 0.0:
        recent_alert_timer -= delta
    var alert_target := clampf(recent_alert_timer / 4.5, 0.0, 1.0)
    recent_alert = lerpf(recent_alert, alert_target, minf(1.0, delta * 2.4 * intensity))
    if recent_alert_timer <= 0.0:
        var resting_energy := 0.35 if state_mode == 1.0 else (0.18 if state_mode == 3.0 else 0.05)
        target_energy = lerpf(target_energy, resting_energy, minf(1.0, delta * 0.9 * intensity))

func _update_invitation(delta: float) -> void:
    if interaction_active or deep_focus_timer > 0.0 or learning_active:
        invitation_target = 0.0
    else:
        if invitation_elapsed < 0.0 and elapsed >= next_invitation_at:
            invitation_elapsed = 0.0
        if invitation_elapsed >= 0.0:
            invitation_elapsed += delta
            if invitation_elapsed < 1.25:
                invitation_target = sin((invitation_elapsed / 1.25) * PI) * 0.72
            else:
                invitation_target = 0.0
                invitation_elapsed = -1.0
                next_invitation_at = elapsed + random.randf_range(3.5, 6.5)
    invitation_amount = lerpf(invitation_amount, invitation_target, minf(1.0, delta * 4.0 * intensity))

func _update_deep_focus(delta: float) -> void:
    if deep_focus_timer > 0.0:
        deep_focus_timer -= delta
    var focus_target := 1.0 if deep_focus_timer > 0.0 else 0.0
    deep_focus_level = lerpf(deep_focus_level, focus_target, minf(1.0, delta * 3.4 * intensity))

func _update_learning(delta: float) -> void:
    if learning_active:
        learning_elapsed += delta
        if learning_elapsed >= 3.4:
            learning_active = false
            learning_amount_target = 0.0
            learning_focus_target = Vector2.ZERO
        else:
            var segment := mini(3, int(learning_elapsed / 0.85))
            var directions := [Vector2(-1.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(0.0, -1.0)]
            learning_focus_target = directions[segment]
            var segment_time := fmod(learning_elapsed, 0.85) / 0.85
            learning_amount_target = sin(segment_time * PI) * 0.95
    learning_focus = learning_focus.lerp(learning_focus_target, minf(1.0, delta * 7.0 * intensity))
    learning_amount = lerpf(learning_amount, learning_amount_target, minf(1.0, delta * 7.0 * intensity))

func _update_awakening(delta: float) -> void:
    if awakening_timer > 0.0:
        awakening_timer -= delta
    var target := 1.0 if awakening_timer > 0.0 else 0.0
    awakening_level = lerpf(awakening_level, target, minf(1.0, delta * 2.8 * intensity))

func start_awakening() -> void:
    awakening_timer = 3.2
    invitation_target = 0.0
    pulse = 0.35
    if is_instance_valid(sound_service):
        sound_service.awakening_tone()

func set_living_state(state: int) -> void:
    state_mode = float(state)
    target_energy = 0.35 if state == 1 else (0.18 if state == 3 else 0.05)
    if state == 2:
        target_energy = 0.62
        pulse = 0.85
    particles.color = Color("#bfede0") if state != 3 else Color("#d4b77b")

func set_gaze_target(screen_position: Vector2, viewport_size: Vector2) -> void:
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    gaze_target = Vector2(
        clampf(screen_position.x / viewport_size.x, 0.15, 0.85),
        clampf(screen_position.y / viewport_size.y, 0.15, 0.85)
    )
    gaze_release_at = elapsed + 2.6
    focus_target = gaze_target

func set_interaction(active: bool) -> void:
    interaction_active = active
    if active:
        blink_active = false
        blink_target = 0.0
        learning_active = false
        learning_amount_target = 0.0
    else:
        gaze_release_at = elapsed + 2.6
        anticipation_target = Vector2.ZERO

func update_directional_anticipation(delta: Vector2, viewport_size: Vector2) -> void:
    if not interaction_active:
        return
    var normalized := Vector2(delta.x / maxf(viewport_size.x, 1.0), delta.y / maxf(viewport_size.y, 1.0))
    if normalized.length() < 0.012:
        anticipation_target = Vector2.ZERO
        return
    if absf(normalized.x) > absf(normalized.y):
        anticipation_target = Vector2(sign(normalized.x), 0.0)
    else:
        anticipation_target = Vector2(0.0, sign(normalized.y))

func start_deep_focus() -> void:
    deep_focus_timer = 1.75
    invitation_target = 0.0
    pulse = 0.08
    if is_instance_valid(sound_service):
        sound_service.focus_notice_tone()
    if Input.has_method("vibrate_handheld"):
        Input.vibrate_handheld(12, 0.08)

func remember_recent_activity() -> void:
    recent_alert_timer = 5.5
    recent_alert = maxf(recent_alert, 0.65)
    target_energy = maxf(target_energy, 0.42)
    learning_active = true
    learning_elapsed = 0.0
    learning_focus_target = Vector2.ZERO
    learning_amount_target = 0.0
    _sync_progression()

func set_transition_open(value: float) -> void:
    transition_open = clampf(value, 0.0, 1.0)
    _apply_shader_params()
    _update_portal_shader()

func focus_pulse() -> void:
    pulse = 1.0
    target_energy = 0.72

func set_desktop_mode(value: bool) -> void:
    desktop_mode = value

func set_orientation_motion(progress: float) -> void:
    orientation_motion_target = clampf(progress, 0.0, 1.0)

func set_parallax_enabled(value: bool) -> void:
    parallax_enabled = value
    if not value:
        sensor_offset_target = Vector2.ZERO

func set_sensor_offset(acceleration: Vector3) -> void:
    if not parallax_enabled:
        sensor_offset_target = Vector2.ZERO
        return
    sensor_offset_target = Vector2(
        clampf(-acceleration.x / 90.0, -0.012, 0.012),
        clampf(acceleration.y / 120.0, -0.010, 0.010)
    )

func set_animation_intensity(value: float) -> void:
    intensity = clampf(value, 0.0, 1.0)

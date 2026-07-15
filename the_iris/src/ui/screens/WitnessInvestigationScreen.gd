extends WitnessMomentPhase
class_name WitnessInvestigationScreen

## Witness Investigation Phase - Frozen moment with attunement perspectives
## Tap objects to attune. Each reveals a different layer of truth.

signal investigation_complete

@onready var viewport: SubViewport = $MomentViewport
@onready var frozen_moment: Sprite2D = $MomentViewport/MomentContainer/FrozenMoment
@onready var shader_overlay: ColorRect = $MomentViewport/MomentContainer/AttunementShaderOverlay
@onready var hotspots_container: Control = $MomentViewport/MomentContainer/AttunementHotspots
@onready var viewport_rect: TextureRect = $ViewportTextureRect
@onready var phase_label: Label = $TopBar/PhaseLabel
@onready var attunement_count_label: Label = $TopBar/AttunementCount
@onready var attunement_panel: PanelContainer = $AttunementPanel
@onready var attunement_title: Label = $AttunementPanel/AttunementContent/AttunementTitle
@onready var attunement_description: Label = $AttunementPanel/AttunementContent/AttunementDescription
@onready var attunement_evidence: Label = $AttunementPanel/AttunementContent/AttunementEvidence
@onready var attunement_close: Button = $AttunementPanel/AttunementContent/AttunementClose
@onready var iris_intervention: Label = $IrisIntervention
@onready var continue_prompt: Label = $ContinuePrompt

var _moment_data: Dictionary = {}
var _attunements: Array[Dictionary] = []
var _hotspot_nodes: Array[Control] = []
var _completed_attunements: Array[String] = []
var _shader_material: ShaderMaterial
var _current_attunement: String = ""
var _discovery_threshold: int = 3
var _iris_intervened: bool = false
var _investigation_start_time: float = 0.0

func _ready() -> void:
    super._ready()
    phase_name = "investigating"
    
    viewport_rect.texture = viewport.get_texture()
    
    _shader_material = shader_overlay.material as ShaderMaterial
    if _shader_material:
        _shader_material.set_shader_parameter("time", 0.0)
        _shader_material.set_shader_parameter("attunement_mode", 0)
        _shader_material.set_shader_parameter("attunement_intensity", 0.0)
        _shader_material.set_shader_parameter("viewport_size", get_viewport_rect().size)
    
    # Style labels
    if ThemeService:
        ThemeService.apply_label_style(phase_label, "label_small", "primary_variant")
        phase_label.add_theme_font_size_override("font_size", 12)
        
        ThemeService.apply_label_style(attunement_count_label, "label_small", "text_tertiary")
        attunement_count_label.add_theme_font_size_override("font_size", 12)
        
        ThemeService.apply_label_style(attunement_title, "headline", "text_primary")
        attunement_title.add_theme_font_size_override("font_size", 22)
        
        ThemeService.apply_label_style(attunement_description, "body", "text_secondary")
        attunement_description.add_theme_font_size_override("font_size", 14)
        attunement_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        ThemeService.apply_label_style(attunement_evidence, "body_small", "primary_variant")
        attunement_evidence.add_theme_font_size_override("font_size", 13)
        attunement_evidence.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        ThemeService.apply_label_style(iris_intervention, "headline", "primary_variant")
        iris_intervention.add_theme_font_size_override("font_size", 18)
        iris_intervention.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        ThemeService.apply_label_style(continue_prompt, "caption", "text_tertiary")
        continue_prompt.add_theme_font_size_override("font_size", 12)
        continue_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    
    # Style close button
    _style_close_button()
    attunement_close.pressed.connect(_close_attunement_panel)
    
    attunement_panel.visible = false
    iris_intervention.visible = false
    continue_prompt.visible = false
    
    set_process(true)

func _style_close_button() -> void:
    var tokens = ThemeService.tokens if ThemeService else {}
    var radius = int(tokens.get("radius_md", 14)) if not tokens.is_empty() else 14
    var surface_col = tokens.get("surface_elevated", Color("#2A2A36")) if not tokens.is_empty() else Color("#2A2A36")
    
    var normal = StyleBoxFlat.new()
    normal.bg_color = surface_col
    normal.border_color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
    normal.border_width_left = 1
    normal.border_width_right = 1
    normal.border_width_top = 1
    normal.border_width_bottom = 1
    normal.corner_radius_top_left = radius
    normal.corner_radius_top_right = radius
    normal.corner_radius_bottom_left = radius
    normal.corner_radius_bottom_right = radius
    normal.content_margin_left = 20
    normal.content_margin_right = 20
    normal.content_margin_top = 12
    normal.content_margin_bottom = 12
    
    var hover = normal.duplicate()
    hover.bg_color = surface_col.lightened(0.1)
    
    attunement_close.add_theme_stylebox_override("normal", normal)
    attunement_close.add_theme_stylebox_override("hover", hover)
    attunement_close.add_theme_stylebox_override("pressed", hover)
    attunement_close.add_theme_stylebox_override("focus", hover)
    if ThemeService:
        attunement_close.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))
        attunement_close.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))

func _on_configure() -> void:
    if moment_definition:
        _moment_data = moment_definition.to_blueprint()
        _attunements = _moment_data.get("investigation", {}).get("attunements", [])
        _discovery_threshold = int(_moment_data.get("investigation", {}).get("discovery_threshold", 3))
        
        # Load frozen moment background — prefer action image for frozen scene
        var env = _moment_data.get("environment", {})
        var action_path = env.get("action_image", "")
        var bg_path = env.get("background_image", "")
        var primary_path = action_path if (action_path and ResourceLoader.exists(action_path)) else bg_path
        if primary_path and ResourceLoader.exists(primary_path):
            frozen_moment.texture = load(primary_path) as Texture2D
        
        _create_hotspots()

func _on_begin() -> void:
    _investigation_start_time = Time.get_ticks_msec() / 1000.0
    _show_continue_prompt()
    _speak("Each anomaly holds a perspective. Attune to what draws your attention.")

func _process(delta: float) -> void:
    if _shader_material:
        _shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func _create_hotspots() -> void:
    for child in hotspots_container.get_children():
        child.queue_free()
    _hotspot_nodes.clear()
    
    var hotspot_defs: Array[Dictionary] = []
    for i in range(_attunements.size()):
        var att := _attunements[i]
        if att.has("pos") and att.has("size"):
            hotspot_defs.append({
                "id": str(att.get("object", "")),
                "pos": att.get("pos", Vector2(0.5, 0.5)),
                "size": att.get("size", Vector2(0.16, 0.16)),
                "label": str(att.get("object", "")).replace("_", " ").capitalize()
            })
        else:
            var col_idx := i % 2
            var row_idx := int(i / 2)
            var norm_pos := Vector2(0.22 + float(col_idx) * 0.44 + (float(i) * 0.03), 0.32 + float(row_idx) * 0.20)
            hotspot_defs.append({
                "id": str(att.get("object", "")),
                "pos": norm_pos,
                "size": Vector2(0.16, 0.16),
                "label": str(att.get("object", "")).replace("_", " ").capitalize()
            })
            
    # Fallback if no attunements provided
    if hotspot_defs.is_empty():
        hotspot_defs = [
            {"id": "primary_cup", "pos": Vector2(0.65, 0.38), "size": Vector2(0.12, 0.15), "label": "Tea Cup"},
            {"id": "hand", "pos": Vector2(0.55, 0.45), "size": Vector2(0.18, 0.20), "label": "Hand"}
        ]
    
    var viewport_size = get_viewport_rect().size
    for i in range(hotspot_defs.size()):
        var hs = hotspot_defs[i]
        var hotspot = _create_hotspot(hs, viewport_size, i)
        hotspots_container.add_child(hotspot)
        _hotspot_nodes.append(hotspot)

func _create_hotspot(hs: Dictionary, viewport_size: Vector2, index: int) -> Control:
    var hotspot = Control.new()
    hotspot.name = "Hotspot_%s" % hs.id
    hotspot.set_meta("attunement_id", hs.id)
    hotspot.set_meta("hotspot_index", index)
    hotspot.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    
    var pos = hs.pos * viewport_size
    var size = hs.size * viewport_size
    hotspot.position = pos - size * 0.5
    hotspot.custom_minimum_size = size
    
    # Interactive
    hotspot.mouse_filter = Control.MOUSE_FILTER_PASS
    
    # Subtle optical anomaly indicator
    var indicator = Control.new()
    indicator.name = "Indicator"
    indicator.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    var draw_script = GDScript.new()
    draw_script.source_code = """
extends Control
@export var pulse_speed := 1.5
var time := 0.0
var visible := true
var is_completed := false

func _process(delta):
    time += delta
    queue_redraw()

func _draw():
    if not visible:
        return
    var rect = Rect2(Vector2.ZERO, size)
    if is_completed:
        var col = Color(0.88, 0.78, 0.45, 0.5)
        draw_rect(rect, col, false, 1.5)
        draw_circle(size * 0.5, min(size.x, size.y) * 0.15, Color(0.88, 0.78, 0.45, 0.3))
    else:
        var alpha = 0.22 + sin(time * pulse_speed) * 0.12
        var col = Color(0.35, 0.92, 0.82, alpha)
        draw_rect(rect, col, false, 1.2)
        # Corner optical brackets
        var bracket = min(size.x, size.y) * 0.25
        draw_line(Vector2(0, bracket), Vector2(0, 0), col, 1.5)
        draw_line(Vector2(0, 0), Vector2(bracket, 0), col, 1.5)
        draw_line(Vector2(size.x, size.y - bracket), Vector2(size.x, size.y), col, 1.5)
        draw_line(Vector2(size.x, size.y), Vector2(size.x - bracket, size.y), col, 1.5)
"""
    indicator.set_script(draw_script)
    hotspot.add_child(indicator)
    
    hotspot.gui_input.connect(_on_hotspot_gui_input.bind(hotspot))
    
    return hotspot

func _on_hotspot_gui_input(event: InputEvent, hotspot: Control) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _activate_attunement(hotspot.get_meta("attunement_id"))
    elif event is InputEventScreenTouch:
        if event.pressed:
            _activate_attunement(hotspot.get_meta("attunement_id"))

func _activate_attunement(attunement_id: String) -> void:
    if _current_attunement == attunement_id:
        return
    
    # Find attunement data
    var attunement_data = null
    for a in _attunements:
        if a.object == attunement_id:
            attunement_data = a
            break
    
    if not attunement_data:
        return
    
    _current_attunement = attunement_id
    _show_attunement_panel(attunement_data)
    _apply_attunement_shader(attunement_data)
    _play_sfx("attunement_enter", 0.5)
    _vibrate(35)
    var sound := get_tree().root.get_node_or_null("Main/ProceduralSound") if get_tree() and get_tree().root.has_node("Main/ProceduralSound") else null
    if sound and sound.has_method("focus_notice_tone"):
        sound.focus_notice_tone()

func _show_attunement_panel(attunement_data: Dictionary) -> void:
    var type_names = {
        "thermal": "THERMAL ATTUNEMENT",
        "skeletal": "SKELETAL ATTUNEMENT",
        "text": "TEXT ATTUNEMENT",
        "forensic": "FORENSIC ATTUNEMENT",
        "trajectory": "TRAJECTORY ATTUNEMENT",
        "spectral": "SPECTRAL ATTUNEMENT"
    }
    
    attunement_title.text = type_names.get(attunement_data.type, "ATTUNEMENT")
    attunement_description.text = attunement_data.reveals
    attunement_evidence.text = ""
    
    attunement_panel.visible = true
    attunement_panel.modulate.a = 0.0
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(attunement_panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
    else:
        attunement_panel.modulate.a = 1.0

func _apply_attunement_shader(attunement_data: Dictionary) -> void:
    if not _shader_material:
        return
    
    var type_to_mode = {
        "thermal": 1,
        "skeletal": 2,
        "text": 3,
        "forensic": 4,
        "trajectory": 5,
        "spectral": 6
    }
    
    var mode = type_to_mode.get(attunement_data.type, 0)
    _shader_material.set_shader_parameter("attunement_mode", mode)
    _shader_material.set_shader_parameter("attunement_intensity", 1.0)
    
    # Set hotspot center for this attunement
    var hs = _find_hotspot_by_id(attunement_data.object)
    if hs:
        var center = (hs.global_position + hs.size * 0.5) / get_viewport_rect().size
        _shader_material.set_shader_parameter("hotspot_center", center)
        _shader_material.set_shader_parameter("hotspot_radius", max(hs.size.x, hs.size.y) / get_viewport_rect().size.x * 1.5)

func _find_hotspot_by_id(attunement_id: String) -> Control:
    for hs in _hotspot_nodes:
        if hs.get_meta("attunement_id", "") == attunement_id:
            return hs
    return null

func _close_attunement_panel() -> void:
    if _current_attunement == "":
        return
    
    # Mark as completed if not already
    if not _completed_attunements.has(_current_attunement):
        _completed_attunements.append(_current_attunement)
        _update_attunement_count()
        var hs := _find_hotspot_by_id(_current_attunement)
        if hs and hs.has_node("Indicator"):
            hs.get_node("Indicator").set("is_completed", true)
        _check_discovery_threshold()
    
    # Animate out
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(attunement_panel, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
        tween.finished.connect(func(): attunement_panel.visible = false)
    else:
        attunement_panel.visible = false
        attunement_panel.modulate.a = 0.0
    
    # Reset shader
    if _shader_material:
        _shader_material.set_shader_parameter("attunement_mode", 0)
        _shader_material.set_shader_parameter("attunement_intensity", 0.0)
    
    _current_attunement = ""
    _play_sfx("attunement_exit", 0.4)

func _update_attunement_count() -> void:
    attunement_count_label.text = "Attunements: %d / %d" % [_completed_attunements.size(), _attunements.size()]

func _check_discovery_threshold() -> void:
    if _iris_intervened:
        return
    if _completed_attunements.size() >= _discovery_threshold:
        _trigger_iris_intervention()

func _trigger_iris_intervention() -> void:
    _iris_intervened = true
    
    var intervention_text = _moment_data.get("investigation", {}).get("iris_intervention", 
        "You have seen enough. Or you haven't. The moment asks only for your presence.")
    
    iris_intervention.text = intervention_text
    iris_intervention.visible = true
    iris_intervention.modulate.a = 0.0
    
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(iris_intervention, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    else:
        iris_intervention.modulate.a = 1.0
    
    _speak(intervention_text)
    _play_sfx("revelation", 0.6)
    _vibrate(60)
    
    # Show proceed prompt after Iris finishes observation
    get_tree().create_timer(3.2).timeout.connect(_show_continue_prompt)

func _show_continue_prompt() -> void:
    continue_prompt.text = "THE TRUTH IS PRESERVED · TAP TO CONTINUE"
    continue_prompt.visible = true
    continue_prompt.modulate.a = 0.0
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(continue_prompt, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
    else:
        continue_prompt.modulate.a = 1.0
    # Enable background tap to complete once prompt appears
    if not gui_input.is_connected(_on_screen_tap_complete):
        gui_input.connect(_on_screen_tap_complete)

func _on_screen_tap_complete(event: InputEvent) -> void:
    if not _iris_intervened or _current_attunement != "":
        return
    if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
        _complete_investigation()

func _complete_investigation() -> void:
    set_process(false)
    
    var data = {
        "completed_attunements": _completed_attunements.duplicate(true),
        "total_attunements": _attunements.size(),
        "discovery_threshold_reached": _iris_intervened,
        "investigation_duration": Time.get_ticks_msec() / 1000.0 - _investigation_start_time,
        "moment_id": moment_definition.moment_id if moment_definition else ""
    }
    
    complete(data)

func _on_viewport_resized(size: Vector2) -> void:
    if _shader_material:
        _shader_material.set_shader_parameter("viewport_size", size)
    _create_hotspots()
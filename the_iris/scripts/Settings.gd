extends BaseScreen
class_name SettingsScreen

signal request_home
signal request_witness

@onready var production_host: ProductionDestinationHost = $ProductionDestinationHost
var production_bridge: TwoSecondWitnessProductionBridge
var production_active := false
var state_manager: IrisStateManager
var sound_label: Label
var motion_label: Label
var contrast_label: Label
var reduced_label: Label
var access_label: Label
var captions_label: Label
var orientation_label: Label
var parallax_label: Label
var confirmation_label: Label

func _ready() -> void:
    super._ready()
    add_back_label("THE IRIS  ·  CALIBRATION")
    make_label("CALIBRATION", 26, INK, Vector2(32, 108), Vector2(656, 48))
    make_label("tune the instrument to your way of perceiving", 14, MUTED, Vector2(34, 157), Vector2(656, 32))
    sound_label = make_label("", 17, INK, Vector2(64, 250), Vector2(592, 42))
    motion_label = make_label("", 17, INK, Vector2(64, 355), Vector2(592, 42))
    contrast_label = make_label("", 17, INK, Vector2(64, 460), Vector2(592, 42))
    reduced_label = make_label("", 17, INK, Vector2(64, 565), Vector2(592, 42))
    access_label = make_label("", 17, INK, Vector2(64, 670), Vector2(592, 42))
    captions_label = make_label("", 17, INK, Vector2(64, 775), Vector2(592, 42))
    orientation_label = make_label("", 17, INK, Vector2(64, 880), Vector2(592, 42))
    parallax_label = make_label("", 17, INK, Vector2(64, 985), Vector2(592, 42))
    make_label("AUDIO", 11, DIM, Vector2(34, 220), Vector2(650, 25))
    make_label("MOTION", 11, DIM, Vector2(34, 325), Vector2(650, 25))
    make_label("VISIBILITY", 11, DIM, Vector2(34, 430), Vector2(650, 25))
    make_label("MOTION ACCESS", 11, DIM, Vector2(34, 535), Vector2(650, 25))
    make_label("EXPLICIT ACCESS", 11, DIM, Vector2(34, 640), Vector2(650, 25))
    make_label("VOICE ACCESS", 11, DIM, Vector2(34, 745), Vector2(650, 25))
    make_label("ORIENTATION", 11, DIM, Vector2(34, 850), Vector2(650, 25))
    make_label("OPTICAL PARALLAX", 11, DIM, Vector2(34, 955), Vector2(650, 25))
    confirmation_label = make_label("", 14, AMBER, Vector2(34, 1060), Vector2(652, 30), HORIZONTAL_ALIGNMENT_CENTER)
    make_label("tap a row to change  ·  swipe down to return", 12, DIM, Vector2(34, 1235), Vector2(652, 30), HORIZONTAL_ALIGNMENT_CENTER)
    for y in [315.0, 420.0, 525.0, 630.0, 735.0, 840.0, 945.0, 1050.0]:
        add_rule(y, Color("#1f3b3b"), 64.0, 656.0)
    production_host.request_home.connect(_on_production_home)
    production_host.request_witness.connect(_on_production_witness)
    _refresh_copy()
    queue_redraw()

func set_production_bridge(value: TwoSecondWitnessProductionBridge) -> void:
    production_bridge = value
    production_host.set_production_bridge(value)

func _on_production_home() -> void:
    production_active = false
    production_host.exit()
    queue_redraw()

func _on_production_witness() -> void:
    request_witness.emit()

func set_state_manager(value: IrisStateManager) -> void:
    state_manager = value
    _refresh_copy()

func enter() -> void:
    if production_bridge != null:
        production_active = true
        confirmation_label.visible = false
        production_host.enter()
        return
    production_active = false
    confirmation_label.visible = true
    confirmation_label.text = ""
    _refresh_copy()

func _refresh_copy() -> void:
    if not is_instance_valid(sound_label) or not state_manager:
        return
    var sound_on := state_manager.sound_enabled
    var production_reduced := state_manager.reduced_motion
    var production_contrast := state_manager.high_contrast
    if SettingsService:
        sound_on = not bool(SettingsService.get_value("mute_master", not sound_on))
        production_reduced = bool(SettingsService.get_value("reduced_motion", production_reduced)) or bool(SettingsService.get_value("accessibility_reduce_motion", false))
        production_contrast = bool(SettingsService.get_value("high_contrast", production_contrast))
    sound_label.text = "BREATHING PULSE" + ("                              ON" if sound_on else "                              OFF")
    motion_label.text = "ANIMATION INTENSITY" + ("                         FULL" if state_manager.animation_intensity > 0.5 else "                         LOW")
    contrast_label.text = "HIGH CONTRAST" + ("                              ON" if production_contrast else "                              OFF")
    reduced_label.text = "REDUCED MOTION" + ("                              ON" if production_reduced else "                              OFF")
    access_label.text = "EXPLICIT ACCESS PATH" + ("                         ON" if state_manager.accessible_navigation else "                         OFF")
    captions_label.text = "VOICE TRANSCRIPT" + ("                              ON" if state_manager.captions_enabled else "                              OFF")
    orientation_label.text = "LOCK ORIENTATION" + ("                              ON" if state_manager.orientation_lock else "                              OFF")
    sound_label.add_theme_color_override("font_color", Color("#e1f5ed") if sound_on else DIM)
    motion_label.add_theme_color_override("font_color", Color("#e1f5ed") if state_manager.animation_intensity > 0.5 else DIM)
    contrast_label.add_theme_color_override("font_color", Color("#e1f5ed") if production_contrast else DIM)
    reduced_label.add_theme_color_override("font_color", Color("#e1f5ed") if production_reduced else DIM)
    access_label.add_theme_color_override("font_color", Color("#e1f5ed") if state_manager.accessible_navigation else DIM)
    captions_label.add_theme_color_override("font_color", Color("#e1f5ed") if state_manager.captions_enabled else DIM)
    orientation_label.add_theme_color_override("font_color", Color("#e1f5ed") if state_manager.orientation_lock else DIM)
    parallax_label.text = "LENS PARALLAX" + ("                              ON" if state_manager.parallax_enabled else "                              OFF")
    parallax_label.add_theme_color_override("font_color", Color("#e1f5ed") if state_manager.parallax_enabled else DIM)

func _draw() -> void:
    var vs := get_viewport_rect().size
    draw_rect(Rect2(0, 0, size.x, size.y), Color("#0a1118"))
    for i in range(8):
        var y := 274.0 + i * 105.0
        draw_circle(Vector2(34, y), 4.0, Color("#63c8b2"))
        draw_line(Vector2(38, y), Vector2(54, y), Color(0.39, 0.78, 0.70, 0.65), 1.0)
    draw_rect(Rect2(64, 1100, 592, 1), Color("#1f3b3b"))
    draw_rect(Rect2(64, 1120, 592, 82), Color(0.20, 0.11, 0.08, 0.24))
    draw_string(ThemeDB.fallback_font, Vector2(82, 1152), "RESET WITNESS RECORD", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d1a866"))
    draw_string(ThemeDB.fallback_font, Vector2(82, 1178), "clear discoveries and attention score", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#7d7770"))

func handle_tap(position: Vector2) -> void:
    if production_active:
        if position.y < 96.0 and position.x < 320.0:
            request_home.emit()
        return
    if position.y < 88.0 and position.x < 330.0:
        request_home.emit()
    elif position.y >= 215.0 and position.y < 315.0:
        state_manager.sound_enabled = not state_manager.sound_enabled
        if SettingsService:
            SettingsService.set_value("mute_master", not state_manager.sound_enabled)
        state_manager.update_preferences()
        confirmation_label.text = "sound preference updated"
        _refresh_copy()
    elif position.y >= 320.0 and position.y < 420.0:
        state_manager.animation_intensity = 0.15 if state_manager.animation_intensity > 0.5 else 1.0
        if SettingsService:
            SettingsService.set_value("reduced_motion", state_manager.animation_intensity <= 0.5)
        state_manager.update_preferences()
        confirmation_label.text = "motion preference updated"
        _refresh_copy()
    elif position.y >= 425.0 and position.y < 525.0:
        state_manager.high_contrast = not state_manager.high_contrast
        if SettingsService:
            SettingsService.set_value("high_contrast", state_manager.high_contrast)
        state_manager.update_preferences()
        confirmation_label.text = "visibility preference updated"
        _refresh_copy()
    elif position.y >= 530.0 and position.y < 630.0:
        state_manager.reduced_motion = not state_manager.reduced_motion
        if SettingsService:
            SettingsService.set_value("reduced_motion", state_manager.reduced_motion)
            SettingsService.set_value("accessibility_reduce_motion", state_manager.reduced_motion)
        state_manager.update_preferences()
        confirmation_label.text = "reduced motion updated"
        _refresh_copy()
    elif position.y >= 635.0 and position.y < 735.0:
        state_manager.accessible_navigation = not state_manager.accessible_navigation
        state_manager.update_preferences()
        confirmation_label.text = "explicit access path updated"
        _refresh_copy()
    elif position.y >= 740.0 and position.y < 845.0:
        state_manager.captions_enabled = not state_manager.captions_enabled
        state_manager.update_preferences()
        confirmation_label.text = "voice transcript updated"
        _refresh_copy()
    elif position.y >= 845.0 and position.y < 950.0:
        state_manager.orientation_lock = not state_manager.orientation_lock
        state_manager.update_preferences()
        confirmation_label.text = "orientation preference updated"
        _refresh_copy()
    elif position.y >= 950.0 and position.y < 1055.0:
        state_manager.parallax_enabled = not state_manager.parallax_enabled
        state_manager.update_preferences()
        confirmation_label.text = "parallax preference updated"
        _refresh_copy()
    elif position.y >= 1090.0 and position.y < 1220.0:
        state_manager.reset_progress()
        confirmation_label.text = "witness record reset"
        _refresh_copy()

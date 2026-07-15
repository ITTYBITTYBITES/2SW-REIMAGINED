extends WitnessMomentPhase
class_name WitnessReconstructionScreen

## Witness Reconstruction Phase - Spatial fragment placement
## No validation, no correct answers. Only what the player carries.

signal reconstruction_complete

@onready var viewport: SubViewport = $DeskViewport
@onready var desk_bg: Sprite2D = $DeskViewport/DeskContainer/DeskBackground
@onready var ghost_container: Control = $DeskViewport/DeskContainer/GhostOutlinesContainer
@onready var viewport_rect: TextureRect = $ViewportTextureRect
@onready var phase_label: Label = $TopBar/PhaseLabel
@onready var iris_prompt: Label = $IrisPrompt
@onready var fragment_palette: HBoxContainer = $FragmentPalette
@onready var continue_btn: Button = $ContinueButton
@onready var instruction_hint: Label = $InstructionHint

var _moment_data: Dictionary = {}
var _ghost_outlines: Array[Dictionary] = []
var _fragment_definitions: Array[Dictionary] = []
var _fragment_cards: Array[Control] = []
var _placed_fragments: Dictionary = {}  # ghost_id -> Array[fragment_ids]
var _palette_fragments: Dictionary = {}  # fragment_id -> Control (card in palette)
var _dragged_fragment: Control = null
var _drag_offset: Vector2 = Vector2.ZERO
var _original_palette_pos: Vector2 = Vector2.ZERO
var _is_dragging: bool = false

func _ready() -> void:
    super._ready()
    phase_name = "reconstructing"
    
    viewport_rect.texture = viewport.get_texture()
    
    # Style phase label
    if ThemeService:
        ThemeService.apply_label_style(phase_label, "label_small", "primary_variant")
    phase_label.add_theme_font_size_override("font_size", 12)
    
    # Style iris prompt
    if ThemeService:
        ThemeService.apply_label_style(iris_prompt, "body", "text_secondary")
    iris_prompt.add_theme_font_size_override("font_size", 15)
    
    # Style instruction hint
    if ThemeService:
        ThemeService.apply_label_style(instruction_hint, "caption", "text_tertiary")
    instruction_hint.add_theme_font_size_override("font_size", 12)
    
    # Style continue button
    _style_continue_button()
    continue_btn.pressed.connect(_on_continue_pressed)
    continue_btn.visible = false
    continue_btn.disabled = true
    
    fragment_palette.visible = true
    instruction_hint.visible = false
    iris_prompt.visible = false

func _style_continue_button() -> void:
    var tokens = ThemeService.tokens if ThemeService else {}
    var radius = int(tokens.get("radius_lg", 18)) if not tokens.is_empty() else 18
    var primary_col = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
    
    var normal = StyleBoxFlat.new()
    normal.bg_color = primary_col
    normal.corner_radius_top_left = radius
    normal.corner_radius_top_right = radius
    normal.corner_radius_bottom_left = radius
    normal.corner_radius_bottom_right = radius
    normal.content_margin_left = 24
    normal.content_margin_right = 24
    normal.content_margin_top = 14
    normal.content_margin_bottom = 14
    
    var hover = normal.duplicate()
    hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
    
    continue_btn.add_theme_stylebox_override("normal", normal)
    continue_btn.add_theme_stylebox_override("hover", hover)
    continue_btn.add_theme_stylebox_override("pressed", hover)
    continue_btn.add_theme_stylebox_override("focus", hover)
    continue_btn.add_theme_stylebox_override("disabled", normal.duplicate())
    continue_btn.add_theme_color_override("font_color", Color.WHITE)
    if ThemeService:
        continue_btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))

func _on_configure() -> void:
    if moment_definition:
        _moment_data = moment_definition.to_blueprint()
        var recon = _moment_data.get("mechanics", {}).get("memory", {})
        
        # Load ghost outlines from moment definition
        var env = _moment_data.get("environment", {})
        var ambient = env.get("ambient_details", [])
        _build_ghost_outlines(ambient)
        
        # Load fragment palette
        var fragments = _moment_data.get("reconstruction", {}).get("fragment_palette", [])
        _fragment_definitions = fragments
        
        # Load desk background
        var bg_path = env.get("background_image", "")
        if bg_path and ResourceLoader.exists(bg_path):
            desk_bg.texture = load(bg_path) as Texture2D
        else:
            # Use observation image as reference, desaturated
            desk_bg.modulate = Color(1, 1, 1, 0.12)

func _on_begin() -> void:
    _create_ghost_outlines()
    _create_fragment_palette()
    _show_iris_prompt()

func _build_ghost_outlines(ambient_details: Array) -> void:
    # Define ghost outline positions relative to desk (normalized 0-1)
    # These correspond to the ambient objects in the moment
    _ghost_outlines = [
        {"id": "notebook", "label": "Notebook", "pos": Vector2(0.25, 0.55), "size": Vector2(0.18, 0.14)},
        {"id": "primary_cup", "label": "Tea Cup", "pos": Vector2(0.65, 0.38), "size": Vector2(0.08, 0.10)},
        {"id": "pen", "label": "Pen", "pos": Vector2(0.35, 0.50), "size": Vector2(0.06, 0.12)},
        {"id": "glasses", "label": "Glasses", "pos": Vector2(0.20, 0.62), "size": Vector2(0.08, 0.05)},
        {"id": "keys", "label": "Keys", "pos": Vector2(0.80, 0.70), "size": Vector2(0.07, 0.06)},
        {"id": "plant", "label": "Plant", "pos": Vector2(0.10, 0.25), "size": Vector2(0.12, 0.20)},
        {"id": "second_cup", "label": "Second Cup", "pos": Vector2(0.75, 0.55), "size": Vector2(0.07, 0.09)},
    ]

func _create_ghost_outlines() -> void:
    for child in ghost_container.get_children():
        child.queue_free()
    
    var viewport_size = get_viewport_rect().size
    for i, ghost in _ghost_outlines:
        var outline = _create_ghost_outline(ghost, viewport_size)
        ghost_container.add_child(outline)
        # Store reference
        outline.set_meta("ghost_id", ghost.id)
        outline.set_meta("ghost_index", i)

func _create_ghost_outline(ghost: Dictionary, viewport_size: Vector2) -> Control:
    var container = Control.new()
    container.name = "Ghost_%s" % ghost.id
    container.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    
    var pos = ghost.pos * viewport_size
    var size = ghost.size * viewport_size
    container.position = pos - size * 0.5
    container.custom_minimum_size = size
    
    # Draw ghost outline via script
    var draw_script = GDScript.new()
    draw_script.source_code = """
extends Control
@export var pulse_speed := 1.2
@export var base_alpha := 0.15
@export var pulse_alpha := 0.08
var time := 0.0

func _process(delta):
    time += delta
    queue_redraw()

func _draw():
    var rect = Rect2(Vector2.ZERO, size)
    var alpha = base_alpha + sin(time * pulse_speed) * pulse_alpha
    var color = Color(1, 1, 1, alpha)
    draw_rect(rect, color, false, 1.5)
    # Corner markers
    var corner_size = 8.0
    draw_line(Vector2(0, corner_size), Vector2(0, 0), color, 1.5)
    draw_line(Vector2(0, 0), Vector2(corner_size, 0), color, 1.5)
    draw_line(Vector2(size.x, size.y - corner_size), Vector2(size.x, size.y), color, 1.5)
    draw_line(Vector2(size.x, size.y), Vector2(size.x - corner_size, size.y), color, 1.5)
    draw_line(Vector2(size.x - corner_size, 0), Vector2(size.x, 0), color, 1.5)
    draw_line(Vector2(size.x, 0), Vector2(size.x, corner_size), color, 1.5)
    draw_line(Vector2(0, size.y), Vector2(corner_size, size.y), color, 1.5)
    draw_line(Vector2(0, size.y - corner_size), Vector2(0, size.y), color, 1.5)
"""
    container.set_script(draw_script)
    container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Add label
    var label = Label.new()
    label.text = ghost.label
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    label.custom_minimum_size = Vector2(size.x, 20)
    label.position = Vector2(0, size.y + 4)
    if ThemeService:
        ThemeService.apply_label_style(label, "caption", "text_tertiary")
    label.add_theme_font_size_override("font_size", 10)
    label.modulate.a = 0.6
    container.add_child(label)
    
    return container

func _create_fragment_palette() -> void:
    for child in fragment_palette.get_children():
        child.queue_free()
    _fragment_cards.clear()
    _palette_fragments.clear()
    
    for frag_def in _fragment_definitions:
        var card = _create_fragment_card(frag_def)
        fragment_palette.add_child(card)
        _fragment_cards.append(card)
        _palette_fragments[frag_def.id] = card

func _create_fragment_card(frag_def: Dictionary) -> Control:
    var card = Control.new()
    card.name = "Fragment_%s" % frag_def.id
    card.set_meta("fragment_id", frag_def.id)
    card.set_meta("fragment_data", frag_def)
    custom_minimum_size = Vector2(100, 80)
    size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    # Panel background
    var panel = PanelContainer.new()
    panel.name = "Panel"
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    var tokens = ThemeService.tokens if ThemeService else {}
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.12, 0.12, 0.16, 0.7)
    style.border_color = Color(0.4, 0.4, 0.5, 0.5)
    style.border_width_left = 1
    style.border_width_right = 1
    style.border_width_top = 1
    style.border_width_bottom = 1
    var radius = int(tokens.get("radius_md", 12)) if not tokens.is_empty() else 12
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    card.add_child(panel)
    
    # Icon + Label vertical layout
    var vbox = VBoxContainer.new()
    vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vbox.alignment = BOX_ALIGNMENT_CENTER
    vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
    panel.add_child(vbox)
    
    var icon_label = Label.new()
    icon_label.text = frag_def.icon
    icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    icon_label.add_theme_font_size_override("font_size", 28)
    vbox.add_child(icon_label)
    
    var text_label = Label.new()
    text_label.text = frag_def.label
    text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    text_label.custom_minimum_size = Vector2(90, 0)
    if ThemeService:
        ThemeService.apply_label_style(text_label, "caption", "text_secondary")
    text_label.add_theme_font_size_override("font_size", 11)
    vbox.add_child(text_label)
    
    # Input handling for drag
    var touch_area = Control.new()
    touch_area.name = "TouchArea"
    touch_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    touch_area.mouse_filter = Control.MOUSE_FILTER_PASS
    card.add_child(touch_area)
    
    touch_area.gui_input.connect(_on_fragment_gui_input.bind(card))
    
    # Subtle float animation
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(card, "position:y", card.position.y + 4.0, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
    
    return card

func _on_fragment_gui_input(event: InputEvent, card: Control) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _start_drag(card, event.position)
        elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            _end_drag(event.position)
    elif event is InputEventMouseMotion and _is_dragging:
        _update_drag(event.position)
    elif event is InputEventScreenTouch:
        if event.pressed:
            _start_drag(card, event.position)
        else:
            _end_drag(event.position)
    elif event is InputEventScreenDrag and _is_dragging:
        _update_drag(event.position)

func _start_drag(card: Control, screen_pos: Vector2) -> void:
    _is_dragging = true
    _dragged_fragment = card
    _original_palette_pos = card.global_position
    _drag_offset = card.global_position - screen_pos
    
    # Bring to front
    card.get_parent().move_child(card, -1)
    
    # Visual feedback
    var panel = card.get_node("Panel") as PanelContainer
    if panel:
        var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
        if style:
            var hover_style = style.duplicate()
            hover_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
            hover_style.border_color = Color(0.6, 0.6, 0.8, 0.8)
            panel.add_theme_stylebox_override("panel", hover_style)
    
    # Scale up slightly
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(card, "scale", Vector2(1.08, 1.08), 0.15).set_ease(Tween.EASE_OUT)
    
    _vibrate(20)
    _play_sfx("ui_click", 0.3)

func _update_drag(screen_pos: Vector2) -> void:
    if not _is_dragging or not _dragged_fragment:
        return
    _dragged_fragment.global_position = screen_pos + _drag_offset

func _end_drag(screen_pos: Vector2) -> void:
    if not _is_dragging or not _dragged_fragment:
        return
    
    var fragment_id = _dragged_fragment.get_meta("fragment_id")
    var dropped_on_ghost = false
    var ghost_id = ""
    
    # Check if dropped on a ghost outline
    var ghost_at_pos = _get_ghost_at_position(screen_pos)
    if ghost_at_pos:
        ghost_id = ghost_at_pos.get_meta("ghost_id")
        _place_fragment_on_ghost(fragment_id, ghost_id)
        dropped_on_ghost = true
    
    # Return to palette if not dropped on ghost
    if not dropped_on_ghost:
        _return_fragment_to_palette(_dragged_fragment)
    else:
        _play_sfx("ui_click", 0.4)
        _check_continue_availability()
    
    # Reset drag state
    _dragged_fragment = null
    _is_dragging = false
    _drag_offset = Vector2.ZERO

func _get_ghost_at_position(screen_pos: Vector2) -> Control:
    for child in ghost_container.get_children():
        if child is Control:
            var rect = Rect2(child.global_position, child.size)
            if rect.has_point(screen_pos):
                return child
    return null

func _place_fragment_on_ghost(fragment_id: String, ghost_id: String) -> void:
    # Add to placed fragments
    if not _placed_fragments.has(ghost_id):
        _placed_fragments[ghost_id] = []
    _placed_fragments[ghost_id].append(fragment_id)
    
    # Create placed visual on ghost
    var ghost = _find_ghost_by_id(ghost_id)
    if ghost:
        var frag_def = _find_fragment_def(fragment_id)
        var placed = _create_placed_fragment(frag_def)
        ghost.add_child(placed)
        
        # Animate placement
        placed.position = Vector2(ghost.size.x * 0.5, ghost.size.y * 0.5)
        placed.scale = Vector2(0.5, 0.5)
        placed.modulate.a = 0.0
        if _should_animate:
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(placed, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
            tween.parallel().tween_property(placed, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
    
    # Remove from palette
    var palette_card = _palette_fragments.get(fragment_id)
    if palette_card:
        palette_card.queue_free()
        _palette_fragments.erase(fragment_id)

func _return_fragment_to_palette(card: Control) -> void:
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(card, "global_position", _original_palette_pos, 0.3).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
        tween.finished.connect(func(): _reset_card_style(card))
    else:
        card.global_position = _original_palette_pos
        card.scale = Vector2(1.0, 1.0)
        _reset_card_style(card)

func _reset_card_style(card: Control) -> void:
    var panel = card.get_node("Panel") as PanelContainer
    if panel:
        var tokens = ThemeService.tokens if ThemeService else {}
        var style = StyleBoxFlat.new()
        style.bg_color = Color(0.12, 0.12, 0.16, 0.7)
        style.border_color = Color(0.4, 0.4, 0.5, 0.5)
        style.border_width_left = 1
        style.border_width_right = 1
        style.border_width_top = 1
        style.border_width_bottom = 1
        var radius = int(tokens.get("radius_md", 12)) if not tokens.is_empty() else 12
        style.corner_radius_top_left = radius
        style.corner_radius_top_right = radius
        style.corner_radius_bottom_left = radius
        style.corner_radius_bottom_right = radius
        style.content_margin_left = 12
        style.content_margin_right = 12
        style.content_margin_top = 10
        style.content_margin_bottom = 10
        panel.add_theme_stylebox_override("panel", style)

func _create_placed_fragment(frag_def: Dictionary) -> Control:
    var placed = Control.new()
    placed.name = "Placed_%s" % frag_def.id
    placed.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    
    var label = Label.new()
    label.text = "%s %s" % [frag_def.icon, frag_def.label]
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(120, 0)
    if ThemeService:
        ThemeService.apply_label_style(label, "caption", "text_secondary")
    label.add_theme_font_size_override("font_size", 10)
    label.modulate = Color(1, 1, 1, 0.9)
    placed.add_child(label)
    
    return placed

func _find_ghost_by_id(ghost_id: String) -> Control:
    for child in ghost_container.get_children():
        if child.get_meta("ghost_id", "") == ghost_id:
            return child
    return null

func _find_fragment_def(fragment_id: String) -> Dictionary:
    for frag in _fragment_definitions:
        if frag.id == fragment_id:
            return frag
    return {}

func _show_iris_prompt() -> void:
    var prompt_text = _moment_data.get("reconstruction", {}).get("iris_prompt", "Place what stayed with you. Leave what didn't. There is no wrong answer — only what you carry.")
    iris_prompt.text = prompt_text
    iris_prompt.visible = true
    instruction_hint.visible = true
    
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(iris_prompt, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(instruction_hint, "modulate:a", 0.7, 0.6).set_ease(Tween.EASE_OUT).set_delay(0.3)
    else:
        iris_prompt.modulate.a = 1.0
        instruction_hint.modulate.a = 0.7
    
    _speak(prompt_text)

func _check_continue_availability() -> void:
    # Continue available after at least one fragment placed OR after 10 seconds
    var has_placements = false
    for fragments in _placed_fragments.values():
        if fragments.size() > 0:
            has_placements = true
            break
    
    continue_btn.disabled = not has_placements
    if has_placements and not continue_btn.visible:
        continue_btn.visible = true
        if _should_animate:
            continue_btn.modulate.a = 0.0
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(continue_btn, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)

func _on_continue_pressed() -> void:
    _play_sfx("ui_click", 0.5)
    _vibrate(30)
    
    # Collect reconstruction data
    var data = {
        "placed_fragments": _placed_fragments.duplicate(true),
        "unplaced_fragments": _palette_fragments.keys(),
        "ghost_outlines": _ghost_outlines.map(func(g: Dictionary): return g.id),
        "moment_id": moment_definition.moment_id if moment_definition else ""
    }
    
    complete(data)

func _on_viewport_resized(size: Vector2) -> void:
    # Recreate ghost outlines at new positions
    _create_ghost_outlines()
    
    # Reposition placed fragments
    for ghost_id, fragments in _placed_fragments:
        var ghost = _find_ghost_by_id(ghost_id)
        if ghost:
            # Clear and recreate placed visuals
            for child in ghost.get_children():
                if child.name.begins_with("Placed_"):
                    child.queue_free()
            for frag_id in fragments:
                var frag_def = _find_fragment_def(frag_id)
                var placed = _create_placed_fragment(frag_def)
                ghost.add_child(placed)
                placed.position = Vector2(ghost.size.x * 0.5, ghost.size.y * 0.5)
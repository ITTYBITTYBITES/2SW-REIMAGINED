extends WitnessMomentPhase
class_name WitnessRevelationScreen

## Witness Revelation Phase — Dynamic archive entry builds from player's choices.
## Only what was carried. The moment preserved.

signal revelation_complete

const ARCHIVE_FRAME_PATH := "res://assets/gameplay/wm_archive_frame.png"

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var content: VBoxContainer = $ScrollContainer/Content
@onready var archive_entry: PanelContainer = $ScrollContainer/Content/ArchiveEntry
@onready var entry_title: Label = $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/EntryTitle
@onready var entry_meta: Label = $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/EntryMeta
@onready var carried_list: VBoxContainer = $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/CarriedSection/CarriedList
@onready var attunements_list: VBoxContainer = $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/AttunementsSection/AttunementsList
@onready var iris_note_text: Label = $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/IrisNoteSection/IrisNoteText
@onready var progress_label: Label = $ScrollContainer/Content/ProgressSection/ProgressLabel
@onready var continue_btn: Button = $ContinueButton

var _moment_data: Dictionary = {}
var _revelation_step: int = 0
var _archive_mapping: Dictionary = {}
var _reveal_image: TextureRect = null

func _ready() -> void:
    super._ready()
    phase_name = "revealing"
    _apply_archive_frame()
    
    # Style
    if ThemeService:
        var tokens = ThemeService.tokens
        
        # Archive entry panel
        var entry_style = StyleBoxFlat.new()
        entry_style.bg_color = Color(0.08, 0.09, 0.12, 0.9)
        entry_style.border_color = Color(0.3, 0.4, 0.5, 0.4)
        entry_style.border_width_left = 1
        entry_style.border_width_right = 1
        entry_style.border_width_top = 1
        entry_style.border_width_bottom = 1
        var radius = int(tokens.get("radius_lg", 20)) if not tokens.is_empty() else 20
        entry_style.corner_radius_top_left = radius
        entry_style.corner_radius_top_right = radius
        entry_style.corner_radius_bottom_left = radius
        entry_style.corner_radius_bottom_right = radius
        archive_entry.add_theme_stylebox_override("panel", entry_style)
        
        # Labels
        ThemeService.apply_label_style(entry_title, "display", "text_primary")
        entry_title.add_theme_font_size_override("font_size", 28)
        entry_title.add_theme_color_override("font_color", tokens.get("primary_variant", Color("#8A68FF")))
        
        ThemeService.apply_label_style(entry_meta, "caption", "text_tertiary")
        entry_meta.add_theme_font_size_override("font_size", 11)
        
        ThemeService.apply_label_style($ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/CarriedSection/CarriedLabel, "label_small", "primary_variant")
        $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/CarriedSection/CarriedLabel.add_theme_font_size_override("font_size", 12)
        
        ThemeService.apply_label_style($ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/AttunementsSection/AttunementsLabel, "label_small", "primary_variant")
        $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/AttunementsSection/AttunementsLabel.add_theme_font_size_override("font_size", 12)
        
        ThemeService.apply_label_style($ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/IrisNoteSection/IrisNoteLabel, "label_small", "primary_variant")
        $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/IrisNoteSection/IrisNoteLabel.add_theme_font_size_override("font_size", 12)
        
        ThemeService.apply_label_style(iris_note_text, "body", "text_secondary")
        iris_note_text.add_theme_font_size_override("font_size", 14)
        iris_note_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        ThemeService.apply_label_style(progress_label, "body_small", "primary_variant")
        progress_label.add_theme_font_size_override("font_size", 13)
    
    # Style continue button
    _style_continue_button()
    continue_btn.pressed.connect(_on_continue_pressed)
    continue_btn.visible = false
    
    # Separators styling
    for sep in [$ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/Divider1, 
                $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/Divider2,
                $ScrollContainer/Content/ArchiveEntry/EntryMargin/EntryVBox/Divider3]:
        if sep and ThemeService:
            sep.add_theme_color_override("separator_color", ThemeService.get_color("border", Color("#2E2E3A")))

func _apply_archive_frame() -> void:
    if not ResourceLoader.exists(ARCHIVE_FRAME_PATH):
        return
    var frame := TextureRect.new()
    frame.name = "ArchiveFrame"
    frame.texture = load(ARCHIVE_FRAME_PATH) as Texture2D
    frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    frame.modulate = Color(1.0, 1.0, 1.0, 0.32)
    archive_entry.add_child(frame)
    archive_entry.move_child(frame, 0)

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
    continue_btn.add_theme_color_override("font_color", Color.WHITE)
    if ThemeService:
        continue_btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))

func configure(definition: WitnessMoment) -> void:
    super.configure(definition)
    # Reconstruction and investigation data are passed via phase_data in orchestrator.
    # Keep the complete blueprint here for reveal imagery and archive lookups.
    _moment_data = definition.to_blueprint() if definition else {}
    _archive_mapping = definition.archive_mapping if definition else {}

func _on_begin() -> void:
    _try_load_reveal_image()
    _build_archive_entry_stepwise()

func _try_load_reveal_image() -> void:
    if is_instance_valid(_reveal_image):
        _reveal_image.free()
    _reveal_image = null

    var env = _moment_data.get("environment", {})
    var reveal_path = env.get("reveal_image", "")
    if reveal_path and ResourceLoader.exists(reveal_path):
        _reveal_image = TextureRect.new()
        _reveal_image.name = "MomentReveal"
        _reveal_image.texture = load(reveal_path) as Texture2D
        _reveal_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        _reveal_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        _reveal_image.custom_minimum_size = Vector2(0, 200)
        _reveal_image.modulate.a = 0.0
        _reveal_image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        _reveal_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
        # Insert before the archive entry
        content.add_child(_reveal_image)
        content.move_child(_reveal_image, 0)
        if _should_animate:
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(_reveal_image, "modulate:a", 0.85, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
        else:
            _reveal_image.modulate.a = 0.85

func _build_archive_entry_stepwise() -> void:
    _revelation_step = 0
    _clear_lists()
    
    # Set static entry data
    if moment_definition:
        entry_title.text = _archive_mapping.get("title", moment_definition.title).to_upper()
        entry_meta.text = "%s · %s · %s · %.1f seconds" % [
            moment_definition.moment_id,
            _archive_mapping.get("category", moment_definition.chapter_id),
            "7:47 AM",
            2.0
        ]
    
    # Start stepwise reveal
    _reveal_step()

func _reveal_step() -> void:
    _revelation_step += 1
    
    match _revelation_step:
        1:
            _reveal_carried_fragments()
        2:
            _reveal_attunements()
        3:
            _reveal_iris_note()
        4:
            _reveal_progress()
            _show_continue_button()
        _:
            pass
    
    # Schedule next step
    if _revelation_step < 4:
        get_tree().create_timer(1.2).timeout.connect(_reveal_step)

func _reveal_carried_fragments() -> void:
    _play_sfx("archive_entry_add", 0.5)
    
    var reconstruction_data = get_meta("reconstruction_data", {})
    var investigation_data = get_meta("investigation_data", {})
    
    var placed = reconstruction_data.get("placed_fragments", {})
    var unplaced = reconstruction_data.get("unplaced_fragments", [])
    var all_fragments = _moment_data.get("reconstruction", {}).get("fragment_palette", [])
    
    var fragment_lookup = {}
    for f in all_fragments:
        fragment_lookup[f.id] = f
    
    # Show carried (placed) fragments
    var has_any = false
    for ghost_id, fragments in placed:
        for frag_id in fragments:
            has_any = true
            var frag_def = fragment_lookup.get(frag_id, {})
            var item = _create_carried_item(frag_def, true)
            carried_list.add_child(item)
            item.modulate.a = 0.0
            if _should_animate:
                var tween = create_tween()
                tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
                tween.tween_property(item, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT).set_delay(carried_list.get_child_count() * 0.15)
            else:
                item.modulate.a = 1.0
    
    # Show unplaced as faded
    for frag_id in unplaced:
        var frag_def = fragment_lookup.get(frag_id, {})
        var item = _create_carried_item(frag_def, false)
        carried_list.add_child(item)
        item.modulate.a = 0.0
        if _should_animate:
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(item, "modulate:a", 0.35, 0.4).set_ease(Tween.EASE_OUT).set_delay(carried_list.get_child_count() * 0.15)
        else:
            item.modulate.a = 0.35

func _create_carried_item(frag_def: Dictionary, carried: bool) -> HBoxContainer:
    var item = HBoxContainer.new()
    item.alignment = BOX_ALIGNMENT_CENTER
    
    var checkbox = TextureRect.new()
    checkbox.custom_minimum_size = Vector2(24, 24)
    checkbox.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    checkbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    
    # Use unicode checkbox chars via label instead
    var check_label = Label.new()
    check_label.custom_minimum_size = Vector2(28, 28)
    check_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    check_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    check_label.add_theme_font_size_override("font_size", 18)
    if carried:
        check_label.text = "☑"
        check_label.add_theme_color_override("font_color", ThemeService.get_color("success") if ThemeService else Color("#4ADE80"))
    else:
        check_label.text = "☐"
        check_label.add_theme_color_override("font_color", ThemeService.get_color("text_tertiary") if ThemeService else Color("#6B7280"))
    item.add_child(check_label)
    
    var icon_label = Label.new()
    icon_label.text = frag_def.get("icon", "•")
    icon_label.custom_minimum_size = Vector2(28, 28)
    icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    icon_label.add_theme_font_size_override("font_size", 20)
    item.add_child(icon_label)
    
    var text_label = Label.new()
    text_label.text = frag_def.get("label", frag_def.get("id", "Unknown"))
    text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if ThemeService:
        ThemeService.apply_label_style(text_label, "body", "text_primary" if carried else "text_secondary")
    text_label.add_theme_font_size_override("font_size", 14)
    if not carried:
        text_label.modulate.a = 0.5
    item.add_child(text_label)
    
    return item

func _reveal_attunements() -> void:
    _play_sfx("archive_entry_add", 0.5)
    
    var investigation_data = get_meta("investigation_data", {})
    
    var completed = investigation_data.get("completed_attunements", [])
    var all_attunements = _moment_data.get("investigation", {}).get("attunements", [])
    
    var attunement_lookup = {}
    for a in all_attunements:
        attunement_lookup[a.object] = a
    
    for att_id in completed:
        var att_data = attunement_lookup.get(att_id, {})
        var item = _create_attunement_item(att_data)
        attunements_list.add_child(item)
        item.modulate.a = 0.0
        if _should_animate:
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(item, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT).set_delay(attunements_list.get_child_count() * 0.15)
        else:
            item.modulate.a = 1.0
    
    # Show count
    var total = all_attunements.size()
    var label = Label.new()
    label.text = "%d of %d attunements carried" % [completed.size(), total]
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    if ThemeService:
        ThemeService.apply_label_style(label, "caption", "text_tertiary")
    label.add_theme_font_size_override("font_size", 11)
    attunements_list.add_child(label)

func _create_attunement_item(att_data: Dictionary) -> HBoxContainer:
    var item = HBoxContainer.new()
    item.alignment = BOX_ALIGNMENT_CENTER
    
    var type_icons = {
        "thermal": "🌡️",
        "skeletal": "🦴",
        "text": "📝",
        "forensic": "🔬",
        "trajectory": "✨",
        "spectral": "🌈"
    }
    
    var icon_label = Label.new()
    icon_label.text = type_icons.get(att_data.type, "•")
    icon_label.custom_minimum_size = Vector2(28, 28)
    icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    icon_label.add_theme_font_size_override("font_size", 20)
    item.add_child(icon_label)
    
    var text_label = Label.new()
    var obj_name := str(att_data.get("object", "Artifact")).replace("_", " ").capitalize()
    var type_name := str(att_data.get("type", "attunement")).capitalize()
    text_label.text = "%s (%s)" % [obj_name, type_name]
    text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    if ThemeService:
        ThemeService.apply_label_style(text_label, "body", "text_primary")
    text_label.add_theme_font_size_override("font_size", 14)
    item.add_child(text_label)
    
    return item

func _reveal_iris_note() -> void:
    _play_sfx("iris_note", 0.6)
    
    var note = _archive_mapping.get("iris_note", 
        "The cup was never meant to be drunk. It was meant to be witnessed cooling.")
    
    iris_note_text.text = note
    iris_note_text.visible = true
    iris_note_text.modulate.a = 0.0
    
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(iris_note_text, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
    else:
        iris_note_text.modulate.a = 1.0
    
    _speak(note)

func _reveal_progress() -> void:
    _play_sfx("progress_reveal", 0.5)
    
    if moment_definition:
        var rewards = moment_definition.rewards
        var progress_points = rewards.get("progress_points", 0)
        var mastery = rewards.get("mastery", {})
        var achievements = rewards.get("achievements", [])
        
        var lines = []
        if progress_points > 0:
            lines.append("+%d Insight" % progress_points)
        for family, value in mastery:
            lines.append("%s awareness deepened +%.0f%%" % [family.capitalize(), value * 100])
        for ach in achievements:
            lines.append("Memory preserved: %s" % ach.replace("_", " ").capitalize())
        
        progress_label.text = "\n".join(lines)
        progress_label.visible = true
        progress_label.modulate.a = 0.0
        
        if _should_animate:
            var tween = create_tween()
            tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
            tween.tween_property(progress_label, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
        else:
            progress_label.modulate.a = 1.0

func _show_continue_button() -> void:
    continue_btn.visible = true
    continue_btn.modulate.a = 0.0
    if _should_animate:
        var tween = create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(continue_btn, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    else:
        continue_btn.modulate.a = 1.0

func _clear_lists() -> void:
    for child in carried_list.get_children():
        child.queue_free()
    for child in attunements_list.get_children():
        child.queue_free()
    iris_note_text.visible = false
    progress_label.visible = false

func _on_continue_pressed() -> void:
    _play_sfx("ui_click", 0.5)
    _vibrate(30)
    
    var data = {
        "archive_entry": _archive_mapping.get("title", "First Attention Field"),
        "moment_id": moment_definition.moment_id if moment_definition else "",
        "rewards": moment_definition.rewards if moment_definition else {}
    }
    
    complete(data)
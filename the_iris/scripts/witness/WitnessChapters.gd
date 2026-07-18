extends Control
class_name WitnessChapters

## Displays Chapter 01 and plays each of the five completed Witness Moments.
signal home_requested
signal generic_moment_requested(moment_id: String)

var registry: IncidentRegistry
var director: WitnessExperienceDirector
var orchestrator: WitnessMomentOrchestrator
var background: TextureRect
var panel: ColorRect
var phase_label: Label
var title_label: Label
var subtitle_label: Label
var body_label: Label
var actions: Control
var scroll_container: ScrollContainer
var chapter_list: VBoxContainer
var back_button: Button
var attuned: Dictionary = {}
var in_chapters := true

func configure(value_registry: IncidentRegistry, value_director: WitnessExperienceDirector, value_orchestrator: WitnessMomentOrchestrator) -> void:
	registry = value_registry
	director = value_director
	orchestrator = value_orchestrator
	if not orchestrator.phase_changed.is_connected(_on_phase_changed):
		orchestrator.phase_changed.connect(_on_phase_changed)
	if not orchestrator.moment_completed.is_connected(_on_moment_completed):
		orchestrator.moment_completed.connect(_on_moment_completed)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.52, 0.70, 0.66, 0.42)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var veil := ColorRect.new()
	veil.color = Color(0.01, 0.05, 0.06, 0.62)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	back_button = _button("‹  IRIS HOME", Vector2(25, 28), Vector2(150, 36), Color("#143e3b"), 12)
	back_button.pressed.connect(_back)
	phase_label = _label("WITNESS CHAPTERS", 11, Color("#88cbb9"), Vector2(33, 86), Vector2(440, 24))
	title_label = _label("Chapter 01", 27, Color("#f1fff9"), Vector2(32, 115), Vector2(460, 47))
	subtitle_label = _label("Learning to Notice", 14, Color("#b7dcd1"), Vector2(33, 164), Vector2(460, 27))
	body_label = _label("", 15, Color("#d7eee7"), Vector2(33, 207), Vector2(470, 150))
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	panel = ColorRect.new()
	panel.position = Vector2(20, 385)
	panel.size = Vector2(500, 525)
	panel.color = Color(0.025, 0.105, 0.11, 0.92)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	scroll_container = ScrollContainer.new()
	scroll_container.position = Vector2(38, 407)
	scroll_container.size = Vector2(464, 310)
	add_child(scroll_container)

	chapter_list = VBoxContainer.new()
	chapter_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapter_list.add_theme_constant_override("separation", 11)
	scroll_container.add_child(chapter_list)

	actions = Control.new()
	actions.position = Vector2(38, 736)
	actions.size = Vector2(464, 160)
	add_child(actions)
	show_chapters()

func show_chapters() -> void:
	in_chapters = true
	background.texture = null
	background.modulate = Color(1, 1, 1, 0)
	phase_label.text = "WITNESS CHAPTER 01"
	title_label.text = "Learning to Notice"
	subtitle_label.text = "Five completed recollections"
	body_label.text = "Choose any completed Witness Moment. Each can be revisited from its first arrival to its final revelation."
	panel.position = Vector2(20, 338)
	panel.size = Vector2(500, 572)
	scroll_container.visible = true
	scroll_container.position = Vector2(38, 362)
	scroll_container.size = Vector2(464, 520)
	_clear_actions()
	for child in chapter_list.get_children():
		child.queue_free()
	for moment in director.chapter_moments():
		var id := str(moment.get("id", ""))
		var button_text := "%s  ·  %s" % [id, str(moment.get("title", "Untitled"))]
		if registry.is_completed(id):
			button_text += "   ✓ WITNESSED"
		var card := _button(button_text, Vector2.ZERO, Vector2(464, 67), Color("#174943"), 13, false)
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		card.pressed.connect(open_moment.bind(id))
		chapter_list.add_child(card)

func open_moment(moment_id: String) -> void:
	if moment_id in ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005", "WM_TEST", "WM_ASSET_TEST", "WM_006", "WM_007", "WM_008", "WM_009", "WM_010", "WM_011", "WM_012"]:
		generic_moment_requested.emit(moment_id)
		return
	var launch := director.launch(moment_id)
	if launch.is_empty():
		return
	in_chapters = false
	attuned.clear()
	scroll_container.visible = false
	orchestrator.start(launch)

func _on_phase_changed(_phase: WitnessMomentOrchestrator.Phase, moment: Dictionary) -> void:
	if moment.is_empty():
		return
	present_phase(moment)

func present_phase(moment: Dictionary) -> void:
	var phase := orchestrator.phase_name()
	phase_label.text = "%s  ·  %s" % [moment.get("id", ""), phase]
	title_label.text = str(moment.get("title", ""))
	subtitle_label.text = str(moment.get("subtitle", ""))
	panel.position = Vector2(20, 511)
	panel.size = Vector2(500, 399)
	background.modulate = Color(1, 1, 1, 0.84)
	_clear_actions()

	match phase:
		"ARRIVING":
			background.texture = load(str(moment.get("background", "")))
			body_label.text = str(moment.get("introduction", ""))
			_add_action("BEGIN OBSERVATION", _advance)
		"OBSERVING":
			background.texture = load(str(moment.get("action", "")))
			body_label.text = "Observe the two-second moment.\n\n%s" % str(moment.get("observation", ""))
			_add_action("CARRY WHAT YOU NOTICED", _advance)
		"RECONSTRUCTING":
			background.texture = load(str(moment.get("background", "")))
			body_label.text = str(moment.get("reconstruction", ""))
			_add_action("RECONSTRUCTION HELD", _advance)
		"INVESTIGATING":
			background.texture = load(str(moment.get("background", "")))
			body_label.text = "Attune to the details that change the recollection."
			_show_attunements(moment)
		"REVEALING":
			background.texture = load(str(moment.get("reveal", "")))
			body_label.text = "“%s”" % str(moment.get("revelation", ""))
			_add_action("COMPLETE WITNESS MOMENT", _advance)

func _show_attunements(moment: Dictionary) -> void:
	var details: Array = moment.get("attunements", [])
	for index in range(details.size()):
		var text := str(details[index])
		var prefix := "✓ " if attuned.has(index) else "ATTUNE  ·  "
		_add_action(prefix + text, _attune.bind(index, details.size()), 11)

func _attune(index: int, total: int) -> void:
	attuned[index] = true
	if attuned.size() >= total:
		_clear_actions()
		_add_action("CONTINUE TO REVELATION", _advance)
		return
	var moment := orchestrator.current_moment()
	_clear_actions()
	_show_attunements(moment)

func _on_moment_completed(moment_id: String) -> void:
	registry.mark_completed(moment_id)
	orchestrator.cancel()
	show_chapters()

func _advance() -> void:
	orchestrator.advance()

func _back() -> void:
	if in_chapters:
		home_requested.emit()
	else:
		orchestrator.cancel()
		show_chapters()

func _clear_actions() -> void:
	for child in actions.get_children():
		child.queue_free()

func _add_action(text_value: String, callback: Callable, font_size := 13) -> void:
	var button := _button(text_value, Vector2(0, actions.get_child_count() * 50), Vector2(464, 44), Color("#286e61"), font_size, false)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(callback)
	actions.add_child(button)

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(text_value: String, position_value: Vector2, size_value: Vector2, color: Color, font_size: int, attach := true) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#f3fff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 7
	normal.corner_radius_top_right = 7
	normal.corner_radius_bottom_left = 7
	normal.corner_radius_bottom_right = 7
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	if attach:
		add_child(button)
	return button

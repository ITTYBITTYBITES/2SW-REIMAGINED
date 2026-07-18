extends Control
class_name IrisHome

## The Iris-centered archive overlay. The one real destination lives in MemoryField.
signal continue_witness_requested
signal iris_requested
signal memory_intent_focused(normalized_target: Vector2)
signal memory_intent_released
signal memory_selected
signal archive_requested

var elapsed := 0.0
var atmosphere_redraw_in := 0.0
var memory_field: MemoryField
var journey_stat_label: Label
var discoveries_stat_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# The field is above the settled Iris, but below contextual archive language.
	memory_field = MemoryField.new()
	memory_field.name = "MemoryField"
	memory_field.intent_focused.connect(memory_intent_focused.emit)
	memory_field.intent_released.connect(memory_intent_released.emit)
	memory_field.continue_selected.connect(_on_continue_witness_selected)
	add_child(memory_field)

	_label("THE WITNESS ARCHIVE", 11, Color("#86b9ad"), Vector2(28, 28), Vector2(270, 22))
	_label("Between moments", 25, Color("#e9faf4"), Vector2(28, 51), Vector2(330, 42))
	var introduction := _label("A quiet field where the Iris keeps what attention carried.", 14, Color("#9bc2b7"), Vector2(28, 97), Vector2(350, 44))
	introduction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var rest_button := _text_button("REST WITH IRIS", Vector2(377, 30), Vector2(135, 28))
	rest_button.name = "RestWithIris"
	rest_button.pressed.connect(iris_requested.emit)

	var archive_button := _text_button("OPEN ARCHIVE", Vector2(377, 65), Vector2(135, 28))
	archive_button.name = "OpenArchive"
	archive_button.pressed.connect(archive_requested.emit)

	_label("MEMORY FIELD", 10, Color("#7fbcae"), Vector2(28, 648), Vector2(240, 20))
	_label("One living thread is close enough to follow.", 14, Color("#d7eee7"), Vector2(28, 668), Vector2(430, 24))

	_label("JOURNEY", 10, Color("#86b9ad"), Vector2(28, 742), Vector2(220, 18))
	journey_stat_label = _label("Aperture 1 · Observer\n0 Resonance", 11, Color("#a9c9be"), Vector2(28, 760), Vector2(220, 34))
	
	_label("DISCOVERIES", 10, Color("#86b9ad"), Vector2(290, 742), Vector2(220, 18))
	discoveries_stat_label = _label("0 / 6 Restored\nMastery: Observer", 11, Color("#a9c9be"), Vector2(290, 760), Vector2(220, 34))

	_label("The archive keeps only what attention carried.", 11, Color("#668e85"), Vector2(24, 889), Vector2(492, 22), HORIZONTAL_ALIGNMENT_CENTER)

func _on_continue_witness_selected() -> void:
	memory_selected.emit()
	continue_witness_requested.emit()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	atmosphere_redraw_in -= delta
	if atmosphere_redraw_in <= 0.0:
		# The archive atmosphere moves at a deliberate, low-frequency cadence.
		atmosphere_redraw_in = 0.12
		queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	# A translucent field leaves the actual Living Iris visible beneath the hub.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.002, 0.015, 0.021, 0.32))
	var center := Vector2(size.x * 0.5, size.y * 0.46)
	for ring in range(5, 0, -1):
		var amount := float(ring) / 5.0
		var pulse := sin(elapsed * 0.09 + amount * 1.7) * 0.5 + 0.5
		var radius := minf(size.x, size.y) * (0.18 + amount * 0.11)
		draw_circle(center + Vector2(0, 12), radius, Color(0.03, 0.22, 0.20, (0.010 + pulse * 0.007) * (1.0 - amount * 0.38)))

	# Archive marks frame the lens without becoming a button grid.
	for index in range(4):
		var x := 24.0 + float(index) * 7.0
		var length := 90.0 + sin(elapsed * 0.14 + float(index)) * 6.0
		draw_line(Vector2(x, 165), Vector2(x, 165 + length), Color(0.25, 0.62, 0.56, 0.10), 1.0, true)
		draw_line(Vector2(size.x - x, 165), Vector2(size.x - x, 165 + length), Color(0.25, 0.62, 0.56, 0.10), 1.0, true)
	draw_line(Vector2(24, 721), Vector2(size.x - 24, 721), Color(0.28, 0.67, 0.59, 0.08), 1.0, true)
	draw_line(Vector2(size.x * 0.5, 742), Vector2(size.x * 0.5, 800), Color(0.28, 0.67, 0.59, 0.07), 1.0, true)
	for index in range(3):
		var y := 873.0 + float(index) * 8.0
		draw_line(Vector2(24, y), Vector2(size.x - 24, y), Color(0.28, 0.67, 0.59, 0.055), 1.0, true)

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _text_button(text_value: String, position_value: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.flat = true
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("#8fc8b8"))
	button.add_theme_color_override("font_hover_color", Color("#ddfff3"))
	button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(button)
	return button

func update_profile_presentation(profile: WitnessProfile) -> void:
	if profile == null:
		return
	if journey_stat_label != null:
		journey_stat_label.text = "Aperture %d · %s\n%d Resonance" % [profile.aperture_rank, profile.aperture_title, profile.resonance]
	if discoveries_stat_label != null:
		var completed_count := profile.completed_moment_ids.size()
		discoveries_stat_label.text = "%d / 6 Restored\nMastery: %s" % [completed_count, profile.aperture_title]

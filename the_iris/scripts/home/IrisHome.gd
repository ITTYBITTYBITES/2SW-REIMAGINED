extends Control
class_name IrisHome

## The archive environment surrounding the single settled Living Iris.
signal witness_requested
signal iris_requested

var elapsed := 0.0
var atmosphere_redraw_in := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_label("THE WITNESS ARCHIVE", 11, Color("#86b9ad"), Vector2(28, 28), Vector2(270, 22))
	_label("Between moments", 25, Color("#e9faf4"), Vector2(28, 51), Vector2(330, 42))
	var introduction := _label("A quiet field where the Iris keeps what attention carried.", 14, Color("#9bc2b7"), Vector2(28, 97), Vector2(350, 44))
	introduction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var rest_button := _text_button("REST WITH IRIS", Vector2(377, 30), Vector2(135, 28))
	rest_button.name = "RestWithIris"
	rest_button.pressed.connect(iris_requested.emit)

	_label("WITNESS ARCHIVE", 10, Color("#7fbcae"), Vector2(28, 613), Vector2(240, 22))
	_label("The first chapter is waiting in the light.", 14, Color("#d7eee7"), Vector2(28, 633), Vector2(430, 24))

	var continue_card := _archive_card(Vector2(24, 663), Vector2(492, 88), Color("#123936"), true)
	continue_card.name = "ContinueWitnessCard"
	_card_label(continue_card, "CONTINUE WITNESS", 10, Color("#91d1bf"), Vector2(18, 10), Vector2(280, 18))
	_card_label(continue_card, "Chapter 01 · Learning to Notice", 18, Color("#f1fff9"), Vector2(18, 27), Vector2(330, 28))
	_card_label(continue_card, "WM_001–WM_005 · five recollections held", 12, Color("#afcfc5"), Vector2(18, 57), Vector2(330, 20))
	_card_label(continue_card, "OPEN  →", 11, Color("#bff4df"), Vector2(378, 34), Vector2(92, 22), HORIZONTAL_ALIGNMENT_RIGHT)
	_card_hit_area(continue_card, witness_requested.emit)

	var journey_card := _archive_card(Vector2(24, 765), Vector2(234, 94), Color("#0d2929"), false)
	_card_label(journey_card, "JOURNEY", 10, Color("#86b9ad"), Vector2(16, 12), Vector2(180, 18))
	_card_label(journey_card, "Progress takes shape", 15, Color("#e4f6ef"), Vector2(16, 31), Vector2(198, 24))
	_card_label(journey_card, "Each return will deepen the record.", 11, Color("#95b9ae"), Vector2(16, 57), Vector2(198, 24))

	var discoveries_card := _archive_card(Vector2(282, 765), Vector2(234, 94), Color("#0d2929"), false)
	_card_label(discoveries_card, "DISCOVERIES", 10, Color("#86b9ad"), Vector2(16, 12), Vector2(180, 18))
	_card_label(discoveries_card, "A shared record", 15, Color("#e4f6ef"), Vector2(16, 31), Vector2(198, 24))
	_card_label(discoveries_card, "Discoveries will gather with the Iris.", 11, Color("#95b9ae"), Vector2(16, 57), Vector2(198, 24))

	_label("The archive keeps only what attention carried.", 11, Color("#668e85"), Vector2(24, 889), Vector2(492, 22), HORIZONTAL_ALIGNMENT_CENTER)

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
	# A translucent archive field leaves the actual Living Iris visible beneath it.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.002, 0.015, 0.021, 0.32))
	var center := Vector2(size.x * 0.5, size.y * 0.46)
	for ring in range(5, 0, -1):
		var amount := float(ring) / 5.0
		var pulse := sin(elapsed * 0.09 + amount * 1.7) * 0.5 + 0.5
		var radius := minf(size.x, size.y) * (0.18 + amount * 0.11)
		draw_circle(center + Vector2(0, 12), radius, Color(0.03, 0.22, 0.20, (0.010 + pulse * 0.007) * (1.0 - amount * 0.38)))

	# Archive marks frame the lens without becoming a navigation grid.
	for index in range(4):
		var x := 24.0 + float(index) * 7.0
		var length := 90.0 + sin(elapsed * 0.14 + float(index)) * 6.0
		draw_line(Vector2(x, 165), Vector2(x, 165 + length), Color(0.25, 0.62, 0.56, 0.10), 1.0, true)
		draw_line(Vector2(size.x - x, 165), Vector2(size.x - x, 165 + length), Color(0.25, 0.62, 0.56, 0.10), 1.0, true)
	for index in range(3):
		var y := 873.0 + float(index) * 8.0
		draw_line(Vector2(24, y), Vector2(size.x - 24, y), Color(0.28, 0.67, 0.59, 0.055), 1.0, true)

func _archive_card(position_value: Vector2, size_value: Vector2, color: Color, featured: bool) -> Panel:
	var card := Panel.new()
	card.position = position_value
	card.size = size_value
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#2f7066") if featured else Color("#1d514c")
	style.set_border_width_all(1)
	style.corner_radius_top_left = 13
	style.corner_radius_top_right = 13
	style.corner_radius_bottom_left = 13
	style.corner_radius_bottom_right = 13
	style.shadow_color = Color(0, 0, 0, 0.24)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	card.add_theme_stylebox_override("panel", style)
	add_child(card)
	return card

func _card_label(parent: Control, text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _card_hit_area(parent: Control, action: Callable) -> void:
	var hit_area := Button.new()
	hit_area.name = "ArchiveAction"
	hit_area.flat = true
	hit_area.position = Vector2.ZERO
	hit_area.size = parent.size
	hit_area.mouse_filter = Control.MOUSE_FILTER_STOP
	var normal := StyleBoxEmpty.new()
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.26, 0.72, 0.63, 0.10)
	hover.corner_radius_top_left = 13
	hover.corner_radius_top_right = 13
	hover.corner_radius_bottom_left = 13
	hover.corner_radius_bottom_right = 13
	hit_area.add_theme_stylebox_override("normal", normal)
	hit_area.add_theme_stylebox_override("hover", hover)
	hit_area.pressed.connect(action)
	parent.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(hit_area)

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

extends Control
class_name SpatialHub

## Retained Iris home/navigation presentation after the Witness runtime reset.
## It intentionally exposes one inactive Witness entry rather than old content.
signal witness_requested
signal profile_requested

var elapsed := 0.0
var profile: WitnessProfile
var status_label: Label
var hint_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var witness_button := _button("WITNESS", Vector2(28, 26), Vector2(230, 32))
	witness_button.pressed.connect(witness_requested.emit)
	var profile_button := _button("PROFILE", Vector2(282, 26), Vector2(230, 32))
	profile_button.pressed.connect(profile_requested.emit)
	_label("THE IRIS", 11, Color("#8ac8b9"), Vector2(28, 92), Vector2(220, 20))
	_label("A quiet field between remembered things.", 24, Color("#effff8"), Vector2(28, 116), Vector2(470, 45))
	hint_label = _label("A memory has lost one second.", 14, Color("#cce8df"), Vector2(28, 624), Vector2(484, 28))
	status_label = _label("THE IRIS IS LISTENING", 11, Color("#86b9ad"), Vector2(28, 738), Vector2(484, 24), HORIZONTAL_ALIGNMENT_CENTER)
	_label("The Iris remains open.", 11, Color("#668e85"), Vector2(24, 889), Vector2(492, 22), HORIZONTAL_ALIGNMENT_CENTER)

func configure(value_profile: WitnessProfile) -> void:
	profile = value_profile
	if status_label != null:
		status_label.text = "THE IRIS IS LISTENING" if profile == null else "THE IRIS IS LISTENING · %s" % profile.witness_name

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.002, 0.015, 0.021, 0.29))
	var center := Vector2(size.x * 0.5, size.y * 0.458)
	for index in range(4, 0, -1):
		var pulse := sin(elapsed * 0.22 + float(index)) * 0.5 + 0.5
		draw_arc(center, 130.0 + float(index) * 42.0, 0.0, TAU, 60, Color(0.14, 0.64, 0.54, 0.018 + pulse * 0.012), 1.0, true)

func _button(text_value: String, position_value: Vector2, size_value: Vector2) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.flat = true
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("#91cbbd"))
	button.add_theme_color_override("font_hover_color", Color("#e3fff5"))
	add_child(button)
	return button

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

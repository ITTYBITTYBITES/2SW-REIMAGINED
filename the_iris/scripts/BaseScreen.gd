extends Control
class_name BaseScreen

const BG := Color("#081019")
const INK := Color("#dff4ee")
const MUTED := Color("#7da39e")
const DIM := Color("#42615f")
const TEAL := Color("#63c8b2")
const AMBER := Color("#d1a866")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_on_viewport_resized(get_viewport_rect().size)

func _on_viewport_resized(_size: Vector2) -> void:
	pass

func make_label(text_value: String, font_size: int, color: Color, pos: Vector2, box: Vector2, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = box
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func add_rule(y: float, color := Color("#234343"), left := 34.0, right := 686.0) -> ColorRect:
	var rule := ColorRect.new()
	rule.position = Vector2(left, y)
	rule.size = Vector2(right - left, 1.0)
	rule.color = color
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rule)
	return rule

func add_back_label(label_text := "←  THE IRIS") -> Label:
	return make_label(label_text, 14, MUTED, Vector2(30, 34), Vector2(250, 32))

func clear_dynamic() -> void:
	for child in get_children():
		if child is Label or child is ColorRect:
			child.queue_free()

extends Control
class_name IrisHome

## The prototype's only destination screen. It keeps navigation deliberately
## narrow: return to the Iris or enter the available Witness Chapter.
signal witness_requested
signal iris_requested

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color("#08191b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	_label("IRIS HOME", 15, Color("#e6fbf4"), Vector2(32, 43), Vector2(400, 30))
	_label("THE LIVING INSTRUMENT IS AWAKE", 10, Color("#6fa497"), Vector2(32, 73), Vector2(430, 22))
	_label("Where attention settles", 29, Color("#d9f6eb"), Vector2(32, 168), Vector2(470, 56))
	var copy := _label("The Iris has opened the first Witness Chapter. Five completed moments are ready to revisit.", 16, Color("#a5c9bf"), Vector2(32, 235), Vector2(465, 72))
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var chapter_card := ColorRect.new()
	chapter_card.position = Vector2(32, 360)
	chapter_card.size = Vector2(476, 204)
	chapter_card.color = Color("#103331")
	chapter_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(chapter_card)
	_label("WITNESS CHAPTER 01", 11, Color("#80c9b6"), Vector2(56, 385), Vector2(390, 25))
	_label("Learning to Notice", 23, Color("#effff8"), Vector2(56, 416), Vector2(390, 40))
	var chapter_copy := _label("WM_001–WM_005 · Five complete recollections", 14, Color("#aed4c8"), Vector2(56, 462), Vector2(390, 34))
	chapter_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var witness_button := _button("ENTER WITNESS CHAPTERS", Vector2(56, 510), Vector2(428, 42), Color("#2c7e6b"))
	witness_button.pressed.connect(witness_requested.emit)
	var iris_button := _button("RETURN TO THE LIVING IRIS", Vector2(56, 650), Vector2(428, 46), Color("#173f3b"))
	iris_button.pressed.connect(iris_requested.emit)
	_label("Five complete recollections are ready to revisit", 11, Color("#5f8980"), Vector2(32, 823), Vector2(476, 25), HORIZONTAL_ALIGNMENT_CENTER)

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

func _button(text_value: String, position_value: Vector2, size_value: Vector2, color: Color) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = position_value
	button.size = size_value
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color("#effff9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	add_child(button)
	return button

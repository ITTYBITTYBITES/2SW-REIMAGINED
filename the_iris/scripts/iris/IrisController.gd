extends Control
class_name IrisController

## Presentation and navigation presence for the Living Iris.
signal home_requested

var iris_core: IrisCore
var living_iris: LivingIris
var presence: Label
var invitation: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.color = Color("#061316")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	iris_core = IrisCore.new()
	iris_core.name = "IrisCore"
	add_child(iris_core)
	living_iris = LivingIris.new()
	living_iris.name = "LivingIris"
	living_iris.set_core(iris_core)
	add_child(living_iris)

	presence = _label("THE IRIS", 16, Color("#dff9ef"), Vector2(30, 31), Vector2(400, 30))
	_label("A LIVING PERCEPTION INSTRUMENT", 10, Color("#74a99c"), Vector2(31, 58), Vector2(420, 22))
	invitation = _label("touch the iris to enter", 15, Color("#b9e9d9"), Vector2(30, 736), Vector2(480, 34), HORIZONTAL_ALIGNMENT_CENTER)
	_label("HOME  ·  WITNESS CHAPTERS", 11, Color("#6b9389"), Vector2(30, 774), Vector2(480, 24), HORIZONTAL_ALIGNMENT_CENTER)

func appear() -> void:
	visible = true
	iris_core.transition_to(IrisCore.State.AWARE)
	invitation.text = "touch the iris to enter"

func settle() -> void:
	iris_core.transition_to(IrisCore.State.SETTLED)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		iris_core.transition_to(IrisCore.State.FOCUSED)
		home_requested.emit()
	elif event is InputEventScreenTouch and event.pressed:
		iris_core.transition_to(IrisCore.State.FOCUSED)
		home_requested.emit()

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

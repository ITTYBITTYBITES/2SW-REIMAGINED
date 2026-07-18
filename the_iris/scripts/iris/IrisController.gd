extends Control
class_name IrisController

## Owns the current Iris screen and translates a deliberate Iris interaction
## into the existing Home navigation request.
signal home_requested

const ATTENTION_HOLD_SECONDS := 0.56

var iris_core: IrisCore
var living_iris: LivingIris
var brand_label: Label
var invitation: Label
var state_label: Label
var navigation_label: Label
var home_request_in := -1.0
var attention_locked := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.color = Color("#030a0d")
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

	brand_label = _label("THE IRIS", 16, Color("#e2faf1"), Vector2(30, 31), Vector2(400, 30))
	state_label = _label("A LIVING PERCEPTION INSTRUMENT", 10, Color("#6f9e92"), Vector2(31, 58), Vector2(420, 22))
	invitation = _label("the iris is listening", 15, Color("#bde8d9"), Vector2(30, 736), Vector2(480, 34), HORIZONTAL_ALIGNMENT_CENTER)
	navigation_label = _label("HOME  ·  WITNESS CHAPTERS", 11, Color("#668d84"), Vector2(30, 774), Vector2(480, 24), HORIZONTAL_ALIGNMENT_CENTER)
	iris_core.state_changed.connect(_on_state_changed)

func _process(delta: float) -> void:
	if home_request_in < 0.0:
		return
	home_request_in -= delta
	if home_request_in <= 0.0:
		home_request_in = -1.0
		attention_locked = false
		home_requested.emit()

func dormant() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.DORMANT)
	invitation.text = "the iris is listening"

func calibrate() -> void:
	_cancel_attention()
	visible = true
	iris_core.transition_to(IrisCore.State.CALIBRATING)
	invitation.text = "the instrument calibrates"

func welcome() -> void:
	_cancel_attention()
	visible = true
	iris_core.transition_to(IrisCore.State.WELCOMING)
	invitation.text = "touch the iris to enter"

## Direct Iris Home integration: the existing Iris becomes a non-interactive
## settled presence behind the archive environment. No second renderer exists.
func set_home_environment(active: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if active else Control.MOUSE_FILTER_STOP
	brand_label.visible = not active
	state_label.visible = not active
	invitation.visible = not active
	navigation_label.visible = not active

func observe() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.OBSERVING)

func settle() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.SETTLED)

func reflect() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.REFLECTIVE)

func _gui_input(event: InputEvent) -> void:
	if attention_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		_begin_attention(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_begin_attention(event.position)

func _begin_attention(position: Vector2) -> void:
	attention_locked = true
	var safe_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	var normalized_target := (position - safe_size * 0.5) / safe_size
	iris_core.acquire_attention(normalized_target)
	invitation.text = "attention acquired"
	home_request_in = ATTENTION_HOLD_SECONDS

func _cancel_attention() -> void:
	home_request_in = -1.0
	attention_locked = false

func _on_state_changed(next_state: IrisCore.State) -> void:
	state_label.text = _presence_line(next_state)
	match next_state:
		IrisCore.State.STIRRING:
			invitation.text = "something stirs"
		IrisCore.State.AWAKENING:
			invitation.text = "attention wakes the instrument"
		IrisCore.State.WELCOMING:
			invitation.text = "touch the iris to enter"
		IrisCore.State.AWARE:
			invitation.text = "the iris is ready"
		IrisCore.State.FOCUSED:
			invitation.text = "attention acquired"
		IrisCore.State.OBSERVING:
			invitation.text = "attention is held"
		IrisCore.State.REFLECTIVE:
			invitation.text = "what was noticed remains"

func _presence_line(next_state: IrisCore.State) -> String:
	match next_state:
		IrisCore.State.CALIBRATING:
			return "THE FIELD BEGINS TO FORM"
		IrisCore.State.STIRRING:
			return "SOMETHING NOTICES"
		IrisCore.State.AWAKENING:
			return "ATTENTION TAKES SHAPE"
		IrisCore.State.WELCOMING:
			return "THE IRIS IS OPEN"
		IrisCore.State.AWARE:
			return "THE IRIS IS AWARE"
		IrisCore.State.ATTENDING:
			return "ATTENTION ACQUIRED"
		IrisCore.State.FOCUSED:
			return "FOCUS HELD"
		IrisCore.State.OBSERVING:
			return "WITNESSING"
		IrisCore.State.SETTLED:
			return "THE FIELD SETTLES"
		IrisCore.State.REFLECTIVE:
			return "THE MOMENT REMAINS"
	return "A LIVING PERCEPTION INSTRUMENT"

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

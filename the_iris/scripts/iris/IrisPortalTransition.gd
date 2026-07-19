extends Control
class_name IrisPortalTransition

## Mission 054C — a short, authored passage through the one Living Iris.
## It owns transition presentation only; Application remains the authority for
## loading moments and routing home/archive/chapter destinations.
enum PortalState { READY, FOCUSING, DILATING, ENTERING, TRANSITIONING, ARRIVED }

signal entry_arrived(moment_id: String)
signal return_arrived
signal state_changed(next_state: PortalState)

const FOCUS_SECONDS := 0.58
const DILATE_SECONDS := 0.72
const ENTER_SECONDS := 0.68
const TRANSITION_SECONDS := 0.46

var living_iris: LivingIris
var state: PortalState = PortalState.READY
var elapsed := 0.0
var current_moment_id := ""
var current_title := ""
var current_subtitle := ""
var return_mode := false
var pupil_amount := 0.0
var camera_amount := 0.0
var title_label: Label
var subtitle_label: Label
var instruction_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	title_label = _label("", 24, Color("#ebfff7"), Vector2(32, 675), Vector2(476, 40), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle_label = _label("", 12, Color("#9ed5c5"), Vector2(32, 718), Vector2(476, 23), HORIZONTAL_ALIGNMENT_CENTER)
	instruction_label = _label("", 11, Color("#b8e4d8"), Vector2(32, 750), Vector2(476, 24), HORIZONTAL_ALIGNMENT_CENTER)

func configure(value_living_iris: LivingIris) -> void:
	living_iris = value_living_iris

func begin_entry(moment_id: String, moment_data: Dictionary) -> void:
	if state != PortalState.READY:
		return
	return_mode = false
	current_moment_id = moment_id
	current_title = str(moment_data.get("title", "A memory"))
	current_subtitle = str(moment_data.get("subtitle", "The Iris holds a memory"))
	title_label.text = current_title
	subtitle_label.text = current_subtitle
	instruction_label.text = "THE PUPIL OPENS ONTO A REMEMBERED MOMENT"
	visible = true
	_set_state(PortalState.FOCUSING)
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_attention.ogg")
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Iris Portal Focus")

func begin_return() -> void:
	if state != PortalState.READY:
		return
	return_mode = true
	current_moment_id = ""
	current_title = "The memory returns"
	current_subtitle = "The Iris keeps what attention carried"
	title_label.text = current_title
	subtitle_label.text = current_subtitle
	instruction_label.text = "THE FIELD COLLAPSES BACK INTO THE PUPIL"
	visible = true
	pupil_amount = 1.0
	camera_amount = 1.0
	_set_state(PortalState.TRANSITIONING)
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_transition.ogg")
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Iris Portal Return")

func _process(delta: float) -> void:
	if state == PortalState.READY:
		return
	elapsed += delta
	match state:
		PortalState.FOCUSING:
			camera_amount = _ease(elapsed / FOCUS_SECONDS) * 0.32
			if elapsed >= FOCUS_SECONDS:
				_set_state(PortalState.DILATING)
				IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_focus.ogg")
		PortalState.DILATING:
			var amount := _ease(elapsed / DILATE_SECONDS)
			pupil_amount = amount
			camera_amount = 0.32 + amount * 0.42
			if elapsed >= DILATE_SECONDS:
				_set_state(PortalState.ENTERING)
				IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_transition.ogg")
		PortalState.ENTERING:
			var amount := _ease(elapsed / ENTER_SECONDS)
			pupil_amount = 1.0
			camera_amount = 0.74 + amount * 0.26
			if elapsed >= ENTER_SECONDS:
				_set_state(PortalState.TRANSITIONING)
		PortalState.TRANSITIONING:
			var amount := _ease(elapsed / TRANSITION_SECONDS)
			if return_mode:
				pupil_amount = 1.0 - amount
				camera_amount = 1.0 - amount
			else:
				pupil_amount = 1.0
				camera_amount = 1.0
			if elapsed >= TRANSITION_SECONDS:
				_set_state(PortalState.ARRIVED)
		PortalState.ARRIVED:
			_complete_arrival()
	_apply_iris_portal_amount()
	queue_redraw()

func _set_state(next_state: PortalState) -> void:
	state = next_state
	elapsed = 0.0
	state_changed.emit(state)

func _complete_arrival() -> void:
	var was_return := return_mode
	var moment_id := current_moment_id
	_reset()
	if was_return:
		return_arrived.emit()
	else:
		entry_arrived.emit(moment_id)

func _reset() -> void:
	if living_iris != null:
		living_iris.portal_dilation = 0.0
	pupil_amount = 0.0
	camera_amount = 0.0
	visible = false
	state = PortalState.READY
	elapsed = 0.0

func _apply_iris_portal_amount() -> void:
	if living_iris != null:
		living_iris.portal_dilation = pupil_amount

func _ease(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _draw() -> void:
	if not visible or size.x <= 0.0 or size.y <= 0.0:
		return
	var center := Vector2(size.x * 0.5, size.y * 0.458)
	var aperture_radius := minf(size.x * 0.145, size.y * 0.082) * (1.0 + camera_amount * 7.1)
	# The preview is an intentionally abstract ambient hint, not new art content.
	var preview_alpha := clampf(pupil_amount * 0.84 + camera_amount * 0.18, 0.0, 0.90)
	for ring in range(5, 0, -1):
		var spread := 1.0 + float(ring) * 0.26
		draw_circle(center, aperture_radius * spread, Color(0.08, 0.55, 0.45, preview_alpha * 0.05))
	draw_circle(center, aperture_radius, Color(0.006, 0.028, 0.036, preview_alpha))
	# Refraction bands imply a scene being held behind the pupil.
	for index in range(7):
		var y := center.y - aperture_radius + float(index) * aperture_radius * 0.28
		var wave := sin(elapsed * 4.0 + float(index) * 1.37) * aperture_radius * 0.12
		draw_line(Vector2(center.x - aperture_radius * 0.78, y + wave), Vector2(center.x + aperture_radius * 0.78, y - wave), Color(0.32, 0.90, 0.72, preview_alpha * 0.18), 1.0, true)
	if camera_amount > 0.68:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.001, 0.008, 0.012, (camera_amount - 0.68) * 2.8))

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

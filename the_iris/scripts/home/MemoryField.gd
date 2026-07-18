extends Control
class_name MemoryField

## One lightweight memory fragment for the first Iris-centered Home route.
signal intent_focused(normalized_target: Vector2)
signal intent_released
signal continue_selected

const SELECTION_HOLD_SECONDS := 0.42

var elapsed := 0.0
var focus_amount := 0.0
var target_focus := 0.0
var selection_remaining := -1.0
var selection_amount := 0.0
var selection_locked := false
var pointer_position := Vector2.ZERO
var pointer_near := false
var was_visible := false
var redraw_in := 0.0
var title_label: Label
var subtitle_label: Label
var hint_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	pointer_position = size * 0.5
	title_label = _label("CONTINUE WITNESS", 10, Color("#9bd5c4"))
	subtitle_label = _label("CHAPTER 01", 9, Color("#6fa99b"))
	hint_label = _label("A memory waits", 10, Color("#8fbcb0"))

func _process(delta: float) -> void:
	var active := is_visible_in_tree()
	if active and not was_visible:
		_reset_field()
	was_visible = active
	if not active:
		return

	elapsed += delta
	if not pointer_near and selection_remaining < 0.0:
		target_focus = 0.0
	focus_amount = lerpf(focus_amount, target_focus, minf(1.0, delta * 4.2))
	if selection_remaining >= 0.0:
		selection_remaining -= delta
		selection_amount = clampf(1.0 - selection_remaining / SELECTION_HOLD_SECONDS, 0.0, 1.0)
		if selection_remaining <= 0.0:
			selection_remaining = -1.0
			continue_selected.emit()

	_layout_labels(_shard_position())
	redraw_in -= delta
	if redraw_in <= 0.0:
		# A memory drifts deliberately; the Iris remains the higher-frequency life signal.
		redraw_in = 1.0 / 30.0
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if selection_locked:
		return
	if event is InputEventMouseMotion:
		_update_pointer(event.position)
	elif event is InputEventScreenDrag:
		_update_pointer(event.position)
	elif event is InputEventMouseButton and event.pressed:
		_select_if_near(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_select_if_near(event.position)

func _update_pointer(position: Vector2) -> void:
	pointer_position = position
	var near := position.distance_to(_shard_position()) <= _proximity_radius()
	if near and not pointer_near:
		_focus_memory()
	elif not near and pointer_near and selection_remaining < 0.0:
		target_focus = 0.0
		intent_released.emit()
	pointer_near = near

func _select_if_near(position: Vector2) -> void:
	pointer_position = position
	if position.distance_to(_shard_position()) > _proximity_radius():
		return
	_focus_memory()
	selection_locked = true
	selection_remaining = SELECTION_HOLD_SECONDS

func _focus_memory() -> void:
	if target_focus < 1.0:
		target_focus = 1.0
		intent_focused.emit(_normalized_shard_target())

func _reset_field() -> void:
	focus_amount = 0.0
	target_focus = 0.0
	selection_remaining = -1.0
	selection_amount = 0.0
	selection_locked = false
	pointer_near = false
	redraw_in = 0.0
	pointer_position = size * 0.5

func _shard_position() -> Vector2:
	var iris_center := Vector2(size.x * 0.5, size.y * 0.458)
	var orbit_radius := minf(size.x * 0.33, size.y * 0.18) + 52.0
	var orbit_angle := 0.66 + sin(elapsed * 0.11) * 0.07 + sin(elapsed * 0.037 + 1.8) * 0.035
	var orbit := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	var position := iris_center + orbit
	if focus_amount > 0.0:
		var pull := (pointer_position - position).limit_length(46.0)
		position += pull * focus_amount * 0.34
	if selection_amount > 0.0:
		position = position.lerp(iris_center, selection_amount * 0.42)
	return position

func _normalized_shard_target() -> Vector2:
	var safe_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	return (_shard_position() - safe_size * 0.5) / safe_size

func _proximity_radius() -> float:
	return 78.0 + focus_amount * 24.0

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var position := _shard_position()
	var iris_center := Vector2(size.x * 0.5, size.y * 0.458)
	var float_wave := sin(elapsed * 0.78) * 0.5 + 0.5
	var shard_radius := 17.0 + focus_amount * 5.0 - selection_amount * 3.0
	var glow_alpha := 0.055 + focus_amount * 0.15 + selection_amount * 0.12

	if focus_amount > 0.02:
		draw_line(iris_center, position, Color(0.38, 0.90, 0.76, focus_amount * 0.18), 1.0, true)
	for ring in range(3, 0, -1):
		var amount := float(ring) / 3.0
		draw_circle(position, shard_radius * (1.0 + amount * 0.62), Color(0.15, 0.72, 0.61, glow_alpha * (1.0 - amount * 0.45)))

	var points := PackedVector2Array()
	for index in range(6):
		var angle := TAU * float(index) / 6.0 + elapsed * 0.10
		var variation := 0.86 + 0.14 * sin(elapsed * 0.43 + float(index) * 1.91)
		points.append(position + Vector2(cos(angle), sin(angle)) * shard_radius * variation)
	draw_colored_polygon(points, Color(0.08, 0.34 + focus_amount * 0.16, 0.30 + focus_amount * 0.14, 0.94))

	var core_radius := shard_radius * (0.36 + float_wave * 0.05)
	draw_circle(position, core_radius, Color(0.69, 1.0, 0.88, 0.62 + focus_amount * 0.28))
	draw_circle(position + Vector2(-core_radius * 0.24, -core_radius * 0.24), core_radius * 0.24, Color(1, 1, 1, 0.80))

func _layout_labels(position: Vector2) -> void:
	var label_origin := position + Vector2(-82, 27)
	title_label.position = label_origin
	title_label.size = Vector2(164, 18)
	title_label.modulate.a = 0.72 + focus_amount * 0.28
	subtitle_label.position = label_origin + Vector2(0, 17)
	subtitle_label.size = Vector2(164, 16)
	subtitle_label.modulate.a = 0.60 + focus_amount * 0.40
	hint_label.position = label_origin + Vector2(0, 37)
	hint_label.size = Vector2(164, 18)
	hint_label.text = "Focus held" if focus_amount > 0.65 else "A memory waits"
	hint_label.modulate.a = 0.45 + focus_amount * 0.55

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

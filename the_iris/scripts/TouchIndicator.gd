extends Control
var touch_position: Vector2 = Vector2.ZERO
var touch_visible: bool = false
var touch_age: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func show_touch(touch_at: Vector2) -> void:
	touch_position = touch_at
	touch_visible = true
	touch_age = 0.0
	queue_redraw()

func move_touch(touch_at: Vector2) -> void:
	touch_position = touch_at
	touch_visible = true
	touch_age = 0.0
	queue_redraw()

func hide_touch() -> void:
	touch_visible = false
	queue_redraw()

func _process(delta: float) -> void:
	if touch_visible:
		touch_age += delta
		if touch_age > 0.8:
			touch_visible = false
		queue_redraw()

func _draw() -> void:
	if not touch_visible:
		return
	var fade: float = clampf(1.0 - touch_age / 0.8, 0.0, 1.0)
	draw_circle(touch_position, 18.0, Color(0.45, 0.90, 0.80, 0.10 * fade))
	draw_arc(touch_position, 14.0 + touch_age * 12.0, 0.0, TAU, 40, Color(0.64, 0.98, 0.90, 0.68 * fade), 1.5)
	draw_circle(touch_position, 3.0, Color(0.86, 1.0, 0.95, 0.90 * fade))

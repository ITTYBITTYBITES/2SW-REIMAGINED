extends Control
class_name MissingSecondProps

## Scene-specific props/atmosphere renderer for The Missing Second.
var time_value := 0.0
var frozen := false
var resolved := false
var examined := ""
var photo_revealed := false

func set_room_time(value: float) -> void:
	time_value = value
	queue_redraw()

func set_frozen(value: bool) -> void:
	frozen = value
	queue_redraw()

func set_resolved(value: bool) -> void:
	resolved = value
	queue_redraw()

func set_examined(value: String) -> void:
	examined = value
	queue_redraw()

func set_photo_revealed(value: bool) -> void:
	photo_revealed = value
	queue_redraw()

func _draw() -> void:
	var steam_t: float = time_value if not frozen else floor(time_value * 4.0) / 4.0
	# Platform light is a moving translucent room layer.
	var sweep := fmod(steam_t * 0.18, 1.0)
	var x := lerpf(-size.x * 0.40, size.x * 1.12, sweep)
	var light := PackedVector2Array([Vector2(x, 0), Vector2(x + size.x * 0.34, 0), Vector2(x + size.x * 0.72, size.y), Vector2(x + size.x * 0.38, size.y)])
	draw_colored_polygon(light, Color(0.95, 0.65, 0.30, 0.075))

	# Tea and living steam.
	var tea := Vector2(size.x * 0.20, size.y * 0.72)
	_draw_local_ellipse(tea, Vector2(36, 12), Color("#c8b38e"))
	_draw_local_ellipse(tea + Vector2(0, -4), Vector2(28, 8), Color("#3a2c28"))
	for index in range(3):
		var phase: float = steam_t * 1.2 + float(index) * 1.9
		var steam_x := tea.x + sin(phase) * 8.0
		var steam_y := tea.y - 18.0 - fmod(steam_t * 18.0 + float(index) * 13.0, 44.0)
		draw_arc(Vector2(steam_x, steam_y), 9.0, -1.0, 1.0, 10, Color(0.88, 0.92, 0.94, 0.24), 1.2, true)

	# Photograph is deliberately quiet until resolution.
	var photo := Vector2(size.x * 0.54, size.y * 0.70)
	var photo_tint := Color("#e4c58f") if photo_revealed else Color("#9d9079")
	draw_rect(Rect2(photo - Vector2(30, 20), Vector2(60, 40)), photo_tint)
	draw_rect(Rect2(photo - Vector2(25, 15), Vector2(50, 30)), Color("#6d5a50"))
	draw_circle(photo + Vector2(-8, -2), 6, Color("#d8b98a"))
	draw_line(photo + Vector2(-8, 5), photo + Vector2(10, 12), Color("#d8b98a"), 2.0, true)

	# Suitcase anchor.
	var suitcase := Vector2(size.x * 0.72, size.y * 0.72)
	draw_rect(Rect2(suitcase - Vector2(54, 24), Vector2(108, 48)), Color("#5c4438"), true)
	draw_rect(Rect2(suitcase - Vector2(49, 19), Vector2(98, 38)), Color("#80604b"), false, 2.0)
	draw_arc(suitcase + Vector2(0, -25), 16, PI, TAU, 16, Color("#9b765a"), 3.0, true)

	# Inspection feedback stays on the physical object, not in a generic card.
	if not examined.is_empty():
		var focus := tea if examined == "tea" else (photo if examined == "photograph" else (suitcase if examined == "suitcase" else Vector2(size.x * 0.5, size.y * 0.28)))
		draw_arc(focus, 46, 0, TAU, 28, Color(0.72, 0.92, 0.84, 0.38), 1.4, true)

func _draw_local_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(1.0, radii.y / radii.x))
	draw_circle(Vector2.ZERO, radii.x, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

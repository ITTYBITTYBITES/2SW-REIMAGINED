extends Control
class_name MissingSecondClock

## Scene-specific clock for The Missing Second. Not a reusable timing system.
var second_angle := -PI * 0.5
var frozen := false
var highlight := 0.0

func set_observation_time(seconds: float) -> void:
	if frozen:
		return
	# One clock second is one sixtieth of a full analog-clock rotation.
	second_angle = -PI * 0.5 + fmod(seconds * TAU / 60.0, TAU)
	queue_redraw()

func set_frozen_angle(angle_value: float) -> void:
	frozen = true
	second_angle = angle_value
	queue_redraw()

func set_highlight(amount: float) -> void:
	highlight = clampf(amount, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.46
	for ring in range(3, 0, -1):
		draw_circle(center, radius * (1.0 + float(ring) * 0.07), Color(0.86, 0.78, 0.57, highlight * 0.06))
	draw_circle(center, radius, Color("#e7dfc8"))
	draw_circle(center, radius * 0.89, Color("#29313a"))
	draw_circle(center, radius * 0.82, Color("#d9d0b8"))
	for index in range(12):
		var angle := -PI * 0.5 + float(index) * TAU / 12.0
		var from := center + Vector2(cos(angle), sin(angle)) * radius * 0.65
		var to := center + Vector2(cos(angle), sin(angle)) * radius * 0.75
		draw_line(from, to, Color("#313741"), 2.0 if index % 3 == 0 else 1.0, true)
	var hand_end := center + Vector2(cos(second_angle), sin(second_angle)) * radius * 0.68
	draw_line(center, hand_end, Color("#b94f3e").lerp(Color("#f7b55b"), highlight), 2.6, true)
	draw_circle(center, radius * 0.07, Color("#343a44"))

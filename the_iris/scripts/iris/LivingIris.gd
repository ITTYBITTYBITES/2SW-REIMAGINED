extends Control
class_name LivingIris

## Image-free Living Iris rendering. A single Control draws the complete
## instrument with lightweight 2D primitives for mobile-friendly animation.
var core: IrisCore
var elapsed := 0.0
var behavior := {
	"breath": 0.42,
	"glow": 0.14,
	"pupil": 0.36,
	"gaze": Vector2.ZERO,
	"fiber_motion": 0.22,
	"fiber_density": 42,
	"focus": 0.0,
	"reflective": 0.0,
	"awakening": 0.0,
	"calibration": 0.0
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_core(value: IrisCore) -> void:
	core = value

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	if core != null:
		behavior = core.tick(delta)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var breath := float(behavior.get("breath", 0.5))
	var glow := float(behavior.get("glow", 0.2))
	var pupil_ratio := float(behavior.get("pupil", 0.33))
	var gaze: Vector2 = behavior.get("gaze", Vector2.ZERO)
	var fiber_motion := float(behavior.get("fiber_motion", 0.3))
	var fiber_density := int(behavior.get("fiber_density", 48))
	var focus := float(behavior.get("focus", 0.0))
	var reflective := float(behavior.get("reflective", 0.0))
	var awakening := float(behavior.get("awakening", 1.0))
	var calibration := float(behavior.get("calibration", 0.0))
	var birth := lerpf(0.52, 1.0, awakening)
	var breath_wave := sin(elapsed * breath * TAU) * 0.5 + 0.5
	var radius := minf(size.x * 0.342, size.y * 0.192) * birth
	radius *= 1.0 + (breath_wave - 0.5) * 0.025
	var center := Vector2(size.x * 0.5, size.y * 0.458) + gaze * radius * 2.2

	_draw_aura(center, radius, glow, focus, awakening)
	_draw_iris_body(center, radius, glow, breath_wave, awakening)
	_draw_fibers(center, radius, pupil_ratio, fiber_motion, fiber_density, glow, focus)
	_draw_pupil(center, radius, pupil_ratio, glow, focus, breath_wave)
	if reflective > 0.0:
		_draw_reflections(center, radius, reflective)
	if calibration > 0.0:
		_draw_calibration(center, radius, calibration)

func _draw_aura(center: Vector2, radius: float, glow: float, focus: float, awakening: float) -> void:
	var rings := 8
	for index in range(rings, 0, -1):
		var amount := float(index) / float(rings)
		var alpha := (0.004 + glow * 0.021) * (1.0 - amount * 0.52) * awakening
		var tint := Color(0.09 + focus * 0.05, 0.46 + glow * 0.28, 0.40 + glow * 0.18, alpha)
		draw_circle(center, radius * (1.08 + amount * (0.58 + focus * 0.13)), tint)

func _draw_iris_body(center: Vector2, radius: float, glow: float, breath_wave: float, awakening: float) -> void:
	var silhouette := PackedVector2Array()
	for index in range(72):
		var angle := TAU * float(index) / 72.0
		var ripple := sin(angle * 6.0 + elapsed * 0.52) * 0.013
		ripple += sin(angle * 13.0 - elapsed * 0.31) * 0.006
		silhouette.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.07 + ripple))
	draw_colored_polygon(silhouette, Color(0.025, 0.135 + glow * 0.05, 0.13 + glow * 0.04, awakening))
	draw_circle(center, radius * 1.015, Color(0.08, 0.38 + glow * 0.12, 0.33 + glow * 0.10, awakening))
	draw_circle(center, radius * 0.962, Color(0.025, 0.19 + breath_wave * 0.055, 0.18 + breath_wave * 0.04, awakening))
	draw_circle(center, radius * 0.905, Color(0.012, 0.09, 0.105, awakening))

	var rim_alpha := 0.12 + glow * 0.26
	for ring in range(3):
		var ring_radius := radius * (0.90 + float(ring) * 0.042)
		draw_arc(center, ring_radius, 0.0, TAU, 96, Color(0.20, 0.88, 0.70, rim_alpha / float(ring + 1)), 1.1, true)

func _draw_fibers(center: Vector2, radius: float, pupil_ratio: float, motion: float, density: int, glow: float, focus: float) -> void:
	var inner_base := radius * pupil_ratio * 1.04
	for index in range(density):
		var ratio := float(index) / float(density)
		var seed := float(index) * 1.618
		var angle := ratio * TAU + sin(elapsed * 0.31 + seed) * 0.035 * motion
		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-direction.y, direction.x)
		var organic := sin(seed * 2.1 + elapsed * (0.65 + motion * 1.5))
		var inner := inner_base * (0.89 + 0.14 * sin(seed * 1.7))
		var outer := radius * (0.72 + 0.19 * (sin(seed * 0.73) * 0.5 + 0.5))
		var bend := radius * (0.014 + motion * 0.034) * organic
		var middle := lerpf(inner, outer, 0.48)
		var first := center + direction * inner
		var second := center + direction * middle + tangent * bend
		var third := center + direction * outer + tangent * bend * 0.34
		var bright := 0.45 + 0.55 * (sin(seed * 4.1 + elapsed * 1.3) * 0.5 + 0.5)
		var alpha := (0.07 + glow * 0.25) * bright
		var fiber_color := Color(0.18 + bright * 0.18, 0.56 + bright * 0.31, 0.46 + bright * 0.25, alpha)
		var width := 0.62 + bright * 0.68 + focus * 0.20
		draw_line(first, second, fiber_color, width, true)
		draw_line(second, third, fiber_color, width * 0.74, true)

func _draw_pupil(center: Vector2, radius: float, pupil_ratio: float, glow: float, focus: float, breath_wave: float) -> void:
	var pupil_radius := radius * pupil_ratio
	var corona_alpha := 0.08 + glow * 0.16
	draw_circle(center, pupil_radius * 1.28, Color(0.18, 0.82, 0.66, corona_alpha))
	draw_circle(center, pupil_radius * 1.11, Color(0.008, 0.030, 0.041, 0.96))
	draw_circle(center, pupil_radius, Color(0.001, 0.006, 0.012, 1.0))

	var glint_position := center + Vector2(-radius * (0.24 - focus * 0.04), -radius * 0.255)
	var glint_radius := radius * (0.072 + breath_wave * 0.014)
	draw_circle(glint_position, glint_radius, Color(0.70, 1.0, 0.90, 0.18 + glow * 0.36))
	draw_circle(glint_position + Vector2(-radius * 0.018, -radius * 0.018), glint_radius * 0.34, Color(0.96, 1.0, 0.98, 0.72))
	draw_circle(center + Vector2(radius * 0.14, radius * 0.18), radius * 0.018, Color(0.36, 0.92, 0.77, 0.12 + glow * 0.22))

func _draw_reflections(center: Vector2, radius: float, amount: float) -> void:
	for index in range(3):
		var angle := elapsed * (0.22 + float(index) * 0.05) + float(index) * TAU / 3.0
		var start := center + Vector2(cos(angle), sin(angle)) * radius * 0.48
		var end := center + Vector2(cos(angle + 0.23), sin(angle + 0.23)) * radius * 0.78
		draw_line(start, end, Color(0.78, 0.95, 0.84, amount * 0.18), 1.0, true)

func _draw_calibration(center: Vector2, radius: float, amount: float) -> void:
	var calibration_radius := radius * (0.58 + sin(elapsed * 3.0) * 0.04)
	draw_arc(center, calibration_radius, 0.0, TAU, 48, Color(0.65, 0.98, 0.87, amount * 0.24), 1.0, true)

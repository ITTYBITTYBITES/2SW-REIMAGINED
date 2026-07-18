extends Control
class_name LivingIris

## The sole Iris renderer. It uses lightweight procedural 2D primitives and
## suspends all animation work while the Iris screen is hidden.
var core: IrisCore
var elapsed := 0.0
var behavior := {
	"breath_primary": 0.46,
	"breath_secondary": 0.118,
	"breath_wave": 0.5,
	"glow": 0.0,
	"pupil": 0.38,
	"gaze": Vector2.ZERO,
	"fiber_motion": 0.0,
	"fiber_density": 0,
	"focus": 0.0,
	"reflective": 0.0,
	"presence": 0.0,
	"calibration": 0.0,
	"blink": 0.0,
	"pulse": 0.0,
	"drift": 0.5,
	"asymmetry": 0.0
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
	var presence := float(behavior.get("presence", 0.0))
	if presence <= 0.001:
		return
	var glow := float(behavior.get("glow", 0.0))
	var pupil_ratio := float(behavior.get("pupil", 0.36))
	var gaze: Vector2 = behavior.get("gaze", Vector2.ZERO)
	var fiber_motion := float(behavior.get("fiber_motion", 0.0))
	var fiber_density := int(behavior.get("fiber_density", 0))
	var focus := float(behavior.get("focus", 0.0))
	var reflective := float(behavior.get("reflective", 0.0))
	var calibration := float(behavior.get("calibration", 0.0))
	var blink := float(behavior.get("blink", 0.0))
	var pulse := float(behavior.get("pulse", 0.0))
	var drift := float(behavior.get("drift", 0.5))
	var asymmetry := float(behavior.get("asymmetry", 0.0))
	var breath_wave := float(behavior.get("breath_wave", 0.5))

	var base_radius := minf(size.x * 0.342, size.y * 0.192)
	var radius := base_radius * lerpf(0.16, 1.0, presence)
	radius *= 1.0 + (breath_wave - 0.5) * 0.028 + pulse * 0.024
	var center := Vector2(size.x * 0.5, size.y * 0.458) + gaze * radius * 2.15
	var openness := 1.0 - blink * 0.70

	# A blink closes the whole living aperture instead of overlaying a separate image.
	draw_set_transform(center, 0.0, Vector2(1.0, openness))
	_draw_aura(Vector2.ZERO, radius, presence, glow, focus, pulse, drift)
	_draw_iris_body(Vector2.ZERO, radius, presence, glow, breath_wave, drift, asymmetry)
	_draw_fibers(Vector2.ZERO, radius, pupil_ratio, fiber_motion, fiber_density, presence, glow, focus, drift, asymmetry)
	_draw_pupil(Vector2.ZERO, radius, pupil_ratio, presence, glow, focus, breath_wave, pulse)
	if reflective > 0.0:
		_draw_reflections(Vector2.ZERO, radius, reflective, drift)
	if calibration > 0.0:
		_draw_calibration(Vector2.ZERO, radius, calibration)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_aura(center: Vector2, radius: float, presence: float, glow: float, focus: float, pulse: float, drift: float) -> void:
	var rings := 6
	for index in range(rings, 0, -1):
		var amount := float(index) / float(rings)
		var spread := 1.08 + amount * (0.54 + focus * 0.15 + pulse * 0.12)
		var alpha := (0.003 + glow * 0.023 + pulse * 0.012) * (1.0 - amount * 0.48) * presence
		var tint := Color(0.07 + focus * 0.06, 0.38 + glow * 0.30 + drift * 0.03, 0.33 + glow * 0.24, alpha)
		draw_circle(center, radius * spread, tint)

func _draw_iris_body(center: Vector2, radius: float, presence: float, glow: float, breath_wave: float, drift: float, asymmetry: float) -> void:
	var silhouette := PackedVector2Array()
	for index in range(48):
		var angle := TAU * float(index) / 48.0
		var ripple := sin(angle * 5.0 + elapsed * 0.47 + asymmetry) * 0.013
		ripple += sin(angle * 11.0 - elapsed * 0.19 + asymmetry * 1.7) * 0.006
		ripple += sin(angle * 3.0 + elapsed * 0.071) * 0.004
		silhouette.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.07 + ripple))
	draw_colored_polygon(silhouette, Color(0.018, 0.105 + glow * 0.06, 0.105 + glow * 0.045, presence))
	draw_circle(center, radius * 1.015, Color(0.05, 0.31 + glow * 0.15, 0.28 + glow * 0.12, presence))
	draw_circle(center, radius * 0.965, Color(0.017, 0.145 + breath_wave * 0.065 + drift * 0.02, 0.145 + breath_wave * 0.050, presence))
	draw_circle(center, radius * 0.908, Color(0.007, 0.052, 0.066, presence))

	var rim_alpha := (0.055 + glow * 0.18) * presence
	for ring in range(2):
		var ring_radius := radius * (0.912 + float(ring) * 0.048)
		draw_arc(center, ring_radius, 0.0, TAU, 40, Color(0.14, 0.70 + drift * 0.08, 0.56 + drift * 0.10, rim_alpha / float(ring + 1)), 0.85, true)

func _draw_fibers(center: Vector2, radius: float, pupil_ratio: float, motion: float, density: int, presence: float, glow: float, focus: float, drift: float, asymmetry: float) -> void:
	if density <= 0:
		return
	var inner_base := radius * pupil_ratio * 1.04
	for index in range(density):
		var ratio := float(index) / float(density)
		var fiber_seed := float(index) * 1.618 + asymmetry
		var angle := ratio * TAU + sin(elapsed * 0.29 + fiber_seed) * 0.050 * motion
		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-direction.y, direction.x)
		var organic := sin(fiber_seed * 2.13 + elapsed * (0.51 + motion * 1.37))
		organic += sin(fiber_seed * 0.71 - elapsed * 0.17) * 0.34
		var inner := inner_base * (0.91 + 0.16 * sin(fiber_seed * 1.63))
		var outer := radius * (0.62 + 0.27 * (sin(fiber_seed * 0.79 + drift) * 0.5 + 0.5))
		var first_bend := radius * (0.012 + motion * 0.044) * organic
		var second_bend := radius * (0.008 + motion * 0.030) * sin(fiber_seed * 3.73 - elapsed * 0.41)
		var first := center + direction * inner
		var second := center + direction * lerpf(inner, outer, 0.30) + tangent * first_bend
		var third := center + direction * lerpf(inner, outer, 0.68) + tangent * second_bend
		var fourth := center + direction * outer + tangent * second_bend * 0.22
		var bright := 0.32 + 0.68 * (sin(fiber_seed * 4.17 + elapsed * 1.09 + drift) * 0.5 + 0.5)
		var alpha := (0.028 + glow * 0.17 + focus * 0.035) * bright * presence
		var fiber_color := Color(0.10 + bright * 0.19, 0.39 + bright * 0.36, 0.32 + bright * 0.29, alpha)
		var width := 0.42 + bright * 0.54 + focus * 0.14
		draw_line(first, second, fiber_color, width, true)
		draw_line(second, third, fiber_color, width * 0.74, true)
		if index % 3 == 0:
			draw_line(third, fourth, fiber_color, width * 0.52, true)

func _draw_pupil(center: Vector2, radius: float, pupil_ratio: float, presence: float, glow: float, focus: float, breath_wave: float, pulse: float) -> void:
	var pupil_radius := radius * pupil_ratio
	var corona_alpha := (0.06 + glow * 0.18 + pulse * 0.08) * presence
	draw_circle(center, pupil_radius * (1.28 + pulse * 0.06), Color(0.13, 0.72, 0.57, corona_alpha))
	draw_circle(center, pupil_radius * 1.11, Color(0.004, 0.018, 0.029, 0.98 * presence))
	draw_circle(center, pupil_radius, Color(0.001, 0.004, 0.009, presence))

	var glint_position := center + Vector2(-radius * (0.24 - focus * 0.045), -radius * 0.255)
	var glint_radius := radius * (0.062 + breath_wave * 0.016 + pulse * 0.012)
	draw_circle(glint_position, glint_radius, Color(0.63, 1.0, 0.86, (0.12 + glow * 0.38) * presence))
	draw_circle(glint_position + Vector2(-radius * 0.017, -radius * 0.017), glint_radius * 0.32, Color(0.95, 1.0, 0.98, 0.72 * presence))
	draw_circle(center + Vector2(radius * 0.14, radius * 0.18), radius * 0.017, Color(0.25, 0.86, 0.70, (0.08 + glow * 0.24) * presence))

func _draw_reflections(center: Vector2, radius: float, amount: float, drift: float) -> void:
	for index in range(3):
		var angle := elapsed * (0.19 + float(index) * 0.037) + float(index) * TAU / 3.0 + drift
		var start := center + Vector2(cos(angle), sin(angle)) * radius * 0.47
		var end := center + Vector2(cos(angle + 0.21), sin(angle + 0.21)) * radius * 0.78
		draw_line(start, end, Color(0.73, 0.96, 0.82, amount * 0.17), 0.9, true)

func _draw_calibration(center: Vector2, radius: float, amount: float) -> void:
	var calibration_radius := radius * (0.54 + sin(elapsed * 2.7) * 0.05)
	draw_arc(center, calibration_radius, 0.0, TAU, 40, Color(0.61, 0.98, 0.85, amount * 0.21), 0.9, true)

extends Control
class_name LivingIris

## Image-free Living Iris rendering. Every visible eye element is drawn here.
var core: IrisCore
var elapsed := 0.0
var behavior := {"breath": 0.65, "glow": 0.45, "pupil": 0.32, "gaze": Vector2.ZERO}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func set_core(value: IrisCore) -> void:
	core = value

func _process(delta: float) -> void:
	elapsed += delta
	if core != null:
		behavior = core.tick(delta)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var breath := float(behavior.get("breath", 0.7))
	var glow := float(behavior.get("glow", 0.5))
	var pupil_ratio := float(behavior.get("pupil", 0.30))
	var gaze: Vector2 = behavior.get("gaze", Vector2.ZERO)
	var radius := minf(size.x * 0.36, size.y * 0.20) * (1.0 + sin(elapsed * breath * 1.6) * 0.018)
	var center := Vector2(size.x * 0.5, size.y * 0.46) + gaze * radius * 1.8

	# Soft optical bloom, rendered from outside inward.
	for ring in range(9, 0, -1):
		var amount := float(ring) / 9.0
		var bloom := Color(0.10, 0.95, 0.70, 0.010 + glow * 0.018 * (1.0 - amount))
		draw_circle(center, radius * (1.0 + amount * 0.55), bloom)

	draw_circle(center, radius * 1.08, Color("#b8f4df"))
	draw_circle(center, radius * 1.01, Color("#4fb39a"))
	draw_circle(center, radius * 0.94, Color("#0d403d"))

	# Radial fibers make the iris responsive without a texture or shader.
	for index in range(96):
		var angle := TAU * float(index) / 96.0 + elapsed * 0.10
		var direction := Vector2(cos(angle), sin(angle))
		var wave := 0.78 + 0.18 * sin(elapsed * breath * 1.8 + float(index) * 1.71)
		var inner := radius * pupil_ratio * wave
		var outer := radius * (0.82 + 0.10 * sin(float(index) * 2.3))
		var fiber_color := Color(0.36, 0.96, 0.75, 0.20 + glow * 0.22)
		draw_line(center + direction * inner, center + direction * outer, fiber_color, 1.2, true)

	var pupil_radius := radius * pupil_ratio
	draw_circle(center, pupil_radius * 1.10, Color("#061117"))
	draw_circle(center, pupil_radius, Color("#010408"))
	draw_circle(center + Vector2(-radius * 0.23, -radius * 0.24), radius * 0.11, Color(0.88, 1.0, 0.96, 0.68))
	draw_circle(center + Vector2(-radius * 0.20, -radius * 0.21), radius * 0.045, Color(1, 1, 1, 0.88))

extends Control
class_name LivingIris

## The sole Iris renderer. It uses lightweight procedural 2D primitives and
## suspends all animation work while the Iris screen is hidden.
var core: IrisCore
var evolution_profile: IrisEvolutionProfile
## Authored by IrisPortalTransition; the core remains the lifecycle authority.
var portal_dilation := 0.0
## Transient confirmation layered on permanent archive-derived fragment detail.
var fragment_absorption_flash := 0.0
var latest_absorbed_fragment := ""
## Short-lived relational responses; permanent qualities remain profile-derived.
var memory_response := ""
var memory_response_amount := 0.0
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

func absorb_truth_fragment(fragment_id: String) -> void:
	latest_absorbed_fragment = fragment_id
	fragment_absorption_flash = 1.0
	present_memory_response("stabilized")

func present_memory_response(response: String) -> void:
	memory_response = response
	memory_response_amount = 1.0
	queue_redraw()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	fragment_absorption_flash = maxf(0.0, fragment_absorption_flash - delta * 0.42)
	memory_response_amount = maxf(0.0, memory_response_amount - delta * 0.55)
	if core != null:
		var base_behavior := core.tick(delta)
		if evolution_profile != null:
			behavior = IrisEvolutionVisualConsumer.apply_evolution(evolution_profile, base_behavior)
		else:
			behavior = base_behavior
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
	var response_breath := 0.0
	if memory_response == "unsettled":
		response_breath = sin(elapsed * 5.2) * 0.018 * memory_response_amount
	elif memory_response == "stabilized":
		response_breath = sin(elapsed * 1.25) * 0.010 * memory_response_amount
	radius *= 1.0 + (breath_wave - 0.5) * 0.028 + pulse * 0.024 + response_breath
	var center := Vector2(size.x * 0.5, size.y * 0.458) + gaze * radius * 2.15
	var openness := 1.0 - blink * 0.70

	# A blink closes the whole living aperture instead of overlaying a separate image.
	draw_set_transform(center, 0.0, Vector2(1.0, openness))
	_draw_aura(Vector2.ZERO, radius, presence, glow, focus, pulse, drift)
	_draw_iris_body(Vector2.ZERO, radius, presence, glow, breath_wave, drift, asymmetry)
	_draw_fibers(Vector2.ZERO, radius, pupil_ratio, fiber_motion, fiber_density, presence, glow, focus, drift, asymmetry)
	_draw_recovered_fragments(Vector2.ZERO, radius, presence)
	_draw_memory_response(Vector2.ZERO, radius, presence)
	_draw_pupil(Vector2.ZERO, radius, pupil_ratio, presence, glow, focus, breath_wave, pulse)
	if reflective > 0.0:
		_draw_reflections(Vector2.ZERO, radius, reflective, drift)
	if calibration > 0.0:
		_draw_calibration(Vector2.ZERO, radius, calibration)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_aura(center: Vector2, radius: float, presence: float, glow: float, focus: float, pulse: float, drift: float) -> void:
	var depth_offset: float = float(behavior.get("depth_offset", 0.0))
	var rings := 6
	for index in range(rings, 0, -1):
		var amount := float(index) / float(rings)
		var spread := 1.08 + amount * (0.54 + focus * 0.15 + pulse * 0.12 + depth_offset * 0.25)
		var alpha := (0.003 + glow * 0.023 + pulse * 0.012) * (1.0 - amount * 0.48) * presence
		var tint := Color(0.07 + focus * 0.06, 0.38 + glow * 0.30 + drift * 0.03, 0.33 + glow * 0.24, alpha)
		draw_circle(center, radius * spread, tint)
		
	# Dynamic Evolution Flare Layer for high-end procedural glow visuals
	if depth_offset > 0.05:
		var flare_alpha := (0.015 + glow * 0.08) * depth_offset * presence
		var flare_tint := Color(0.42, 0.95, 0.82, flare_alpha)
		draw_circle(center, radius * (0.85 + depth_offset * 0.15), flare_tint)

func _draw_iris_body(center: Vector2, radius: float, presence: float, glow: float, breath_wave: float, drift: float, asymmetry: float) -> void:
	var geometry_scale: float = float(behavior.get("geometry_scale", 1.0))
	var depth_offset: float = float(behavior.get("depth_offset", 0.0))
	
	var segments := roundi(48.0 * geometry_scale)
	var silhouette := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		var ripple := sin(angle * 5.0 + elapsed * 0.47 + asymmetry) * 0.013 * geometry_scale
		ripple += sin(angle * 11.0 - elapsed * 0.19 + asymmetry * 1.7) * 0.006 * geometry_scale
		ripple += sin(angle * 3.0 + elapsed * 0.071) * 0.004
		silhouette.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.07 + ripple))
	draw_colored_polygon(silhouette, Color(0.018, 0.105 + glow * 0.06, 0.105 + glow * 0.045, presence))
	
	if depth_offset > 0.05:
		draw_circle(center, radius * (1.02 + depth_offset * 0.05), Color(0.012, 0.08, 0.07, presence * 0.42))
		draw_arc(center, radius * (0.98 + depth_offset * 0.06), 0.0, TAU, 50, Color(0.25, 0.92, 0.78, presence * 0.35 * depth_offset), 0.75, true)
		
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

func _draw_recovered_fragments(center: Vector2, radius: float, presence: float) -> void:
	var fragment_count := int(behavior.get("fragment_memory", 0))
	if fragment_count <= 0:
		return
	var bloom := bool(behavior.get("fragment_bloom", false))
	var glow := float(behavior.get("fragment_glow", 0.12))
	for index in range(fragment_count):
		var angle := elapsed * 0.31 + float(index) * TAU / float(fragment_count) - 0.72
		var position_value := center + Vector2(cos(angle), sin(angle)) * radius * 0.56
		var shard_radius := radius * (0.038 + sin(elapsed * 1.5 + float(index)) * 0.004)
		for ring in range(3, 0, -1):
			draw_circle(position_value, shard_radius * (1.0 + float(ring) * 0.9), Color(0.93, 0.76, 0.34, glow * presence * 0.14))
		draw_circle(position_value, shard_radius, Color(1.0, 0.87, 0.48, (0.55 + glow) * presence))
		draw_circle(position_value + Vector2(-shard_radius * 0.25, -shard_radius * 0.25), shard_radius * 0.28, Color(1.0, 1.0, 0.90, presence))
	if bloom:
		draw_arc(center, radius * 0.72, -1.35, 0.25, 30, Color(0.95, 0.78, 0.38, glow * presence * 0.55), 1.2, true)
	if fragment_absorption_flash > 0.0:
		var flash_radius := radius * (0.38 + (1.0 - fragment_absorption_flash) * 0.95)
		draw_arc(center, flash_radius, 0.0, TAU, 48, Color(1.0, 0.87, 0.48, fragment_absorption_flash * presence * 0.64), 1.8, true)

func _draw_memory_response(center: Vector2, radius: float, presence: float) -> void:
	if memory_response_amount <= 0.01:
		return
	var amount := memory_response_amount * presence
	if memory_response == "unsettled":
		# A brief cool, irregular rhythm acknowledges a false detail without a punishment UI.
		var offset := sin(elapsed * 11.0) * radius * 0.035
		draw_arc(center + Vector2(offset, 0), radius * 0.68, -1.15, 1.2, 32, Color(0.38, 0.65, 1.0, amount * 0.32), 1.5, true)
		draw_arc(center - Vector2(offset, 0), radius * 0.82, 1.9, 4.1, 32, Color(0.38, 0.65, 1.0, amount * 0.18), 0.9, true)
	elif memory_response == "stabilized":
		var settle_radius := radius * (0.42 + (1.0 - memory_response_amount) * 0.42)
		draw_arc(center, settle_radius, 0.0, TAU, 44, Color(0.96, 0.80, 0.42, amount * 0.42), 1.4, true)
	elif memory_response == "remembering":
		draw_arc(center, radius * 0.74, -0.9, 0.9, 36, Color(0.70, 0.94, 0.82, amount * 0.30), 1.2, true)

func _draw_pupil(center: Vector2, radius: float, pupil_ratio: float, presence: float, glow: float, focus: float, breath_wave: float, pulse: float) -> void:
	var biological_pulse: float = float(behavior.get("biological_pulse", 1.0))
	# Portal dilation is temporary presentation input; it never changes IrisCore.
	var pupil_radius := radius * pupil_ratio * lerpf(1.0, 2.48, portal_dilation)
	var corona_alpha := (0.06 + glow * 0.18 + pulse * 0.08) * presence
	draw_circle(center, pupil_radius * (1.28 + pulse * 0.06), Color(0.13, 0.72, 0.57, corona_alpha))
	draw_circle(center, pupil_radius * 1.11, Color(0.004, 0.018, 0.029, 0.98 * presence))
	draw_circle(center, pupil_radius, Color(0.001, 0.004, 0.009, presence))

	var glint_position := center + Vector2(-radius * (0.24 - focus * 0.045), -radius * 0.255)
	var glint_radius := radius * (0.062 + breath_wave * 0.016 + pulse * 0.012) * biological_pulse
	draw_circle(glint_position, glint_radius, Color(0.63, 1.0, 0.86, (0.12 + glow * 0.38) * presence))
	draw_circle(glint_position + Vector2(-radius * 0.017, -radius * 0.017), glint_radius * 0.32, Color(0.95, 1.0, 0.98, 0.72 * presence))
	draw_circle(center + Vector2(radius * 0.14, radius * 0.18), radius * 0.017, Color(0.25, 0.86, 0.70, (0.08 + glow * 0.24) * presence))
	
	if behavior.has("full_evolution_flare"):
		draw_arc(center, radius * 0.42, 0.0, TAU, 60, Color(0.82, 1.0, 0.94, presence * 0.5), 1.2, true)

func _draw_reflections(center: Vector2, radius: float, amount: float, drift: float) -> void:
	for index in range(3):
		var angle := elapsed * (0.19 + float(index) * 0.037) + float(index) * TAU / 3.0 + drift
		var start := center + Vector2(cos(angle), sin(angle)) * radius * 0.47
		var end := center + Vector2(cos(angle + 0.21), sin(angle + 0.21)) * radius * 0.78
		draw_line(start, end, Color(0.73, 0.96, 0.82, amount * 0.17), 0.9, true)

func _draw_calibration(center: Vector2, radius: float, amount: float) -> void:
	var calibration_radius := radius * (0.54 + sin(elapsed * 2.7) * 0.05)
	draw_arc(center, calibration_radius, 0.0, TAU, 40, Color(0.61, 0.98, 0.85, amount * 0.21), 0.9, true)

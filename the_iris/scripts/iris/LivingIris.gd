extends Control
class_name LivingIris

## The sole Iris renderer — a procedural _draw() system that generates living
## texture (high-density neural fibers, concave bowl depth, procedural eyelid
## shutters, noise-driven undulation) modulated by an atmosphere shader.
##
## V4.0 High-Fidelity Mandate:
##   - 200+ neural fibers with per-index alpha/width layering
##   - Radial-gradient "bowl" for concave depth (darkens toward pupil)
##   - Procedural eyelid arcs (biological blink shutters)
##   - FastNoiseLite-driven undulation (fibers "swim", not just breathe)
## All driven by IrisCore behavior + mood colors. No experience-specific knowledge.

var core: IrisCore
var evolution_profile: IrisEvolutionProfile
var portal_dilation := 0.0
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

# Density multiplier: the core's per-state density (up to ~56) is scaled up to
# the 200+ fiber mandate. Higher states (FOCUSED) get denser fringe.
const FIBER_DENSITY_MULTIPLIER := 4.0
# Bowl gradient ring count — more rings = smoother concave falloff.
const BOWL_RINGS := 14

var _atmosphere_shader: ShaderMaterial
# FastNoiseLite drives organic fiber undulation (the "swim"). Sampled per fiber.
var _noise: FastNoiseLite

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_attach_atmosphere_shader()
	_init_noise()

func _init_noise() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = randi() % 100000
	_noise.frequency = 0.012
	_noise.fractal_octaves = 3
	_noise.fractal_lacunarity = 2.0
	_noise.fractal_gain = 0.5

func _attach_atmosphere_shader() -> void:
	var shader := load("res://shaders/iris_atmosphere.gdshader")
	if shader is Shader:
		_atmosphere_shader = ShaderMaterial.new()
		_atmosphere_shader.shader = shader
		material = _atmosphere_shader

func set_core(value: IrisCore) -> void:
	core = value

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	if core != null:
		var base_behavior := core.tick(delta)
		if evolution_profile != null:
			behavior = IrisEvolutionVisualConsumer.apply_evolution(evolution_profile, base_behavior)
		else:
			behavior = base_behavior
	_push_atmosphere_uniforms()
	queue_redraw()

func _push_atmosphere_uniforms() -> void:
	if _atmosphere_shader == null:
		return
	_atmosphere_shader.set_shader_parameter("base_color", behavior.get("mood_base_color", Color.BLACK))
	_atmosphere_shader.set_shader_parameter("glow_color", behavior.get("mood_glow_color", Color.BLACK))
	_atmosphere_shader.set_shader_parameter("energy_intensity", float(behavior.get("mood_energy", 0.0)))
	_atmosphere_shader.set_shader_parameter("time", elapsed)

# Per-frame mood color cache (set in _process, read by the draw helpers).
var _mood_base := Color(0.02, 0.03, 0.055)
var _mood_glow := Color(0.075, 0.12, 0.28)
var _mood_secondary := Color.BLACK
var _mood_secondary_weight := 0.0

func _cache_mood_colors() -> void:
	_mood_base = behavior.get("mood_base_color", _mood_base)
	_mood_glow = behavior.get("mood_glow_color", _mood_glow)
	_mood_secondary = behavior.get("mood_secondary_color", Color.BLACK)
	_mood_secondary_weight = float(behavior.get("mood_secondary_weight", 0.0))

## Blend between the mood's deep base and its emissive glow by t in [0,1].
func _mood_tint(t: float) -> Color:
	var c := _mood_base.lerp(_mood_glow, clampf(t, 0.0, 1.0))
	if _mood_secondary_weight > 0.001:
		c = c.lerp(_mood_secondary, _mood_secondary_weight * 0.5 * (0.5 + 0.5 * t))
	return c

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	_cache_mood_colors()
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

	# Scale the core's authored density up to the 200+ fiber mandate.
	var dense_fibers := int(roundf(fiber_density * FIBER_DENSITY_MULTIPLIER))

	# A blink closes the whole living aperture instead of overlaying a separate image.
	draw_set_transform(center, 0.0, Vector2(1.0, openness))
	_draw_aura(Vector2.ZERO, radius, presence, glow, focus, pulse, drift)
	_draw_iris_body(Vector2.ZERO, radius, presence, glow, breath_wave, drift, asymmetry, pupil_ratio)
	_draw_fibers(Vector2.ZERO, radius, pupil_ratio, fiber_motion, dense_fibers, presence, glow, focus, drift, asymmetry)
	_draw_pupil(Vector2.ZERO, radius, pupil_ratio, presence, glow, focus, breath_wave, pulse)
	if reflective > 0.0:
		_draw_reflections(Vector2.ZERO, radius, reflective, drift)
	if calibration > 0.0:
		_draw_calibration(Vector2.ZERO, radius, calibration)
	# Procedural eyelid shutters — drawn last so they occlude the aperture on blink.
	_draw_eyelids(Vector2.ZERO, radius, presence, blink, focus)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_aura(center: Vector2, radius: float, presence: float, glow: float, focus: float, pulse: float, drift: float) -> void:
	var depth_offset: float = float(behavior.get("depth_offset", 0.0))
	var rings := 6
	for index in range(rings, 0, -1):
		var amount := float(index) / float(rings)
		var spread := 1.08 + amount * (0.54 + focus * 0.15 + pulse * 0.12 + depth_offset * 0.25)
		var alpha := (0.003 + glow * 0.023 + pulse * 0.012) * (1.0 - amount * 0.48) * presence
		var tint := _mood_tint(0.35 + glow * 0.45 + focus * 0.10)
		tint.a = alpha
		draw_circle(center, radius * spread, tint)

	if depth_offset > 0.05:
		var flare_alpha := (0.015 + glow * 0.08) * depth_offset * presence
		var flare_tint := _mood_tint(0.9)
		flare_tint.a = flare_alpha
		draw_circle(center, radius * (0.85 + depth_offset * 0.15), flare_tint)

## Draws the iris body with a CONCAVE BOWL gradient: concentric rings darken
## by ~35% as they approach the pupil, simulating physical eye depth.
func _draw_iris_body(center: Vector2, radius: float, presence: float, glow: float, breath_wave: float, drift: float, asymmetry: float, pupil_ratio: float) -> void:
	var geometry_scale: float = float(behavior.get("geometry_scale", 1.0))
	var depth_offset: float = float(behavior.get("depth_offset", 0.0))

	# Organic outer silhouette (preserved).
	var segments := roundi(48.0 * geometry_scale)
	var silhouette := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		var ripple := sin(angle * 5.0 + elapsed * 0.47 + asymmetry) * 0.013 * geometry_scale
		ripple += sin(angle * 11.0 - elapsed * 0.19 + asymmetry * 1.7) * 0.006 * geometry_scale
		ripple += sin(angle * 3.0 + elapsed * 0.071) * 0.004
		silhouette.append(center + Vector2(cos(angle), sin(angle)) * radius * (1.07 + ripple))
	var body_tint := _mood_tint(0.18 + glow * 0.08)
	body_tint.a = presence
	draw_colored_polygon(silhouette, body_tint)

	if depth_offset > 0.05:
		var depth_base := _mood_tint(0.12)
		depth_base.a = presence * 0.42
		draw_circle(center, radius * (1.02 + depth_offset * 0.05), depth_base)
		var depth_arc := _mood_tint(0.88)
		depth_arc.a = presence * 0.35 * depth_offset
		draw_arc(center, radius * (0.98 + depth_offset * 0.06), 0.0, TAU, 50, depth_arc, 0.75, true)

	# --- CONCAVE BOWL GRADIENT ---
	# Draw BOWL_RINGS concentric filled circles from the outer rim inward to
	# just outside the pupil. Each ring is darkened progressively (up to ~35%
	# darker at the deepest point) so the eye reads as a recessed bowl, not a
	# flat plate. The mood glow tints the outer rings; the base bed dominates
	# near the pupil.
	var inner_edge := radius * (pupil_ratio + 0.02)
	var span := radius * 1.015 - inner_edge
	for ring in range(BOWL_RINGS):
		var t := float(ring) / float(BOWL_RINGS - 1)  # 0 = outer, 1 = near pupil
		var ring_radius := (radius * 1.015) - span * t
		# Brightness falls off toward the pupil — the concave depth cue.
		var darken := 1.0 - (0.35 * t)  # outer = full, inner = 65% brightness
		var bowl_color := _mood_tint(0.18 + (1.0 - t) * 0.22 + glow * 0.08).darkened(1.0 - darken)
		bowl_color.a = presence * (0.85 + 0.15 * (1.0 - t))
		draw_circle(center, ring_radius, bowl_color)

	# Subtle rim light at the outer edge (catches the cinematic key light).
	var rim_alpha := (0.055 + glow * 0.18) * presence
	for ring in range(2):
		var ring_radius := radius * (0.912 + float(ring) * 0.048)
		var rim_tint := _mood_tint(0.62 + drift * 0.12)
		rim_tint.a = rim_alpha / float(ring + 1)
		draw_arc(center, ring_radius, 0.0, TAU, 40, rim_tint, 0.85, true)

## High-density neural fibers with per-index layering + noise-driven undulation.
## density is already scaled by FIBER_DENSITY_MULTIPLIER (200+ at high states).
func _draw_fibers(center: Vector2, radius: float, pupil_ratio: float, motion: float, density: int, presence: float, glow: float, focus: float, drift: float, asymmetry: float) -> void:
	if density <= 0:
		return
	var inner_base := radius * pupil_ratio * 1.04
	for index in range(density):
		var ratio := float(index) / float(density)
		var fiber_seed := float(index) * 1.618 + asymmetry

		# --- NOISE-DRIVEN UNDULATION (the "swim") ---
		# Sample FastNoiseLite in a slowly-rotating polar field so each fiber
		# moves independently, not just in lockstep breath.
		var noise_phase := elapsed * 0.35
		var n_angle := _noise.get_noise_2d(cos(ratio * TAU) * 2.0 + noise_phase, sin(ratio * TAU) * 2.0)
		var n_length := _noise.get_noise_2d(fiber_seed * 0.5, elapsed * 0.4)
		var angle := ratio * TAU + sin(elapsed * 0.29 + fiber_seed) * 0.050 * motion + n_angle * 0.06 * motion

		var direction := Vector2(cos(angle), sin(angle))
		var tangent := Vector2(-direction.y, direction.x)
		var organic := sin(fiber_seed * 2.13 + elapsed * (0.51 + motion * 1.37))
		organic += sin(fiber_seed * 0.71 - elapsed * 0.17) * 0.34
		organic += n_length * 0.4  # noise adds organic, non-periodic variation

		var inner := inner_base * (0.91 + 0.16 * sin(fiber_seed * 1.63))
		# Fiber length also modulated by noise — some fibers reach further than others.
		var length_mod := 1.0 + n_length * 0.18 * motion
		var outer := radius * (0.62 + 0.27 * (sin(fiber_seed * 0.79 + drift) * 0.5 + 0.5)) * length_mod
		var first_bend := radius * (0.012 + motion * 0.044) * organic
		var second_bend := radius * (0.008 + motion * 0.030) * sin(fiber_seed * 3.73 - elapsed * 0.41)
		var first := center + direction * inner
		var second := center + direction * lerpf(inner, outer, 0.30) + tangent * first_bend
		var third := center + direction * lerpf(inner, outer, 0.68) + tangent * second_bend
		var fourth := center + direction * outer + tangent * second_bend * 0.22

		# --- PER-INDEX LAYERING (faint/deep vs bright/surface) ---
		# A slow sine across indices creates "depth bands" of fibers: some are
		# faint and deep, others bright and surface-level — the layered look.
		var bright := 0.32 + 0.68 * (sin(fiber_seed * 4.17 + elapsed * 1.09 + drift) * 0.5 + 0.5)
		var depth_band := 0.6 + 0.4 * sin(fiber_seed * 0.93)
		var alpha := (0.020 + glow * 0.17 + focus * 0.035) * bright * depth_band * presence
		var fiber_color := _mood_tint(0.22 + bright * 0.65)
		fiber_color.a = alpha
		# Width varies per index — thin faint fibers + occasional bold surface ones.
		var width := (0.32 + bright * 0.54 + focus * 0.14) * depth_band
		# Anti-alias the faint fibers; keep the bright ones crisp.
		var antialias := bright < 0.55
		draw_line(first, second, fiber_color, width, antialias)
		draw_line(second, third, fiber_color, width * 0.74, antialias)
		# Only the brighter fibers get a third segment (the "fringe tips").
		if bright > 0.55:
			draw_line(third, fourth, fiber_color, width * 0.5, antialias)

func _draw_pupil(center: Vector2, radius: float, pupil_ratio: float, presence: float, glow: float, focus: float, breath_wave: float, pulse: float) -> void:
	var biological_pulse: float = float(behavior.get("biological_pulse", 1.0))
	var pupil_radius := radius * pupil_ratio * lerpf(1.0, 2.48, portal_dilation)
	var corona_alpha := (0.06 + glow * 0.18 + pulse * 0.08) * presence
	var corona := _mood_tint(0.72)
	corona.a = corona_alpha
	draw_circle(center, pupil_radius * (1.28 + pulse * 0.06), corona)
	# Recessed pupil — extra-dark ring + deep center sells the "depth" of the bowl.
	draw_circle(center, pupil_radius * 1.11, Color(0.004, 0.018, 0.029, 0.98 * presence))
	draw_circle(center, pupil_radius, Color(0.001, 0.004, 0.009, presence))

	var glint_position := center + Vector2(-radius * (0.24 - focus * 0.045), -radius * 0.255)
	var glint_radius := radius * (0.062 + breath_wave * 0.016 + pulse * 0.012) * biological_pulse
	var primary_glint := _mood_glow.lightened(0.4)
	primary_glint.a = (0.12 + glow * 0.38) * presence
	draw_circle(glint_position, glint_radius, primary_glint)
	var secondary_glint := _mood_glow.lightened(0.7)
	secondary_glint.a = 0.72 * presence
	draw_circle(glint_position + Vector2(-radius * 0.017, -radius * 0.017), glint_radius * 0.32, secondary_glint)
	var accent := _mood_glow.darkened(0.2)
	accent.a = (0.08 + glow * 0.24) * presence
	draw_circle(center + Vector2(radius * 0.14, radius * 0.18), radius * 0.017, accent)

	if behavior.has("full_evolution_flare"):
		var flare := _mood_glow.lightened(0.6)
		flare.a = presence * 0.5
		draw_arc(center, radius * 0.42, 0.0, TAU, 60, flare, 1.2, true)

## Procedural eyelid shutters — two arcs (upper + lower) that close over the
## aperture driven by blink_amount. Semi-transparent teal-tinted, biologically
## curved. openness = 0 -> fully closed; 1 -> fully open (arcs parked at edges).
func _draw_eyelids(center: Vector2, radius: float, presence: float, blink: float, focus: float) -> void:
	if blink <= 0.01:
		return  # eyes open — no shutter drawn (saves fill rate)
	# blink 0..1 -> lid coverage 0..~0.6 of the radius past the centerline.
	var coverage := clampf(blink, 0.0, 1.0) * 0.62
	# Lid color: a muted teal-tinted membrane, brighter at the leading edge.
	var lid_base := _mood_tint(0.12)
	var lid_edge := _mood_tint(0.45 + focus * 0.1)
	# Upper lid: a filled chord sweeping down from the top.
	_draw_lid_arc(center, radius, coverage, true, presence, lid_base, lid_edge)
	# Lower lid: mirrors from the bottom.
	_draw_lid_arc(center, radius, coverage, false, presence, lid_base, lid_edge)

func _draw_lid_arc(center: Vector2, radius: float, coverage: float, upper: bool, presence: float, base_col: Color, edge_col: Color) -> void:
	# Build a filled "lid" as a polygon: an arc along the outer rim plus a chord
	# across at the coverage depth.
	var r := radius * 1.12
	var half_arc := coverage * PI  # how much of the upper/lower hemisphere is covered
	var start_a := (-PI / 2.0) - half_arc if upper else (PI / 2.0) - half_arc
	var end_a := (-PI / 2.0) + half_arc if upper else (PI / 2.0) + half_arc
	var pts := PackedVector2Array()
	var steps := 18
	# Outer rim points
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var a := lerpf(start_a, end_a, t)
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	# Chord across (the lid's leading edge)
	var chord_y := center.y + (radius * (0.06 - coverage * 1.1) * (1.0 if upper else -1.0))
	# Close the polygon back along the chord
	pts.append(center + Vector2(cos(end_a), sin(end_a)) * r * 0.2)
	pts.append(center + Vector2(cos(start_a), sin(start_a)) * r * 0.2)
	var lid_color := base_col.lerp(edge_col, 0.3)
	lid_color.a = presence * 0.92
	draw_colored_polygon(pts, lid_color)
	# Leading edge highlight — a crisp arc along the chord for definition.
	var edge_a := presence * 0.55
	edge_col.a = edge_a
	var edge_start := center + Vector2(cos(start_a), sin(start_a)) * r
	var edge_end := center + Vector2(cos(end_a), sin(end_a)) * r
	draw_line(edge_start, edge_end, edge_col, 1.6, true)

func _draw_reflections(center: Vector2, radius: float, amount: float, drift: float) -> void:
	for index in range(3):
		var angle := elapsed * (0.19 + float(index) * 0.037) + float(index) * TAU / 3.0 + drift
		var start := center + Vector2(cos(angle), sin(angle)) * radius * 0.47
		var end := center + Vector2(cos(angle + 0.21), sin(angle + 0.21)) * radius * 0.78
		var refl := _mood_glow.lightened(0.35)
		refl.a = amount * 0.17
		draw_line(start, end, refl, 0.9, true)

func _draw_calibration(center: Vector2, radius: float, amount: float) -> void:
	var calibration_radius := radius * (0.54 + sin(elapsed * 2.7) * 0.05)
	var cal := _mood_glow.lightened(0.5)
	cal.a = amount * 0.21
	draw_arc(center, calibration_radius, 0.0, TAU, 40, cal, 0.9, true)

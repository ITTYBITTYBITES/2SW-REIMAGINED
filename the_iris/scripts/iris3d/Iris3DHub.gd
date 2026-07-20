extends Control
class_name Iris3DHub

## Iris3DHub — the 3D reconstruction of the Living Iris (V4.0).
##
## Replaces the flat 2D _draw() system with a genuine 3D organ inside a
## SubViewport. Four depth layers (back to front):
##   1. Pupil (the Void) — a literal hole in the stroma (shader alpha)
##   2. Stroma (the Muscle) — concave bowl mesh + Simplex-noise fiber shader
##   3. Eyelids (Biological Shutters) — two almond meshes driven by IrisCore blink
##   4. Cornea (Glass) — transparent dome + fixed specular glint (parallax)
##
## Driven by the EXISTING IrisCore 11-state machine (preserved brain).
## All visual/behavioral params are @export for calibration.
## Architecture: SubViewportContainer → SubViewport (transparent) → Node3D.

# --- Calibration (@export for VISUAL_CALIBRATION_GUIDE.md) ---
@export_group("Stroma")
@export var stroma_color: Color = Color(0.020, 0.045, 0.075)
@export var glow_color: Color = Color(0.20, 0.62, 0.78)
@export var glow_energy: float = 0.8
@export var fiber_density: float = 40.0
@export var fiber_swim: float = 0.6
@export var depth_intensity: float = 0.8

@export_group("Pupil")
@export var base_dilation: float = 0.30
@export var dilation_speed: float = 3.0
@export var hippus_amplitude: float = 0.02
@export var hippus_speed: float = 1.2

@export_group("Eyelids")
@export var blink_frequency_min: float = 3.5
@export var blink_frequency_max: float = 8.0
@export var blink_duration: float = 0.18
@export var lid_color: Color = Color(0.015, 0.04, 0.06)
@export var lid_margin_color: Color = Color(0.25, 0.55, 0.50)
@export var resting_upper_coverage: float = 0.15
@export var resting_lower_coverage: float = 0.06

@export_group("Cornea")
@export var glass_alpha: float = 0.12
@export var glass_roughness: float = 0.05
@export var glint_intensity: float = 1.8

@export_group("Camera")
@export var camera_fov: float = 32.0
@export var camera_distance: float = 7.0
@export var parallax_strength: float = 0.08

@export_group("Lighting")
@export var key_light_energy: float = 1.2
@export var key_light_color: Color = Color(0.9, 0.95, 1.0)
@export var ambient_energy: float = 0.4

# --- Brain connection ---
var core: IrisCore
var evolution_profile: IrisEvolutionProfile
var portal_dilation := 0.0
var elapsed := 0.0

# --- 3D scene nodes ---
var _viewport_container: SubViewportContainer
var _viewport: SubViewport
var _world: Node3D
var _camera: Camera3D
var _key_light: DirectionalLight3D
var _ambient_light: WorldEnvironment
var _stroma_mesh: MeshInstance3D
var _stroma_mat: ShaderMaterial
var _cornea_mesh: MeshInstance3D
var _cornea_mat: ShaderMaterial
var _upper_lid: MeshInstance3D
var _lower_lid: MeshInstance3D
var _upper_lid_mat: StandardMaterial3D
var _lower_lid_mat: StandardMaterial3D
var _eye_root: Node3D  # all iris content pivots from here (for gaze/parallax)

# --- Blink state ---
var _blink_timer: float = 4.0
var _blink_phase: float = -1.0  # -1 = open, 0..1 = closing/opening
var _gaze_target: Vector2 = Vector2.ZERO
var _current_gaze: Vector2 = Vector2.ZERO
var _hippus_rng := RandomNumberGenerator.new()

# --- Portal zoom state (the threshold transition) ---
signal portal_zoom_requested
signal portal_zoom_complete
var _portal_zooming: bool = false
var _portal_zoom_t: float = 0.0
const PORTAL_ZOOM_DURATION := 1.2
var _portal_zoom_from: float = 7.0
var _portal_zoom_to: float = -0.5  # past the pupil mesh

# --- Mood colors (driven by IrisCore mood system) ---
var _mood_base := Color(0.020, 0.045, 0.075)
var _mood_glow := Color(0.20, 0.62, 0.78)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hippus_rng.randomize()
	_build_3d_scene()

func set_core(value: IrisCore) -> void:
	core = value

func _build_3d_scene() -> void:
	# SubViewportContainer (transparent, stretches to fill)
	_viewport_container = SubViewportContainer.new()
	_viewport_container.name = "IrisViewportContainer"
	_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport_container.stretch = true
	_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_viewport_container)

	# SubViewport (own 3D world, transparent background)
	_viewport = SubViewport.new()
	_viewport.name = "IrisViewport"
	_viewport.size = Vector2i(540, 960)
	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport_container.add_child(_viewport)

	# Node3D world
	_world = Node3D.new()
	_world.name = "IrisWorld"
	_viewport.add_child(_world)

	# Eye root (pivots for gaze/parallax)
	_eye_root = Node3D.new()
	_eye_root.name = "EyeRoot"
	_world.add_child(_eye_root)

	# Camera
	_camera = Camera3D.new()
	_camera.name = "IrisCamera"
	_camera.fov = camera_fov
	_camera.position = Vector3(0.0, 0.0, camera_distance)
	_camera.current = true
	_world.add_child(_camera)

	# Key light (upper-left, creates the specular glint on the cornea)
	_key_light = DirectionalLight3D.new()
	_key_light.name = "KeyLight"
	_key_light.rotation_degrees = Vector3(-35.0, 30.0, 0.0)
	_key_light.light_energy = key_light_energy
	_key_light.light_color = key_light_color
	_key_light.shadow_enabled = false
	_world.add_child(_key_light)

	# Ambient environment
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.004, 0.008, 0.014, 0.0)  # transparent
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.1, 0.15, 0.2)
	env.ambient_light_energy = ambient_energy
	env.fog_enabled = false
	_ambient_light = WorldEnvironment.new()
	_ambient_light.environment = env
	_world.add_child(_ambient_light)

	# --- LAYER 2: STROMA (concave bowl + fiber shader) ---
	_stroma_mesh = MeshInstance3D.new()
	_stroma_mesh.name = "Stroma"
	_stroma_mesh.mesh = _build_concave_bowl(1.0, 0.35, 64, 16)
	var stroma_shader := load("res://shaders/stroma_fibers.gdshader")
	if stroma_shader is Shader:
		_stroma_mat = ShaderMaterial.new()
		_stroma_mat.shader = stroma_shader
	_stroma_mesh.material_override = _stroma_mat
	_eye_root.add_child(_stroma_mesh)

	# --- LAYER 4: CORNEA (transparent glass dome + specular glint) ---
	_cornea_mesh = MeshInstance3D.new()
	_cornea_mesh.name = "Cornea"
	_cornea_mesh.mesh = _build_sphere_cap(1.08, 0.55, 48)
	var cornea_shader := load("res://shaders/cornea_glass.gdshader")
	if cornea_shader is Shader:
		_cornea_mat = ShaderMaterial.new()
		_cornea_mat.shader = cornea_shader
		_cornea_mat.render_priority = 2
	_cornea_mesh.material_override = _cornea_mat
	_eye_root.add_child(_cornea_mesh)

	# --- LAYER 3: EYELIDS (biological shutters) ---
	_upper_lid = MeshInstance3D.new()
	_upper_lid.name = "UpperLid"
	_upper_lid.mesh = _build_lid_mesh(1.15, true)
	_upper_lid_mat = StandardMaterial3D.new()
	_upper_lid_mat.albedo_color = lid_color
	_upper_lid_mat.roughness = 0.6
	_upper_lid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_upper_lid.material_override = _upper_lid_mat
	_eye_root.add_child(_upper_lid)

	_lower_lid = MeshInstance3D.new()
	_lower_lid.name = "LowerLid"
	_lower_lid.mesh = _build_lid_mesh(1.15, false)
	_lower_lid_mat = StandardMaterial3D.new()
	_lower_lid_mat.albedo_color = lid_color
	_lower_lid_mat.roughness = 0.6
	_lower_lid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_lower_lid.material_override = _lower_lid_mat
	_eye_root.add_child(_lower_lid)

	# Initialize shader uniforms
	_push_shader_params()


# --- Procedural mesh builders ---

## Concave bowl (paraboloid): deepest at center, rises toward the rim.
## The stroma fiber shader runs on this mesh.
func _build_concave_bowl(radius: float, depth: float, radial_seg: int, ring_count: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for ring in range(ring_count + 1):
		var rt := float(ring) / float(ring_count)  # 0 = center, 1 = rim
		var r := radius * rt
		var z := -depth * (1.0 - rt * rt)  # paraboloid: deepest at center
		var u := 0.5 + 0.5 * rt  # UV: center=0.5, edge=1.0
		for seg in range(radial_seg):
			var ang := TAU * float(seg) / float(radial_seg)
			var ang_next := TAU * float(seg + 1) / float(radial_seg)
			var uv_ang := float(seg) / float(radial_seg)
			var uv_ang_next := float(seg + 1) / float(radial_seg)
			if ring < ring_count:
				var rt2 := float(ring + 1) / float(ring_count)
				var r2 := radius * rt2
				var z2 := -depth * (1.0 - rt2 * rt2)
				var u2 := 0.5 + 0.5 * rt2
				# Two triangles per quad
				# Center vertex (current ring)
				var v1 := Vector3(cos(ang) * r, sin(ang) * r, z)
				var v2 := Vector3(cos(ang_next) * r, sin(ang_next) * r, z)
				var v3 := Vector3(cos(ang_next) * r2, sin(ang_next) * r2, z2)
				var v4 := Vector3(cos(ang) * r2, sin(ang) * r2, z2)
				st.set_uv(Vector2(uv_ang + 0.5 * u, u))
				st.add_vertex(v1)
				st.set_uv(Vector2(uv_ang_next + 0.5 * u, u))
				st.add_vertex(v2)
				st.set_uv(Vector2(uv_ang_next + 0.5 * u2, u2))
				st.add_vertex(v3)
				st.set_uv(Vector2(uv_ang + 0.5 * u, u))
				st.add_vertex(v1)
				st.set_uv(Vector2(uv_ang_next + 0.5 * u2, u2))
				st.add_vertex(v3)
				st.set_uv(Vector2(uv_ang + 0.5 * u2, u2))
				st.add_vertex(v4)
	st.index()
	st.generate_normals()
	return st.commit()

## Sphere cap: the front portion of a sphere (for the cornea glass dome).
func _build_sphere_cap(radius: float, coverage: float, segments: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_segs: int = int(float(segments) * 0.5)
	for ring in range(half_segs):
		var phi1 := (float(ring) / float(half_segs)) * coverage * PI
		var phi2 := (float(ring + 1) / float(half_segs)) * coverage * PI
		for seg in range(segments):
			var theta1 := TAU * float(seg) / float(segments)
			var theta2 := TAU * float(seg + 1) / float(segments)
			var v1 := Vector3(
				radius * sin(phi1) * cos(theta1),
				radius * sin(phi1) * sin(theta1),
				radius * cos(phi1)
			)
			var v2 := Vector3(
				radius * sin(phi1) * cos(theta2),
				radius * sin(phi1) * sin(theta2),
				radius * cos(phi1)
			)
			var v3 := Vector3(
				radius * sin(phi2) * cos(theta2),
				radius * sin(phi2) * sin(theta2),
				radius * cos(phi2)
			)
			var v4 := Vector3(
				radius * sin(phi2) * cos(theta1),
				radius * sin(phi2) * sin(theta1),
				radius * cos(phi2)
			)
			st.set_uv(Vector2(float(seg) / float(segments), float(ring) / float(segments)))
			st.add_vertex(v1)
			st.set_uv(Vector2(float(seg + 1) / float(segments), float(ring) / float(segments)))
			st.add_vertex(v2)
			st.set_uv(Vector2(float(seg + 1) / float(segments), float(ring + 1) / float(segments)))
			st.add_vertex(v3)
			st.set_uv(Vector2(float(seg) / float(segments), float(ring) / float(segments)))
			st.add_vertex(v1)
			st.set_uv(Vector2(float(seg + 1) / float(segments), float(ring + 1) / float(segments)))
			st.add_vertex(v3)
			st.set_uv(Vector2(float(seg) / float(segments), float(ring + 1) / float(segments)))
			st.add_vertex(v4)
	st.index()
	st.generate_normals()
	return st.commit()

## Eyelid mesh: a thin curved shell shaped like an almond edge.
## Positioned to occlude the top (upper=true) or bottom (upper=false) of the iris.
func _build_lid_mesh(radius: float, upper: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sign_y := -1.0 if upper else 1.0
	var width := radius * 1.3
	var height := radius * 0.5
	var seg := 24
	# Build a curved shell that arcs over the iris
	for i in range(seg):
		var t1 := float(i) / float(seg)
		var t2 := float(i + 1) / float(seg)
		# Arc from left (-width) to right (+width), curving upward (upper) or downward
		var x1 := lerpf(-width, width, t1)
		var x2 := lerpf(-width, width, t2)
		# Parabolic curve: y = sign_y * height * (1 - (x/width)^2) for the leading edge
		var y1 := sign_y * height * (1.0 - (x1 / width) * (x1 / width))
		var y2 := sign_y * height * (1.0 - (x2 / width) * (x2 / width))
		# The lid extends further outward (behind the iris plane)
		var y1_outer := sign_y * height * 1.5 * (1.0 - (x1 / width) * (x1 / width)) - sign_y * 0.1
		var y2_outer := sign_y * height * 1.5 * (1.0 - (x2 / width) * (x2 / width)) - sign_y * 0.1
		var z_front := 0.05
		var z_back := -0.15
		# Front face quad (the visible lid surface)
		st.set_uv(Vector2(t1, 0.0))
		st.add_vertex(Vector3(x1, y1, z_front))
		st.set_uv(Vector2(t2, 0.0))
		st.add_vertex(Vector3(x2, y2, z_front))
		st.set_uv(Vector2(t2, 1.0))
		st.add_vertex(Vector3(x2, y2_outer, z_back))
		st.set_uv(Vector2(t1, 0.0))
		st.add_vertex(Vector3(x1, y1, z_front))
		st.set_uv(Vector2(t2, 1.0))
		st.add_vertex(Vector3(x2, y2_outer, z_back))
		st.set_uv(Vector2(t1, 1.0))
		st.add_vertex(Vector3(x1, y1_outer, z_back))
	st.index()
	st.generate_normals()
	return st.commit()


# --- Per-frame update ---

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	if core != null:
		var base_behavior := core.tick(delta)
		if evolution_profile != null:
			base_behavior = IrisEvolutionVisualConsumer.apply_evolution(evolution_profile, base_behavior)
		_drive_from_behavior(base_behavior, delta)
	_update_portal_zoom(delta)
	_push_shader_params()

func _drive_from_behavior(b: Dictionary, delta: float) -> void:
	# Mood colors
	_mood_base = b.get("mood_base_color", _mood_base)
	_mood_glow = b.get("mood_glow_color", _mood_glow)
	glow_energy = lerpf(glow_energy, float(b.get("mood_energy", 0.5)) * 0.9, delta * 2.0)
	stroma_color = _mood_base
	glow_color = _mood_glow

	# Pupil dilation from IrisCore's pupil value + hippus (heartbeat pulse)
	var core_pupil := float(b.get("pupil", 0.36))
	var hippus := sin(elapsed * hippus_speed * TAU) * hippus_amplitude
	var target_dilation := base_dilation + (core_pupil - 0.36) * 0.8 + hippus
	target_dilation = clampf(target_dilation, 0.08, 0.7)
	base_dilation = lerpf(base_dilation, target_dilation, delta * dilation_speed)

	# Portal dilation (the IrisPortalTransition opens the pupil for entry)
	var effective_dilation := base_dilation * lerpf(1.0, 2.8, portal_dilation)

	# Gaze / saccades — move the eye root to look at the gaze target
	_gaze_target = b.get("gaze", Vector2.ZERO)
	_current_gaze = _current_gaze.lerp(_gaze_target, delta * 5.0)
	var gaze_offset := _current_gaze * parallax_strength
	_eye_root.position = Vector3(gaze_offset.x, -gaze_offset.y, 0.0)
	# Translate only — NEVER look_at (flips bowl away from camera = 1000% mag)
	_eye_root.rotation = Vector3.ZERO

	# Blink — drive eyelid coverage from IrisCore blink + autonomous blink timer
	var core_blink := float(b.get("blink", 0.0))
	_update_autonomous_blink(delta)
	var blink_amount := maxf(core_blink, _blink_phase_to_coverage())
	_drive_eyelids(blink_amount, float(b.get("focus", 0.0)))

	# Update shader dilation
	if _stroma_mat:
		_stroma_mat.set_shader_parameter("dilation", effective_dilation)

func _update_autonomous_blink(delta: float) -> void:
	if _blink_phase < 0.0:
		# Counting down to next blink
		_blink_timer -= delta
		if _blink_timer <= 0.0:
			_blink_phase = 0.0
			_blink_timer = randf_range(blink_frequency_min, blink_frequency_max)
	else:
		# Blink in progress (0 -> 1 -> complete)
		_blink_phase += delta / blink_duration
		if _blink_phase >= 1.0:
			_blink_phase = -1.0

func _blink_phase_to_coverage() -> float:
	# 0 -> 0.5 = closing (coverage ramps 0 -> 1), 0.5 -> 1.0 = opening (1 -> 0)
	if _blink_phase < 0.0:
		return 0.0
	if _blink_phase < 0.5:
		return smoothstep(0.0, 0.5, _blink_phase)
	return smoothstep(1.0, 0.5, _blink_phase)

func _drive_eyelids(blink_amount: float, focus: float) -> void:
	# ALMOND APERTURE: the lids permanently frame the circular iris into a
	# wider-than-tall almond shape. At rest (blink=0), the upper lid covers the
	# top ~30% and the lower lid covers the bottom ~12% of the iris.
	var upper_rest_cov := 0.28 + resting_upper_coverage  # ~0.43 total
	var lower_rest_cov := 0.06 + resting_lower_coverage  # ~0.12 total
	var upper_cov := clampf(upper_rest_cov + blink_amount * 0.50, 0.0, 0.95)
	var lower_cov := clampf(lower_rest_cov + blink_amount * 0.55, 0.0, 0.95)
	# Slide lids to occlude the iris top/bottom. The lid mesh arcs over the
	# iris; positioning it higher (upper) or lower (lower) increases coverage.
	_upper_lid.position.y = lerpf(0.15, 1.15, upper_cov)
	_lower_lid.position.y = lerpf(-0.05, -1.15, lower_cov)
	# Squint on focus — narrows the almond vertically
	var squint := 1.0 - focus * 0.10
	_upper_lid.position.y *= squint
	_lower_lid.position.y *= squint
	# Lid margin color brightens with focus
	var margin := lid_margin_color.lerp(glow_color, focus * 0.3)
	_upper_lid_mat.albedo_color = lid_color.lerp(margin, 0.15)
	_lower_lid_mat.albedo_color = lid_color.lerp(margin, 0.15)

## Begin the portal zoom: camera flies from distance 7.0 through the pupil.
## Fires portal_zoom_requested when the camera crosses the pupil threshold,
## then portal_zoom_complete when the zoom finishes.
func begin_portal_zoom() -> void:
	if _portal_zooming:
		return
	_portal_zooming = true
	_portal_zoom_t = 0.0
	_portal_zoom_from = camera_distance

func _update_portal_zoom(delta: float) -> void:
	if not _portal_zooming:
		return
	_portal_zoom_t += delta / PORTAL_ZOOM_DURATION
	var t := clampf(_portal_zoom_t, 0.0, 1.0)
	# Ease in — accelerate into the pupil
	var eased := t * t
	_camera.position.z = lerpf(_portal_zoom_from, _portal_zoom_to, eased)
	# Trigger the experience load at the threshold (camera passes the pupil)
	if t >= 0.65 and not _portal_threshold_fired:
		_portal_threshold_fired = true
		portal_zoom_requested.emit()
	if t >= 1.0:
		_portal_zooming = false
		portal_zoom_complete.emit()

var _portal_threshold_fired := false

func _push_shader_params() -> void:
	if _stroma_mat:
		_stroma_mat.set_shader_parameter("stroma_color", stroma_color)
		_stroma_mat.set_shader_parameter("glow_color", glow_color)
		_stroma_mat.set_shader_parameter("glow_energy", glow_energy)
		_stroma_mat.set_shader_parameter("fiber_density", fiber_density)
		_stroma_mat.set_shader_parameter("fiber_swim", fiber_swim)
		_stroma_mat.set_shader_parameter("depth_intensity", depth_intensity)
		_stroma_mat.set_shader_parameter("time", elapsed)
	if _cornea_mat:
		_cornea_mat.set_shader_parameter("glass_alpha", glass_alpha)
		_cornea_mat.set_shader_parameter("glass_roughness", glass_roughness)
		_cornea_mat.set_shader_parameter("glint_intensity", glint_intensity)
		_cornea_mat.set_shader_parameter("tint", Color(0.8, 0.95, 1.0))

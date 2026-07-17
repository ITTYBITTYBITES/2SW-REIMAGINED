extends Control
class_name LivingIris3D

## Living 3D Iris foundation.
## Presentation-only layer: it consumes runtime/progression state and never owns gameplay progression.

enum QualityTier { LOW, MEDIUM, HIGH }

@export var quality_tier: QualityTier = QualityTier.MEDIUM
@export var eye_radius := 1.12
@export var iris_radius := 0.42
@export var pupil_radius := 0.16

var viewport_container: SubViewportContainer
var viewport: SubViewport
var eye_root: Node3D
var eye_model: Node3D
var camera: Camera3D
var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var sclera: MeshInstance3D
var cornea: MeshInstance3D
var iris_disc: MeshInstance3D
var pupil_disc: MeshInstance3D
var memory_shards: Node3D
var shard_nodes: Array[MeshInstance3D] = []

var elapsed := 0.0
var transition_open := 0.0
var target_transition_open := 0.0
var progression_level := 0
var glow_strength := 0.45
var energy := 0.0
var pupil_open := 0.105
var gaze_target := Vector2(0.5, 0.5)
var current_gaze := Vector2(0.5, 0.5)
var blink_amount := 0.0
var quality_label := "MEDIUM"

var mat_sclera: StandardMaterial3D
var mat_cornea: StandardMaterial3D
var mat_iris: StandardMaterial3D
var mat_pupil: StandardMaterial3D
var mat_shard: StandardMaterial3D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_viewport()
	_build_eye_scene()
	apply_quality_tier(quality_tier)
	set_process(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_viewport_size()
		_update_camera_for_size()

func _process(delta: float) -> void:
	elapsed += delta
	transition_open = lerpf(transition_open, target_transition_open, minf(1.0, delta * 5.0))
	current_gaze = current_gaze.lerp(gaze_target, minf(1.0, delta * 4.0))
	_update_eye_animation(delta)
	_update_memory_shards()

func _build_viewport() -> void:
	viewport_container = SubViewportContainer.new()
	viewport_container.name = "SubViewportContainer"
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport_container.stretch = false
	add_child(viewport_container)

	viewport = SubViewport.new()
	viewport.name = "SubViewport"
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.disable_3d = false
	viewport_container.add_child(viewport)
	_update_viewport_size()

func _build_eye_scene() -> void:
	eye_root = Node3D.new()
	eye_root.name = "EyeRoot"
	viewport.add_child(eye_root)

	world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.18, 0.32, 0.34)
	env.ambient_light_energy = 0.8
	world_environment.environment = env
	eye_root.add_child(world_environment)

	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0, 0, 4.6)
	camera.fov = 34.0
	camera.current = true
	eye_root.add_child(camera)
	camera.look_at_from_position(camera.position, Vector3.ZERO, Vector3.UP)

	key_light = DirectionalLight3D.new()
	key_light.name = "KeyLight"
	key_light.rotation_degrees = Vector3(-35, 25, 0)
	key_light.light_energy = 1.2
	eye_root.add_child(key_light)

	fill_light = OmniLight3D.new()
	fill_light.name = "GazeLight"
	fill_light.position = Vector3(0.55, 0.55, 2.2)
	fill_light.light_color = Color(0.50, 0.95, 0.86)
	fill_light.light_energy = 0.7
	fill_light.omni_range = 5.0
	eye_root.add_child(fill_light)

	eye_model = Node3D.new()
	eye_model.name = "EyeModel"
	eye_root.add_child(eye_model)

	mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.62, 0.92, 0.86, 0.30)
	mat_sclera.roughness = 0.38
	mat_sclera.metallic = 0.0
	mat_sclera.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_sclera.emission_enabled = true
	mat_sclera.emission = Color(0.08, 0.24, 0.22)
	mat_sclera.emission_energy_multiplier = 0.28

	mat_cornea = StandardMaterial3D.new()
	mat_cornea.albedo_color = Color(0.85, 1.0, 0.96, 0.18)
	mat_cornea.roughness = 0.05
	mat_cornea.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_cornea.emission_enabled = true
	mat_cornea.emission = Color(0.10, 0.34, 0.32)
	mat_cornea.emission_energy_multiplier = 0.12

	mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = Color(0.08, 0.62, 0.55, 0.94)
	mat_iris.roughness = 0.52
	mat_iris.emission_enabled = true
	mat_iris.emission = Color(0.10, 0.55, 0.48)
	mat_iris.emission_energy_multiplier = 0.45

	mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.005, 0.012, 0.018, 1.0)
	mat_pupil.roughness = 0.12
	mat_pupil.emission_enabled = true
	mat_pupil.emission = Color(0.02, 0.06, 0.08)
	mat_pupil.emission_energy_multiplier = 0.55

	mat_shard = StandardMaterial3D.new()
	mat_shard.albedo_color = Color(0.80, 0.95, 0.88, 0.82)
	mat_shard.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_shard.emission_enabled = true
	mat_shard.emission = Color(0.25, 0.80, 0.68)
	mat_shard.emission_energy_multiplier = 0.45

	sclera = MeshInstance3D.new()
	sclera.name = "ScleraVolume"
	var sclera_mesh := SphereMesh.new()
	sclera_mesh.radius = eye_radius
	sclera_mesh.height = eye_radius * 2.0
	sclera_mesh.radial_segments = 32
	sclera_mesh.rings = 16
	sclera.mesh = sclera_mesh
	sclera.material_override = mat_sclera
	eye_model.add_child(sclera)

	iris_disc = MeshInstance3D.new()
	iris_disc.name = "IrisMaterialSurface"
	var iris_mesh := QuadMesh.new()
	iris_mesh.size = Vector2(iris_radius * 2.0, iris_radius * 2.0)
	iris_disc.mesh = iris_mesh
	iris_disc.position = Vector3(0, 0, eye_radius + 0.012)
	iris_disc.material_override = mat_iris
	eye_model.add_child(iris_disc)

	pupil_disc = MeshInstance3D.new()
	pupil_disc.name = "PupilPortal"
	var pupil_mesh := QuadMesh.new()
	pupil_mesh.size = Vector2(pupil_radius * 2.0, pupil_radius * 2.0)
	pupil_disc.mesh = pupil_mesh
	pupil_disc.position = Vector3(0, 0, eye_radius + 0.018)
	pupil_disc.material_override = mat_pupil
	eye_model.add_child(pupil_disc)

	cornea = MeshInstance3D.new()
	cornea.name = "CorneaSurface"
	var cornea_mesh := SphereMesh.new()
	cornea_mesh.radius = eye_radius * 1.018
	cornea_mesh.height = eye_radius * 2.036
	cornea_mesh.radial_segments = 32
	cornea_mesh.rings = 16
	cornea.mesh = cornea_mesh
	cornea.material_override = mat_cornea
	eye_model.add_child(cornea)

	memory_shards = Node3D.new()
	memory_shards.name = "MemoryShards"
	eye_model.add_child(memory_shards)
	_build_memory_shards(5)
	_update_camera_for_size()

func _build_memory_shards(count: int) -> void:
	if not is_instance_valid(memory_shards):
		return
	for shard in shard_nodes:
		if is_instance_valid(shard):
			shard.queue_free()
	shard_nodes.clear()
	for i in range(count):
		var shard := MeshInstance3D.new()
		shard.name = "MemoryShard_%d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.08, 0.14, 0.025)
		shard.mesh = mesh
		shard.material_override = mat_shard
		memory_shards.add_child(shard)
		shard_nodes.append(shard)

func apply_quality_tier(tier: int) -> void:
	quality_tier = tier
	match quality_tier:
		QualityTier.LOW:
			quality_label = "LOW"
			_build_memory_shards(2)
			cornea.visible = false
			fill_light.visible = false
			key_light.light_energy = 0.85
		QualityTier.HIGH:
			quality_label = "HIGH"
			_build_memory_shards(8)
			cornea.visible = true
			fill_light.visible = true
			key_light.light_energy = 1.35
		_:
			quality_label = "MEDIUM"
			_build_memory_shards(5)
			cornea.visible = true
			fill_light.visible = true
			key_light.light_energy = 1.1

func set_quality_level(value: String) -> void:
	match value.to_upper():
		"LOW": apply_quality_tier(QualityTier.LOW)
		"HIGH": apply_quality_tier(QualityTier.HIGH)
		_: apply_quality_tier(QualityTier.MEDIUM)

func update_visual_state(state: Dictionary) -> void:
	progression_level = int(state.get("progression_level", progression_level))
	glow_strength = float(state.get("glow_strength", glow_strength))
	energy = float(state.get("energy", energy))
	pupil_open = float(state.get("pupil_open", pupil_open))
	blink_amount = float(state.get("blink_amount", blink_amount))
	var gaze_value: Variant = state.get("gaze_target", gaze_target)
	if gaze_value is Vector2:
		gaze_target = gaze_value
	set_transition_open(float(state.get("transition_open", target_transition_open)))

func set_iris_evolution_state(evolution_state: Dictionary) -> void:
	var completed := int(evolution_state.get("completed_moment_count", evolution_state.get("completed_incident_count", progression_level)))
	progression_level = clampi(completed, 0, 8)
	glow_strength = clampf(0.40 + float(evolution_state.get("total_progress", 0)) / 250.0, 0.35, 1.35)
	_update_materials()

func set_transition_open(value: float) -> void:
	target_transition_open = clampf(value, 0.0, 1.0)

func get_quality_label() -> String:
	return quality_label

func _update_viewport_size() -> void:
	if viewport == null:
		return
	var vp_size := size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		vp_size = Vector2(540, 960)
	viewport.size = Vector2i(maxi(int(vp_size.x), 1), maxi(int(vp_size.y), 1))

func _update_camera_for_size() -> void:
	if camera == null:
		return
	var vp_size := size
	var landscape := vp_size.x > vp_size.y
	var aspect := vp_size.x / maxf(vp_size.y, 1.0)
	camera.fov = 30.0 if landscape else 34.0
	camera.position.z = 4.0 + clampf(absf(aspect - 0.5625), 0.0, 1.0) * 0.75
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _update_eye_animation(_delta: float) -> void:
	if eye_model == null:
		return
	var gaze_delta := (current_gaze - Vector2(0.5, 0.5))
	var breathe := sin(elapsed * 0.85) * 0.018
	var transition_push := transition_open * 1.35
	eye_model.rotation_degrees = Vector3(gaze_delta.y * -9.0, gaze_delta.x * 12.0, sin(elapsed * 0.28) * 1.2)
	eye_model.scale = Vector3.ONE * (1.0 + breathe + transition_open * 0.06)
	camera.position.z = lerpf(4.4, 2.55, transition_push)
	camera.look_at(Vector3(0, 0, 0.18 * transition_open), Vector3.UP)

	var pupil_scale := clampf(0.74 + (pupil_open * 3.0) + transition_open * 1.65 + energy * 0.10, 0.55, 2.8)
	pupil_disc.scale = Vector3(pupil_scale, pupil_scale, 1.0)
	iris_disc.scale = Vector3.ONE * (1.0 + progression_level * 0.018 + energy * 0.035)
	cornea.scale = Vector3(1.0, maxf(0.12, 1.0 - blink_amount * 0.35), 1.0)
	fill_light.light_energy = clampf(0.28 + glow_strength * 0.7 + energy * 0.3, 0.15, 1.8)
	_update_materials()

func _update_materials() -> void:
	if mat_iris == null:
		return
	var warmth := clampf(float(progression_level) / 8.0, 0.0, 1.0)
	var base_col := Color(0.06, 0.52 + warmth * 0.16, 0.48 + warmth * 0.05, 0.94)
	mat_iris.albedo_color = base_col
	mat_iris.emission = base_col
	mat_iris.emission_energy_multiplier = clampf(0.25 + glow_strength * 0.55, 0.15, 1.25)
	mat_sclera.emission_energy_multiplier = clampf(0.12 + glow_strength * 0.18, 0.08, 0.55)
	mat_shard.emission_energy_multiplier = clampf(0.20 + glow_strength * 0.5, 0.15, 1.0)

func _update_memory_shards() -> void:
	if memory_shards == null:
		return
	var visible_count := clampi(progression_level, 0, shard_nodes.size())
	memory_shards.rotation.z = elapsed * 0.18
	for i in range(shard_nodes.size()):
		var shard := shard_nodes[i]
		var active := i < visible_count
		shard.visible = active
		if not active:
			continue
		var angle := elapsed * (0.34 + i * 0.015) + (TAU / maxf(float(shard_nodes.size()), 1.0)) * float(i)
		var radius := 1.32 + sin(elapsed * 0.41 + i) * 0.05
		shard.position = Vector3(cos(angle) * radius, sin(angle) * radius * 0.62, 0.28 + sin(angle * 0.7) * 0.08)
		shard.rotation_degrees = Vector3(0, 0, rad_to_deg(angle) + 90.0)

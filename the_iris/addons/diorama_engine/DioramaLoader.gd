extends RefCounted
class_name DioramaLoader

## DioramaLoader — reads a Diorama JSON definition and produces a scene tree.
##
## Responsibilities:
##   - Parse and validate the JSON schema (actors, camera, clues, environment, lights, timeline).
##   - Instantiate 3D nodes (mesh primitives or loaded .glb/.gltf models).
##   - Apply PBR materials (albedo, roughness, metallic, normal maps, emission).
##   - Wire up interaction targets from clue definitions.
##   - Return a structured DioramaBundle the DioramaPlayer can mount.
##
## The loader contains ZERO rendering knowledge — no camera, no environment settings,
## no post-processing. That lives in DioramaPlayer and CinematicEnvironment.

signal load_progress(step: String, current: int, total: int)
signal load_complete(bundle: DioramaBundle)
signal load_error(message: String)

# --- Bundle returned to the player ---

class DioramaBundle:
	var id: String = ""
	var title: String = ""
	var subtitle: String = ""
	var environment_def: Dictionary = {}
	var camera_def: Dictionary = {}
	var light_defs: Array = []
	var objects: Dictionary = {}          # id -> Node3D
	var interaction_defs: Array = []      # clue definitions
	var timeline: Array = []
	var text: Dictionary = {}
	var duration: float = 15.0
	var root: Node3D = null               # caller adds this to the scene tree

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func load_definition(path: String) -> void:
	if not FileAccess.file_exists(path):
		load_error.emit("Definition file not found: %s" % path)
		return

	var raw := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		load_error.emit("Definition is not valid JSON: %s" % path)
		return

	var bundle := _assemble(parsed)
	load_complete.emit(bundle)

func load_from_dict(def: Dictionary) -> void:
	var bundle := _assemble(def)
	load_complete.emit(bundle)

# ---------------------------------------------------------------------------
# Assembly — translate definition into a node tree + bundle
# ---------------------------------------------------------------------------

func _assemble(def: Dictionary) -> DioramaBundle:
	var bundle := DioramaBundle.new()
	bundle.id = String(def.get("id", "unnamed"))
	bundle.title = String(def.get("title", ""))
	bundle.subtitle = String(def.get("subtitle", ""))
	bundle.environment_def = def.get("environment", {})
	bundle.camera_def = def.get("camera", {})
	bundle.light_defs = def.get("lights", [])
	bundle.timeline = def.get("timeline", [])
	bundle.text = def.get("text", {})
	bundle.duration = float(def.get("duration", 15.0))
	bundle.interaction_defs = def.get("clues", def.get("interactions", []))

	# Build the 3D root node
	var root := Node3D.new()
	root.name = "DioramaRoot_%s" % bundle.id
	bundle.root = root

	# Actors / objects
	var actor_defs: Array = def.get("actors", def.get("objects", []))
	var total := actor_defs.size()
	for i in range(total):
		var actor_def: Dictionary = actor_defs[i]
		load_progress.emit("Spawning actors", i, total)
		var node := _build_actor(actor_def, root)
		if node != null and actor_def.has("id"):
			bundle.objects[String(actor_def["id"])] = node

	# Register clues as interaction targets
	for clue_def in bundle.interaction_defs:
		var target_id := String(clue_def.get("target", ""))
		if bundle.objects.has(target_id):
			pass  # target exists; player will wire hit-testing

	return bundle

# ---------------------------------------------------------------------------
# Actor construction
# ---------------------------------------------------------------------------

func _build_actor(def: Dictionary, parent: Node) -> Node3D:
	var type := String(def.get("type", "box"))

	# Group / pivot — just a transform node with children
	if type in ["group", "pivot"]:
		var n := Node3D.new()
		n.name = String(def.get("id", type))
		_apply_transform(n, def)
		parent.add_child(n)
		for child_def in def.get("children", []):
			_build_actor(child_def, n)
		return n

	# External model (.glb / .gltf)
	if def.has("scene"):
		var scene_path := String(def["scene"])
		if ResourceLoader.exists(scene_path):
			var packed: PackedScene = load(scene_path)
			if packed:
				var instance := packed.instantiate()
				instance.name = String(def.get("id", "model"))
				if instance is Node3D:
					_apply_transform(instance as Node3D, def)
				parent.add_child(instance)
				return instance as Node3D
		# Fall through to primitive if scene can't load

	# Mesh primitive
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = String(def.get("id", type))
	mesh_inst.mesh = _create_mesh(type, _vec3(def.get("size", [1.0, 1.0, 1.0])))
	mesh_inst.material_override = _create_pbr_material(def)
	_apply_transform(mesh_inst, def)
	parent.add_child(mesh_inst)

	# Children
	for child_def in def.get("children", []):
		_build_actor(child_def, mesh_inst)

	return mesh_inst

# ---------------------------------------------------------------------------
# Mesh factory
# ---------------------------------------------------------------------------

func _create_mesh(type: String, size: Vector3) -> Mesh:
	match type:
		"box":
			var m := BoxMesh.new()
			m.size = size
			return m
		"cylinder":
			var m := CylinderMesh.new()
			m.top_radius = size.x * 0.5
			m.bottom_radius = size.x * 0.5
			m.height = size.y
			m.radial_segments = 32
			return m
		"sphere":
			var m := SphereMesh.new()
			m.radius = size.x * 0.5
			m.height = size.y
			m.radial_segments = 32
			m.rings = 16
			return m
		"plane":
			var m := PlaneMesh.new()
			m.size = Vector2(size.x, size.z)
			return m
		"capsule":
			var m := CapsuleMesh.new()
			m.radius = size.x * 0.5
			m.height = size.y
			m.radial_segments = 32
			return m
		_:
			var m := BoxMesh.new()
			m.size = size
			return m

# ---------------------------------------------------------------------------
# PBR Material factory (roughness, metallic, normal, emission)
# ---------------------------------------------------------------------------

func _create_pbr_material(def: Dictionary) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()

	# Albedo
	mat.albedo_color = _color(def.get("albedo", def.get("albedo_color", [0.5, 0.5, 0.5])))

	# PBR properties — the "cinematic difference"
	mat.roughness = float(def.get("roughness", 0.85))
	mat.metallic = float(def.get("metallic", 0.0))
	mat.specular = float(def.get("specular", 0.5))

	# Normal map (catches the light, adds surface detail)
	if def.has("normal_map"):
		var nm_path := String(def["normal_map"])
		if ResourceLoader.exists(nm_path):
			mat.normal_enabled = true
			mat.normal_texture = load(nm_path)
			mat.normal_scale = float(def.get("normal_strength", 1.0))

	# Roughness map (per-pixel roughness variation)
	if def.has("roughness_map"):
		var rm_path := String(def["roughness_map"])
		if ResourceLoader.exists(rm_path):
			mat.roughness_texture = load(rm_path)

	# Emission (glowing surfaces)
	if def.has("emission"):
		mat.emission_enabled = true
		mat.emission = _color(def["emission"])
		mat.emission_energy_multiplier = float(def.get("emission_energy", 1.0))

	# Transparency
	if def.has("transparency"):
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var a := clampf(1.0 - float(def["transparency"]), 0.0, 1.0)
		mat.albedo_color.a = a

	# Double-sided
	if bool(def.get("double_sided", false)):
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	# AO map (ambient occlusion texture)
	if def.has("ao_map"):
		var ao_path := String(def["ao_map"])
		if ResourceLoader.exists(ao_path):
			mat.ao_enabled = true
			mat.ao_texture = load(ao_path)
			mat.ao_light_affect = float(def.get("ao_light_affect", 1.0))

	return mat

# ---------------------------------------------------------------------------
# Transform helpers
# ---------------------------------------------------------------------------

func _apply_transform(node: Node3D, def: Dictionary) -> void:
	node.position = _vec3(def.get("position", [0.0, 0.0, 0.0]))
	node.rotation_degrees = _vec3(def.get("rotation_deg", [0.0, 0.0, 0.0]))
	if def.has("scale"):
		node.scale = _vec3(def["scale"])

# ---------------------------------------------------------------------------
# Type coercion helpers
# ---------------------------------------------------------------------------

func _color(arr: Variant) -> Color:
	if arr is Array and arr.size() >= 3:
		if arr.size() >= 4:
			return Color(float(arr[0]), float(arr[1]), float(arr[2]), float(arr[3]))
		return Color(float(arr[0]), float(arr[1]), float(arr[2]))
	return Color.WHITE

func _vec3(arr: Variant) -> Vector3:
	if arr is Array and arr.size() >= 3:
		return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))
	return Vector3.ZERO

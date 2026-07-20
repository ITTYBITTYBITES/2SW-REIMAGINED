extends Control
class_name DioramaPlayer

## DioramaPlayer — the master "record player" for cinematic 3D experiences.
##
## Sits in the scene tree as a reusable Control node. It owns:
##   - A SubViewport with the full Cinematic Stack (ACES, Glow, SSAO, SSR).
##   - A CinematicCamera with 35mm focal length and depth of field.
##   - A Key Light + Fill Light pair for cinematic depth.
##   - A DioramaLoader that reads JSON definitions and spawns content.
##   - An Iris transition (pupil dilation) for entering/exiting experiences.
##   - A fade veil for smooth transitions.
##   - A UI overlay for text (entry, prompt, response, resolution).
##
## Architecture:
##   Engine (this) ← data-driven by → Experience (JSON definition)
##
## Usage:
##   diorama_player.load_and_play("res://content/missing_second/missing_second.json")
##   diorama_player.experience_completed.connect(my_handler)

signal experience_loaded(experience_id: String)
signal experience_started(experience_id: String)
signal experience_completed(experience_id: String)
signal experience_return_requested

const VIEWPORT_WIDTH := 540
const VIEWPORT_HEIGHT := 960

# --- Node references (from scene) ---
@onready var viewport_container: SubViewportContainer = $ViewportContainer
@onready var viewport: SubViewport = $ViewportContainer/DioramaViewport
@onready var world_env: WorldEnvironment = $ViewportContainer/DioramaViewport/WorldEnvironment
@onready var camera: CinematicCamera = $ViewportContainer/DioramaViewport/CinematicCamera
@onready var key_light: DirectionalLight3D = $ViewportContainer/DioramaViewport/CinematicKeyLight
@onready var fill_light: DirectionalLight3D = $ViewportContainer/DioramaViewport/CinematicFillLight
@onready var fade_veil: ColorRect = $FadeVeil

# --- Content root (where spawned actors live) ---
var content_root: Node3D = null

# --- Loader ---
var loader: DioramaLoader = null

# --- Experience state ---
var bundle: DioramaLoader.DioramaBundle = null
var objects: Dictionary = {}
var interaction_nodes: Dictionary = {}
var _actor_defs_cache: Array = []

# --- Timeline / state machine ---
var phases: Array = []
var phase_index: int = -1
var phase_elapsed: float = 0.0
var interactions_enabled: bool = false
var phase_frozen: bool = false
var snapshot: Dictionary = {}
var resolving: bool = false
var resolved: bool = false

# --- UI overlay (built programmatically) ---
var ui_overlay: Control
var entry_label: Label
var prompt_label: Label
var response_label: Label
var resolution_label: Label
var return_button: Button

# --- Input ---
var _consume_next_release: bool = false

func _ready() -> void:
	visible = false
	_build_ui_overlay()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func load_and_play(definition_path: String) -> bool:
	if not FileAccess.file_exists(definition_path):
		push_error("[DioramaPlayer] Definition not found: %s" % definition_path)
		return false

	# Parse JSON
	var raw := FileAccess.get_file_as_string(definition_path)
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		push_error("[DioramaPlayer] Invalid JSON: %s" % definition_path)
		return false

	_assemble_from_def(parsed)
	return true

func load_and_play_from_dict(def: Dictionary) -> void:
	_assemble_from_def(def)

func stop() -> void:
	_clear_content()
	visible = false

func is_playing() -> bool:
	return visible and bundle != null

# ---------------------------------------------------------------------------
# Assembly — build the experience from a definition
# ---------------------------------------------------------------------------

func _assemble_from_def(def: Dictionary) -> void:
	_clear_content()

	bundle = DioramaLoader.DioramaBundle.new()
	bundle.id = String(def.get("id", "unnamed"))
	bundle.title = String(def.get("title", ""))
	bundle.subtitle = String(def.get("subtitle", ""))
	bundle.environment_def = def.get("environment", {})
	bundle.camera_def = def.get("camera", {})
	bundle.light_defs = def.get("lights", [])
	bundle.timeline = def.get("timeline", def.get("phases", []))
	bundle.text = def.get("text", {})
	bundle.duration = float(def.get("duration", 15.0))
	bundle.interaction_defs = def.get("clues", def.get("interactions", []))

	# Apply cinematic environment overrides
	_apply_environment(bundle.environment_def)

	# Configure camera from definition
	camera.configure_from_def(bundle.camera_def)

	# Build content root
	content_root = Node3D.new()
	content_root.name = "ContentRoot"
	viewport.add_child(content_root)

	# Spawn actors/objects
	var actor_defs: Array = def.get("actors", def.get("objects", []))
	_actor_defs_cache = actor_defs
	for actor_def in actor_defs:
		var node := _build_actor(actor_def, content_root)
		if node != null and (actor_def as Dictionary).has("id"):
			objects[String(actor_def["id"])] = node
			bundle.objects[String(actor_def["id"])] = node

	# Wire interactions from clue definitions
	_setup_interactions(bundle.interaction_defs)

	# Setup timeline
	phases = bundle.timeline

	# Apply definition lights (in addition to the built-in key/fill)
	for light_def in bundle.light_defs:
		_build_extra_light(light_def)

	# Start
	visible = true
	fade_veil.color.a = 1.0  # start fully black
	_enter_phase(0)
	experience_loaded.emit(bundle.id)

	# Iris open to reveal the scene
	camera.open_iris(1.2, func():
		_fade_veil_to(0.0, 1.25)
		experience_started.emit(bundle.id)
	)

# ---------------------------------------------------------------------------
# Environment — update the pre-baked WorldEnvironment from JSON
# ---------------------------------------------------------------------------

func _apply_environment(env_def: Dictionary) -> void:
	if env_def.is_empty():
		return

	var env := world_env.environment

	# Override background color
	if env_def.has("background_color"):
		env.background_color = CinematicEnvironment._color(env_def["background_color"])

	# Override ambient
	if env_def.has("ambient_color"):
		env.ambient_light_color = CinematicEnvironment._color(env_def["ambient_color"])
	if env_def.has("ambient_energy"):
		env.ambient_light_energy = float(env_def["ambient_energy"])

	# Override fog
	if env_def.has("fog_enabled"):
		env.fog_enabled = bool(env_def["fog_enabled"])
		if env.fog_enabled:
			if env_def.has("fog_color"):
				env.fog_light_color = CinematicEnvironment._color(env_def["fog_color"])
			if env_def.has("fog_energy"):
				env.fog_light_energy = float(env_def["fog_energy"])
			if env_def.has("fog_density"):
				env.fog_density = float(env_def["fog_density"])

	# SSAO overrides
	var ssao_def: Dictionary = env_def.get("ssao", {})
	if ssao_def.has("enabled"):
		env.ssao_enabled = bool(ssao_def["enabled"])
	if ssao_def.has("radius"):
		env.ssao_radius = float(ssao_def["radius"])
	if ssao_def.has("intensity"):
		env.ssao_intensity = float(ssao_def["intensity"])

	# Glow overrides
	var glow_def: Dictionary = env_def.get("glow", {})
	if glow_def.has("enabled"):
		env.glow_enabled = bool(glow_def["enabled"])
	if glow_def.has("intensity"):
		env.glow_intensity = float(glow_def["intensity"])

# ---------------------------------------------------------------------------
# Actor construction (mesh primitives + external models)
# ---------------------------------------------------------------------------

func _build_actor(def: Dictionary, parent: Node) -> Node3D:
	var type := String(def.get("type", "box"))

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

	# Mesh primitive
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = String(def.get("id", type))
	mesh_inst.mesh = _create_mesh(type, _vec3(def.get("size", [1.0, 1.0, 1.0])))
	mesh_inst.material_override = _create_pbr_material(def)
	_apply_transform(mesh_inst, def)
	parent.add_child(mesh_inst)

	for child_def in def.get("children", []):
		_build_actor(child_def, mesh_inst)

	return mesh_inst

## Apply position + rotation (and optional scale) from a definition to a Node3D.
## Used by _build_actor for group/pivot, external-model, and mesh branches.
func _apply_transform(node: Node3D, def: Dictionary) -> void:
	if node == null:
		return
	node.position = _vec3(def.get("position", [0.0, 0.0, 0.0]))
	node.rotation_degrees = _vec3(def.get("rotation_deg", [0.0, 0.0, 0.0]))
	if def.has("scale"):
		node.scale = _vec3(def["scale"])

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

func _create_pbr_material(def: Dictionary) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color(def.get("albedo", def.get("albedo_color", [0.5, 0.5, 0.5])))
	mat.roughness = float(def.get("roughness", 0.85))
	mat.metallic = float(def.get("metallic", 0.0))
	mat.specular = float(def.get("specular", 0.5))

	if def.has("normal_map"):
		var nm_path := String(def["normal_map"])
		if ResourceLoader.exists(nm_path):
			mat.normal_enabled = true
			mat.normal_texture = load(nm_path)
			mat.normal_scale = float(def.get("normal_strength", 1.0))

	if def.has("roughness_map"):
		var rm_path := String(def["roughness_map"])
		if ResourceLoader.exists(rm_path):
			mat.roughness_texture = load(rm_path)

	if def.has("ao_map"):
		var ao_path := String(def["ao_map"])
		if ResourceLoader.exists(ao_path):
			mat.ao_enabled = true
			mat.ao_texture = load(ao_path)

	if def.has("emission"):
		mat.emission_enabled = true
		mat.emission = _color(def["emission"])
		mat.emission_energy_multiplier = float(def.get("emission_energy", 1.0))

	if def.has("transparency"):
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var a := clampf(1.0 - float(def["transparency"]), 0.0, 1.0)
		mat.albedo_color.a = a

	if bool(def.get("double_sided", false)):
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	return mat

func _build_extra_light(light_def: Dictionary) -> void:
	var light: Light3D
	match String(light_def.get("type", "directional")):
		"directional":
			var d := DirectionalLight3D.new()
			d.rotation_degrees = _vec3(light_def.get("rotation_deg", [-45.0, 30.0, 0.0]))
			light = d
		"spot":
			var s := SpotLight3D.new()
			s.position = _vec3(light_def.get("position", [0.0, 3.0, 0.0]))
			s.rotation_degrees = _vec3(light_def.get("rotation_deg", [-55.0, 0.0, 0.0]))
			s.spot_range = float(light_def.get("range", 12.0))
			s.spot_angle = float(light_def.get("spot_angle_deg", 45.0))
			light = s
		"point":
			var p := OmniLight3D.new()
			p.position = _vec3(light_def.get("position", [0.0, 2.0, 0.0]))
			p.omni_range = float(light_def.get("range", 8.0))
			light = p
		_:
			light = DirectionalLight3D.new()

	light.light_energy = float(light_def.get("energy", 1.0))
	light.light_color = _color(light_def.get("color", [1.0, 1.0, 1.0]))
	light.shadow_enabled = bool(light_def.get("shadow", false))
	if light_def.has("id"):
		light.name = String(light_def["id"])
	viewport.add_child(light)

# ---------------------------------------------------------------------------
# Interactions
# ---------------------------------------------------------------------------

func _setup_interactions(interaction_defs: Array) -> void:
	interaction_nodes.clear()
	for idef in interaction_defs:
		var target_id := String(idef.get("target", ""))
		if not objects.has(target_id):
			continue
		interaction_nodes[String(idef.get("id", target_id))] = {
			"target": objects[target_id],
			"def": idef,
			"radius": float(idef.get("hit_radius", 0.6))
		}

func _gui_input(event: InputEvent) -> void:
	if not interactions_enabled:
		return
	var tap_pos := Vector2.ZERO
	var is_tap := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_pos = event.position
		is_tap = true
	elif event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
		is_tap = true
	if is_tap:
		_handle_tap(tap_pos)
		get_viewport().set_input_as_handled()

func _handle_tap(screen_pos: Vector2) -> void:
	if resolved:
		return
	var best_id := ""
	var best_dist := INF
	for iid in interaction_nodes:
		var entry: Dictionary = interaction_nodes[iid]
		var target: Node3D = entry["target"]
		if not is_instance_valid(target):
			continue
		var world_pos: Vector3 = target.global_position
		var screen_pos3 := camera.unproject_position(world_pos)
		var dx := screen_pos3.x - screen_pos.x
		var dy := screen_pos3.y - screen_pos.y
		var screen_dist := Vector2(dx, dy).length()
		var depth := (world_pos - camera.global_position).length()
		var world_radius: float = entry["radius"]
		var screen_radius := world_radius * (VIEWPORT_HEIGHT * 0.5) / maxf(depth * tan(deg_to_rad(camera.fov) * 0.5), 0.001)
		if screen_dist <= screen_radius and screen_dist < best_dist:
			best_dist = screen_dist
			best_id = iid
	if best_id != "":
		_dispatch_interaction(best_id)

func _dispatch_interaction(iid: String) -> void:
	var entry: Dictionary = interaction_nodes[iid]
	var idef: Dictionary = entry["def"]
	var outcome := String(idef.get("outcome", idef.get("type", "wrong")))
	var response := String(idef.get("response", ""))
	if outcome == "correct":
		if resolving or resolved:
			return
		resolving = true
		interactions_enabled = false
		_show_response(response)
		_begin_resolution()
	else:
		_show_response(response)
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Examination")

func _show_response(text_value: String) -> void:
	response_label.text = text_value
	response_label.visible = not text_value.is_empty()

# ---------------------------------------------------------------------------
# Timeline / state machine
# ---------------------------------------------------------------------------

func _process(delta: float) -> void:
	if not visible or phase_index < 0 or phase_index >= phases.size():
		return
	phase_elapsed += delta
	var phase: Dictionary = phases[phase_index]
	var mode := String(phase.get("mode", "animate"))
	if mode == "animate" and not resolving:
		_advance_phase_animations(phase, delta)
	if phase.has("duration"):
		if phase_elapsed >= float(phase["duration"]):
			_advance_phase()

func _enter_phase(index: int) -> void:
	if index < 0 or index >= phases.size():
		_complete_experience()
		return
	phase_index = index
	phase_elapsed = 0.0
	var phase: Dictionary = phases[index]
	var mode := String(phase.get("mode", "animate"))
	if mode == "freeze":
		if not phase_frozen:
			_capture_snapshot()
			phase_frozen = true
		_apply_snapshot()
	else:
		if phase_frozen:
			phase_frozen = false

	var text: Dictionary = bundle.text if bundle else {}
	if phase.has("entry_text_key"):
		var key := String(phase["entry_text_key"])
		entry_label.text = String(text.get(key, ""))
		entry_label.visible = not entry_label.text.is_empty()
		_hide_other_text("entry")
	if phase.has("prompt_text_key"):
		var key := String(phase["prompt_text_key"])
		prompt_label.text = String(text.get(key, ""))
		prompt_label.visible = not prompt_label.text.is_empty()
		_hide_other_text("prompt")
	if bool(phase.get("enable_interactions", false)):
		interactions_enabled = true
	if String(phase.get("id", "")) == "forming":
		_fade_veil_to(0.0, float(phase.get("duration", 1.25)))

func _advance_phase() -> void:
	if phase_index >= 0 and phase_index < phases.size():
		var pid := String(phases[phase_index].get("id", ""))
		if pid == "investigating":
			return
		if pid == "resolving":
			_finish_resolution(phases[phase_index])
			return
	_enter_phase(phase_index + 1)

func _advance_phase_animations(phase: Dictionary, delta: float) -> void:
	var dur := float(phase.get("duration", 1.0))
	var t := phase_elapsed
	for anim in phase.get("animations", []):
		_apply_animation(anim, t, dur, delta)

func _apply_animation(anim: Dictionary, t: float, dur: float, delta: float) -> void:
	var target_id := String(anim.get("target", ""))
	if not objects.has(target_id):
		return
	var target: Node3D = objects[target_id]
	var prop := String(anim.get("property", ""))
	var atype := String(anim.get("type", ""))
	var progress := clampf(t / maxf(dur, 0.0001), 0.0, 1.0)
	match atype:
		"lerp":
			_set_property(target, prop, lerpf(float(anim["from"]), float(anim["to"]), progress))
		"lerp_delayed":
			var delay := float(anim.get("delay", 0.0))
			if t >= delay:
				var p2 := clampf((t - delay) / maxf(dur - delay, 0.0001), 0.0, 1.0)
				_set_property(target, prop, lerpf(float(anim["from"]), float(anim["to"]), p2))
		"rate":
			_add_property(target, prop, float(anim["rate"]) * delta)
		"rate_with_jump":
			_add_property(target, prop, float(anim["rate"]) * delta)
			var key := "jump_done_%s_%s" % [target_id, prop.replace(":", "_")]
			if t >= float(anim.get("jump_at", INF)) and not get_meta(key, false):
				_add_property(target, prop, float(anim.get("jump", 0.0)))
				set_meta(key, true)
		"ease_back_by":
			var frozen_val: Variant = _read_snapshot(target_id, prop)
			if frozen_val != null:
				var target_val := float(frozen_val) - float(anim["amount"])
				var eased := _ease_in_out(progress)
				_set_property(target, prop, lerpf(float(frozen_val), target_val, eased))
		"event":
			var at_t := float(anim.get("at", 0.0))
			if t >= at_t:
				var ekey := "event_done_%s_%s_%s" % [target_id, prop.replace(":", "_"), atype]
				if not get_meta(ekey, false):
					set_meta(ekey, true)
					_trigger_event(target, prop)

func _trigger_event(target: Node3D, event_name: String) -> void:
	if event_name == "reveal":
		_reveal_object(target)

func _reveal_object(target: Node3D) -> void:
	if target is MeshInstance3D:
		var mat := target.material_override as StandardMaterial3D
		if mat != null:
			var obj_def: Variant = _find_def_by_id(target.name)
			if obj_def != null:
				mat.emission_energy_multiplier = float(obj_def.get("_reveal_emission_energy", mat.emission_energy_multiplier))
				if obj_def.has("_reveal_albedo"):
					mat.albedo_color = _color(obj_def["_reveal_albedo"])
			else:
				mat.emission_energy_multiplier = 1.0

func _find_def_by_id(oid: String) -> Variant:
	if _actor_defs_cache.is_empty():
		return null
	for def in _actor_defs_cache:
		if def is Dictionary and String(def.get("id", "")) == oid:
			return def
	return null

func _set_property(target: Node3D, prop: String, value: float) -> void:
	match prop:
		"position:x": target.position.x = value
		"position:y": target.position.y = value
		"position:z": target.position.z = value
		"rotation:x": target.rotation.x = value
		"rotation:y": target.rotation_degrees.y = value
		"rotation:z": target.rotation.z = value

func _add_property(target: Node3D, prop: String, delta_value: float) -> void:
	match prop:
		"position:x": target.position.x += delta_value
		"position:y": target.position.y += delta_value
		"position:z": target.position.z += delta_value
		"rotation:x": target.rotation.x += delta_value
		"rotation:y": target.rotation_degrees.y += delta_value
		"rotation:z": target.rotation.z += delta_value

func _capture_snapshot() -> void:
	snapshot.clear()
	for phase in phases:
		for anim in phase.get("animations", []):
			var tid := String(anim.get("target", ""))
			var prop := String(anim.get("property", ""))
			if tid == "" or prop == "":
				continue
			if not snapshot.has(tid):
				snapshot[tid] = {}
			if not snapshot[tid].has(prop):
				snapshot[tid][prop] = _read_property(objects.get(tid), prop)

func _apply_snapshot() -> void:
	for tid in snapshot:
		var target: Node3D = objects.get(tid)
		if target == null:
			continue
		for prop in snapshot[tid]:
			_set_property(target, prop, float(snapshot[tid][prop]))

func _read_snapshot(tid: String, prop: String) -> Variant:
	if snapshot.has(tid) and snapshot[tid].has(prop):
		return snapshot[tid][prop]
	return null

func _read_property(target: Node3D, prop: String) -> float:
	if target == null:
		return 0.0
	match prop:
		"position:x": return target.position.x
		"position:y": return target.position.y
		"position:z": return target.position.z
		"rotation:x": return target.rotation.x
		"rotation:y": return target.rotation_degrees.y
		"rotation:z": return target.rotation.z
	return 0.0

func _hide_other_text(keep: String) -> void:
	# Clear ALL sibling text labels except the one being shown, so phases never
	# stack entry/prompt/response/resolution text on top of each other (which
	# was causing the "doubled text" effect during experience playback).
	if keep != "entry" and entry_label: entry_label.visible = false
	if keep != "prompt" and prompt_label: prompt_label.visible = false
	if keep != "response" and response_label: response_label.visible = false
	if keep != "resolution" and resolution_label: resolution_label.visible = false

func _ease_in_out(v: float) -> float:
	return v * v * (3.0 - 2.0 * v)

# ---------------------------------------------------------------------------
# Resolution
# ---------------------------------------------------------------------------

func _begin_resolution() -> void:
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.SUCCESS, "Discovery")
	for k in get_meta_list():
		if String(k).begins_with("jump_done_") or String(k).begins_with("event_done_"):
			remove_meta(k)
	_enter_phase(_phase_index_of("resolving"))

func _phase_index_of(pid: String) -> int:
	for i in range(phases.size()):
		if String(phases[i].get("id", "")) == pid:
			return i
	return -1

func _process_resolution_beats(phase: Dictionary) -> void:
	var dur := float(phase.get("duration", 3.0))
	for beat in phase.get("resolution_beats", []):
		var at_t := float(beat.get("at", 1.0)) * dur
		var key := "beat_done_%s" % String(beat.get("action", ""))
		if phase_elapsed >= at_t and not get_meta(key, false):
			set_meta(key, true)
			match String(beat.get("action", "")):
				"reveal_photograph":
					if objects.has("photograph"):
						_reveal_object(objects["photograph"])
				"show_resolution_text":
					var text: Dictionary = bundle.text if bundle else {}
					resolution_label.text = String(text.get("resolution_text", ""))
					resolution_label.visible = true
					_hide_other_text("resolution")
				"complete":
					_finish_resolution(phase)

func _finish_resolution(phase: Dictionary) -> void:
	if resolved:
		return
	resolved = true
	resolving = false
	if bool(phase.get("show_return_at_end", true)):
		return_button.text = String(bundle.text.get("return_label", "RETURN TO IRIS")) if bundle else "RETURN TO IRIS"
		return_button.visible = true
		experience_completed.emit(bundle.id if bundle else "")

func _complete_experience() -> void:
	resolved = true
	visible = false

func _physics_process(_delta: float) -> void:
	if not visible or phase_index < 0:
		return
	if phase_index >= 0 and phase_index < phases.size():
		var pid := String(phases[phase_index].get("id", ""))
		if pid == "resolving" and resolving:
			_process_resolution_beats(phases[phase_index])

# ---------------------------------------------------------------------------
# UI Overlay
# ---------------------------------------------------------------------------

func _build_ui_overlay() -> void:
	ui_overlay = Control.new()
	ui_overlay.name = "UIOverlay"
	ui_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_overlay)

	entry_label = _make_label(Vector2(32, 70), Vector2(476, 40), 17, Color("#ecf8f2"), HORIZONTAL_ALIGNMENT_CENTER)
	prompt_label = _make_label(Vector2(38, 744), Vector2(464, 56), 14, Color("#e3fff5"), HORIZONTAL_ALIGNMENT_CENTER)
	response_label = _make_label(Vector2(38, 680), Vector2(464, 58), 14, Color("#bde8d9"), HORIZONTAL_ALIGNMENT_CENTER)
	resolution_label = _make_label(Vector2(38, 600), Vector2(464, 170), 17, Color("#ecf8f2"), HORIZONTAL_ALIGNMENT_CENTER)
	for l in [entry_label, prompt_label, response_label, resolution_label]:
		ui_overlay.add_child(l)

	return_button = Button.new()
	return_button.text = "RETURN TO IRIS"
	return_button.position = Vector2(42, 822)
	return_button.size = Vector2(456, 50)
	return_button.add_theme_font_size_override("font_size", 14)
	return_button.add_theme_color_override("font_color", Color("#f3fff9"))
	return_button.mouse_filter = Control.MOUSE_FILTER_STOP
	return_button.visible = false
	return_button.pressed.connect(_on_return_pressed)
	ui_overlay.add_child(return_button)

func _make_label(pos: Vector2, sz: Vector2, font_size: int, color: Color, align: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = sz
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = false
	return label

func _on_return_pressed() -> void:
	experience_return_requested.emit()

# ---------------------------------------------------------------------------
# Fade veil
# ---------------------------------------------------------------------------

func _fade_veil_to(target_alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_veil, "color:a", target_alpha, maxf(duration, 0.05))

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

func _clear_content() -> void:
	if content_root != null:
		for child in content_root.get_children():
			content_root.remove_child(child)
			child.queue_free()
		content_root.queue_free()
		content_root = null
	objects.clear()
	interaction_nodes.clear()
	phases.clear()
	phase_index = -1
	phase_elapsed = 0.0
	interactions_enabled = false
	phase_frozen = false
	snapshot.clear()
	resolving = false
	resolved = false
	bundle = null
	if entry_label: entry_label.visible = false
	if prompt_label: prompt_label.visible = false
	if response_label: response_label.visible = false
	if resolution_label: resolution_label.visible = false
	if return_button: return_button.visible = false
	if fade_veil: fade_veil.color.a = 1.0

# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------

func active_experience_id() -> String:
	return bundle.id if bundle else ""

func current_phase_id() -> String:
	if phase_index >= 0 and phase_index < phases.size():
		return String(phases[phase_index].get("id", ""))
	return ""

# ---------------------------------------------------------------------------
# Helpers
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

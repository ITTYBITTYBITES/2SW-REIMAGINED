extends Control
class_name DioramaEngine

## Diorama Engine — the 3D experience renderer for Two Second Witness.
##
## Role (preserved): sits between the Living Iris portal and a memory. Owns the
## SubViewport render infrastructure (camera, world environment, the 3D world
## root) and renders exactly one experience at a time.
##
## JSON-driven assembly (per Mission 073G): the engine assembles the environment,
## lights, camera, objects, timeline, and interactions entirely from a JSON
## definition. It contains NO experience-specific knowledge — no clock, no
## "missing second", no waiting room. All such data lives in the definition.
##
## Generic capabilities the engine provides (used by any definition):
##   - mesh primitives: box, cylinder, sphere, plane, group, pivot
##   - lights: directional, spot
##   - camera placement (position + look_at)
##   - environment/atmosphere
##   - a timeline of phases; each phase animates object properties using a small
##     set of generic primitives: lerp, lerp_delayed, rate, rate_with_jump,
##     ease_back_by, event, and a freeze mode that snapshots and holds.
##   - 3D interaction via camera ray-pick into interaction targets, dispatched
##     to definition outcomes (wrong / correct).
##
## The 3D world lives in a SubViewport (own_world_3d) so the 2D Living Iris layer
## and the 3D memory layer stay cleanly isolated.

signal experience_completed
signal experience_return_requested

const VIEWPORT_WIDTH := 540
const VIEWPORT_HEIGHT := 960
const INTERACTION_MASK := 1  # collision layer for interaction targets

# --- render infrastructure (built once in _ready, preserved) ---
var viewport_container: SubViewportContainer
var viewport: SubViewport
var camera: Camera3D
var world_env: WorldEnvironment
var experience_root: Node3D

# --- assembled from the definition ---
var definition: Dictionary = {}
var objects: Dictionary = {}        # id -> Node3D (every addressable object)
var interactions: Array = []        # raw interaction defs
var interaction_nodes: Dictionary = {}  # interaction id -> {target, area, def}
var lights: Dictionary = {}         # id -> Light3D

# --- UI overlay (2D, over the 3D viewport) ---
var ui_overlay: Control
var fade_veil: ColorRect
var entry_label: Label
var prompt_label: Label
var response_label: Label
var resolution_label: Label
var return_button: Button

# --- timeline / state machine ---
var phases: Array = []
var phase_index: int = -1
var phase_elapsed: float = 0.0
var interactions_enabled: bool = false
var phase_frozen: bool = false
var snapshot: Dictionary = {}        # object id -> { property -> value } captured on freeze
var resolving: bool = false
var resolved: bool = false
var return_visible: bool = false

# --- input ---
var _consume_next_release: bool = false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_render_infrastructure()
	_build_ui_overlay()

# ---------------------------------------------------------------------------
# Render infrastructure (SubViewport + camera + empty world + environment slot)
# ---------------------------------------------------------------------------
func _build_render_infrastructure() -> void:
	viewport_container = SubViewportContainer.new()
	viewport_container.name = "ViewportContainer"
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(viewport_container)

	viewport = SubViewport.new()
	viewport.name = "DioramaViewport"
	viewport.size = Vector2i(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
	viewport.disable_3d = false
	# Must own its own 3D world (this app is 2D-rooted) or 3D never renders.
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport_container.add_child(viewport)

	world_env = WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	viewport.add_child(world_env)

	camera = Camera3D.new()
	camera.name = "DioramaCamera"
	viewport.add_child(camera)
	camera.current = true

	experience_root = Node3D.new()
	experience_root.name = "ExperienceRoot"
	viewport.add_child(experience_root)

func _build_ui_overlay() -> void:
	ui_overlay = Control.new()
	ui_overlay.name = "UIOverlay"
	ui_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_overlay)

	fade_veil = ColorRect.new()
	fade_veil.color = Color(0.005, 0.008, 0.014, 1.0)
	fade_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_overlay.add_child(fade_veil)

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

# ---------------------------------------------------------------------------
# Launch — load a JSON definition and assemble the experience from it.
# ---------------------------------------------------------------------------
func launch_experience(definition_path: String) -> bool:
	if not FileAccess.file_exists(definition_path):
		push_error("[DioramaEngine] Definition not found: %s" % definition_path)
		return false
	var raw := FileAccess.get_file_as_string(definition_path)
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		push_error("[DioramaEngine] Definition is not a valid JSON object: %s" % definition_path)
		return false
	_assemble(parsed)
	_enter_phase(0)
	visible = true
	return true

func clear_experience() -> void:
	# Tear down assembled experience; preserve render infra + UI overlay shell.
	for child in experience_root.get_children():
		experience_root.remove_child(child)
		child.queue_free()
	for light in lights.values():
		if is_instance_valid(light):
			light.queue_free()
	lights.clear()
	objects.clear()
	interaction_nodes.clear()
	interactions.clear()
	phases.clear()
	phase_index = -1
	phase_elapsed = 0.0
	interactions_enabled = false
	phase_frozen = false
	snapshot.clear()
	resolving = false
	resolved = false
	return_visible = false
	definition = {}
	for l in [entry_label, prompt_label, response_label, resolution_label]:
		l.text = ""
		l.visible = false
	return_button.visible = false
	fade_veil.color = Color(0.005, 0.008, 0.014, 1.0)
	visible = false

# ---------------------------------------------------------------------------
# Assembly — build everything from the definition. No experience knowledge.
# ---------------------------------------------------------------------------
func _assemble(def: Dictionary) -> void:
	definition = def
	_apply_environment(def.get("environment", {}))
	_apply_camera(def.get("camera", {}))
	for light_def in def.get("lights", []):
		_build_light(light_def)
	for obj_def in def.get("objects", []):
		_build_object(obj_def, experience_root)
	interactions = def.get("interactions", [])
	_setup_interactions()
	phases = def.get("timeline", [])

func _apply_environment(env_def: Dictionary) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = _color(env_def.get("background_color", [0.01, 0.02, 0.03]))
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = _color(env_def.get("ambient_color", [0.2, 0.2, 0.2]))
	env.ambient_light_energy = float(env_def.get("ambient_energy", 0.8))
	if bool(env_def.get("fog_enabled", false)):
		env.fog_enabled = true
		env.fog_light_color = _color(env_def.get("fog_color", [0.05, 0.1, 0.15]))
		env.fog_light_energy = float(env_def.get("fog_energy", 0.3))
		env.fog_density = float(env_def.get("fog_density", 0.04))
	world_env.environment = env

func _apply_camera(cam_def: Dictionary) -> void:
	camera.fov = float(cam_def.get("fov", 50.0))
	var pos := _vec3(cam_def.get("position", [0.0, 1.6, 5.0]))
	var look := _vec3(cam_def.get("look_at", [0.0, 1.5, 0.0]))
	camera.global_position = pos
	camera.look_at(look)

func _build_light(light_def: Dictionary) -> void:
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
		_:
			var d2 := DirectionalLight3D.new()
			light = d2
	light.light_energy = float(light_def.get("energy", 1.0))
	light.light_color = _color(light_def.get("color", [1.0, 1.0, 1.0]))
	light.shadow_enabled = bool(light_def.get("shadow", false))
	if light_def.has("id"):
		light.name = String(light_def["id"])
	viewport.add_child(light)
	if light_def.has("id"):
		lights[String(light_def["id"])] = light

func _build_object(obj_def: Dictionary, parent: Node) -> Node3D:
	var node := _create_object_node(obj_def)
	if obj_def.has("id"):
		objects[String(obj_def["id"])] = node
	parent.add_child(node)
	if node is Node3D:
		node.position = _vec3(obj_def.get("position", [0.0, 0.0, 0.0]))
		node.rotation_degrees = _vec3(obj_def.get("rotation_deg", [0.0, 0.0, 0.0]))
	for child_def in obj_def.get("children", []):
		_build_object(child_def, node)
	return node

func _create_object_node(obj_def: Dictionary) -> Node3D:
	var type := String(obj_def.get("type", "box"))
	match type:
		"group", "pivot":
			var n := Node3D.new()
			n.name = String(obj_def.get("id", type))
			return n
	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = _create_mesh(type, _vec3(obj_def.get("size", [1.0, 1.0, 1.0])))
	mesh_inst.material_override = _create_material(obj_def)
	mesh_inst.name = String(obj_def.get("id", type))
	return mesh_inst

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
			return m
		"sphere":
			var m := SphereMesh.new()
			m.radius = size.x * 0.5
			m.height = size.y
			return m
		"plane":
			var m := PlaneMesh.new()
			m.size = Vector2(size.x, size.z)
			return m
		_:
			var m := BoxMesh.new()
			m.size = size
			return m

func _create_material(obj_def: Dictionary) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _color(obj_def.get("albedo", [0.5, 0.5, 0.5]))
	mat.roughness = float(obj_def.get("roughness", 0.85))
	mat.metallic = float(obj_def.get("metallic", 0.0))
	if obj_def.has("emission"):
		mat.emission_enabled = true
		mat.emission = _color(obj_def["emission"])
		mat.emission_energy_multiplier = float(obj_def.get("emission_energy", 1.0))
	if obj_def.has("transparency"):
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var a := clampf(1.0 - float(obj_def["transparency"]), 0.0, 1.0)
		mat.albedo_color.a = a
	return mat

# ---------------------------------------------------------------------------
# Interactions — camera ray-pick against interaction target origins.
# Scaffold-grade screen-space radius hit test (robust, SubViewport-safe).
# ---------------------------------------------------------------------------
func _setup_interactions() -> void:
	for idef in interactions:
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
	# Project each interaction target's world origin to screen; pick the nearest
	# within its hit radius (in world units, via depth-aware distance).
	var best_id := ""
	var best_dist := INF
	for iid in interaction_nodes:
		var entry: Dictionary = interaction_nodes[iid]
		var target: Node3D = entry["target"]
		if not is_instance_valid(target):
			continue
		var world_pos: Vector3 = target.global_position
		var screen_pos3 := camera.unproject_position(world_pos)
		# Convert engine-local tap coords to viewport coords (1:1 since engine == viewport size).
		var dx := screen_pos3.x - screen_pos.x
		var dy := screen_pos3.y - screen_pos.y
		var screen_dist := Vector2(dx, dy).length()
		# Approximate world radius at that depth for a fair hit area.
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
	var outcome := String(idef.get("outcome", "wrong"))
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
# Timeline / state machine (driven entirely by the definition).
# ---------------------------------------------------------------------------
func _process(delta: float) -> void:
	if not visible or phase_index < 0 or phase_index >= phases.size():
		return
	phase_elapsed += delta
	var phase: Dictionary = phases[phase_index]
	var mode := String(phase.get("mode", "animate"))
	if mode == "animate" and not resolving_paused():
		_advance_phase_animations(phase, delta)
	if phase.has("duration"):
		if phase_elapsed >= float(phase["duration"]):
			_advance_phase()
	elif mode == "freeze" and phase.has("enable_interactions"):
		pass  # investigating: open-ended, waits for interaction

func resolving_paused() -> bool:
	# While resolving, animation advancement continues; this hook keeps the
	# generic loop clean for future gated behavior.
	return false

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
	# Phase entry text.
	var text: Dictionary = definition.get("text", {})
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

func _fade_veil_to(target_alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_veil, "color:a", target_alpha, maxf(duration, 0.05))

func _advance_phase() -> void:
	# natural phase progression. investigating waits for the correct
	# interaction; resolving completes by finishing (showing RETURN), it does
	# not auto-advance out of the experience.
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
			# Continuous accumulation; loops for steam-like rising via modulo on bound if provided.
			_add_property(target, prop, float(anim["rate"]) * delta)
		"rate_with_jump":
			_add_property(target, prop, float(anim["rate"]) * delta)
			# Apply the discrete jump once when crossing jump_at (tracked via metadata).
			var key := "jump_done_%s_%s" % [target_id, prop.replace(":", "_")]
			if t >= float(anim.get("jump_at", INF)) and not get_meta(key, false):
				_add_property(target, prop, float(anim.get("jump", 0.0)))
				set_meta(key, true)
		"ease_back_by":
			# Ease the frozen value back toward (frozen - amount) over the phase.
			var frozen_val: Variant = _read_snapshot(target_id, prop)
			if frozen_val != null:
				var target_val := float(frozen_val) - float(anim["amount"])
				var eased := _ease_in_out(progress)
				_set_property(target, prop, lerpf(float(frozen_val), target_val, eased))
		"event":
			var at_t := float(anim.get("at", 0.0))
			if t >= at_t:
				var key := "event_done_%s_%s_%s" % [target_id, prop.replace(":", "_"), atype]
				if not get_meta(key, false):
					set_meta(key, true)
					_trigger_event(target, prop)

func _trigger_event(target: Node3D, event_name: String) -> void:
	if event_name == "reveal":
		_reveal_object(target)

func _reveal_object(target: Node3D) -> void:
	if target is MeshInstance3D:
		var mat := target.material_override as StandardMaterial3D
		if mat != null:
			# Use definition hints if present on the original def (by node name).
			var obj_def: Variant = _find_def_by_id(target.name)
			if obj_def != null:
				mat.emission_energy_multiplier = float(obj_def.get("_reveal_emission_energy", mat.emission_energy_multiplier))
				if obj_def.has("_reveal_albedo"):
					mat.albedo_color = _color(obj_def["_reveal_albedo"])
			else:
				mat.emission_energy_multiplier = 1.0

func _find_def_by_id(oid: String) -> Variant:
	for od in definition.get("objects", []):
		if String(od.get("id", "")) == oid:
			return od
	return null

func _set_property(target: Node3D, prop: String, value: float) -> void:
	if prop == "position:x":
		target.position.x = value
	elif prop == "position:y":
		target.position.y = value
	elif prop == "position:z":
		target.position.z = value
	elif prop == "rotation:x":
		target.rotation.x = value
	elif prop == "rotation:y":
		target.rotation_degrees.y = value
	elif prop == "rotation:z":
		target.rotation.z = value

func _add_property(target: Node3D, prop: String, delta_value: float) -> void:
	if prop == "position:x":
		target.position.x += delta_value
	elif prop == "position:y":
		target.position.y += delta_value
	elif prop == "position:z":
		target.position.z += delta_value
	elif prop == "rotation:x":
		target.rotation.x += delta_value
	elif prop == "rotation:y":
		target.rotation_degrees.y += delta_value
	elif prop == "rotation:z":
		target.rotation.z += delta_value

func _capture_snapshot() -> void:
	snapshot.clear()
	# Snapshot every animatable target referenced anywhere in the timeline.
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
	if prop == "position:x":
		return target.position.x
	if prop == "position:y":
		return target.position.y
	if prop == "position:z":
		return target.position.z
	if prop == "rotation:x":
		return target.rotation.x
	if prop == "rotation:y":
		return target.rotation_degrees.y
	if prop == "rotation:z":
		return target.rotation.z
	return 0.0

func _hide_other_text(keep: String) -> void:
	if keep != "entry":
		entry_label.visible = false
	if keep != "prompt":
		prompt_label.visible = false

func _ease_in_out(v: float) -> float:
	return v * v * (3.0 - 2.0 * v)

# ---------------------------------------------------------------------------
# Resolution beats.
# ---------------------------------------------------------------------------
func _begin_resolution() -> void:
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.SUCCESS, "Discovery")
	# Reset per-run animation flags so resolving animations can re-trigger.
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
					var text: Dictionary = definition.get("text", {})
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
		return_button.text = String(definition.get("text", {}).get("return_label", "RETURN TO IRIS"))
		return_button.visible = true
		return_visible = true
	experience_completed.emit()

func _complete_experience() -> void:
	resolved = true
	visible = false

func _on_return_pressed() -> void:
	experience_return_requested.emit()

# ---------------------------------------------------------------------------
# Per-frame: also drive resolution beats when in resolving phase.
# ---------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	if not visible or phase_index < 0:
		return
	if phase_index >= 0 and phase_index < phases.size():
		var pid := String(phases[phase_index].get("id", ""))
		if pid == "resolving" and resolving:
			_process_resolution_beats(phases[phase_index])

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _color(arr: Variant) -> Color:
	if arr is Array and arr.size() >= 3:
		return Color(float(arr[0]), float(arr[1]), float(arr[2]))
	return Color.WHITE

func _vec3(arr: Variant) -> Vector3:
	if arr is Array and arr.size() >= 3:
		return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))
	return Vector3.ZERO

# Backwards-compat / diagnostics
func active_experience_id() -> String:
	return String(definition.get("id", ""))

func current_phase_id() -> String:
	if phase_index >= 0 and phase_index < phases.size():
		return String(phases[phase_index].get("id", ""))
	return ""

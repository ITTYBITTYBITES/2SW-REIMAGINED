extends Control
class_name DioramaEngine

## Diorama Engine — the 3D experience renderer for Two Second Witness.
##
## This is the experience renderer that sits between the Living Iris portal and
## a memory experience. It owns the 3D camera, the world environment, the
## lighting stage, and the root where exactly one Diorama experience scene is
## instantiated and rendered at a time.
##
## Architectural boundary (per the experience-path reset):
##   - It is NOT a generic moment/phase/framework system. One engine, one
##     active experience at a time, launched by scene path from the Application.
##   - It does not know what a "clock" or a "witness" is. It renders whatever
##     experience scene the Application hands it.
##
## The 3D world lives inside a SubViewport so the 2D Living Iris layer and the
## 3D memory layer are cleanly isolated and can be shown/hidden independently.
##
## SCAFFOLD NOTE: the camera/environment/light rig here are minimal and exist
## to prove the 3D launch path. The full cinematic 3D lighting/atmosphere
## treatment is defined in MISSION_073D and lands with production art.

signal experience_completed
signal experience_return_requested

const VIEWPORT_WIDTH := 540
const VIEWPORT_HEIGHT := 960

var viewport_container: SubViewportContainer
var viewport: SubViewport
var camera: Camera3D
var experience_root: Node3D
var current_experience: Node = null

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	viewport_container = SubViewportContainer.new()
	viewport_container.name = "ViewportContainer"
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(viewport_container)

	viewport = SubViewport.new()
	viewport.name = "DioramaViewport"
	viewport.size = Vector2i(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
	viewport.disable_3d = false
	# The SubViewport must own its own 3D world; otherwise it tries to share the
	# parent window's world (this app is 2D-rooted) and the 3D scene never renders.
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	viewport_container.add_child(viewport)

	# Minimal 3D environment/atmosphere (slate memory darkness). The 073D
	# color-script + fog/grade replaces this when art lands.
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.010, 0.018, 0.028)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.22, 0.28, 0.32)
	environment.ambient_light_energy = 0.9
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.06, 0.12, 0.16)
	environment.fog_light_energy = 0.35
	environment.fog_density = 0.04
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = environment
	viewport.add_child(world_env)

	camera = Camera3D.new()
	camera.name = "DioramaCamera"
	camera.fov = 50.0
	# Portrait composition, eye-height, looking into the stage at the centered clock.
	camera.transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 1.6, 5.2))
	viewport.add_child(camera)
	# Make current AFTER parenting so the SubViewport adopts it as active camera.
	camera.current = true

	# Scaffold key/fill light. Replaced by the 073D emotional-lighting rig.
	var key_light := DirectionalLight3D.new()
	key_light.name = "KeyLight"
	key_light.rotation_degrees = Vector3(-40.0, 25.0, 0.0)
	key_light.light_energy = 1.4
	key_light.light_color = Color(1.0, 0.90, 0.72)
	viewport.add_child(key_light)

	experience_root = Node3D.new()
	experience_root.name = "ExperienceRoot"
	viewport.add_child(experience_root)

## Launch a Diorama experience scene. Clears any active experience first, then
## instantiates the scene under ExperienceRoot, wires its signals, and calls its
## begin() entry point if present. Returns true on success.
func launch_experience(packed_scene: PackedScene) -> bool:
	if packed_scene == null:
		push_error("[DioramaEngine] Cannot launch experience: scene is null.")
		return false
	clear_experience()
	var instance := packed_scene.instantiate()
	if instance == null:
		push_error("[DioramaEngine] Failed to instantiate experience scene.")
		return false
	experience_root.add_child(instance)
	current_experience = instance
	if instance.has_signal("completed"):
		instance.completed.connect(_on_experience_completed)
	if instance.has_signal("return_requested"):
		instance.return_requested.connect(_on_experience_return_requested)
	if instance.has_method("begin"):
		instance.begin()
	visible = true
	return true

## Clear the active experience and hide the engine.
func clear_experience() -> void:
	if current_experience != null:
		if current_experience.has_method("close"):
			current_experience.close()
		if current_experience.is_inside_tree():
			current_experience.get_parent().remove_child(current_experience)
		current_experience.queue_free()
		current_experience = null
	visible = false

## The id/class of the active experience, if any (for routing/diagnostics).
func active_experience_id() -> String:
	if current_experience == null:
		return ""
	return current_experience.name

func _on_experience_completed() -> void:
	experience_completed.emit()

func _on_experience_return_requested() -> void:
	experience_return_requested.emit()

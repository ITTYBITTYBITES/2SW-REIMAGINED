extends SceneTree

## Experience One launch-path validation.
##
## Validates the new architecture: Living Iris → Iris portal → Diorama Engine →
## Clock Witness Experience → return → Iris Home.
##
## This test drives the Application through its PUBLIC flow (portal transition,
## diorama launch, experience begin/return) rather than reaching into a button
## signal. It cannot prove a physical tap reaches the 3D RETURN button
## headlessly — that is covered by the graphical runtime capture — but it does
## confirm the launch path, 3D renderer activation, and return routing are
## structurally sound.
var failures: Array[String] = []

const EXPERIENCE_ONE_ID := "experience_one"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/Application.tscn")
	_assert(scene != null, "Application scene loads")
	if scene == null:
		_finish()
		return
	var app: PrototypeApplication = scene.instantiate()
	root.add_child(app)
	await process_frame

	_assert(app.diorama_engine != null, "Application owns a DioramaEngine")
	_assert(app.diorama_engine is DioramaEngine, "DioramaEngine is the 3D experience renderer")
	_assert(not app.diorama_engine.visible, "DioramaEngine is hidden during Iris presence")
	_assert(app.experience_one_scene != null, "Experience One scene (Clock Witness) is preloaded")
	_assert(app.diorama_engine.experience_root != null, "DioramaEngine has a 3D ExperienceRoot")
	_assert(app.diorama_engine.camera != null and app.diorama_engine.camera.current, "DioramaEngine has an active 3D Camera3D")

	# Verify the old experience is fully gone.
	_assert(ResourceLoader.exists("res://scenes/MissingSecondExperience.tscn") == false, "old MissingSecond scene is removed")
	_assert(DirAccess.dir_exists_absolute("res://assets/missing_second") == false, "old missing_second asset folder is removed")

	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Iris Home is available before launching Experience One")

	# Launch Experience One and let the Iris portal complete its entry naturally,
	# exactly as it does in the real game (the portal fires entry_arrived once).
	app.start_experience_one()
	await create_timer(3.2).timeout  # portal entry (~2.44s) completes → launch
	_assert(app.diorama_engine.visible, "DioramaEngine becomes visible after Iris portal entry")
	_assert(app.diorama_engine.current_experience != null, "an experience is mounted in the Diorama Engine")
	_assert(app.diorama_engine.current_experience is ClockWitnessExperience, "Experience One is the Clock Witness memory")
	_assert(app.diorama_engine.current_experience.has_method("begin"), "experience exposes begin() entry point")
	_assert(app.diorama_engine.current_experience.has_signal("return_requested"), "experience exposes return_requested signal")

	# Return from the experience through the public Application route.
	app.return_from_experience_one()
	await create_timer(2.0).timeout
	_assert(not app.diorama_engine.visible, "DioramaEngine is hidden after return")
	_assert(app.diorama_engine.current_experience == null, "experience is cleared after return")

	app.free()
	await process_frame
	_finish()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _finish() -> void:
	if failures.is_empty():
		print("EXPERIENCE_ONE_LAUNCH_PASS")
		quit(0)
	quit(1)

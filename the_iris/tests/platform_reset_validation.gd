extends SceneTree

## Platform integrity validation after the experience-path reset.
##
## Confirms:
##   - retired generic/WM/flagship runtimes remain absent;
##   - the retired Missing Second experience is fully removed;
##   - the Living Iris Home + Diorama Engine experience renderer are present;
##   - the Experience One launch path routes Iris → Diorama → return → Iris.
##
## (Earlier versions asserted an obsolete "WitnessResetView / show_witness_reset"
## empty-entry state and hung when those were absent. Witness now launches a real
## Diorama experience; this test has been reconciled with that reality.)
var failures: Array[String] = []

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

	# Retired runtimes must remain absent.
	for retired in ["GenericWitnessGameplay", "WitnessMomentOrchestrator", "WM001GameplayLoop", "FlagshipWitnessMoment"]:
		_assert(app.get_node_or_null(retired) == null, "retired runtime absent: %s" % retired)

	# Retired Missing Second experience must be fully removed.
	_assert(ResourceLoader.exists("res://scenes/MissingSecondExperience.tscn") == false, "retired MissingSecond scene is removed")
	_assert(DirAccess.dir_exists_absolute("res://assets/missing_second") == false, "retired missing_second asset folder is removed")

	# Living Iris + Home must remain available.
	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Living Iris Home remains available")

	# The Diorama Engine experience renderer must be present and wired.
	_assert(app.diorama_engine != null and app.diorama_engine is DioramaEngine, "Diorama Engine experience renderer is present")
	_assert(app.experience_one_scene != null, "Experience One (Clock Witness) scene is registered")

	# Experience One launch → Diorama → return → Home routing. Drive the natural
	# portal flow (entry fires once, then return) exactly as the real game does.
	app.start_experience_one()
	await create_timer(3.2).timeout  # portal entry completes → Diorama launches
	_assert(app.diorama_engine.visible, "Experience One launches into the Diorama Engine")
	_assert(app.diorama_engine.current_experience is ClockWitnessExperience, "Clock Witness is the active Diorama experience")
	app.return_from_experience_one()
	await create_timer(3.0).timeout  # return portal completes → show_home
	_assert(not app.diorama_engine.visible, "Diorama Engine hides after return")
	_assert(app.diorama_engine.current_experience == null, "experience cleared after return")

	app.free()
	await process_frame
	_finish()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _finish() -> void:
	if failures.is_empty():
		print("PLATFORM_RESET_VALIDATION_PASS")
		quit(0)
	quit(1)

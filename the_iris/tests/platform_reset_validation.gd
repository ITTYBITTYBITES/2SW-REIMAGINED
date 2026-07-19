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
	_assert(ResourceLoader.exists("res://scenes/ClockWitnessExperience.tscn") == false, "renderer-validation scene removed")
	_assert(DirAccess.dir_exists_absolute("res://assets/missing_second") == false, "retired missing_second asset folder is removed")

	# Living Iris + Home must remain available.
	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Living Iris Home remains available")

	# The DioramaPlayer (SOP v2 addon-based engine) must be present and JSON-driven.
	_assert(app.diorama_player != null and app.diorama_player is DioramaPlayer, "DioramaPlayer experience renderer is present")
	_assert(FileAccess.file_exists("res://content/missing_second/missing_second.json"), "Experience One is a JSON definition")

	# Experience One launch -> DioramaPlayer -> return -> Iris routing. Natural portal flow.
	app.start_experience_one()
	await create_timer(3.2).timeout
	_assert(app.diorama_player.visible, "Experience One launches into the DioramaPlayer")
	_assert(app.diorama_player.objects.size() >= 12, "player assembles the scene from JSON")
	app.return_from_experience()
	await create_timer(3.0).timeout
	_assert(not app.diorama_player.visible, "DioramaPlayer hides after return")

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

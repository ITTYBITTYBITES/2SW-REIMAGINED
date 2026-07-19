extends SceneTree

## Experience One launch-path validation (JSON-driven architecture).
##
## Validates: Living Iris -> Iris portal -> Diorama Engine assembles Experience
## One from its JSON definition -> the full Missing Second timeline runs ->
## correct interaction triggers resolution -> return -> Iris Home.
##
## Drives the Application through its public flow. Interaction discovery is
## simulated by invoking the engine's internal dispatch (the real tap path is
## covered by graphical runtime capture — see DIORAMA_LAUNCH_EVIDENCE).
var failures: Array[String] = []

const EXPERIENCE_ONE_ID := "experience_one"
const DEFINITION_PATH := "res://content/experience_one/experience_one.json"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/Application.tscn")
	_assert(scene != null, "Application scene loads")
	if scene == null:
		_finish(); return
	var app: PrototypeApplication = scene.instantiate()
	root.add_child(app)
	await process_frame

	_assert(app.diorama_engine != null and app.diorama_engine is DioramaEngine, "Application owns a DioramaEngine")
	_assert(not app.diorama_engine.visible, "DioramaEngine is hidden during Iris presence")
	_assert(FileAccess.file_exists(DEFINITION_PATH), "Experience One JSON definition exists")
	_assert(ResourceLoader.exists("res://scenes/ClockWitnessExperience.tscn") == false, "renderer-validation scene removed")
	_assert(DirAccess.dir_exists_absolute("res://assets/missing_second") == false, "old missing_second assets remain removed")

	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Iris Home available before launch")

	# Launch via the natural portal flow (entry fires once on completion).
	app.start_experience_one()
	await create_timer(3.2).timeout
	_assert(app.diorama_engine.visible, "DioramaEngine becomes visible after portal entry")
	var engine: DioramaEngine = app.diorama_engine
	_assert(engine.objects.size() >= 12, "engine assembled objects from JSON (got %d)" % engine.objects.size())
	_assert(engine.objects.has("clock_pivot"), "clock_pivot assembled")
	_assert(engine.objects.has("second_hand"), "second_hand assembled")
	_assert(engine.objects.has("traveler"), "traveler assembled")
	_assert(engine.interaction_nodes.size() == 4, "four interactions wired (tea/suitcase/photograph/clock)")
	_assert(engine.current_phase_id() in ["forming","observing","reconstructing","investigating"], "timeline is running (phase=%s)" % engine.current_phase_id())

	# Fast-forward to investigation by waiting in wall-clock increments until
	# interactions are enabled (the timeline is time-based; process_frame loops
	# run uncapped in headless, so wall-clock waits are required).
	var waited := 0.0
	while not engine.interactions_enabled and waited < 8.0:
		await create_timer(0.2).timeout
		waited += 0.2
	_assert(engine.interactions_enabled, "investigation phase enables interactions (waited %.1fs, phase=%s)" % [waited, engine.current_phase_id()])
	_assert(engine.current_phase_id() == "investigating", "reached investigating phase (got %s)" % engine.current_phase_id())

	# Simulate the correct discovery (clock). The engine exposes its dispatch
	# for validation; the real input path is verified in graphical capture.
	engine._dispatch_interaction("clock")
	await create_timer(0.4).timeout
	_assert(engine.current_phase_id() == "resolving", "correct clock selection enters resolving (got %s)" % engine.current_phase_id())
	# Resolution beats are time-based (3.0s phase); wait wall-clock for completion.
	waited = 0.0
	while not engine.resolved and waited < 6.0:
		await create_timer(0.2).timeout
		waited += 0.2
	_assert(engine.resolved, "resolution completes (waited %.1fs)" % waited)
	_assert(engine.return_button.visible, "RETURN TO IRIS appears after resolution")

	# Return through the public Application route.
	app.return_from_experience_one()
	await create_timer(3.0).timeout
	_assert(not engine.visible, "DioramaEngine hides after return")
	_assert(app.iris.visible, "Living Iris restored after return")

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

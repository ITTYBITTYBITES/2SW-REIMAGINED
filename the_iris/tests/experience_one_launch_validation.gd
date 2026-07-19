extends SceneTree

## Experience One launch-path validation (DioramaPlayer / SOP v2 architecture).
##
## Validates: Living Iris -> Iris portal -> DioramaPlayer assembles Experience
## One from its JSON definition -> the full Missing Second timeline runs ->
## correct clue interaction triggers resolution -> return -> Living Iris.
##
## Drives the Application through its public flow. Interaction discovery is
## simulated by invoking the player's internal dispatch (the real tap path is
## covered by graphical runtime capture — see DIORAMA_LAUNCH_EVIDENCE).
##
## NOTE: this test was ported after the "Diorama Engine SOP Reset" commit, which
## renamed the engine from `diorama_engine` (DioramaEngine) to
## `diorama_player` (DioramaPlayer, addons/diorama_engine) and moved the active
## definition to content/missing_second/missing_second.json (clue_* ids).
var failures: Array[String] = []

const EXPERIENCE_ONE_ID := "missing_second"
const DEFINITION_PATH := "res://content/missing_second/missing_second.json"

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

	_assert(app.diorama_player != null and app.diorama_player is DioramaPlayer, "Application owns a DioramaPlayer")
	_assert(not app.diorama_player.visible, "DioramaPlayer is hidden during Iris presence")
	_assert(FileAccess.file_exists(DEFINITION_PATH), "Experience One JSON definition exists")

	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Iris Home available before launch")

	# Launch via the natural portal flow (entry fires once on completion).
	app.start_experience_one()
	await create_timer(3.2).timeout
	_assert(app.diorama_player.visible, "DioramaPlayer becomes visible after portal entry")
	var player: DioramaPlayer = app.diorama_player
	_assert(player.objects.size() >= 12, "player assembled objects from JSON (got %d)" % player.objects.size())
	_assert(player.objects.has("clock_pivot"), "clock_pivot assembled")
	_assert(player.objects.has("traveler"), "traveler assembled")
	_assert(player.interaction_nodes.size() == 4, "four clue interactions wired")
	_assert(player.current_phase_id() in ["forming","observing","reconstructing","investigating"], "timeline is running (phase=%s)" % player.current_phase_id())

	# Fast-forward to investigation by waiting in wall-clock increments until
	# interactions are enabled (the timeline is time-based; process_frame loops
	# run uncapped in headless, so wall-clock waits are required).
	var waited := 0.0
	while not player.interactions_enabled and waited < 8.0:
		await create_timer(0.2).timeout
		waited += 0.2
	_assert(player.interactions_enabled, "investigation phase enables interactions (waited %.1fs, phase=%s)" % [waited, player.current_phase_id()])
	_assert(player.current_phase_id() == "investigating", "reached investigating phase (got %s)" % player.current_phase_id())

	# Simulate the correct discovery (clock clue). The clue id in missing_second.json
	# is "clue_clock"; fall back to "clock" if the definition uses the older id.
	var clock_clue_id := "clue_clock" if player.interaction_nodes.has("clue_clock") else "clock"
	_assert(player.interaction_nodes.has(clock_clue_id), "clock clue interaction exists (%s)" % clock_clue_id)
	player._dispatch_interaction(clock_clue_id)
	await create_timer(0.4).timeout
	_assert(player.current_phase_id() == "resolving", "correct clock selection enters resolving (got %s)" % player.current_phase_id())
	# Resolution beats are time-based (3.0s phase); wait wall-clock for completion.
	waited = 0.0
	while not player.resolved and waited < 6.0:
		await create_timer(0.2).timeout
		waited += 0.2
	_assert(player.resolved, "resolution completes (waited %.1fs)" % waited)
	_assert(player.return_button.visible, "RETURN TO IRIS appears after resolution")

	# Return through the public Application route.
	app.return_from_experience()
	await create_timer(3.0).timeout
	_assert(not player.visible, "DioramaPlayer hides after return")
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

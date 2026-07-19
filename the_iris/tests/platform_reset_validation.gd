extends SceneTree

## Mission 071B platform validation. Confirms the application boots with the
## old gameplay branch absent and one intentional empty Witness entry state.
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
	_assert(app.get_node_or_null("GenericWitnessGameplay") == null, "retired generic runtime is absent")
	_assert(app.get_node_or_null("WitnessMomentOrchestrator") == null, "retired orchestrator is absent")
	_assert(app.get_node_or_null("WM001GameplayLoop") == null, "retired WM-001 prototype is absent")
	_assert(app.get_node_or_null("FlagshipWitnessMoment") == null, "retired flagship prototype is absent")
	_assert(app.get_node_or_null("WitnessResetView") != null, "intentional empty Witness entry exists")
	app.startup._finish()
	app.show_home()
	await process_frame
	_assert(app.home.visible and app.iris.visible, "Iris Home remains available")
	app.show_witness_reset()
	_assert(app.reset_view.visible and not app.home.visible, "Witness entry intentionally shows reset state")
	app.show_home()
	_assert(app.home.visible and not app.reset_view.visible, "return to Iris Home works")
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

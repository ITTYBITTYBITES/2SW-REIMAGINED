extends SceneTree

## Current-product smoke test: the retained Iris path and every Witness Moment
## must load, transition, and complete without external systems.
func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/Application.tscn")
	if scene == null:
		_fail("Application scene did not load")
		return
	var app: PrototypeApplication = scene.instantiate()
	root.add_child(app)
	await process_frame

	if app.registry.chapter_moments().size() != 5:
		_fail("Expected exactly five retained Witness Moments")
		return
	if app.iris.iris_core.state != IrisCore.State.DORMANT:
		_fail("Iris did not begin dormant")
		return

	app.startup._finish()
	if app.iris.iris_core.state != IrisCore.State.CALIBRATING:
		_fail("Boot did not enter Iris calibration")
		return
	app.iris.iris_core.tick(0.7)
	if app.iris.iris_core.state != IrisCore.State.STIRRING:
		_fail("Calibration did not advance to stirring")
		return
	app.iris.iris_core.tick(1.1)
	if app.iris.iris_core.state != IrisCore.State.AWAKENING:
		_fail("Stirring did not advance to awakening")
		return
	app.iris.iris_core.tick(1.8)
	if app.iris.iris_core.state != IrisCore.State.WELCOMING:
		_fail("Awakening did not advance to welcoming")
		return
	app.iris.iris_core.tick(2.3)
	if app.iris.iris_core.state != IrisCore.State.AWARE:
		_fail("Welcoming did not advance to aware")
		return

	var tap := InputEventMouseButton.new()
	tap.pressed = true
	tap.position = Vector2(270.0, 440.0)
	app.iris._gui_input(tap)
	if app.iris.iris_core.state != IrisCore.State.ATTENDING:
		_fail("Iris did not acquire attention before focus")
		return
	app.iris.iris_core.tick(0.4)
	if app.iris.iris_core.state != IrisCore.State.FOCUSED:
		_fail("Attention did not advance to focused")
		return
	await create_timer(0.65).timeout
	if not app.home.visible or app.iris.iris_core.state != IrisCore.State.SETTLED:
		_fail("Focused Iris interaction did not arrive at settled Home")
		return
	if not app.iris.visible or app.iris.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("Home did not retain the Living Iris as a non-interactive presence")
		return
	var rest_action := app.home.get_node_or_null("RestWithIris") as Button
	if rest_action == null:
		_fail("Home rest action is unavailable")
		return
	rest_action.pressed.emit()
	await process_frame
	if app.home.visible or not app.iris.visible or app.iris.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("Home rest action did not restore direct Iris presence")
		return
	app.show_home()
	await process_frame
	var memory_field := app.home.get_node_or_null("MemoryField") as MemoryField
	if memory_field == null:
		_fail("Iris Home Memory Field is unavailable")
		return
	var shard_hover := InputEventMouseMotion.new()
	shard_hover.position = memory_field._shard_position()
	memory_field._gui_input(shard_hover)
	if app.iris.iris_core.state != IrisCore.State.ATTENDING:
		_fail("Continue Witness shard did not acquire Iris attention")
		return
	var intent_exit := InputEventMouseMotion.new()
	intent_exit.position = Vector2(20, 620)
	memory_field._gui_input(intent_exit)
	if app.iris.iris_core.state != IrisCore.State.SETTLED:
		_fail("Iris did not settle when Memory Field intent was released")
		return
	var shard_tap := InputEventMouseButton.new()
	shard_tap.pressed = true
	shard_tap.position = memory_field._shard_position()
	memory_field._gui_input(shard_tap)
	if app.iris.iris_core.state != IrisCore.State.ATTENDING:
		_fail("Continue Witness shard did not reacquire Iris attention")
		return
	await create_timer(0.5).timeout
	if not app.witness.visible or app.iris.iris_core.state != IrisCore.State.OBSERVING:
		_fail("Continue Witness shard did not enter the protected Witness flow")
		return

	for moment in app.director.chapter_moments():
		var id := str(moment["id"])
		app.witness.open_moment(id)
		for _phase in range(4):
			app.orchestrator.advance()
		app.orchestrator.advance()
		if not app.registry.is_completed(id):
			_fail("Moment did not complete: %s" % id)
			return
	if app.iris.iris_core.state != IrisCore.State.REFLECTIVE:
		_fail("Witness completion did not make the Iris reflective")
		return

	app.show_home()
	app.show_iris()
	if app.iris.iris_core.state != IrisCore.State.WELCOMING:
		_fail("Return path did not restore the welcoming Iris")
		return
	print("LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

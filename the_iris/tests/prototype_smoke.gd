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
	app.iris.iris_core.tick(0.8)
	if app.iris.iris_core.state != IrisCore.State.AWAKENING:
		_fail("Calibration did not advance to awakening")
		return
	app.iris.iris_core.tick(1.4)
	if app.iris.iris_core.state != IrisCore.State.WELCOMING:
		_fail("Awakening did not advance to welcoming")
		return
	app.iris.iris_core.tick(2.2)
	if app.iris.iris_core.state != IrisCore.State.AWARE:
		_fail("Welcoming did not advance to aware")
		return

	app.show_home()
	if app.iris.iris_core.state != IrisCore.State.SETTLED:
		_fail("Home transition did not settle the Iris")
		return
	app.show_witness()
	if app.iris.iris_core.state != IrisCore.State.OBSERVING:
		_fail("Witness transition did not focus the Iris on observation")
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
	print("LIVING_IRIS_SMOKE_PASS: boot, calibration, awakening, home, witness, return, and WM_001–WM_005 loaded.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

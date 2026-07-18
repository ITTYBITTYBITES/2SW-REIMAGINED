extends SceneTree

## Current-product smoke test: every retained moment must load and complete.
func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/Application.tscn")
	if scene == null:
		push_error("Application scene did not load")
		quit(1)
		return
	var app: PrototypeApplication = scene.instantiate()
	root.add_child(app)
	await process_frame
	if app.registry.chapter_moments().size() != 5:
		push_error("Expected exactly five retained Witness Moments")
		quit(1)
		return
	app.show_witness()
	for moment in app.director.chapter_moments():
		var id := str(moment["id"])
		app.witness.open_moment(id)
		for _phase in range(4):
			app.orchestrator.advance()
		app.orchestrator.advance()
		if not app.registry.is_completed(id):
			push_error("Moment did not complete: %s" % id)
			quit(1)
			return
	print("CLEAN_ROOM_SMOKE_PASS: startup, Iris, home, and WM_001–WM_005 loaded.")
	quit(0)

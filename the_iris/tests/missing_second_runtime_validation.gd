extends SceneTree

## Scene-local runtime smoke for The Missing Second. This does not replace
## required graphical human validation.
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
	app.startup._finish()
	app.show_home()
	await process_frame
	app.start_missing_second()
	await create_timer(3.0).timeout
	var experience := app.missing_second
	_assert(experience != null and experience.visible, "Missing Second becomes visible after Iris portal entry")
	await create_timer(1.4).timeout
	_assert(experience.state == MissingSecondExperience.State.OBSERVING, "living observation begins after memory formation")
	await create_timer(2.2).timeout
	_assert(experience.state == MissingSecondExperience.State.RECONSTRUCTING or experience.state == MissingSecondExperience.State.INVESTIGATING, "room freezes into reconstruction")
	await create_timer(0.7).timeout
	_assert(experience.state == MissingSecondExperience.State.INVESTIGATING, "physical object investigation begins")
	experience.tea_choice.pressed.emit()
	_assert(not experience.object_response.text.is_empty(), "wrong object receives contextual response")
	experience.clock.pressed.emit()
	_assert(experience.state == MissingSecondExperience.State.RESOLVING, "clock selection begins resolution")
	await create_timer(3.2).timeout
	_assert(experience.state == MissingSecondExperience.State.COMPLETE, "truth sequence reaches completion")
	_assert(experience.return_action.visible, "return action is visible after truth")
	experience.return_action.pressed.emit()
	await create_timer(2.0).timeout
	_assert(app.home.visible and not experience.visible, "return reaches Iris Home")
	app.free()
	await process_frame
	_finish()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _finish() -> void:
	if failures.is_empty():
		print("MISSING_SECOND_RUNTIME_PASS")
		quit(0)
	quit(1)

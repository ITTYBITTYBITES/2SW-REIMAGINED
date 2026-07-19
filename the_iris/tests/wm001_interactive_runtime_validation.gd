extends SceneTree

## Mission 067: exercises the actual Application → portal → GenericWitnessGameplay
## control path for WM-001 using real Button signals and real timers.
## Run: godot --headless --path . -s tests/wm001_interactive_runtime_validation.gd

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://scenes/Application.tscn")
	_assert(packed != null, "Application scene loads")
	if packed == null:
		_finish()
		return
	var app: PrototypeApplication = packed.instantiate()
	root.add_child(app)
	await process_frame

	# Complete boot before opening a memory so StartupFlow cannot supersede it.
	app.startup._finish()
	app.show_home()
	await process_frame
	app.request_memory_portal("WM_001")
	await create_timer(3.2).timeout

	var loop := app.generic_gameplay
	_assert(loop.visible, "GenericWitnessGameplay is visible after portal arrival")
	_assert(loop.phase == GenericWitnessGameplay.Phase.BRIEFING, "WM-001 enters visible briefing state")
	_assert(loop.in_intro_cinematic and not loop.action_button.visible, "briefing action is gated while intro cinematic forms")

	await create_timer(2.0).timeout
	_assert(not loop.in_intro_cinematic and loop.action_button.visible, "Begin Observation becomes available after intro cinematic")
	loop.action_button.pressed.emit()
	_assert(loop.phase == GenericWitnessGameplay.Phase.OBSERVATION, "Begin Observation enters observation phase")
	_assert(float(loop.timer_label.get_meta("remaining", -1.0)) > 0.0, "observation timer starts")

	await create_timer(2.3).timeout
	_assert(loop.phase == GenericWitnessGameplay.Phase.FRACTURE, "observation timer enters Fracture selection")
	_assert(loop.fracture_button.visible, "Fracture target is instantiated and visible")
	loop.fracture_button.pressed.emit()
	_assert(loop.active_fracture.discovery_state, "Fracture selection is evaluated as discovered")
	_assert(loop.action_button.visible, "Synchronization action becomes available after discovery")

	loop.action_button.pressed.emit()
	_assert(loop.phase == GenericWitnessGameplay.Phase.SYNCHRONIZATION, "Begin Synchronization enters synchronization phase")
	_assert(loop.synchronization_progress.visible and loop.stability_progress.visible, "synchronization controls are visible")
	loop.action_button.button_down.emit()
	await create_timer(1.2).timeout
	_assert(loop.active_fracture.synchronization_state, "hold focus completes synchronization")
	_assert(loop.phase == GenericWitnessGameplay.Phase.CONTEXT, "successful synchronization enters evidence selection")
	_assert(loop.evidence_container.visible, "evidence selection controls are visible")

	for child in loop.evidence_container.get_children():
		if child is Button:
			(child as Button).pressed.emit()
	loop.action_button.pressed.emit()
	_assert(loop.phase == GenericWitnessGameplay.Phase.REVELATION, "selected evidence enters Revelation")
	loop.action_button.pressed.emit()
	_assert(loop.phase == GenericWitnessGameplay.Phase.TRUTH_FRAGMENT, "Revelation enters Truth Fragment presentation")
	loop.action_button.pressed.emit()
	await process_frame
	_assert(loop.phase == GenericWitnessGameplay.Phase.REWARD, "Truth Fragment produces reward state")
	_assert(app.witness_profile.completed_moment_ids.has("WM_001"), "WM-001 completion records profile")
	_assert(str(app.witness_profile.moment_records.get("WM_001", {}).get("truth_fragment_id", "")) == "fragment_borrowed_light", "Borrowed Light is persisted")

	loop.action_button.pressed.emit()
	await create_timer(2.0).timeout
	_assert(app.home.visible and not loop.visible, "reward return reaches Iris Home through portal")
	app.free()
	await process_frame
	_finish()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _finish() -> void:
	if failures.is_empty():
		print("M067_INTERACTIVE_WM001_PASS")
		quit(0)
	quit(1)

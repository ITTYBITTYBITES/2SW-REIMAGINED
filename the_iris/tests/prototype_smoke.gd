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
	var response_intents: Array = []
	var evolution_updates: Array = []
	app.iris_personality.response_intent_emitted.connect(func(intent): response_intents.append(intent))
	app.iris_evolution_updated.connect(func(data): evolution_updates.append(data))

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
	var introducing_intent := _find_intent(response_intents, "boot_complete", "INTRODUCING")
	if introducing_intent == null or introducing_intent.audio_key.is_empty() or introducing_intent.voice_key.is_empty():
		_fail("Boot did not emit an introducing response intent contract")
		return
	if app.iris.expression_overlay.active_intent == null or app.iris.expression_overlay.active_intent.expression_mode != "INTRODUCING" or app.iris.expression_overlay.message_label.text.is_empty():
		_fail("Introducing intent did not reach the Iris expression consumer")
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
	if _find_intent(response_intents, "memory_focus", "CURIOUS") == null:
		_fail("Memory focus did not emit a curious response intent")
		return
	if app.iris.expression_overlay.active_intent == null or app.iris.expression_overlay.active_intent.expression_mode != "CURIOUS":
		_fail("Curious intent did not reach the Iris expression consumer")
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
	if not app.wm001_gameplay.visible or app.iris.iris_core.state != IrisCore.State.OBSERVING:
		_fail("Continue Witness shard did not enter the WM_001 gameplay loop")
		return
	if _find_intent(response_intents, "memory_focus", "ATTENTIVE") == null:
		_fail("Focused memory did not emit an attentive response intent")
		return
	if _find_intent(response_intents, "memory_selected", "GUIDING") == null or _find_intent(response_intents, "witness_entered", "GUIDING") == null:
		_fail("Memory selection did not emit guiding response intents")
		return

	var loop := app.wm001_gameplay
	loop._advance()
	await create_timer(2.1).timeout
	if loop.phase != WM001GameplayLoop.Phase.DISCOVERY:
		_fail("WM_001 did not complete its two-second observation")
		return
	loop._find_anomaly()
	loop._advance()
	if loop.phase != WM001GameplayLoop.Phase.CONTEXT:
		_fail("WM_001 did not advance from anomaly capture to context")
		return
	for evidence_key in ["paused_brush", "crystal_prism", "color_notes"]:
		var evidence_button := loop.evidence_container.get_node("Evidence_%s" % evidence_key) as Button
		if evidence_button == null:
			_fail("WM_001 evidence interaction is missing: %s" % evidence_key)
			return
		evidence_button.pressed.emit()
	loop._advance()
	if loop.phase != WM001GameplayLoop.Phase.RESOLUTION:
		_fail("WM_001 did not resolve after context collection")
		return
	loop._advance()
	await process_frame
	if loop.phase != WM001GameplayLoop.Phase.REWARD:
		_fail("WM_001 did not produce a reward result")
		return
	if not app.registry.is_completed("WM_001") or not app.witness_profile.completed_moment_ids.has("WM_001"):
		_fail("WM_001 completion did not update the protected route and local profile")
		return
	if evolution_updates.is_empty() or app.latest_iris_evolution == null:
		_fail("Profile completion did not emit an Iris evolution hook")
		return
	if app.iris.iris_core.state != IrisCore.State.REFLECTIVE:
		_fail("WM_001 completion did not make the Iris reflective")
		return
	if _find_intent(response_intents, "witness_completed", "REFLECTIVE") == null:
		_fail("Witness completion did not emit a reflective response intent")
		return

	var hub_returns_before_reflection := _count_intents(response_intents, "hub_return", "IDLE")
	loop._advance()
	if not app.home.visible:
		_fail("WM_001 reward did not return to Iris Hub")
		return
	if app.iris.iris_core.state != IrisCore.State.REFLECTIVE:
		_fail("Reflective return did not preserve Iris reflection in the Hub")
		return
	if app.iris.expression_overlay.active_intent == null or app.iris.expression_overlay.active_intent.expression_mode != "REFLECTIVE":
		_fail("Reflective response did not reach the Iris expression consumer")
		return
	await create_timer(1.8).timeout
	if app.iris.iris_core.state != IrisCore.State.SETTLED:
		_fail("Reflective Hub return did not settle after its presentation interval")
		return
	if _count_intents(response_intents, "hub_return", "IDLE") <= hub_returns_before_reflection:
		_fail("Reflective Hub return did not emit a new idle response intent")
		return

	# WM_002–WM_005 remain playable through the unchanged generic Witness runtime.
	app.show_witness()
	for moment_id in ["WM_002", "WM_003", "WM_004", "WM_005"]:
		app.witness.open_moment(moment_id)
		for _phase in range(5):
			app.orchestrator.advance()
		if not app.registry.is_completed(moment_id):
			_fail("Protected Witness Moment did not complete: %s" % moment_id)
			return
	app.show_home()
	await create_timer(1.8).timeout
	app.show_iris()
	if app.iris.iris_core.state != IrisCore.State.WELCOMING:
		_fail("Return path did not restore the welcoming Iris")
		return
	print("LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.")
	quit(0)

func _find_intent(intents: Array, event_key: String, mode: String) -> IrisResponseIntent:
	for intent: IrisResponseIntent in intents:
		if intent.source_event == event_key and intent.expression_mode == mode:
			return intent
	return null

func _count_intents(intents: Array, event_key: String, mode: String) -> int:
	var count := 0
	for intent: IrisResponseIntent in intents:
		if intent.source_event == event_key and intent.expression_mode == mode:
			count += 1
	return count

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

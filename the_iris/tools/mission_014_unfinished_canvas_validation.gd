extends SceneTree

## MISSION 014 — The Unfinished Canvas validation harness.
## Headless usage:
##   godot --headless --path the_iris --script res://tools/mission_014_unfinished_canvas_validation.gd
##
## Validates INC_UNFINISHED_CANVAS / WM_001 player experience loop:
##   - Incident registry loading
##   - Moment 001 narrative and setting contracts
##   - Observation profile (2s cinematic duration, notable details)
##   - Reconstruction palette & ghost outlines (spatial drag-and-drop contract)
##   - Investigation attunements & discovery threshold (spectral, forensic, trajectory, text)
##   - Revelation & archive mapping (dynamic archive entry assembly)
##   - PlayerProgressService result recording
##
## Exit code 0 = GREEN, 1 = RED.

func _initialize() -> void:
	for _i: int in range(5):
		await process_frame
	var checks_script: GDScript = load("res://tools/mission_014_unfinished_canvas_validation_checks.gd")
	if checks_script == null:
		print("FAIL | bootstrap could not load checks script")
		quit(1)
		return
	var checks_node: Node = checks_script.new()
	root.add_child(checks_node)
	var failed_count: int = await checks_node.run_checks(self)
	root.remove_child(checks_node)
	checks_node.queue_free()
	quit(1 if failed_count > 0 else 0)

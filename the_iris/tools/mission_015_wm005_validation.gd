extends SceneTree

## WM_005 The Witness validation harness.
## Headless usage:
##   godot --headless --path the_iris --script res://tools/mission_015_wm005_validation.gd

func _initialize() -> void:
	for _i: int in range(5):
		await process_frame
	var checks_script: GDScript = load("res://tools/mission_015_wm005_validation_checks.gd")
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

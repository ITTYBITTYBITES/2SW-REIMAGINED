extends SceneTree

## MISSION 012 — Incident Registry Runtime validation harness (bootstrap).
## Headless usage:
##   godot --headless --path the_iris --script res://tools/incident_registry_validation.gd
##
## This bootstrap waits for the autoload graph to finish booting, then loads
## and runs the check suite from `incident_registry_validation_checks.gd`.
## The two-step shape is required because scripts that reference autoload
## singleton identifiers can only compile after the autoloads are registered.
##
## Exit code 0 = GREEN, 1 = RED.

func _initialize() -> void:
	for _i: int in range(5):
		await process_frame
	var checks_script: GDScript = load("res://tools/incident_registry_validation_checks.gd")
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

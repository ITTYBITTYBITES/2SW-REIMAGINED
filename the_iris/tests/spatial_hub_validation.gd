extends SceneTree

## Platform-only Spatial Hub validation after Witness runtime reset.
func _init() -> void:
	var source := FileAccess.get_file_as_string("res://scripts/home/SpatialHub.gd")
	var app_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	var failures: Array[String] = []
	for token in ["SpatialHubRoot", "Foreground_Nav", "Midground_Active", "Background_Constellation", "Camera3D.new()"]:
		if not source.contains(token):
			failures.append("Missing retained platform hub element: %s" % token)
	if not source.contains("witness_requested"):
		failures.append("Witness entry state is unavailable")
	if not app_source.contains("show_witness_reset"):
		failures.append("Application does not expose reset witness entry state")
	if failures.is_empty():
		print("Spatial Hub platform validation passed.")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)

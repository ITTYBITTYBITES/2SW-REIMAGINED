extends SceneTree

## Platform navigation validation after the experience-path reset.
##
## Validates the KEPT navigation contract that the Application depends on:
##   - SpatialHub exposes `witness_requested` (the Witness entry signal)
##   - Application wires `witness_requested` to the Experience One launch
##   - The retired Missing Second wiring is gone
##
## (Earlier versions of this test asserted a 3D SpatialHub vocabulary and a
## `show_witness_reset` entry that never existed in this codebase snapshot;
## those assertions are stale and have been reconciled with the real contract.)
func _init() -> void:
	var hub_source := FileAccess.get_file_as_string("res://scripts/home/SpatialHub.gd")
	var app_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	var home_source := FileAccess.get_file_as_string("res://scripts/home/IrisHome.gd")
	var failures: Array[String] = []

	if not hub_source.contains("signal witness_requested"):
		failures.append("SpatialHub does not expose the witness_requested signal")
	if not hub_source.contains("WITNESS"):
		failures.append("SpatialHub does not expose the WITNESS entry affordance")
	if not home_source.contains("witness_requested"):
		failures.append("IrisHome does not forward the witness_requested navigation signal")
	# The experience path routes through the DioramaPlayer (SOP v2 renamed the
	# engine from DioramaEngine to the addons/diorama_engine DioramaPlayer).
	if not app_source.contains("start_experience_one"):
		failures.append("Application does not wire witness entry to Experience One launch")
	if not (app_source.contains("DioramaPlayer") or app_source.contains("DioramaEngine")):
		failures.append("Application does not route the experience through the Diorama engine")
	# The retired path must be gone.
	if app_source.contains("start_missing_second"):
		failures.append("Retired Missing Second launch wiring still present in Application")
	if app_source.contains("MissingSecondExperience"):
		failures.append("Retired Missing Second scene reference still present in Application")

	if failures.is_empty():
		print("Spatial Hub platform validation passed.")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)

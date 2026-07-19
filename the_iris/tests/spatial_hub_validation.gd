extends SceneTree

## Static Mission 054B contract validation.
## Run with: godot --headless -s tests/spatial_hub_validation.gd

const HUB_PATH := "res://scripts/home/SpatialHub.gd"
const HOME_PATH := "res://scripts/home/IrisHome.gd"
const APP_PATH := "res://scripts/Application.gd"

var failures: Array[String] = []

func _init() -> void:
	_assert(FileAccess.file_exists(HUB_PATH), "SpatialHub script is missing")
	_assert(FileAccess.file_exists(HOME_PATH), "IrisHome host script is missing")
	_assert(FileAccess.file_exists(APP_PATH), "Application route script is missing")
	var hub_source := FileAccess.get_file_as_string(HUB_PATH)
	var home_source := FileAccess.get_file_as_string(HOME_PATH)
	var app_source := FileAccess.get_file_as_string(APP_PATH)
	for layer_name in ["SpatialHubRoot", "Foreground_Nav", "Midground_Active", "Background_Constellation"]:
		_assert(hub_source.contains(layer_name), "Missing spatial hierarchy layer: %s" % layer_name)
	_assert(hub_source.contains("Node3D.new()"), "Spatial hub does not create Node3D foundation nodes")
	_assert(hub_source.contains("Camera3D.new()"), "Spatial hub does not create camera movement foundation")
	_assert(hub_source.contains("ORBIT_SPEED"), "Spatial hub does not expose orbit behavior")
	_assert(hub_source.contains("shard_focused") and hub_source.contains("shard_selected"), "Spatial hub selection signals are incomplete")
	_assert(hub_source.contains("FM_001") and hub_source.contains("WM_001"), "Spatial hub does not use existing memory identifiers")
	_assert(home_source.contains("SpatialHub.new()"), "IrisHome does not host SpatialHub")
	_assert(home_source.contains("witness_chapters_requested.emit()"), "Story route no longer reaches existing chapter navigation")
	_assert(home_source.contains("archive_requested.emit()"), "Archive route no longer reaches existing archive navigation")
	_assert(app_source.contains("home.configure(witness_profile, registry)"), "Application does not configure hub from existing authorities")
	if failures.is_empty():
		print("Spatial Hub validation passed.")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

extends SceneTree

## Mission 054C static portal contract validation.
## Run: godot --headless -s tests/iris_portal_validation.gd

const PORTAL_PATH := "res://scripts/iris/IrisPortalTransition.gd"
const IRIS_PATH := "res://scripts/iris/LivingIris.gd"
const APPLICATION_PATH := "res://scripts/Application.gd"

var failures: Array[String] = []

func _init() -> void:
	_assert(FileAccess.file_exists(PORTAL_PATH), "Iris portal transition script exists")
	var portal := FileAccess.get_file_as_string(PORTAL_PATH)
	var iris := FileAccess.get_file_as_string(IRIS_PATH)
	var application := FileAccess.get_file_as_string(APPLICATION_PATH)
	for state_name in ["READY", "FOCUSING", "DILATING", "ENTERING", "TRANSITIONING", "ARRIVED"]:
		_assert(portal.contains(state_name), "portal state exists: %s" % state_name)
	_assert(portal.contains("begin_entry") and portal.contains("begin_return"), "entry and return APIs exist")
	_assert(portal.contains("entry_arrived") and portal.contains("return_arrived"), "arrival signals exist")
	_assert(portal.contains("IrisAudioConsumer") and portal.contains("IrisHapticConsumer"), "portal sensory hooks exist")
	_assert(portal.contains("current_title") and portal.contains("current_subtitle"), "memory identity preview exists")
	_assert(portal.contains("camera_amount") and portal.contains("pupil_amount"), "camera and pupil animation foundation exists")
	_assert(iris.contains("portal_dilation") and iris.contains("lerpf(1.0, 2.48, portal_dilation)"), "LivingIris consumes transient pupil dilation")
	_assert(application.contains("request_memory_portal") and application.contains("_on_portal_entry_arrived"), "existing entry routes pass through portal")
	_assert(application.contains("_begin_portal_return") and application.contains("_on_portal_return_arrived"), "return pathway is composed")
	_assert(application.contains("start_generic_gameplay(moment_id)"), "existing gameplay loader remains intact")
	_assert(not portal.contains("content/witness/") and not portal.contains(".json\""), "portal adds no new content dependency")
	if failures.is_empty():
		print("Iris portal validation passed.")
		quit(0)
	for failure in failures:
		push_error(failure)
	quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

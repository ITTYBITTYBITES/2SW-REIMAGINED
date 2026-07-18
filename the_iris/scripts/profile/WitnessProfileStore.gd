extends RefCounted
class_name WitnessProfileStore

## Small local JSON persistence boundary. No account, network, or social data.
const DEFAULT_PROFILE_PATH := "user://witness_profile.json"

var profile_path := DEFAULT_PROFILE_PATH

func _init(path := DEFAULT_PROFILE_PATH) -> void:
	profile_path = path

func load_profile() -> WitnessProfile:
	if not FileAccess.file_exists(profile_path):
		return WitnessProfile.new()
	var file := FileAccess.open(profile_path, FileAccess.READ)
	if file == null:
		return WitnessProfile.new()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return WitnessProfile.new()
	return WitnessProfile.from_dictionary(parsed as Dictionary)

func save_profile(profile: WitnessProfile) -> bool:
	if profile == null:
		return false
	var file := FileAccess.open(profile_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(profile.to_dictionary()))
	return true

func erase_profile() -> void:
	if FileAccess.file_exists(profile_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(profile_path))

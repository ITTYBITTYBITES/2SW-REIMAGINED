extends RefCounted
## ExperienceBase - Contract for all experiences
## New experiences inherit and implement these methods

class_name ExperienceBase

var id: String = ""
var manifest: Dictionary = {}
var is_active: bool = false

signal started(exp_id: String)
signal completed(exp_id: String, result: Dictionary)
signal failed(exp_id: String, reason: String)

func _init(exp_id: String, manifest_data: Dictionary = {}) -> void:
	id = exp_id
	manifest = manifest_data

func get_title() -> String:
	return manifest.get("title", id.capitalize())

func get_description() -> String:
	return manifest.get("description", "")

func get_preview_color() -> Color:
	var col_str: String = manifest.get("preview_color", "#7C5CFF")
	return Color(col_str)

func start(params: Dictionary = {}) -> Dictionary:
	# Override in child experiences
	# Return session config
	is_active = true
	started.emit(id)
	return {"status": "started", "exp_id": id, "params": params}

func end(result: Dictionary = {}) -> Dictionary:
	is_active = false
	completed.emit(id, result)
	return result

func abort(reason: String = "user_abort") -> void:
	is_active = false
	failed.emit(id, reason)

func get_manifest() -> Dictionary:
	return manifest

# Serialization for save
func get_progress_template() -> Dictionary:
	return {
		"played": 0,
		"best_score": 0,
		"last_played": "",
		"total_score": 0,
		"mastery": 0.0
	}

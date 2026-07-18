extends Node
class_name IncidentRegistry

## The entire playable Witness catalogue. There is one authored incident per
## completed moment.
const MOMENT_PATHS := [
	"res://content/witness/wm_001.json",
	"res://content/witness/wm_002.json",
	"res://content/witness/wm_003.json",
	"res://content/witness/wm_004.json",
	"res://content/witness/wm_005.json",
	"res://content/witness/wm_test.json",
	"res://content/witness/wm_asset_test.json",
	"res://content/witness/fm_001.json",
	"res://content/witness/wm_006.json",
	"res://content/witness/wm_007.json",
	"res://content/witness/wm_008.json"
]

var moments: Array[Dictionary] = []
var by_id: Dictionary = {}
var completed: Dictionary = {}

func load_catalogue() -> void:
	moments.clear()
	by_id.clear()
	for path in MOMENT_PATHS:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_error("Witness content is missing: %s" % path)
			continue
		var parsed = JSON.parse_string(file.get_as_text())
		if not parsed is Dictionary:
			push_error("Witness content is invalid JSON: %s" % path)
			continue
		var moment_data: Dictionary = parsed
		if not _is_valid(moment_data):
			push_error("Witness content is incomplete: %s" % path)
			continue
		moments.append(moment_data)
		by_id[moment_data["id"]] = moment_data

func chapter_moments() -> Array[Dictionary]:
	return moments.duplicate(true)

func moment(id: String) -> Dictionary:
	var found: Dictionary = by_id.get(id, {})
	return found.duplicate(true)

func mark_completed(id: String) -> void:
	if by_id.has(id):
		completed[id] = true

func is_completed(id: String) -> bool:
	return completed.has(id)

func _is_valid(data: Dictionary) -> bool:
	for key in ["id", "incident_id", "title", "introduction", "background", "action", "reveal"]:
		if str(data.get(key, "")).is_empty():
			return false
	return true

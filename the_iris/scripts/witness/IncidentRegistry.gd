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
	"res://content/witness/wm_008.json",
	"res://content/witness/wm_009.json",
	"res://content/witness/wm_010.json",
	"res://content/witness/wm_011.json",
	"res://content/witness/wm_012.json"
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
	print_developer_diagnostics()

func print_developer_diagnostics() -> void:
	print("=====================================================================")
	print("🔍 [IncidentRegistry Developer Diagnostics] Content Discovery Report")
	print("=====================================================================")
	
	var loaded_ids: Array[String] = []
	for m in moments:
		loaded_ids.append(str(m.get("id", "")))
	print("Loaded Witness Moments (%d total):" % loaded_ids.size())
	for id in loaded_ids:
		print("  - %s" % id)
		
	var failed_paths: Array[String] = []
	for path in MOMENT_PATHS:
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			failed_paths.append(path + " (Missing File)")
			continue
		var parsed = JSON.parse_string(file.get_as_text())
		if not parsed is Dictionary:
			failed_paths.append(path + " (Invalid JSON)")
			continue
		if not _is_valid(parsed):
			failed_paths.append(path + " (Incomplete Fields)")
			continue
			
	print("\nFailed/Missing Moments (%d total):" % failed_paths.size())
	if failed_paths.is_empty():
		print("  - None (All files verified and compiled successfully)")
	else:
		for f_path in failed_paths:
			print("  - %s" % f_path)
			
	print("\nVisible in Chapter Selection:")
	for id in loaded_ids:
		if id in ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005", "WM_006", "WM_007", "WM_008", "WM_009", "WM_010", "WM_011", "WM_012"]:
			print("  - %s (Exposed to player)" % id)
		else:
			print("  - %s (Dev / Sandbox only)" % id)
	print("=====================================================================")

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

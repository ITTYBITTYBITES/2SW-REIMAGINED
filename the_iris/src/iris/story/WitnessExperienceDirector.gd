extends Node
class_name WitnessExperienceDirector

# Production Witness Moment Director for Two Second Witness 4.0
# Dynamically loads all Chapter 1 definitions (WM_001 through WM_005) from content JSONs
# without hardcoding individual moments into runtime controllers.

const CONTENT_DIR := "res://src/iris/story/content/"
const CHAPTER_MOMENTS := ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005"]
var moments: Dictionary = {}

func _ready() -> void:
    _load_moments()

func _load_moments() -> void:
    moments.clear()
    var files: Array[String] = [
        "moment_001.json",
        "moment_002.json",
        "moment_003.json",
        "moment_004.json",
        "moment_005.json"
    ]
    for file_name: String in files:
        var path: String = CONTENT_DIR + file_name
        if not FileAccess.file_exists(path):
            continue
        var file: FileAccess = FileAccess.open(path, FileAccess.READ)
        if not file:
            continue
        var parsed: Variant = JSON.parse_string(file.get_as_text())
        if parsed is Dictionary:
            var definition: WitnessMoment = WitnessMoment.from_dictionary(parsed as Dictionary)
            if not definition.moment_id.is_empty():
                moments[definition.moment_id] = definition

func select_moment(moment_id: String = "WM_001") -> WitnessMoment:
    if moments.is_empty():
        _load_moments()
    return moments.get(moment_id) as WitnessMoment

func select_first_moment() -> WitnessMoment:
    return select_moment("WM_001")

# Determines the active Chapter 1 moment based on the observer's completed observations
func get_current_chapter_moment(completed_obs: int) -> WitnessMoment:
    if moments.is_empty():
        _load_moments()
    var idx: int = clampi(completed_obs, 0, CHAPTER_MOMENTS.size() - 1)
    var target_id: String = CHAPTER_MOMENTS[idx]
    if moments.has(target_id):
        return moments[target_id] as WitnessMoment
    return select_first_moment()

# Determines the next moment ID in the chapter sequence
func get_next_moment_id(current_id: String) -> String:
    var idx: int = CHAPTER_MOMENTS.find(current_id)
    if idx >= 0 and idx + 1 < CHAPTER_MOMENTS.size():
        return CHAPTER_MOMENTS[idx + 1]
    return "" # End of chapter

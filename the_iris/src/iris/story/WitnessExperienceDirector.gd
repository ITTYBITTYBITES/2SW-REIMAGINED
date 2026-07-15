extends Node
class_name WitnessExperienceDirector

const MOMENT_PATH := "res://src/iris/story/content/moment_001.json"
var moments: Dictionary = {}

func _ready() -> void:
    _load_moments()

func _load_moments() -> void:
    moments.clear()
    if not FileAccess.file_exists(MOMENT_PATH):
        return
    var file := FileAccess.open(MOMENT_PATH, FileAccess.READ)
    if not file:
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        var definition := WitnessMoment.from_dictionary(parsed as Dictionary)
        moments[definition.moment_id] = definition

func select_moment(moment_id: String = "WM_001") -> WitnessMoment:
    return moments.get(moment_id) as WitnessMoment

func select_first_moment() -> WitnessMoment:
    return select_moment("WM_001")

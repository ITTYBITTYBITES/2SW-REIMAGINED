import re

file_path = "src/iris/story/WitnessExperienceDirector.gd"
with open(file_path, "r") as f:
    content = f.read()

# I will replace the hardcoded CHAPTER_MOMENTS with a dynamically loaded array.
# First, update the constant to an empty array or remove it entirely.
# Let's read the dir in `_load_moments` instead.

new_content = re.sub(
r'''const CHAPTER_MOMENTS := \[
    "WM_001", "WM_002", "WM_003", "WM_004", "WM_005",
    "WM_006", "WM_007", "WM_008", "WM_009", "WM_010"
\]''',
"""var CHAPTER_MOMENTS: Array[String] = []""",
content)

load_moments_replacement = """func _load_moments() -> void:
    moments.clear()
    CHAPTER_MOMENTS.clear()
    
    var dir = DirAccess.open(CONTENT_DIR)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        var moment_ids = []
        while file_name != "":
            if not dir.current_is_dir() and file_name.begins_with("moment_") and file_name.ends_with(".json"):
                var path: String = CONTENT_DIR + file_name
                var file: FileAccess = FileAccess.open(path, FileAccess.READ)
                if file:
                    var parsed: Variant = JSON.parse_string(file.get_as_text())
                    if parsed is Dictionary:
                        var definition: WitnessMoment = WitnessMoment.from_dictionary(parsed as Dictionary)
                        if not definition.moment_id.is_empty():
                            moments[definition.moment_id] = definition
                            moment_ids.append(definition.moment_id)
            file_name = dir.get_next()
        
        # Sort alphanumerically to guarantee sequence WM_001 -> WM_015
        moment_ids.sort()
        for m_id in moment_ids:
            CHAPTER_MOMENTS.append(m_id)"""

new_content = re.sub(
r'''func _load_moments\(\) -> void:
    moments\.clear\(\)
    var files: Array\[String\] = \[
        "moment_001\.json", "moment_002\.json", "moment_003\.json", "moment_004\.json", "moment_005\.json",
        "moment_006\.json", "moment_007\.json", "moment_008\.json", "moment_009\.json", "moment_010\.json"
    \]
    for file_name: String in files:
        var path: String = CONTENT_DIR \+ file_name
        if not FileAccess\.file_exists\(path\):
            continue
        var file: FileAccess = FileAccess\.open\(path, FileAccess\.READ\)
        if not file:
            continue
        var parsed: Variant = JSON\.parse_string\(file\.get_as_text\(\)\)
        if parsed is Dictionary:
            var definition: WitnessMoment = WitnessMoment\.from_dictionary\(parsed as Dictionary\)
            if not definition\.moment_id\.is_empty\(\):
                moments\[definition\.moment_id\] = definition''',
load_moments_replacement,
new_content)

with open(file_path, "w") as f:
    f.write(new_content)

print("Updated WitnessExperienceDirector.gd to dynamically discover moment files.")

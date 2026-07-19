extends RefCounted
class_name LivingArchiveProjection

## Read-only projection over WitnessProfile.moment_records. This is deliberately
## not a save system: WitnessProfile and WitnessArchive remain the authorities.
const CHAPTER_MEMBERS := {
	"chapter_01": ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005"]
}

static func recovered_fragments(profile: WitnessProfile) -> Array[Dictionary]:
	var fragments: Array[Dictionary] = []
	if profile == null:
		return fragments
	for moment_id in profile.moment_records.keys():
		var record_value = profile.moment_records.get(moment_id, {})
		if not record_value is Dictionary:
			continue
		var record: Dictionary = record_value
		if not bool(record.get("truth_fragment_recovered", false)):
			continue
		var fragment_id := str(record.get("truth_fragment_id", ""))
		if fragment_id.is_empty():
			continue
		fragments.append({
			"fragment_id": fragment_id,
			"moment_id": str(moment_id),
			"display_name": _display_name(fragment_id),
			"archive_entry": str(record.get("truth_fragment_archive_entry", "")),
			"revelation": str(record.get("truth_fragment_revelation", "")),
			"absorbed_at": str(record.get("truth_fragment_first_absorbed_at", "")),
			"chapter_id": chapter_for_moment(str(moment_id))
		})
	fragments.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("fragment_id", "")) < str(b.get("fragment_id", "")))
	return fragments

static func chapter_blooms(profile: WitnessProfile) -> Dictionary:
	var recovered := recovered_fragments(profile)
	var recovered_by_moment := {}
	for fragment in recovered:
		recovered_by_moment[str(fragment.get("moment_id", ""))] = fragment
	var blooms := {}
	for chapter_id in CHAPTER_MEMBERS.keys():
		var members: Array = CHAPTER_MEMBERS[chapter_id]
		var recovered_members: Array[String] = []
		for moment_id in members:
			if recovered_by_moment.has(moment_id):
				recovered_members.append(moment_id)
		blooms[chapter_id] = {
			"chapter_id": chapter_id,
			"recovered_moments": recovered_members,
			"recovered_count": recovered_members.size(),
			"total_count": members.size(),
			"bloomed": not recovered_members.is_empty()
		}
	return blooms

static func chapter_for_moment(moment_id: String) -> String:
	for chapter_id in CHAPTER_MEMBERS.keys():
		if moment_id in CHAPTER_MEMBERS[chapter_id]:
			return chapter_id
	return "unassigned"

static func _display_name(fragment_id: String) -> String:
	var cleaned := fragment_id
	if cleaned.begins_with("fragment_"):
		cleaned = cleaned.trim_prefix("fragment_")
	return cleaned.replace("_", " ").capitalize()

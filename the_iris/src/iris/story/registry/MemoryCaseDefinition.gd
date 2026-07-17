extends Resource
class_name MemoryCaseDefinition

## Memory Case data contract for the Incident Registry (MISSION 012).
## Implements the MISSION 008 contract: a replayable or variant memory instance
## used by an Incident. Separate from Incident because one memory may feed
## multiple incidents, replays with altered context, false memories,
## contradictory testimony, and investigation expansion.
##
## This resource is data only. It contains no gameplay logic and owns no
## progression state. Validation is performed by IncidentRegistry.

@export var memory_case_id := ""
@export var source_memory_id := ""
@export var incident_id := ""
@export var case_title := ""
@export_multiline var case_context := ""
@export var reliability_profile := "reliable"
@export var timeline_position := 0
@export var witness_moment_ids: Array[String] = []
@export var observation_profile: Dictionary = {}
@export var reconstruction_profile: Dictionary = {}
@export var reasoning_profile: Dictionary = {}
@export var resolution_profile: Dictionary = {}
@export var variant_rules: Dictionary = {}
@export var asset_refs: Dictionary = {}
@export var archive_refs: Dictionary = {}
@export var version := "1.0"

static func from_dictionary(data: Dictionary, owner_incident_id: String = "") -> MemoryCaseDefinition:
	var memory_case := MemoryCaseDefinition.new()
	memory_case.memory_case_id = str(data.get("memory_case_id", ""))
	memory_case.source_memory_id = str(data.get("source_memory_id", ""))
	var declared_incident := str(data.get("incident_id", ""))
	memory_case.incident_id = declared_incident if not declared_incident.is_empty() else owner_incident_id
	memory_case.case_title = str(data.get("case_title", ""))
	memory_case.case_context = str(data.get("case_context", ""))
	memory_case.reliability_profile = str(data.get("reliability_profile", "reliable"))
	memory_case.timeline_position = int(data.get("timeline_position", 0))
	memory_case.witness_moment_ids = _to_string_array(data.get("witness_moment_ids", []))
	memory_case.observation_profile = _to_dictionary(data.get("observation_profile", {}))
	memory_case.reconstruction_profile = _to_dictionary(data.get("reconstruction_profile", {}))
	memory_case.reasoning_profile = _to_dictionary(data.get("reasoning_profile", {}))
	memory_case.resolution_profile = _to_dictionary(data.get("resolution_profile", {}))
	memory_case.variant_rules = _to_dictionary(data.get("variant_rules", {}))
	memory_case.asset_refs = _to_dictionary(data.get("asset_refs", {}))
	memory_case.archive_refs = _to_dictionary(data.get("archive_refs", {}))
	memory_case.version = str(data.get("version", "1.0"))
	return memory_case

static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in (value as Array):
			var text := str(item).strip_edges()
			if not text.is_empty():
				result.append(text)
	elif value is String and not (value as String).strip_edges().is_empty():
		result.append((value as String).strip_edges())
	return result

static func _to_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}

func primary_moment_id() -> String:
	if witness_moment_ids.is_empty():
		return ""
	return witness_moment_ids[0]

func to_blueprint() -> Dictionary:
	return {
		"memory_case_id": memory_case_id,
		"source_memory_id": source_memory_id,
		"incident_id": incident_id,
		"case_title": case_title,
		"case_context": case_context,
		"reliability_profile": reliability_profile,
		"timeline_position": timeline_position,
		"witness_moment_ids": witness_moment_ids.duplicate(),
		"observation_profile": observation_profile.duplicate(true),
		"reconstruction_profile": reconstruction_profile.duplicate(true),
		"reasoning_profile": reasoning_profile.duplicate(true),
		"resolution_profile": resolution_profile.duplicate(true),
		"variant_rules": variant_rules.duplicate(true),
		"asset_refs": asset_refs.duplicate(true),
		"archive_refs": archive_refs.duplicate(true),
		"version": version
	}

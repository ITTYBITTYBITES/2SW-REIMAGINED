extends Resource
class_name IncidentDefinition

## Incident data contract for the Incident Registry (MISSION 012).
## Implements the MISSION 008 contract: the Incident is the universal content
## unit selected by the Witness Director and consumed by the Witness Runtime.
##
## An Incident represents a playable investigative content package containing
## one or more Memory Cases, mechanics, scoring rules, progression hooks, and
## archive metadata. Incident data must be sufficient for Director selection
## and Runtime launch without custom controller code.
##
## This resource is data only. It contains no gameplay logic, no progression
## branches, and no content-specific runtime code. Validation is performed by
## IncidentRegistry against the registry schema.

const CONTRACT_VERSION := 1

@export var schema_version := CONTRACT_VERSION
@export var incident_id := ""
@export var title := ""
@export var subtitle := ""
@export_multiline var description := ""
@export var authoring_status := "active"
@export var mode_eligibility: Array[String] = []
@export var memory_cases: Array[MemoryCaseDefinition] = []
@export var primary_memory_case_id := ""
@export var chapter_arc_association := ""
@export var narrative_thread_ids: Array[String] = []
@export var difficulty: Dictionary = {}
@export var required_rank := 1
@export var mechanics_used: Array[String] = []
@export var observation_data_ref := ""
@export var reconstruction_data_ref := ""
@export var reasoning_challenge_data_ref := ""
@export var audio_refs: Dictionary = {}
@export var visual_refs: Dictionary = {}
@export var scoring_rules_ref := ""
@export var mastery_tags: Array[String] = []
@export var archive_metadata: Dictionary = {}
@export var iris_evolution_hooks: Array[String] = []
@export var availability_rules: Dictionary = {}
@export var replay_rules: Dictionary = {}
@export var training_slices: Array = []
@export var version := "1.0"
@export var authoring_metadata: Dictionary = {}
@export var validation: Dictionary = {}
@export var selection_priority := 100

static func from_dictionary(data: Dictionary) -> IncidentDefinition:
	var incident := IncidentDefinition.new()
	incident.schema_version = int(data.get("schema_version", CONTRACT_VERSION))
	incident.incident_id = str(data.get("incident_id", ""))
	incident.title = str(data.get("title", ""))
	incident.subtitle = str(data.get("subtitle", data.get("codename", "")))
	incident.description = str(data.get("description", ""))
	incident.authoring_status = str(data.get("status", data.get("authoring_status", "active")))
	incident.mode_eligibility = MemoryCaseDefinition._to_string_array(data.get("mode_eligibility", []))
	incident.primary_memory_case_id = str(data.get("primary_memory_case_id", ""))
	incident.chapter_arc_association = str(data.get("chapter_arc_association", ""))
	incident.narrative_thread_ids = MemoryCaseDefinition._to_string_array(data.get("narrative_thread_ids", []))
	incident.difficulty = MemoryCaseDefinition._to_dictionary(data.get("difficulty", {}))
	incident.required_rank = maxi(int(data.get("required_rank", 1)), 1)
	incident.mechanics_used = MemoryCaseDefinition._to_string_array(data.get("mechanics_used", []))
	incident.observation_data_ref = str(data.get("observation_data_ref", ""))
	incident.reconstruction_data_ref = str(data.get("reconstruction_data_ref", ""))
	incident.reasoning_challenge_data_ref = str(data.get("reasoning_challenge_data_ref", ""))
	incident.audio_refs = MemoryCaseDefinition._to_dictionary(data.get("audio_refs", {}))
	incident.visual_refs = MemoryCaseDefinition._to_dictionary(data.get("visual_refs", {}))
	incident.scoring_rules_ref = str(data.get("scoring_rules_ref", ""))
	incident.mastery_tags = MemoryCaseDefinition._to_string_array(data.get("mastery_tags", []))
	incident.archive_metadata = MemoryCaseDefinition._to_dictionary(data.get("archive_metadata", {}))
	incident.iris_evolution_hooks = MemoryCaseDefinition._to_string_array(data.get("iris_evolution_hooks", []))
	incident.availability_rules = MemoryCaseDefinition._to_dictionary(data.get("availability_rules", {}))
	incident.replay_rules = MemoryCaseDefinition._to_dictionary(data.get("replay_rules", {}))
	if data.get("training_slices", []) is Array:
		incident.training_slices = (data.get("training_slices", []) as Array).duplicate(true)
	incident.version = str(data.get("version", "1.0"))
	incident.authoring_metadata = MemoryCaseDefinition._to_dictionary(data.get("authoring_metadata", {}))
	incident.validation = MemoryCaseDefinition._to_dictionary(data.get("validation", {}))
	incident.selection_priority = int(data.get("selection_priority", 100))
	incident.memory_cases = _parse_memory_cases(data.get("memory_cases", []), incident.incident_id)
	return incident

static func _parse_memory_cases(value: Variant, owner_incident_id: String) -> Array[MemoryCaseDefinition]:
	var cases: Array[MemoryCaseDefinition] = []
	if not (value is Array):
		return cases
	for entry: Variant in (value as Array):
		if entry is Dictionary:
			var memory_case := MemoryCaseDefinition.from_dictionary(entry as Dictionary, owner_incident_id)
			cases.append(memory_case)
	return cases

func memory_case_ids() -> Array[String]:
	var ids: Array[String] = []
	for memory_case: MemoryCaseDefinition in memory_cases:
		ids.append(memory_case.memory_case_id)
	return ids

func primary_memory_case() -> MemoryCaseDefinition:
	if not primary_memory_case_id.is_empty():
		for memory_case: MemoryCaseDefinition in memory_cases:
			if memory_case.memory_case_id == primary_memory_case_id:
				return memory_case
	if not memory_cases.is_empty():
		return memory_cases[0]
	return null

func get_memory_case(memory_case_id: String) -> MemoryCaseDefinition:
	for memory_case: MemoryCaseDefinition in memory_cases:
		if memory_case.memory_case_id == memory_case_id:
			return memory_case
	return null

func witness_moment_ids() -> Array[String]:
	var ids: Array[String] = []
	for memory_case: MemoryCaseDefinition in memory_cases:
		for moment_id: String in memory_case.witness_moment_ids:
			if not ids.has(moment_id):
				ids.append(moment_id)
	return ids

func get_baseline_difficulty() -> int:
	return int(difficulty.get("baseline", required_rank))

func allows_replay() -> bool:
	return bool(replay_rules.get("allow_replay", true))

func is_in_active_service() -> bool:
	return authoring_status == "active"

func to_blueprint() -> Dictionary:
	var cases: Array = []
	for memory_case: MemoryCaseDefinition in memory_cases:
		cases.append(memory_case.to_blueprint())
	return {
		"schema_version": schema_version,
		"incident_id": incident_id,
		"title": title,
		"subtitle": subtitle,
		"description": description,
		"status": authoring_status,
		"mode_eligibility": mode_eligibility.duplicate(),
		"memory_case_ids": memory_case_ids(),
		"primary_memory_case_id": primary_memory_case_id,
		"memory_cases": cases,
		"chapter_arc_association": chapter_arc_association,
		"narrative_thread_ids": narrative_thread_ids.duplicate(),
		"difficulty": difficulty.duplicate(true),
		"required_rank": required_rank,
		"mechanics_used": mechanics_used.duplicate(),
		"observation_data_ref": observation_data_ref,
		"reconstruction_data_ref": reconstruction_data_ref,
		"reasoning_challenge_data_ref": reasoning_challenge_data_ref,
		"audio_refs": audio_refs.duplicate(true),
		"visual_refs": visual_refs.duplicate(true),
		"scoring_rules_ref": scoring_rules_ref,
		"mastery_tags": mastery_tags.duplicate(),
		"archive_metadata": archive_metadata.duplicate(true),
		"iris_evolution_hooks": iris_evolution_hooks.duplicate(),
		"availability_rules": availability_rules.duplicate(true),
		"replay_rules": replay_rules.duplicate(true),
		"training_slices": training_slices.duplicate(true),
		"version": version,
		"authoring_metadata": authoring_metadata.duplicate(true),
		"validation": validation.duplicate(true),
		"selection_priority": selection_priority
	}

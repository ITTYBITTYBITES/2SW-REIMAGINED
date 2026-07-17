extends Node
class_name WitnessExperienceDirector

# Production Witness Moment Director for Two Second Witness 4.0
# Dynamically loads all definitions from content JSONs
# without hardcoding individual moments into runtime controllers.

const CONTENT_DIR := "res://src/iris/story/content/"
const CHAPTER_MOMENTS := [
    "WM_001", "WM_002", "WM_003", "WM_004", "WM_005",
    "WM_006", "WM_007", "WM_008", "WM_009", "WM_010"
]
var moments: Dictionary = {}

func _ready() -> void:
    _load_moments()

func _load_moments() -> void:
    moments.clear()
    var files: Array[String] = [
        "moment_001.json", "moment_002.json", "moment_003.json", "moment_004.json", "moment_005.json",
        "moment_006.json", "moment_007.json", "moment_008.json", "moment_009.json", "moment_010.json"
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

## Director selection entry point (MISSION 008 contract target).
## The Director is the mode/context-facing authority; incident availability,
## lifecycle, and eligibility are owned by the Incident Registry. The Director
## queries the registry, resolves the selected memory case to an authored
## Witness Moment, and returns the runtime launch contract consumed by
## WitnessMomentOrchestrator.start_incident().
func get_next_incident(context: Dictionary = {}) -> Dictionary:
    if moments.is_empty():
        _load_moments()
    var registry := _incident_registry()
    if registry != null:
        return _select_incident_via_registry(registry, context)
    # Registry singleton unavailable: only possible outside the configured
    # autoload graph (isolated tooling/tests). Legacy adapter remains so the
    # runtime never hard-fails when the registry cannot exist at all.
    return _select_incident_legacy(context)

func _incident_registry() -> Node:
    return get_node_or_null("/root/IncidentRegistry")

func _select_incident_via_registry(registry: Node, context: Dictionary) -> Dictionary:
    if not registry.is_ready():
        push_error("WitnessExperienceDirector: Incident Registry is not ready")
        return {}
    var query := context.duplicate(true)
    if str(query.get("mode", "")).is_empty():
        query["mode"] = "story"
    var provided: Variant = query.get("player_progress_snapshot", {})
    if (not (provided is Dictionary) or (provided as Dictionary).is_empty()) and get_node_or_null("/root/PlayerProgressService") != null:
        query["player_progress_snapshot"] = PlayerProgressService.get_player_state()
    var picked: Dictionary = registry.select_incident(query)
    if picked.is_empty():
        # RED path: no eligible incident. Surface emptiness; never bypass the
        # registry with hardcoded content.
        return {}
    var incident: IncidentDefinition = picked.get("incident")
    var memory_case: MemoryCaseDefinition = picked.get("memory_case")
    if incident == null or memory_case == null:
        push_error("WitnessExperienceDirector: registry selection missing incident/memory case")
        return {}
    var moment_id := memory_case.primary_moment_id()
    var selected: WitnessMoment = select_moment(moment_id)
    if selected == null:
        push_error("WitnessExperienceDirector: authored witness moment unresolved: %s" % moment_id)
        return {}
    var mode := str(query.get("mode", "story"))
    var reason := str(picked.get("reason", "registry_selection"))
    var difficulty := int(picked.get("difficulty", incident.get_baseline_difficulty()))
    var registry_version := str(picked.get("registry_version", registry.get_registry_version()))
    return {
        "selected_incident": incident.to_blueprint(),
        "selected_memory_case": memory_case.to_blueprint(),
        "moment_id": selected.moment_id,
        "incident_id": incident.incident_id,
        "memory_case_id": memory_case.memory_case_id,
        "reason": reason,
        "mode": mode,
        "difficulty": difficulty,
        "expected_skill": selected.observation_mechanic,
        "registry_version": registry_version,
        "selection_source": "incident_registry",
        "runtime_context": {
            "mode": mode,
            "incident_id": incident.incident_id,
            "memory_case_id": memory_case.memory_case_id,
            "moment_id": selected.moment_id,
            "selection_reason": reason,
            "selection_source": "incident_registry",
            "registry_version": registry_version,
            "schema_version": incident.schema_version,
            "content_version": incident.version,
            "required_rank": incident.required_rank
        }
    }

# Legacy selection adapter used only when the Incident Registry singleton does
# not exist (pre-registry tooling context). Wraps current authored moments with
# incident-like identifiers; identical to the MISSION 009 behavior.
func _select_incident_legacy(context: Dictionary = {}) -> Dictionary:
    var mode := str(context.get("mode", "story"))
    var player_state: Dictionary = context.get("player_progress_snapshot", {})
    if player_state.is_empty() and get_node_or_null("/root/PlayerProgressService") != null:
        player_state = PlayerProgressService.get_player_state()
    var witness: Dictionary = player_state.get("witness_progress", {})
    var completed_ids_value: Variant = witness.get("completed_moment_ids", [])
    var completed_ids: Array = completed_ids_value if completed_ids_value is Array else []
    var selected_id := ""
    for candidate_id: String in CHAPTER_MOMENTS:
        if not completed_ids.has(candidate_id):
            selected_id = candidate_id
            break
    if selected_id.is_empty():
        selected_id = CHAPTER_MOMENTS[0] if not CHAPTER_MOMENTS.is_empty() else ""
    var selected: WitnessMoment = select_moment(selected_id)
    if selected == null:
        return {}
    var incident_id := "incident_%s" % selected.moment_id.to_lower()
    var memory_case_id := "memory_%s" % selected.moment_id.to_lower()
    var reason := "next_uncompleted_moment"
    if completed_ids.has(selected_id):
        reason = "replay_cycle"
    return {
        "selected_incident": selected.to_blueprint(),
        "selected_memory_case": {
            "memory_case_id": memory_case_id,
            "moment_id": selected.moment_id,
            "source_memory_id": selected.moment_id.to_lower()
        },
        "moment_id": selected.moment_id,
        "incident_id": incident_id,
        "memory_case_id": memory_case_id,
        "reason": reason,
        "mode": mode,
        "difficulty": selected.rank_requirement,
        "expected_skill": selected.observation_mechanic,
        "selection_source": "legacy_adapter",
        "runtime_context": {
            "mode": mode,
            "incident_id": incident_id,
            "memory_case_id": memory_case_id,
            "moment_id": selected.moment_id,
            "selection_reason": reason,
            "selection_source": "legacy_adapter"
        }
    }

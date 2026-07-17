extends Node
## IncidentRegistry (autoload singleton) — permanent content authority for
## Two Second Witness.
##
## Project convention: autoload singletons do not declare class_name; the
## singleton name itself is the global identifier.
## MISSION 012 runtime implementation of the MISSION 008 contract.
##
## Responsibilities:
## - Load Incident + Memory Case definitions from data (registry manifest).
## - Validate definitions against the incident schema contract.
## - Track Incident lifecycle states.
## - Answer availability/selection queries from WitnessExperienceDirector.
##
## Boundaries (held by contract):
## - The Registry is data-driven. It contains no hardcoded incident logic,
##   no content-specific runtime code, and no progression branches.
## - PlayerProgressService owns completed history and progression outcomes.
##   The Registry derives COMPLETED/ARCHIVED states from that authority and
##   never writes progression.
## - The Registry does not touch Iris presentation, rendering, or export
##   configuration.

signal registry_ready(registered_count: int, valid_count: int, invalid_count: int)
signal registry_load_failed(reason: String)
signal incident_selected(incident_id: String, memory_case_id: String, moment_id: String, reason: String)
signal incident_state_changed(incident_id: String, previous_state: int, new_state: int, reason: String)

## Incident lifecycle states.
## REGISTERED/VALIDATED describe data authority. AVAILABLE is a contextual
## evaluation result. SELECTED/ACTIVE/FAILED are transient runtime states.
## COMPLETED/ARCHIVED are derived from PlayerProgressService history.
enum Lifecycle {
	INVALID,
	REGISTERED,
	VALIDATED,
	AVAILABLE,
	SELECTED,
	ACTIVE,
	FAILED,
	COMPLETED,
	ARCHIVED
}

const MANIFEST_PATH := "res://src/iris/story/incidents/registry_manifest.json"
const SUPPORTED_SCHEMA_VERSION := 1
const STALE_TRANSIENT_TIMEOUT_MSEC := 10 * 60 * 1000
const VALID_MODES: Array[String] = ["story", "daily", "challenge", "training", "archive_replay"]

## Read-only projection of the PlayerProgressService rank ladder
## (Observer=1 .. Master Witness=5). Used only to evaluate the
## `required_rank` contract field. Ownership of rank stays with
## PlayerProgressService; this list is never written back.
const RANK_ORDER: Array[String] = [
	"Observer",
	"Noticer",
	"Attentive Witness",
	"Sharp Witness",
	"Master Witness"
]

var _definitions: Dictionary = {}
var _load_order: Array[String] = []
var _validation_issues: Dictionary = {}
var _invalid_ids: Dictionary = {}
var _transient_states: Dictionary = {}
var _session_completed_incident_ids: Array[String] = []
var _memory_case_index: Dictionary = {}
var _selected_incident_id := ""
var _active_incident_id := ""
var _registry_version := "0.0"
var _manifest_loaded := false
var _ready_emitted := false

func _ready() -> void:
	reload()

## (Re)loads the registry from the data manifest. Data-driven: incidents are
## added by authoring data files listed in the manifest, never by code.
func reload() -> void:
	_definitions.clear()
	_load_order.clear()
	_validation_issues.clear()
	_invalid_ids.clear()
	_transient_states.clear()
	_memory_case_index.clear()
	_selected_incident_id = ""
	_active_incident_id = ""
	_manifest_loaded = false
	_ready_emitted = false

	var manifest := _read_json_dictionary(MANIFEST_PATH)
	if manifest.is_empty():
		var reason := "Incident Registry manifest missing or unreadable: %s" % MANIFEST_PATH
		push_error(reason)
		registry_load_failed.emit(reason)
		return

	_registry_version = str(manifest.get("manifest_version", "0.0"))
	var schema_version := int(manifest.get("registry_schema_version", SUPPORTED_SCHEMA_VERSION))
	if schema_version != SUPPORTED_SCHEMA_VERSION:
		var reason := "Unsupported registry schema version: %d (supported: %d)" % [schema_version, SUPPORTED_SCHEMA_VERSION]
		push_error(reason)
		registry_load_failed.emit(reason)
		return

	var incident_files: Array = manifest.get("incidents", [])
	for entry: Variant in incident_files:
		_register_incident_file(str(entry))

	_manifest_loaded = true
	var valid_count := 0
	for incident_id: String in _load_order:
		if not _invalid_ids.has(incident_id):
			valid_count += 1
	print("IncidentRegistry ready: %d registered, %d valid, %d invalid (manifest v%s)" % [_load_order.size(), valid_count, _invalid_ids.size(), _registry_version])
	_ready_emitted = true
	registry_ready.emit(_load_order.size(), valid_count, _invalid_ids.size())

func is_ready() -> bool:
	return _manifest_loaded

func get_registry_version() -> String:
	return _registry_version

func get_incident_count() -> int:
	return _load_order.size()

func get_registered_incident_ids() -> Array[String]:
	return _load_order.duplicate()

func has_incident(incident_id: String) -> bool:
	return _definitions.has(incident_id)

func get_incident(incident_id: String) -> IncidentDefinition:
	return _definitions.get(incident_id) as IncidentDefinition

func is_valid(incident_id: String) -> bool:
	return has_incident(incident_id) and not _invalid_ids.has(incident_id)

func get_validation_issues(incident_id: String) -> Array:
	return (_validation_issues.get(incident_id, []) as Array).duplicate()

func get_invalid_incident_ids() -> Array[String]:
	var ids: Array[String] = []
	for key: Variant in _invalid_ids.keys():
		ids.append(str(key))
	return ids

## Returns every validated incident currently eligible for the given context.
func get_available_incidents(context: Dictionary = {}) -> Array[IncidentDefinition]:
	var available: Array[IncidentDefinition] = []
	var resolved := _resolve_context(context)
	for incident_id: String in _load_order:
		if _invalid_ids.has(incident_id):
			continue
		var definition: IncidentDefinition = _definitions[incident_id]
		var evaluation := evaluate_availability(definition, resolved)
		if evaluation.get("eligible", false):
			available.append(definition)
	return available

## Evaluates one incident against a resolved selection context.
## All rules come from incident data; no content-specific branches exist here.
func evaluate_availability(definition: IncidentDefinition, resolved: Dictionary) -> Dictionary:
	var reasons: Array[String] = []
	if not definition.is_in_active_service():
		reasons.append("authoring_status:%s" % definition.authoring_status)
	if _invalid_ids.has(definition.incident_id):
		reasons.append("invalid_contract")
	var mode := str(resolved.get("mode", "story"))
	if not definition.mode_eligibility.has(mode):
		reasons.append("mode_not_eligible:%s" % mode)
	var excluded: Array = resolved.get("excluded_incident_ids", [])
	if excluded.has(definition.incident_id):
		reasons.append("excluded_by_context")
	var completion: Dictionary = resolved.get("completion", {})
	var completed := _is_completed(definition, completion)
	if completed and not definition.allows_replay():
		reasons.append("completed_replay_disabled")
	var player_rank := int(resolved.get("player_rank_index", 1))
	if definition.required_rank > player_rank:
		reasons.append("required_rank_not_met:%d>%d" % [definition.required_rank, player_rank])
	var rules := definition.availability_rules
	var completed_ids: Array = completion.get("incident_ids", [])
	var required_completed := MemoryCaseDefinition._to_string_array(rules.get("requires_completed_incident_ids", []))
	for required_id: String in required_completed:
		if not completed_ids.has(required_id) and not _session_completed_incident_ids.has(required_id):
			reasons.append("prerequisite_incident_incomplete:%s" % required_id)
	var min_completed := int(rules.get("min_completed_incidents", 0))
	if min_completed > 0 and completed_ids.size() < min_completed:
		reasons.append("insufficient_completed_incidents:%d<%d" % [completed_ids.size(), min_completed])
	var today := Time.get_date_string_from_system()
	var enabled_from := str(rules.get("enabled_from_date", ""))
	if not enabled_from.is_empty() and today < enabled_from:
		reasons.append("not_yet_enabled:%s" % enabled_from)
	var enabled_until := str(rules.get("enabled_until_date", ""))
	if not enabled_until.is_empty() and today > enabled_until:
		reasons.append("expired:%s" % enabled_until)
	return {
		"eligible": reasons.is_empty(),
		"reasons": reasons,
		"completed": completed
	}

## Director-facing selection. Picks one eligible incident deterministically,
## marks it SELECTED, and returns the definition plus selection metadata.
## Returns {} when nothing is eligible; callers must surface that instead of
## falling back to hardcoded content.
func select_incident(context: Dictionary = {}) -> Dictionary:
	if not _manifest_loaded:
		reload()
	if not _manifest_loaded:
		return {}
	var resolved := _resolve_context(context)
	var candidates: Array[Dictionary] = []
	for incident_id: String in _load_order:
		if _invalid_ids.has(incident_id):
			continue
		var definition: IncidentDefinition = _definitions[incident_id]
		var evaluation := evaluate_availability(definition, resolved)
		if not evaluation.get("eligible", false):
			continue
		candidates.append({
			"definition": definition,
			"completed": bool(evaluation.get("completed", false))
		})
	if candidates.is_empty():
		return {}

	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.get("completed") != b.get("completed"):
			return not bool(a.get("completed"))
		var pa := (a.get("definition") as IncidentDefinition).selection_priority
		var pb := (b.get("definition") as IncidentDefinition).selection_priority
		if pa != pb:
			return pa < pb
		return (a.get("definition") as IncidentDefinition).incident_id < (b.get("definition") as IncidentDefinition).incident_id
	)

	var chosen: Dictionary = candidates[0]
	var definition: IncidentDefinition = chosen["definition"]
	var memory_case := definition.primary_memory_case()
	if memory_case == null:
		return {}
	var was_completed: bool = chosen["completed"]
	var reason := "replay_cycle_by_priority" if was_completed else "first_uncompleted_by_priority"
	if candidates.size() == 1:
		reason += ";only_eligible_candidate"

	notify_incident_selected(definition.incident_id)
	return {
		"incident": definition,
		"memory_case": memory_case,
		"reason": reason,
		"mode": resolved.get("mode", "story"),
		"difficulty": definition.get_baseline_difficulty(),
		"candidates_evaluated": _load_order.size(),
		"eligible_count": candidates.size(),
		"registry_version": _registry_version
	}

## Marks an incident SELECTED (chosen by Director, not yet running).
func notify_incident_selected(incident_id: String) -> void:
	if not has_incident(incident_id):
		return
	_recover_other_transients(incident_id)
	_selected_incident_id = incident_id
	var definition := get_incident(incident_id)
	var memory_case := definition.primary_memory_case() if definition else null
	_set_transient(incident_id, Lifecycle.SELECTED, "director_selection")
	incident_selected.emit(incident_id, memory_case.memory_case_id if memory_case else "", memory_case.primary_moment_id() if memory_case else "", "director_selection")

## Promotes the currently selected incident to ACTIVE (runtime handed off and
## entered). Called from the runtime wiring when the Witness surface opens.
func notify_incident_active(incident_id: String = "") -> void:
	var target := incident_id if not incident_id.is_empty() else _selected_incident_id
	if target.is_empty() or not has_incident(target):
		return
	_active_incident_id = target
	_set_transient(target, Lifecycle.ACTIVE, "runtime_started")

## Records a completed runtime result. Completion history authority remains
## PlayerProgressService; the Registry mirrors the completed lifecycle state
## for selection purposes only.
func notify_incident_completed(result: Dictionary) -> void:
	var target := str(result.get("incident_id", ""))
	if target.is_empty():
		target = _active_incident_id if not _active_incident_id.is_empty() else _selected_incident_id
	if target.is_empty() or not has_incident(target):
		return
	if not _session_completed_incident_ids.has(target):
		_session_completed_incident_ids.append(target)
	_set_transient(target, Lifecycle.COMPLETED, "runtime_result_recorded")
	_active_incident_id = ""
	_selected_incident_id = ""

## Marks the active/selected incident FAILED. Failure never permanently locks
## content: FAILED decays back to availability after the stale timeout.
func notify_incident_failed(reason: String) -> void:
	var target := _active_incident_id if not _active_incident_id.is_empty() else _selected_incident_id
	if target.is_empty() or not has_incident(target):
		return
	_set_transient(target, Lifecycle.FAILED, reason)
	_active_incident_id = ""

## Returns the active/selected incident to availability (player left early).
func notify_incident_abandoned() -> void:
	var target := _active_incident_id if not _active_incident_id.is_empty() else _selected_incident_id
	if target.is_empty() or not has_incident(target):
		return
	_clear_transient(target, "abandoned_by_player")
	_active_incident_id = ""
	_selected_incident_id = ""

## Resolves the current lifecycle state of one incident. Precedence:
## INVALID > fresh transient (SELECTED/ACTIVE/FAILED) > derived completion
## (COMPLETED/ARCHIVED) > VALIDATED/REGISTERED.
func get_lifecycle_state(incident_id: String, context: Dictionary = {}) -> int:
	if not has_incident(incident_id):
		return Lifecycle.INVALID
	if _invalid_ids.has(incident_id):
		return Lifecycle.INVALID
	_recover_stale_transients()
	if _transient_states.has(incident_id):
		var transient: Dictionary = _transient_states[incident_id]
		var state := int(transient.get("state", Lifecycle.REGISTERED))
		if state == Lifecycle.COMPLETED:
			return Lifecycle.ARCHIVED if _is_archived(get_incident(incident_id), _resolve_context(context).get("completion", {})) else Lifecycle.COMPLETED
		return state
	var definition := get_incident(incident_id)
	if not definition.is_in_active_service():
		return Lifecycle.REGISTERED
	var resolved := _resolve_context(context)
	var completion: Dictionary = resolved.get("completion", {})
	if _is_completed(definition, completion):
		return Lifecycle.ARCHIVED if _is_archived(definition, completion) else Lifecycle.COMPLETED
	return Lifecycle.VALIDATED

static func lifecycle_state_name(state: int) -> String:
	match state:
		Lifecycle.INVALID: return "INVALID"
		Lifecycle.REGISTERED: return "REGISTERED"
		Lifecycle.VALIDATED: return "VALIDATED"
		Lifecycle.AVAILABLE: return "AVAILABLE"
		Lifecycle.SELECTED: return "SELECTED"
		Lifecycle.ACTIVE: return "ACTIVE"
		Lifecycle.FAILED: return "FAILED"
		Lifecycle.COMPLETED: return "COMPLETED"
		Lifecycle.ARCHIVED: return "ARCHIVED"
	return "UNKNOWN"

## Registry snapshot for diagnostics, audit reports, and command-center reads.
func get_registry_snapshot(context: Dictionary = {}) -> Dictionary:
	_recover_stale_transients()
	var resolved := _resolve_context(context)
	var states := {}
	for incident_id: String in _load_order:
		var definition: IncidentDefinition = _definitions[incident_id]
		var evaluation := evaluate_availability(definition, resolved) if not _invalid_ids.has(incident_id) else {"eligible": false, "reasons": ["invalid_contract"]}
		states[incident_id] = {
			"lifecycle": lifecycle_state_name(get_lifecycle_state(incident_id, resolved)),
			"eligible": bool(evaluation.get("eligible", false)),
			"eligibility_reasons": evaluation.get("reasons", []),
			"validation_issues": get_validation_issues(incident_id)
		}
	return {
		"registry_version": _registry_version,
		"manifest_path": MANIFEST_PATH,
		"manifest_loaded": _manifest_loaded,
		"schema_version": SUPPORTED_SCHEMA_VERSION,
		"registered_count": _load_order.size(),
		"invalid_count": _invalid_ids.size(),
		"session_completed_incident_ids": _session_completed_incident_ids.duplicate(),
		"selected_incident_id": _selected_incident_id,
		"active_incident_id": _active_incident_id,
		"incidents": states
	}

# --- Internal loading and validation ----------------------------------------

func _register_incident_file(path: String) -> void:
	if path.is_empty():
		return
	var data := _read_json_dictionary(path)
	if data.is_empty():
		push_error("Incident definition unreadable: %s" % path)
		return
	var definition := IncidentDefinition.from_dictionary(data)
	var incident_id := definition.incident_id
	if incident_id.is_empty():
		incident_id = "__unregistered_%s" % path.get_file().get_basename()
	var issues := _validate_incident(definition, path)
	_validation_issues[incident_id] = issues
	if _definitions.has(incident_id) and not issues.has("duplicate_incident_id"):
		issues.append("duplicate_incident_id")
		_validation_issues[incident_id] = issues
	if not _definitions.has(incident_id):
		_definitions[incident_id] = definition
		_load_order.append(incident_id)
	if not issues.is_empty():
		_invalid_ids[incident_id] = true
		push_warning("Incident %s failed validation: %s" % [incident_id, ", ".join(issues)])
	else:
		for memory_case: MemoryCaseDefinition in definition.memory_cases:
			_memory_case_index[memory_case.memory_case_id] = memory_case

func _validate_incident(definition: IncidentDefinition, _source_path: String) -> Array[String]:
	var issues: Array[String] = []
	if definition.schema_version != SUPPORTED_SCHEMA_VERSION:
		issues.append("unsupported_schema_version:%d" % definition.schema_version)
	if definition.incident_id.is_empty():
		issues.append("missing_incident_id")
	if definition.title.is_empty():
		issues.append("missing_title")
	if definition.mode_eligibility.is_empty():
		issues.append("missing_mode_eligibility")
	else:
		for mode: String in definition.mode_eligibility:
			if not VALID_MODES.has(mode):
				issues.append("unsupported_mode:%s" % mode)
	if definition.memory_cases.is_empty():
		issues.append("missing_memory_cases")
	if definition.mechanics_used.is_empty():
		issues.append("missing_mechanics_used")
	if definition.version.is_empty():
		issues.append("missing_version")
	if not definition.primary_memory_case_id.is_empty() and not definition.memory_case_ids().has(definition.primary_memory_case_id):
		issues.append("invalid_primary_memory_case_id:%s" % definition.primary_memory_case_id)
	for memory_case: MemoryCaseDefinition in definition.memory_cases:
		if memory_case.memory_case_id.is_empty():
			issues.append("missing_memory_case_id")
		elif _memory_case_index.has(memory_case.memory_case_id):
			issues.append("duplicate_memory_case_id:%s" % memory_case.memory_case_id)
		if memory_case.witness_moment_ids.is_empty():
			issues.append("missing_witness_moment_ids:%s" % memory_case.memory_case_id)
		if not memory_case.incident_id.is_empty() and memory_case.incident_id != definition.incident_id:
			issues.append("memory_case_owner_mismatch:%s" % memory_case.memory_case_id)
	var metadata := definition.authoring_metadata
	var requires_source := bool(definition.validation.get("requires_source_content", false))
	var source_content := str(metadata.get("source_content", ""))
	if requires_source:
		if source_content.is_empty():
			issues.append("missing_source_content_ref")
		elif not FileAccess.file_exists(source_content):
			issues.append("missing_source_content:%s" % source_content)
	return issues

# --- Internal lifecycle helpers ---------------------------------------------

func _set_transient(incident_id: String, state: int, reason: String) -> void:
	var previous := get_lifecycle_state(incident_id)
	_transient_states[incident_id] = {
		"state": state,
		"at_msec": Time.get_ticks_msec(),
		"reason": reason
	}
	var current := state
	if state == Lifecycle.COMPLETED:
		var resolved := _resolve_context({})
		current = Lifecycle.ARCHIVED if _is_archived(get_incident(incident_id), resolved.get("completion", {})) else Lifecycle.COMPLETED
	if previous != current:
		incident_state_changed.emit(incident_id, previous, current, reason)

func _clear_transient(incident_id: String, reason: String) -> void:
	if not _transient_states.has(incident_id):
		return
	var previous := int(_transient_states[incident_id].get("state", Lifecycle.REGISTERED))
	_transient_states.erase(incident_id)
	var current := get_lifecycle_state(incident_id)
	if previous != current:
		incident_state_changed.emit(incident_id, previous, current, reason)

func _recover_stale_transients() -> void:
	var now := Time.get_ticks_msec()
	var stale: Array[String] = []
	for incident_id: Variant in _transient_states.keys():
		var transient: Dictionary = _transient_states[incident_id]
		var state := int(transient.get("state", Lifecycle.REGISTERED))
		if state == Lifecycle.COMPLETED:
			continue
		if now - int(transient.get("at_msec", 0)) > STALE_TRANSIENT_TIMEOUT_MSEC:
			stale.append(str(incident_id))
	for incident_id: String in stale:
		_clear_transient(incident_id, "stale_transient_recovered")
		if _active_incident_id == incident_id:
			_active_incident_id = ""
		if _selected_incident_id == incident_id:
			_selected_incident_id = ""

func _recover_other_transients(keep_incident_id: String) -> void:
	var recover: Array[String] = []
	for incident_id: Variant in _transient_states.keys():
		if str(incident_id) == keep_incident_id:
			continue
		var state := int(_transient_states[incident_id].get("state", Lifecycle.REGISTERED))
		if state in [Lifecycle.SELECTED, Lifecycle.ACTIVE, Lifecycle.FAILED]:
			recover.append(str(incident_id))
	for incident_id: String in recover:
		_clear_transient(incident_id, "superseded_by_new_selection")

# --- Internal context / completion helpers -----------------------------------

func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed as Dictionary
	return {}

func _resolve_context(context: Dictionary) -> Dictionary:
	var resolved := context.duplicate(true)
	if not resolved.has("mode") or str(resolved.get("mode", "")).is_empty():
		resolved["mode"] = "story"
	if not (resolved.get("excluded_incident_ids") is Array):
		resolved["excluded_incident_ids"] = []
	var snapshot: Dictionary = {}
	var provided: Variant = resolved.get("player_progress_snapshot", {})
	if provided is Dictionary and not (provided as Dictionary).is_empty():
		snapshot = (provided as Dictionary).duplicate(true)
	elif get_node_or_null("/root/PlayerProgressService") != null:
		snapshot = PlayerProgressService.get_player_state()
	resolved["player_progress_snapshot"] = snapshot
	resolved["player_rank_index"] = _resolve_player_rank_index(snapshot)
	resolved["completion"] = _collect_completion_state(snapshot)
	return resolved

func _resolve_player_rank_index(snapshot: Dictionary) -> int:
	var witness: Dictionary = snapshot.get("witness_progress", {})
	var rank_name := str(witness.get("witness_rank", "Observer"))
	var idx := RANK_ORDER.find(rank_name)
	if idx >= 0:
		return idx + 1
	# Unknown future rank names resolve conservatively by progression level.
	return maxi(int(witness.get("witness_level", 1)), 1)

func _collect_completion_state(snapshot: Dictionary) -> Dictionary:
	var witness: Dictionary = snapshot.get("witness_progress", {})
	var incident_ids: Array = []
	var moment_ids: Array = []
	var archive_moment_ids: Array = []
	var raw_incidents: Variant = witness.get("completed_incident_ids", [])
	if raw_incidents is Array:
		incident_ids = (raw_incidents as Array).duplicate()
	var raw_moments: Variant = witness.get("completed_moment_ids", [])
	if raw_moments is Array:
		moment_ids = (raw_moments as Array).duplicate()
	var raw_archive: Variant = witness.get("archive_entries", [])
	if raw_archive is Array:
		for entry: Variant in (raw_archive as Array):
			if entry is Dictionary:
				var entry_id := str((entry as Dictionary).get("id", ""))
				if not entry_id.is_empty():
					archive_moment_ids.append(entry_id)
	return {
		"incident_ids": incident_ids,
		"moment_ids": moment_ids,
		"archive_moment_ids": archive_moment_ids
	}

## Backward-compatible completion check: an incident counts as completed when
## its incident ID is in authority history OR when any of its witness moments
## was completed (covers pre-registry profiles that only recorded moment IDs).
func _is_completed(definition: IncidentDefinition, completion: Dictionary) -> bool:
	if _session_completed_incident_ids.has(definition.incident_id):
		return true
	var incident_ids: Array = completion.get("incident_ids", [])
	if incident_ids.has(definition.incident_id):
		return true
	var moment_ids: Array = completion.get("moment_ids", [])
	for moment_id: String in definition.witness_moment_ids():
		if moment_ids.has(moment_id):
			return true
	return false

func _is_archived(definition: IncidentDefinition, completion: Dictionary) -> bool:
	if not _is_completed(definition, completion):
		return false
	var archived: Array = completion.get("archive_moment_ids", [])
	for moment_id: String in definition.witness_moment_ids():
		if archived.has(moment_id):
			return true
	return false

extends Node

## MISSION 012 — Incident Registry Runtime validation checks.
## Loaded and executed by `incident_registry_validation.gd` after the autoload
## graph has booted. Covers the MISSION 012 validation requirements:
##   1. Registry initialization
##   2. Incident selection
##   3. Lifecycle handling
##   4. Runtime handoff
##   5. Completion state handling
##   6. WM_001-WM_005 validation fixtures
## Returns the number of failed checks; 0 = GREEN.

var _passed := 0
var _failed := 0

func _check(label: String, condition: bool, detail: String = "") -> void:
	if condition:
		_passed += 1
		print("PASS | %s" % label)
	else:
		_failed += 1
		print("FAIL | %s | %s" % [label, detail])

func _fresh_snapshot(completed_incidents: Array = [], completed_moments: Array = []) -> Dictionary:
	return {
		"witness_progress": {
			"completed_incident_ids": completed_incidents,
			"completed_moment_ids": completed_moments,
			"archive_entries": [],
			"witness_rank": "Observer",
			"witness_level": 1,
			"total_progress": 0
		}
	}

func run_checks(_tree: SceneTree) -> int:
	print("=== MISSION 012 INCIDENT REGISTRY RUNTIME VALIDATION ===")
	var registry = get_tree().root.get_node_or_null("IncidentRegistry")
	_check("A1 registry autoload exists", registry != null)
	if registry == null:
		return _finish()

	# --- 1. Registry initialization --------------------------------------
	_check("A2 registry is ready", registry.is_ready())
	_check("A3 five incidents registered", registry.get_incident_count() == 5, "count=%d" % registry.get_incident_count())
	_check("A4 zero invalid incidents", registry.get_invalid_incident_ids().is_empty(), str(registry.get_invalid_incident_ids()))
	var issue_free := true
	for incident_id: String in registry.get_registered_incident_ids():
		if not registry.get_validation_issues(incident_id).is_empty():
			issue_free = false
	_check("A5 all incidents passed schema validation", issue_free)
	_check("A6 manifest version exposed", registry.get_registry_version() == "1.0", registry.get_registry_version())
	var snapshot: Dictionary = registry.get_registry_snapshot({})
	_check("A7 registry snapshot available", snapshot.get("registered_count", 0) == 5)

	# --- 6. WM_001-WM_005 fixtures remain valid ---------------------------
	var expected_moments := {
		"INC_UNFINISHED_CANVAS": "WM_001",
		"INC_FORGOTTEN_MUSEUM": "WM_002",
		"INC_LAST_PERFORMANCE": "WM_003",
		"INC_FAULTY_REACTOR": "WM_004",
		"INC_THE_WITNESS": "WM_005"
	}
	var fixtures_valid := true
	for file_index: int in range(1, 6):
		var path := "res://src/iris/story/content/moment_00%d.json" % file_index
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			fixtures_valid = false
			continue
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if not (parsed is Dictionary):
			fixtures_valid = false
			continue
		var moment := WitnessMoment.from_dictionary(parsed as Dictionary)
		if moment.moment_id != "WM_00%d" % file_index or moment.title.is_empty() or moment.observation.is_empty():
			fixtures_valid = false
	_check("B1 all five witness moment fixtures load into WitnessMoment", fixtures_valid)

	# --- Director wiring ---------------------------------------------------
	var director := WitnessExperienceDirector.new()
	get_tree().root.add_child(director)
	_check("C1 director catalog exposes WM_001", director.select_moment("WM_001") != null)
	_check("C2 director catalog exposes all five fixtures", director.moments.size() == 5, "moments=%d" % director.moments.size())

	# --- 2. Incident selection ---------------------------------------------
	var all_incidents: Array = expected_moments.keys()
	var fresh_selection := director.get_next_incident({"mode": "story", "player_progress_snapshot": _fresh_snapshot()})
	_check("D1 fresh story selection non-empty", not fresh_selection.is_empty())
	_check("D2 fresh selection picks first incident", fresh_selection.get("incident_id", "") == "INC_UNFINISHED_CANVAS", str(fresh_selection.get("incident_id", "")))
	_check("D3 fresh selection resolves primary moment WM_001", fresh_selection.get("moment_id", "") == "WM_001", str(fresh_selection.get("moment_id", "")))
	_check("D4 selection carries memory case contract", not str(fresh_selection.get("memory_case_id", "")).is_empty())
	_check("D5 selection sourced from registry", fresh_selection.get("selection_source", "") == "incident_registry", str(fresh_selection.get("selection_source", "")))
	_check("D6 incident blueprint carries contract fields", fresh_selection.get("selected_incident", {}).get("mode_eligibility", []) == ["story", "archive_replay"])
	_check("D7 runtime context carries launch contract", fresh_selection.get("runtime_context", {}).get("selection_source", "") == "incident_registry")

	var advanced_selection := director.get_next_incident({
		"mode": "story",
		"player_progress_snapshot": _fresh_snapshot(["INC_UNFINISHED_CANVAS"], ["WM_001"])
	})
	_check("D8 progression-advanced selection moves to second incident", advanced_selection.get("incident_id", "") == "INC_FORGOTTEN_MUSEUM", str(advanced_selection.get("incident_id", "")))
	_check("D9 progression-advanced selection resolves WM_002", advanced_selection.get("moment_id", "") == "WM_002")

	var replay_selection := director.get_next_incident({
		"mode": "story",
		"player_progress_snapshot": _fresh_snapshot(all_incidents, ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005"])
	})
	_check("D10 all-complete selection re-enters replay cycle", replay_selection.get("incident_id", "") == "INC_UNFINISHED_CANVAS", str(replay_selection.get("incident_id", "")))
	_check("D11 replay reason reported", str(replay_selection.get("reason", "")).begins_with("replay_cycle"), str(replay_selection.get("reason", "")))

	var daily_selection := director.get_next_incident({
		"mode": "daily",
		"player_progress_snapshot": _fresh_snapshot()
	})
	_check("D12 ineligible mode returns empty (no silent fallback)", daily_selection.is_empty(), str(daily_selection.keys()))

	# --- 3 + 5. Lifecycle handling and completion states -------------------
	var state_changes: Array = []
	registry.incident_state_changed.connect(func(incident_id: String, previous_state: int, new_state: int, _reason: String):
		state_changes.append("%s:%s>%s" % [incident_id, registry.lifecycle_state_name(previous_state), registry.lifecycle_state_name(new_state)])
	)
	var lifecycle_selection: Dictionary = registry.select_incident({"mode": "story", "player_progress_snapshot": _fresh_snapshot()})
	var lifecycle_id: String = (lifecycle_selection.get("incident") as IncidentDefinition).incident_id if not lifecycle_selection.is_empty() else ""
	_check("E1 selection marks incident SELECTED", registry.get_lifecycle_state(lifecycle_id, {"player_progress_snapshot": _fresh_snapshot()}) == registry.Lifecycle.SELECTED, registry.lifecycle_state_name(registry.get_lifecycle_state(lifecycle_id)))
	registry.notify_incident_active()
	_check("E2 runtime entry marks incident ACTIVE", registry.get_lifecycle_state(lifecycle_id) == registry.Lifecycle.ACTIVE, registry.lifecycle_state_name(registry.get_lifecycle_state(lifecycle_id)))
	registry.notify_incident_abandoned()
	_check("E3 abandonment returns incident to availability", registry.get_lifecycle_state(lifecycle_id, {"player_progress_snapshot": _fresh_snapshot()}) == registry.Lifecycle.VALIDATED, registry.lifecycle_state_name(registry.get_lifecycle_state(lifecycle_id)))
	registry.select_incident({"mode": "story", "player_progress_snapshot": _fresh_snapshot()})
	registry.notify_incident_active()
	registry.notify_incident_failed("validation_probe_failure")
	_check("E4 runtime failure marks incident FAILED", registry.get_lifecycle_state(lifecycle_id) == registry.Lifecycle.FAILED, registry.lifecycle_state_name(registry.get_lifecycle_state(lifecycle_id)))
	var reselect: Dictionary = registry.select_incident({"mode": "story", "player_progress_snapshot": _fresh_snapshot()})
	_check("E5 failed incident remains eligible (no permanent lock)", (reselect.get("incident") as IncidentDefinition).incident_id == lifecycle_id)
	registry.notify_incident_active()
	registry.notify_incident_completed({"incident_id": lifecycle_id})
	_check("E6 completion records COMPLETED lifecycle", registry.get_lifecycle_state(lifecycle_id) == registry.Lifecycle.COMPLETED, registry.lifecycle_state_name(registry.get_lifecycle_state(lifecycle_id)))
	_check("E7 state change signals fired", not state_changes.is_empty(), str(state_changes))
	print("INFO | lifecycle transitions observed: %s" % ", ".join(state_changes))

	# --- 4. Runtime handoff through registry path ---------------------------
	var handoff := director.get_next_incident({"mode": "story", "player_progress_snapshot": _fresh_snapshot()})
	var handoff_incident_id := str(handoff.get("incident_id", ""))
	_check("F1 handoff selection rotates past session-completed incident", handoff_incident_id != lifecycle_id and not handoff_incident_id.is_empty(), handoff_incident_id)
	var orchestrator := WitnessMomentOrchestrator.new()
	get_tree().root.add_child(orchestrator)
	orchestrator.set_director(director)
	var failure_holder: Array = [""]
	orchestrator.moment_failed.connect(func(_moment_id: String, reason: String): failure_holder[0] = reason)
	var entered_holder: Array = [null]
	orchestrator.enter_requested.connect(func(moment: WitnessMoment): entered_holder[0] = moment)
	orchestrator.start_incident(handoff)
	await get_tree().process_frame
	await get_tree().process_frame
	var entered_moment: WitnessMoment = entered_holder[0] as WitnessMoment
	_check("F2 orchestrator accepted registry selection", orchestrator.definition != null)
	_check("F3 orchestrator runtime context carries registry incident", orchestrator.runtime_context.get("incident_id", "") == handoff_incident_id, str(orchestrator.runtime_context.get("incident_id", "")))
	_check("F4 orchestrator is active for handoff moment", orchestrator.is_active() and entered_moment != null)
	_check("F5 handoff moment matches registry memory case", entered_moment != null and entered_moment.moment_id == str(handoff.get("moment_id", "")), str(handoff.get("moment_id", "")))
	_check("F6 no orchestrator failure during handoff", str(failure_holder[0]).is_empty(), str(failure_holder[0]))

	director.queue_free()
	orchestrator.queue_free()
	return _finish()

func _finish() -> int:
	print("=== VALIDATION RESULT: %d passed, %d failed ===" % [_passed, _failed])
	return _failed

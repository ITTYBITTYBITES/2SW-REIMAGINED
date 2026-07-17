extends RefCounted
class_name WitnessRuntimeResult

const SCHEMA_VERSION := 1
const RUNTIME_VERSION := 1

var runtime_session_id := ""
var mode := "story"
var incident_id := ""
var memory_case_id := ""
var moment_id := ""
var title := ""
var content_version := "1"
var started_at_ms := 0
var completed_at_ms := 0
var completion_time_ms := 0
var completion_status := "completed"
var observation_score := 0
var reconstruction_score := 0
var reasoning_score := 0
var accuracy_score := 0
var insight_score := 0
var completion_quality := "complete"
var mistakes: Array = []
var discovered_clues: Array = []
var missed_clues: Array = []
var mastery_delta: Dictionary = {}
var archive_payload: Dictionary = {}
var iris_evolution_inputs: Dictionary = {}
var raw_phase_outputs: Dictionary = {}
var achievement_ids: Array = []

func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"runtime_version": RUNTIME_VERSION,
		"runtime_session_id": runtime_session_id,
		"mode": mode,
		"incident_id": incident_id,
		"memory_case_id": memory_case_id,
		"moment_id": moment_id,
		"title": title,
		"content_version": content_version,
		"started_at_ms": started_at_ms,
		"completed_at_ms": completed_at_ms,
		"completion_time_ms": completion_time_ms,
		"completion_status": completion_status,
		"observation_score": observation_score,
		"reconstruction_score": reconstruction_score,
		"reasoning_score": reasoning_score,
		"accuracy_score": accuracy_score,
		"insight_score": insight_score,
		"completion_quality": completion_quality,
		"mistakes": mistakes.duplicate(true),
		"discovered_clues": discovered_clues.duplicate(true),
		"missed_clues": missed_clues.duplicate(true),
		"mastery_delta": mastery_delta.duplicate(true),
		"archive_payload": archive_payload.duplicate(true),
		"iris_evolution_inputs": iris_evolution_inputs.duplicate(true),
		"raw_phase_outputs": raw_phase_outputs.duplicate(true),
		"achievement_ids": achievement_ids.duplicate(true)
	}

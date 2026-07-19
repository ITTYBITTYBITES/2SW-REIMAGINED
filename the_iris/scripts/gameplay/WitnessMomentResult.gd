extends RefCounted
class_name WitnessMomentResult

## Backward-compatible result contract. Existing anomaly fields remain while
## Living Iris outcomes describe the Fracture → Synchronization → Truth loop.
var moment_id := ""
var accuracy := 0.0
var anomalies_found := 0
var anomalies_total := 0
var assistance_used := false
var mastery := false
var observation_style := ""
var fractures_found := 0
var fractures_total := 0
var synchronization_completed := false
var synchronization_score := 0.0
var memory_stability := 0.0
var memory_collapsed := false
var truth_fragment_id := ""
var revelation_text := ""
var revelation_audio_hook := ""
var archive_entry := ""
var truth_fragment_title := ""
var recovered_memory_summary := ""
var truth_statement := ""
var iris_reflection := ""
var iris_reflection_event := ""

func _init(id := "", accuracy_value := 0.0, found := 0, total := 0, used_assistance := false, mastery_value := false, style := "", living_outcomes: Dictionary = {}) -> void:
	moment_id = id
	accuracy = clampf(accuracy_value, 0.0, 1.0)
	anomalies_found = maxi(found, 0)
	anomalies_total = maxi(total, 0)
	assistance_used = used_assistance
	mastery = mastery_value
	observation_style = style
	fractures_found = maxi(0, int(living_outcomes.get("fractures_found", anomalies_found)))
	fractures_total = maxi(0, int(living_outcomes.get("fractures_total", anomalies_total)))
	synchronization_completed = bool(living_outcomes.get("synchronization_completed", false))
	synchronization_score = clampf(float(living_outcomes.get("synchronization_score", 0.0)), 0.0, 1.0)
	memory_stability = clampf(float(living_outcomes.get("memory_stability", 0.0)), 0.0, 1.0)
	memory_collapsed = bool(living_outcomes.get("memory_collapsed", false))
	truth_fragment_id = str(living_outcomes.get("truth_fragment_id", ""))
	revelation_text = str(living_outcomes.get("revelation_text", ""))
	revelation_audio_hook = str(living_outcomes.get("revelation_audio_hook", ""))
	archive_entry = str(living_outcomes.get("archive_entry", ""))
	truth_fragment_title = str(living_outcomes.get("truth_fragment_title", ""))
	recovered_memory_summary = str(living_outcomes.get("recovered_memory_summary", ""))
	truth_statement = str(living_outcomes.get("truth_statement", ""))
	iris_reflection = str(living_outcomes.get("iris_reflection", ""))
	iris_reflection_event = str(living_outcomes.get("iris_reflection_event", ""))

func to_dictionary() -> Dictionary:
	return {
		"accuracy": accuracy,
		"anomalies_found": anomalies_found,
		"anomalies_total": anomalies_total,
		"assistance_used": assistance_used,
		"mastery": mastery,
		"observation_style": observation_style,
		"fractures_found": fractures_found,
		"fractures_total": fractures_total,
		"synchronization_completed": synchronization_completed,
		"synchronization_score": synchronization_score,
		"memory_stability": memory_stability,
		"memory_collapsed": memory_collapsed,
		"truth_fragment_id": truth_fragment_id,
		"revelation_text": revelation_text,
		"revelation_audio_hook": revelation_audio_hook,
		"archive_entry": archive_entry,
		"truth_fragment_title": truth_fragment_title,
		"recovered_memory_summary": recovered_memory_summary,
		"truth_statement": truth_statement,
		"iris_reflection": iris_reflection,
		"iris_reflection_event": iris_reflection_event
	}

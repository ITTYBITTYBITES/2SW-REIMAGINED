extends RefCounted
class_name WitnessProfile

## Local-only player identity and progression record. It observes completed
## Witness Moments without controlling Witness runtime behavior.
const SCHEMA_VERSION := 1

signal profile_changed(snapshot: Dictionary)
signal iris_evolution_changed(data: IrisEvolutionData)

var witness_name := "Witness"
var resonance := 0
var aperture_rank := 1
var aperture_title := "Observer"
var completed_moment_ids: Array[String] = []
var moment_records: Dictionary = {}
var completion_count := 0
var accuracy_total := 0.0
var accuracy_samples := 0
var anomalies_found := 0
var assistance_free_completions := 0
var replay_mastery_count := 0
var observation_style: Dictionary = {}
var iris_evolution: IrisEvolutionData = IrisEvolutionData.new()

static func from_dictionary(data: Dictionary) -> WitnessProfile:
	var profile := WitnessProfile.new()
	profile.witness_name = str(data.get("witness_name", "Witness"))
	profile.resonance = maxi(0, int(data.get("resonance", 0)))
	profile.completed_moment_ids = _string_array(data.get("completed_moment_ids", []))
	profile.moment_records = _dictionary(data.get("moment_records", {}))
	profile.completion_count = maxi(0, int(data.get("completion_count", profile.completed_moment_ids.size())))
	profile.accuracy_total = maxf(0.0, float(data.get("accuracy_total", 0.0)))
	profile.accuracy_samples = maxi(0, int(data.get("accuracy_samples", 0)))
	profile.anomalies_found = maxi(0, int(data.get("anomalies_found", 0)))
	profile.assistance_free_completions = maxi(0, int(data.get("assistance_free_completions", 0)))
	profile.replay_mastery_count = maxi(0, int(data.get("replay_mastery_count", 0)))
	profile.observation_style = _dictionary(data.get("observation_style", {}))
	profile._refresh_progression(false)
	if data.get("iris_evolution", {}) is Dictionary:
		profile.iris_evolution = IrisEvolutionData.from_dictionary(data.get("iris_evolution", {}))
	return profile

func record_completion(moment_id: String, result: Dictionary = {}) -> Dictionary:
	if moment_id.is_empty():
		return {"total": 0, "components": {}}
	var is_replay := completed_moment_ids.has(moment_id)
	var award := WitnessProgression.calculate_resonance_award(result, is_replay)
	resonance += int(award["total"])
	if not is_replay:
		completed_moment_ids.append(moment_id)
	completion_count += 1

	var record: Dictionary = _dictionary(moment_records.get(moment_id, {}))
	record["attempts"] = int(record.get("attempts", 0)) + 1
	record["completion_count"] = int(record.get("completion_count", 0)) + 1
	record["last_resonance_award"] = int(award["total"])
	record["best_resonance_award"] = maxi(int(record.get("best_resonance_award", 0)), int(award["total"]))
	if result.has("accuracy"):
		var accuracy := WitnessProgression._normalized_accuracy(result["accuracy"])
		accuracy_total += accuracy
		accuracy_samples += 1
		record["best_accuracy"] = maxf(float(record.get("best_accuracy", 0.0)), accuracy)
	if result.has("anomalies_found"):
		anomalies_found += maxi(0, int(result["anomalies_found"]))
	if result.has("assistance_used") and not bool(result["assistance_used"]):
		assistance_free_completions += 1
		record["assistance_free_completions"] = int(record.get("assistance_free_completions", 0)) + 1
	if bool(result.get("mastery", false)):
		replay_mastery_count += 1
		record["mastery_count"] = int(record.get("mastery_count", 0)) + 1
	if result.has("observation_style"):
		var style := str(result["observation_style"]).strip_edges()
		if not style.is_empty():
			observation_style[style] = int(observation_style.get(style, 0)) + 1
	moment_records[moment_id] = record

	_refresh_progression(true)
	return award

func average_accuracy() -> float:
	if accuracy_samples <= 0:
		return 0.0
	return accuracy_total / float(accuracy_samples)

func profile_snapshot() -> Dictionary:
	return {
		"witness_name": witness_name,
		"aperture_rank": aperture_rank,
		"aperture_title": aperture_title,
		"resonance": resonance,
		"moments_completed": completed_moment_ids.size(),
		"completion_count": completion_count,
		"accuracy": average_accuracy(),
		"anomalies_found": anomalies_found,
		"assistance_free_completions": assistance_free_completions,
		"replay_mastery_count": replay_mastery_count,
		"observation_style": observation_style.duplicate(true),
		"iris_evolution": iris_evolution.to_dictionary()
	}

func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"witness_name": witness_name,
		"resonance": resonance,
		"completed_moment_ids": completed_moment_ids.duplicate(),
		"moment_records": moment_records.duplicate(true),
		"completion_count": completion_count,
		"accuracy_total": accuracy_total,
		"accuracy_samples": accuracy_samples,
		"anomalies_found": anomalies_found,
		"assistance_free_completions": assistance_free_completions,
		"replay_mastery_count": replay_mastery_count,
		"observation_style": observation_style.duplicate(true),
		"iris_evolution": iris_evolution.to_dictionary()
	}

func _refresh_progression(emit_change: bool) -> void:
	aperture_rank = WitnessProgression.aperture_rank_for(resonance)
	aperture_title = WitnessProgression.aperture_title_for(aperture_rank)
	iris_evolution = IrisEvolutionData.new(
		aperture_rank,
		aperture_title,
		WitnessProgression.resonance_band_for(aperture_rank),
		resonance,
		completed_moment_ids.size()
	)
	if emit_change:
		iris_evolution_changed.emit(iris_evolution)
		profile_changed.emit(profile_snapshot())

static func _string_array(value: Variant) -> Array[String]:
	var items: Array[String] = []
	if value is Array:
		for item in value:
			var text := str(item).strip_edges()
			if not text.is_empty() and not items.has(text):
				items.append(text)
	return items

static func _dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}

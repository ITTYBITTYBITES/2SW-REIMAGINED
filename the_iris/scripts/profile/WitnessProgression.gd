extends RefCounted
class_name WitnessProgression

## Deterministic local progression rules. Current Witness runtime supplies only
## completion events; optional result fields are accepted for future mechanics.
const FIRST_COMPLETION_RESONANCE := 20
const REPLAY_COMPLETION_RESONANCE := 6
const MAX_APERTURE_RANK := 100
const RESONANCE_PER_RANK := 100

static func calculate_resonance_award(result: Dictionary, is_replay: bool) -> Dictionary:
	var components := {}
	var total := REPLAY_COMPLETION_RESONANCE if is_replay else FIRST_COMPLETION_RESONANCE
	components["completion"] = total

	if result.has("accuracy"):
		var accuracy := _normalized_accuracy(result["accuracy"])
		var accuracy_award := roundi(accuracy * 15.0)
		total += accuracy_award
		components["accuracy"] = accuracy_award
	if result.has("anomalies_found"):
		var anomaly_award := maxi(0, int(result["anomalies_found"])) * 4
		total += anomaly_award
		components["anomalies"] = anomaly_award
	if result.has("assistance_used") and not bool(result["assistance_used"]):
		total += 6
		components["unassisted"] = 6
	if bool(result.get("mastery", false)):
		total += 10
		components["mastery"] = 10

	return {"total": total, "components": components}

static func aperture_rank_for(resonance: int) -> int:
	var earned_ranks := floori(float(maxi(resonance, 0)) / float(RESONANCE_PER_RANK))
	return clampi(1 + earned_ranks, 1, MAX_APERTURE_RANK)

static func aperture_title_for(rank: int) -> String:
	if rank >= 100:
		return "Witness"
	if rank >= 50:
		return "Lucid"
	if rank >= 25:
		return "Perceptive"
	if rank >= 10:
		return "Attuned"
	return "Observer"

static func resonance_band_for(rank: int) -> String:
	if rank >= 100:
		return "witness"
	if rank >= 50:
		return "lucid"
	if rank >= 25:
		return "perceptive"
	if rank >= 10:
		return "attuned"
	return "observer"

static func _normalized_accuracy(value: Variant) -> float:
	var numeric := float(value)
	if numeric > 1.0:
		numeric /= 100.0
	return clampf(numeric, 0.0, 1.0)

extends RefCounted
class_name IrisEvolutionData

## Profile-derived data for a future Iris visual consumer. It has no current
## authority over IrisCore or LivingIris.
var aperture_rank := 1
var aperture_title := "Observer"
var resonance_band := "observer"
var resonance := 0
var completed_moments := 0
var visual_cue_key := "iris_evolution_observer"

func _init(rank := 1, title := "Observer", band := "observer", resonance_total := 0, completed_total := 0) -> void:
	aperture_rank = rank
	aperture_title = title
	resonance_band = band
	resonance = resonance_total
	completed_moments = completed_total
	visual_cue_key = "iris_evolution_%s" % resonance_band

static func from_dictionary(data: Dictionary) -> IrisEvolutionData:
	var evolution := IrisEvolutionData.new(
		int(data.get("aperture_rank", 1)),
		str(data.get("aperture_title", "Observer")),
		str(data.get("resonance_band", "observer")),
		int(data.get("resonance", 0)),
		int(data.get("completed_moments", 0))
	)
	evolution.visual_cue_key = str(data.get("visual_cue_key", evolution.visual_cue_key))
	return evolution

func to_dictionary() -> Dictionary:
	return {
		"aperture_rank": aperture_rank,
		"aperture_title": aperture_title,
		"resonance_band": resonance_band,
		"resonance": resonance,
		"completed_moments": completed_moments,
		"visual_cue_key": visual_cue_key
	}

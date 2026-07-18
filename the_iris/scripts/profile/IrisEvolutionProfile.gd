extends RefCounted
class_name IrisEvolutionProfile

## Profile-derived visual and personality evolution contract.
## WitnessProgression remains the sole source of truth for Resonance/Rank.

var aperture_rank := 1
var resonance_total := 0
var evolution_stage := "OBSERVER"
var visual_signature := "basic_glow"
var personality_alignment := "observant"
var unlocked_features: Array[String] = []

func _init(rank := 1, resonance := 0) -> void:
	aperture_rank = rank
	resonance_total = resonance
	_compute_profile()

func _compute_profile() -> void:
	if aperture_rank >= 100:
		evolution_stage = "WITNESS"
		visual_signature = "full_evolution"
		personality_alignment = "complete"
		unlocked_features = [
			"simple_iris", "depth", "focus_response", 
			"layers", "complex_geometry", "anomaly_response", 
			"advanced_patterns", "biological_behavior", "witness_state"
		]
	elif aperture_rank >= 50:
		evolution_stage = "LUCID"
		visual_signature = "lucid_patterns"
		personality_alignment = "harmonious"
		unlocked_features = [
			"simple_iris", "depth", "focus_response", 
			"layers", "complex_geometry", "anomaly_response", 
			"advanced_patterns", "biological_behavior"
		]
	elif aperture_rank >= 25:
		evolution_stage = "PERCEPTIVE"
		visual_signature = "perceptive_geometry"
		personality_alignment = "curious"
		unlocked_features = [
			"simple_iris", "depth", "focus_response", 
			"layers", "complex_geometry", "anomaly_response"
		]
	elif aperture_rank >= 10:
		evolution_stage = "ATTUNED"
		visual_signature = "attuned_depth"
		personality_alignment = "attuned"
		unlocked_features = [
			"simple_iris", "depth", "focus_response", "layers"
		]
	else:
		evolution_stage = "OBSERVER"
		visual_signature = "observer_glow"
		personality_alignment = "observant"
		unlocked_features = [
			"simple_iris"
		]

static func from_dictionary(data: Dictionary) -> IrisEvolutionProfile:
	var profile := IrisEvolutionProfile.new(
		int(data.get("aperture_rank", 1)),
		int(data.get("resonance_total", int(data.get("resonance", 0))))
	)
	return profile

func to_dictionary() -> Dictionary:
	return {
		"aperture_rank": aperture_rank,
		"resonance_total": resonance_total,
		"evolution_stage": evolution_stage,
		"visual_signature": visual_signature,
		"personality_alignment": personality_alignment,
		"unlocked_features": unlocked_features
	}

extends RefCounted
class_name IrisEvolutionVisualConsumer

## Connects player progression to Living Iris visuals by consuming evolution data
## and calculating visual multipliers and parameters dynamically.

static func apply_evolution(profile: IrisEvolutionProfile, base_behavior: Dictionary) -> Dictionary:
	var behavior = base_behavior.duplicate(true)
	if profile == null:
		return behavior
		
	# Retrieve current evolution stage
	var stage := profile.evolution_stage
	
	match stage:
		"OBSERVER":
			# Simple Iris, Basic glow, Minimal movement
			behavior["glow"] = float(behavior.get("glow", 0.0)) * 0.8
			behavior["fiber_motion"] = float(behavior.get("fiber_motion", 0.0)) * 0.4
			behavior["fiber_density"] = clampi(int(behavior.get("fiber_density", 0)), 0, 24)
			behavior["depth_offset"] = 0.0
			behavior["geometry_scale"] = 1.0
			behavior["biological_pulse"] = 1.0
			
		"ATTUNED":
			# Increased depth, Stronger focus response, Additional visual layers
			behavior["glow"] = float(behavior.get("glow", 0.0)) * 1.25
			behavior["fiber_motion"] = float(behavior.get("fiber_motion", 0.0)) * 0.85
			behavior["fiber_density"] = clampi(int(behavior.get("fiber_density", 40)), 10, 48)
			behavior["focus"] = float(behavior.get("focus", 0.0)) * 1.25
			behavior["depth_offset"] = 0.15 # custom draw parameter for increased depth
			behavior["geometry_scale"] = 1.15
			behavior["biological_pulse"] = 1.1
			
		"PERCEPTIVE":
			# More complex geometry, Enhanced anomaly response
			behavior["glow"] = float(behavior.get("glow", 0.0)) * 1.6
			behavior["fiber_motion"] = float(behavior.get("fiber_motion", 0.0)) * 1.15
			behavior["fiber_density"] = clampi(int(behavior.get("fiber_density", 48)), 15, 64)
			behavior["focus"] = float(behavior.get("focus", 0.0)) * 1.6
			behavior["geometry_scale"] = 1.4
			behavior["depth_offset"] = 0.35
			behavior["biological_pulse"] = 1.25
			
		"LUCID":
			# Advanced Iris patterns, Stronger biological behavior
			behavior["glow"] = float(behavior.get("glow", 0.0)) * 2.05
			behavior["fiber_motion"] = float(behavior.get("fiber_motion", 0.0)) * 1.45
			behavior["fiber_density"] = clampi(int(behavior.get("fiber_density", 54)), 20, 80)
			behavior["focus"] = float(behavior.get("focus", 0.0)) * 2.0
			behavior["biological_pulse"] = 1.55 # extra organic pulse factor
			behavior["geometry_scale"] = 1.75
			behavior["depth_offset"] = 0.55
			
		"WITNESS":
			# Full evolution state
			behavior["glow"] = float(behavior.get("glow", 0.0)) * 2.65
			behavior["fiber_motion"] = float(behavior.get("fiber_motion", 0.0)) * 1.85
			behavior["fiber_density"] = clampi(int(behavior.get("fiber_density", 60)), 30, 96)
			behavior["focus"] = float(behavior.get("focus", 0.0)) * 2.45
			behavior["biological_pulse"] = 1.95
			behavior["geometry_scale"] = 2.15
			behavior["depth_offset"] = 0.75
			behavior["full_evolution_flare"] = 1.0 # activates special glowing ring layers
			
	# Truth Fragments are a persistent, archive-derived visual layer. They are
	# additive to rank progression and therefore visible even at Observer rank.
	var fragments := profile.fragment_count
	if fragments > 0:
		behavior["fragment_memory"] = fragments
		behavior["fragment_glow"] = minf(0.34, 0.12 + float(fragments) * 0.055)
		behavior["glow"] = float(behavior.get("glow", 0.0)) + float(behavior["fragment_glow"])
		behavior["fiber_density"] = int(behavior.get("fiber_density", 0)) + mini(fragments * 3, 12)
		behavior["fragment_bloom"] = profile.chapter_blooms.has("chapter_01") and bool(profile.chapter_blooms["chapter_01"].get("bloomed", false))
	return behavior

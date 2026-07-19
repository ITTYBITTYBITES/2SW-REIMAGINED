extends RefCounted
class_name IrisEvolutionVisualConsumer

## Minimal retained visual adapter. It deliberately has no retired gameplay,
## fragment, chapter, or relationship assumptions after the Witness reset.
static func apply_evolution(profile: IrisEvolutionProfile, base_behavior: Dictionary) -> Dictionary:
	var behavior := base_behavior.duplicate(true)
	if profile == null:
		return behavior
	behavior["presence"] = float(behavior.get("presence", 1.0)) * profile.presence_intensity
	return behavior

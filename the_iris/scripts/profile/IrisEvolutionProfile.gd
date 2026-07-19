extends RefCounted
class_name IrisEvolutionProfile

## Retained visual platform profile. New experience progression is intentionally
## deferred until the first bespoke experience has been human-validated.
var visual_signature := "baseline"
var presence_intensity := 1.0

func _init(signature := "baseline", intensity := 1.0) -> void:
	visual_signature = signature
	presence_intensity = clampf(float(intensity), 0.0, 1.0)

static func from_dictionary(data: Dictionary) -> IrisEvolutionProfile:
	return IrisEvolutionProfile.new(str(data.get("visual_signature", "baseline")), float(data.get("presence_intensity", 1.0)))

func to_dictionary() -> Dictionary:
	return {"visual_signature": visual_signature, "presence_intensity": presence_intensity}

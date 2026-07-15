extends ChallengeValidator
class_name SpotDifferenceValidator

const VERSION := "2"

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return ChallengeValidationResult.rejected("Instance is null", "instance.null")
	var errors: Array[String] = instance.get_contract_errors()
	if not errors.is_empty():
		return ChallengeValidationResult.rejected(str(errors), "instance.contract")
	var target_id := str(instance.metadata.get("target_id", ""))
	if target_id.is_empty():
		return ChallengeValidationResult.rejected("Target is missing", "mutation.target")
	var regions_value: Variant = instance.metadata.get("target_regions", [])
	if not (regions_value is Array) or (regions_value as Array).size() != 2:
		return ChallengeValidationResult.rejected("Both target regions are required", "target.region")
	for value: Variant in regions_value:
		if not (value is Dictionary):
			return ChallengeValidationResult.rejected("Region is invalid", "target.region")
		var region: Dictionary = value
		if float(region.get("w", 0.0)) < 0.05 or float(region.get("h", 0.0)) < 0.05:
			return ChallengeValidationResult.rejected("Target region is too small", "target.size")
		if (
			float(region.get("x", -1.0)) < 0.0
			or float(region.get("y", -1.0)) < 0.0
			or float(region.get("x", 0.0)) + float(region.get("w", 0.0)) > 1.0
			or float(region.get("y", 0.0)) + float(region.get("h", 0.0)) > 1.0
		):
			return ChallengeValidationResult.rejected("Target region leaves bounds", "target.bounds")
	if instance.answer_options.size() < 4:
		return ChallengeValidationResult.rejected("Accessible options are incomplete", "distractor.count")
	var unique: Dictionary = {}
	for option: Variant in instance.answer_options:
		unique[str(option)] = true
	if unique.size() != instance.answer_options.size():
		return ChallengeValidationResult.rejected("Options repeat", "distractor.unique")
	var objects_a: Array = instance.generated_scene.get("objects_a", [])
	var objects_b: Array = instance.generated_scene.get("objects_b", [])
	if objects_a.size() < 5 or objects_b.size() not in [objects_a.size(), objects_a.size() - 1]:
		return ChallengeValidationResult.rejected("Paired states are inconsistent", "mutation.count")
	if str(instance.generated_scene.get("mode", "")) == "sequential":
		var state_duration := float(instance.generated_scene.get("state_duration", 0.0))
		if instance.exposure_duration_sec < state_duration * 2.0:
			return ChallengeValidationResult.rejected("Sequential state B is not visible long enough", "exposure.sequential")
	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": [
			"instance.contract", "mutation.target", "target.region", "target.size",
			"target.bounds", "distractor.unique", "mutation.count", "exposure.sequential"
		]
	})

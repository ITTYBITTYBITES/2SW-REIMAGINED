extends ChallengeValidator
class_name SceneInvestigationValidator
## Production fairness validator for generated Scene Investigation instances.

const VERSION: String = "1"

const EXPOSURE_BOUNDS := {
	"beginner": {"min": 5.0, "max": 7.2},
	"standard": {"min": 3.5, "max": 6.0},
	"advanced": {"min": 2.0, "max": 4.2},
	"expert": {"min": 1.5, "max": 2.4}
}

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return _reject("Generator returned no instance", "instance.missing")
	var contract_errors := instance.get_contract_errors()
	if not contract_errors.is_empty():
		return _reject("Instance contract is incomplete", "instance.contract_complete", {"errors": contract_errors})

	var scene := instance.generated_scene
	var objects_value: Variant = scene.get("objects", [])
	if not (objects_value is Array):
		return _reject("Scene objects are missing", "scene.objects_missing")
	var objects: Array = objects_value
	var axes := instance.difficulty_axes
	var minimum := int(axes.get("object_count_min", 1))
	var maximum := int(axes.get("object_count_max", 99))
	if objects.size() < minimum or objects.size() > maximum:
		return _reject("Object count is outside the resolved policy", "scene.object_count_within_policy", {"count": objects.size(), "min": minimum, "max": maximum})

	var ids: Dictionary = {}
	var rects: Array[Rect2] = []
	for raw_object: Variant in objects:
		if not (raw_object is Dictionary):
			return _reject("Scene contains invalid object data", "scene.object_contract")
		var object_data: Dictionary = raw_object
		var object_id := str(object_data.get("instance_id", ""))
		if object_id.is_empty() or ids.has(object_id):
			return _reject("Object IDs must be unique", "scene.object_id_unique", {"object_id": object_id})
		ids[object_id] = true
		var x := float(object_data.get("x", -1.0))
		var y := float(object_data.get("y", -1.0))
		var width := float(object_data.get("w", 0.0))
		var height := float(object_data.get("h", 0.0))
		if x < 0.05 or x > 0.95 or y < 0.24 or y > 0.96:
			return _reject("Question-eligible object is outside the safe scene region", "scene.safe_area", {"object_id": object_id})
		if width < 0.04 or height < 0.035:
			return _reject("Question-eligible object is too small", "scene.target_size", {"object_id": object_id})
		var rect := Rect2(x - width * 0.5, y - height * 0.5, width, height)
		for existing: Rect2 in rects:
			var intersection := rect.intersection(existing)
			if intersection.has_area() and intersection.get_area() > rect.get_area() * 0.18:
				return _reject("Objects overlap beyond the fairness limit", "scene.overlap_limits", {"object_id": object_id})
		rects.append(rect)

	var correct_matches: int = 0
	for option: Variant in instance.answer_options:
		if str(option) == str(instance.correct_answer):
			correct_matches += 1
	if correct_matches != 1:
		return _reject("Answer set is ambiguous", "question.answer_unique", {"matches": correct_matches})

	var prompt := str(instance.question.get("prompt", "")).strip_edges()
	if prompt.is_empty():
		return _reject("Question prompt is empty", "question.prompt")
	var question_type := str(instance.metadata.get("question_type", ""))
	if question_type not in ["count", "attribute", "position", "adjacency", "presence"]:
		return _reject("Question type is not approved", "question.type", {"question_type": question_type})

	var highlight_value: Variant = instance.metadata.get("highlight_ids", [])
	if not (highlight_value is Array) or (highlight_value as Array).is_empty():
		return _reject("Reveal evidence is missing", "reveal.evidence_available")
	for highlight_id: Variant in highlight_value:
		if not ids.has(str(highlight_id)):
			return _reject("Reveal references an unknown object", "reveal.evidence_available", {"highlight_id": highlight_id})

	if question_type == "adjacency" and not _validate_adjacency(highlight_value as Array, objects):
		return _reject("Adjacency relationship is ambiguous", "question.relationship_unambiguous")

	var bounds: Dictionary = EXPOSURE_BOUNDS.get(instance.difficulty_label, EXPOSURE_BOUNDS["beginner"])
	if instance.exposure_duration_sec < float(bounds.get("min", 1.5)) or instance.exposure_duration_sec > float(bounds.get("max", 7.2)):
		return _reject("Exposure is outside the approved tier policy", "exposure.within_policy", {"duration": instance.exposure_duration_sec})

	var renderer_script := str(scene.get("renderer_script", ""))
	if renderer_script.is_empty() or not ResourceLoader.exists(renderer_script):
		return _reject("Scene renderer is unavailable", "asset.required_available", {"renderer_script": renderer_script})
	var background_value: Variant = scene.get("background", {})
	if background_value is Dictionary:
		var background_image := str((background_value as Dictionary).get("image_path", ""))
		if not background_image.is_empty() and not ResourceLoader.exists(background_image):
			return _reject("Scene background is unavailable", "asset.required_available", {"background_image": background_image})
	if str(instance.metadata.get("scene_signature", "")).length() < 32:
		return _reject("Scene signature is missing", "reproduction.version_complete")

	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": [
			"instance.contract_complete",
			"scene.object_count_within_policy",
			"scene.object_id_unique",
			"scene.safe_area",
			"scene.target_size",
			"scene.overlap_limits",
			"question.answer_unique",
			"question.type",
			"question.relationship_unambiguous",
			"reveal.evidence_available",
			"exposure.within_policy",
			"asset.required_available",
			"reproduction.version_complete"
		]
	})

func _validate_adjacency(highlight_ids: Array, objects: Array) -> bool:
	if highlight_ids.size() != 2:
		return false
	var target := _find_object(str(highlight_ids[0]), objects)
	var expected := _find_object(str(highlight_ids[1]), objects)
	if target.is_empty() or expected.is_empty():
		return false
	var target_pos := Vector2(float(target.get("x", 0.0)), float(target.get("y", 0.0)))
	var distances: Array[Dictionary] = []
	for raw_object: Variant in objects:
		if raw_object is Dictionary:
			var object_data: Dictionary = raw_object
			if object_data.get("instance_id") == target.get("instance_id"):
				continue
			var position := Vector2(float(object_data.get("x", 0.0)), float(object_data.get("y", 0.0)))
			distances.append({"id": object_data.get("instance_id", ""), "distance": target_pos.distance_to(position)})
	distances.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["distance"]) < float(b["distance"]))
	if distances.size() < 2:
		return false
	return str(distances[0].get("id", "")) == str(expected.get("instance_id", "")) and float(distances[1]["distance"]) - float(distances[0]["distance"]) >= 0.035

func _find_object(instance_id: String, objects: Array) -> Dictionary:
	for raw_object: Variant in objects:
		if raw_object is Dictionary and str((raw_object as Dictionary).get("instance_id", "")) == instance_id:
			return raw_object
	return {}

func _reject(reason: String, rule_id: String, details: Dictionary = {}) -> ChallengeValidationResult:
	return ChallengeValidationResult.rejected(reason, rule_id, details)

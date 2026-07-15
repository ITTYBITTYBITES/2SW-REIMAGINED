extends ChallengeGenerator
class_name ObjectRecallGenerator
## Seeded generator for exact sets, missing objects, row groups, and bookends.

const VERSION := "2"
const CONTENT_VERSION := "object-recall-v2"
const RENDERER_SCRIPT := "res://src/LegacyMechanics/object_recall/ObjectRecallView.gd"
const OBJECTS_PATH := "res://src/LegacyMechanics/object_recall/content/objects_v2.json"

var _objects: Array[Dictionary] = []

func _init() -> void:
	_load_objects()

func get_version() -> String:
	return VERSION

func get_object_pool_size() -> int:
	return _objects.size()

func generate(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	if _objects.size() < 12:
		return null
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var axes: Dictionary = difficulty.get("axes", {})
	var shown_count: int = clampi(int(axes.get("shown_count", 3)), 3, 6)
	var option_count: int = clampi(
		maxi(int(axes.get("option_count", 6)), shown_count + 2),
		shown_count + 2,
		_objects.size()
	)
	var pool: Array = _objects.duplicate(true)
	_shuffle(pool, rng)
	var shown_definitions: Array[Dictionary] = []
	var option_definitions: Array[Dictionary] = []
	for index: int in range(shown_count):
		shown_definitions.append(pool[index] as Dictionary)
	for index: int in range(option_count):
		option_definitions.append(pool[index] as Dictionary)

	var columns: int = ceili(float(shown_count) / 2.0)
	var objects: Array[Dictionary] = []
	var display_by_id: Dictionary = {}
	for index: int in range(shown_definitions.size()):
		var definition: Dictionary = shown_definitions[index]
		var row: int = floori(float(index) / float(columns))
		var column: int = index % columns
		var colors: Array = definition.get("colors", ["#5B7FD0"])
		var object_data := {
			"id": str(definition.get("id", "object")),
			"label": str(definition.get("label", "Object")),
			"response_value": str(definition.get("label", "Object")),
			"kind": str(definition.get("kind", "circle")),
			"category": str(definition.get("category", "object")),
			"x": float(column + 1) / float(columns + 1),
			"y": 0.34 if row == 0 else 0.70,
			"color": str(colors[rng.randi_range(0, colors.size() - 1)])
		}
		objects.append(object_data)
		display_by_id[object_data.id] = object_data

	var options: Array[String] = []
	var option_objects: Array[Dictionary] = []
	for definition: Dictionary in option_definitions:
		var definition_id := str(definition.get("id", "object"))
		var label := str(definition.get("label", "Object"))
		var option_colors: Array = definition.get("colors", ["#5B7FD0"])
		options.append(label)
		if display_by_id.has(definition_id):
			option_objects.append((display_by_id[definition_id] as Dictionary).duplicate(true))
		else:
			option_objects.append({
				"id": definition_id,
				"label": label,
				"response_value": label,
				"kind": str(definition.get("kind", "circle")),
				"category": str(definition.get("category", "object")),
				"color": str(option_colors[rng.randi_range(0, option_colors.size() - 1)])
			})

	var mode: String = str(template.metadata.get("mode", "seen"))
	var correct: Array[String] = []
	var prompt := "Select every object that appeared."
	var where_to_look := "the highlighted remembered objects"
	match mode:
		"missing":
			correct = [
				str(option_definitions[shown_count].get("label", "Object")),
				str(option_definitions[shown_count + 1].get("label", "Object"))
			]
			prompt = "Select the two objects that did not appear."
			where_to_look = "the NOT SHOWN evidence row"
		"top_row":
			for index: int in range(columns):
				correct.append(str(shown_definitions[index].get("label", "Object")))
			prompt = "Select every object that was on the top row."
			where_to_look = "the highlighted top row"
		"bookends":
			correct = [
				str(shown_definitions.front().get("label", "Object")),
				str(shown_definitions.back().get("label", "Object"))
			]
			prompt = "Select the first and last objects in reading order."
			where_to_look = "the highlighted first and last positions"
		_:
			for definition: Dictionary in shown_definitions:
				correct.append(str(definition.get("label", "Object")))
	_shuffle(options, rng)
	var signature: String = JSON.stringify({
		"template": template.template_id,
		"shown": shown_definitions,
		"correct": correct,
		"options": options
	}).sha256_text()
	var explanation := _explanation_for(mode, correct)
	return ChallengeInstance.new({
		"instance_id": "%s:%s:%d" % [template.family_id, template.template_id, seed_value],
		"family_id": template.family_id,
		"family_version": str(template.metadata.get("family_version", "2")),
		"template_id": template.template_id,
		"template_version": template.template_version,
		"generator_version": VERSION,
		"validator_version": "2",
		"difficulty_policy_version": str(difficulty.get("policy_version", "2")),
		"exposure_policy_version": "2",
		"content_version": CONTENT_VERSION,
		"seed": seed_value,
		"difficulty_label": str(difficulty.get("label", "beginner")),
		"difficulty_axes": axes,
		"exposure_duration_sec": exposure_duration_sec,
		"generated_scene": {
			"renderer_script": RENDERER_SCRIPT,
			"objects": objects,
			"option_objects": option_objects,
			"mode": mode,
			"scene_signature": signature
		},
		"question": {"type": "multiple_choice", "prompt": prompt},
		"answer_options": options,
		"correct_answer": correct,
		"explanation": explanation,
		"metadata": {
			"progress_key": template.family_id,
			"question_type": mode,
			"shown_objects": _labels(shown_definitions),
			"where_to_look": where_to_look,
			"scene_signature": signature,
			"interaction_data": {"selection_count": correct.size()}
		}
	})

func _explanation_for(mode: String, correct: Array[String]) -> String:
	var list := ", ".join(correct)
	match mode:
		"missing":
			return "The two options that never appeared were %s." % list
		"top_row":
			return "The top row held %s." % list
		"bookends":
			return "The first and last positions held %s." % list
		_:
			return "The remembered set was %s." % list

func _labels(definitions: Array[Dictionary]) -> Array[String]:
	var labels: Array[String] = []
	for definition: Dictionary in definitions:
		labels.append(str(definition.get("label", "Object")))
	return labels

func _load_objects() -> void:
	_objects.clear()
	if not FileAccess.file_exists(OBJECTS_PATH):
		return
	var file := FileAccess.open(OBJECTS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	var values: Variant = (parsed as Dictionary).get("objects", [])
	if not (values is Array):
		return
	for value: Variant in values:
		if value is Dictionary:
			_objects.append((value as Dictionary).duplicate(true))

func _shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var swap_value: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = swap_value

extends ChallengeGenerator
class_name SceneInvestigationGenerator
## Seeded procedural generator for Office, Kitchen, and Workshop scenes.

const VERSION: String = "2"
const CONTENT_VERSION: String = "scene-investigation-production-v2"
const RENDERER_SCRIPT: String = "res://src/LegacyMechanics/scene_investigation/SceneInvestigationSceneView.gd"

const COLORS := {
	"blue": {"hex": "#3F6FAE", "label": "Blue"},
	"sky": {"hex": "#6DAEDB", "label": "Sky blue"},
	"green": {"hex": "#4F8A65", "label": "Green"},
	"mint": {"hex": "#78B89A", "label": "Mint"},
	"red": {"hex": "#C95F5F", "label": "Red"},
	"orange": {"hex": "#D98945", "label": "Orange"},
	"yellow": {"hex": "#D9AD4A", "label": "Yellow"},
	"violet": {"hex": "#7660A8", "label": "Violet"},
	"brown": {"hex": "#A98768", "label": "Brown"},
	"gray": {"hex": "#76808F", "label": "Gray"},
	"black": {"hex": "#343842", "label": "Black"},
	"cream": {"hex": "#E8E0D1", "label": "Cream"}
}

func get_version() -> String:
	return VERSION

func generate(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	var content_value: Variant = template.metadata.get("content_data", {})
	if not (content_value is Dictionary):
		return null
	var content: Dictionary = content_value
	var pool_value: Variant = content.get("objects", [])
	if not (pool_value is Array) or (pool_value as Array).is_empty():
		return null

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var axes: Dictionary = difficulty.get("axes", {})
	var min_count := int(axes.get("object_count_min", 8))
	var max_count := int(axes.get("object_count_max", 10))
	var object_count := rng.randi_range(min_count, max_count)
	var object_pool: Array = pool_value
	object_count = mini(object_count, object_pool.size())

	var selected := _select_objects(content, object_pool, object_count, rng)
	var background_value: Variant = content.get("background", {})
	var background: Dictionary = (background_value as Dictionary).duplicate(true) if background_value is Dictionary else {}
	var slots := _build_slots(rng, float(background.get("surface_y", 0.30)))
	var objects := _build_instances(selected, slots, axes, rng)
	var decorations := _build_decorations(int(axes.get("decorative_count", 0)), float(background.get("surface_y", 0.30)), rng)
	var question := _build_question(content, objects, object_pool, axes, rng)
	if question.is_empty():
		return null

	var template_id := template.template_id
	var scene_signature := _scene_signature(template_id, objects, question)
	var generated_scene := {
		"title": content.get("title", template.title),
		"description": content.get("description", ""),
		"template_id": template_id,
		"renderer_script": RENDERER_SCRIPT,
		"background": background,
		"decorations": decorations,
		"objects": objects,
		"scene_signature": scene_signature
	}
	return ChallengeInstance.new({
		"instance_id": "%s:%s:%d" % [template.family_id, template_id, seed_value],
		"family_id": template.family_id,
		"family_version": str(template.metadata.get("family_version", "1")),
		"template_id": template_id,
		"template_version": template.template_version,
		"generator_version": VERSION,
		"validator_version": str(template.metadata.get("validator_version", "1")),
		"difficulty_policy_version": str(difficulty.get("policy_version", "1")),
		"exposure_policy_version": str(template.metadata.get("exposure_policy_version", "1")),
		"content_version": CONTENT_VERSION,
		"seed": seed_value,
		"difficulty_label": str(difficulty.get("label", "beginner")),
		"difficulty_axes": axes,
		"exposure_duration_sec": exposure_duration_sec,
		"generated_scene": generated_scene,
		"question": question.get("question", {}),
		"answer_options": question.get("options", []),
		"correct_answer": question.get("correct", null),
		"explanation": question.get("explanation", ""),
		"validation_metadata": {"candidate": "procedural"},
		"metadata": {
			"content_role": "production",
			"progress_key": "scene_investigation",
			"question_type": question.get("type", "unknown"),
			"highlight_ids": question.get("highlight_ids", []),
			"where_to_look": question.get("where_to_look", "the highlighted area"),
			"scene_signature": scene_signature
		}
	})

func _select_objects(content: Dictionary, pool: Array, count: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	var used_ids: Dictionary = {}
	var required_value: Variant = content.get("required_groups", [])
	if required_value is Array:
		for required_group: Variant in required_value:
			var candidates: Array[Dictionary] = []
			for raw_object: Variant in pool:
				if raw_object is Dictionary:
					var object_data: Dictionary = raw_object
					var groups: Variant = object_data.get("groups", [])
					if groups is Array and groups.has(str(required_group)) and not used_ids.has(str(object_data.get("id", ""))):
						candidates.append(object_data)
			if not candidates.is_empty():
				var chosen: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
				selected.append(chosen)
				used_ids[str(chosen.get("id", ""))] = true

	var shuffled: Array = pool.duplicate(true)
	_shuffle(shuffled, rng)
	for raw_object: Variant in shuffled:
		if selected.size() >= count:
			break
		if raw_object is Dictionary:
			var object_data: Dictionary = raw_object
			var object_id := str(object_data.get("id", ""))
			if not used_ids.has(object_id):
				selected.append(object_data)
				used_ids[object_id] = true
	return selected

func _build_slots(rng: RandomNumberGenerator, surface_y: float) -> Array[Vector2]:
	var slots: Array[Vector2] = []
	var first_row := clampf(surface_y + 0.03, 0.30, 0.58)
	var last_row := 0.93
	var row_spacing := (last_row - first_row) / 3.0
	for row: int in range(4):
		for column: int in range(5):
			var x := 0.10 + float(column) * 0.20 + rng.randf_range(-0.015, 0.015)
			var y := first_row + float(row) * row_spacing + rng.randf_range(-0.010, 0.010)
			slots.append(Vector2(x, y))
	_shuffle(slots, rng)
	return slots

func _build_instances(
	selected: Array[Dictionary],
	slots: Array[Vector2],
	axes: Dictionary,
	rng: RandomNumberGenerator
) -> Array[Dictionary]:
	var instances: Array[Dictionary] = []
	var target_scale := float(axes.get("target_scale", 1.0))
	var similarity := float(axes.get("similarity", 0.2))
	var scene_palette: Array = COLORS.keys()
	_shuffle(scene_palette, rng)
	scene_palette = scene_palette.slice(0, 4)
	for index: int in range(selected.size()):
		var archetype := selected[index]
		var colors_value: Variant = archetype.get("colors", ["blue"])
		var color_names: Array = colors_value if colors_value is Array and not colors_value.is_empty() else ["blue"]
		var color_name := _choose_color(color_names, scene_palette, similarity, rng)
		var color_data: Dictionary = COLORS.get(color_name, COLORS["blue"])
		var slot := slots[index]
		var kind := str(archetype.get("visual_kind", "generic"))
		var size := _size_for_kind(kind) * target_scale
		var rotation := rng.randf_range(-7.0, 7.0) if _is_long_kind(kind) else rng.randf_range(-2.0, 2.0)
		instances.append({
			"instance_id": "obj_%02d" % index,
			"archetype_id": archetype.get("id", "object"),
			"name": archetype.get("name", "object"),
			"visual_kind": kind,
			"groups": (archetype.get("groups", []) as Array).duplicate(),
			"available_colors": color_names.duplicate(),
			"color_name": color_name,
			"color_label": color_data.get("label", color_name.capitalize()),
			"color": color_data.get("hex", "#6DAEDB"),
			"x": slot.x,
			"y": slot.y,
			"w": size.x,
			"h": size.y,
			"rotation_deg": rotation,
			"question_eligible": true
		})
	return instances

func _build_decorations(count: int, surface_y: float, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var decorations: Array[Dictionary] = []
	for index: int in range(count):
		decorations.append({
			"kind": ["dot", "line", "paper_corner"][rng.randi_range(0, 2)],
			"x": rng.randf_range(0.07, 0.93),
			"y": rng.randf_range(maxf(surface_y + 0.02, 0.30), 0.93),
			"scale": rng.randf_range(0.7, 1.2),
			"rotation_deg": rng.randf_range(-25.0, 25.0)
		})
	return decorations

func _build_question(
	content: Dictionary,
	objects: Array[Dictionary],
	pool: Array,
	axes: Dictionary,
	rng: RandomNumberGenerator
) -> Dictionary:
	var types_value: Variant = content.get("question_types", ["presence"])
	var question_types: Array = (types_value as Array).duplicate() if types_value is Array else ["presence"]
	var complexity := float(axes.get("question_complexity", 0.2))
	if complexity < 0.35:
		question_types.erase("adjacency")
	if complexity < 0.18:
		question_types.erase("count")
	if bool(axes.get("color_assist_mode", false)):
		question_types.erase("attribute")
	if question_types.is_empty():
		question_types = ["presence"]
	_shuffle(question_types, rng)
	for type_value: Variant in question_types:
		var question_type := str(type_value)
		var result: Dictionary = {}
		match question_type:
			"count": result = _question_count(objects, rng)
			"attribute": result = _question_attribute(objects, rng)
			"position": result = _question_position(objects, rng)
			"adjacency": result = _question_adjacency(objects, rng)
			"presence": result = _question_presence(objects, pool, rng)
		if not result.is_empty():
			result["type"] = question_type
			return result
	return {}

func _question_count(objects: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var grouped: Dictionary = {}
	for object_data: Dictionary in objects:
		for group_value: Variant in object_data.get("groups", []):
			var group := str(group_value)
			if group in ["decoration", "personal", "accessory", "preparation", "measurement", "equipment"]:
				continue
			if not grouped.has(group):
				grouped[group] = []
			(grouped[group] as Array).append(object_data)
	var candidates: Array[String] = []
	for group: String in grouped.keys():
		var group_count := (grouped[group] as Array).size()
		if group_count >= 2 and group_count <= 5:
			candidates.append(group)
	if candidates.is_empty():
		return {}
	var selected_group := candidates[rng.randi_range(0, candidates.size() - 1)]
	var members: Array = grouped[selected_group]
	var correct := members.size()
	var options := _count_options(correct, rng)
	return {
		"question": {"type": "single_choice", "prompt": "How many %s were visible?" % _friendly_group(selected_group)},
		"options": options,
		"correct": str(correct),
		"explanation": "There were %d %s in the scene." % [correct, _friendly_group(selected_group)],
		"where_to_look": "the highlighted %s" % _friendly_group(selected_group),
		"highlight_ids": _ids_from_objects(members)
	}

func _question_attribute(objects: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var candidates: Array[Dictionary] = []
	for object_data: Dictionary in objects:
		var available: Variant = object_data.get("available_colors", [])
		if available is Array and (available as Array).size() >= 2:
			candidates.append(object_data)
	if candidates.is_empty():
		return {}
	var target := candidates[rng.randi_range(0, candidates.size() - 1)]
	var correct := str(target.get("color_label", "Blue"))
	var labels: Array[String] = []
	for color_data: Dictionary in COLORS.values():
		var label := str(color_data.get("label", ""))
		if label != correct and not labels.has(label):
			labels.append(label)
	_shuffle(labels, rng)
	var options: Array[String] = [correct]
	for label: String in labels.slice(0, 3):
		options.append(label)
	_shuffle(options, rng)
	return {
		"question": {"type": "single_choice", "prompt": "What color was the %s?" % target.get("name", "object")},
		"options": options,
		"correct": correct,
		"explanation": "The %s was %s." % [target.get("name", "object"), correct.to_lower()],
		"where_to_look": "the highlighted %s" % target.get("name", "object"),
		"highlight_ids": [target.get("instance_id", "")]
	}

func _question_position(objects: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var candidates: Array[Dictionary] = []
	for object_data: Dictionary in objects:
		var x := float(object_data.get("x", 0.5))
		if x < 0.38 or x > 0.62:
			candidates.append(object_data)
	if candidates.is_empty():
		return {}
	var target := candidates[rng.randi_range(0, candidates.size() - 1)]
	var correct := "Left" if float(target.get("x", 0.5)) < 0.5 else "Right"
	return {
		"question": {"type": "single_choice", "prompt": "Which side of the scene was the %s on?" % target.get("name", "object")},
		"options": ["Left", "Right"],
		"correct": correct,
		"explanation": "The %s was on the %s side." % [target.get("name", "object"), correct.to_lower()],
		"where_to_look": "the highlighted %s" % target.get("name", "object"),
		"highlight_ids": [target.get("instance_id", "")]
	}

func _question_adjacency(objects: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var candidates: Array[Dictionary] = []
	for target: Dictionary in objects:
		var distances: Array[Dictionary] = []
		var target_pos := Vector2(float(target.get("x", 0.5)), float(target.get("y", 0.5)))
		for neighbor: Dictionary in objects:
			if neighbor.get("instance_id") == target.get("instance_id"):
				continue
			var neighbor_pos := Vector2(float(neighbor.get("x", 0.5)), float(neighbor.get("y", 0.5)))
			distances.append({"object": neighbor, "distance": target_pos.distance_to(neighbor_pos)})
		distances.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["distance"]) < float(b["distance"]))
		if distances.size() >= 2 and float(distances[1]["distance"]) - float(distances[0]["distance"]) >= 0.035:
			var candidate := target.duplicate(true)
			candidate["nearest"] = distances[0]["object"]
			candidates.append(candidate)
	if candidates.is_empty():
		return {}
	var target := candidates[rng.randi_range(0, candidates.size() - 1)]
	var nearest: Dictionary = target.get("nearest", {})
	var correct := str(nearest.get("name", "object"))
	var distractors: Array[String] = []
	for object_data: Dictionary in objects:
		var name := str(object_data.get("name", "object"))
		if name != correct and name != str(target.get("name", "")) and not distractors.has(name):
			distractors.append(name)
	_shuffle(distractors, rng)
	if distractors.size() < 2:
		return {}
	var options: Array[String] = [correct]
	for value: String in distractors.slice(0, mini(3, distractors.size())):
		options.append(value)
	_shuffle(options, rng)
	return {
		"question": {"type": "single_choice", "prompt": "Which object was closest to the %s?" % target.get("name", "object")},
		"options": options,
		"correct": correct,
		"explanation": "The %s was closest to the %s." % [correct, target.get("name", "object")],
		"where_to_look": "the highlighted object pair",
		"highlight_ids": [target.get("instance_id", ""), nearest.get("instance_id", "")]
	}

func _question_presence(objects: Array[Dictionary], pool: Array, rng: RandomNumberGenerator) -> Dictionary:
	if objects.is_empty():
		return {}
	var target := objects[rng.randi_range(0, objects.size() - 1)]
	var present_ids: Dictionary = {}
	for object_data: Dictionary in objects:
		present_ids[str(object_data.get("archetype_id", ""))] = true
	var absent_names: Array[String] = []
	for raw_object: Variant in pool:
		if raw_object is Dictionary:
			var object_data: Dictionary = raw_object
			if not present_ids.has(str(object_data.get("id", ""))):
				absent_names.append(str(object_data.get("name", "object")))
	_shuffle(absent_names, rng)
	if absent_names.size() < 3:
		return {}
	var correct := str(target.get("name", "object"))
	var options: Array[String] = [correct, absent_names[0], absent_names[1], absent_names[2]]
	_shuffle(options, rng)
	return {
		"question": {"type": "single_choice", "prompt": "Which object appeared in the scene?"},
		"options": options,
		"correct": correct,
		"explanation": "The %s appeared in the scene." % correct,
		"where_to_look": "the highlighted %s" % correct,
		"highlight_ids": [target.get("instance_id", "")]
	}

func _count_options(correct: int, rng: RandomNumberGenerator) -> Array[String]:
	var values: Array[int] = [correct]
	for offset: int in [-2, -1, 1, 2, 3]:
		var value := correct + offset
		if value >= 1 and not values.has(value):
			values.append(value)
	_shuffle(values, rng)
	var selected := values.slice(0, mini(4, values.size()))
	if not selected.has(correct):
		selected[0] = correct
	_shuffle(selected, rng)
	var output: Array[String] = []
	for value: int in selected:
		output.append(str(value))
	return output

func _friendly_group(group: String) -> String:
	return {
		"document": "documents",
		"writing": "writing tools",
		"container": "containers",
		"device": "devices",
		"food": "food items",
		"fruit": "pieces of fruit",
		"utensil": "utensils",
		"appliance": "appliances",
		"tool": "tools",
		"hardware": "hardware pieces",
		"safety": "safety items",
		"material": "materials",
		"travel_document": "travel documents",
		"travel_gear": "travel items",
		"garden_tool": "garden tools",
		"plant_care": "plant care items"
	}.get(group, group.replace("_", " "))

func _ids_from_objects(objects: Array) -> Array[String]:
	var ids: Array[String] = []
	for value: Variant in objects:
		if value is Dictionary:
			ids.append(str((value as Dictionary).get("instance_id", "")))
	return ids

func _choose_color(
	allowed_colors: Array,
	scene_palette: Array,
	similarity: float,
	rng: RandomNumberGenerator
) -> String:
	if similarity > 0.3 and rng.randf() < similarity:
		for palette_color: Variant in scene_palette:
			if allowed_colors.has(palette_color):
				return str(palette_color)
	return str(allowed_colors[rng.randi_range(0, allowed_colors.size() - 1)])

func _size_for_kind(kind: String) -> Vector2:
	if _is_long_kind(kind):
		return Vector2(0.135, 0.055)
	if kind in ["plant", "lamp", "bottle", "kettle", "drill", "watering_can", "basket", "pot"]:
		return Vector2(0.105, 0.105)
	return Vector2(0.105, 0.090)

func _is_long_kind(kind: String) -> bool:
	return kind in ["pencil", "pen", "marker", "ruler", "spoon", "fork", "whisk", "hammer", "screwdriver", "wrench", "pliers", "brush", "flashlight", "clamp", "level", "scissors", "spatula", "saw", "trowel", "magnifier"]

func _shuffle(array: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(array.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var swap_value: Variant = array[index]
		array[index] = array[swap_index]
		array[swap_index] = swap_value

func _scene_signature(template_id: String, objects: Array[Dictionary], question: Dictionary) -> String:
	var compact_objects: Array[Dictionary] = []
	for object_data: Dictionary in objects:
		compact_objects.append({
			"id": object_data.get("archetype_id", ""),
			"color": object_data.get("color_name", ""),
			"x": snappedf(float(object_data.get("x", 0.0)), 0.01),
			"y": snappedf(float(object_data.get("y", 0.0)), 0.01)
		})
	var payload := JSON.stringify({
		"template_id": template_id,
		"objects": compact_objects,
		"question": question.get("question", {}),
		"correct": question.get("correct", null)
	})
	return payload.sha256_text()

extends ChallengeGenerator
class_name SpotDifferenceGenerator
## Seeded base/clone/mutation generator with exactly one semantic changed target.

const VERSION := "2"
const CONTENT_VERSION := "spot-difference-v2"
const RENDERER_SCRIPT := "res://src/LegacyMechanics/spot_the_difference/SpotDifferenceView.gd"
const OBJECTS: Array[Dictionary] = [
	{"id":"mug","name":"mug","kind":"cup"}, {"id":"book","name":"book","kind":"book"},
	{"id":"lamp","name":"lamp","kind":"lamp"}, {"id":"plant","name":"plant","kind":"plant"},
	{"id":"clock","name":"clock","kind":"clock"}, {"id":"bottle","name":"bottle","kind":"bottle"},
	{"id":"folder","name":"folder","kind":"book"}, {"id":"keys","name":"keys","kind":"key"},
	{"id":"camera","name":"camera","kind":"camera"}, {"id":"hat","name":"hat","kind":"hat"},
	{"id":"apple","name":"apple","kind":"fruit"}, {"id":"vase","name":"vase","kind":"vase"},
	{"id":"brush","name":"brush","kind":"line"}, {"id":"glasses","name":"glasses","kind":"glasses"},
	{"id":"notebook","name":"notebook","kind":"book"}, {"id":"spoon","name":"spoon","kind":"line"},
	{"id":"bell","name":"bell","kind":"bell"}, {"id":"leaf","name":"leaf","kind":"leaf"},
	{"id":"star","name":"star","kind":"star"}, {"id":"shell","name":"shell","kind":"shell"},
	{"id":"pencil","name":"pencil","kind":"line"}, {"id":"watch","name":"watch","kind":"clock"},
	{"id":"wheel","name":"wheel","kind":"ring"}, {"id":"anchor","name":"anchor","kind":"anchor"},
	{"id":"feather","name":"feather","kind":"leaf"}, {"id":"glove","name":"glove","kind":"glove"},
	{"id":"moon","name":"moon","kind":"moon"}, {"id":"kite","name":"kite","kind":"diamond"},
	{"id":"compass","name":"compass","kind":"compass"}, {"id":"ring","name":"ring","kind":"ring"},
	{"id":"umbrella","name":"umbrella","kind":"umbrella"}, {"id":"boat","name":"boat","kind":"boat"},
	{"id":"ribbon","name":"ribbon","kind":"ribbon"}, {"id":"magnet","name":"magnet","kind":"magnet"},
	{"id":"whistle","name":"whistle","kind":"pill"}, {"id":"acorn","name":"acorn","kind":"acorn"},
	{"id":"candle","name":"candle","kind":"pill"}, {"id":"scissors","name":"scissors","kind":"scissors"},
	{"id":"comb","name":"comb","kind":"comb"}, {"id":"button","name":"button","kind":"circle"},
	{"id":"basket","name":"basket","kind":"basket"}, {"id":"boot","name":"boot","kind":"boot"},
	{"id":"gem","name":"gem","kind":"diamond"}, {"id":"map","name":"map","kind":"book"},
	{"id":"drum","name":"drum","kind":"drum"}, {"id":"flag","name":"flag","kind":"flag"},
	{"id":"cloud","name":"cloud","kind":"cloud"}, {"id":"flower","name":"flower","kind":"flower"}
]
const COLORS := ["#5B7FD0", "#C96854", "#4E9A72", "#C7A548", "#8A68C5", "#4F9B9B", "#D17B9E", "#7B8290"]
const THEMES: Array[Dictionary] = [
	{"id":"paper","background":"#EEE9DE","surface":"#E2D8C5","line":"#766F82","accent":"#B99A62"},
	{"id":"slate","background":"#DCE2E6","surface":"#CBD4D9","line":"#596B75","accent":"#6D8D9C"},
	{"id":"mint","background":"#DFE9E1","surface":"#CEDCCF","line":"#58705F","accent":"#799B81"},
	{"id":"lilac","background":"#E7E0EC","surface":"#D8CCE2","line":"#6E607A","accent":"#927BA3"}
]
const ROTATION_KINDS := ["line", "leaf", "anchor", "umbrella", "boat", "flag", "boot", "comb", "scissors"]

func get_version() -> String:
	return VERSION

func generate(
	template: ChallengeTemplate,
	difficulty: Dictionary,
	exposure_duration_sec: float,
	seed_value: int
) -> ChallengeInstance:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var axes: Dictionary = difficulty.get("axes", {})
	var count: int = rng.randi_range(int(axes.get("object_count_min", 5)), int(axes.get("object_count_max", 7)))
	count = mini(count, 14)
	var definition_pool: Array = OBJECTS.duplicate(true)
	_shuffle(definition_pool, rng)
	var cells: Array = range(16)
	_shuffle(cells, rng)
	var used_cells: Array[int] = []
	var objects_a: Array[Dictionary] = []
	for index: int in range(count):
		var definition: Dictionary = definition_pool[index]
		var cell_index := int(cells[index])
		used_cells.append(cell_index)
		var position := _cell_position(cell_index, rng)
		objects_a.append({
			"instance_id": "obj_%02d" % index,
			"archetype_id": definition.get("id", "object"),
			"name": definition.get("name", "object"),
			"kind": definition.get("kind", "box"),
			"color": COLORS[rng.randi_range(0, COLORS.size() - 1)],
			"cell": cell_index,
			"x": position.x,
			"y": position.y,
			"w": float(axes.get("target_size", 0.15)),
			"h": float(axes.get("target_size", 0.15)),
			"state": 0,
			"rotation": 0.0
		})
	var objects_b: Array[Dictionary] = objects_a.duplicate(true)
	var target_index: int = rng.randi_range(0, objects_a.size() - 1)
	var target_a: Dictionary = objects_a[target_index]
	var target_b: Dictionary = objects_b[target_index]
	var mode: String = str(template.metadata.get("mode", "presence"))
	var mutation := mode
	match mode:
		"presence":
			objects_b.remove_at(target_index)
			mutation = "presence"
		"attribute":
			mutation = _mutate_attribute(target_b, axes, rng)
			objects_b[target_index] = target_b
		"sequential":
			var choices: Array[String] = ["mark", "rotation", "presence"]
			if not bool(axes.get("color_assist_mode", false)):
				choices.append("color")
			mutation = choices[rng.randi_range(0, choices.size() - 1)]
			if mutation == "presence":
				objects_b.remove_at(target_index)
			elif mutation == "rotation" and ROTATION_KINDS.has(str(target_b.get("kind", ""))):
				target_b["rotation"] = 90.0
				objects_b[target_index] = target_b
			elif mutation == "color":
				target_b["color"] = _different_color(str(target_b.get("color", COLORS[0])), rng)
				objects_b[target_index] = target_b
			else:
				mutation = "mark"
				target_b["state"] = 1
				objects_b[target_index] = target_b
		"arrangement":
			var empty_cells: Array[int] = []
			for cell_index: int in range(16):
				if not used_cells.has(cell_index):
					empty_cells.append(cell_index)
			var destination: int = empty_cells[rng.randi_range(0, empty_cells.size() - 1)]
			var moved_position := _cell_position(destination, rng)
			target_b["cell"] = destination
			target_b["x"] = moved_position.x
			target_b["y"] = moved_position.y
			objects_b[target_index] = target_b
			mutation = "arrangement"

	var target_id := str(target_a.get("instance_id", ""))
	var target_name := str(target_a.get("name", "object"))
	var regions: Array[Dictionary] = [_panel_region(target_a, false)]
	regions.append(_panel_region(target_b if mutation != "presence" else target_a, true))
	var options: Array[String] = [target_name.capitalize()]
	for object_data: Dictionary in objects_a:
		var candidate_name := str(object_data.get("name", "")).capitalize()
		if candidate_name != target_name.capitalize() and not options.has(candidate_name):
			options.append(candidate_name)
			if options.size() >= 4:
				break
	_shuffle(options, rng)
	var theme: Dictionary = THEMES[rng.randi_range(0, THEMES.size() - 1)].duplicate(true)
	var signature: String = JSON.stringify({
		"template": template.template_id,
		"a": objects_a,
		"b": objects_b,
		"target": target_id,
		"mutation": mutation,
		"theme": theme.get("id", "paper")
	}).sha256_text()
	var generated_scene := {
		"template_id": template.template_id,
		"renderer_script": RENDERER_SCRIPT,
		"mode": "sequential" if mode == "sequential" else "side_by_side",
		"objects_a": objects_a,
		"objects_b": objects_b,
		"state_duration": float(axes.get("state_duration", 2.5)),
		"theme": theme,
		"target_regions": regions,
		"scene_signature": signature
	}
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
		"generated_scene": generated_scene,
		"question": {"type": "spatial_tap", "prompt": "Tap the detail that changed."},
		"answer_options": options,
		"correct_answer": target_id,
		"explanation": _explanation(target_name, mutation),
		"metadata": {
			"progress_key": template.family_id,
			"question_type": mutation,
			"target_id": target_id,
			"target_name": target_name,
			"target_regions": regions,
			"where_to_look": "the highlighted %s in both states" % target_name,
			"scene_signature": signature,
			"interaction_data": {"regions": _region_options(objects_a)}
		}
	})

func _mutate_attribute(target: Dictionary, axes: Dictionary, rng: RandomNumberGenerator) -> String:
	var use_color := not bool(axes.get("color_assist_mode", false)) and rng.randf() < 0.45
	if use_color:
		target["color"] = _different_color(str(target.get("color", COLORS[0])), rng)
		return "color"
	target["state"] = 1
	return "mark"

func _different_color(current: String, rng: RandomNumberGenerator) -> String:
	var candidates: Array = COLORS.duplicate()
	candidates.erase(current)
	return str(candidates[rng.randi_range(0, candidates.size() - 1)])

func _cell_position(cell_index: int, rng: RandomNumberGenerator) -> Vector2:
	var column := cell_index % 4
	var row := floori(float(cell_index) / 4.0)
	return Vector2(
		0.14 + float(column) * 0.24 + rng.randf_range(-0.015, 0.015),
		0.17 + float(row) * 0.23 + rng.randf_range(-0.015, 0.015)
	)

func _explanation(target_name: String, mutation: String) -> String:
	match mutation:
		"presence":
			return "The %s disappeared between the two states." % target_name
		"color":
			return "The %s changed color." % target_name
		"mark":
			return "The %s gained a center mark." % target_name
		"rotation":
			return "The %s turned between the two states." % target_name
		"arrangement":
			return "The %s moved to a different position." % target_name
		_:
			return "The %s was the one detail that changed." % target_name

func _panel_region(object_data: Dictionary, panel_b: bool) -> Dictionary:
	var panel_left: float = 0.52 if panel_b else 0.03
	var panel_width: float = 0.45
	var x: float = panel_left + float(object_data.get("x", 0.5)) * panel_width
	var y: float = 0.10 + float(object_data.get("y", 0.5)) * 0.84
	var w: float = maxf(float(object_data.get("w", 0.14)) * panel_width, 0.07)
	var h: float = maxf(float(object_data.get("h", 0.14)) * 0.84, 0.08)
	var left: float = clampf(x - w * 0.65, 0.0, 0.94)
	var top: float = clampf(y - h * 0.65, 0.0, 0.92)
	var right: float = clampf(x + w * 0.65, left + 0.05, 1.0)
	var bottom: float = clampf(y + h * 0.65, top + 0.05, 1.0)
	return {"x": left, "y": top, "w": right - left, "h": bottom - top}

func _region_options(objects: Array[Dictionary]) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for object_data: Dictionary in objects:
		output.append({
			"id": object_data.get("instance_id", ""),
			"label": str(object_data.get("name", "Object")).capitalize()
		})
	return output

func _shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var swap_value: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = swap_value

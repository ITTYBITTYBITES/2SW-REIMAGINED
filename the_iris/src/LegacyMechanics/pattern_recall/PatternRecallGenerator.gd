extends ChallengeGenerator
class_name PatternRecallGenerator
## Seeded generator for connected grid paths and reviewed geometric symbols.

const VERSION := "2"
const CONTENT_VERSION := "pattern-recall-v2"
const RENDERER_SCRIPT := "res://src/LegacyMechanics/pattern_recall/PatternRecallView.gd"
const SYMBOLS: Array[Dictionary] = [
	{"token": "Circle", "kind": "circle"},
	{"token": "Triangle", "kind": "triangle"},
	{"token": "Square", "kind": "square"},
	{"token": "Diamond", "kind": "diamond"},
	{"token": "Plus", "kind": "plus"},
	{"token": "Star", "kind": "star"},
	{"token": "Ring", "kind": "ring"},
	{"token": "Cross", "kind": "cross"},
	{"token": "Hexagon", "kind": "hexagon"},
	{"token": "Wave", "kind": "wave"},
	{"token": "Bars", "kind": "bars"},
	{"token": "Arc", "kind": "arc"}
]

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
	var grid_size: int = clampi(int(axes.get("grid_size", 3)), 3, 4)
	var length: int = clampi(int(axes.get("sequence_length", 3)), 3, 6)
	var mode: String = str(template.metadata.get("mode", "grid"))
	var presentation_style := str(template.metadata.get("presentation_style", "single_step"))
	var tokens: Array[String] = []
	var sequence: Array[String] = []
	var symbol_kinds: Dictionary = {}
	if mode == "shapes":
		for symbol: Dictionary in SYMBOLS:
			var token := str(symbol.get("token", "Shape"))
			tokens.append(token)
			symbol_kinds[token] = str(symbol.get("kind", "circle"))
		sequence = _shape_sequence(length, rng)
	else:
		for row: int in range(grid_size):
			for column: int in range(grid_size):
				tokens.append("%s%d" % [char(65 + row), column + 1])
		sequence = _connected_path(grid_size, length, rng)
	if sequence.size() != length:
		return null
	var signature: String = JSON.stringify({
		"template": template.template_id,
		"sequence": sequence,
		"grid": grid_size,
		"style": presentation_style
	}).sha256_text()
	var interval: float = float(axes.get("interval", 0.8))
	var explanation := (
		"The shape sequence was %s." % " → ".join(sequence)
		if mode == "shapes"
		else "The ordered path was %s." % " → ".join(sequence)
	)
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
			"mode": mode,
			"presentation_style": presentation_style,
			"grid_size": grid_size,
			"tokens": tokens,
			"symbol_kinds": symbol_kinds,
			"sequence": sequence,
			"interval": interval,
			"final_hold": float(axes.get("final_hold", 0.35)),
			"scene_signature": signature
		},
		"question": {"type": "sequence_input", "prompt": "Repeat the pattern in the same order."},
		"answer_options": tokens,
		"correct_answer": sequence,
		"explanation": explanation,
		"metadata": {
			"progress_key": template.family_id,
			"question_type": mode,
			"presented_sequence": sequence.duplicate(),
			"where_to_look": "the numbered sequence evidence",
			"scene_signature": signature,
			"interaction_data": {"tokens": tokens, "required_length": sequence.size()}
		}
	})

func _shape_sequence(length: int, rng: RandomNumberGenerator) -> Array[String]:
	var output: Array[String] = []
	for _index: int in range(length):
		var candidates: Array[Dictionary] = SYMBOLS.duplicate(true)
		_shuffle(candidates, rng)
		for symbol: Dictionary in candidates:
			var token := str(symbol.get("token", "Shape"))
			if output.is_empty() or output.back() != token:
				output.append(token)
				break
	return output

func _connected_path(grid_size: int, length: int, rng: RandomNumberGenerator) -> Array[String]:
	for _attempt: int in range(50):
		var cells: Array[Vector2i] = []
		var used: Dictionary = {}
		var current := Vector2i(rng.randi_range(0, grid_size - 1), rng.randi_range(0, grid_size - 1))
		cells.append(current)
		used[_cell_key(current)] = true
		while cells.size() < length:
			var neighbors: Array[Vector2i] = []
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var candidate := current + direction
				if candidate.x >= 0 and candidate.x < grid_size and candidate.y >= 0 and candidate.y < grid_size and not used.has(_cell_key(candidate)):
					neighbors.append(candidate)
			if neighbors.is_empty():
				break
			current = neighbors[rng.randi_range(0, neighbors.size() - 1)]
			cells.append(current)
			used[_cell_key(current)] = true
		if cells.size() == length:
			var output: Array[String] = []
			for cell: Vector2i in cells:
				output.append("%s%d" % [char(65 + cell.y), cell.x + 1])
			return output
	return []

func _cell_key(cell: Vector2i) -> String:
	return "%d:%d" % [cell.x, cell.y]

func _shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var swap_value: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = swap_value

extends ChallengeGenerator
class_name FlashWordsGenerator
## Seeded generator for Single Word, Pair Order, and Word Stream templates.

const VERSION: String = "2"
const CONTENT_VERSION: String = "flash-words-en-v2"
const RENDERER_SCRIPT: String = "res://src/LegacyMechanics/flash_words/FlashWordsSceneView.gd"

func get_version() -> String:
	return VERSION

func generate(template: ChallengeTemplate, difficulty: Dictionary, exposure_duration_sec: float, seed_value: int) -> ChallengeInstance:
	var words_value: Variant = template.metadata.get("word_entries", [])
	if not (words_value is Array) or (words_value as Array).is_empty():
		return null
	var entries: Array = words_value
	var axes: Dictionary = difficulty.get("axes", {})
	var mode := str(template.metadata.get("mode", "single"))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var eligible := _eligible_words(entries, axes)
	var sequence_length := int(axes.get("sequence_length", 1))
	if eligible.size() < sequence_length + 4:
		eligible = entries.duplicate(true)
	var presented := _choose_unique(eligible, sequence_length, rng)
	if presented.size() != sequence_length:
		return null
	var generation_axes := axes.duplicate(true)
	var allowed_value: Variant = template.distractor_rules.get("allowed", [])
	if allowed_value is Array:
		var allowed: Array = allowed_value
		var requested_value: Variant = generation_axes.get("distractor_categories", [])
		var requested: Array = requested_value if requested_value is Array else []
		var filtered: Array[String] = []
		for category: Variant in requested:
			var normalized := "substitution" if str(category) == "single_substitution" else str(category)
			if allowed.has(normalized) or (normalized == "substitution" and allowed.has("single_substitution")):
				filtered.append(normalized)
		if not filtered.is_empty():
			generation_axes["distractor_categories"] = filtered
	var question_data := _build_question(mode, presented, eligible, generation_axes, rng)
	if question_data.is_empty():
		return null
	var display_duration := float(axes.get("display_duration", 2.0))
	var interval := float(axes.get("inter_word_interval", 0.0))
	var presented_words := _word_strings(presented)
	var scene_signature := JSON.stringify({
		"template": template.template_id,
		"words": presented_words,
		"question": question_data.get("question", {}),
		"correct": question_data.get("correct", "")
	}).sha256_text()
	var generated_scene := {
		"title": template.title,
		"template_id": template.template_id,
		"renderer_script": RENDERER_SCRIPT,
		"mode": mode,
		"words": presented_words,
		"display_duration": display_duration,
		"inter_word_interval": interval,
		"reading_comfort_mode": bool(axes.get("reading_comfort_mode", false)),
		"scene_signature": scene_signature
	}
	return ChallengeInstance.new({
		"instance_id": "%s:%s:%d" % [template.family_id, template.template_id, seed_value],
		"family_id": template.family_id,
		"family_version": str(template.metadata.get("family_version", "1")),
		"template_id": template.template_id,
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
		"question": question_data.get("question", {}),
		"answer_options": question_data.get("options", []),
		"correct_answer": question_data.get("correct", null),
		"explanation": question_data.get("explanation", ""),
		"validation_metadata": {"candidate": "procedural_words"},
		"metadata": {
			"content_role": "production",
			"progress_key": "flash_words",
			"mode": mode,
			"question_type": question_data.get("type", "unknown"),
			"presented_words": presented_words,
			"target_position": question_data.get("target_position", -1),
			"distractor_categories": axes.get("distractor_categories", []),
			"scene_signature": scene_signature
		}
	})

func _eligible_words(entries: Array, axes: Dictionary) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var minimum := int(axes.get("word_length_min", 3))
	var maximum := int(axes.get("word_length_max", 8))
	var recent_value: Variant = axes.get("recent_words", [])
	var recent: Array = recent_value if recent_value is Array else []
	for value: Variant in entries:
		if value is Dictionary:
			var entry: Dictionary = value
			var length := int(entry.get("length", 0))
			var word := str(entry.get("word", ""))
			if bool(entry.get("safe", false)) and length >= minimum and length <= maximum and not recent.has(word):
				output.append(entry)
	return output

func _choose_unique(pool: Array, count: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var copy := pool.duplicate(true)
	_shuffle(copy, rng)
	var selected: Array[Dictionary] = []
	var ids: Dictionary = {}
	for value: Variant in copy:
		if value is Dictionary:
			var entry: Dictionary = value
			var word_id := str(entry.get("id", ""))
			if not ids.has(word_id):
				selected.append(entry)
				ids[word_id] = true
				if selected.size() >= count:
					break
	return selected

func _build_question(mode: String, presented: Array[Dictionary], pool: Array, axes: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	match mode:
		"pair": return _pair_question(presented, pool, axes, rng)
		"stream": return _stream_question(presented, pool, axes, rng)
		"position": return _position_question(presented, pool, axes, rng)
		_: return _single_question(presented[0], pool, axes, rng)

func _single_question(correct_entry: Dictionary, pool: Array, axes: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var correct := str(correct_entry.get("word", ""))
	var distractors := _distractors(correct_entry, pool, axes, 3, rng)
	if distractors.size() < 3:
		return {}
	var options: Array[String] = [correct]
	options.append_array(distractors)
	_shuffle(options, rng)
	return {
		"type": "word_recognition",
		"question": {"type": "single_choice", "prompt": "Which word appeared?"},
		"options": options,
		"correct": correct,
		"explanation": "The flashed word was %s." % correct,
		"target_position": 0
	}

func _pair_question(presented: Array[Dictionary], pool: Array, axes: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if presented.size() != 2:
		return {}
	var first := str(presented[0].get("word", ""))
	var second := str(presented[1].get("word", ""))
	var correct := "%s → %s" % [first, second]
	var options: Array[String] = [correct, "%s → %s" % [second, first]]
	var first_distractors := _distractors(presented[0], pool, axes, 2, rng)
	var second_distractors := _distractors(presented[1], pool, axes, 2, rng)
	if not first_distractors.is_empty():
		options.append("%s → %s" % [first_distractors[0], second])
	if not second_distractors.is_empty():
		options.append("%s → %s" % [first, second_distractors[0]])
	options = _unique_strings(options)
	if options.size() < 4:
		return {}
	options = options.slice(0, 4)
	_shuffle(options, rng)
	return {
		"type": "pair_order",
		"question": {"type": "single_choice", "prompt": "Which pair appeared, in order?"},
		"options": options,
		"correct": correct,
		"explanation": "The words appeared as %s." % correct,
		"target_position": 0
	}

func _stream_question(presented: Array[Dictionary], pool: Array, axes: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if presented.size() < 3:
		return {}
	var target_index := rng.randi_range(0, presented.size() - 1)
	var target: Dictionary = presented[target_index]
	var correct := str(target.get("word", ""))
	var presented_words := _word_strings(presented)
	var distractors := _distractors(target, pool, axes, 6, rng)
	var filtered: Array[String] = []
	for word: String in distractors:
		if not presented_words.has(word) and not filtered.has(word):
			filtered.append(word)
			if filtered.size() >= 3:
				break
	if filtered.size() < 3:
		return {}
	var options: Array[String] = [correct]
	options.append_array(filtered)
	_shuffle(options, rng)
	return {
		"type": "stream_presence",
		"question": {"type": "single_choice", "prompt": "Which word was in the sequence?"},
		"options": options,
		"correct": correct,
		"explanation": "%s appeared in position %d." % [correct, target_index + 1],
		"target_position": target_index
	}

func _position_question(presented: Array[Dictionary], pool: Array, axes: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if presented.size() < 3:
		return {}
	var target_index: int = rng.randi_range(0, presented.size() - 1)
	var target: Dictionary = presented[target_index]
	var correct := str(target.get("word", ""))
	var presented_words := _word_strings(presented)
	var candidates := _distractors(target, pool, axes, 8, rng)
	var filtered: Array[String] = []
	for word: String in candidates:
		if not presented_words.has(word) and not filtered.has(word):
			filtered.append(word)
			if filtered.size() >= 3:
				break
	if filtered.size() < 3:
		return {}
	var options: Array[String] = [correct]
	options.append_array(filtered)
	_shuffle(options, rng)
	return {
		"type": "position_recall",
		"question": {
			"type": "single_choice",
			"prompt": "Which word appeared in position %d?" % (target_index + 1)
		},
		"options": options,
		"correct": correct,
		"explanation": "Position %d held %s in the sequence." % [target_index + 1, correct],
		"target_position": target_index
	}

func _distractors(correct: Dictionary, pool: Array, axes: Dictionary, count: int, rng: RandomNumberGenerator) -> Array[String]:
	var correct_id := str(correct.get("id", ""))
	var correct_word := str(correct.get("word", ""))
	var categories_value: Variant = axes.get("distractor_categories", ["similar_length"])
	var categories: Array = categories_value if categories_value is Array else ["similar_length"]
	var neighbor_value: Variant = correct.get("orthographic_neighbors", [])
	var neighbor_ids: Array = neighbor_value if neighbor_value is Array else []
	var preferred: Array[String] = []
	var secondary: Array[String] = []
	for value: Variant in pool:
		if not (value is Dictionary):
			continue
		var entry: Dictionary = value
		var candidate_id := str(entry.get("id", ""))
		var candidate_word := str(entry.get("word", ""))
		if candidate_id == correct_id:
			continue
		if neighbor_ids.has(candidate_id):
			var category := "orthographic"
			if _is_transposition(correct_id, candidate_id):
				category = "transposition"
			elif _edit_distance(correct_id, candidate_id) == 1 and correct_id.length() == candidate_id.length():
				category = "substitution"
			if categories.has(category) or (category == "substitution" and categories.has("orthographic")):
				preferred.append(candidate_word)
				continue
		if categories.has("semantic") and str(entry.get("category", "")) == str(correct.get("category", "")):
			secondary.append(candidate_word)
		elif categories.has("similar_length") and abs(candidate_id.length() - correct_id.length()) <= 1:
			secondary.append(candidate_word)
	_shuffle(preferred, rng)
	_shuffle(secondary, rng)
	var output: Array[String] = []
	for word: String in preferred + secondary:
		if word != correct_word and not output.has(word):
			output.append(word)
			if output.size() >= count:
				return output
	var fallback: Array = pool.duplicate(true)
	_shuffle(fallback, rng)
	for value: Variant in fallback:
		if value is Dictionary:
			var word := str((value as Dictionary).get("word", ""))
			if word != correct_word and not output.has(word):
				output.append(word)
				if output.size() >= count:
					break
	return output

func _is_transposition(a: String, b: String) -> bool:
	if a.length() != b.length():
		return false
	for index: int in range(a.length() - 1):
		var swapped := a.substr(0, index) + a.substr(index + 1, 1) + a.substr(index, 1) + a.substr(index + 2)
		if swapped == b:
			return true
	return false

func _edit_distance(a: String, b: String) -> int:
	var previous: Array[int] = []
	for index: int in range(b.length() + 1):
		previous.append(index)
	for row: int in range(1, a.length() + 1):
		var current: Array[int] = [row]
		for column: int in range(1, b.length() + 1):
			var cost := 0 if a.substr(row - 1, 1) == b.substr(column - 1, 1) else 1
			current.append(mini(mini(current[column - 1] + 1, previous[column] + 1), previous[column - 1] + cost))
		previous = current
	return previous[-1]

func _word_strings(entries: Array[Dictionary]) -> Array[String]:
	var output: Array[String] = []
	for entry: Dictionary in entries:
		output.append(str(entry.get("word", "")))
	return output

func _unique_strings(values: Array[String]) -> Array[String]:
	var output: Array[String] = []
	for value: String in values:
		if not output.has(value):
			output.append(value)
	return output

func _shuffle(values: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var swap_value: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = swap_value

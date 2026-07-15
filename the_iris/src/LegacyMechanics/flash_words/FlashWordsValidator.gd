extends ChallengeValidator
class_name FlashWordsValidator
## Fairness validator for generated Flash Words instances.

const VERSION: String = "2"

func get_version() -> String:
	return VERSION

func validate(instance: ChallengeInstance) -> ChallengeValidationResult:
	if instance == null:
		return _reject("Generator returned no instance", "instance.missing")
	var errors := instance.get_contract_errors()
	if not errors.is_empty():
		return _reject("Instance contract is incomplete", "instance.contract", {"errors": errors})
	var scene := instance.generated_scene
	var mode := str(scene.get("mode", ""))
	if mode not in ["single", "pair", "stream", "position"]:
		return _reject("Unsupported Flash Words mode", "mode.unsupported")
	var words_value: Variant = scene.get("words", [])
	if not (words_value is Array):
		return _reject("Presented words are missing", "words.missing")
	var words: Array = words_value
	var expected_count := 1 if mode == "single" else 2 if mode == "pair" else int(instance.difficulty_axes.get("sequence_length", 3))
	if words.size() != expected_count:
		return _reject("Sequence length does not match policy", "sequence.length", {"expected": expected_count, "actual": words.size()})
	for word_value: Variant in words:
		var word := str(word_value)
		if word.length() < 2 or word.length() > 10 or not _letters_only(word):
			return _reject("Presented word is not display-safe", "word.display_safe", {"word": word})
	var unique_options: Dictionary = {}
	for option: Variant in instance.answer_options:
		unique_options[str(option)] = true
	if unique_options.size() != instance.answer_options.size():
		return _reject("Answer options contain duplicates", "answer.duplicate")
	if instance.answer_options.count(instance.correct_answer) != 1:
		return _reject("Exactly one correct answer is required", "answer.unique")
	if mode in ["stream", "position"]:
		var correct := str(instance.correct_answer)
		for option: Variant in instance.answer_options:
			var option_word := str(option)
			if option_word != correct and words.has(option_word):
				return _reject("Stream distractor was presented", "answer.presented_distractor")
	var display := float(scene.get("display_duration", 0.0))
	var interval := float(scene.get("inter_word_interval", 0.0))
	if display <= 0.0 or interval < 0.0:
		return _reject("Presentation timing is invalid", "timing.invalid")
	var expected_total := display * words.size() + interval * maxi(words.size() - 1, 0)
	if not is_equal_approx(expected_total, instance.exposure_duration_sec):
		return _reject("Total exposure does not match sequence timing", "timing.total")
	var renderer := str(scene.get("renderer_script", ""))
	if renderer.is_empty() or not ResourceLoader.exists(renderer):
		return _reject("Typography renderer is missing", "asset.renderer")
	if str(instance.metadata.get("scene_signature", "")).length() < 32:
		return _reject("Reproduction signature is missing", "reproduction.signature")
	return ChallengeValidationResult.accepted({
		"validator_version": VERSION,
		"rules_checked": [
			"instance.contract",
			"mode.supported",
			"sequence.length",
			"word.display_safe",
			"answer.duplicate",
			"answer.unique",
			"answer.presented_distractor",
			"timing.total",
			"asset.renderer",
			"reproduction.signature"
		]
	})

func _letters_only(word: String) -> bool:
	for index: int in range(word.length()):
		var code := word.unicode_at(index)
		if code < 65 or code > 90:
			return false
	return true

func _reject(reason: String, rule_id: String, details: Dictionary = {}) -> ChallengeValidationResult:
	return ChallengeValidationResult.rejected(reason, rule_id, details)

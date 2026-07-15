extends "res://src/experiences/ExperienceBase.gd"
## FlashwordExperience - Legacy foundation implementation retained for save compatibility.

var _words: Array[String] = []
var _current_word: String = ""
var _choices: Array[String] = []
var _start_time_ms: int = 0

const DEFAULT_WORDS := [
  "WITNESS", "OBSERVE", "MEMORY", "FOCUS", "GLANCE",
  "RECALL", "FLASH", "MOMENT", "QUICK", "SPARK",
  "DETAIL", "SHADOW", "LIGHT", "TRUTH", "CLUE",
  "SIGNAL", "NOTICE", "REACT", "MIND", "EYE"
]

func _init(exp_id: String = "flashword", manifest_data: Dictionary = {}):
	super._init(exp_id, manifest_data)
	_words = DEFAULT_WORDS.duplicate()

func start(params: Dictionary = {}) -> Dictionary:
	var diff: String = params.get("difficulty", "medium")
	_current_word = _pick_word(diff)
	_choices = _generate_choices(_current_word, 4)
	_start_time_ms = Time.get_ticks_msec()

	var session := {
		"exp_id": id,
		"word": _current_word,
		"choices": _choices,
		"difficulty": diff,
		"observation_ms": manifest.get("rules", {}).get("observation_ms", 2000),
		"recall_ms": manifest.get("rules", {}).get("recall_ms", 5000),
		"status": "observation"
	}

	is_active = true
	started.emit(id)

	return session

func submit_answer(answer: String) -> Dictionary:
	var elapsed := Time.get_ticks_msec() - _start_time_ms
	var correct: bool = (answer == _current_word)
	var base_points: int = manifest.get("scoring", {}).get("base_points", 10)
	var score: int = base_points if correct else 0

	# Speed bonus
	if correct:
		var max_time: int = manifest.get("rules", {}).get("recall_ms", 5000)
		var speed_factor: float = clamp(1.0 - (float(elapsed) / float(max_time)), 0.0, 1.0)
		score += int(speed_factor * 10)

	var result := {
		"exp_id": id,
		"correct": correct,
		"answer": answer,
		"expected": _current_word,
		"score": score,
		"reaction_ms": elapsed,
		"streak_bonus": 0
	}

	is_active = false
	completed.emit(id, result)

	# Record to profile
	if ProfileService:
		ProfileService.record_experience_play(id, result)


	return result

func _pick_word(_difficulty: String) -> String:
	if _words.is_empty():
		_words = DEFAULT_WORDS.duplicate()
	return _words[randi() % _words.size()]

func _generate_choices(correct: String, count: int) -> Array[String]:
	var pool := _words.duplicate()
	pool.erase(correct)
	pool.shuffle()

	var choices: Array[String] = [correct]
	while choices.size() < count and pool.size() > 0:
		var w: String = pool.pop_back()
		if not choices.has(w):
			choices.append(w)

	choices.shuffle()
	return choices

func load_word_list_from_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		_words = []
		for entry in parsed:
			if entry is String:
				_words.append(entry)
			elif entry is Dictionary and entry.has("word"):
				_words.append(entry["word"])
	elif parsed is Dictionary and parsed.has("words"):
		_words = parsed["words"]

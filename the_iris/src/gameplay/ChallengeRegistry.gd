extends Node
## ChallengeRegistry - Minimal playable challenge data + run management
## Powers the reusable Two Second Witness gameplay loop

signal challenges_loaded(challenges: Array)
signal registry_updated(challenges: Array)
signal run_started(challenge_ids: Array, start_id: String)

const CHALLENGES_PATH := "res://src/gameplay/challenges.json"

var _initialized: bool = false
var _manifest: Dictionary = {}
var _challenges: Dictionary = {}
var _ordered_ids: Array[String] = []

func _ready() -> void:
	pass

func initialize() -> void:
	if _initialized:
		return
	_load_registry()
	_initialized = true
	var all_challenges := get_all_challenges()
	challenges_loaded.emit(all_challenges)
	registry_updated.emit(all_challenges)

func _load_registry() -> void:
	_manifest = {}
	_challenges.clear()
	_ordered_ids.clear()

	if FileAccess.file_exists(CHALLENGES_PATH):
		var file := FileAccess.open(CHALLENGES_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_manifest = parsed

	if _manifest.is_empty():
		_manifest = _fallback_manifest()

	var sequence: Array = _manifest.get("default_sequence", [])
	for entry in sequence:
		var challenge_id := str(entry)
		if not _ordered_ids.has(challenge_id):
			_ordered_ids.append(challenge_id)

	var challenge_entries: Array = _manifest.get("challenges", [])
	for entry in challenge_entries:
		if entry is Dictionary:
			var challenge := _normalize_challenge(entry)
			var challenge_id: String = challenge.get("id", "")
			if challenge_id == "":
				continue
			_challenges[challenge_id] = challenge
			if not _ordered_ids.has(challenge_id):
				_ordered_ids.append(challenge_id)

func _fallback_manifest() -> Dictionary:
	return {
		"version": 1,
		"featured": "challenge_01",
		"default_sequence": ["challenge_01"],
		"challenges": [
			{
				"id": "challenge_01",
				"title": "Study Desk",
				"short_description": "A detailed desk scene with a green mug.",
				"description": "Observe the study desk and answer from memory.",
				"category": "observation",
				"tags": ["counting", "desk"],
				"estimated_duration_sec": 10,
				"preview_color": "#7C5CFF",
				"image_path": "res://assets/gameplay/observation_challenge_01.png",
				"question": "How many colored pencils were in the green mug?",
				"options": ["3", "4", "5", "6"],
				"correct": "5",
				"detail": "There were 5 writing tools in the green mug.",
				"is_locked": false,
				"coming_soon": false
			}
		]
	}

func _normalize_challenge(entry: Dictionary) -> Dictionary:
	var challenge := entry.duplicate(true)
	challenge["id"] = str(challenge.get("id", ""))
	challenge["title"] = str(challenge.get("title", challenge.get("id", "Challenge")))

	var default_short_desc := "Observe for 2 seconds, then answer from memory."
	var short_desc = challenge.get("description", default_short_desc)
	short_desc = challenge.get("short_description", short_desc)
	challenge["short_description"] = str(short_desc)

	var description = challenge.get("description", challenge.get("short_description", ""))
	challenge["description"] = str(description)
	challenge["category"] = str(challenge.get("category", "observation"))
	challenge["preview_color"] = str(challenge.get("preview_color", "#7C5CFF"))
	challenge["estimated_duration_sec"] = int(challenge.get("estimated_duration_sec", 10))
	challenge["image_path"] = str(challenge.get("image_path", ""))
	challenge["question"] = str(challenge.get("question", "What did you notice?"))
	challenge["correct"] = str(challenge.get("correct", ""))
	challenge["detail"] = str(challenge.get("detail", ""))
	challenge["is_locked"] = bool(challenge.get("is_locked", false))
	challenge["coming_soon"] = bool(challenge.get("coming_soon", false))
	if not challenge.has("tags") or not (challenge["tags"] is Array):
		challenge["tags"] = []
	if not challenge.has("options") or not (challenge["options"] is Array):
		challenge["options"] = []
	return challenge

func get_all_challenges() -> Array[Dictionary]:
	var ordered: Array[Dictionary] = []
	for challenge_id in _ordered_ids:
		if _challenges.has(challenge_id):
			ordered.append((_challenges[challenge_id] as Dictionary).duplicate(true))
	return ordered

func get_challenge(challenge_id: String) -> Dictionary:
	if _challenges.has(challenge_id):
		return (_challenges[challenge_id] as Dictionary).duplicate(true)
	return {}

func get_challenge_ids() -> Array[String]:
	return _ordered_ids.duplicate()

func get_default_challenge_id() -> String:
	if _ordered_ids.is_empty():
		return ""
	return _ordered_ids[0]

func get_featured_challenge() -> Dictionary:
	var featured_id: String = str(_manifest.get("featured", get_default_challenge_id()))
	var featured := get_challenge(featured_id)
	if featured.is_empty() and not _ordered_ids.is_empty():
		featured = get_challenge(_ordered_ids[0])
	return featured

func count() -> int:
	return _ordered_ids.size()

func build_run(start_id: String = "") -> Array[String]:
	var ids := get_challenge_ids()
	if ids.is_empty():
		return []
	var start := start_id if start_id != "" and ids.has(start_id) else ids[0]
	var start_index := ids.find(start)
	if start_index <= 0:
		return ids
	var run: Array[String] = []
	for i in range(start_index, ids.size()):
		run.append(ids[i])
	for i in range(0, start_index):
		run.append(ids[i])
	return run

func start_run(start_id: String = "") -> bool:
	var run_ids := build_run(start_id)
	if run_ids.is_empty():
		return false
	if AppState:
		AppState.set_transient("challenge_run_ids", run_ids)
		AppState.set_transient("challenge_run_index", 0)
	run_started.emit(run_ids, run_ids[0])
	return launch_challenge(run_ids[0])

func launch_challenge(challenge_id: String) -> bool:
	var challenge := get_challenge(challenge_id)
	if challenge.is_empty():
		return false
	if AppState:
		AppState.active_experience_id = challenge_id
		AppState.set_transient("current_challenge_id", challenge_id)
		AppState.set_transient("current_challenge", challenge)
		AppState.clear_transient("last_result")
		AppState.clear_transient("question_started_ms")
	if NavigationService:
		return NavigationService.navigate_to("observation", {
			"challenge_id": challenge_id,
			"challenge_data": challenge
		})
	return false

func replay_current() -> bool:
	var challenge_id := get_current_challenge_id()
	if challenge_id == "":
		challenge_id = get_default_challenge_id()
	return launch_challenge(challenge_id)

func go_to_next_challenge() -> bool:
	var run_ids: Array = AppState.get_transient("challenge_run_ids", []) if AppState else []
	if run_ids.is_empty():
		return start_run()
	var current_index: int = int(AppState.get_transient("challenge_run_index", 0)) if AppState else 0
	current_index += 1
	if current_index >= run_ids.size():
		current_index = 0
	if AppState:
		AppState.set_transient("challenge_run_index", current_index)
	var next_id := str(run_ids[current_index])
	return launch_challenge(next_id)

func get_current_challenge_id() -> String:
	if AppState:
		return str(AppState.get_transient("current_challenge_id", ""))
	return ""

func get_next_challenge_id() -> String:
	var run_ids: Array = AppState.get_transient("challenge_run_ids", []) if AppState else []
	if run_ids.is_empty():
		var ids := get_challenge_ids()
		if ids.size() <= 1:
			return get_default_challenge_id()

		var current := get_current_challenge_id()
		var idx := ids.find(current)
		if idx == -1:
			return ids[0]
		idx += 1
		if idx >= ids.size():
			idx = 0
		return ids[idx]
	var current_index: int = int(AppState.get_transient("challenge_run_index", 0)) if AppState else 0
	current_index += 1
	if current_index >= run_ids.size():
		current_index = 0
	return str(run_ids[current_index])

func get_run_position() -> Dictionary:
	var run_ids: Array = AppState.get_transient("challenge_run_ids", []) if AppState else []
	var index: int = int(AppState.get_transient("challenge_run_index", 0)) if AppState else 0
	return {
		"index": index,
		"total": run_ids.size(),
		"current_id": get_current_challenge_id(),
		"next_id": get_next_challenge_id()
	}

func clear_run() -> void:
	if AppState:
		AppState.clear_transient("challenge_run_ids")
		AppState.clear_transient("challenge_run_index")
		AppState.clear_transient("current_challenge_id")
		AppState.clear_transient("current_challenge")

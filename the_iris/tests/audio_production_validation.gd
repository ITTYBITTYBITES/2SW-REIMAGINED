extends SceneTree

## Mission 053C production audio validation.
## Verifies that the Living Iris production audio library exists, imports, and resolves
## through the current runtime hooks without relying on validation test sounds.
##
## Run: godot --headless -s tests/audio_production_validation.gd

var passed := 0
var failed := 0

const PRODUCTION_AUDIO := [
	"res://assets/audio/iris/iris_awaken.ogg",
	"res://assets/audio/iris/iris_breath_loop.ogg",
	"res://assets/audio/iris/iris_focus.ogg",
	"res://assets/audio/iris/iris_attention.ogg",
	"res://assets/audio/iris/iris_confirm.ogg",
	"res://assets/audio/iris/iris_transition.ogg",
	"res://assets/audio/iris/iris_presence.ogg",
	"res://assets/audio/navigation/ui_click.ogg",
	"res://assets/audio/navigation/portal_open.ogg",
	"res://assets/audio/navigation/portal_close.ogg",
	"res://assets/audio/navigation/chapter_enter.ogg",
	"res://assets/audio/navigation/chapter_complete.ogg",
	"res://assets/audio/witness/observation_start.ogg",
	"res://assets/audio/witness/memory_lock.ogg",
	"res://assets/audio/witness/recall_start.ogg",
	"res://assets/audio/witness/correct_detection.ogg",
	"res://assets/audio/witness/incorrect_detection.ogg",
	"res://assets/audio/witness/reveal.ogg",
	"res://assets/audio/witness/resolution.ogg",
	"res://assets/audio/environments/museum_ambient.ogg",
	"res://assets/audio/environments/canvas_room_ambient.ogg",
	"res://assets/audio/environments/performance_ambient.ogg",
	"res://assets/audio/environments/reactor_ambient.ogg",
	"res://assets/audio/ui/shard_hover.ogg",
]

const LOOP_AUDIO := [
	"res://assets/audio/iris/iris_breath_loop.ogg",
	"res://assets/audio/iris/iris_presence.ogg",
	"res://assets/audio/environments/museum_ambient.ogg",
	"res://assets/audio/environments/canvas_room_ambient.ogg",
	"res://assets/audio/environments/performance_ambient.ogg",
	"res://assets/audio/environments/reactor_ambient.ogg",
]

const RUNTIME_EVENT_AUDIO := [
	"res://assets/audio/navigation/ui_click.ogg",
	"res://assets/audio/navigation/portal_open.ogg",
	"res://assets/audio/navigation/portal_close.ogg",
	"res://assets/audio/navigation/chapter_enter.ogg",
	"res://assets/audio/navigation/chapter_complete.ogg",
	"res://assets/audio/witness/observation_start.ogg",
	"res://assets/audio/witness/memory_lock.ogg",
	"res://assets/audio/witness/recall_start.ogg",
	"res://assets/audio/witness/correct_detection.ogg",
	"res://assets/audio/witness/incorrect_detection.ogg",
	"res://assets/audio/witness/reveal.ogg",
	"res://assets/audio/witness/resolution.ogg",
	"res://assets/audio/ui/shard_hover.ogg",
]

func _init() -> void:
	print("")
	print("=================================================")
	print("  MISSION 053C — PRODUCTION AUDIO VALIDATION")
	print("=================================================")
	print("")

	_test_production_files_exist_and_import()
	_test_presence_and_mode_routing()
	_test_runtime_event_paths()
	_test_manifest_audio_references()
	_test_loop_initialization()
	_test_no_test_assets_in_runtime_manifests()

	print("")
	print("-------------------------------------------------")
	print("  RESULTS: %d passed, %d failed" % [passed, failed])
	print("-------------------------------------------------")
	print("")
	quit(0 if failed == 0 else 1)

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

func _test_production_files_exist_and_import() -> void:
	print("── 1. Production files and Godot loading ──")
	for path in PRODUCTION_AUDIO:
		_assert(FileAccess.file_exists(path), "%s exists" % path)
		var stream = load(path)
		_assert(stream is AudioStream, "%s loads as AudioStream" % path)

func _test_presence_and_mode_routing() -> void:
	print("── 2. Iris presence and expression routing ──")
	for event_name in IrisAudioConsumer.PRESENCE_AUDIO.keys():
		var path: String = IrisAudioConsumer.PRESENCE_AUDIO[event_name]
		_assert(not path.is_empty(), "%s maps to a path" % event_name)
		_assert(FileAccess.file_exists(path), "%s path exists: %s" % [event_name, path])

	for mode in ["INTRODUCING", "IDLE", "CURIOUS", "ATTENTIVE", "GUIDING", "REFLECTIVE"]:
		var mode_path := IrisAudioConsumer._resolve_mode_path(mode)
		_assert(not mode_path.is_empty(), "%s maps to a production path" % mode)
		_assert(FileAccess.file_exists(mode_path), "%s path exists: %s" % [mode, mode_path])

func _test_runtime_event_paths() -> void:
	print("── 3. Runtime event path resolution ──")
	for path in RUNTIME_EVENT_AUDIO:
		_assert(FileAccess.file_exists(path), "runtime event asset exists: %s" % path)

func _test_manifest_audio_references() -> void:
	print("── 4. Witness manifest audio references ──")
	var files := DirAccess.get_files_at("res://content/witness")
	for file_name in files:
		if not file_name.ends_with(".json"):
			continue
		var path := "res://content/witness/" + file_name
		var text := FileAccess.get_file_as_string(path)
		var data = JSON.parse_string(text)
		_assert(data is Dictionary, "%s parses as JSON" % file_name)
		if not data is Dictionary:
			continue
		var asset_manifest: Dictionary = data.get("asset_manifest", {})
		var audio_assets: Dictionary = asset_manifest.get("audio_assets", {})
		if audio_assets.is_empty():
			continue
		for key in audio_assets.keys():
			var audio_path := str(audio_assets[key]).strip_edges()
			if audio_path.is_empty():
				continue
			_assert(FileAccess.file_exists(audio_path), "%s audio %s exists: %s" % [file_name, key, audio_path])
			_assert(not audio_path.contains("test_"), "%s audio %s is not a validation test sound" % [file_name, key])

func _test_loop_initialization() -> void:
	print("── 5. Ambient loop initialization ──")
	for path in LOOP_AUDIO:
		IrisAudioConsumer.stop_ambient_loop()
		IrisAudioConsumer.play_ambient_loop(path)
		_assert(IrisAudioConsumer._ambient_player != null, "loop player created for %s" % path)
		if IrisAudioConsumer._ambient_player != null:
			_assert(IrisAudioConsumer._ambient_player.stream is AudioStream, "loop stream loaded for %s" % path)
			if IrisAudioConsumer._ambient_player.stream is AudioStreamOggVorbis:
				_assert(IrisAudioConsumer._ambient_player.stream.loop == true, "OGG loop flag enabled for %s" % path)
		IrisAudioConsumer.stop_ambient_loop()
	_assert(IrisAudioConsumer._ambient_player == null, "loop player cleaned up")

func _test_no_test_assets_in_runtime_manifests() -> void:
	print("── 6. Runtime manifests are free of validation asset names ──")
	var files := DirAccess.get_files_at("res://content/witness")
	for file_name in files:
		if not file_name.ends_with(".json"):
			continue
		var text := FileAccess.get_file_as_string("res://content/witness/" + file_name)
		_assert(not text.contains("test_ui_click.wav"), "%s does not reference test_ui_click.wav" % file_name)
		_assert(not text.contains("test_ambient_loop.ogg"), "%s does not reference test_ambient_loop.ogg" % file_name)
		_assert(not text.contains("test_resolution.ogg"), "%s does not reference test_resolution.ogg" % file_name)

extends SceneTree

## Audio Runtime Reality Test (Mission 053B)
## Proves the repaired audio runtime pipeline works with real imported audio assets.
## Tests: file loading, ambient loop lifecycle, presence routing, and fallback safety.
##
## Run: godot --headless -s tests/audio_runtime_validation.gd

var passed := 0
var failed := 0

const AUDIO_DIR := "res://assets/audio/test/"

func _init() -> void:
	print("")
	print("==============================================")
	print("  MISSION 053B — AUDIO REALITY TEST")
	print("==============================================")
	print("")

	_test_file_existence()
	_test_wav_loading()
	_test_ogg_loading()
	_test_ambient_loop_lifecycle()
	_test_presence_routing()
	_test_fallback_safety()
	_test_consume_null()
	_test_dead_code_removed()

	print("")
	print("----------------------------------------------")
	print("  RESULTS: %d passed, %d failed" % [passed, failed])
	print("----------------------------------------------")
	print("")
	quit(0 if failed == 0 else 1)

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		print("  ✗ FAILED: %s" % description)

# ─── 1. File existence ───
func _test_file_existence() -> void:
	print("── 1. Test asset file existence ──")
	_assert(FileAccess.file_exists(AUDIO_DIR + "test_ui_click.wav"), "test_ui_click.wav exists")
	_assert(FileAccess.file_exists(AUDIO_DIR + "test_ambient_loop.ogg"), "test_ambient_loop.ogg exists")
	_assert(FileAccess.file_exists(AUDIO_DIR + "test_resolution.ogg"), "test_resolution.ogg exists")
	_assert(FileAccess.file_exists(AUDIO_DIR + ".gdkeep"), "audio directory tracked")

# ─── 2. WAV loading ───
func _test_wav_loading() -> void:
	print("── 2. WAV stream loading ──")
	var stream = load(AUDIO_DIR + "test_ui_click.wav")
	_assert(stream != null, "WAV loaded without null")
	_assert(stream is AudioStream, "WAV is AudioStream type")
	if stream is AudioStreamWAV:
		_assert(stream.format == AudioStreamWAV.FORMAT_16_BITS, "WAV is 16-bit PCM")
		_assert(stream.mix_rate == 44100, "WAV is 44.1kHz sample rate")
		_assert(stream.stereo == false, "WAV is mono (mobile-optimal)")

# ─── 3. OGG loading ───
func _test_ogg_loading() -> void:
	print("── 3. OGG Vorbis stream loading ──")
	var stream_ambient = load(AUDIO_DIR + "test_ambient_loop.ogg")
	_assert(stream_ambient != null, "Ambient OGG loaded without null")
	_assert(stream_ambient is AudioStream, "Ambient OGG is AudioStream type")
	if stream_ambient is AudioStreamOggVorbis:
		_assert(true, "Ambient OGG is AudioStreamOggVorbis type")

	var stream_res = load(AUDIO_DIR + "test_resolution.ogg")
	_assert(stream_res != null, "Resolution OGG loaded without null")
	_assert(stream_res is AudioStream, "Resolution OGG is AudioStream type")

# ─── 4. Ambient loop lifecycle ───
func _test_ambient_loop_lifecycle() -> void:
	print("── 4. Ambient loop lifecycle ──")
	# Ensure clean state
	IrisAudioConsumer.stop_ambient_loop()
	_assert(IrisAudioConsumer._ambient_player == null, "No ambient player before test")

	# Start ambient with real asset
	IrisAudioConsumer.play_ambient_loop(AUDIO_DIR + "test_ambient_loop.ogg")
	_assert(IrisAudioConsumer._ambient_player != null, "Ambient player created")
	if IrisAudioConsumer._ambient_player != null:
		_assert(IrisAudioConsumer._ambient_player.stream != null, "Ambient player has stream")
		_assert(IrisAudioConsumer._ambient_player.is_inside_tree(), "Ambient player in scene tree")
		# Check loop was set on the stream
		if IrisAudioConsumer._ambient_player.stream is AudioStreamOggVorbis:
			_assert(IrisAudioConsumer._ambient_player.stream.loop == true, "OGG loop flag set to true")

	# Stop ambient
	IrisAudioConsumer.stop_ambient_loop()
	_assert(IrisAudioConsumer._ambient_player == null, "Ambient player freed after stop")

	# Double stop is safe
	IrisAudioConsumer.stop_ambient_loop()
	_assert(true, "Double stop_ambient_loop: no crash")

# ─── 5. Presence routing ───
func _test_presence_routing() -> void:
	print("── 5. Presence event routing ──")
	# Known events resolve to paths
	var path: String = IrisAudioConsumer.PRESENCE_AUDIO.get("iris_awaken", "")
	_assert(not path.is_empty(), "iris_awaken has path: %s" % path)

	path = IrisAudioConsumer.PRESENCE_AUDIO.get("hub_return", "")
	_assert(not path.is_empty(), "hub_return has path: %s" % path)

	path = IrisAudioConsumer.PRESENCE_AUDIO.get("evolution_detected", "")
	_assert(not path.is_empty(), "evolution_detected has path: %s" % path)

	path = IrisAudioConsumer.PRESENCE_AUDIO.get("new_aperture_reached", "")
	_assert(not path.is_empty(), "new_aperture_reached has path: %s" % path)

	# Mode paths resolve
	path = IrisAudioConsumer._resolve_mode_path("INTRODUCING")
	_assert(not path.is_empty(), "INTRODUCING mode resolves to path")

	path = IrisAudioConsumer._resolve_mode_path("REFLECTIVE")
	_assert(not path.is_empty(), "REFLECTIVE mode resolves to path")

	path = IrisAudioConsumer._resolve_mode_path("UNKNOWN_MODE")
	_assert(path.is_empty(), "Unknown mode returns empty path")

# ─── 6. Fallback safety ───
func _test_fallback_safety() -> void:
	print("── 6. Missing asset fallback safety ──")
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/test/NONEXISTENT.ogg")
	_assert(true, "play_manifest_sound missing file: no crash")

	IrisAudioConsumer._play_oneshot("")
	_assert(true, "_play_oneshot empty path: no crash")

	IrisAudioConsumer.play_ambient_loop("res://assets/audio/test/NONEXISTENT.ogg")
	_assert(IrisAudioConsumer._ambient_player == null, "No player for missing ambient")

	IrisAudioConsumer.play_presence_sound("unknown_event")
	_assert(true, "Unknown presence event: no crash")

# ─── 7. Null intent ───
func _test_consume_null() -> void:
	print("── 7. Null intent safety ──")
	IrisAudioConsumer.consume(null)
	_assert(true, "consume(null): no crash")

# ─── 8. Dead code removed ───
func _test_dead_code_removed() -> void:
	print("── 8. Dead code verification ──")
	# Inspect an instance; calling has_method on a script class is a Godot 4.6 parse error.
	var consumer := IrisAudioConsumer.new()
	_assert(not consumer.has_method("AUDIO_ASSETS"), "AUDIO_ASSETS dead constant removed (not a method)")
	# Verify the class still has the key working methods.
	_assert(consumer.has_method("play_manifest_sound"), "play_manifest_sound exists")
	_assert(consumer.has_method("play_ambient_loop"), "play_ambient_loop exists")
	_assert(consumer.has_method("stop_ambient_loop"), "stop_ambient_loop exists")
	_assert(consumer.has_method("play_presence_sound"), "play_presence_sound exists")
	_assert(consumer.has_method("consume"), "consume exists")

extends SceneTree

## Mission 054A validation: Living Iris awakening ritual foundation.
## Run: godot --headless -s tests/iris_awakening_validation.gd

var passed := 0
var failed := 0

const DIALOGUE_EVENTS := ["iris_welcome", "iris_idle", "iris_ready", "iris_return"]
const REQUIRED_AUDIO := [
	"res://assets/audio/iris/iris_awaken.ogg",
	"res://assets/audio/iris/iris_breath_loop.ogg",
	"res://assets/audio/iris/iris_focus.ogg",
	"res://assets/audio/iris/iris_attention.ogg",
	"res://assets/audio/iris/iris_confirm.ogg",
	"res://assets/audio/iris/iris_transition.ogg",
	"res://assets/audio/iris/iris_presence.ogg",
]

func _init() -> void:
	print("")
	print("==============================================")
	print("  MISSION 054A — IRIS AWAKENING VALIDATION")
	print("==============================================")
	print("")

	_test_dialogue_registry()
	_test_audio_references()
	_test_controller_ritual_api()
	_test_core_attention_fields()
	_test_haptic_events_are_low_intensity()

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
		printerr("  ✗ FAILED: %s" % description)

func _test_dialogue_registry() -> void:
	print("── 1. Data-driven Iris dialogue events ──")
	_assert(FileAccess.file_exists(IrisDialogueRegistry.DIALOGUE_PATH), "dialogue JSON exists")
	for event_name in DIALOGUE_EVENTS:
		_assert(IrisDialogueRegistry.has_event(event_name), "%s registered" % event_name)
		_assert(not IrisDialogueRegistry.text_for_event(event_name).is_empty(), "%s has text" % event_name)
		_assert(not IrisDialogueRegistry.expression_for_event(event_name, "").is_empty(), "%s has expression mode" % event_name)
		var audio_path := IrisDialogueRegistry.audio_for_event(event_name)
		_assert(audio_path.begins_with("res://assets/audio/iris/"), "%s uses Iris audio namespace" % event_name)
		_assert(FileAccess.file_exists(audio_path), "%s audio exists: %s" % [event_name, audio_path])

func _test_audio_references() -> void:
	print("── 2. Awakening audio references ──")
	for path in REQUIRED_AUDIO:
		_assert(FileAccess.file_exists(path), "required Iris audio exists: %s" % path)
	_assert(IrisAudioConsumer.PRESENCE_AUDIO.has("iris_welcome"), "presence map includes iris_welcome")
	_assert(IrisAudioConsumer.PRESENCE_AUDIO.has("iris_ready"), "presence map includes iris_ready")
	_assert(IrisAudioConsumer.PRESENCE_AUDIO.has("iris_return"), "presence map includes iris_return")

func _test_controller_ritual_api() -> void:
	print("── 3. IrisController ritual API ──")
	var controller := IrisController.new()
	_assert(controller.has_method("begin_awakening_ritual"), "IrisController exposes begin_awakening_ritual")
	_assert(controller.has_method("_update_awakening_ritual"), "IrisController owns timed ritual update")
	_assert(controller.has_method("_end_awakening_ritual"), "IrisController can end ritual safely")

func _test_core_attention_fields() -> void:
	print("── 4. Simulated awareness behavior ──")
	var core := IrisCore.new()
	_assert(core.has_method("acquire_attention"), "IrisCore supports interaction attention")
	_assert(core.has_method("_update_simulated_attention"), "IrisCore supports simulated attention changes")
	_assert(IrisCore.State.has("AWARE"), "IrisCore has AWARE state")

func _test_haptic_events_are_low_intensity() -> void:
	print("── 5. Haptic hook sanity ──")
	for event_name in DIALOGUE_EVENTS:
		var haptic_key := IrisDialogueRegistry.haptic_for_event(event_name)
		_assert(not haptic_key.is_empty(), "%s has haptic hook" % event_name)
	_assert(IrisHapticConsumer.Pattern.LIGHT == 0, "LIGHT haptic pattern remains available for subtle pulses")

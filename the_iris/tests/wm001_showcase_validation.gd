extends SceneTree

## Mission 055B validation: WM-001 authored Living Iris showcase contract.
## Run: godot --headless -s tests/wm001_showcase_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 055B — WM-001 SHOWCASE VALIDATION")
	_test_showcase_definition()
	_test_iris_guidance_events()
	_test_runtime_and_return_contract()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_showcase_definition() -> void:
	var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_001.json")
	_assert(definition != null, "WM-001 loads through the existing loader")
	if definition == null:
		return
	_assert(bool(definition.showcase.get("enabled", false)), "WM-001 enables optional showcase presentation")
	_assert(not str(definition.showcase.get("observation_prompt", "")).is_empty(), "WM-001 has authored observation language")
	_assert(definition.showcase.get("false_leads", []) is Array and definition.showcase.get("false_leads", []).size() >= 2, "WM-001 has discovery false leads")
	_assert(float(definition.showcase.get("reconstruction_seconds", 0.0)) > 0.0, "WM-001 has reconstruction timing")
	_assert(float(definition.showcase.get("iris_presence_alpha", 1.0)) < 1.0, "WM-001 leaves visual room for the existing Iris presence")
	_assert(definition.primary_fracture().fracture_id == "borrowed_light", "WM-001 retains Borrowed Light fracture")
	_assert(str(definition.truth_fragment.get("truth_fragment_id", "")) == "fragment_borrowed_light", "WM-001 retains Borrowed Light fragment")
	for audio_key in ["ambient", "fracture_discovery", "synchronization_complete", "reconstruction"]:
		var path := str(definition.asset_manifest.audio_assets.get(audio_key, ""))
		_assert(not path.is_empty() and FileAccess.file_exists(path), "WM-001 %s audio resolves" % audio_key)

func _test_iris_guidance_events() -> void:
	var required := ["wm001_observe", "wm001_fracture_prompt", "wm001_fracture_found", "wm001_synchronize", "wm001_revelation", "truth_fragment_absorbed"]
	for event_name in required:
		_assert(IrisDialogueRegistry.has_event(event_name), "%s is registered" % event_name)
		var audio_path := IrisDialogueRegistry.audio_for_event(event_name)
		_assert(FileAccess.file_exists(audio_path), "%s audio resolves" % event_name)

func _test_runtime_and_return_contract() -> void:
	var gameplay := GenericWitnessGameplay.new()
	_assert(gameplay.has_signal("iris_guidance_requested"), "generic gameplay emits Iris guidance through existing Application ownership")
	_assert(gameplay.has_method("_draw"), "generic gameplay has procedural showcase atmosphere renderer")
	_assert(gameplay.has_method("_update_synchronization"), "synchronization remains active in showcase runtime")
	var application_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	_assert(application_source.contains("iris_guidance_requested.connect"), "Application consumes guidance without new routing")
	_assert(application_source.contains("record_completion(result.moment_id"), "existing profile persistence remains completion authority")
	_assert(application_source.contains("_begin_portal_return"), "existing pupil return path remains intact")

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

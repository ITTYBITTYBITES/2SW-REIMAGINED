extends SceneTree

## Mission 062 validation: WM-005 authored Living Iris production migration.
## Run: godot --headless -s tests/wm005_production_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 062 — WM-005 PRODUCTION MIGRATION VALIDATION")
	_test_wm005_contract()
	_test_iris_events_and_runtime_path()
	_test_fragment_archive_projection()
	_test_existing_content_compatibility()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_wm005_contract() -> void:
	var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_005.json")
	_assert(definition != null, "WM-005 loads through existing content loader")
	if definition == null:
		return
	_assert(definition.primary_fracture().fracture_id == "returned_gaze", "WM-005 has authored returned gaze fracture")
	_assert(float(definition.primary_fracture().synchronization.get("hold_duration", 0.0)) >= 1.3, "WM-005 has tuned synchronization duration")
	_assert(float(definition.memory_stability.get("initial", 0.0)) <= 0.7, "WM-005 has authored stability pressure")
	_assert(bool(definition.showcase.get("enabled", false)), "WM-005 enables existing showcase presentation")
	_assert(definition.showcase.get("false_leads", []) is Array and definition.showcase.get("false_leads", []).size() >= 2, "WM-005 has authored investigation false leads")
	_assert(str(definition.truth_fragment.get("truth_fragment_id", "")) == "fragment_shared_aperture", "WM-005 has Shared Aperture fragment")
	for key in ["recovered_memory_summary", "truth_statement", "iris_reflection", "iris_reflection_event"]:
		_assert(not str(definition.truth_fragment.get(key, "")).is_empty(), "WM-005 fragment has %s" % key)
	for key in ["ambient", "fracture_discovery", "synchronization_complete", "reconstruction"]:
		var path := str(definition.asset_manifest.audio_assets.get(key, ""))
		_assert(not path.is_empty() and FileAccess.file_exists(path), "WM-005 %s audio resolves" % key)

func _test_iris_events_and_runtime_path() -> void:
	for event_name in ["wm005_observe", "wm005_fracture_prompt", "wm005_fracture_found", "wm005_synchronize", "wm005_revelation", "shared_aperture_reflection"]:
		_assert(IrisDialogueRegistry.has_event(event_name), "%s Iris event resolves" % event_name)
		_assert(FileAccess.file_exists(IrisDialogueRegistry.audio_for_event(event_name)), "%s event audio resolves" % event_name)
	var gameplay_source := FileAccess.get_file_as_string("res://scripts/gameplay/GenericWitnessGameplay.gd")
	_assert(gameplay_source.contains("atmosphere_light_color"), "existing showcase renderer consumes authored atmosphere data")
	_assert(gameplay_source.contains("_update_synchronization"), "WM-005 uses existing synchronization runtime")
	var app_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	_assert(app_source.contains("start_generic_gameplay(moment_id)"), "existing Application route remains intact")

func _test_fragment_archive_projection() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_005", {
		"accuracy": 0.9,
		"truth_fragment_id": "fragment_shared_aperture",
		"revelation_text": "Witness and Iris preserve memories together.",
		"archive_entry": "Shared Aperture — the recovered bond between Witness and Iris.",
		"truth_fragment_title": "Shared Aperture",
		"recovered_memory_summary": "Inside the Iris, the observer discovers that attention keeps damaged memories from disappearing.",
		"truth_statement": "You are not only observing the Iris. Together, you are preserving what would otherwise be lost.",
		"iris_reflection": "I kept the door open. You were the witness who could return through it.",
		"iris_reflection_event": "shared_aperture_reflection",
		"memory_stability": 0.9,
		"synchronization_score": 1.0,
		"synchronization_completed": true
	})
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	_assert(fragments.size() == 1, "WM-005 result projects through existing Archive authority")
	if not fragments.is_empty():
		_assert(str(fragments[0].get("display_name", "")) == "Shared Aperture", "Archive uses authored Shared Aperture title")
		_assert(str(fragments[0].get("chapter_id", "")) == "chapter_01", "WM-005 remains in Chapter 01")
		_assert(not str(fragments[0].get("iris_reflection", "")).is_empty(), "Archive receives Iris reflection")
	var restarted := WitnessProfile.from_dictionary(profile.to_dictionary())
	_assert(WitnessArchive.recovered_truth_fragments(restarted).size() == 1, "WM-005 fragment persists through existing profile serialization")

func _test_existing_content_compatibility() -> void:
	for index in [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12]:
		var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_%03d.json" % index)
		_assert(definition != null, "WM-%03d remains compatible" % index)
		if definition != null:
			_assert(not definition.primary_fracture().fracture_id.is_empty(), "WM-%03d keeps compatible fracture runtime" % index)

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

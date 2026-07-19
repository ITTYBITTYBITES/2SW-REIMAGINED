extends SceneTree

## Mission 060 validation: WM-003 authored Living Iris production migration.
## Run: godot --headless -s tests/wm003_production_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 060 — WM-003 PRODUCTION MIGRATION VALIDATION")
	_test_wm003_contract()
	_test_iris_events_and_runtime_path()
	_test_fragment_archive_projection()
	_test_existing_content_compatibility()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_wm003_contract() -> void:
	var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_003.json")
	_assert(definition != null, "WM-003 loads through existing content loader")
	if definition == null:
		return
	_assert(definition.primary_fracture().fracture_id == "departing_echo", "WM-003 has authored departing echo fracture")
	_assert(float(definition.primary_fracture().synchronization.get("hold_duration", 0.0)) >= 1.2, "WM-003 has tuned synchronization duration")
	_assert(float(definition.memory_stability.get("initial", 0.0)) < 0.8, "WM-003 has authored stability pressure")
	_assert(bool(definition.showcase.get("enabled", false)), "WM-003 enables existing showcase presentation")
	_assert(definition.showcase.get("false_leads", []) is Array and definition.showcase.get("false_leads", []).size() >= 2, "WM-003 has authored investigation false leads")
	_assert(str(definition.truth_fragment.get("truth_fragment_id", "")) == "fragment_safe_harbor", "WM-003 has Safe Harbor fragment")
	for key in ["recovered_memory_summary", "truth_statement", "iris_reflection", "iris_reflection_event"]:
		_assert(not str(definition.truth_fragment.get(key, "")).is_empty(), "WM-003 fragment has %s" % key)
	for key in ["ambient", "fracture_discovery", "synchronization_complete", "reconstruction"]:
		var path := str(definition.asset_manifest.audio_assets.get(key, ""))
		_assert(not path.is_empty() and FileAccess.file_exists(path), "WM-003 %s audio resolves" % key)

func _test_iris_events_and_runtime_path() -> void:
	for event_name in ["wm003_observe", "wm003_fracture_prompt", "wm003_fracture_found", "wm003_synchronize", "wm003_revelation", "safe_harbor_reflection"]:
		_assert(IrisDialogueRegistry.has_event(event_name), "%s Iris event resolves" % event_name)
		_assert(FileAccess.file_exists(IrisDialogueRegistry.audio_for_event(event_name)), "%s event audio resolves" % event_name)
	var gameplay_source := FileAccess.get_file_as_string("res://scripts/gameplay/GenericWitnessGameplay.gd")
	_assert(gameplay_source.contains("atmosphere_light_color"), "existing showcase renderer consumes authored atmosphere data")
	_assert(gameplay_source.contains("_update_synchronization"), "WM-003 uses existing synchronization runtime")
	var app_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	_assert(app_source.contains("start_generic_gameplay(moment_id)"), "existing Application route remains intact")

func _test_fragment_archive_projection() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_003", {
		"accuracy": 0.91,
		"truth_fragment_id": "fragment_safe_harbor",
		"revelation_text": "Elena’s journey became a reunion.",
		"archive_entry": "Safe Harbor — a recovered passage from Elena’s final performance.",
		"truth_fragment_title": "Safe Harbor",
		"recovered_memory_summary": "A violinist’s last performance before crossing the ocean to join her brother.",
		"truth_statement": "The journey was a path opened by a note already received.",
		"iris_reflection": "Some goodbyes carry us forward before we know we can leave.",
		"iris_reflection_event": "safe_harbor_reflection",
		"memory_stability": 0.91,
		"synchronization_score": 1.0,
		"synchronization_completed": true
	})
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	_assert(fragments.size() == 1, "WM-003 result projects through existing Archive authority")
	if not fragments.is_empty():
		_assert(str(fragments[0].get("display_name", "")) == "Safe Harbor", "Archive uses authored Safe Harbor title")
		_assert(str(fragments[0].get("chapter_id", "")) == "chapter_01", "WM-003 remains in Chapter 01")
		_assert(not str(fragments[0].get("iris_reflection", "")).is_empty(), "Archive receives Iris reflection")
	var restarted := WitnessProfile.from_dictionary(profile.to_dictionary())
	_assert(WitnessArchive.recovered_truth_fragments(restarted).size() == 1, "WM-003 fragment persists through existing profile serialization")

func _test_existing_content_compatibility() -> void:
	for index in [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]:
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

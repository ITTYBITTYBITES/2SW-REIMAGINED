extends SceneTree

## Mission 055 validation: additive Fracture/Synchronization/Fragment evolution.
## Run: godot --headless -s tests/witness_engine_evolution_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 055 — WITNESS ENGINE EVOLUTION VALIDATION")
	_test_legacy_moment_compatibility()
	_test_wm001_living_contract()
	_test_result_and_archive_extension()
	_test_runtime_and_iris_hooks()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_legacy_moment_compatibility() -> void:
	for index in range(1, 13):
		var id := "WM_%03d" % index
		var definition := WitnessContentLoader.load_moment_definition("res://content/witness/%s.json" % id.to_lower())
		_assert(definition != null, "%s loads through the existing loader" % id)
		if definition == null:
			continue
		_assert(not definition.fractures.is_empty(), "%s receives a compatible Fracture" % id)
		_assert(not definition.primary_fracture().fracture_id.is_empty(), "%s has fracture identity" % id)
		_assert(definition.memory_stability.has("initial"), "%s receives safe stability defaults" % id)
		_assert(not str(definition.truth_fragment.get("truth_fragment_id", "")).is_empty(), "%s receives a safe truth fragment ID" % id)

func _test_wm001_living_contract() -> void:
	var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_001.json")
	_assert(definition != null, "WM_001 loads")
	if definition == null:
		return
	var fracture := definition.primary_fracture()
	_assert(fracture.fracture_id == "borrowed_light", "WM_001 keeps authored fracture ID")
	_assert(float(fracture.synchronization.get("hold_duration", 0.0)) > 0.0, "WM_001 has synchronization hold data")
	_assert(str(definition.truth_fragment.get("truth_fragment_id", "")) == "fragment_borrowed_light", "WM_001 has authored Truth Fragment")
	_assert(not str(definition.truth_fragment.get("revelation_text", "")).is_empty(), "WM_001 has revelation text")

func _test_result_and_archive_extension() -> void:
	var result := WitnessMomentResult.new("WM_001", 0.9, 1, 1, false, false, "deliberate", {
		"fractures_found": 1,
		"fractures_total": 1,
		"synchronization_completed": true,
		"synchronization_score": 1.0,
		"memory_stability": 1.0,
		"truth_fragment_id": "fragment_borrowed_light",
		"revelation_text": "A recovered truth.",
		"archive_entry": "Archive proof."
	})
	var record := result.to_dictionary()
	_assert(record.get("truth_fragment_id", "") == "fragment_borrowed_light", "result exposes truth fragment")
	_assert(bool(record.get("synchronization_completed", false)), "result exposes synchronization outcome")
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", record)
	var saved: Dictionary = profile.moment_records.get("WM_001", {})
	_assert(bool(saved.get("truth_fragment_recovered", false)), "archive record stores absorbed fragment")
	_assert(float(saved.get("best_memory_stability", 0.0)) >= 1.0, "archive record stores stability")
	_assert(float(saved.get("best_synchronization_score", 0.0)) >= 1.0, "archive record stores synchronization")

func _test_runtime_and_iris_hooks() -> void:
	var gameplay := GenericWitnessGameplay.new()
	_assert(gameplay.has_method("_find_fracture"), "generic runtime supports Fracture discovery")
	_assert(gameplay.has_method("_update_synchronization"), "generic runtime supports Synchronization")
	_assert(GenericWitnessGameplay.Phase.has("SYNCHRONIZATION"), "generic runtime has Synchronization phase")
	_assert(GenericWitnessGameplay.Phase.has("TRUTH_FRAGMENT"), "generic runtime has Truth Fragment phase")
	_assert(IrisDialogueRegistry.has_event("truth_fragment_absorbed"), "Iris absorption dialogue event is registered")
	var app_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	_assert(app_source.contains("truth_fragment_absorbed"), "Application routes fragment completion into existing Iris feedback")

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

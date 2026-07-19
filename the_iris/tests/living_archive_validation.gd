extends SceneTree

## Mission 056 validation: Truth Fragment persistence → Archive projection →
## persistent Iris evolution → Spatial Hub constellation contract.
## Run: godot --headless -s tests/living_archive_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 056 — LIVING IRIS ARCHIVE VALIDATION")
	_test_fragment_persistence_and_bloom()
	_test_iris_evolution_projection()
	_test_constellation_and_compatibility()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_fragment_persistence_and_bloom() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", {
		"accuracy": 1.0,
		"truth_fragment_id": "fragment_borrowed_light",
		"revelation_text": "Cause arrived after its effect.",
		"archive_entry": "Borrowed Light — a recovered causal truth.",
		"memory_stability": 1.0,
		"synchronization_score": 1.0,
		"synchronization_completed": true
	})
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	_assert(fragments.size() == 1, "WM-001 completion creates one recovered fragment")
	if not fragments.is_empty():
		_assert(str(fragments[0].get("fragment_id", "")) == "fragment_borrowed_light", "Borrowed Light identity persists")
		_assert(str(fragments[0].get("display_name", "")) == "Borrowed Light", "fragment has player-facing display name")
		_assert(str(fragments[0].get("chapter_id", "")) == "chapter_01", "fragment belongs to Chapter 01")
	var blooms := WitnessArchive.chapter_blooms(profile)
	var chapter_one: Dictionary = blooms.get("chapter_01", {})
	_assert(int(chapter_one.get("recovered_count", 0)) == 1, "Chapter 01 bloom records Borrowed Light")
	_assert(bool(chapter_one.get("bloomed", false)), "Chapter 01 bloom is active")
	_assert(profile.moment_records.has("WM_001"), "WitnessProfile remains the only persisted moment authority")
	var restored_profile := WitnessProfile.from_dictionary(profile.to_dictionary())
	_assert(WitnessArchive.recovered_truth_fragments(restored_profile).size() == 1, "fragment persists through existing profile serialization")

func _test_iris_evolution_projection() -> void:
	var fragments: Array[Dictionary] = [{"fragment_id": "fragment_borrowed_light", "moment_id": "WM_001", "chapter_id": "chapter_01"}]
	var blooms := {"chapter_01": {"bloomed": true, "recovered_count": 1, "total_count": 5}}
	var evolution := IrisEvolutionProfile.new(1, 0, fragments, blooms)
	var behavior := IrisEvolutionVisualConsumer.apply_evolution(evolution, {"glow": 0.1, "fiber_density": 20})
	_assert(evolution.fragment_count == 1, "Iris evolution receives persistent fragment count")
	_assert(int(behavior.get("fragment_memory", 0)) == 1, "Iris visual behavior receives recovered-memory detail")
	_assert(bool(behavior.get("fragment_bloom", false)), "Iris visual behavior receives Chapter 01 bloom")
	var iris := LivingIris.new()
	_assert(iris.has_method("absorb_truth_fragment"), "Living Iris exposes transient absorption presentation")

func _test_constellation_and_compatibility() -> void:
	var hub_source := FileAccess.get_file_as_string("res://scripts/home/SpatialHub.gd")
	_assert(hub_source.contains("WitnessArchive.recovered_truth_fragments"), "constellation derives from existing Archive authority")
	_assert(hub_source.contains("fragment_identity") and hub_source.contains("chapter_id"), "constellation carries fragment identity and chapter metadata")
	for index in range(2, 13):
		var path := "res://content/witness/wm_%03d.json" % index
		var definition := WitnessContentLoader.load_moment_definition(path)
		_assert(definition != null, "WM_%03d remains compatible" % index)
		if definition != null:
			_assert(not definition.primary_fracture().fracture_id.is_empty(), "WM_%03d keeps safe Fracture compatibility" % index)

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

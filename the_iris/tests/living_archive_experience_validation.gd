extends SceneTree

## Mission 057 validation: derived relationship presentation and recovered-memory
## inspection. Run: godot --headless -s tests/living_archive_experience_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 057 — LIVING ARCHIVE EXPERIENCE VALIDATION")
	_test_fresh_profile()
	_test_recovered_memory_relationship()
	_test_persistence_and_constellation_contract()
	_test_runtime_and_content_compatibility()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_fresh_profile() -> void:
	var profile := WitnessProfile.new()
	var state := WitnessArchive.living_presentation(profile)
	_assert(WitnessArchive.recovered_truth_fragments(profile).is_empty(), "fresh profile has no recovered fragments")
	_assert(str(state.get("relationship_state", "")) == "LISTENING", "fresh Iris begins in listening relationship state")
	_assert(int(state.get("recovered_fragment_count", -1)) == 0, "fresh presentation has no confirmed truths")
	var evolution := IrisEvolutionProfile.new(1, 0, [], {}, state)
	_assert(evolution.fragment_count == 0 and evolution.relationship_state == "LISTENING", "fresh Iris evolution uses default derived state")

func _test_recovered_memory_relationship() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", _fragment_result("fragment_borrowed_light", 0.94))
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	var state := WitnessArchive.living_presentation(profile)
	_assert(fragments.size() == 1, "Borrowed Light appears from existing Archive authority")
	if not fragments.is_empty():
		_assert(str(fragments[0].get("display_name", "")) == "Borrowed Light", "recovered fragment has meaningful identity")
		_assert(str(fragments[0].get("chapter_id", "")) == "chapter_01", "Borrowed Light resolves Chapter 01 association")
		_assert(not str(fragments[0].get("memory_summary", "")).is_empty(), "fragment presentation carries recovered memory summary")
		_assert(not str(fragments[0].get("truth_statement", "")).is_empty(), "fragment presentation carries restored truth")
		_assert(not str(fragments[0].get("iris_reflection", "")).is_empty(), "fragment presentation carries Iris reflection")
	_assert(str(state.get("relationship_state", "")) == "REMEMBERING", "one truth changes Iris relationship state to remembering")
	_assert(float(state.get("memory_stability", 0.0)) > 0.9, "relationship stability derives from record data")

	# A second record proves awareness is derived from archive state rather than manually set.
	profile.record_completion("WM_002", _fragment_result("fragment_museum_echo", 0.82))
	var expanded := WitnessArchive.living_presentation(profile)
	_assert(int(expanded.get("recovered_fragment_count", 0)) == 2, "multiple recovered fragments increase confirmed truth count")
	_assert(str(expanded.get("relationship_state", "")) == "ATTUNING", "multiple recovered fragments raise relationship awareness")
	_assert(float(expanded.get("awareness_level", 0.0)) > float(state.get("awareness_level", 0.0)), "awareness level is archive-derived")

func _test_persistence_and_constellation_contract() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", _fragment_result("fragment_borrowed_light", 1.0))
	var restarted := WitnessProfile.from_dictionary(profile.to_dictionary())
	_assert(WitnessArchive.recovered_truth_fragments(restarted).size() == 1, "fragment remains after existing profile serialization/restart")
	var hub_source := FileAccess.get_file_as_string("res://scripts/home/SpatialHub.gd")
	_assert(hub_source.contains("WitnessArchive.recovered_truth_fragments"), "constellation still derives from Archive authority")
	_assert(hub_source.contains("fragment_identity") and hub_source.contains("chapter_id"), "constellation nodes retain unique fragment and chapter identity")
	_assert(not hub_source.contains("FileAccess.open("), "Spatial Hub does not create a persistence path")

func _test_runtime_and_content_compatibility() -> void:
	var iris := LivingIris.new()
	_assert(iris.has_method("present_memory_response"), "Living Iris supports subtle unsettled/stabilized/remembering responses")
	var gameplay := GenericWitnessGameplay.new()
	_assert(gameplay.has_signal("iris_memory_response_requested"), "existing Witness runtime can request Iris memory response")
	_assert(IrisDialogueRegistry.has_event("archive_fragment_viewed"), "Archive reflection dialogue event resolves")
	var application_source := FileAccess.get_file_as_string("res://scripts/Application.gd")
	_assert(application_source.contains("fragment_inspected.connect"), "existing Archive route connects to Iris reflection")
	_assert(application_source.contains("record_completion(result.moment_id"), "existing profile completion authority remains intact")
	for index in range(2, 13):
		var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_%03d.json" % index)
		_assert(definition != null, "WM_%03d remains compatible" % index)

func _fragment_result(fragment_id: String, stability: float) -> Dictionary:
	return {
		"accuracy": stability,
		"truth_fragment_id": fragment_id,
		"revelation_text": "A truth held by the Iris.",
		"archive_entry": "A recovered memory preserved by the Iris.",
		"truth_fragment_title": "Borrowed Light",
		"recovered_memory_summary": "The final moments of a forgotten artist.",
		"truth_statement": "The light was not lost. It was protected.",
		"iris_reflection": "Some memories disappear because nobody was there to witness them.",
		"iris_reflection_event": "borrowed_light_reflection",
		"memory_stability": stability,
		"synchronization_score": stability,
		"synchronization_completed": true
	}

func _assert(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("  ✓ %s" % description)
	else:
		failed += 1
		printerr("  ✗ FAILED: %s" % description)

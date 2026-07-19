extends SceneTree

## Mission 059 production-readiness validation for the two authored Chapter 01
## Living Iris moments. Run: godot --headless -s tests/chapter_pipeline_validation.gd

var passed := 0
var failed := 0

func _init() -> void:
	print("MISSION 059 — CHAPTER 01 PRODUCTION PIPELINE VALIDATION")
	_test_authored_moment_contracts()
	_test_shared_fragment_pipeline()
	_test_relationship_and_bloom_derivation()
	_test_serialization_and_authority_boundaries()
	print("RESULTS: %d passed, %d failed" % [passed, failed])
	quit(0 if failed == 0 else 1)

func _test_authored_moment_contracts() -> void:
	for spec in [
		{"id": "WM_001", "fracture": "borrowed_light", "fragment": "fragment_borrowed_light"},
		{"id": "WM_002", "fracture": "inherited_warmth", "fragment": "fragment_inherited_warmth"}
	]:
		var id := str(spec.get("id", ""))
		var definition := WitnessContentLoader.load_moment_definition("res://content/witness/%s.json" % id.to_lower())
		_assert(definition != null, "%s loads through the existing production loader" % id)
		if definition == null:
			continue
		_assert(definition.primary_fracture().fracture_id == str(spec.get("fracture", "")), "%s resolves authored Fracture identity" % id)
		_assert(bool(definition.showcase.get("enabled", false)), "%s uses optional existing showcase presentation" % id)
		_assert(not str(definition.truth_fragment.get("truth_fragment_id", "")).is_empty(), "%s resolves Truth Fragment" % id)
		_assert(str(definition.truth_fragment.get("truth_fragment_id", "")) == str(spec.get("fragment", "")), "%s resolves expected fragment identity" % id)
		_assert(float(definition.primary_fracture().synchronization.get("hold_duration", 0.0)) > 0.0, "%s resolves synchronization data" % id)
		for key in ["observation_event", "fracture_discovered_event", "synchronization_event", "revelation_event"]:
			var event_name := str(definition.iris_guidance.get(key, ""))
			_assert(not event_name.is_empty() and IrisDialogueRegistry.has_event(event_name), "%s %s Iris event resolves" % [id, key])

func _test_shared_fragment_pipeline() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", _result_for("fragment_borrowed_light", "Borrowed Light", 0.95))
	profile.record_completion("WM_002", _result_for("fragment_inherited_warmth", "Inherited Warmth", 0.88))
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	_assert(fragments.size() == 2, "both authored fragments derive from WitnessProfile records")
	var identities := []
	for fragment in fragments:
		identities.append(str(fragment.get("fragment_id", "")))
	_assert(identities.has("fragment_borrowed_light") and identities.has("fragment_inherited_warmth"), "Archive projects both unique fragment identities")
	_assert(profile.moment_records.size() == 2, "only existing moment_records store recovered fragment state")

func _test_relationship_and_bloom_derivation() -> void:
	var profile := WitnessProfile.new()
	var fresh := WitnessArchive.living_presentation(profile)
	_assert(str(fresh.get("relationship_state", "")) == "LISTENING", "0 fragments derives LISTENING")
	profile.record_completion("WM_001", _result_for("fragment_borrowed_light", "Borrowed Light", 0.95))
	var one := WitnessArchive.living_presentation(profile)
	_assert(str(one.get("relationship_state", "")) == "REMEMBERING", "1 fragment derives REMEMBERING")
	profile.record_completion("WM_002", _result_for("fragment_inherited_warmth", "Inherited Warmth", 0.88))
	var two := WitnessArchive.living_presentation(profile)
	_assert(str(two.get("relationship_state", "")) == "ATTUNING", "2 fragments derives ATTUNING")
	var bloom: Dictionary = WitnessArchive.chapter_blooms(profile).get("chapter_01", {})
	_assert(int(bloom.get("recovered_count", 0)) == 2 and int(bloom.get("total_count", 0)) == 5, "Chapter 01 bloom derives 2 / 5")
	var evo := IrisEvolutionProfile.new(profile.aperture_rank, profile.resonance, WitnessArchive.recovered_truth_fragments(profile), WitnessArchive.chapter_blooms(profile), two)
	var behavior := IrisEvolutionVisualConsumer.apply_evolution(evo, {"glow": 0.1, "fiber_density": 20})
	_assert(evo.relationship_state == "ATTUNING" and int(behavior.get("fragment_memory", 0)) == 2, "Iris evolution remains Archive/profile-derived")

func _test_serialization_and_authority_boundaries() -> void:
	var profile := WitnessProfile.new()
	profile.record_completion("WM_001", _result_for("fragment_borrowed_light", "Borrowed Light", 0.95))
	profile.record_completion("WM_002", _result_for("fragment_inherited_warmth", "Inherited Warmth", 0.88))
	var restored := WitnessProfile.from_dictionary(profile.to_dictionary())
	_assert(WitnessArchive.recovered_truth_fragments(restored).size() == 2, "profile serialization preserves both fragments")
	var hub_source := FileAccess.get_file_as_string("res://scripts/home/SpatialHub.gd")
	_assert(hub_source.contains("WitnessArchive.recovered_truth_fragments") and hub_source.contains("fragment_identity"), "Spatial Hub constellation uses existing Archive projection")
	_assert(not hub_source.contains("FileAccess.open("), "Spatial Hub does not create duplicate persistence")
	for index in range(3, 13):
		var definition := WitnessContentLoader.load_moment_definition("res://content/witness/wm_%03d.json" % index)
		_assert(definition != null, "WM-%03d remains compatible baseline content" % index)

func _result_for(fragment_id: String, title: String, stability: float) -> Dictionary:
	return {
		"accuracy": stability,
		"truth_fragment_id": fragment_id,
		"revelation_text": "A recovered truth.",
		"archive_entry": title + " — a preserved memory.",
		"truth_fragment_title": title,
		"recovered_memory_summary": "A memory retained by the Iris.",
		"truth_statement": "The truth was restored.",
		"iris_reflection": "The Iris remembers.",
		"iris_reflection_event": "archive_fragment_viewed",
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

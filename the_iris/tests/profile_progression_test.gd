extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var profile := WitnessProfile.new()
	var evolution_events: Array = []
	profile.iris_evolution_changed.connect(func(data): evolution_events.append(data))

	var first_award := profile.record_completion("WM_001")
	_assert(int(first_award["total"]) == WitnessProgression.FIRST_COMPLETION_RESONANCE, "First completion resonance is incorrect")
	_assert(profile.completed_moment_ids.has("WM_001"), "First completion was not recorded")
	_assert(profile.completion_count == 1, "Completion count is incorrect")

	var replay_award := profile.record_completion("WM_001", {
		"accuracy": 1.0,
		"anomalies_found": 2,
		"assistance_used": false,
		"mastery": true,
		"observation_style": "deliberate"
	})
	_assert(int(replay_award["total"]) == 45, "Replay progression components are incorrect")
	_assert(profile.replay_mastery_count == 1, "Mastery was not recorded")
	_assert(profile.assistance_free_completions == 1, "Unassisted completion was not recorded")
	_assert(profile.average_accuracy() == 1.0, "Accuracy was not recorded")
	_assert(not evolution_events.is_empty(), "Iris evolution hook did not emit")

	_assert(WitnessProgression.aperture_rank_for(900) == 10, "Aperture 10 mapping is incorrect")
	_assert(WitnessProgression.aperture_title_for(10) == "Attuned", "Attuned title mapping is incorrect")
	_assert(WitnessProgression.aperture_rank_for(9900) == 100, "Aperture 100 mapping is incorrect")
	_assert(WitnessProgression.aperture_title_for(100) == "Witness", "Witness title mapping is incorrect")

	var test_path := "user://witness_profile_progression_test.json"
	var store := WitnessProfileStore.new(test_path)
	store.erase_profile()
	_assert(store.save_profile(profile), "Profile did not save")
	var loaded := store.load_profile()
	_assert(loaded.resonance == profile.resonance, "Saved resonance did not load")
	_assert(loaded.completed_moment_ids == profile.completed_moment_ids, "Saved moments did not load")
	_assert(loaded.replay_mastery_count == profile.replay_mastery_count, "Saved mastery did not load")
	store.erase_profile()

	print("WITNESS_PROFILE_PROGRESSION_TEST: PASS")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)

extends Control
class_name PrototypeApplication

## Clean-room application composition: boot → Iris → Iris Home → Witness.
signal iris_evolution_updated(data: IrisEvolutionData)
var registry: IncidentRegistry
var director: WitnessExperienceDirector
var orchestrator: WitnessMomentOrchestrator
var profile_store: WitnessProfileStore
var witness_profile: WitnessProfile
var latest_iris_evolution: IrisEvolutionData
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var witness: WitnessChapters
var wm001_gameplay: WM001GameplayLoop
var flagship_gameplay: FlagshipWitnessMoment
var generic_gameplay: GenericWitnessGameplay
var archive_ui: WitnessArchiveUI
var replayed_from_archive := false
var startup: StartupFlow
var pending_witness_results: Dictionary = {}
var boot_introduction_pending := false
var memory_focus_active := false
var reflective_return_pending := false
var reflective_return_in := -1.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	registry = IncidentRegistry.new()
	registry.name = "IncidentRegistry"
	registry.load_catalogue()
	add_child(registry)

	profile_store = WitnessProfileStore.new()
	witness_profile = profile_store.load_profile()
	witness_profile.iris_evolution_changed.connect(_on_iris_evolution_changed)
	latest_iris_evolution = witness_profile.iris_evolution

	director = WitnessExperienceDirector.new()
	director.name = "WitnessExperienceDirector"
	director.configure(registry)
	add_child(director)
	orchestrator = WitnessMomentOrchestrator.new()
	orchestrator.name = "WitnessMomentOrchestrator"
	orchestrator.moment_completed.connect(_on_witness_moment_completed)
	add_child(orchestrator)

	iris = IrisController.new()
	iris.name = "IrisController"
	iris.home_requested.connect(show_home)
	add_child(iris)
	iris.living_iris.evolution_profile = IrisEvolutionProfile.new(witness_profile.aperture_rank, witness_profile.resonance)
	iris.iris_core.state_changed.connect(_on_iris_core_state_changed)

	iris_personality = IrisPersonalityResolver.new()
	iris_personality.name = "IrisPersonalityResolver"
	iris_personality.response_intent_emitted.connect(iris.present_response_intent)
	add_child(iris_personality)

	home = IrisHome.new()
	home.name = "IrisHome"
	home.continue_witness_requested.connect(start_flagship_moment)
	home.iris_requested.connect(show_iris)
	home.memory_intent_focused.connect(_on_home_memory_intent_focused)
	home.memory_intent_released.connect(_on_home_memory_intent_released)
	home.memory_selected.connect(_on_home_memory_selected)
	home.archive_requested.connect(show_archive)
	home.witness_chapters_requested.connect(show_witness)
	add_child(home)
	home.update_profile_presentation(witness_profile)

	witness = WitnessChapters.new()
	witness.name = "WitnessChapters"
	witness.configure(registry, director, orchestrator)
	witness.home_requested.connect(show_home)
	witness.generic_moment_requested.connect(start_generic_gameplay)
	add_child(witness)

	generic_gameplay = GenericWitnessGameplay.new()
	generic_gameplay.name = "GenericWitnessGameplay"
	generic_gameplay.completion_requested.connect(_on_generic_completion_requested)
	generic_gameplay.return_requested.connect(_on_generic_return_requested)
	add_child(generic_gameplay)

	archive_ui = WitnessArchiveUI.new()
	archive_ui.name = "WitnessArchiveUI"
	archive_ui.configure(witness_profile, registry)
	archive_ui.back_to_hub_requested.connect(show_home)
	archive_ui.replay_requested.connect(replay_from_archive)
	add_child(archive_ui)

	wm001_gameplay = WM001GameplayLoop.new()
	wm001_gameplay.name = "WM001GameplayLoop"
	wm001_gameplay.configure(director, orchestrator)
	wm001_gameplay.completion_requested.connect(_on_wm001_completion_requested)
	wm001_gameplay.return_requested.connect(_on_wm001_return_requested)
	add_child(wm001_gameplay)

	flagship_gameplay = FlagshipWitnessMoment.new()
	flagship_gameplay.name = "FlagshipWitnessMoment"
	flagship_gameplay.completion_requested.connect(_on_flagship_completion_requested)
	flagship_gameplay.return_requested.connect(_on_flagship_return_requested)
	add_child(flagship_gameplay)

	startup = StartupFlow.new()
	startup.name = "StartupFlow"
	startup.finished.connect(_on_startup_finished)
	add_child(startup)
	prepare_iris()

func _on_startup_finished() -> void:
	boot_introduction_pending = true
	show_iris(true)

func prepare_iris() -> void:
	iris.set_home_environment(false)
	iris.visible = false
	home.visible = false
	witness.visible = false
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	generic_gameplay.visible = false
	archive_ui.visible = false
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.set_home_environment(false)
	iris.visible = true
	home.visible = false
	witness.visible = false
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	generic_gameplay.visible = false
	archive_ui.visible = false
	if from_boot:
		iris.calibrate()
	else:
		iris.welcome()

func show_home() -> void:
	# The single Living Iris remains visible as the settled center of Home.
	iris.visible = true
	iris.set_gameplay_environment(false)
	if reflective_return_pending:
		# Preserve the existing REFLECTIVE state briefly so return carries meaning.
		iris.reflect()
		reflective_return_in = 1.65
	else:
		iris.settle()
		_emit_personality_response("hub_return")
		IrisAudioConsumer.play_presence_sound("hub_return")
	iris.set_home_environment(true)
	home.visible = true
	witness.visible = false
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	generic_gameplay.visible = false
	archive_ui.visible = false

func _on_home_memory_intent_focused(normalized_target: Vector2) -> void:
	if home.visible and iris.visible:
		memory_focus_active = true
		iris.iris_core.acquire_attention(normalized_target)
		_emit_personality_response("memory_focus")

func _on_home_memory_intent_released() -> void:
	if home.visible and iris.visible:
		memory_focus_active = false
		iris.settle()

func _on_home_memory_selected() -> void:
	memory_focus_active = false
	_emit_personality_response("memory_selected")

func _on_iris_core_state_changed(next_state: IrisCore.State) -> void:
	if boot_introduction_pending and next_state == IrisCore.State.WELCOMING:
		boot_introduction_pending = false
		_emit_personality_response("boot_complete")
	if memory_focus_active and next_state == IrisCore.State.FOCUSED:
		_emit_personality_response("memory_focus")

func _emit_personality_response(experience_event: String) -> void:
	if iris_personality != null:
		iris_personality.resolve(int(iris.iris_core.state), experience_event)

func start_wm001_gameplay() -> void:
	reflective_return_pending = false
	reflective_return_in = -1.0
	iris.set_home_environment(false)
	iris.visible = false
	home.visible = false
	witness.visible = false
	iris.observe()
	_emit_personality_response("witness_entered")
	if not wm001_gameplay.start():
		show_witness()

func _on_wm001_completion_requested(result: WitnessMomentResult) -> void:
	pending_witness_results[result.moment_id] = result.to_dictionary()
	while orchestrator.phase != WitnessMomentOrchestrator.Phase.REVEALING:
		orchestrator.advance()
	orchestrator.advance()

func _on_wm001_return_requested() -> void:
	wm001_gameplay.close()
	show_home()

func start_flagship_moment() -> void:
	start_generic_gameplay("FM_001")

func _on_flagship_completion_requested(result: WitnessMomentResult) -> void:
	var award := {"total": 0, "components": {}}
	if witness_profile != null:
		award = witness_profile.record_completion(result.moment_id, result.to_dictionary())
		profile_store.save_profile(witness_profile)
	reflective_return_pending = true
	iris.reflect()
	_emit_personality_response("witness_completed")
	flagship_gameplay.present_reward(award, witness_profile)

func _on_flagship_return_requested() -> void:
	flagship_gameplay.close()
	show_home()

func show_witness() -> void:
	reflective_return_pending = false
	reflective_return_in = -1.0
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.visible = false
	home.visible = false
	witness.visible = true
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	generic_gameplay.visible = false
	archive_ui.visible = false
	iris.observe()
	_emit_personality_response("witness_entered")
	witness.show_chapters()

func _on_witness_moment_completed(moment_id: String) -> void:
	var result: Dictionary = pending_witness_results.get(moment_id, {})
	pending_witness_results.erase(moment_id)
	var award := {"total": 0, "components": {}}
	if witness_profile != null:
		award = witness_profile.record_completion(moment_id, result)
		profile_store.save_profile(witness_profile)
	reflective_return_pending = true
	iris.reflect()
	_emit_personality_response("witness_completed")
	if wm001_gameplay.visible and moment_id == "WM_001":
		wm001_gameplay.present_reward(award, witness_profile)

func _on_iris_evolution_changed(data: IrisEvolutionData) -> void:
	var old_data := latest_iris_evolution
	latest_iris_evolution = data
	iris_evolution_updated.emit(data)
	
	var new_evo := IrisEvolutionProfile.new(data.aperture_rank, data.resonance)
	if iris != null and iris.living_iris != null:
		iris.living_iris.evolution_profile = new_evo
		
	if home != null:
		home.update_profile_presentation(witness_profile)
		
	# Check for progression feedback triggers
	if old_data != null and old_data.aperture_rank > 0:
		var old_evo := IrisEvolutionProfile.new(old_data.aperture_rank, old_data.resonance)
		if old_evo.evolution_stage != new_evo.evolution_stage:
			_emit_personality_response("evolution_detected")
			IrisAudioConsumer.play_presence_sound("evolution_detected")
		elif old_data.aperture_rank != data.aperture_rank:
			_emit_personality_response("new_aperture_reached")
			IrisAudioConsumer.play_presence_sound("new_aperture_reached")

func show_archive() -> void:
	reflective_return_pending = false
	reflective_return_in = -1.0
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.visible = false
	home.visible = false
	witness.visible = false
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	generic_gameplay.visible = false
	archive_ui.configure(witness_profile, registry)
	archive_ui.open()

func replay_from_archive(moment_id: String) -> void:
	replayed_from_archive = true
	start_generic_gameplay(moment_id)

func start_generic_gameplay(moment_id: String) -> void:
	reflective_return_pending = false
	reflective_return_in = -1.0
	iris.set_home_environment(false)
	iris.visible = true
	iris.set_gameplay_environment(true)
	home.visible = false
	witness.visible = false
	wm001_gameplay.visible = false
	flagship_gameplay.visible = false
	archive_ui.visible = false
	iris.observe()
	_emit_personality_response("witness_entered")
	
	var path := "res://content/witness/" + moment_id.to_lower() + ".json"
	var def := WitnessContentLoader.load_moment_definition(path)
	if def != null:
		generic_gameplay.start(def)
	else:
		if replayed_from_archive:
			show_archive()
		else:
			show_witness()

func _on_generic_completion_requested(result: WitnessMomentResult) -> void:
	var award := {"total": 0, "components": {}}
	if registry != null:
		registry.mark_completed(result.moment_id)
	if witness_profile != null:
		var result_dict := result.to_dictionary()
		result_dict["discovered_clues"] = generic_gameplay.evidence_found.keys()
		award = witness_profile.record_completion(result.moment_id, result_dict)
		profile_store.save_profile(witness_profile)
	
	reflective_return_pending = true
	iris.reflect()
	
	# Check if Chapter 1 has just been completely restored!
	var all_completed := true
	for id in ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005"]:
		if not registry.is_completed(id):
			all_completed = false
			break
			
	if all_completed:
		_emit_personality_response("chapter_restored")
	else:
		_emit_personality_response("witness_completed")
		
	generic_gameplay.present_reward(award, witness_profile)

func _on_generic_return_requested() -> void:
	generic_gameplay.close()
	if replayed_from_archive:
		replayed_from_archive = false
		show_archive()
	else:
		show_home()

func _process(delta: float) -> void:
	if reflective_return_in < 0.0:
		return
	reflective_return_in -= delta
	if reflective_return_in <= 0.0:
		reflective_return_in = -1.0
		reflective_return_pending = false
		if home.visible and iris.visible:
			iris.settle()
			_emit_personality_response("hub_return")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if witness.visible:
			witness._back()
		elif home.visible:
			show_iris()

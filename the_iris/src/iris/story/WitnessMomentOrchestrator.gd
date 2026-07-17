extends Node
class_name WitnessMomentOrchestrator

## Universal Witness Runtime orchestrator.
## Owns temporary active runtime state only and submits completion results to
## PlayerProgressService. It does not award progression directly.

signal phase_changed(phase: int, moment_id: String)
signal enter_requested(moment: WitnessMoment)
signal phase_started(phase_name: String, moment_id: String)
signal phase_completed(phase_name: String, data: Dictionary)
signal moment_completed(moment_id: String, result: Dictionary)
signal moment_failed(moment_id: String, reason: String)
signal return_requested(moment_id: String)
signal archive_update_requested(moment_id: String, data: Dictionary)

var director: WitnessExperienceDirector
var definition: WitnessMoment
var state: WitnessMomentState = WitnessMomentState.new()
var current_phase_screen: Control = null
var phase_data: Dictionary = {}
var accumulated_data: Dictionary = {}
var runtime_context: Dictionary = {}
var runtime_session_id := ""

const PHASE_ORDER := [
    "arriving",
    "attuning",
    "observing",
    "reconstructing",
    "investigating",
    "revealing",
    "archiving",
    "returning"
]

var _current_phase_index: int = -1
var _screen_root_ref: Control = null

func _ready() -> void:
    _resolve_screen_root()

func set_director(value: WitnessExperienceDirector) -> void:
    director = value

var sound_service: Node = null

func set_sensory_services(sound: Node) -> void:
    sound_service = sound

func start_incident(selection: Dictionary) -> void:
    if selection.is_empty():
        _fail("Witness Director returned no incident selection")
        return
    var context_value: Variant = selection.get("runtime_context", {})
    var context: Dictionary = (context_value as Dictionary).duplicate(true) if context_value is Dictionary else {}
    for key: String in ["mode", "incident_id", "memory_case_id", "moment_id", "reason"]:
        if selection.has(key) and not context.has(key):
            context[key] = selection[key]
            
    if AnalyticsService:
        var inc_id = str(selection.get("incident_id", ""))
        var ch_id = str(selection.get("selected_incident", {}).get("chapter_arc_association", ""))
        AnalyticsService.log_event("chapter_started", {
            "incident_id": inc_id,
            "chapter_id": ch_id,
            "moment_id": str(selection.get("moment_id", ""))
        })
        
    start_moment(str(selection.get("moment_id", context.get("moment_id", ""))), context)

func start_moment(moment_id: String = "WM_001", context: Dictionary = {}) -> void:
    if director == null:
        _fail("Witness Experience Director is not connected")
        return
    if moment_id.is_empty():
        var selection := director.get_next_incident(context)
        if selection.is_empty():
            _fail("Witness Director could not select an incident")
            return
        start_incident(selection)
        return
    var selected: WitnessMoment = director.select_moment(moment_id)
    if selected == null:
        _fail("Witness Moment is unavailable: %s" % moment_id)
        return

    definition = selected
    runtime_context = context.duplicate(true)
    if not runtime_context.has("mode"):
        runtime_context["mode"] = "story"
    if not runtime_context.has("incident_id"):
        runtime_context["incident_id"] = "incident_%s" % definition.moment_id.to_lower()
    if not runtime_context.has("memory_case_id"):
        runtime_context["memory_case_id"] = "memory_%s" % definition.moment_id.to_lower()
    runtime_context["moment_id"] = definition.moment_id
    runtime_session_id = "witness_%s_%d" % [definition.moment_id.to_lower(), Time.get_ticks_usec()]

    state = WitnessMomentState.new()
    state.moment_id = definition.moment_id
    state.moment_version = 1
    state.phase = WitnessMomentState.Phase.ARRIVING
    state.started_at_ms = Time.get_ticks_msec()
    state.production_route = str(runtime_context.get("mode", "story"))
    state.production_session_id = runtime_session_id
    accumulated_data.clear()
    phase_data.clear()
    phase_data["context"] = runtime_context.duplicate(true)

    _emit_phase()
    enter_requested.emit(definition)
    if AnalyticsService:
        AnalyticsService.log_event("witness_moment_started", {
            "moment_id": definition.moment_id,
            "chapter_id": definition.chapter_id,
            "incident_id": runtime_context.get("incident_id", "")
        })

func notify_witness_surface_ready() -> void:
    if definition == null:
        return
    if state.phase == WitnessMomentState.Phase.ARRIVING:
        _advance_to_phase("attuning")

func request_return() -> void:
    if definition == null:
        return
    state.phase = WitnessMomentState.Phase.RETURNING
    _emit_phase()
    return_requested.emit(definition.moment_id)
    _return_to_iris()

func get_snapshot() -> Dictionary:
    var snapshot := state.snapshot()
    snapshot["runtime_session_id"] = runtime_session_id
    snapshot["runtime_context"] = runtime_context.duplicate(true)
    snapshot["phase_data_keys"] = phase_data.keys()
    return snapshot

func is_active() -> bool:
    return definition != null and state.phase not in [WitnessMomentState.Phase.DORMANT, WitnessMomentState.Phase.COMPLETED, WitnessMomentState.Phase.FAILED]

func _advance_to_phase(phase_name: String) -> void:
    var idx = PHASE_ORDER.find(phase_name)
    if idx == -1:
        _fail("Unknown phase: %s" % phase_name)
        return

    _current_phase_index = idx
    _clear_current_screen()

    match phase_name:
        "arriving":
            _enter_arriving()
        "attuning":
            _enter_attuning()
        "observing":
            _enter_observing()
        "reconstructing":
            _enter_reconstructing()
        "investigating":
            _enter_investigating()
        "revealing":
            _enter_revealing()
        "archiving":
            _enter_archiving()
        "returning":
            _enter_returning()
        _:
            _fail("Unhandled phase: %s" % phase_name)

func _enter_arriving() -> void:
    state.phase = WitnessMomentState.Phase.ARRIVING
    _emit_phase()
    get_tree().create_timer(0.5).timeout.connect(func(): _advance_to_phase("attuning"))

func _enter_attuning() -> void:
    state.phase = WitnessMomentState.Phase.ATTUNING
    state.beat_index = 1
    _emit_phase()
    phase_started.emit("attuning", state.moment_id)
    get_tree().create_timer(1.0).timeout.connect(func(): _advance_to_phase("observing"))

func _enter_observing() -> void:
    var screen = _instantiate_screen("res://src/ui/screens/WitnessObservationScreen.tscn")
    if screen == null:
        _fail("Observation phase screen could not be loaded")
        return
    state.phase = WitnessMomentState.Phase.OBSERVING
    state.beat_index = 2
    _emit_phase()
    phase_started.emit("observing", state.moment_id)
    screen.observation_complete.connect(_on_observation_complete)
    screen.phase_failed.connect(_fail)
    _mount_phase_screen(screen)
    if not screen.is_node_ready():
        await screen.ready
    screen.configure(definition)
    screen.begin()

func _on_observation_complete(data: Dictionary) -> void:
    phase_data["observation"] = data.duplicate(true)
    phase_completed.emit("observing", data)
    if AnalyticsService:
        AnalyticsService.log_event("observation_completed", {
            "moment_id": state.moment_id,
            "duration": data.get("observation_duration", 0)
        })
    _advance_to_phase("reconstructing")

func _enter_reconstructing() -> void:
    var screen = _instantiate_screen("res://src/ui/screens/WitnessReconstructionScreen.tscn")
    if screen == null:
        _fail("Reconstruction phase screen could not be loaded")
        return
    state.phase = WitnessMomentState.Phase.RECONSTRUCTING
    state.beat_index = 3
    _emit_phase()
    phase_started.emit("reconstructing", state.moment_id)
    screen.reconstruction_complete.connect(_on_reconstruction_complete)
    screen.phase_failed.connect(_fail)
    _mount_phase_screen(screen)
    if not screen.is_node_ready():
        await screen.ready
    screen.configure(definition)
    screen.begin()

func _on_reconstruction_complete(data: Dictionary) -> void:
    phase_data["reconstruction"] = data.duplicate(true)
    phase_completed.emit("reconstructing", data)
    if AnalyticsService:
        AnalyticsService.log_event("recall_answer_submitted", {
            "moment_id": state.moment_id,
            "phase": "reconstruction",
            "placed_fragments_count": data.get("placed_fragments", {}).size()
        })
    _advance_to_phase("investigating")

func _enter_investigating() -> void:
    var screen = _instantiate_screen("res://src/ui/screens/WitnessInvestigationScreen.tscn")
    if screen == null:
        _fail("Investigation phase screen could not be loaded")
        return
    state.phase = WitnessMomentState.Phase.INVESTIGATING
    state.beat_index = 4
    _emit_phase()
    phase_started.emit("investigating", state.moment_id)
    screen.investigation_complete.connect(_on_investigation_complete)
    screen.phase_failed.connect(_fail)
    _mount_phase_screen(screen)
    if not screen.is_node_ready():
        await screen.ready
    screen.configure(definition)
    screen.begin()

func _on_investigation_complete(data: Dictionary) -> void:
    phase_data["investigation"] = data.duplicate(true)
    phase_completed.emit("investigating", data)
    if AnalyticsService:
        AnalyticsService.log_event("incident_identified", {
            "moment_id": state.moment_id,
            "completed_attunements": data.get("completed_attunements", []).size()
        })
    _advance_to_phase("revealing")

func _enter_revealing() -> void:
    var screen = _instantiate_screen("res://src/ui/screens/WitnessRevelationScreen.tscn")
    if screen == null:
        _fail("Revelation phase screen could not be loaded")
        return
    state.phase = WitnessMomentState.Phase.REVEALING
    state.beat_index = 5
    _emit_phase()
    phase_started.emit("revealing", state.moment_id)
    screen.revelation_complete.connect(_on_revelation_complete)
    screen.phase_failed.connect(_fail)
    _mount_phase_screen(screen)
    if not screen.is_node_ready():
        await screen.ready
    screen.configure(definition)
    screen.set_meta("reconstruction_data", phase_data.get("reconstruction", {}))
    screen.set_meta("investigation_data", phase_data.get("investigation", {}))
    screen.begin()

func _on_revelation_complete(data: Dictionary) -> void:
    phase_data["revelation"] = data.duplicate(true)
    phase_completed.emit("revealing", data)
    _advance_to_phase("archiving")

func _enter_archiving() -> void:
    state.phase = WitnessMomentState.Phase.ARCHIVING
    state.beat_index = 6
    _emit_phase()

    var result := _build_runtime_result()
    var result_data := result.to_dictionary()
    if PlayerProgressService:
        PlayerProgressService.record_witness_runtime_result(result_data)
    archive_update_requested.emit(state.moment_id, result_data)

    state.result_committed = true
    state.phase = WitnessMomentState.Phase.COMPLETED
    _emit_phase()
    moment_completed.emit(state.moment_id, result_data)
    definition = null
    _clear_current_screen()

func _enter_returning() -> void:
    state.phase = WitnessMomentState.Phase.RETURNING
    _emit_phase()
    _return_to_iris()

func _build_runtime_result() -> WitnessRuntimeResult:
    var result := WitnessRuntimeResult.new()
    var rewards: Dictionary = definition.rewards if definition else {}
    var reconstruction: Dictionary = phase_data.get("reconstruction", {})
    var investigation: Dictionary = phase_data.get("investigation", {})
    var revelation: Dictionary = phase_data.get("revelation", {})
    var placed_fragments: Dictionary = reconstruction.get("placed_fragments", {})
    var ghost_outlines: Array = reconstruction.get("ghost_outlines", [])
    var completed_attunements: Array = investigation.get("completed_attunements", [])
    var total_attunements := int(investigation.get("total_attunements", maxi(completed_attunements.size(), 1)))
    var reconstruction_ratio := float(placed_fragments.size()) / maxf(float(maxi(ghost_outlines.size(), 1)), 1.0)
    var reasoning_ratio := float(completed_attunements.size()) / maxf(float(maxi(total_attunements, 1)), 1.0)

    result.runtime_session_id = runtime_session_id
    result.mode = str(runtime_context.get("mode", "story"))
    result.incident_id = str(runtime_context.get("incident_id", "incident_%s" % state.moment_id.to_lower()))
    result.memory_case_id = str(runtime_context.get("memory_case_id", "memory_%s" % state.moment_id.to_lower()))
    result.moment_id = state.moment_id
    result.title = definition.title if definition else state.moment_id
    result.content_version = str(runtime_context.get("content_version", "1"))
    result.started_at_ms = state.started_at_ms
    result.completed_at_ms = Time.get_ticks_msec()
    result.completion_time_ms = maxi(result.completed_at_ms - result.started_at_ms, 0)
    result.completion_status = "completed"
    result.observation_score = 100 if phase_data.has("observation") else 0
    result.reconstruction_score = int(round(reconstruction_ratio * 100.0))
    result.reasoning_score = int(round(reasoning_ratio * 100.0))
    result.accuracy_score = int(round(float(result.observation_score + result.reconstruction_score + result.reasoning_score) / 3.0))
    result.insight_score = int(rewards.get("progress_points", 0))
    result.completion_quality = "complete" if result.accuracy_score >= 50 else "partial"
    result.discovered_clues = completed_attunements.duplicate(true)
    result.mastery_delta = (rewards.get("mastery", {}) as Dictionary).duplicate(true) if rewards.get("mastery", {}) is Dictionary else {}
    result.achievement_ids = (rewards.get("achievements", []) as Array).duplicate(true) if rewards.get("achievements", []) is Array else []
    result.archive_payload = {
        "id": state.moment_id,
        "title": definition.archive_mapping.get("title", definition.title) if definition else state.moment_id,
        "category": definition.archive_mapping.get("category", definition.chapter_id) if definition else "witness",
        "carried_fragments": placed_fragments.duplicate(true),
        "attunements": completed_attunements.duplicate(true),
        "iris_note": definition.archive_mapping.get("iris_note", "") if definition else "",
        "revelation": revelation.duplicate(true)
    }
    result.iris_evolution_inputs = {
        "moment_id": state.moment_id,
        "incident_id": result.incident_id,
        "completion_quality": result.completion_quality,
        "insight_score": result.insight_score,
        "mastery_delta": result.mastery_delta.duplicate(true)
    }
    result.raw_phase_outputs = phase_data.duplicate(true)
    return result

func _return_to_iris() -> void:
    if NavigationService:
        NavigationService.navigate_to("home")

func _instantiate_screen(scene_path: String) -> Control:
    if not ResourceLoader.exists(scene_path):
        push_error("Witness Moment screen not found: %s" % scene_path)
        return null
    var packed: PackedScene = load(scene_path)
    if packed == null:
        push_error("Failed to load screen: %s" % scene_path)
        return null
    var screen = packed.instantiate() as Control
    if screen == null:
        push_error("Screen root is not a Control: %s" % scene_path)
        return null
    return screen

func _mount_phase_screen(screen: Control) -> void:
    _clear_current_screen()
    current_phase_screen = screen
    if sound_service:
        screen.set_meta("sound_service", sound_service)
    _resolve_screen_root()
    if _screen_root_ref:
        _screen_root_ref.add_child(screen)
        screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    else:
        add_child(screen)
        screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _clear_current_screen() -> void:
    if is_instance_valid(current_phase_screen):
        current_phase_screen.queue_free()
    current_phase_screen = null

func _resolve_screen_root() -> void:
    if _screen_root_ref and is_instance_valid(_screen_root_ref):
        return
    var parent_node := get_parent()
    if parent_node:
        _screen_root_ref = parent_node.get_node_or_null("Interface/ScreenRoot") as Control
    if _screen_root_ref == null and get_tree().root.has_node("Main/Interface/ScreenRoot"):
        _screen_root_ref = get_tree().root.get_node("Main/Interface/ScreenRoot") as Control
    if _screen_root_ref == null and get_tree().root.has_node("Interface/ScreenRoot"):
        _screen_root_ref = get_tree().root.get_node("Interface/ScreenRoot") as Control
    if _screen_root_ref == null and get_tree().root.has_node("ScreenRoot"):
        _screen_root_ref = get_tree().root.get_node("ScreenRoot") as Control

func _emit_phase() -> void:
    phase_changed.emit(state.phase, state.moment_id)

func _fail(reason: String) -> void:
    var failed_id: String = definition.moment_id if definition else ""
    state.phase = WitnessMomentState.Phase.FAILED
    moment_failed.emit(failed_id, reason)
    _emit_phase()
    _clear_current_screen()
    definition = null

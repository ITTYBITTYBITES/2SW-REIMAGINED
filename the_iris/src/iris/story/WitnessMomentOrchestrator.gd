extends Node
class_name WitnessMomentOrchestrator

## Direct orchestration of Witness Moment phases using new screens.
## Replaces the legacy ProductionWitnessHost -> ChallengeSessionService pipeline for WM_001.

signal phase_changed(phase: int, moment_id: String)
signal enter_requested(moment: WitnessMoment)
signal phase_started(phase_name: String, moment_id: String)
signal phase_completed(phase_name: String, data: Dictionary)
signal moment_completed(moment_id: String, result: Dictionary)
signal moment_failed(moment_id: String, reason: String)
signal return_requested(moment_id: String)
signal archive_update_requested(moment_id: String, data: Dictionary)

@onready var screen_root: Control = get_tree().root.get_node("Interface/ScreenRoot") if get_tree().root.has_node("Interface/ScreenRoot") else null

var director: WitnessExperienceDirector
var definition: WitnessMoment
var state: WitnessMomentState = WitnessMomentState.new()
var current_phase_screen: Control = null
var phase_data: Dictionary = {}
var accumulated_data: Dictionary = {}

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
    # Find screen root
    if get_tree().root.has_node("Interface/ScreenRoot"):
        _screen_root_ref = get_tree().root.get_node("Interface/ScreenRoot")
    elif get_tree().root.has_node("ScreenRoot"):
        _screen_root_ref = get_tree().root.get_node("ScreenRoot")

func set_director(value: WitnessExperienceDirector) -> void:
    director = value

func start_moment(moment_id: String = "WM_001") -> void:
    if director == null:
        _fail("Witness Experience Director is not connected")
        return
    var selected: WitnessMoment = director.select_moment(moment_id)
    if selected == null:
        _fail("Witness Moment is unavailable: %s" % moment_id)
        return
    
    definition = selected
    state = WitnessMomentState.new()
    state.moment_id = definition.moment_id
    state.moment_version = 1
    state.phase = WitnessMomentState.Phase.ARRIVING
    state.started_at_ms = Time.get_ticks_msec()
    accumulated_data.clear()
    phase_data.clear()
    
    _emit_phase()
    enter_requested.emit(definition)
    
    # Begin first phase after a brief moment
    get_tree().create_timer(0.1).timeout.connect(func(): _advance_to_phase("attuning"))

func notify_witness_surface_ready() -> void:
    """Called when the Witness screen is visible and ready."""
    if definition == null:
        return
    # Transition from attuning to observing
    _advance_to_phase("observing")

func request_return() -> void:
    if definition == null:
        return
    state.phase = WitnessMomentState.Phase.RETURNING
    _emit_phase()
    return_requested.emit(definition.moment_id)
    _return_to_iris()

func get_snapshot() -> Dictionary:
    return state.snapshot()

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
    # Arriving is handled by StoryMode -> Witness transition
    get_tree().create_timer(0.5).timeout.connect(func(): _advance_to_phase("attuning"))

func _enter_attuning() -> void:
    state.phase = WitnessMomentState.Phase.ATTUNING
    state.beat_index = 1
    _emit_phase()
    phase_started.emit("attuning", state.moment_id)
    # Attuning is the brief moment on the Witness screen before observation
    # The actual attunement prompt is inside the Observation screen
    get_tree().create_timer(1.0).timeout.connect(func(): _advance_to_phase("observing"))

func _enter_observing() -> void:
    state.phase = WitnessMomentState.Phase.OBSERVING
    state.beat_index = 2
    _emit_phase()
    phase_started.emit("observing", state.moment_id)
    
    var screen = _instantiate_screen("res://src/ui/screens/WitnessObservationScreen.tscn")
    if screen:
        screen.configure(definition)
        screen.observation_complete.connect(_on_observation_complete)
        screen.phase_failed.connect(_fail)
        _mount_phase_screen(screen)
        screen.begin()

func _on_observation_complete() -> void:
    phase_completed.emit("observing", {"moment_id": state.moment_id})
    _advance_to_phase("reconstructing")

func _enter_reconstructing() -> void:
    state.phase = WitnessMomentState.Phase.RECONSTRUCTING
    state.beat_index = 3
    _emit_phase()
    phase_started.emit("reconstructing", state.moment_id)
    
    var screen = _instantiate_screen("res://src/ui/screens/WitnessReconstructionScreen.tscn")
    if screen:
        screen.configure(definition)
        screen.reconstruction_complete.connect(_on_reconstruction_complete)
        screen.phase_failed.connect(_fail)
        _mount_phase_screen(screen)
        screen.begin()

func _on_reconstruction_complete(data: Dictionary) -> void:
    phase_data["reconstruction"] = data
    phase_completed.emit("reconstructing", data)
    _advance_to_phase("investigating")

func _enter_investigating() -> void:
    state.phase = WitnessMomentState.Phase.INVESTIGATING
    state.beat_index = 4
    _emit_phase()
    phase_started.emit("investigating", state.moment_id)
    
    var screen = _instantiate_screen("res://src/ui/screens/WitnessInvestigationScreen.tscn")
    if screen:
        screen.configure(definition)
        screen.investigation_complete.connect(_on_investigation_complete)
        screen.phase_failed.connect(_fail)
        _mount_phase_screen(screen)
        screen.begin()

func _on_investigation_complete(data: Dictionary) -> void:
    phase_data["investigation"] = data
    phase_completed.emit("investigating", data)
    _advance_to_phase("revealing")

func _enter_revealing() -> void:
    state.phase = WitnessMomentState.Phase.REVEALING
    state.beat_index = 5
    _emit_phase()
    phase_started.emit("revealing", state.moment_id)
    
    var screen = _instantiate_screen("res://src/ui/screens/WitnessRevelationScreen.tscn")
    if screen:
        screen.configure(definition)
        # Store phase data for the screen to access
        screen.set_meta("reconstruction_data", phase_data.get("reconstruction", {}))
        screen.set_meta("investigation_data", phase_data.get("investigation", {}))
        screen.revelation_complete.connect(_on_revelation_complete)
        screen.phase_failed.connect(_fail)
        _mount_phase_screen(screen)
        screen.begin()

func _on_revelation_complete(data: Dictionary) -> void:
    phase_data["revelation"] = data
    phase_completed.emit("revealing", data)
    _advance_to_phase("archiving")

func _enter_archiving() -> void:
    state.phase = WitnessMomentState.Phase.ARCHIVING
    state.beat_index = 6
    _emit_phase()
    
    # Update profile and archive
    _commit_to_archive()
    
    state.phase = WitnessMomentState.Phase.COMPLETED
    _emit_phase()
    moment_completed.emit(state.moment_id, phase_data)
    definition = null

func _enter_returning() -> void:
    state.phase = WitnessMomentState.Phase.RETURNING
    _emit_phase()
    _return_to_iris()

func _commit_to_archive() -> void:
    # Update profile via ProfileService using existing structure
    if ProfileService:
        var rewards = definition.rewards if definition else {}
        var points = rewards.get("progress_points", 12)
        
        # Add Insight (triggers progression logic)
        ProfileService.add_xp(points)
        
        # Preserve memory markers
        for ach: Variant in rewards.get("achievements", []):
            var achievements: Array = ProfileService.profile.get("achievements", []) as Array
            if not achievements.has(ach):
                achievements.append(ach)
                ProfileService.profile["achievements"] = achievements
        
        # Add archive entry to a witness-specific field
        var archive: Array = ProfileService.profile.get("witness_archive", []) as Array
        var entry: Dictionary = {
            "id": definition.moment_id,
            "title": definition.archive_mapping.get("title", definition.title),
            "category": definition.archive_mapping.get("category", definition.chapter_id),
            "completed_at": Time.get_unix_time_from_system(),
            "carried_fragments": phase_data.get("reconstruction", {}).get("placed_fragments", {}),
            "attunements": phase_data.get("investigation", {}).get("completed_attunements", []),
            "iris_note": definition.archive_mapping.get("iris_note", "")
        }
        archive.append(entry)
        ProfileService.profile["witness_archive"] = archive
        
        # Track completed moments count
        var completed = ProfileService.profile.get("witness_moments_completed", 0)
        ProfileService.profile["witness_moments_completed"] = completed + 1
        
        # Track discoveries
        if phase_data.get("investigation", {}).get("discovery_threshold_reached", false):
            var discoveries = ProfileService.profile.get("witness_discoveries", 0)
            ProfileService.profile["witness_discoveries"] = discoveries + 1
        
        ProfileService.save()
    
    # Also emit for any listeners
    archive_update_requested.emit(state.moment_id, phase_data)

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
    
    if _screen_root_ref:
        _screen_root_ref.add_child(screen)
        screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    else:
        # Fallback: add to self's viewport
        get_viewport().get_canvas_layer().add_child(screen)
        screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _clear_current_screen() -> void:
    if is_instance_valid(current_phase_screen):
        current_phase_screen.queue_free()
    current_phase_screen = null

func _emit_phase() -> void:
    phase_changed.emit(state.phase, state.moment_id)

func _fail(reason: String) -> void:
    var failed_id: String = definition.moment_id if definition else ""
    state.phase = WitnessMomentState.Phase.FAILED
    moment_failed.emit(failed_id, reason)
    _emit_phase()
    _clear_current_screen()
    definition = null
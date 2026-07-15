extends Control
class_name ProductionWitnessHost

signal request_home
signal production_phase(phase: String, params: Dictionary)
signal production_result_ready(result: Dictionary)
signal production_failed(reason: String)

var bridge: TwoSecondWitnessProductionBridge
var active_production_screen: Control
var pending_start := false
var started := false
var current_definition: WitnessMoment

const EXPERIENCE_ROUTES := {
    "tutorial": "res://src/ui/screens/TutorialScreen.tscn",
    "observation": "res://src/ui/screens/ObservationChallengeScreen.tscn",
    "memory_question": "res://src/ui/screens/MemoryQuestionScreen.tscn",
    "result": "res://src/ui/screens/ResultScreen.tscn"
}

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 100
    if NavigationService and not NavigationService.route_changed.is_connected(_on_production_route_changed):
        NavigationService.route_changed.connect(_on_production_route_changed)

func set_production_bridge(value: TwoSecondWitnessProductionBridge) -> void:
    bridge = value
    if bridge and not bridge.ready_for_gameplay.is_connected(_on_production_ready):
        bridge.ready_for_gameplay.connect(_on_production_ready)

func enter() -> void:
    visible = true
    started = true
    if bridge and bridge.is_ready_for_gameplay():
        _start_production_session()
    else:
        pending_start = true

func start_moment(definition: WitnessMoment) -> void:
    current_definition = definition
    visible = true
    started = true
    if bridge and bridge.is_ready_for_gameplay():
        _start_production_session()
    else:
        pending_start = true

func exit() -> void:
    started = false
    pending_start = false
    visible = false
    _clear_production_screen()
    current_definition = null

func _on_production_ready() -> void:
    if pending_start and started:
        pending_start = false
        _start_production_session()

func _start_production_session() -> void:
    if not ChallengeSessionService:
        return
    if ChallengeSessionService.has_active_session():
        var current_route := NavigationService.current_route if NavigationService else ""
        if current_route in EXPERIENCE_ROUTES:
            _mount_route(current_route, NavigationService.current_params)
            return
        ChallengeSessionService.return_home()
    if is_instance_valid(current_definition):
        # Moment 001 uses the existing Scene Investigation template as a
        # compatibility mechanic; future definitions will carry this context
        # as authored data rather than branching in the host.
        var template_id := "office_v1"
        if current_definition.moment_id == "WM_001":
            template_id = "office_v1"
        if not ChallengeSessionService.start_template_session(template_id, "witness_story"):
            production_failed.emit("Production Witness session could not start")
    else:
        ChallengeSessionService.start_recommended_session("iris")

func _on_production_route_changed(route: String, params: Dictionary) -> void:
    if not started:
        return
    if EXPERIENCE_ROUTES.has(route):
        _mount_route(route, params)
        match route:
            "tutorial": production_phase.emit("attunement", params)
            "observation": production_phase.emit("observing", params)
            "memory_question": production_phase.emit("reconstructing", params)
            "result":
                production_phase.emit("revealing", params)
                production_result_ready.emit(params)
    elif route == "home":
        production_phase.emit("returned", params)
        request_home.emit()

func _mount_route(route: String, params: Dictionary) -> void:
    var scene_path: String = EXPERIENCE_ROUTES.get(route, "")
    if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
        production_failed.emit("Production Witness screen is unavailable: %s" % route)
        return
    _clear_production_screen()
    var packed: PackedScene = load(scene_path)
    if packed == null:
        return
    active_production_screen = packed.instantiate() as Control
    if active_production_screen == null:
        return
    active_production_screen.name = "Production_%s" % route
    active_production_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    active_production_screen.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(active_production_screen)
    if active_production_screen.has_method("on_navigated_to"):
        active_production_screen.call("on_navigated_to", params)

func _clear_production_screen() -> void:
    if is_instance_valid(active_production_screen):
        active_production_screen.queue_free()
    active_production_screen = null

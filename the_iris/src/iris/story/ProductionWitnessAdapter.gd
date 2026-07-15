extends Node
class_name ProductionWitnessAdapter

signal phase_changed(phase: String, params: Dictionary)
signal result_ready(result: Dictionary)
signal returned
signal failed(reason: String)

var host: ProductionWitnessHost

func set_host(value: ProductionWitnessHost) -> void:
    host = value
    if host == null:
        return
    if not host.production_phase.is_connected(_on_phase):
        host.production_phase.connect(_on_phase)
    if not host.production_result_ready.is_connected(_on_result):
        host.production_result_ready.connect(_on_result)
    if not host.request_home.is_connected(_on_returned):
        host.request_home.connect(_on_returned)
    if not host.production_failed.is_connected(_on_failed):
        host.production_failed.connect(_on_failed)

func start(definition: WitnessMoment) -> void:
    if host == null:
        failed.emit("Production Witness host is not connected")
        return
    host.start_moment(definition)

func return_home() -> void:
    if ChallengeSessionService and ChallengeSessionService.has_active_session():
        ChallengeSessionService.return_home()
    elif NavigationService:
        NavigationService.navigate_to("home")

func _on_phase(phase: String, params: Dictionary) -> void:
    phase_changed.emit(phase, params)

func _on_result(result: Dictionary) -> void:
    result_ready.emit(result)

func _on_returned() -> void:
    returned.emit()

func _on_failed(reason: String) -> void:
    failed.emit(reason)

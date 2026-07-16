extends Node
class_name WitnessMomentRuntime

signal phase_changed(phase: int, moment_id: String)
signal enter_requested(moment: WitnessMoment)
signal production_start_requested(moment: WitnessMoment)
signal result_received(result: Dictionary)
signal archive_update_requested(moment_id: String, result: Dictionary)
signal return_requested(moment_id: String)
signal runtime_completed(moment_id: String)
signal runtime_failed(moment_id: String, reason: String)

@onready var production_adapter: ProductionWitnessAdapter = $ProductionWitnessAdapter

var director: WitnessExperienceDirector
var definition: WitnessMoment
var state: WitnessMomentState = WitnessMomentState.new()
var last_result: Dictionary = {}

func _ready() -> void:
    production_adapter.phase_changed.connect(_on_production_phase)
    production_adapter.result_ready.connect(_on_production_result)
    production_adapter.returned.connect(_on_production_returned)
    production_adapter.failed.connect(_on_production_failed)

func set_director(value: WitnessExperienceDirector) -> void:
    director = value

func set_production_host(host: ProductionWitnessHost) -> void:
    production_adapter.set_host(host)

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
    _emit_phase()
    enter_requested.emit(definition)

func notify_witness_surface_ready() -> void:
    if definition == null:
        return
    state.phase = WitnessMomentState.Phase.ATTUNING
    state.beat_index = 1
    _emit_phase()
    production_start_requested.emit(definition)
    production_adapter.start(definition)

func request_return() -> void:
    if definition == null:
        return
    state.phase = WitnessMomentState.Phase.RETURNING
    _emit_phase()
    return_requested.emit(definition.moment_id)
    production_adapter.return_home()

func get_snapshot() -> Dictionary:
    return state.snapshot()

func is_active() -> bool:
    return definition != null and state.phase not in [WitnessMomentState.Phase.DORMANT, WitnessMomentState.Phase.COMPLETED, WitnessMomentState.Phase.FAILED]

func _on_production_phase(phase: String, _params: Dictionary) -> void:
    match phase:
        "attunement": state.phase = WitnessMomentState.Phase.ATTUNING
        "observing": state.phase = WitnessMomentState.Phase.OBSERVING
        "reconstructing": state.phase = WitnessMomentState.Phase.RECONSTRUCTING
        "revealing": state.phase = WitnessMomentState.Phase.REVEALING
        "returned": state.phase = WitnessMomentState.Phase.RETURNING
        _:
            return
    state.beat_index += 1
    _emit_phase()

func _on_production_result(result: Dictionary) -> void:
    last_result = result.duplicate(true)
    state.result_committed = true
    state.phase = WitnessMomentState.Phase.REVEALING
    result_received.emit(last_result)
    _emit_phase()

func _on_production_returned() -> void:
    if definition == null:
        return
    state.phase = WitnessMomentState.Phase.ARCHIVING
    _emit_phase()
    archive_update_requested.emit(definition.moment_id, last_result)
    state.phase = WitnessMomentState.Phase.COMPLETED
    _emit_phase()
    runtime_completed.emit(definition.moment_id)
    definition = null

func _on_production_failed(reason: String) -> void:
    _fail(reason)

func _emit_phase() -> void:
    phase_changed.emit(state.phase, state.moment_id)

func _fail(reason: String) -> void:
    var failed_id: String = definition.moment_id if definition else ""
    state.phase = WitnessMomentState.Phase.FAILED
    runtime_failed.emit(failed_id, reason)
    _emit_phase()

extends Control
class_name PrototypeApplication

## Clean-room application composition: boot → Iris → Iris Home → Witness.
var registry: IncidentRegistry
var director: WitnessExperienceDirector
var orchestrator: WitnessMomentOrchestrator
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var witness: WitnessChapters
var startup: StartupFlow
var boot_introduction_pending := false
var memory_focus_active := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	registry = IncidentRegistry.new()
	registry.name = "IncidentRegistry"
	registry.load_catalogue()
	add_child(registry)
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
	iris.iris_core.state_changed.connect(_on_iris_core_state_changed)

	iris_personality = IrisPersonalityResolver.new()
	iris_personality.name = "IrisPersonalityResolver"
	add_child(iris_personality)

	home = IrisHome.new()
	home.name = "IrisHome"
	home.witness_requested.connect(show_witness)
	home.iris_requested.connect(show_iris)
	home.memory_intent_focused.connect(_on_home_memory_intent_focused)
	home.memory_intent_released.connect(_on_home_memory_intent_released)
	home.memory_selected.connect(_on_home_memory_selected)
	add_child(home)

	witness = WitnessChapters.new()
	witness.name = "WitnessChapters"
	witness.configure(registry, director, orchestrator)
	witness.home_requested.connect(show_home)
	add_child(witness)

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
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.set_home_environment(false)
	iris.visible = true
	home.visible = false
	witness.visible = false
	if from_boot:
		iris.calibrate()
	else:
		iris.welcome()

func show_home() -> void:
	# The single Living Iris remains visible as the settled center of Home.
	iris.visible = true
	iris.settle()
	iris.set_home_environment(true)
	home.visible = true
	witness.visible = false
	_emit_personality_response("hub_return")

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

func show_witness() -> void:
	iris.set_home_environment(false)
	iris.visible = false
	home.visible = false
	witness.visible = true
	iris.observe()
	_emit_personality_response("witness_entered")
	witness.show_chapters()

func _on_witness_moment_completed(_moment_id: String) -> void:
	iris.reflect()
	_emit_personality_response("witness_completed")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if witness.visible:
			witness._back()
		elif home.visible:
			show_iris()

extends Control
class_name PrototypeApplication

## Clean-room application composition: boot → Iris → Iris Home → Witness.
var registry: IncidentRegistry
var director: WitnessExperienceDirector
var orchestrator: WitnessMomentOrchestrator
var iris: IrisController
var home: IrisHome
var witness: WitnessChapters
var startup: StartupFlow

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

	home = IrisHome.new()
	home.name = "IrisHome"
	home.witness_requested.connect(show_witness)
	home.iris_requested.connect(show_iris)
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
	show_iris(true)

func prepare_iris() -> void:
	iris.visible = false
	home.visible = false
	witness.visible = false
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.visible = true
	home.visible = false
	witness.visible = false
	if from_boot:
		iris.calibrate()
	else:
		iris.welcome()

func show_home() -> void:
	iris.visible = false
	home.visible = true
	witness.visible = false
	iris.settle()

func show_witness() -> void:
	iris.visible = false
	home.visible = false
	witness.visible = true
	iris.observe()
	witness.show_chapters()

func _on_witness_moment_completed(_moment_id: String) -> void:
	iris.reflect()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if witness.visible:
			witness._back()
		elif home.visible:
			show_iris()

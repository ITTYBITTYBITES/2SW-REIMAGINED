extends Control
class_name PrototypeApplication

## Platform shell plus one bespoke Missing Second experience.
var profile_store: WitnessProfileStore
var witness_profile: WitnessProfile
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var startup: StartupFlow
var iris_portal: IrisPortalTransition
var missing_second: MissingSecondExperience

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_store = WitnessProfileStore.new()
	witness_profile = profile_store.load_profile()

	iris = IrisController.new()
	iris.name = "IrisController"
	iris.home_requested.connect(show_home)
	add_child(iris)
	iris.living_iris.evolution_profile = IrisEvolutionProfile.new()

	iris_personality = IrisPersonalityResolver.new()
	iris_personality.name = "IrisPersonalityResolver"
	iris_personality.response_intent_emitted.connect(iris.present_response_intent)
	add_child(iris_personality)

	home = IrisHome.new()
	home.name = "IrisHome"
	home.witness_requested.connect(start_missing_second)
	home.iris_requested.connect(show_iris)
	add_child(home)
	home.configure(witness_profile)

	iris_portal = IrisPortalTransition.new()
	iris_portal.name = "IrisPortalTransition"
	iris_portal.configure(iris.living_iris)
	iris_portal.entry_arrived.connect(_on_portal_entry_arrived)
	iris_portal.return_arrived.connect(show_home)
	add_child(iris_portal)

	var missing_scene: PackedScene = load("res://scenes/MissingSecondExperience.tscn")
	if missing_scene != null:
		missing_second = missing_scene.instantiate() as MissingSecondExperience
		missing_second.name = "MissingSecondExperience"
		missing_second.completion_requested.connect(_on_missing_second_complete)
		missing_second.return_requested.connect(return_from_missing_second)
		add_child(missing_second)

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
	if missing_second != null:
		missing_second.visible = false
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.visible = true
	home.visible = false
	if missing_second != null:
		missing_second.visible = false
	if from_boot:
		iris.begin_awakening_ritual()
	else:
		IrisAudioConsumer.play_ambient_loop("res://assets/audio/iris/iris_breath_loop.ogg")
		iris.welcome()
		_emit_iris_event("iris_welcome")

func show_home() -> void:
	iris.visible = true
	iris.set_gameplay_environment(false)
	iris.set_home_environment(true)
	iris.settle()
	IrisAudioConsumer.play_ambient_loop("res://assets/audio/iris/iris_breath_loop.ogg")
	home.visible = true
	if missing_second != null:
		missing_second.visible = false
	_emit_iris_event("iris_return")

func start_missing_second() -> void:
	if missing_second == null or iris_portal.state != IrisPortalTransition.PortalState.READY:
		return
	iris.visible = true
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.iris_core.acquire_attention(Vector2.ZERO)
	home.visible = false
	missing_second.visible = false
	iris_portal.begin_entry("missing_second", {
		"title": "The Missing Second",
		"subtitle": "A waiting room holds one missing second."
	})

func _on_portal_entry_arrived(entry_id: String) -> void:
	if entry_id != "missing_second" or missing_second == null:
		show_home()
		return
	iris.visible = false
	missing_second.begin()

func _on_missing_second_complete() -> void:
	# The Iris receives the experience only at the threshold, never as in-memory guidance.
	iris.visible = true
	iris.set_gameplay_environment(true)
	iris.reflect()
	_emit_iris_event("iris_return")

func return_from_missing_second() -> void:
	if missing_second == null:
		show_home()
		return
	missing_second.close()
	iris.visible = true
	iris.set_gameplay_environment(false)
	iris.set_home_environment(false)
	iris_portal.begin_return()

func _emit_iris_event(event_name: String) -> void:
	if iris_personality != null:
		iris_personality.resolve(int(iris.iris_core.state), event_name)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if missing_second != null and missing_second.visible:
			return_from_missing_second()
		elif home.visible:
			show_iris()

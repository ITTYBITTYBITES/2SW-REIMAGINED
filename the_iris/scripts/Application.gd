extends Control
class_name PrototypeApplication

## Platform shell plus the Diorama-powered Experience One launch path.
##
## Flow:
##   Living Iris → Iris Home → WITNESS → Iris portal →
##   Diorama Engine → Clock Witness Experience → return → Iris
##
## The old bespoke "Missing Second" Control scene and its assets have been
## retired (experience-path reset). The Living Iris system, navigation, and
## shared platform infrastructure are retained unchanged.

const EXPERIENCE_ONE_ID := "experience_one"
const EXPERIENCE_ONE_DEFINITION_PATH := "res://content/experience_one/experience_one.json"

var profile_store: WitnessProfileStore
var witness_profile: WitnessProfile
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var startup: StartupFlow
var iris_portal: IrisPortalTransition
var diorama_engine: DioramaEngine

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
	home.witness_requested.connect(start_experience_one)
	home.iris_requested.connect(show_iris)
	add_child(home)
	home.configure(witness_profile)

	iris_portal = IrisPortalTransition.new()
	iris_portal.name = "IrisPortalTransition"
	iris_portal.configure(iris.living_iris)
	iris_portal.entry_arrived.connect(_on_portal_entry_arrived)
	iris_portal.return_arrived.connect(show_home)
	add_child(iris_portal)

	# Diorama Engine: the 3D experience renderer. Sits between the Iris portal
	# and a memory experience. Drawn beneath the portal (z_index 100) so the
	# pupil transition can bridge Iris ↔ memory cleanly.
	diorama_engine = DioramaEngine.new()
	diorama_engine.name = "DioramaEngine"
	diorama_engine.experience_completed.connect(_on_experience_one_complete)
	diorama_engine.experience_return_requested.connect(return_from_experience_one)
	add_child(diorama_engine)

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
	_hide_diorama()
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.visible = true
	home.visible = false
	_hide_diorama()
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
	_hide_diorama()
	_emit_iris_event("iris_return")

## Experience One launch: the Iris pupil opens onto the Diorama Engine, which
## then assembles and renders the experience defined in the Experience One JSON.
func start_experience_one() -> void:
	if not FileAccess.file_exists(EXPERIENCE_ONE_DEFINITION_PATH) or iris_portal.state != IrisPortalTransition.PortalState.READY:
		return
	iris.visible = true
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.iris_core.acquire_attention(Vector2.ZERO)
	home.visible = false
	_hide_diorama()
	iris_portal.begin_entry(EXPERIENCE_ONE_ID, {
		"title": "The Missing Second",
		"subtitle": "A waiting room holds one missing second."
	})

func _on_portal_entry_arrived(entry_id: String) -> void:
	if entry_id != EXPERIENCE_ONE_ID or not FileAccess.file_exists(EXPERIENCE_ONE_DEFINITION_PATH):
		show_home()
		return
	iris.visible = false
	diorama_engine.launch_experience(EXPERIENCE_ONE_DEFINITION_PATH)

func _on_experience_one_complete() -> void:
	# The Iris receives the experience only at the threshold, never in-memory.
	iris.visible = true
	iris.set_gameplay_environment(true)
	iris.reflect()
	_emit_iris_event("iris_return")

func return_from_experience_one() -> void:
	if not diorama_engine.visible:
		show_home()
		return
	diorama_engine.clear_experience()
	iris.visible = true
	iris.set_gameplay_environment(false)
	iris.set_home_environment(false)
	iris_portal.begin_return()

func _hide_diorama() -> void:
	if diorama_engine != null:
		diorama_engine.clear_experience()

func _emit_iris_event(event_name: String) -> void:
	if iris_personality != null:
		iris_personality.resolve(int(iris.iris_core.state), event_name)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if diorama_engine != null and diorama_engine.visible:
			return_from_experience_one()
		elif home.visible:
			show_iris()

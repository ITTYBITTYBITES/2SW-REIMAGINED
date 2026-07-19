extends Control
class_name PrototypeApplication

## Platform shell — routes between Living Iris and the Diorama Player.
##
## Flow:
##   Living Iris → (tap the Iris) → Iris portal →
##   DioramaPlayer (addons/diorama_engine) → Missing Second → return → Living Iris
##
## The DioramaPlayer is the reusable engine from addons/diorama_engine/.
## The Missing Second is a data-driven JSON module in content/missing_second/.
## No experience-specific knowledge lives in this script.

const EXPERIENCE_ONE_ID := "missing_second"
const EXPERIENCE_ONE_DEFINITION_PATH := "res://content/missing_second/missing_second.json"

var profile_store: WitnessProfileStore
var witness_profile: WitnessProfile
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var startup: StartupFlow
var iris_portal: IrisPortalTransition
var diorama_player: DioramaPlayer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	profile_store = WitnessProfileStore.new()
	witness_profile = profile_store.load_profile()

	iris = IrisController.new()
	iris.name = "IrisController"
	iris.home_requested.connect(start_experience_one)
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
	iris_portal.return_arrived.connect(_return_to_iris_presence)
	add_child(iris_portal)

	# Diorama Player — the cinematic 3D experience renderer.
	# Loaded from addons/diorama_engine/. Contains its own SubViewport,
	# CinematicCamera (35mm + DOF), ACES tonemapping, Glow, SSAO, SSR,
	# and key/fill lighting. Content is loaded from JSON definitions.
	diorama_player = DioramaPlayer.new()
	diorama_player.name = "DioramaPlayer"
	diorama_player.experience_completed.connect(_on_experience_complete)
	diorama_player.experience_return_requested.connect(return_from_experience)
	add_child(diorama_player)

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

## Experience launch: the Iris pupil opens onto the Diorama Player, which
## reads the JSON definition and assembles the cinematic 3D scene.
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
		_return_to_iris_presence()
		return
	iris.visible = false
	diorama_player.load_and_play(EXPERIENCE_ONE_DEFINITION_PATH)

func _on_experience_complete(_experience_id: String) -> void:
	iris.visible = true
	iris.set_gameplay_environment(true)
	iris.reflect()
	# A truth has been witnessed: flare the SUCCESS mood, then settle.
	iris.trigger_success_mood()
	_emit_iris_event("iris_return")

func return_from_experience() -> void:
	if not diorama_player.is_playing():
		_return_to_iris_presence()
		return
	diorama_player.stop()
	iris.visible = true
	iris.set_gameplay_environment(false)
	iris.set_home_environment(false)
	iris_portal.begin_return()

func _return_to_iris_presence() -> void:
	iris.visible = true
	iris.set_gameplay_environment(false)
	iris.set_home_environment(false)
	iris.settle()
	IrisAudioConsumer.play_ambient_loop("res://assets/audio/iris/iris_breath_loop.ogg")
	home.visible = false
	_hide_diorama()
	_emit_iris_event("iris_return")

func _hide_diorama() -> void:
	if diorama_player != null:
		diorama_player.stop()

func _emit_iris_event(event_name: String) -> void:
	if iris_personality != null:
		iris_personality.resolve(int(iris.iris_core.state), event_name)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if diorama_player != null and diorama_player.is_playing():
			return_from_experience()
		elif home.visible:
			show_iris()

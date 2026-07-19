extends Control
class_name PrototypeApplication

## Platform shell retained after the Witness gameplay reset.
var profile_store: WitnessProfileStore
var witness_profile: WitnessProfile
var iris: IrisController
var iris_personality: IrisPersonalityResolver
var home: IrisHome
var startup: StartupFlow
var reset_view: Control

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
	home.witness_requested.connect(show_witness_reset)
	home.iris_requested.connect(show_iris)
	add_child(home)
	home.configure(witness_profile)

	reset_view = _create_reset_view()
	reset_view.name = "WitnessResetView"
	add_child(reset_view)

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
	reset_view.visible = false
	iris.dormant()

func show_iris(from_boot := false) -> void:
	iris.set_home_environment(false)
	iris.set_gameplay_environment(false)
	iris.visible = true
	home.visible = false
	reset_view.visible = false
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
	reset_view.visible = false
	_emit_iris_event("iris_return")

func show_witness_reset() -> void:
	# Intentional empty entry state. The first bespoke experience is not yet wired.
	iris.visible = true
	iris.set_home_environment(false)
	iris.set_gameplay_environment(true)
	iris.observe()
	home.visible = false
	reset_view.visible = true

func _emit_iris_event(event_name: String) -> void:
	if iris_personality != null:
		iris_personality.resolve(int(iris.iris_core.state), event_name)

func _create_reset_view() -> Control:
	var view := Control.new()
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.visible = false
	var veil := ColorRect.new()
	veil.color = Color(0.002, 0.012, 0.016, 0.68)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_child(veil)
	var title := _label("WITNESS", 27, Color("#effff8"), Vector2(32, 150), Vector2(476, 46))
	view.add_child(title)
	var body := _label("A new Witness experience is being built from one complete moment outward. The Iris remains open.", 16, Color("#cde7de"), Vector2(32, 214), Vector2(476, 90))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	view.add_child(body)
	var return_button := Button.new()
	return_button.text = "RETURN TO IRIS"
	return_button.position = Vector2(42, 790)
	return_button.size = Vector2(456, 48)
	return_button.add_theme_font_size_override("font_size", 13)
	return_button.pressed.connect(show_home)
	view.add_child(return_button)
	return view

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if reset_view.visible:
			show_home()
		elif home.visible:
			show_iris()

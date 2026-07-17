extends IrisController
class_name IrisHomeScreen
## IrisHomeScreen - Production home screen centered around the Living Iris
## Clean, cinematic interface with single iris display and navigation cards

@onready var iris_visual: ColorRect = $IrisDisplay/IrisContainer/IrisVisual
@onready var glow_layer: TextureRect = $IrisDisplay/GlowLayer
@onready var ring1: TextureRect = $IrisDisplay/CalibrationRings/Ring1
@onready var ring2: TextureRect = $IrisDisplay/CalibrationRings/Ring2
@onready var pupil_portal: TextureRect = $IrisDisplay/AwakeningAnimation/PupilPortal
@onready var particles: CPUParticles2D = $Particles
@onready var welcome_title: Label = $WelcomePanel/WelcomeTitle
@onready var welcome_subtitle: Label = $WelcomePanel/WelcomeSubtitle
@onready var welcome_text: Label = $WelcomePanel/WelcomeText

# Navigation card references
@onready var continue_card: PanelContainer = $NavigationCards/CardsContainer/ContinueJourney
@onready var witness_card: PanelContainer = $NavigationCards/CardsContainer/WitnessChapters
@onready var progress_card: PanelContainer = $NavigationCards/CardsContainer/ProgressCard
@onready var profile_card: PanelContainer = $NavigationCards/CardsContainer/ProfileCard

# Utility bar references
@onready var audio_btn: Button = $UtilityBar/UtilityHBox/AudioButton
@onready var haptics_btn: Button = $UtilityBar/UtilityHBox/HapticsButton
@onready var help_btn: Button = $UtilityBar/UtilityHBox/HelpButton
@onready var info_btn: Button = $UtilityBar/UtilityHBox/InfoButton

# State connections
var iris_core: IrisCore
var state_manager: IrisStateManager
var navigation_controller: IrisNavigationController

# Animation state
var elapsed: float = 0.0
var awakening_level: float = 0.0
var pulse_elapsed: float = 0.0
var ring_rotation: float = 0.0

# Iris state mapping
const IRIS_STATE_MAP := {
	IrisCore.State.DORMANT: 0,
	IrisCore.State.AWARE: 1,
	IrisCore.State.FOCUSED: 2,
	IrisCore.State.SETTLED: 3
}

func _ready() -> void:
	# Initialize references
	_setup_iris_core()
	_setup_state_connections()
	_setup_navigation()
	_setup_utility_buttons()
	
	# Start animations
	set_process(true)
	_start_awakening()
	
	# Update visuals based on current state
	_update_from_state()

func _setup_iris_core() -> void:
	# Find or create IrisCore
	var existing_core = get_node_or_null("IrisCore")
	if existing_core:
		iris_core = existing_core
	else:
		iris_core = IrisCore.new()
		iris_core.name = "IrisCore"
		add_child(iris_core)
		iris_core.state_changed.connect(_on_iris_state_changed)

func _setup_state_connections() -> void:
	# Connect to StateManager if available
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		state_manager = main.get_node_or_null("StateManager")
		if state_manager:
			state_manager.state_changed.connect(_on_state_changed)
	
	# Connect to NavigationController
	if main:
		navigation_controller = main.get_node_or_null("NavigationController")

func _setup_navigation() -> void:
	# Connect card click handlers
	if continue_card:
		continue_card.gui_input.connect(_on_continue_card_input)
	if witness_card:
		witness_card.gui_input.connect(_on_witness_card_input)
	if progress_card:
		progress_card.gui_input.connect(_on_progress_card_input)
	if profile_card:
		profile_card.gui_input.connect(_on_profile_card_input)

func _setup_utility_buttons() -> void:
	if audio_btn:
		audio_btn.pressed.connect(_on_audio_pressed)
	if haptics_btn:
		haptics_btn.pressed.connect(_on_haptics_pressed)
	if help_btn:
		help_btn.pressed.connect(_on_help_pressed)
	if info_btn:
		info_btn.pressed.connect(_on_info_pressed)

func _start_awakening() -> void:
	# Trigger awakening animation
	var tween := create_tween()
	tween.tween_property(self, "awakening_level", 1.0, 2.4).set_ease(Tween.EASE_OUT)
	# Pulse the iris
	pulse_elapsed = 0.0

func _on_iris_state_changed(new_state: int) -> void:
	_update_from_state()

func _on_state_changed(new_state: int) -> void:
	_update_from_state()

func _update_from_state() -> void:
	if iris_core:
		var state := iris_core.current_state
		match state:
			IrisCore.State.DORMANT:
				_set_iris_visual_state(0.05, 0.1, 1.0)
				welcome_title.modulate.a = 0.5
				welcome_subtitle.modulate.a = 0.4
				welcome_text.modulate.a = 0.3
			WitnessChapters
			IrisCore.State.AWARE:
				_set_iris_visual_state(0.35, 0.4, 1.0)
				welcome_title.modulate.a = 0.8
				welcome_subtitle.modulate.a = 0.7
				welcome_text.modulate.a = 0.6
			IrisCore
			IrisCore.State.FOCUSED:
				_set_iris_visual_state(0.62, 0.8, 1.0)
				welcome_title.modulate.a = 1.0
				welcome_subtitle.modulate.a = 0.9
				welcome_text.modulate.a = 0.8
				# Highlight active card
				continue_card.modulate = Color(1, 1, 1, 0.95)
				witness_card.modulate = Color(1, 1, 1, 0.75)
				progress_card.modulate = Color(1, 1, 1, 0.75)
				profile_card.modulate = Color(1, 1, 1, 0.75)
			IrisCore.State.SETTLED:
				_set_iris_visual_state(0.18, 0.5, 1.0)
				welcome_title.modulate.a = 1.0
				welcome_subtitle.modulate.a = 1.0

func _set_iris_visual_state(energy: float, glow: float, particle_scale: float) -> void:
	# Update shader parameters
	if iris_visual and iris_visual.material is ShaderMaterial:
		var shader_mat := iris_visual.material as ShaderMaterial
		shader_mat.set_shader_parameter("energy", energy)
		shader_mat.set_shader_parameter("glow_strength", glow)
	
	# Update glow layer
	if glow_layer:
		glow_layer.modulate.a = glow * 0.45
	
	# Update particles
	if particles:
		particles.amount = int(18 * particle_scale)

func _process(delta: float) -> void:
	elapsed += delta
	pulse_elapsed += delta
	
	# Animate rings
	ring_rotation += delta * 0.15
	if ring1:
		ring1.rotation = ring_rotation * 0.5
	if ring2:
		ring2.rotation = ring_rotation * 0.3
	
	# Animate ambient glow
	if glow_layer:
		var glow_pulse := 0.35 + sin(elapsed * 2.0) * 0.05
		glow_layer.modulate.a = glow_pulse * awakening_level
		glow_layer.scale = Vector2(1.0 + sin(elapsed * 0.6) * 0.03, 1.0 + sin(elapsed * 0.6) * 0.03)
	
	# Animate pupil portal
	if pupil_portal:
		pupil_portal.modulate.a = 0.85 * awakening_level
		pupil_portal.scale = Vector2(1.0 + sin(elapsed * 1.2) * 0.05, 1.0 + sin(elapsed * 1.2) * 0.05)
	
	# Subtle breathing for welcome text
	if welcome_title:
		welcome_title.position.y = 50.0 + sin(elapsed * 0.8) * 2.0
	if welcome_subtitle:
		welcome_subtitle.position.y = 94.0 + sin(elapsed * 0.8) * 2.0
	if welcome_text:
		welcome_text.position.y = 134.0 + sin(elapsed * 0.8) * 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_on_tap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap(event.position)

func _on_tap(position: Vector2) -> void:
	# Check if tap is on a navigation card
	var view_size := get_viewport_rect().size
	var normalized := Vector2(position.x / view_size.x, position.y / view_size.y)
	
	# Card positions (normalized)
	var card_width := 140.0 / view_size.x
	var card_height := 160.0 / view_size.y
	var card_y := 700.0 / view_size.y
	
	# Continue Journey card (first card)
	var card1_x := 48.0 / view_size.x
	if normalized.x >= card1_x and normalized.x <= card1_x + card_width and normalized.y >= card_y and normalized.y <= card_y + card_height:
		_on_continue_journey()
		return
	
	# Witness Chapters card
	var card2_x := card1_x + card_width + (16.0 / view_size.x)
	if normalized.x >= card2_x and normalized.x <= card2_x + card_width and normalized.y >= card_y and normalized.y <= card_y + card_height:
		_on_witness_chapters()
		return
	
	# Progress card
	var card3_x := card2_x + card_width + (16.0 / view_size.x)
	if normalized.x >= card3_x and normalized.x <= card3_x + card_width and normalized.y >= card_y and normalized.y <= card_y + card_height:
		_on_progress()
		return
	
	# Profile card
	var card4_x := card3_x + card_width + (16.0 / view_size.x)
	if normalized.x >= card4_x and normalized.x <= card4_x + card_width and normalized.y >= card_y and normalized.y <= card_y + card_height:
		_on_profile()
		return
	
	# Tap on iris for focus
	var iris_center := Vector2(0.5, 0.5)
	var iris_size := Vector2(240.0 / view_size.x, 240.0 / view_size.y)
	var iris_pos := Vector2(240.0 / view_size.x, 200.0 / view_size.y)
	if normalized.x >= iris_pos.x and normalized.x <= iris_pos.x + iris_size.x and normalized.y >= iris_pos.y and normalized.y <= iris_pos.y + iris_size.y:
		_on_iris_focus()

func _on_continue_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_continue_journey()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_on_continue_journey()
		get_viewport().set_input_as_handled()

func _on_witness_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_witness_chapters()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_on_witness_chapters()
		get_viewport().set_input_as_handled()

func _on_progress_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_progress()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_on_progress()
		get_viewport().set_input_as_handled()

func _on_profile_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_profile()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_on_profile()
		get_viewport().set_input_as_handled()

func _on_continue_journey() -> void:
	if navigation_controller:
		navigation_controller.emit_intent(IrisInputIntent.ENTER)
	elif state_manager:
		# Trigger witness mode
		if has_node("/root/Main/WitnessMode"):
			var witness_mode = get_node("/root/Main/Interface/ScreenRoot/WitnessMode")
			if witness_mode:
				witness_mode.visible = true
				if witness_mode.has_method("enter"):
					witness_mode.enter()
		# Update iris state
		if iris_core:
			iris_core.transition_to(IrisCore.State.FOCUSED)

func _on_witness_chapters() -> void:
	# Navigate to archive/discovery
	if navigation_controller:
		navigation_controller.emit_intent(IrisInputIntent.EXPLORE_RIGHT)
	elif has_node("/root/Main/Interface/ScreenRoot/Archive"):
		var archive = get_node("/root/Main/Interface/ScreenRoot/Archive")
		if archive:
			archive.visible = true
			if archive.has_method("enter"):
				archive.enter()

func _on_progress() -> void:
	# Navigate to profile
	if navigation_controller:
		navigation_controller.emit_intent(IrisInputIntent.EXPLORE_DOWN)
	elif has_node("/root/Main/Interface/ScreenRoot/Profile"):
		var profile = get_node("/root/Main/Interface/ScreenRoot/Profile")
		if profile:
			profile.visible = true
			if profile.has_method("enter"):
				profile.enter()

func _on_profile() -> void:
	# Navigate to settings
	if navigation_controller:
		navigation_controller.emit_intent(IrisInputIntent.EXPLORE_UP)
	elif has_node("/root/Main/Interface/ScreenRoot/Settings"):
		var settings = get_node("/root/Main/Interface/ScreenRoot/Settings")
		if settings:
			settings.visible = true
			if settings.has_method("enter"):
				settings.enter()

func _on_iris_focus() -> void:
	# Trigger deep focus state
	if iris_core:
		iris_core.transition_to(IrisCore.State.FOCUSED)
	
	# Animate focus
	var tween := create_tween()
	tween.tween_property(pupil_portal, "scale", Vector2(1.15, 1.15), 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(pupil_portal, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2)

func _on_audio_pressed() -> void:
	# Toggle audio
	if state_manager:
		state_manager.sound_enabled = not state_manager.sound_enabled

func _on_haptics_pressed() -> void:
	# Toggle haptics
	if state_manager:
		state_manager.haptics_enabled = not state_manager.haptics_enabled

func _on_help_pressed() -> void:
	# Show help
	pass

func _on_info_pressed() -> void:
	# Show info
	pass

# Public methods for external control

func set_living_state(state: int) -> void:
	if iris_core:
		match state:
			0: iris_core.transition_to(IrisCore.State.DORMANT)
			1: iris_core.transition_to(IrisCore.State.AWARE)
			2: iris_core.transition_to(IrisCore.State.FOCUSED)
			3: iris_core.transition_to(IrisCore.State.SETTLED)

func start_awakening() -> void:
	_start_awakening()

func focus_pulse() -> void:
	pulse_elapsed = 0.0
	if particles:
		particles.amount = 25

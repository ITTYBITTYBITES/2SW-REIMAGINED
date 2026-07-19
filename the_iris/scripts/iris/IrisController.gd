extends Control
class_name IrisController

## Owns the current Iris screen and translates a deliberate Iris interaction
## into the existing Home navigation request.
signal home_requested

const ATTENTION_HOLD_SECONDS := 0.56

var iris_core: IrisCore
var living_iris: Iris3DHub
var expression_overlay: IrisExpressionOverlay
var brand_label: Label
var invitation: Label
var state_label: Label
var navigation_label: Label
var background: ColorRect
var ritual_veil: ColorRect
var home_request_in := -1.0
var attention_locked := false
var awakening_ritual_active := false
var awakening_ritual_elapsed := 0.0
var ritual_ambient_started := false
var ritual_activation_played := false
var ritual_transition_played := false
var ritual_ready_played := false
var voice_manager: IrisVoiceManager
var soundscape: IrisSoundscape
var onboarding_ritual: IrisOnboardingRitual

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	background = ColorRect.new()
	background.color = Color("#030a0d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	iris_core = IrisCore.new()
	iris_core.name = "IrisCore"
	add_child(iris_core)
	living_iris = Iris3DHub.new()
	living_iris.name = "LivingIris"
	living_iris.set_core(iris_core)
	add_child(living_iris)

	# V4.0 Acoustic Nervous System + Onboarding Ritual
	voice_manager = IrisVoiceManager.new()
	voice_manager.name = "IrisVoiceManager"
	add_child(voice_manager)

	soundscape = IrisSoundscape.new()
	soundscape.name = "IrisSoundscape"
	add_child(soundscape)

	onboarding_ritual = IrisOnboardingRitual.new()
	onboarding_ritual.name = "IrisOnboardingRitual"
	onboarding_ritual.configure(iris_core, living_iris, voice_manager, soundscape)
	add_child(onboarding_ritual)

	expression_overlay = IrisExpressionOverlay.new()
	expression_overlay.name = "IrisExpressionOverlay"
	add_child(expression_overlay)

	brand_label = _label("THE IRIS", 16, Color("#e2faf1"), Vector2(30, 31), Vector2(400, 30))
	state_label = _label("A LIVING PERCEPTION INSTRUMENT", 10, Color("#6f9e92"), Vector2(31, 58), Vector2(420, 22))
	invitation = _label("the iris is listening", 15, Color("#bde8d9"), Vector2(30, 736), Vector2(480, 34), HORIZONTAL_ALIGNMENT_CENTER)
	navigation_label = _label("HOME  ·  WITNESS CHAPTERS", 11, Color("#668d84"), Vector2(30, 774), Vector2(480, 24), HORIZONTAL_ALIGNMENT_CENTER)

	ritual_veil = ColorRect.new()
	ritual_veil.color = Color("#010306")
	ritual_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ritual_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ritual_veil.visible = false
	add_child(ritual_veil)
	iris_core.state_changed.connect(_on_state_changed)

func _process(delta: float) -> void:
	if awakening_ritual_active:
		_update_awakening_ritual(delta)
	# Drive the acoustic nervous system from IrisCore's live state fields.
	if soundscape and iris_core:
		soundscape.update_from_core(iris_core, delta)
	if home_request_in < 0.0:
		return
	home_request_in -= delta
	if home_request_in <= 0.0:
		home_request_in = -1.0
		attention_locked = false
		home_requested.emit()

func dormant() -> void:
	_cancel_attention()
	_end_awakening_ritual()
	iris_core.transition_to(IrisCore.State.DORMANT)
	invitation.text = "the iris is listening"

func calibrate() -> void:
	_cancel_attention()
	visible = true
	iris_core.transition_to(IrisCore.State.CALIBRATING)
	invitation.text = "the instrument calibrates"

func begin_awakening_ritual() -> void:
	_cancel_attention()
	visible = true
	awakening_ritual_active = true
	awakening_ritual_elapsed = 0.0
	ritual_ambient_started = false
	ritual_activation_played = false
	ritual_transition_played = false
	ritual_ready_played = false
	iris_core.transition_to(IrisCore.State.DORMANT)
	invitation.text = ""
	for label in [brand_label, state_label, invitation, navigation_label]:
		label.modulate.a = 0.0
	ritual_veil.visible = true
	ritual_veil.modulate.a = 1.0
	# V4.0: Start the First 60 Seconds onboarding ritual
	if onboarding_ritual:
		onboarding_ritual.begin()

func welcome() -> void:
	_cancel_attention()
	_end_awakening_ritual()
	visible = true
	iris_core.transition_to(IrisCore.State.WELCOMING)
	invitation.text = "touch the iris to enter"

func _update_awakening_ritual(delta: float) -> void:
	awakening_ritual_elapsed += delta
	var t := awakening_ritual_elapsed

	# Dark/quiet state first; ambience enters before the aperture is visible.
	if not ritual_ambient_started and t >= 0.46:
		ritual_ambient_started = true
		IrisAudioConsumer.play_ambient_loop("res://assets/audio/iris/iris_breath_loop.ogg")

	# The core lifecycle still owns animation; the ritual only authors the first cue timing.
	if t >= 1.08 and iris_core.state == IrisCore.State.DORMANT:
		iris_core.transition_to(IrisCore.State.CALIBRATING)
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Iris Awakening Pulse")

	if not ritual_activation_played and t >= 2.04:
		ritual_activation_played = true
		IrisAudioConsumer.play_presence_sound("iris_awaken")

	if not ritual_transition_played and t >= 3.62:
		ritual_transition_played = true
		IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_transition.ogg")

	if not ritual_ready_played and t >= 6.45:
		ritual_ready_played = true
		IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Iris Ready Pulse")

	# Reveal UI language only after the artifact has visibly noticed the player.
	var label_alpha := _ease_in_out(clampf((t - 4.2) / 1.25, 0.0, 1.0))
	brand_label.modulate.a = label_alpha
	state_label.modulate.a = label_alpha
	invitation.modulate.a = label_alpha
	navigation_label.modulate.a = label_alpha * 0.82

	if ritual_veil != null:
		var veil_alpha := 1.0 - _ease_in_out(clampf((t - 0.78) / 2.35, 0.0, 1.0))
		ritual_veil.modulate.a = veil_alpha
		if veil_alpha <= 0.01:
			ritual_veil.visible = false

	if t >= 7.2:
		_end_awakening_ritual()

func _end_awakening_ritual() -> void:
	awakening_ritual_active = false
	if ritual_veil != null:
		ritual_veil.visible = false
	for label in [brand_label, state_label, invitation, navigation_label]:
		if label != null:
			label.modulate.a = 1.0

func _ease_in_out(value: float) -> float:
	return value * value * (3.0 - 2.0 * value)

## Direct Iris Home integration: the existing Iris becomes a non-interactive
## settled presence behind the archive environment. No second renderer exists.
func set_home_environment(active: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if active else Control.MOUSE_FILTER_STOP
	expression_overlay.set_home_environment(active)
	brand_label.visible = not active
	state_label.visible = not active
	invitation.visible = not active
	navigation_label.visible = not active
	if active:
		background.color = Color(0.002, 0.015, 0.021, 0.32)
		living_iris.modulate = Color.WHITE
	else:
		background.color = Color("#030a0d")

func set_gameplay_environment(active: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if active else Control.MOUSE_FILTER_STOP
	# Keep expression overlay visible so personality resolved messages can float
	expression_overlay.set_home_environment(false)
	brand_label.visible = not active
	state_label.visible = not active
	invitation.visible = not active
	navigation_label.visible = not active
	
	if active:
		# Make background fully transparent so gameplay is visible beneath
		background.color = Color(0.0, 0.0, 0.0, 0.0)
		# Semi-transparent watermark background effect for the Living Iris
		living_iris.modulate = Color(1.0, 1.0, 1.0, 0.15)
	else:
		background.color = Color("#030a0d")
		living_iris.modulate = Color.WHITE

func present_response_intent(intent: IrisResponseIntent) -> void:
	expression_overlay.present(intent)
	IrisAudioConsumer.consume(intent)
	IrisHapticConsumer.consume(intent)
	IrisAccessibilityConsumer.consume(intent)

func observe() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.OBSERVING)

func settle() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.SETTLED)

## Fire the SUCCESS mood flare (a truth has been witnessed). Locks the mood so
## the following state transitions (REFLECTIVE) don't immediately wash it out,
## then auto-releases after a beat so the Iris settles back to its identity.
func trigger_success_mood(hold_seconds := 3.5) -> void:
	iris_core.change_mood(IrisCore.Mood.SUCCESS, true)
	var tree := get_tree()
	if tree != null:
		var t := tree.create_timer(hold_seconds)
		t.timeout.connect(_release_success_mood)

func _release_success_mood() -> void:
	if iris_core != null:
		iris_core.release_mood()

## Progression tint (protocol §4). When the player's evolution profile crosses
## a threshold, the Iris gains a secondary highlight color ("multi-chromatic
## flecks"). Wired to IrisEvolutionProfile so the Progression Service boundary
## stays intact — no rank system is invented here.
func apply_progression_tint(secondary_color: Color, weight: float) -> void:
	iris_core.mood_secondary_color = secondary_color
	iris_core.mood_secondary_weight = weight
	iris_core._mood_target_secondary = secondary_color
	iris_core._mood_target_secondary_weight = weight

func reflect() -> void:
	_cancel_attention()
	iris_core.transition_to(IrisCore.State.REFLECTIVE)

func _gui_input(event: InputEvent) -> void:
	if awakening_ritual_active or attention_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		_begin_attention(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_begin_attention(event.position)

func _begin_attention(tap_position: Vector2) -> void:
	attention_locked = true
	var safe_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	var normalized_target := (tap_position - safe_size * 0.5) / safe_size
	iris_core.acquire_attention(normalized_target)
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/iris/iris_attention.ogg")
	IrisHapticConsumer.trigger_pattern(IrisHapticConsumer.Pattern.LIGHT, "Iris Interaction Acknowledgment")
	invitation.text = "attention acquired"
	home_request_in = ATTENTION_HOLD_SECONDS

func _cancel_attention() -> void:
	home_request_in = -1.0
	attention_locked = false

func _on_state_changed(next_state: IrisCore.State) -> void:
	state_label.text = _presence_line(next_state)
	match next_state:
		IrisCore.State.STIRRING:
			invitation.text = "something stirs"
		IrisCore.State.AWAKENING:
			invitation.text = "attention wakes the instrument"
		IrisCore.State.WELCOMING:
			invitation.text = "touch the iris to enter"
		IrisCore.State.AWARE:
			invitation.text = "the iris is ready"
		IrisCore.State.FOCUSED:
			invitation.text = "attention acquired"
		IrisCore.State.OBSERVING:
			invitation.text = "attention is held"
		IrisCore.State.REFLECTIVE:
			invitation.text = "what was noticed remains"

func _presence_line(next_state: IrisCore.State) -> String:
	match next_state:
		IrisCore.State.CALIBRATING:
			return "THE FIELD BEGINS TO FORM"
		IrisCore.State.STIRRING:
			return "SOMETHING NOTICES"
		IrisCore.State.AWAKENING:
			return "ATTENTION TAKES SHAPE"
		IrisCore.State.WELCOMING:
			return "THE IRIS IS OPEN"
		IrisCore.State.AWARE:
			return "THE IRIS IS AWARE"
		IrisCore.State.ATTENDING:
			return "ATTENTION ACQUIRED"
		IrisCore.State.FOCUSED:
			return "FOCUS HELD"
		IrisCore.State.OBSERVING:
			return "WITNESSING"
		IrisCore.State.SETTLED:
			return "THE FIELD SETTLES"
		IrisCore.State.REFLECTIVE:
			return "THE MOMENT REMAINS"
	return "A LIVING PERCEPTION INSTRUMENT"

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

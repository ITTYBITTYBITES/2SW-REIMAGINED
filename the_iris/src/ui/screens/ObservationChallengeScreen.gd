extends Control
## ObservationChallengeScreen – shared scene-image presentation adapter
## Reads a resolved ChallengeInstance from the Challenge Runtime while retaining
## compatibility with deterministic fixture dictionaries.

@onready var timer_bar: ProgressBar = $Margin/VBox/TimerBar
@onready var image_rect: TextureRect = $Margin/VBox/ImageContainer/Margin/ObservationImage
@onready var countdown_label: Label = $Margin/VBox/HUD/CountdownLabel
@onready var instruction_label: Label = $Margin/VBox/HUD/Phase/InstructionLabel
@onready var hint_label: Label = $Margin/VBox/HUD/Phase/Hint
@onready var image_container: PanelContainer = $Margin/VBox/ImageContainer
@onready var background_rect: ColorRect = $Background

var _elapsed: float = 0.0
var _duration: float = 2.0
var _challenge_id: String = "challenge_01"
var _challenge_data: Dictionary = {}
var _scene_view: Control = null
var _last_remaining_int: int = -1
var _pulse_at_remaining: Array[int] = []

const FALLBACK_CHALLENGE := {
	"id": "challenge_01",
	"title": "Study Desk",
	"image_path": "res://assets/gameplay/observation_challenge_01.png",
	"question": "How many colored pencils were in the green mug?",
	"options": ["3", "4", "5", "6"],
	"correct": "5",
	"detail": "There were 5 writing tools in the green mug."
}

func _ready() -> void:
	# AppShell supplies route data through on_navigated_to after adding the scene.
	# Starting here as well caused duplicate initialization and duplicate haptics.
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin, 12.0)

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}

	if background_rect:
		background_rect.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")

	# The compact HUD keeps phase, family identity, and time visible without
	# competing with the observation surface.
	if instruction_label:
		if ThemeService:
			ThemeService.apply_label_style(instruction_label, "label_small", "primary_variant")
		instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		instruction_label.text = "OBSERVE"

	if countdown_label:
		if ThemeService:
			ThemeService.apply_label_style(countdown_label, "label", "text_primary")
		countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		countdown_label.autowrap_mode = TextServer.AUTOWRAP_OFF

	if hint_label:
		if ThemeService:
			ThemeService.apply_label_style(hint_label, "caption", "text_tertiary")
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Timer bar – purple, rounded, matching Home CTA
	if timer_bar:
		timer_bar.show_percentage = false
		var bg_style := StyleBoxFlat.new()
		bg_style.bg_color = Color("#24242C")
		bg_style.corner_radius_top_left = 99
		bg_style.corner_radius_top_right = 99
		bg_style.corner_radius_bottom_left = 99
		bg_style.corner_radius_bottom_right = 99
		timer_bar.add_theme_stylebox_override("background", bg_style)
		var fill_style := StyleBoxFlat.new()
		var primary: Color = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
		fill_style.bg_color = primary
		fill_style.corner_radius_top_left = 99
		fill_style.corner_radius_top_right = 99
		fill_style.corner_radius_bottom_left = 99
		fill_style.corner_radius_bottom_right = 99
		timer_bar.add_theme_stylebox_override("fill", fill_style)

	# The stage is a clipping boundary, not a decorative card. Family artwork
	# owns the visual field while a quiet edge protects content on small phones.
	if image_container:
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		var radius: int = int(tokens.get("radius_lg", 20))
		style.corner_radius_top_left = radius
		style.corner_radius_top_right = radius
		style.corner_radius_bottom_left = radius
		style.corner_radius_bottom_right = radius
		style.border_color = _with_alpha(tokens.get("border", Color("#2E2E3A")), 0.55)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		image_container.add_theme_stylebox_override("panel", style)

	if image_rect:
		image_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

func _load_challenge() -> void:
	if _challenge_data.is_empty() and AppState:
		var transient = AppState.get_transient("current_challenge", {})
		if transient is Dictionary and not transient.is_empty():
			_challenge_data = transient

	if _challenge_data.is_empty() and ChallengeRegistry:
		_challenge_data = ChallengeRegistry.get_challenge(_challenge_id)

	if _challenge_data.is_empty():
		_challenge_data = FALLBACK_CHALLENGE.duplicate(true)

	_challenge_id = str(_challenge_data.get("instance_id", _challenge_data.get("id", _challenge_id)))
	var generated_scene: Dictionary = {}
	var raw_scene: Variant = _challenge_data.get("generated_scene", {})
	if raw_scene is Dictionary:
		generated_scene = raw_scene as Dictionary
	_duration = maxf(float(_challenge_data.get("exposure_duration_sec", 2.0)), 0.1)
	_clear_scene_view()
	var renderer_script := str(generated_scene.get("renderer_script", ""))
	if not renderer_script.is_empty() and ResourceLoader.exists(renderer_script):
		_show_generated_scene(generated_scene, renderer_script)
	else:
		var image_path: String = str(generated_scene.get(
			"image_path",
			_challenge_data.get("image_path", FALLBACK_CHALLENGE["image_path"])
		))
		if ResourceLoader.exists(image_path):
			var tex = load(image_path) as Texture2D
			if tex and image_rect:
				image_rect.visible = true
				image_rect.texture = tex
		else:
			if image_rect:
				image_rect.visible = true
				image_rect.texture = null

	if hint_label:
		hint_label.text = _challenge_identity(generated_scene)

func _show_generated_scene(generated_scene: Dictionary, renderer_script: String) -> void:
	var script: Script = load(renderer_script)
	if script == null or image_rect == null:
		return
	image_rect.visible = false
	_scene_view = Control.new()
	_scene_view.name = "GeneratedSceneView"
	_scene_view.set_script(script)
	_scene_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scene_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scene_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image_rect.get_parent().add_child(_scene_view)
	_scene_view.call("set_scene_data", generated_scene, [])

func _clear_scene_view() -> void:
	if is_instance_valid(_scene_view):
		_scene_view.queue_free()
	_scene_view = null
	if image_rect:
		image_rect.visible = true

func _challenge_identity(generated_scene: Dictionary) -> String:
	var family_title := ""
	var family_id := str(_challenge_data.get("family_id", ""))
	if ChallengeFamilyRegistry and not family_id.is_empty():
		var family: ChallengeFamily = ChallengeFamilyRegistry.get_family(family_id)
		if family:
			family_title = family.title
	var scene_title := str(generated_scene.get("title", _challenge_data.get("title", "")))
	if not family_title.is_empty() and not scene_title.is_empty() and scene_title != family_title:
		return "%s · %s" % [family_title, scene_title]
	if not family_title.is_empty():
		return family_title
	return scene_title if not scene_title.is_empty() else "Focus your attention"

func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color

func _start_observation() -> void:
	_elapsed = 0.0
	_duration = maxf(_duration, 0.1)
	set_process(true)
	_last_remaining_int = -1
	# Pulse on the final 3 whole-second boundaries to build anticipation.
	_pulse_at_remaining = []
	if _duration >= 2.5:
		_pulse_at_remaining = [3, 2, 1]
	elif _duration >= 1.5:
		_pulse_at_remaining = [2, 1]
	elif _duration >= 0.8:
		_pulse_at_remaining = [1]
	if instruction_label:
		instruction_label.text = "OBSERVE"
	if countdown_label:
		countdown_label.text = "%.1fs" % _duration
	if timer_bar:
		timer_bar.max_value = _duration
		timer_bar.value = _duration

	# Premium entrance: a soft scale-in on the timer bar and a hint label fade.
	if timer_bar and _should_animate():
		timer_bar.modulate = Color(1, 1, 1, 0.0)
		var bar_tween := create_tween()
		bar_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var bar_dur := _get_anim_duration(0.30)
		bar_tween.tween_property(timer_bar, "modulate:a", 1.0, bar_dur).set_ease(Tween.EASE_OUT)
	if instruction_label and _should_animate():
		instruction_label.modulate = Color(1, 1, 1, 0.0)
		instruction_label.scale = Vector2(0.92, 0.92)
		var lbl_tween := create_tween()
		lbl_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var lbl_dur := _get_anim_duration(0.35)
		lbl_tween.tween_property(instruction_label, "modulate:a", 1.0, lbl_dur).set_ease(Tween.EASE_OUT)
		lbl_tween.parallel().tween_property(instruction_label, "scale", Vector2.ONE, lbl_dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(50)
	if AudioService:
		AudioService.play_sfx("observation_start", 0.75)


func _process(delta: float) -> void:
	_elapsed += delta
	var remaining = max(_duration - _elapsed, 0.0)

	if countdown_label:
		countdown_label.text = "%.1fs" % remaining
	if timer_bar:
		timer_bar.value = remaining

	# Tick the timer with a soft pulse on whole-second boundaries
	var remaining_int: int = int(ceil(remaining))
	if remaining_int != _last_remaining_int and remaining_int > 0 and remaining_int <= 3:
		if _pulse_at_remaining.has(remaining_int):
			if AudioService:
				AudioService.play_sfx("flash_pulse", 0.45)
			if timer_bar and _should_animate():
				var tween := create_tween()
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property(timer_bar, "modulate:a", 0.55, 0.05)
				tween.tween_property(timer_bar, "modulate:a", 1.0, 0.10)
	_last_remaining_int = remaining_int

	if _elapsed >= _duration:
		set_process(false)
		_transition_to_question()

func _transition_to_question() -> void:
	if AudioService:
		AudioService.play_sfx("conceal", 0.40)
		AudioService.duck_bgm(-6.0, 0.15)
	var fade_dur := _get_anim_duration(0.22)
	if not _should_animate():
		_do_question_transition()
		return
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, fade_dur)
	tween.finished.connect(_do_question_transition)

func _do_question_transition() -> void:
	if AppState:
		AppState.set_transient("current_challenge_id", _challenge_id)
		AppState.set_transient("current_challenge", _challenge_data)
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.advance_to_response()
	else:
		ErrorHandler.handle(
			"RUNTIME_SESSION_MISSING",
			"Observation cannot continue without an active challenge session",
			{"instance_id": _challenge_id}
		)
		if NavigationService:
			NavigationService.navigate_to("home")

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id := "challenge_01"
	if AppState:
		fallback_id = AppState.get_transient("current_challenge_id", fallback_id)
	_challenge_id = str(params.get("challenge_id", fallback_id))
	if params.has("challenge_data") and params.get("challenge_data") is Dictionary:
		_challenge_data = params.get("challenge_data")
	else:
		_challenge_data = {}

	modulate.a = 1.0
	_apply_responsive_layout()
	_apply_theme()
	_load_challenge()
	_start_observation()

	if AnalyticsService:
		AnalyticsService.log_event("observation_started", {"challenge_id": _challenge_id})

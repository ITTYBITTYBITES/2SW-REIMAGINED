extends Control
## Family-owned Scene Investigation tutorial. Navigation and persistence are owned by the generic host.

signal completed(family_id: String, tutorial_version: String)
signal skipped(family_id: String, tutorial_version: String)
signal practice_requested(family_id: String, template_id: String)

const FAMILY_ID: String = "scene_investigation"
## TutorialScreen - Witness onboarding, premium
## 3-step: Observe / Remember / Recall
## Matches HomeScreen / TitleSplash visual language

@onready var brand_label: Label = $MainMargin/Scroll/Content/Hero/BrandLabel
@onready var step_title: Label = $MainMargin/Scroll/Content/Hero/StepTitle
@onready var eye_rect: TextureRect = $MainMargin/Scroll/Content/Hero/EyeWrap/Eye
@onready var description_label: Label = $MainMargin/Scroll/Content/Hero/Description
@onready var page_indicator: HBoxContainer = $MainMargin/Scroll/Content/PageIndicator
@onready var next_button: Button = $MainMargin/Scroll/Content/Actions/NextButton
@onready var skip_button: Button = $MainMargin/Scroll/Content/Actions/SkipButton

const TUTORIAL_VERSION: String = "2"
const DEMO_TEMPLATE_ID: String = "office_v1"
const DEMO_SEED: int = 271828

var _current_step: int = 0
var _eye_tween: Tween = null
var _demo_instance: ChallengeInstance = null
var _demo_host: Control = null
var _demo_view: Control = null
var _answer_container: VBoxContainer = null
var _demo_answered: bool = false

var _steps := [
	{
		"title": "SCENE INVESTIGATION",
		"desc": "Study the whole scene. After it disappears, you will get one fair question.",
		"mode": "eye",
		"button": "SHOW ME  →",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": true
	},
	{
		"title": "OBSERVE",
		"desc": "Take your time with this demonstration. Tap when you are ready for the question.",
		"mode": "demo",
		"button": "I'M READY  →",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": false
	},
	{
		"title": "RECALL",
		"desc": "Answer from memory. The scene returns after you choose.",
		"mode": "answer",
		"button": "",
		"eye_alpha": 0.5,
		"eye_scale": 0.96,
		"pulse": false
	},
	{
		"title": "REVEAL",
		"desc": "The result highlights the exact detail, so every miss feels understandable.",
		"mode": "reveal",
		"button": "ONE MORE STEP  →",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": false
	},
	{
		"title": "YOUR TURN",
		"desc": "Your first round uses a clear Office scene and comfortable timing.",
		"mode": "eye",
		"button": "START PRACTICE",
		"eye_alpha": 1.0,
		"eye_scale": 1.0,
		"pulse": true
	}
]

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_prepare_demo()
	_ensure_tutorial_ui()
	_apply_theme()
	_update_step(false)
	_animate_in()
	_wire_buttons()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin, 24.0)

func _prepare_demo() -> void:
	if not ChallengeFamilyRegistry:
		return
	var module: ChallengeFamilyModule = ChallengeFamilyRegistry.get_module("scene_investigation")
	if module == null:
		return
	var template := module.get_template(DEMO_TEMPLATE_ID)
	if template == null:
		return
	var player_state: Dictionary = {}
	var difficulty := module.get_difficulty_policy().resolve_difficulty(player_state, module.get_family(), template)
	var exposure := module.get_exposure_policy().resolve_exposure(template, difficulty, player_state)
	var candidate := module.get_generator().generate(template, difficulty, exposure, DEMO_SEED)
	if module.get_validator().validate(candidate).is_valid:
		_demo_instance = candidate

func _ensure_tutorial_ui() -> void:
	var hero := get_node_or_null("MainMargin/Scroll/Content/Hero") as VBoxContainer
	if hero and _demo_host == null:
		_demo_host = Control.new()
		_demo_host.name = "DemoHost"
		_demo_host.custom_minimum_size = Vector2(0, 300)
		_demo_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero.add_child(_demo_host)
		hero.move_child(_demo_host, description_label.get_index())
	var content := get_node_or_null("MainMargin/Scroll/Content") as VBoxContainer
	if content and _answer_container == null:
		_answer_container = VBoxContainer.new()
		_answer_container.name = "TutorialAnswers"
		_answer_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_answer_container.add_theme_constant_override("separation", 8)
		content.add_child(_answer_container)
		content.move_child(_answer_container, page_indicator.get_index())
	_rebuild_indicators()
	_build_demo_answers()

func _rebuild_indicators() -> void:
	if page_indicator == null:
		return
	for child: Node in page_indicator.get_children():
		child.queue_free()
	for index: int in range(_steps.size()):
		var dot := PanelContainer.new()
		dot.name = "Dot%d" % (index + 1)
		dot.custom_minimum_size = Vector2(12, 12)
		page_indicator.add_child(dot)

func _build_demo_answers() -> void:
	if _answer_container == null:
		return
	for child: Node in _answer_container.get_children():
		child.queue_free()
	if _demo_instance == null:
		return
	for option: Variant in _demo_instance.answer_options:
		var button := Button.new()
		button.text = str(option)
		button.custom_minimum_size = Vector2(0, 54)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_demo_answer.bind(str(option)))
		_answer_container.add_child(button)

func _on_demo_answer(answer: String) -> void:
	if _demo_instance == null or _demo_answered:
		return
	_demo_answered = true
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	_current_step = 3
	_update_step(false)
	var correct := str(_demo_instance.correct_answer)
	description_label.text = "%s\n%s" % [
		"You chose %s. The answer was %s." % [answer, correct],
		_demo_instance.explanation
	]

func _show_demo(reveal: bool) -> void:
	if _demo_host == null:
		return
	_demo_host.visible = true
	if is_instance_valid(_demo_view):
		_demo_view.queue_free()
	_demo_view = null
	if _demo_instance == null:
		return
	var renderer_path := str(_demo_instance.generated_scene.get("renderer_script", ""))
	if renderer_path.is_empty() or not ResourceLoader.exists(renderer_path):
		return
	var script: Script = load(renderer_path)
	_demo_view = Control.new()
	_demo_view.set_script(script)
	_demo_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_demo_host.add_child(_demo_view)
	var highlights: Array = _demo_instance.metadata.get("highlight_ids", []) if reveal else []
	_demo_view.call("set_scene_data", _demo_instance.generated_scene, highlights)

func _hide_demo() -> void:
	if _demo_host:
		_demo_host.visible = false

func _wire_buttons() -> void:
	if next_button and not next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.connect(_on_next_pressed)
	if skip_button and not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _apply_theme() -> void:
	var tokens := {}
	if ThemeService and not ThemeService.tokens.is_empty():
		tokens = ThemeService.tokens

	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")

	if brand_label:
		if ThemeService:
			ThemeService.apply_label_style(brand_label, "label", "text_tertiary")
			brand_label.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(16))
	if step_title:
		if ThemeService:
			ThemeService.apply_label_style(step_title, "display", "text_primary")
			step_title.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(42))
	if description_label:
		if ThemeService:
			ThemeService.apply_label_style(description_label, "body_small", "text_secondary")
		description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_style_buttons(tokens)
	_update_indicators()

func _style_buttons(tokens: Dictionary) -> void:
	if not next_button:
		return
	var primary: Color = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	var radius: int = int(tokens.get("radius_lg", 18)) if not tokens.is_empty() else 18

	var normal := StyleBoxFlat.new()
	normal.bg_color = primary
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 18
	normal.content_margin_bottom = 18

	var hover := normal.duplicate()
	hover.bg_color = tokens.get("primary_variant", Color("#8A68FF")) if not tokens.is_empty() else Color("#8A68FF")
	var pressed := normal.duplicate()
	pressed.bg_color = primary.darkened(0.15)

	next_button.add_theme_stylebox_override("normal", normal)
	next_button.add_theme_stylebox_override("hover", hover)
	next_button.add_theme_stylebox_override("pressed", pressed)
	next_button.add_theme_stylebox_override("focus", hover)
	next_button.add_theme_color_override("font_color", Color.WHITE)
	if ThemeService:
		next_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	next_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if skip_button:
		skip_button.add_theme_color_override("font_color", tokens.get("text_tertiary", Color("#8A8AA3")) if not tokens.is_empty() else Color("#8A8AA3"))
		if ThemeService:
			skip_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("label"))
		skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _update_step(animate: bool = true) -> void:
	if _current_step < 0 or _current_step >= _steps.size():
		return
	var data: Dictionary = _steps[_current_step]
	if step_title:
		step_title.text = str(data.get("title", ""))
	if description_label:
		description_label.text = str(data.get("desc", ""))

	var mode := str(data.get("mode", "eye"))
	if eye_rect:
		eye_rect.get_parent().visible = mode == "eye"
	if mode == "demo":
		_show_demo(false)
	elif mode == "reveal":
		_show_demo(true)
	else:
		_hide_demo()
	if _answer_container:
		_answer_container.visible = mode == "answer"

	_apply_eye_state(data, animate)
	if next_button:
		next_button.text = str(data.get("button", "NEXT  →"))
		next_button.visible = mode != "answer"
		next_button.disabled = mode == "answer"
	if skip_button:
		skip_button.text = "Skip Tutorial"
	_update_indicators()

func _apply_eye_state(data: Dictionary, animate: bool) -> void:
	if not eye_rect:
		return
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()

	var target_alpha: float = data.get("eye_alpha", 1.0)
	var target_scale: float = data.get("eye_scale", 1.0)
	var pulse: bool = data.get("pulse", false) and _should_animate()

	if not animate or not _should_animate():
		eye_rect.modulate.a = target_alpha
		eye_rect.scale = Vector2(target_scale, target_scale)
		if pulse:
			_start_eye_pulse()
		return

	var t := create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(eye_rect, "modulate:a", target_alpha, _get_anim_duration(0.25))
	t.parallel().tween_property(eye_rect, "scale", Vector2(target_scale, target_scale), _get_anim_duration(0.25))
	t.finished.connect(func():
		if pulse:
			_start_eye_pulse()
	)

func _start_eye_pulse() -> void:
	if not eye_rect or not _should_animate():
		return
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	var breathe := _get_anim_duration(1.2)
	_eye_tween = create_tween()
	_eye_tween.set_loops()
	_eye_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_eye_tween.tween_property(eye_rect, "modulate:a", 0.92, breathe)
	_eye_tween.tween_property(eye_rect, "modulate:a", 1.0, breathe)
	_eye_tween.parallel()
	_eye_tween.tween_property(eye_rect, "scale", Vector2(1.015, 1.015), breathe)
	_eye_tween.tween_property(eye_rect, "scale", Vector2.ONE, breathe)

func _stop_eye_pulse() -> void:
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	_eye_tween = null
	if eye_rect:
		eye_rect.modulate.a = 1.0
		eye_rect.scale = Vector2.ONE

func _update_indicators() -> void:
	if not page_indicator:
		return
	var tokens := ThemeService.tokens if ThemeService else {}
	var primary: Color = tokens.get("primary", Color("#6A3DFF")) if not tokens.is_empty() else Color("#6A3DFF")
	var border: Color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")

	var dots: Array[Node] = page_indicator.get_children()
	for i: int in range(dots.size()):
		var dot: Node = dots[i]
		if dot is PanelContainer:
			var sb := StyleBoxFlat.new()
			sb.bg_color = primary if i == _current_step else border
			sb.corner_radius_top_left = 99
			sb.corner_radius_top_right = 99
			sb.corner_radius_bottom_left = 99
			sb.corner_radius_bottom_right = 99
			dot.add_theme_stylebox_override("panel", sb)

func _on_next_pressed() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")

	if _current_step < _steps.size() - 1:
		_current_step += 1
		_animate_step_transition()
	else:
		_finish_tutorial(false)

func _on_skip_pressed() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")
	_finish_tutorial(true)

func _animate_in() -> void:
	modulate.a = 0.0
	if not _should_animate():
		modulate.a = 1.0
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, _get_anim_duration(0.35))

func _animate_step_transition() -> void:
	if not _should_animate():
		_update_step(false)
		return
	var hero := get_node_or_null("MainMargin/Scroll/Content/Hero")
	if not hero:
		_update_step(false)
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(hero, "modulate:a", 0.0, _get_anim_duration(0.15))
	tween.tween_callback(func(): _update_step(true))
	tween.tween_property(hero, "modulate:a", 1.0, _get_anim_duration(0.2))

func _finish_tutorial(was_skipped: bool) -> void:
	_stop_eye_pulse()
	var fade_dur := _get_anim_duration(0.3)
	if not _should_animate():
		_emit_tutorial_result(was_skipped)
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, fade_dur)
	tween.finished.connect(_emit_tutorial_result.bind(was_skipped))

func _emit_tutorial_result(was_skipped: bool) -> void:
	if was_skipped:
		skipped.emit(FAMILY_ID, TUTORIAL_VERSION)
	else:
		completed.emit(FAMILY_ID, TUTORIAL_VERSION)
	practice_requested.emit(FAMILY_ID, DEMO_TEMPLATE_ID)

func configure(_family: ChallengeFamily, _profile: TutorialProfile) -> void:
	reset_tutorial()

func reset_tutorial() -> void:
	_current_step = 0
	_demo_answered = false
	_prepare_demo()
	_build_demo_answers()
	_update_step(false)
	modulate.a = 1.0
	_apply_theme()

func on_navigated_to(_params: Dictionary) -> void:
	reset_tutorial()

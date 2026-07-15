extends Control
## Generic interaction host retained at the established Recall route.
## Family meaning and correctness remain in family ScoringPolicy code.

@onready var brand_label: Label = $MainMargin/Scroll/Content/Header/BrandLabel
@onready var subtitle_label: Label = $MainMargin/Scroll/Content/Header/SubtitleLabel
@onready var question_label: Label = $MainMargin/Scroll/Content/QuestionLabel
@onready var question_accent: ColorRect = $MainMargin/Scroll/Content/QuestionAccent
@onready var options_container: VBoxContainer = $MainMargin/Scroll/Content/OptionsContainer
@onready var background_rect: ColorRect = $Background

var _challenge_data: Dictionary = {}
var _challenge_id: String = "challenge_01"
var _correct_answer: Variant = null
var _selected_answer: Variant = null
var _interaction_profile: InteractionProfile
var _adapter: InteractionAdapter
var _submitted: bool = false

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin, 16.0)

func _should_animate() -> bool:
	return AccessibilityService.should_animate() if AccessibilityService else true

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	background_rect.color = tokens.get("background", Color("#0F0F12"))
	var accent := _family_accent()
	question_accent.color = accent
	if ThemeService:
		ThemeService.apply_label_style(brand_label, "label_small", "primary_variant")
		ThemeService.apply_label_style(subtitle_label, "caption", "text_tertiary")
		ThemeService.apply_label_style(question_label, "headline", "text_primary")
	brand_label.text = "RECALL"
	brand_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _family_title() -> String:
	var family_id := str(_challenge_data.get("family_id", ""))
	if ChallengeFamilyRegistry and not family_id.is_empty():
		var family: ChallengeFamily = ChallengeFamilyRegistry.get_family(family_id)
		if family:
			return family.title
	return "What did you notice?"

func _family_accent() -> Color:
	var accents: Array[Color] = [
		Color("#8A68FF"),
		Color("#36CFC9"),
		Color("#FFB454"),
		Color("#F071B8"),
		Color("#62A8FF")
	]
	var identity := str(_challenge_data.get("family_id", "challenge"))
	return accents[absi(identity.hash()) % accents.size()]

func _load_question(profile_data: Dictionary = {}) -> void:
	if _challenge_data.is_empty() and AppState:
		var transient: Variant = AppState.get_transient("current_challenge", {})
		if transient is Dictionary and not (transient as Dictionary).is_empty():
			_challenge_data = transient
	if _challenge_data.is_empty() and ChallengeRegistry:
		_challenge_data = ChallengeRegistry.get_challenge(_challenge_id)
	if _challenge_data.is_empty():
		_challenge_data = {
			"id": "challenge_01",
			"question": {"prompt": "How many colored pencils were in the green mug?"},
			"answer_options": ["3", "4", "5", "6"],
			"correct_answer": "5"
		}
	_challenge_id = str(_challenge_data.get("instance_id", _challenge_data.get("id", _challenge_id)))
	_correct_answer = _challenge_data.get("correct_answer", _challenge_data.get("correct", null))
	var raw_question: Variant = _challenge_data.get("question", {})
	question_label.text = str((raw_question as Dictionary).get("prompt", "What did you notice?")) if raw_question is Dictionary else str(raw_question)
	subtitle_label.text = _family_title()
	_interaction_profile = InteractionProfile.new(profile_data) if not profile_data.is_empty() else InteractionProfile.default_single_choice()
	_mount_adapter()
	if AppState:
		AppState.set_transient("question_started_ms", Time.get_ticks_msec())

func _mount_adapter() -> void:
	_submitted = false
	if _adapter:
		_adapter.unmount()
	for child: Node in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()
	var adapter_id: String = _interaction_profile.adapter_id
	var wants_accessible: bool = bool(SettingsService.get_value("accessibility_screen_reader_hints", false)) if SettingsService else false
	if wants_accessible and not _interaction_profile.accessible_adapter_id.is_empty():
		adapter_id = _interaction_profile.accessible_adapter_id
	_adapter = InteractionAdapterRegistry.create_adapter(adapter_id) if InteractionAdapterRegistry else null
	if _adapter == null:
		ErrorHandler.handle("INTERACTION_ADAPTER_MISSING", "Interaction adapter unavailable", {"adapter_id": adapter_id})
		if NavigationService:
			NavigationService.navigate_to("home")
		return
	_adapter.configure(_interaction_profile, _challenge_data)
	_adapter.interaction_submitted.connect(_on_interaction_submitted)
	_adapter.mount(options_container)
	_style_interaction_tree(options_container)
	ResponsiveLayout.enforce_touch_targets(options_container)

func _on_interaction_submitted(payload: Variant) -> void:
	if _submitted:
		return
	_submitted = true
	_selected_answer = payload
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	var started: int = int(AppState.get_transient("question_started_ms", Time.get_ticks_msec())) if AppState else Time.get_ticks_msec()
	var reaction_ms: int = maxi(Time.get_ticks_msec() - started, 0)
	if ChallengeSessionService and ChallengeSessionService.has_active_session():
		ChallengeSessionService.submit_response(payload, reaction_ms)
		var result_delay := AccessibilityService.get_animation_duration(0.25) if AccessibilityService else 0.25
		get_tree().create_timer(result_delay).timeout.connect(ChallengeSessionService.present_result)
		return
	ErrorHandler.handle("RUNTIME_SESSION_MISSING", "Recall cannot score without an active challenge session", {"instance_id": _challenge_id})
	if NavigationService:
		NavigationService.navigate_to("home")

# Compatibility entry used by validated regressions and existing single-choice UI.
func _on_option_selected(answer: String, button: Button) -> void:
	if _submitted:
		return
	var is_correct: bool = str(answer) == str(_correct_answer)
	_highlight_answers(button, is_correct)
	if _adapter:
		_adapter.set_disabled(true)
	_on_interaction_submitted(answer)

func _style_interaction_tree(node: Node) -> void:
	if node is CheckButton:
		_apply_check_theme(node as CheckButton)
	elif node is Button:
		_apply_option_theme(node as Button)
	for child: Node in node.get_children():
		_style_interaction_tree(child)

func _apply_check_theme(check: CheckButton) -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var normal := StyleBoxFlat.new()
	normal.bg_color = _with_alpha(tokens.get("surface", Color("#1E1E26")), 0.72)
	normal.border_color = _with_alpha(tokens.get("border", Color("#2E2E3A")), 0.72)
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	check.add_theme_stylebox_override("normal", normal)
	check.add_theme_stylebox_override("hover", hover)
	check.add_theme_stylebox_override("focus", hover)
	check.add_theme_stylebox_override("pressed", hover)
	check.custom_minimum_size.y = maxf(check.custom_minimum_size.y, 56.0)
	check.focus_mode = Control.FOCUS_ALL
	check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_typography(check, "body_small")

func _apply_option_theme(button: Button) -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var normal := StyleBoxFlat.new()
	normal.bg_color = _with_alpha(tokens.get("surface", Color("#1E1E26")), 0.78)
	normal.border_color = _with_alpha(tokens.get("border", Color("#2E2E3A")), 0.78)
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	var radius: int = int(tokens.get("radius_md", 14))
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 14
	normal.content_margin_bottom = 14
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.10)
	var focus: StyleBoxFlat = hover.duplicate()
	focus.border_color = tokens.get("primary_variant", Color("#8A68FF"))
	focus.border_width_left = 2
	focus.border_width_right = 2
	focus.border_width_top = 2
	focus.border_width_bottom = 2
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.custom_minimum_size.y = 58
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_typography(button, "button")
		button.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))

func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color

func _highlight_answers(selected_button: Button, is_correct: bool) -> void:
	if not ThemeService or selected_button == null:
		return
	var color: Color = ThemeService.get_color("success") if is_correct else ThemeService.get_color("error")
	var style := StyleBoxFlat.new()
	style.bg_color = color
	var radius: int = ThemeService.get_radius("radius_lg")
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	selected_button.add_theme_stylebox_override("normal", style)

func on_navigated_to(params: Dictionary) -> void:
	var fallback_id: String = str(AppState.get_transient("current_challenge_id", "challenge_01")) if AppState else "challenge_01"
	_challenge_id = str(params.get("challenge_id", fallback_id))
	var challenge_value: Variant = params.get("challenge_data", {})
	_challenge_data = (challenge_value as Dictionary).duplicate(true) if challenge_value is Dictionary else {}
	var profile_value: Variant = params.get("interaction_profile", {})
	var profile_data: Dictionary = (profile_value as Dictionary).duplicate(true) if profile_value is Dictionary else {}
	modulate.a = 1.0
	_apply_responsive_layout()
	_load_question(profile_data)
	_apply_theme()
	_animate_in()

func _animate_in() -> void:
	if not _should_animate():
		modulate.a = 1.0
		return
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, AccessibilityService.get_animation_duration(0.3) if AccessibilityService else 0.3)

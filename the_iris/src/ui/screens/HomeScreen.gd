extends Control
## Data-driven Home product hub. It never names a concrete Challenge Type.

@onready var brand_label: Label = $MainMargin/Scroll/Content/Hero/BrandLabel
@onready var greeting_label: Label = $MainMargin/Scroll/Content/Hero/GreetingLabel
@onready var rank_label: Label = $MainMargin/Scroll/Content/Hero/RankLabel
@onready var tagline_label: Label = $MainMargin/Scroll/Content/Hero/Tagline
@onready var stat_level: PanelContainer = $MainMargin/Scroll/Content/StatsRow/LevelCard
@onready var stat_progress: PanelContainer = $MainMargin/Scroll/Content/StatsRow/ProgressCard
@onready var stat_streak: PanelContainer = $MainMargin/Scroll/Content/StatsRow/StreakCard
@onready var play_now_button: Button = $MainMargin/Scroll/Content/PlayNowButton
@onready var recommendation_reason: Label = $MainMargin/Scroll/Content/RecommendationReason
@onready var continue_button: Button = $MainMargin/Scroll/Content/PrimaryLinks/ContinueButton
@onready var library_button: Button = $MainMargin/Scroll/Content/PrimaryLinks/LibraryButton
@onready var featured_header: Label = $MainMargin/Scroll/Content/FeaturedHeader
@onready var featured_host: VBoxContainer = $MainMargin/Scroll/Content/FeaturedHost
@onready var achievements_header: Label = $MainMargin/Scroll/Content/AchievementsHeader
@onready var achievements_host: VBoxContainer = $MainMargin/Scroll/Content/AchievementsHost
@onready var achievements_button: Button = $MainMargin/Scroll/Content/AchievementsButton
@onready var profile_button: Button = $MainMargin/Scroll/Content/QuickActions/ProfileButton
@onready var settings_button: Button = $MainMargin/Scroll/Content/QuickActions/SettingsButton
@onready var programs_card: PanelContainer = $MainMargin/Scroll/Content/ProgramsCard
@onready var programs_button: Button = $MainMargin/Scroll/Content/ProgramsCard/Margin/VBox/ProgramsButton

var _home_data: Dictionary = {}
var _launch_pending: bool = false
var _refresh_pending: bool = false

func _ready() -> void:
	_wire_buttons()
	_apply_responsive_layout()
	_apply_theme()
	_refresh_data()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService and not ProfileService.profile_saved.is_connected(_on_profile_saved):
		ProfileService.profile_saved.connect(_on_profile_saved)
	if AchievementService and not AchievementService.achievement_progress_updated.is_connected(_on_achievement_progress_updated):
		AchievementService.achievement_progress_updated.connect(_on_achievement_progress_updated)

func _wire_buttons() -> void:
	if not play_now_button.pressed.is_connected(_on_play_now):
		play_now_button.pressed.connect(_on_play_now)
	if not continue_button.pressed.is_connected(_on_continue):
		continue_button.pressed.connect(_on_continue)
	if not library_button.pressed.is_connected(_on_library):
		library_button.pressed.connect(_on_library)
	if not achievements_button.pressed.is_connected(_on_achievements):
		achievements_button.pressed.connect(_on_achievements)
	if not profile_button.pressed.is_connected(_on_profile):
		profile_button.pressed.connect(_on_profile)
	if not settings_button.pressed.is_connected(_on_settings):
		settings_button.pressed.connect(_on_settings)
	if not programs_button.pressed.is_connected(_on_programs):
		programs_button.pressed.connect(_on_programs)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background:
		background.color = tokens.get("background", Color("#0F0F12"))
	if ThemeService:
		ThemeService.apply_label_style(brand_label, "label_small", "text_tertiary")
		ThemeService.apply_label_style(greeting_label, "display", "text_primary")
		ThemeService.apply_label_style(rank_label, "title", "primary_variant")
		ThemeService.apply_label_style(tagline_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(recommendation_reason, "caption", "text_secondary")
		ThemeService.apply_label_style(featured_header, "label", "text_tertiary")
		ThemeService.apply_label_style(achievements_header, "label", "text_tertiary")
		ThemeService.apply_label_style(
			$MainMargin/Scroll/Content/QuickActionsHeader,
			"label",
			"text_tertiary"
		)
	_style_stat_card(stat_level, "WITNESS LEVEL", tokens)
	_style_stat_card(stat_progress, "PROGRESS", tokens)
	_style_stat_card(stat_streak, "STREAK", tokens)
	_style_button(play_now_button, true, tokens)
	for button: Button in [continue_button, library_button, achievements_button, profile_button, settings_button]:
		_style_button(button, false, tokens)
	_style_programs_card(tokens)

func _style_stat_card(card: PanelContainer, label_text: String, tokens: Dictionary) -> void:
	var style := _card_style(tokens)
	card.add_theme_stylebox_override("panel", style)
	var label: Label = card.get_node("Margin/VBox/Label") as Label
	var value: Label = card.get_node("Margin/VBox/Value") as Label
	label.text = label_text
	if ThemeService:
		ThemeService.apply_label_style(label, "label_small", "text_tertiary")
		ThemeService.apply_label_style(value, "title", "text_primary")

func _style_button(button: Button, primary: bool, tokens: Dictionary) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = (
		tokens.get("primary", Color("#6A3DFF"))
		if primary
		else tokens.get("surface", Color("#1E1E26"))
	)
	normal.border_color = tokens.get("border", Color("#2E2E3A"))
	normal.border_width_left = 0 if primary else 1
	normal.border_width_right = normal.border_width_left
	normal.border_width_top = normal.border_width_left
	normal.border_width_bottom = normal.border_width_left
	normal.corner_radius_top_left = 16
	normal.corner_radius_top_right = 16
	normal.corner_radius_bottom_left = 16
	normal.corner_radius_bottom_right = 16
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 14
	normal.content_margin_bottom = 14
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.10)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override(
		"font_size",
		ThemeService.get_font_size("body_small") if ThemeService else 16
	)

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin)

func _style_programs_card(tokens: Dictionary) -> void:
	programs_card.add_theme_stylebox_override("panel", _card_style(tokens))
	var title: Label = programs_card.get_node("Margin/VBox/Title") as Label
	var copy: Label = programs_card.get_node("Margin/VBox/Copy") as Label
	if ThemeService:
		ThemeService.apply_label_style(title, "title", "text_primary")
		ThemeService.apply_label_style(copy, "body_small", "text_secondary")
	_style_button(programs_button, false, tokens)

func _card_style(tokens: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 3)
	return style

func _refresh_data() -> void:
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	_home_data = RecommendationService.get_home_snapshot(player_state) if RecommendationService else {}
	_refresh_summary()
	_refresh_actions()
	_refresh_featured()
	_refresh_achievements()

func _refresh_summary() -> void:
	var summary: Dictionary = _home_data.get("witness_summary", {})
	var previous_level: int = 0
	var _previous_rank: String = ""
	if rank_label:
		previous_level = int(stat_level.get_node("Margin/VBox/Value").text) if stat_level else 0
		_previous_rank = rank_label.text
	rank_label.text = str(summary.get("rank", "Observer"))
	_set_stat_value(stat_level, str(summary.get("level", 1)))
	_set_stat_value(stat_progress, str(summary.get("progress_points", 0)))
	_set_stat_value(stat_streak, "%d · best %d" % [
		int(summary.get("current_streak", 0)),
		int(summary.get("best_streak", 0))
	])
	# Detect a rank-up and play a small celebratory flash.
	var new_level: int = int(summary.get("level", 1))
	if new_level > previous_level and previous_level > 0 and is_visible_in_tree():
		_flash_rank_up()

func _set_stat_value(card: PanelContainer, text: String) -> void:
	var value: Label = card.get_node("Margin/VBox/Value") as Label
	value.text = text

func _flash_rank_up() -> void:
	if not is_visible_in_tree():
		return
	if rank_label:
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var dur := 0.5
		tween.tween_property(rank_label, "modulate", Color(1.0, 0.72, 0.30, 1.0), dur * 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_property(rank_label, "modulate", Color(1, 1, 1, 1), dur * 0.6).set_ease(Tween.EASE_IN)
		rank_label.scale = Vector2.ONE
		var scale_tween := create_tween()
		scale_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		scale_tween.tween_property(rank_label, "scale", Vector2(1.12, 1.12), dur * 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		scale_tween.tween_property(rank_label, "scale", Vector2.ONE, dur * 0.55).set_ease(Tween.EASE_IN)
	if AudioService:
		AudioService.play_sfx("ui_unlock", 0.85)

func _refresh_actions() -> void:
	var play_recommendation: Dictionary = _home_data.get("play_now", {})
	play_now_button.disabled = play_recommendation.is_empty()
	play_now_button.text = "PLAY NOW\n%s" % str(play_recommendation.get("title", "Find a Challenge"))
	recommendation_reason.text = str(play_recommendation.get("reason_text", "Your next round is ready"))
	var continue_recommendation: Dictionary = _home_data.get("continue", {})
	var has_recent: bool = bool(_home_data.get("has_recent", false))
	continue_button.disabled = continue_recommendation.is_empty()
	continue_button.text = (
		"CONTINUE · %s" % str(continue_recommendation.get("program_title", continue_recommendation.get("title", "Recent Challenge")))
		if has_recent or not str(continue_recommendation.get("program_id", "")).is_empty()
		else "CONTINUE · START RECOMMENDATION"
	)
	var featured_program: Dictionary = _home_data.get("featured_program", {})
	var programs_copy: Label = programs_card.get_node("Margin/VBox/Copy") as Label
	if featured_program.is_empty():
		programs_copy.text = "Curated challenge journeys are ready from the Programs tab."
	else:
		programs_copy.text = "%s · %s" % [
			str(featured_program.get("title", "Featured Program")),
			str(featured_program.get("description", ""))
		]
	programs_button.disabled = int(_home_data.get("program_count", 0)) == 0

func _refresh_featured() -> void:
	for child: Node in featured_host.get_children():
		child.queue_free()
	var featured: Dictionary = _home_data.get("featured", {})
	var available: Array = _home_data.get("available_challenge_types", [])
	var card_data: Dictionary = _challenge_for_recommendation(featured, available)
	if card_data.is_empty():
		var empty := Label.new()
		empty.text = "A featured Challenge Type will appear when content is available."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_label_style(empty, "body_small", "text_secondary")
		featured_host.add_child(empty)
		return
	var card: Control = _create_challenge_card(card_data)
	card.name = "FeaturedChallengeCard"
	featured_host.add_child(card)

func _challenge_for_recommendation(recommendation: Dictionary, available: Array) -> Dictionary:
	var family_id: String = str(recommendation.get("family_id", ""))
	for item_value: Variant in available:
		if item_value is Dictionary:
			var item: Dictionary = item_value
			if str(item.get("family_id", "")) == family_id:
				return item.duplicate(true)
	return {}

func _create_challenge_card(challenge: Dictionary) -> Control:
	var scene: PackedScene = load("res://src/ui/components/ExperienceCard.tscn")
	var card: Control = scene.instantiate() as Control
	card.call("set_experience", challenge)
	card.connect("experience_selected", _on_featured_selected)
	card.connect("tutorial_requested", _on_tutorial_requested)
	card.connect("favorite_toggled", _on_favorite_toggled)
	return card

func _refresh_achievements() -> void:
	for child: Node in achievements_host.get_children():
		child.queue_free()
	var statuses: Array = _home_data.get("achievements_in_progress", [])
	if statuses.is_empty():
		var complete := Label.new()
		complete.text = "Every current milestone is unlocked."
		if ThemeService:
			ThemeService.apply_label_style(complete, "body_small", "text_secondary")
		achievements_host.add_child(complete)
		return
	for status_value: Variant in statuses:
		if status_value is Dictionary:
			achievements_host.add_child(_create_achievement_preview(status_value))

func _create_achievement_preview(status: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(ThemeService.tokens if ThemeService else {}))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	margin.add_child(stack)
	var row := HBoxContainer.new()
	stack.add_child(row)
	var title := Label.new()
	title.text = str(status.get("title", "Milestone"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_label_style(title, "label", "text_primary")
	row.add_child(title)
	var count := Label.new()
	count.text = "%d / %d" % [int(status.get("current", 0)), int(status.get("target", 1))]
	if ThemeService:
		ThemeService.apply_label_style(count, "caption", "text_secondary")
	count.autowrap_mode = TextServer.AUTOWRAP_OFF
	count.custom_minimum_size.x = 64.0
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(count)
	var progress := ProgressBar.new()
	progress.max_value = float(status.get("target", 1.0))
	progress.value = float(status.get("current", 0.0))
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 7)
	stack.add_child(progress)
	return card

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_launch_pending = false
	_set_launch_loading(false)
	_apply_responsive_layout()
	_apply_theme()
	_refresh_data()

func _on_play_now() -> void:
	if _launch_pending:
		return
	_play_feedback()
	_launch_pending = true
	_set_launch_loading(true, "Preparing your recommended round…")
	await get_tree().process_frame
	var started: bool = (
		ChallengeSessionService.start_recommended_session("play_now")
		if ChallengeSessionService
		else false
	)
	_set_launch_loading(false)
	_launch_pending = false
	if not started and NavigationService:
		NavigationService.navigate_to("experiences")

# Preserved for validated Gate 1/Gate 3 UI regression entry points.
func _on_quick_play() -> void:
	_on_play_now()

func _on_continue() -> void:
	if _launch_pending:
		return
	_play_feedback()
	_launch_pending = true
	_set_launch_loading(true, "Preparing your next round…")
	await get_tree().process_frame
	var started: bool = (
		ChallengeSessionService.start_continue_session("continue")
		if ChallengeSessionService
		else false
	)
	_set_launch_loading(false)
	_launch_pending = false
	if not started and NavigationService:
		NavigationService.navigate_to("experiences")

func _on_featured_selected(template_id: String) -> void:
	if _launch_pending:
		return
	_launch_pending = true
	_set_launch_loading(true, "Preparing today’s featured round…")
	await get_tree().process_frame
	var started: bool = (
		ChallengeSessionService.start_template_session(template_id, "home_featured")
		if ChallengeSessionService
		else false
	)
	_set_launch_loading(false)
	_launch_pending = false
	if not started and NavigationService:
		NavigationService.navigate_to("experiences")

func _set_launch_loading(loading: bool, message: String = "") -> void:
	play_now_button.disabled = loading or _home_data.get("play_now", {}).is_empty()
	continue_button.disabled = loading or _home_data.get("continue", {}).is_empty()
	programs_button.disabled = loading or int(_home_data.get("program_count", 0)) == 0
	if AppState:
		AppState.set_loading(loading, message)

func _on_tutorial_requested(family_id: String) -> void:
	if NavigationService:
		NavigationService.navigate_to("tutorial", {"replay": true, "family_id": family_id})

func _on_favorite_toggled(family_id: String, favorite: bool) -> void:
	if PlayerProgressService and PlayerProgressService.set_family_favorite(family_id, favorite):
		_refresh_data()

func _on_library() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("experiences")

func _on_achievements() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("achievements")

func _on_programs() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("programs")

func _on_profile() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("profile")

func _on_settings() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("settings")

func _play_feedback() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh_featured()
		_refresh_achievements()
	else:
		_refresh_pending = true

func _on_profile_saved(_profile: Dictionary) -> void:
	_request_data_refresh()

func _on_achievement_progress_updated(_statuses: Array[Dictionary]) -> void:
	_request_data_refresh()

func _request_data_refresh() -> void:
	if is_visible_in_tree():
		call_deferred("_refresh_data")
	else:
		_refresh_pending = true

extends Control
## Witness Home — Phase 0 focused landing surface.
## "What should I witness now?"
## Reuses all existing services. No new gameplay or data logic.

@onready var brand_eye: TextureRect = $MainMargin/Scroll/Content/IdentityLayer/BrandRow/Eye
@onready var greeting_label: Label = $MainMargin/Scroll/Content/IdentityLayer/Greeting
@onready var rank_label: Label = $MainMargin/Scroll/Content/IdentityLayer/RankRow/RankLabel
@onready var level_pill: PanelContainer = $MainMargin/Scroll/Content/IdentityLayer/RankRow/LevelPill
@onready var level_text: Label = $MainMargin/Scroll/Content/IdentityLayer/RankRow/LevelPill/LevelMargin/LevelText
@onready var progress_bar: ProgressBar = $MainMargin/Scroll/Content/IdentityLayer/ProgressBar

@onready var daily_host: VBoxContainer = $MainMargin/Scroll/Content/DailyExperienceLayer/DailyCardHost
@onready var daily_card: Control = $MainMargin/Scroll/Content/DailyExperienceLayer/DailyCardHost/DailyExperienceCard

var _current_daily_is_continue: bool = false

@onready var streak_pill: PanelContainer = $MainMargin/Scroll/Content/ProgressLayer/StreakPill
@onready var streak_value: Label = $MainMargin/Scroll/Content/ProgressLayer/StreakPill/StreakMargin/StreakVBox/StreakValue
@onready var streak_sub: Label = $MainMargin/Scroll/Content/ProgressLayer/StreakPill/StreakMargin/StreakVBox/StreakSub
@onready var ach_pill: PanelContainer = $MainMargin/Scroll/Content/ProgressLayer/AchievementPill
@onready var ach_value: Label = $MainMargin/Scroll/Content/ProgressLayer/AchievementPill/AchMargin/AchVBox/AchValue
@onready var ach_sub: Label = $MainMargin/Scroll/Content/ProgressLayer/AchievementPill/AchMargin/AchVBox/AchSub

@onready var discovery_header_label: Label = $MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryHeader/HeaderLabel
@onready var see_all_button: Button = $MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryHeader/SeeAllButton
@onready var programs_card: PanelContainer = $MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox/ProgramsCard
@onready var programs_copy: Label = $MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox/ProgramsCard/ProgramsMargin/ProgramsVBox/ProgramsCopy
@onready var programs_button: Button = $MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox/ProgramsCard/ProgramsMargin/ProgramsVBox/ProgramsButton

var _home_data: Dictionary = {}
var _launch_pending: bool = false

func _ready() -> void:
	_wire_buttons()
	_apply_theme()
	_apply_responsive_layout()
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
	if daily_card and daily_card.has_signal("start_requested") and not daily_card.start_requested.is_connected(_on_daily_start):
		daily_card.start_requested.connect(_on_daily_start)
	
	if see_all_button and not see_all_button.pressed.is_connected(_on_library):
		see_all_button.pressed.connect(_on_library)
	if programs_button and not programs_button.pressed.is_connected(_on_record):
		programs_button.pressed.connect(_on_record)
	_ensure_secondary_settings_action()

func _ensure_secondary_settings_action() -> void:
	var host := get_node_or_null("MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox") as HBoxContainer
	if host == null or host.has_node("SettingsCard"):
		return
	var card := PanelContainer.new()
	card.name = "SettingsCard"
	card.custom_minimum_size = Vector2(220, 0)
	host.add_child(card)
	var margin := MarginContainer.new()
	margin.name = "SettingsMargin"
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.name = "SettingsVBox"
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)
	var title := Label.new()
	title.name = "SettingsTitle"
	title.text = "SETTINGS"
	stack.add_child(title)
	var copy := Label.new()
	copy.name = "SettingsCopy"
	copy.text = "Comfort, sound, accessibility"
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(copy)
	var button := Button.new()
	button.name = "SettingsButton"
	button.text = "OPEN"
	button.custom_minimum_size = Vector2(0, 40)
	button.pressed.connect(_on_settings)
	stack.add_child(button)

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var bg: ColorRect = get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12"))
	
	# Identity
	if ThemeService:
		ThemeService.apply_label_style(greeting_label, "body", "text_primary")
		ThemeService.apply_label_style(rank_label, "title", "primary_variant")
		ThemeService.apply_label_style(level_text, "label_small", "text_primary")
		ThemeService.apply_label_style(discovery_header_label, "label_small", "text_tertiary")
	
	# Level pill
	_style_level_pill(level_pill, tokens)
	
	# Progress bar styling
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = tokens.get("background_tertiary", Color("#24242C"))
	bar_bg.corner_radius_top_left = 99
	bar_bg.corner_radius_top_right = 99
	bar_bg.corner_radius_bottom_left = 99
	bar_bg.corner_radius_bottom_right = 99
	progress_bar.add_theme_stylebox_override("background", bar_bg)
	
	var bar_fill := bar_bg.duplicate()
	bar_fill.bg_color = tokens.get("primary_variant", Color("#8A68FF"))
	progress_bar.add_theme_stylebox_override("fill", bar_fill)
	
	# Pills
	_style_pill(streak_pill, tokens)
	_style_pill(ach_pill, tokens)
	_style_programs_card(tokens)
	_style_settings_card(tokens)
	
	# Buttons
	_style_secondary_button(see_all_button, tokens)
	_style_secondary_button(programs_button, tokens)
	_apply_text_layout_guards()

func _apply_text_layout_guards() -> void:
	for label: Label in [greeting_label, rank_label, level_text, discovery_header_label, streak_value, streak_sub, ach_value, ach_sub]:
		_set_single_line_label(label)
	for path: String in [
		"MainMargin/Scroll/Content/ProgressLayer/StreakPill/StreakMargin/StreakVBox/StreakLabel",
		"MainMargin/Scroll/Content/ProgressLayer/AchievementPill/AchMargin/AchVBox/AchLabel",
		"MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox/ProgramsCard/ProgramsMargin/ProgramsVBox/ProgramsTitle"
	]:
		_set_single_line_label(get_node_or_null(path) as Label)

func _set_single_line_label(label: Label) -> void:
	if not label:
		return
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _style_pill(pill: PanelContainer, tokens: Dictionary) -> void:
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
	pill.add_theme_stylebox_override("panel", style)
	
	# Main labels (small tertiary)
	for lbl_path in [
		"StreakMargin/StreakVBox/StreakLabel",
		"AchMargin/AchVBox/AchLabel"
	]:
		var lbl = pill.get_node_or_null(lbl_path)
		if lbl is Label and ThemeService:
			ThemeService.apply_label_style(lbl as Label, "label_small", "text_tertiary")
	
	# Main values (title primary)
	for val_path in [
		"StreakMargin/StreakVBox/StreakValue",
		"AchMargin/AchVBox/AchValue"
	]:
		var val = pill.get_node_or_null(val_path)
		if val is Label and ThemeService:
			ThemeService.apply_label_style(val as Label, "title", "text_primary")
	
	# Sub labels (caption, more subtle)
	for sub_path in [
		"StreakMargin/StreakVBox/StreakSub",
		"AchMargin/AchVBox/AchSub"
	]:
		var sub = pill.get_node_or_null(sub_path)
		if sub is Label and ThemeService:
			ThemeService.apply_label_style(sub as Label, "caption", "text_tertiary")
			sub.add_theme_font_size_override("font_size", max(11, ThemeService.get_font_size("caption") - 1))

func _style_programs_card(tokens: Dictionary) -> void:
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
	programs_card.add_theme_stylebox_override("panel", style)
	
	if ThemeService:
		var prog_title: Label = programs_card.get_node_or_null("ProgramsMargin/ProgramsVBox/ProgramsTitle") as Label
		if prog_title:
			ThemeService.apply_label_style(prog_title, "label", "text_primary")
		ThemeService.apply_label_style(programs_copy, "caption", "text_secondary")
		ThemeService.apply_typography(programs_button, "label_small")

func _style_settings_card(tokens: Dictionary) -> void:
	var card := get_node_or_null("MainMargin/Scroll/Content/DiscoveryLayer/DiscoveryScroll/DiscoveryHBox/SettingsCard") as PanelContainer
	if not card:
		return
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
	card.add_theme_stylebox_override("panel", style)
	if ThemeService:
		ThemeService.apply_label_style(card.get_node("SettingsMargin/SettingsVBox/SettingsTitle") as Label, "label", "text_primary")
		ThemeService.apply_label_style(card.get_node("SettingsMargin/SettingsVBox/SettingsCopy") as Label, "caption", "text_secondary")
		ThemeService.apply_typography(card.get_node("SettingsMargin/SettingsVBox/SettingsButton") as Button, "label_small")
	_style_secondary_button(card.get_node("SettingsMargin/SettingsVBox/SettingsButton") as Button, tokens)

func _style_secondary_button(btn: Button, tokens: Dictionary) -> void:
	if not btn:
		return
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("surface", Color("#1E1E26"))
	normal.border_color = tokens.get("border", Color("#2E2E3A"))
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small") if ThemeService else 14)

func _style_level_pill(pill: PanelContainer, tokens: Dictionary) -> void:
	if not pill:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(tokens.get("primary", Color("#6A3DFF")), 0.18)
	style.border_color = tokens.get("primary_variant", Color("#8A68FF"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_left = 999
	style.corner_radius_bottom_right = 999
	pill.add_theme_stylebox_override("panel", style)
	
	if level_text and ThemeService:
		ThemeService.apply_label_style(level_text, "label_small", "text_primary")
		level_text.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small"))

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin)
	ResponsiveLayout.prepare_mobile_scroll(
		$MainMargin/Scroll,
		$MainMargin/Scroll/Content,
		$MainMargin/Scroll/Content/BottomSpacer
	)

func _refresh_data() -> void:
	var player_state: Dictionary = PlayerProgressService.get_player_state() if PlayerProgressService else {}
	_home_data = RecommendationService.get_home_snapshot(player_state) if RecommendationService else {}
	
	_refresh_identity()
	_refresh_daily_experience()
	_refresh_progress()
	_refresh_discovery()

func _refresh_identity() -> void:
	var summary: Dictionary = _home_data.get("witness_summary", {})
	
	greeting_label.text = "Witness"
	rank_label.text = "Observe what others miss."
	level_text.text = "LVL %d" % int(summary.get("level", 1))
	if level_pill:
		level_pill.visible = false
	if progress_bar:
		progress_bar.visible = false
	
	# Simple brand eye modulation
	if brand_eye:
		brand_eye.modulate = Color(1, 1, 1, 0.85)

func _refresh_daily_experience() -> void:
	var play_now: Dictionary = _home_data.get("play_now", {})
	var continue_rec: Dictionary = _home_data.get("continue", {})
	var has_recent: bool = bool(_home_data.get("has_recent", false))
	var available: Array = _home_data.get("available_challenge_types", [])
	
	# Prioritize Continue when there is an active program or recent session
	var use_continue: bool = false
	if not continue_rec.is_empty():
		var prog_id := str(continue_rec.get("program_id", ""))
		if not prog_id.is_empty() or has_recent:
			use_continue = true
	
	if daily_card and daily_card.has_method("set_recommendation"):
		if use_continue:
			_current_daily_is_continue = true
			if daily_card.has_method("set_continue_recommendation"):
				daily_card.set_continue_recommendation(continue_rec, available)
			else:
				daily_card.set_recommendation(continue_rec, available)
		else:
			_current_daily_is_continue = false
			daily_card.set_recommendation(play_now, available)

func _refresh_progress() -> void:
	var record: Dictionary = PlayerProgressService.get_observation_record() if PlayerProgressService else {}
	var moments := int(record.get("total_plays", 0))
	var accuracy := int(round(float(record.get("accuracy", 0.0)) * 100.0))
	var rank := str(record.get("witness_rank", "Observer"))
	var level := int(record.get("witness_level", 1))
	var streak_label_node := get_node_or_null("MainMargin/Scroll/Content/ProgressLayer/StreakPill/StreakMargin/StreakVBox/StreakLabel") as Label
	var ach_label_node := get_node_or_null("MainMargin/Scroll/Content/ProgressLayer/AchievementPill/AchMargin/AchVBox/AchLabel") as Label
	if streak_label_node:
		streak_label_node.text = "MOMENTS WITNESSED"
	if ach_label_node:
		ach_label_node.text = "WITNESS RECORD"
	streak_value.text = str(moments)
	if streak_sub:
		streak_sub.text = "completed observations" if moments != 1 else "completed observation"
	ach_value.text = "%d%%" % accuracy if moments > 0 else "New"
	if ach_sub:
		ach_sub.text = "%s · Level %d" % [rank, level]

func _refresh_discovery() -> void:
	if discovery_header_label:
		discovery_header_label.text = "SECONDARY"
	if see_all_button:
		see_all_button.text = "Explore Experiences"
	var title := programs_card.get_node_or_null("ProgramsMargin/ProgramsVBox/ProgramsTitle") as Label
	if title:
		title.text = "YOUR RECORD"
	programs_copy.text = "Review observations, accuracy, and personal milestones."
	programs_button.text = "OPEN RECORD"
	programs_button.disabled = false

func on_navigated_to(_params: Dictionary = {}) -> void:
	_launch_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh_data()

# === ACTIONS ===

func _on_daily_start() -> void:
	if _launch_pending:
		return
	_launch_pending = true
	
	var is_continue := _current_daily_is_continue or bool(_home_data.get("continue", {}).get("program_id", ""))
	var loading_msg := "Preparing your next round…" if is_continue else "Preparing your recommended round…"
	_set_loading(true, loading_msg)
	
	await get_tree().process_frame
	
	var started: bool = false
	if ChallengeSessionService:
		if is_continue:
			started = ChallengeSessionService.start_continue_session("continue")
		else:
			started = ChallengeSessionService.start_recommended_session("play_now")
	
	_set_loading(false)
	_launch_pending = false
	
	if not started and NavigationService:
		NavigationService.navigate_to("experiences")

func _on_library() -> void:
	_play_feedback()
	if NavigationService:
		NavigationService.navigate_to("experiences")

func _on_record() -> void:
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

func _set_loading(loading: bool, message: String = "") -> void:
	if daily_card and daily_card.has_method("set_disabled"):
		daily_card.set_disabled(loading)
	if AppState:
		AppState.set_loading(loading, message if message != "" else "Preparing…")

func _on_theme_changed(_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh_daily_experience()
	else:
		# Defer until visible
		pass

func _on_profile_saved(_profile: Dictionary) -> void:
	_request_refresh()

func _on_achievement_progress_updated(_statuses: Array[Dictionary]) -> void:
	_request_refresh()

func _request_refresh() -> void:
	if is_visible_in_tree():
		call_deferred("_refresh_data")
	else:
		pass

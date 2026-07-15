extends Control
## Player identity, Witness progression, mastery, achievements, and recent history.

const SKILL_ACCENTS: Array[Color] = [
	Color("#8A68FF"), Color("#36CFC9"), Color("#FFB454"), Color("#F071B8"), Color("#62A8FF")
]
const MONTH_NAMES: Array[String] = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
]

var _refresh_pending: bool = false

@onready var avatar_card: PanelContainer = $Margin/Scroll/VBox/AvatarCard
@onready var badge: PanelContainer = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Badge
@onready
var badge_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Badge/Margin/VBox/BadgeLabel
@onready var profile_eyebrow: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/Eyebrow
@onready var name_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/NameLabel
@onready var rank_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/RankLabel
@onready var since_label: Label = $Margin/Scroll/VBox/AvatarCard/Margin/HBox/Text/SinceLabel
@onready var level_card: PanelContainer = $Margin/Scroll/VBox/LevelCard
@onready var stats_grid: GridContainer = $Margin/Scroll/VBox/StatsGrid
@onready var family_mastery: VBoxContainer = $Margin/Scroll/VBox/ExperienceProgress
@onready var history_list: VBoxContainer = $Margin/Scroll/VBox/HistoryList
@onready var program_header: Label = $Margin/Scroll/VBox/ProgramsHeader
@onready var program_summary: VBoxContainer = $Margin/Scroll/VBox/ProgramSummary
@onready var achievement_card: PanelContainer = $Margin/Scroll/VBox/AchievementCard
@onready var achievement_summary: Label = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/Summary
@onready var achievement_next: Label = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/NextMilestone
@onready
var achievement_bar: ProgressBar = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/AchievementBar
@onready
var achievement_button: Button = $Margin/Scroll/VBox/AchievementCard/Margin/VBox/AchievementButton
@onready var collections_card: PanelContainer = $Margin/Scroll/VBox/CollectionsCard


func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	if not achievement_button.pressed.is_connected(_on_achievements_pressed):
		achievement_button.pressed.connect(_on_achievements_pressed)
	if OS.is_debug_build():
		_create_debug_reset_button()
	_apply_theme()
	_refresh()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	if ProfileService and not ProfileService.profile_saved.is_connected(_on_profile_saved):
		ProfileService.profile_saved.connect(_on_profile_saved)
	if (
		AchievementService
		and not AchievementService.achievement_progress_updated.is_connected(
			_on_achievement_progress_updated
		)
	):
		AchievementService.achievement_progress_updated.connect(_on_achievement_progress_updated)
	if ChallengeFamilyRegistry:
		if not ChallengeFamilyRegistry.family_registered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_registered.connect(_on_family_changed)
		if not ChallengeFamilyRegistry.family_unregistered.is_connected(_on_family_changed):
			ChallengeFamilyRegistry.family_unregistered.connect(_on_family_changed)


func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)
	ResponsiveLayout.prepare_mobile_scroll($Margin/Scroll, $Margin/Scroll/VBox, $Margin/Scroll/VBox/BottomSpacer)


func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background:
		background.color = tokens.get("background", Color("#0F0F12"))
	avatar_card.add_theme_stylebox_override("panel", _hero_style(tokens))
	badge.add_theme_stylebox_override("panel", _badge_style(tokens))
	level_card.add_theme_stylebox_override(
		"panel",
		_card_style(tokens, _with_alpha(tokens.get("primary", Color("#6A3DFF")), 0.5), true)
	)
	achievement_card.add_theme_stylebox_override(
		"panel",
		_card_style(tokens, _with_alpha(tokens.get("primary", Color("#6A3DFF")), 0.5), true)
	)
	collections_card.add_theme_stylebox_override("panel", _card_style(tokens))
	_style_progress_bar(achievement_bar, tokens.get("primary_variant", Color("#8A68FF")))
	_style_primary_button(achievement_button, tokens)

	if ThemeService:
		ThemeService.apply_label_style(profile_eyebrow, "label_small", "primary_variant")
		ThemeService.apply_label_style(name_label, "headline", "text_primary")
		ThemeService.apply_label_style(rank_label, "label", "primary_variant")
		ThemeService.apply_label_style(since_label, "caption", "text_secondary")
		ThemeService.apply_label_style(badge_label, "caption", "text_primary")
		for path: String in [
			"Margin/Scroll/VBox/ObservationHeader",
			"Margin/Scroll/VBox/MasteryHeader",
			"Margin/Scroll/VBox/AchievementsHeader",
			"Margin/Scroll/VBox/HistoryHeader",
			"Margin/Scroll/VBox/ProgramsHeader"
		]:
			ThemeService.apply_label_style(get_node(path) as Label, "label_small", "text_tertiary")
		for path: String in [
			"Margin/Scroll/VBox/RecordIntro",
			"Margin/Scroll/VBox/MasteryIntro",
			"Margin/Scroll/VBox/HistoryIntro"
		]:
			ThemeService.apply_label_style(get_node(path) as Label, "caption", "text_secondary")
		ThemeService.apply_label_style(achievement_summary, "title", "text_primary")
		ThemeService.apply_label_style(achievement_next, "body_small", "text_secondary")


func _refresh() -> void:
	if not ProfileService:
		return
	var profile: Dictionary = ProfileService.profile
	var record: Dictionary = (
		PlayerProgressService.get_observation_record() if PlayerProgressService else {}
	)
	name_label.text = str(profile.get("display_name", "Witness"))
	rank_label.text = (
		"%s · Witness Level %d"
		% [str(record.get("witness_rank", "Observer")), int(record.get("witness_level", 1))]
	)
	since_label.text = _membership_copy(str(profile.get("created_at", "")))
	_refresh_level(record)
	_refresh_observation_record(record)
	_refresh_family_mastery()
	_refresh_achievement_summary()
	_refresh_history()
	_refresh_program_summary()
	# Collection data remains compatible with existing saves but is intentionally
	# not presented as a player-facing Profile section.
	_refresh_collections()


func _membership_copy(created_at: String) -> String:
	var member_since := "today"
	var date_part: String = created_at.split("T")[0] if not created_at.is_empty() else ""
	var pieces: PackedStringArray = date_part.split("-")
	if pieces.size() >= 2:
		var month: int = int(pieces[1])
		var year: int = int(pieces[0])
		if month >= 1 and month <= MONTH_NAMES.size() and year > 0:
			member_since = "%s %d" % [MONTH_NAMES[month - 1], year]
	return "Witness since %s" % member_since


func _refresh_level(record: Dictionary) -> void:
	for child: Node in level_card.get_children():
		child.queue_free()
	var total_progress: int = int(record.get("total_progress", 0))
	var level: int = int(record.get("witness_level", 1))
	var progress_in_level: int = total_progress % 100
	var margin := _margin(18)
	level_card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	var eyebrow := Label.new()
	eyebrow.text = "WITNESS PROGRESS"
	if ThemeService:
		ThemeService.apply_label_style(eyebrow, "label_small", "primary_variant")
	stack.add_child(eyebrow)
	var title := Label.new()
	title.text = "%d of 100 toward Witness Level %d" % [progress_in_level, level + 1]
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(title, "title", "text_primary")
	stack.add_child(title)

	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = float(progress_in_level)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 9)
	_style_progress_bar(bar, _theme_color("primary_variant", Color("#8A68FF")))
	stack.add_child(bar)

	var next_rank: String = str(record.get("next_rank", "Top Rank"))
	var next_rank_level: int = int(record.get("next_rank_level", level))
	var milestone := Label.new()
	milestone.text = (
		"Next rank · %s at Witness Level %d" % [next_rank, next_rank_level]
		if next_rank != "Top Rank"
		else "Master Witness rank achieved"
	)
	milestone.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(milestone, "body_small", "text_secondary")
	stack.add_child(milestone)


func _refresh_observation_record(record: Dictionary) -> void:
	for child: Node in stats_grid.get_children():
		child.queue_free()
	# Fastest Response and Current Streak are useful internally, but putting every
	# available number on Profile made the record feel like a spreadsheet.
	var definitions: Array[Dictionary] = [
		{
			"label": "Accuracy",
			"value": "%d%%" % int(round(float(record.get("accuracy", 0.0)) * 100.0)),
			"highlight": true
		},
		{
			"label": "Challenges Completed",
			"value": str(record.get("total_plays", 0)),
			"highlight": false
		},
		{"label": "Best Streak", "value": str(record.get("best_streak", 0)), "highlight": false}
	]
	for definition: Dictionary in definitions:
		stats_grid.add_child(
			_stat_card(
				str(definition.get("label", "Stat")),
				str(definition.get("value", "0")),
				bool(definition.get("highlight", false))
			)
		)


func _refresh_family_mastery() -> void:
	for child: Node in family_mastery.get_children():
		child.queue_free()
	var player_state: Dictionary = (
		PlayerProgressService.get_player_state() if PlayerProgressService else {}
	)
	var challenge_types: Array[Dictionary] = (
		RecommendationService.get_available_challenge_types(player_state)
		if RecommendationService
		else []
	)
	if challenge_types.is_empty():
		family_mastery.add_child(_empty_label("Your Challenge Type mastery will grow here."))
		return
	for challenge_type: Dictionary in challenge_types:
		family_mastery.add_child(_mastery_card(challenge_type))


func _mastery_card(challenge_type: Dictionary) -> Control:
	var title_text: String = str(challenge_type.get("title", "Challenge Type"))
	var identity: String = str(challenge_type.get("family_id", title_text))
	var accent: Color = _accent_for(identity)
	var progress: Dictionary = challenge_type.get("progress", {})
	var mastery_value: float = clampf(float(progress.get("mastery", 0.0)), 0.0, 100.0)
	var mastery_percent: int = int(round(mastery_value))

	var card := PanelContainer.new()
	card.add_theme_stylebox_override(
		"panel", _card_style(ThemeService.tokens if ThemeService else {}, _with_alpha(accent, 0.55))
	)
	var margin := _margin(15)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	stack.add_child(header)
	var skill_badge := PanelContainer.new()
	skill_badge.custom_minimum_size = Vector2(44, 44)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = _with_alpha(accent, 0.16)
	badge_style.border_color = _with_alpha(accent, 0.6)
	badge_style.border_width_left = 1
	badge_style.border_width_right = 1
	badge_style.border_width_top = 1
	badge_style.border_width_bottom = 1
	badge_style.corner_radius_top_left = 12
	badge_style.corner_radius_top_right = 12
	badge_style.corner_radius_bottom_left = 12
	badge_style.corner_radius_bottom_right = 12
	skill_badge.add_theme_stylebox_override("panel", badge_style)
	var initial := Label.new()
	initial.text = title_text.left(1).to_upper()
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_color_override("font_color", accent)
	if ThemeService:
		ThemeService.apply_typography(initial, "title")
	skill_badge.add_child(initial)
	header.add_child(skill_badge)

	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.add_theme_constant_override("separation", 2)
	header.add_child(text_stack)
	var title := Label.new()
	title.text = title_text
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(title, "label", "text_primary")
	text_stack.add_child(title)
	var focus := Label.new()
	focus.text = _focus_copy(challenge_type.get("gameplay_focus", []))
	focus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(focus, "caption", "text_secondary")
	text_stack.add_child(focus)

	var mastery := Label.new()
	mastery.text = "%d%%" % mastery_percent
	mastery.custom_minimum_size.x = 58
	mastery.autowrap_mode = TextServer.AUTOWRAP_OFF
	mastery.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mastery.add_theme_color_override("font_color", accent)
	if ThemeService:
		ThemeService.apply_typography(mastery, "label")
	header.add_child(mastery)

	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = mastery_value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	_style_progress_bar(bar, accent)
	stack.add_child(bar)

	var growth := Label.new()
	growth.text = _mastery_message(mastery_percent, int(progress.get("plays", 0)))
	growth.add_theme_color_override("font_color", accent)
	if ThemeService:
		ThemeService.apply_typography(growth, "label_small")
	stack.add_child(growth)
	var detail := Label.new()
	detail.text = (
		"%d rounds · %d%% accuracy"
		% [int(progress.get("plays", 0)), int(round(float(progress.get("accuracy", 0.0)) * 100.0))]
	)
	if ThemeService:
		ThemeService.apply_label_style(detail, "caption", "text_secondary")
	stack.add_child(detail)
	return card


func _focus_copy(value: Variant) -> String:
	if not (value is Array) or (value as Array).is_empty():
		return "Observation skill"
	var labels: Array[String] = []
	var focus_values: Array = value as Array
	for index: int in range(mini(2, focus_values.size())):
		labels.append(str(focus_values[index]))
	return " · ".join(labels)


func _mastery_message(mastery: int, plays: int) -> String:
	if plays <= 0:
		return "Ready for your first observation"
	if mastery < 25:
		return "Building familiarity"
	if mastery < 50:
		return "Finding your rhythm"
	if mastery < 75:
		return "Growing more consistent"
	if mastery < 90:
		return "Strong and still improving"
	return "Exceptional command"


func _refresh_achievement_summary() -> void:
	var unlocked: int = AchievementService.get_unlocked_count() if AchievementService else 0
	var total: int = AchievementService.get_definitions().size() if AchievementService else 0
	achievement_summary.text = "%d of %d achievements earned" % [unlocked, total]
	achievement_bar.max_value = maxf(float(total), 1.0)
	achievement_bar.value = float(unlocked)
	var featured: Array[Dictionary] = (
		AchievementService.get_featured_statuses(1) if AchievementService else []
	)
	if featured.is_empty():
		achievement_next.text = "Every current achievement is yours."
	else:
		var next_status: Dictionary = featured[0]
		achievement_next.text = (
			"Up next · %s · %d / %d"
			% [
				str(next_status.get("title", "Next milestone")),
				int(next_status.get("current", 0)),
				int(next_status.get("target", 1))
			]
		)


# CHALLENGE HISTORY is presented as a shorter, calmer recent record.
func _refresh_history() -> void:
	for child: Node in history_list.get_children():
		child.queue_free()
	var history: Array[Dictionary] = (
		PlayerProgressService.get_recent_history(6) if PlayerProgressService else []
	)
	if history.is_empty():
		history_list.add_child(
			_empty_label("Complete a round and your recent observations will appear here.")
		)
		return
	for entry: Dictionary in history:
		history_list.add_child(_history_row(entry))


func _history_row(entry: Dictionary) -> Control:
	var correct: bool = str(entry.get("outcome", "")) == "correct"
	var accent: Color = (
		_theme_color("success", Color("#2EE6A6"))
		if correct
		else _theme_color("primary_variant", Color("#8A68FF"))
	)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override(
		"panel", _card_style(ThemeService.tokens if ThemeService else {}, _with_alpha(accent, 0.35))
	)
	var margin := _margin(13)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	stack.add_child(row)
	var title := Label.new()
	title.text = str(entry.get("family_title", "Challenge Type"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(title, "body_small", "text_primary")
	row.add_child(title)
	var outcome := Label.new()
	outcome.text = "Detail found" if correct else "Missed detail"
	outcome.autowrap_mode = TextServer.AUTOWRAP_OFF
	outcome.custom_minimum_size.x = 100.0
	outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	outcome.add_theme_color_override("font_color", accent)
	if ThemeService:
		ThemeService.apply_typography(outcome, "label_small")
	row.add_child(outcome)

	var template := Label.new()
	template.text = str(entry.get("template_id", "Round")).replace("_", " ").capitalize()
	template.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(template, "caption", "text_secondary")
	stack.add_child(template)
	return card


func _refresh_program_summary() -> void:
	for child: Node in program_summary.get_children():
		child.queue_free()
	program_header.visible = false
	program_summary.visible = false
	if not ProgramService:
		return
	var player_state: Dictionary = (
		PlayerProgressService.get_player_state() if PlayerProgressService else {}
	)
	var shown: bool = false
	for program: Dictionary in ProgramService.get_programs(player_state):
		var progress: Dictionary = program.get("progress", {})
		if (
			int(progress.get("rounds_completed", 0)) == 0
			and int(progress.get("current_run_round", 0)) == 0
		):
			continue
		shown = true
		program_summary.add_child(
			_simple_record_card(
				str(program.get("title", "Program")),
				(
					"%d rounds · %d journeys complete · %d%% accuracy"
					% [
						int(progress.get("rounds_completed", 0)),
						int(progress.get("completed_runs", 0)),
						int(round(float(progress.get("accuracy", 0.0)) * 100.0))
					]
				)
			)
		)
	program_header.visible = shown
	program_summary.visible = shown


func _refresh_collections() -> void:
	var title: Label = $Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Title
	var copy: Label = $Margin/Scroll/VBox/CollectionsCard/Margin/VBox/Copy
	var player_state: Dictionary = (
		PlayerProgressService.get_player_state() if PlayerProgressService else {}
	)
	var catalog: Array[Dictionary] = (
		RecommendationService.get_available_challenge_types(player_state)
		if RecommendationService
		else []
	)
	var discovered: int = 0
	for item: Dictionary in catalog:
		if int((item.get("progress", {}) as Dictionary).get("plays", 0)) > 0:
			discovered += 1
	var achievements_unlocked: int = (
		AchievementService.get_unlocked_count() if AchievementService else 0
	)
	var achievement_total: int = (
		AchievementService.get_definitions().size() if AchievementService else 0
	)
	var completed_runs: int = ProgramService.get_completed_run_count() if ProgramService else 0
	var collection_ratio := (
		float(discovered + achievements_unlocked)
		/ maxf(float(catalog.size() + achievement_total), 1.0)
	)
	title.text = "COLLECTION PROGRESS · %d%%" % int(round(collection_ratio * 100.0))
	copy.text = (
		"Challenge Types discovered: %d / %d\nAchievements collected: %d / %d\nCurated runs completed: %d"
		% [discovered, catalog.size(), achievements_unlocked, achievement_total, completed_runs]
	)


func _simple_record_card(title_text: String, detail_text: String) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override(
		"panel", _card_style(ThemeService.tokens if ThemeService else {})
	)
	var margin := _margin(13)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)
	var title := Label.new()
	title.text = title_text
	if ThemeService:
		ThemeService.apply_label_style(title, "body_small", "text_primary")
	stack.add_child(title)
	var detail := Label.new()
	detail.text = detail_text
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(detail, "caption", "text_secondary")
	stack.add_child(detail)
	return card


func _stat_card(label_text: String, value_text: String, highlighted: bool) -> Control:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var accent: Color = tokens.get("primary_variant", Color("#8A68FF"))
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 104 if highlighted else 92)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(
		"panel",
		_card_style(
			tokens, _with_alpha(accent, 0.65) if highlighted else Color.TRANSPARENT, highlighted
		)
	)
	var margin := _margin(14)
	card.add_child(margin)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)
	var value := Label.new()
	value.text = value_text
	value.add_theme_color_override(
		"font_color", accent if highlighted else tokens.get("text_primary", Color.WHITE)
	)
	if ThemeService:
		ThemeService.apply_typography(value, "display" if highlighted else "title")
	stack.add_child(value)
	var label := Label.new()
	label.text = label_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "label_small", "text_tertiary")
	stack.add_child(label)
	return card


func _empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size.y = 56
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if ThemeService:
		ThemeService.apply_label_style(label, "body_small", "text_secondary")
	return label


func _margin(amount: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", amount)
	margin.add_theme_constant_override("margin_right", amount)
	margin.add_theme_constant_override("margin_top", amount)
	margin.add_theme_constant_override("margin_bottom", amount)
	return margin


func _hero_style(tokens: Dictionary) -> StyleBoxFlat:
	var style := _card_style(
		tokens, _with_alpha(tokens.get("primary", Color("#6A3DFF")), 0.85), true
	)
	style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	return style


func _badge_style(tokens: Dictionary) -> StyleBoxFlat:
	var primary: Color = tokens.get("primary", Color("#6A3DFF"))
	var style := StyleBoxFlat.new()
	style.bg_color = _with_alpha(primary, 0.14)
	style.border_color = _with_alpha(primary, 0.55)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style


func _card_style(
	tokens: Dictionary, border_override: Color = Color.TRANSPARENT, elevated: bool = false
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = (
		tokens.get("surface_elevated", Color("#2A2A36"))
		if elevated
		else tokens.get("surface", Color("#1E1E26"))
	)
	style.border_color = (
		border_override if border_override.a > 0.0 else tokens.get("border", Color("#2E2E3A"))
	)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	if elevated:
		style.shadow_color = Color(0, 0, 0, 0.24)
		style.shadow_size = 12
		style.shadow_offset = Vector2(0, 4)
	return style


func _style_progress_bar(bar: ProgressBar, accent: Color) -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var background := StyleBoxFlat.new()
	background.bg_color = tokens.get("background_tertiary", Color("#24242C"))
	background.corner_radius_top_left = 99
	background.corner_radius_top_right = 99
	background.corner_radius_bottom_left = 99
	background.corner_radius_bottom_right = 99
	bar.add_theme_stylebox_override("background", background)
	var fill: StyleBoxFlat = background.duplicate()
	fill.bg_color = accent
	bar.add_theme_stylebox_override("fill", fill)


func _style_primary_button(button: Button, tokens: Dictionary) -> void:
	if ThemeService:
		ThemeService.apply_typography(button, "button")
	var normal := StyleBoxFlat.new()
	normal.bg_color = tokens.get("primary", Color("#6A3DFF"))
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.08)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _accent_for(identity: String) -> Color:
	if SKILL_ACCENTS.is_empty():
		return Color("#8A68FF")
	return SKILL_ACCENTS[absi(identity.hash()) % SKILL_ACCENTS.size()]


func _theme_color(token: String, fallback: Color) -> Color:
	return ThemeService.get_color(token, fallback) if ThemeService else fallback


func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color


func _create_debug_reset_button() -> void:
	var reset_button := Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "RESET PROFILE (DEBUG)"
	reset_button.custom_minimum_size = Vector2(0, 48)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if ThemeService:
		ThemeService.apply_typography(reset_button, "button")
	reset_button.pressed.connect(_on_reset_pressed)
	$Margin/Scroll/VBox.add_child(reset_button)


func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh()


func _on_achievements_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if NavigationService:
		NavigationService.navigate_to("achievements")


func _on_reset_pressed() -> void:
	if not OS.is_debug_build():
		return
	if ProfileService:
		ProfileService.reset_profile()
	if PlayerProgressService:
		PlayerProgressService.initialize()
	_refresh()


func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	if is_visible_in_tree():
		_apply_theme()
		_refresh()
	else:
		_refresh_pending = true


func _on_profile_saved(_profile: Dictionary) -> void:
	_request_refresh()


func _on_achievement_progress_updated(_statuses: Array[Dictionary]) -> void:
	_request_refresh()


func _on_family_changed(_family_id: String) -> void:
	_request_refresh()


func _request_refresh() -> void:
	if is_visible_in_tree():
		call_deferred("_refresh")
	else:
		_refresh_pending = true

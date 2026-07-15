extends Control
## Data-driven achievement collection.

@onready var title_label: Label = $Margin/Scroll/Content/Title
@onready var summary_label: Label = $Margin/Scroll/Content/Summary
@onready var achievement_list: VBoxContainer = $Margin/Scroll/Content/AchievementList

var _refresh_pending: bool = false

func _ready() -> void:
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_refresh()
	if AchievementService and not AchievementService.achievement_progress_updated.is_connected(_on_progress_updated):
		AchievementService.achievement_progress_updated.connect(_on_progress_updated)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_apply_responsive_layout()
	_apply_theme()
	_refresh()

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)

func _apply_theme() -> void:
	var background := get_node_or_null("Background") as ColorRect
	if background:
		background.color = ThemeService.get_color("background", Color("#0F0F12")) if ThemeService else Color("#0F0F12")
	if ThemeService:
		ThemeService.apply_label_style(title_label, "display", "text_primary")
		ThemeService.apply_label_style(summary_label, "body", "text_secondary")

func _refresh() -> void:
	if not achievement_list or not AchievementService:
		return
	for child: Node in achievement_list.get_children():
		child.queue_free()
	var statuses: Array[Dictionary] = AchievementService.get_statuses()
	var unlocked := AchievementService.get_unlocked_count()
	var in_progress := maxi(statuses.size() - unlocked, 0)
	summary_label.text = "%d collected · %d in progress" % [unlocked, in_progress]
	statuses.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_unlocked := bool(a.get("unlocked", false))
		var b_unlocked := bool(b.get("unlocked", false))
		if a_unlocked != b_unlocked:
			return not a_unlocked
		if not is_equal_approx(float(a.get("ratio", 0.0)), float(b.get("ratio", 0.0))):
			return float(a.get("ratio", 0.0)) > float(b.get("ratio", 0.0))
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)
	if statuses.is_empty():
		var empty := Label.new()
		empty.text = "Milestones will appear as the Challenge Library grows."
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_label_style(empty, "body", "text_secondary")
		achievement_list.add_child(empty)
		return
	for status: Dictionary in statuses:
		achievement_list.add_child(_create_card(status))

func _create_card(status: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 96)
	var style := StyleBoxFlat.new()
	style.bg_color = ThemeService.get_color("surface", Color("#1E1E26")) if ThemeService else Color("#1E1E26")
	style.border_color = ThemeService.get_color("primary", Color("#6A3DFF")) if bool(status.get("unlocked", false)) and ThemeService else Color("#2E2E3A")
	style.border_width_left = 2 if bool(status.get("unlocked", false)) else 1
	style.border_width_right = style.border_width_left
	style.border_width_top = style.border_width_left
	style.border_width_bottom = style.border_width_left
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	card.add_theme_stylebox_override("panel", style)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)
	var badge_panel := PanelContainer.new()
	badge_panel.custom_minimum_size = Vector2(68, 34)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = (
		Color(ThemeService.get_color("success", Color("#2EE6A6")), 0.28)
		if bool(status.get("unlocked", false)) and ThemeService
		else Color(ThemeService.get_color("primary", Color("#6A3DFF")), 0.18) if ThemeService else Color("#2A2A36")
	)
	badge_style.border_color = ThemeService.get_color("success", Color("#2EE6A6")) if bool(status.get("unlocked", false)) and ThemeService else ThemeService.get_color("border_strong", Color("#3D3D4D")) if ThemeService else Color("#3D3D4D")
	badge_style.border_width_left = 1
	badge_style.border_width_right = 1
	badge_style.border_width_top = 1
	badge_style.border_width_bottom = 1
	badge_style.corner_radius_top_left = 14
	badge_style.corner_radius_top_right = 14
	badge_style.corner_radius_bottom_left = 14
	badge_style.corner_radius_bottom_right = 14
	badge_style.content_margin_left = 8
	badge_style.content_margin_right = 8
	badge_style.content_margin_top = 6
	badge_style.content_margin_bottom = 6
	badge_panel.add_theme_stylebox_override("panel", badge_style)
	var badge := Label.new()
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.text = "DONE" if bool(status.get("unlocked", false)) else "NEXT"
	badge.add_theme_font_size_override(
		"font_size",
		ThemeService.get_font_size("label_small") if ThemeService else 14
	)
	badge.add_theme_color_override("font_color", ThemeService.get_color("text_primary", Color.WHITE) if ThemeService else Color.WHITE)
	badge_panel.add_child(badge)
	row.add_child(badge_panel)
	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_stack)
	var title := Label.new()
	title.text = str(status.get("title", "Milestone"))
	if ThemeService:
		ThemeService.apply_label_style(title, "title", "text_primary")
	text_stack.add_child(title)
	var description := Label.new()
	description.text = (
		"%s\nCOLLECTED" % str(status.get("description", ""))
		if bool(status.get("unlocked", false))
		else "%s\nProgress: %d / %d" % [
			str(status.get("description", "")),
			int(status.get("current", 0)),
			int(status.get("target", 1))
		]
	)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(description, "body_small", "text_secondary")
	text_stack.add_child(description)
	var progress := ProgressBar.new()
	progress.max_value = float(status.get("target", 1.0))
	progress.value = float(status.get("current", 0.0))
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 7)
	text_stack.add_child(progress)
	return card

func _on_progress_updated(_statuses: Array[Dictionary]) -> void:
	_request_refresh()

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()
	_request_refresh()

func _request_refresh() -> void:
	if is_visible_in_tree():
		_refresh()
	else:
		_refresh_pending = true

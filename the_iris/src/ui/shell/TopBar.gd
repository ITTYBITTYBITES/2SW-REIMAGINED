extends Control
## TopBar - App header with title, actions, brand

@export var title_text: String = "Two Second Witness" : set = set_title
@export var show_back: bool = false
@export var show_profile: bool = true

signal back_pressed()
signal profile_pressed()
signal settings_pressed()

@onready var title_label: Label = $Margin/HBox/Title
@onready var back_button: Button = $Margin/HBox/BackButton
@onready var profile_button: Button = $Margin/HBox/Actions/ProfileButton
@onready var settings_button: Button = $Margin/HBox/Actions/SettingsButton

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh()
	if ThemeService:
		if not ThemeService.theme_changed.is_connected(_on_theme_changed):
			ThemeService.theme_changed.connect(_on_theme_changed)

func _ensure_ui() -> void:
	var touch_min := 48
	if ThemeService:
		touch_min = ThemeService.tokens.get("touch_target_min", 48)
	if has_node("Margin/HBox/Title"):
		# Wire existing and fix touch targets
		if back_button:
			back_button.custom_minimum_size = Vector2(touch_min, touch_min)
			back_button.text = "Back"
			back_button.tooltip_text = "Back"
			if not back_button.pressed.is_connected(_on_back):
				back_button.pressed.connect(_on_back)
		if profile_button:
			profile_button.custom_minimum_size = Vector2(touch_min, touch_min)
			profile_button.text = "Record"
			profile_button.tooltip_text = "Witness Record"
			if not profile_button.pressed.is_connected(_on_profile):
				profile_button.pressed.connect(_on_profile)
		if settings_button:
			settings_button.custom_minimum_size = Vector2(touch_min, touch_min)
			settings_button.text = "Set"
			settings_button.tooltip_text = "Settings"
			if not settings_button.pressed.is_connected(_on_settings):
				settings_button.pressed.connect(_on_settings)
		return

	# Build programmatically
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.name = "HBox"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(hbox)

	var back := Button.new()
	back.name = "BackButton"
	back.text = "Back"
	back.visible = show_back
	back.custom_minimum_size = Vector2(touch_min, touch_min)
	hbox.add_child(back)

	var title := Label.new()
	title.name = "Title"
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(title)

	var actions := HBoxContainer.new()
	actions.name = "Actions"
	hbox.add_child(actions)

	var set_btn := Button.new()
	set_btn.name = "SettingsButton"
	set_btn.text = "Set"
	set_btn.custom_minimum_size = Vector2(touch_min, touch_min)
	actions.add_child(set_btn)

	var prof := Button.new()
	prof.name = "ProfileButton"
	prof.text = "Record"
	prof.custom_minimum_size = Vector2(touch_min, touch_min)
	prof.visible = show_profile
	actions.add_child(prof)

	back_button = back
	title_label = title
	settings_button = set_btn
	profile_button = prof

	back_button.pressed.connect(_on_back)
	profile_button.pressed.connect(_on_profile)
	settings_button.pressed.connect(_on_settings)

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var bg = tokens.get("background", Color("#0F0F12"))

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	# No rounding for top bar, just bottom border
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_bottom = 1
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 3)
	add_theme_stylebox_override("panel", style)

	var touch_min: int = tokens.get("touch_target_min", 48) as int
	_style_bar_button(back_button, touch_min)
	_style_bar_button(settings_button, touch_min)
	_style_bar_button(profile_button, touch_min)

	if title_label:
		ThemeService.apply_label_style(title_label, "title", "text_primary")
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _style_bar_button(btn: Button, min_size: int) -> void:
	if not btn or not ThemeService:
		return
	btn.custom_minimum_size = Vector2(min_size, min_size)
	ThemeService.apply_typography(btn, "title")
	btn.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))
	btn.flat = true
	btn.focus_mode = Control.FOCUS_ALL
	btn.autowrap_mode = TextServer.AUTOWRAP_OFF
	btn.clip_text = true

func _refresh() -> void:
	if has_node("Margin/HBox/BackButton"):
		$Margin/HBox/BackButton.visible = show_back
	if has_node("Margin/HBox/Actions/ProfileButton"):
		$Margin/HBox/Actions/ProfileButton.visible = show_profile
	if has_node("Margin/HBox/Title"):
		$Margin/HBox/Title.text = title_text

func set_title(t: String) -> void:
	title_text = t
	if has_node("Margin/HBox/Title"):
		$Margin/HBox/Title.text = t

func set_show_back(v: bool) -> void:
	show_back = v
	_refresh()

func set_show_actions(visible_actions: bool) -> void:
	var actions := get_node_or_null("Margin/HBox/Actions") as Control
	if actions:
		actions.visible = visible_actions

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func _on_back() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	back_pressed.emit()

func _on_profile() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	profile_pressed.emit()

func _on_settings() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	settings_pressed.emit()

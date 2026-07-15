extends Control
## Player-facing settings organized around comfort, sound, and accessibility.

const SETTING_HELP := {
	"reduced_motion": "Removes decorative movement and shortens transitions.",
	"font_scale": "Adjusts interface text from 0.8× to 1.4×.",
	"volume_ui": "Controls taps and navigation feedback.",
	"haptics_enabled": "Uses short touch feedback on supported devices.",
	"reading_comfort_mode": "Uses larger word presentation and steadier timing.",
	"high_contrast": "Strengthens text, borders, and gameplay evidence.",
	"color_assist_mode": "Reinforces visual cues so color is never the only signal.",
	"accessibility_screen_reader_hints":
	"Uses an alternate answer layout designed for assistive navigation when available.",
	"show_tutorials": "Shows a short introduction before the first round of each Challenge Type.",
	"comfortable_timing": "Adds time to observation moments without reducing progress.",
	"analytics_enabled": (
		"Keeps a private activity log on this device. Nothing is uploaded; "
		+ "turning this off clears the log."
	)
}

var _refresh_pending: bool = false
var _refresh_timer: Timer = null
var _reset_dialog: ConfirmationDialog = null

@onready var scroll: ScrollContainer = $Margin/Scroll
@onready var vbox: VBoxContainer = $Margin/Scroll/VBox


func _ready() -> void:
	_refresh_timer = Timer.new()
	_refresh_timer.one_shot = true
	_refresh_timer.wait_time = 0.2
	_refresh_timer.timeout.connect(_refresh)
	add_child(_refresh_timer)
	_ensure_reset_dialog()
	_ensure_ui()
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_refresh()

	if SettingsService and not SettingsService.setting_changed.is_connected(_on_setting_changed):
		SettingsService.setting_changed.connect(_on_setting_changed)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)


func _ensure_ui() -> void:
	if has_node("Margin/Scroll/VBox"):
		return

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var scroll_container := ScrollContainer.new()
	scroll_container.name = "Scroll"
	margin.add_child(scroll_container)

	var content := VBoxContainer.new()
	content.name = "VBox"
	content.add_theme_constant_override("separation", 28)
	scroll_container.add_child(content)

	scroll = scroll_container
	vbox = content


func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($Margin)
	var bottom_spacer: Control = null
	if vbox:
		bottom_spacer = vbox.get_node_or_null("BottomSpacer") as Control
	ResponsiveLayout.prepare_mobile_scroll(scroll, vbox, bottom_spacer)


func _apply_theme() -> void:
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background and ThemeService:
		background.color = ThemeService.get_color("background", Color("#0F0F12"))
	if is_node_ready() and is_visible_in_tree():
		_schedule_refresh()


func _refresh() -> void:
	if not has_node("Margin/Scroll/VBox") or not SettingsService:
		return
	var previous_scroll_position: int = scroll.scroll_vertical if scroll else 0
	var content: VBoxContainer = $Margin/Scroll/VBox
	for child: Node in content.get_children():
		child.queue_free()

	var intro := VBoxContainer.new()
	intro.add_theme_constant_override("separation", 6)
	var title := Label.new()
	title.text = "Make it yours"
	if ThemeService:
		ThemeService.apply_label_style(title, "headline", "text_primary")
	else:
		title.add_theme_font_size_override("font_size", 28)
	intro.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Choose the presentation, pace, and feedback that feel right for you."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(subtitle, "body_small", "text_secondary")
	intro.add_child(subtitle)
	content.add_child(intro)

	var appearance_rows: Array[Control] = []
	appearance_rows.append(
		_create_setting_row_toggle(
			"Dark Mode",
			"theme_mode",
			SettingsService.get_value("theme_mode", "dark") == "dark",
			_on_theme_toggle
		)
	)
	appearance_rows.append(
		_create_setting_row_slider(
			"Text Size", "font_scale", SettingsService.get_value("font_scale", 1.0), 0.8, 1.4, 0.1
		)
	)
	appearance_rows.append(
		_create_setting_row_toggle(
			"Reduced Motion",
			"reduced_motion",
			SettingsService.get_value("reduced_motion", false),
			_on_generic_toggle
		)
	)
	content.add_child(
		_create_settings_section(
			"Appearance", "A clear, comfortable view on every screen.", appearance_rows
		)
	)

	var sound_rows: Array[Control] = []
	sound_rows.append(
		_create_setting_row_slider(
			"Audio Level",
			"volume_master",
			SettingsService.get_value("volume_master", 0.95),
			0.0,
			1.0,
			0.1
		)
	)
	sound_rows.append(
		_create_setting_row_slider(
			"Music", "volume_bgm", SettingsService.get_value("volume_bgm", 0.62), 0.0, 1.0, 0.1
		)
	)
	sound_rows.append(
		_create_setting_row_slider(
			"Sound Effects",
			"volume_sfx",
			SettingsService.get_value("volume_sfx", 0.78),
			0.0,
			1.0,
			0.1
		)
	)
	sound_rows.append(
		_create_setting_row_slider(
			"Interface Sounds",
			"volume_ui",
			SettingsService.get_value("volume_ui", 0.58),
			0.0,
			1.0,
			0.1
		)
	)
	sound_rows.append(
		_create_setting_row_toggle(
			"Mute All Audio",
			"mute_master",
			SettingsService.get_value("mute_master", false),
			_on_generic_toggle
		)
	)
	sound_rows.append(
		_create_setting_row_toggle(
			"Haptics",
			"haptics_enabled",
			SettingsService.get_value("haptics_enabled", true),
			_on_generic_toggle
		)
	)
	content.add_child(
		_create_settings_section(
			"Sound & Feedback", "Balance focus cues, music, and touch feedback.", sound_rows
		)
	)

	var comfort_rows: Array[Control] = []
	comfort_rows.append(
		_create_setting_row_toggle(
			"Reading Comfort Mode",
			"reading_comfort_mode",
			SettingsService.get_value("reading_comfort_mode", false),
			_on_generic_toggle
		)
	)
	comfort_rows.append(
		_create_setting_row_toggle(
			"More Observation Time",
			"comfortable_timing",
			SettingsService.get_value("comfortable_timing", false),
			_on_generic_toggle
		)
	)
	comfort_rows.append(
		_create_setting_row_toggle(
			"Show Tutorials",
			"show_tutorials",
			SettingsService.get_value("show_tutorials", true),
			_on_generic_toggle
		)
	)
	content.add_child(
		_create_settings_section(
			"Play Comfort",
			"Adjust pacing and guidance without changing your progress.",
			comfort_rows
		)
	)

	var accessibility_rows: Array[Control] = []
	accessibility_rows.append(
		_create_setting_row_toggle(
			"High Contrast",
			"high_contrast",
			SettingsService.get_value("high_contrast", false),
			_on_generic_toggle
		)
	)
	accessibility_rows.append(
		_create_setting_row_toggle(
			"Color Assistance",
			"color_assist_mode",
			SettingsService.get_value("color_assist_mode", false),
			_on_generic_toggle
		)
	)
	accessibility_rows.append(
		_create_setting_row_toggle(
			"Assistive Controls",
			"accessibility_screen_reader_hints",
			SettingsService.get_value("accessibility_screen_reader_hints", false),
			_on_generic_toggle
		)
	)
	content.add_child(
		_create_settings_section(
			"Accessibility",
			"Keep evidence and interactions easy to distinguish.",
			accessibility_rows
		)
	)

	var privacy_rows: Array[Control] = []
	privacy_rows.append(
		_create_setting_row_toggle(
			"On-device Activity",
			"analytics_enabled",
			SettingsService.get_value("analytics_enabled", true),
			_on_generic_toggle
		)
	)
	content.add_child(
		_create_settings_section("Privacy", "Activity stays private to this device.", privacy_rows)
	)

	# Offline Play is product behavior, not a configurable setting. Keep it as
	# concise reassurance beside the single About destination.
	content.add_child(_create_about_card())

	var reset_btn := Button.new()
	reset_btn.text = "Restore Default Settings"
	reset_btn.custom_minimum_size = Vector2(0, 52)
	reset_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_btn.tooltip_text = "Restore every setting to its original value"
	_style_action_button(reset_btn, false)
	content.add_child(reset_btn)
	reset_btn.pressed.connect(_on_reset_settings)

	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size.y = 20
	content.add_child(bottom_spacer)
	call_deferred("_restore_scroll_position", previous_scroll_position)


func _restore_scroll_position(position: int) -> void:
	if scroll:
		scroll.scroll_vertical = position


func _create_settings_section(
	title_text: String, description: String, rows: Array[Control]
) -> Control:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 10)

	var heading_stack := VBoxContainer.new()
	heading_stack.add_theme_constant_override("separation", 3)
	section.add_child(heading_stack)
	var heading := Label.new()
	heading.text = title_text.to_upper()
	if ThemeService:
		ThemeService.apply_label_style(heading, "label_small", "primary_variant")
	else:
		heading.add_theme_font_size_override("font_size", 16)
	heading_stack.add_child(heading)
	var copy := Label.new()
	copy.text = description
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(copy, "caption", "text_tertiary")
	heading_stack.add_child(copy)

	for row: Control in rows:
		section.add_child(row)
	return section


func _create_setting_row_toggle(
	label_text: String, key: String, value: bool, callback: Callable
) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 58)
	hbox.add_theme_constant_override("separation", 12)

	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.add_theme_constant_override("separation", 3)
	hbox.add_child(text_stack)

	var label := Label.new()
	label.text = label_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "body_small", "text_primary")
	text_stack.add_child(label)
	_add_help_text(text_stack, key)

	var toggle := CheckButton.new()
	toggle.button_pressed = value
	toggle.set_meta("key", key)
	toggle.tooltip_text = str(SETTING_HELP.get(key, label_text))
	toggle.focus_mode = Control.FOCUS_ALL
	toggle.custom_minimum_size = Vector2(56, 48)
	toggle.toggled.connect(func(enabled: bool) -> void: callback.call(key, enabled))
	hbox.add_child(toggle)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _setting_card_style())
	card.add_child(hbox)
	return card


func _create_setting_row_slider(
	label_text: String, key: String, value: float, min_value: float, max_value: float, step: float
) -> Control:
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	stack.add_child(header)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "body_small", "text_primary")
	header.add_child(label)

	var value_label := Label.new()
	value_label.name = "ValueLabel"
	value_label.custom_minimum_size.x = 64.0
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.text = _format_slider_value(key, value)
	if ThemeService:
		ThemeService.apply_label_style(value_label, "label_small", "primary_variant")
		value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	header.add_child(value_label)
	_add_help_text(stack, key)

	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.custom_minimum_size.y = 48
	slider.set_meta("key", key)
	slider.set_meta("value_label", value_label)
	slider.tooltip_text = str(SETTING_HELP.get(key, label_text))
	slider.focus_mode = Control.FOCUS_ALL
	slider.value_changed.connect(
		func(new_value: float) -> void:
			var current_label: Label = slider.get_meta("value_label") as Label
			if current_label:
				current_label.text = _format_slider_value(key, new_value)
			_on_slider_changed(key, new_value)
	)
	stack.add_child(slider)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _setting_card_style())
	card.add_child(stack)
	return card


func _add_help_text(parent: VBoxContainer, key: String) -> void:
	var help_text := str(SETTING_HELP.get(key, ""))
	if help_text.is_empty():
		return
	var help := Label.new()
	help.text = help_text
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(help, "caption", "text_secondary")
	parent.add_child(help)


func _format_slider_value(key: String, value: float) -> String:
	if key.begins_with("volume"):
		return "%d%%" % int(round(value * 100.0))
	if key == "font_scale":
		return "%.1f×" % value
	return "%.1f" % value


func _setting_card_style() -> StyleBoxFlat:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("border", Color("#2E2E3A"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	var radius: int = int(tokens.get("radius_md", 12))
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	return style


func _create_about_card() -> Control:
	var card := PanelContainer.new()
	var style := _setting_card_style()
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
	style.border_color = _with_alpha(tokens.get("primary", Color("#6A3DFF")), 0.45)
	card.add_theme_stylebox_override("panel", style)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	card.add_child(stack)
	var title := Label.new()
	title.text = "ABOUT & PRIVACY"
	if ThemeService:
		ThemeService.apply_label_style(title, "label_small", "primary_variant")
	stack.add_child(title)
	var copy := Label.new()
	copy.text = "Play offline at any time. Progress stays on this device."
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(copy, "body_small", "text_secondary")
	stack.add_child(copy)
	var button := Button.new()
	button.text = "About, Privacy & Credits  →"
	button.custom_minimum_size = Vector2(0, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_action_button(button, true)
	button.pressed.connect(_on_about_pressed)
	stack.add_child(button)
	return card


func _style_action_button(button: Button, primary: bool) -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	if ThemeService:
		ThemeService.apply_typography(button, "button")
	var normal := StyleBoxFlat.new()
	normal.bg_color = (
		tokens.get("primary", Color("#6A3DFF"))
		if primary
		else tokens.get("background_tertiary", Color("#24242C"))
	)
	normal.border_color = tokens.get("border", Color("#2E2E3A"))
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
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


func _ensure_reset_dialog() -> void:
	if _reset_dialog != null:
		return
	_reset_dialog = ConfirmationDialog.new()
	_reset_dialog.name = "ConfirmationDialog"
	_reset_dialog.title = "Restore default settings?"
	_reset_dialog.dialog_text = (
		"This restores appearance, sound, play comfort, privacy, and accessibility "
		+ "settings. Your Witness Progress stays intact."
	)
	_reset_dialog.ok_button_text = "RESTORE DEFAULTS"
	_reset_dialog.cancel_button_text = "KEEP MY SETTINGS"
	_reset_dialog.confirmed.connect(_perform_reset_settings)
	add_child(_reset_dialog)


func on_navigated_to(_params: Dictionary) -> void:
	_refresh_pending = false
	_apply_responsive_layout()
	_refresh()


func _with_alpha(value: Variant, alpha: float) -> Color:
	var color: Color = value if value is Color else Color.WHITE
	color.a = alpha
	return color


func _on_generic_toggle(key: String, value: bool) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")


func _on_theme_toggle(_key: String, is_dark: bool) -> void:
	var mode: String = "dark" if is_dark else "light"
	if SettingsService:
		SettingsService.set_value("theme_mode", mode)
	if ThemeService:
		ThemeService.set_theme_mode(
			ThemeService.ThemeMode.DARK if is_dark else ThemeService.ThemeMode.LIGHT
		)
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	if AudioService:
		AudioService.play_ui("ui_click")


func _on_slider_changed(key: String, value: float) -> void:
	if SettingsService:
		SettingsService.set_value(key, value)


func _on_about_pressed() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	if NavigationService:
		NavigationService.navigate_to("about", {"section": "about"})


func _on_reset_settings() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	_ensure_reset_dialog()
	_reset_dialog.popup_centered(Vector2i(520, 260))


func _perform_reset_settings() -> void:
	if SettingsService:
		SettingsService.reset_to_defaults()
	_refresh()
	if AccessibilityService:
		AccessibilityService.vibrate(35)


func _on_setting_changed(key: String, _value: Variant) -> void:
	if key in ["theme_mode", "high_contrast", "font_scale"]:
		_schedule_refresh()


func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	var background: ColorRect = get_node_or_null("Background") as ColorRect
	if background and ThemeService:
		background.color = ThemeService.get_color("background", Color("#0F0F12"))
	_schedule_refresh()


func _schedule_refresh() -> void:
	if not is_visible_in_tree():
		_refresh_pending = true
		return
	if _refresh_timer:
		_refresh_timer.start()

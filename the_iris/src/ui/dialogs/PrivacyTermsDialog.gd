extends Control
## PrivacyTermsDialog - Centered modal presented over the loading screen on first launch
## Lightweight, editorial style. Blocks interaction with content beneath until accepted.

signal accepted()
signal view_policy()
signal view_terms()

@onready var scrim: ColorRect = $Scrim
@onready var panel: PanelContainer = $Margin/CenterVBox/DialogPanel
@onready var title_label: Label = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Title
@onready var welcome_label: Label = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Body/Welcome
@onready var bullets_label: Label = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Body/Bullets
@onready var footer_label: Label = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Body/Footer
@onready var policy_btn: Button = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Actions/PolicyButton
@onready var terms_btn: Button = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Actions/TermsButton
@onready var accept_btn: Button = $Margin/CenterVBox/DialogPanel/InnerMargin/Scroll/VBox/Actions/AcceptButton

func _ready() -> void:
	_enforce_layout()
	_apply_theme()
	_connect()
	accept_btn.grab_focus()
	_animate_in()

func _enforce_layout() -> void:
	# Force the modal to fill the viewport, sit on top, and stop input so the
	# dialog is clearly visible and content beneath cannot be tapped through.
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_right = 0
	offset_top = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	if scrim:
		scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
		scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_responsive_size()

func _apply_responsive_size() -> void:
	# Keep the panel within a comfortable reading width on phones and tablets.
	var viewport_width := get_viewport().get_visible_rect().size.x
	var target_width := clampf(viewport_width - 56.0, 260.0, 520.0)
	if panel:
		panel.custom_minimum_size = Vector2(target_width, 0)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _connect() -> void:
	if accept_btn and not accept_btn.pressed.is_connected(_on_accept):
		accept_btn.pressed.connect(_on_accept)
	if policy_btn and not policy_btn.pressed.is_connected(_on_policy):
		policy_btn.pressed.connect(_on_policy)
	if terms_btn and not terms_btn.pressed.is_connected(_on_terms):
		terms_btn.pressed.connect(_on_terms)

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	if scrim:
		scrim.color = Color(0,0,0,0.55)
	# Panel
	if panel:
		var style := StyleBoxFlat.new()
		style.bg_color = tokens.get("surface_elevated", Color("#2A2A36"))
		style.border_color = tokens.get("border_strong", Color("#3D3D4D"))
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.corner_radius_top_left = tokens.get("radius_lg", 20)
		style.corner_radius_top_right = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_left = tokens.get("radius_lg", 20)
		style.corner_radius_bottom_right = tokens.get("radius_lg", 20)
		# Padding handled by the InnerMargin MarginContainer in the scene.
		panel.add_theme_stylebox_override("panel", style)

	if title_label:
		title_label.text = "Terms & Privacy"
		if ThemeService:
			ThemeService.apply_label_style(title_label, "title", "text_primary")
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if welcome_label:
		welcome_label.text = "Welcome to Two Second Witness."
		if ThemeService:
			ThemeService.apply_label_style(welcome_label, "body", "text_primary")
		welcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		welcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if bullets_label:
		bullets_label.text = "\n".join([
			"• Progress is stored locally on your device.",
			"• No account is required.",
			"• No personal information is collected.",
			"• No advertising is currently included."
		])
		if ThemeService:
			ThemeService.apply_label_style(bullets_label, "body_small", "text_secondary")
		bullets_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if footer_label:
		footer_label.text = "By continuing, you accept the Terms of Service and Privacy Policy."
		if ThemeService:
			ThemeService.apply_label_style(footer_label, "caption", "text_tertiary")
		footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Buttons
	if accept_btn:
		accept_btn.text = "ACCEPT & CONTINUE"
		_apply_button_style(accept_btn,
			tokens.get("primary", Color("#6A3DFF")),
			tokens.get("primary_variant", Color("#8A68FF")),
			tokens.get("text_on_primary", Color.WHITE),
			tokens.get("radius_md", 12))
	if policy_btn:
		policy_btn.text = "VIEW PRIVACY POLICY"
		_apply_button_style(policy_btn,
			Color.TRANSPARENT,
			Color(tokens.get("surface_elevated", Color("#2A2A36"))),
			tokens.get("text_secondary", Color.GRAY),
			tokens.get("radius_md", 12),
			true)
	if terms_btn:
		terms_btn.text = "VIEW TERMS OF SERVICE"
		_apply_button_style(terms_btn,
			Color.TRANSPARENT,
			Color(tokens.get("surface_elevated", Color("#2A2A36"))),
			tokens.get("text_secondary", Color.GRAY),
			tokens.get("radius_md", 12),
			true)

func _apply_button_style(
	btn: Button,
	bg: Color,
	bg_hover: Color,
	fg: Color,
	radius: int,
	ghost: bool = false
) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 14
	normal.content_margin_bottom = 14
	if ghost:
		normal.bg_color = Color.TRANSPARENT

	var hover := normal.duplicate()
	hover.bg_color = bg_hover if not ghost else Color(bg_hover).lerp(Color.WHITE, -0.4)
	var pressed := normal.duplicate()
	pressed.bg_color = bg.darkened(0.1)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_color_override("font_color", fg)
	if ThemeService:
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("button"))
	else:
		btn.add_theme_font_size_override("font_size", 18)
	btn.custom_minimum_size.y = 48
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _animate_in() -> void:
	modulate.a = 0.0
	if panel:
		panel.scale = Vector2(0.95, 0.95)
		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		if AccessibilityService and AccessibilityService.is_reduced_motion_enabled():
			modulate.a = 1.0
			panel.scale = Vector2.ONE
			return
		tween.tween_property(self, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT)
		var panel_tween := tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.3)
		panel_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_accept() -> void:
	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	accepted.emit()

func _on_policy() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	view_policy.emit()

func _on_terms() -> void:
	if AudioService:
		AudioService.play_ui("ui_click")
	view_terms.emit()

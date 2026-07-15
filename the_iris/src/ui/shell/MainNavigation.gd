extends Control
## MainNavigation - Bottom tab navigation, polished mobile-first

signal tab_selected(route: String)

const TABS := [
	{"route": "home", "label": "Witness", "eyebrow": "Begin"},
	{"route": "profile", "label": "Record", "eyebrow": "Yours"},
	{"route": "settings", "label": "Settings", "eyebrow": "Tune"},
]

var current_route: String = "home"
var _buttons: Dictionary = {} # route -> Button

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	_refresh_selection()
	if NavigationService and not NavigationService.route_changed.is_connected(_on_route_changed):
		NavigationService.route_changed.connect(_on_route_changed)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _ensure_ui() -> void:
	if has_node("Margin/HBox"):
		# Wire existing if built from scene
		_wire_existing_buttons()
		return

	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.name = "HBox"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 4)
	margin.add_child(hbox)

	for tab in TABS:
		var btn_container := VBoxContainer.new()
		btn_container.name = "%s_Container" % tab["route"]
		btn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_child(btn_container)

		var btn := Button.new()
		btn.name = "%s_Button" % tab["route"]
		# Eyebrow + label avoids generic symbol icons and stays legible on mobile.
		btn.text = "%s\n%s" % [tab.get("eyebrow", ""), tab.get("label", "")]
		btn.custom_minimum_size = Vector2(0, 64)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Store route meta
		btn.set_meta("route", tab["route"])
		btn.pressed.connect(_on_tab_pressed.bind(tab["route"]))
		btn_container.add_child(btn)
		_buttons[tab["route"]] = btn

func _wire_existing_buttons() -> void:
	var active_routes: Array[String] = []
	for tab in TABS:
		active_routes.append(str(tab["route"]))
	for child: Node in get_node("Margin/HBox").get_children():
		var child_name := str(child.name)
		if child_name.ends_with("_Container"):
			var route_name := child_name.trim_suffix("_Container")
			var child_control := child as Control
			if child_control:
				child_control.visible = active_routes.has(route_name)
	for tab in TABS:
		var route: String = tab["route"]
		var path := "Margin/HBox/%s_Container/%s_Button" % [route, route]
		if has_node(path):
			var btn: Button = get_node(path)
			_buttons[route] = btn
			if not btn.pressed.is_connected(_on_tab_pressed):
				btn.pressed.connect(_on_tab_pressed.bind(route))

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = tokens.get("background_secondary", Color("#1A1A1F"))
	bg_style.border_color = tokens.get("border", Color("#2E2E3A"))
	bg_style.border_width_top = 1
	bg_style.corner_radius_top_left = tokens.get("radius_lg", 20)
	bg_style.corner_radius_top_right = tokens.get("radius_lg", 20)
	bg_style.shadow_color = Color(0, 0, 0, 0.35)
	bg_style.shadow_size = 18
	bg_style.shadow_offset = Vector2(0, -4)
	add_theme_stylebox_override("panel", bg_style)

	# AppShell positions the entire navigation layer above the safe area. Keep
	# inner padding stable so the bar height does not double-count gesture insets.
	var margin_node := get_node_or_null("Margin")
	if margin_node is MarginContainer:
		var m: MarginContainer = margin_node
		m.add_theme_constant_override("margin_bottom", 10)
		m.add_theme_constant_override("margin_top", 10)
		m.add_theme_constant_override("margin_left", 8)
		m.add_theme_constant_override("margin_right", 8)

	# Helper to get tab info
	var tab_map := {}
	for t in TABS:
		tab_map[t["route"]] = t

	for route in _buttons.keys():
		var btn: Button = _buttons[route]
		var is_selected: bool = (route == current_route)
		var tab_info: Dictionary = tab_map.get(route, {})
		var eyebrow := str(tab_info.get("eyebrow", ""))
		var label := str(tab_info.get("label", route.capitalize()))
		btn.text = "%s\n%s" % [eyebrow, label]
		btn.tooltip_text = label
		btn.focus_mode = Control.FOCUS_ALL
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

		btn.custom_minimum_size.y = max(64, tokens.get("touch_target_min", 48))

		var normal := StyleBoxFlat.new()
		normal.corner_radius_top_left = tokens.get("radius_md", 12)
		normal.corner_radius_top_right = tokens.get("radius_md", 12)
		normal.corner_radius_bottom_left = tokens.get("radius_md", 12)
		normal.corner_radius_bottom_right = tokens.get("radius_md", 12)
		normal.content_margin_left = 8
		normal.content_margin_right = 8
		normal.content_margin_top = 10
		normal.content_margin_bottom = 10

		if is_selected:
			# Premium selected state – match Home mockup
			normal.bg_color = Color(tokens.get("primary", Color("#6A3DFF")), 0.22)
			btn.add_theme_color_override("font_color", tokens.get("primary_variant", Color("#8A68FF")))
			# subtle top accent
			normal.border_width_top = 2
			normal.border_color = tokens.get("primary", Color("#6A3DFF"))
		else:
			normal.bg_color = Color.TRANSPARENT
			btn.add_theme_color_override("font_color", tokens.get("text_tertiary", Color.GRAY))

		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", normal)
		btn.add_theme_stylebox_override("pressed", normal)
		btn.add_theme_stylebox_override("focus", normal)
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small"))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _refresh_selection() -> void:
	_apply_theme()

func _on_tab_pressed(route: String) -> void:
	if route == current_route:
		# Haptic feedback but no navigation
		if AccessibilityService:
			AccessibilityService.vibrate(20)
		return

	current_route = route
	_refresh_selection()

	if AccessibilityService:
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")

	tab_selected.emit(route)

	if AnalyticsService:
		AnalyticsService.log_event("tab_selected", {"route": route})

func _on_route_changed(route: String, _params: Dictionary) -> void:
	# Only care about tab routes
	var is_tab := false
	for t in TABS:
		if t["route"] == route:
			is_tab = true
			break
	if is_tab:
		current_route = route
		_refresh_selection()

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

func set_current_route(route: String) -> void:
	current_route = route
	_refresh_selection()

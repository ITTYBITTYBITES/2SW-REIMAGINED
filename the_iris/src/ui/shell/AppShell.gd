extends Control
## AppShell - Root application container
## Manages layers, first-run flow, splash system, main navigation
## Premium ITTYBITTYBITES + Two Second Witness identity

@onready var content_container: Control = $ContentLayer/ContentContainer
@onready var nav_bar: Control = $NavigationLayer/MainNavigation
@onready var top_bar: Control = $TopBarLayer/TopBar
@onready var overlay_layer: Control = $OverlayLayer
@onready var loading_overlay: Control = $OverlayLayer/LoadingOverlay
@onready var error_banner: Control = $OverlayLayer/ErrorBanner
@onready var background_layer: Control = $BackgroundLayer

var modal_layer: Control = null

var _current_screen: Control = null
var _screen_cache: Dictionary = {}
var _boot_flow: Node
var _screen_transition: Tween = null
var _loading_pulse: Tween = null
var _current_route: String = ""

const CACHEABLE_ROUTES: Array[String] = [
	"home", "experiences", "profile", "settings", "about", "achievements", "programs"
]

const SCREEN_SCENES := {
	"publisher_splash": "res://src/ui/screens/PublisherSplashScreen.tscn",
	"title_splash":    "res://src/ui/screens/TitleSplashScreen.tscn",
	"splash":          "res://src/ui/screens/TitleSplashScreen.tscn",
	"tutorial":        "res://src/ui/screens/TutorialScreen.tscn",
	"observation":     "res://src/ui/screens/ObservationChallengeScreen.tscn",
	"memory_question": "res://src/ui/screens/MemoryQuestionScreen.tscn",
	"result":          "res://src/ui/screens/ResultScreen.tscn",
	"about":           "res://src/ui/screens/AboutScreen.tscn",
	"achievements":    "res://src/ui/screens/AchievementsScreen.tscn",
	"programs":        "res://src/ui/screens/ProgramsScreen.tscn",
	"home":            "res://src/ui/screens/HomeV2Screen.tscn",
	"experiences":     "res://src/ui/screens/ExperiencesScreen.tscn",
	"profile":         "res://src/ui/screens/ProfileScreen.tscn",
	"settings":        "res://src/ui/screens/SettingsScreen.tscn"
}

func _ready() -> void:
	_ensure_boot_flow()

	if AppState:
		if not AppState.phase_changed.is_connected(_on_phase_changed):
			AppState.phase_changed.connect(_on_phase_changed)
		if not AppState.loading_changed.is_connected(_on_loading_changed):
			AppState.loading_changed.connect(_on_loading_changed)
	if NavigationService:
		if not NavigationService.route_changed.is_connected(_on_route_changed):
			NavigationService.route_changed.connect(_on_route_changed)
	if ErrorHandler:
		if not ErrorHandler.user_message_requested.is_connected(_on_user_message):
			ErrorHandler.user_message_requested.connect(_on_user_message)
	if ChallengeSessionService and not ChallengeSessionService.session_failed.is_connected(_on_session_failed):
		ChallengeSessionService.session_failed.connect(_on_session_failed)
	if ThemeService:
		if not ThemeService.theme_changed.is_connected(_on_theme_changed):
			ThemeService.theme_changed.connect(_on_theme_changed)

	_apply_safe_area()
	_apply_theme()
	_setup_loading_overlay()
	_setup_error_banner()
	_ensure_modal_layer()

	if top_bar:
		if top_bar.has_signal("back_pressed") and not top_bar.back_pressed.is_connected(_on_topbar_back):
			top_bar.back_pressed.connect(_on_topbar_back)
		var has_profile_signal := top_bar.has_signal("profile_pressed")
		if has_profile_signal and not top_bar.profile_pressed.is_connected(_on_topbar_profile):
			top_bar.profile_pressed.connect(_on_topbar_profile)
		var has_settings_signal := top_bar.has_signal("settings_pressed")
		if has_settings_signal and not top_bar.settings_pressed.is_connected(_on_topbar_settings):
			top_bar.settings_pressed.connect(_on_topbar_settings)

	if nav_bar and nav_bar.has_signal("tab_selected"):
		if not nav_bar.tab_selected.is_connected(_on_nav_tab_selected):
			nav_bar.tab_selected.connect(_on_nav_tab_selected)

	# Display the publisher splash immediately while systems initialize in the
	# background, so the user sees branding within the first frame or two.
	if NavigationService:
		NavigationService.replace("publisher_splash")

	if _boot_flow:
		_boot_flow.boot_completed.connect(_on_boot_completed)
		_boot_flow.boot_failed.connect(_on_boot_failed)
		_boot_flow.start_boot()
	else:
		call_deferred("_on_boot_completed")

func _ensure_boot_flow() -> void:
	var boot_script = load("res://src/core/app/AppBoot.gd")
	if boot_script:
		_boot_flow = boot_script.new()
		_boot_flow.name = "AppBoot"
		add_child(_boot_flow)

func _on_boot_completed() -> void:
	AppState.set_loading(false)
	# The publisher splash is displayed immediately in _ready; once boot finishes
	# the splash's own timer advances us to the title/loading screen. If for some
	# reason we're not on a splash route (e.g. deep link), load that screen.
	if NavigationService:
		var current = NavigationService.current_route
		if current != "publisher_splash" and current != "title_splash" and current != "splash":
			_load_screen(current)
	# Notify the active splash screen that boot has completed (if it is already up).
	if _current_screen and _current_screen.has_method("notify_boot_completed"):
		_current_screen.notify_boot_completed()

func _on_boot_failed(reason: String) -> void:
	_show_error("Boot failed: %s" % reason)
	AppState.set_loading(false)
	if NavigationService:
		NavigationService.navigate_to("publisher_splash")

func _on_route_changed(route: String, params: Dictionary) -> void:
	# Resolve chrome visibility and safe-area content rect before mounting the
	# screen. This prevents splash/gameplay routes from drawing one frame inside
	# the previous route's content frame.
	_update_chrome(route)
	_load_screen(route, params)

func _load_screen(route: String, params: Dictionary = {}) -> void:
	var started_at: int = Time.get_ticks_usec()
	if _current_screen != null and _current_route == route:
		_current_screen.visible = true
		if _current_screen.has_method("on_navigated_to"):
			_current_screen.call("on_navigated_to", params)
		ResponsiveLayout.prepare_scroll_descendants(_current_screen)
		ResponsiveLayout.enforce_touch_targets(_current_screen)
		_animate_screen_in(route)
		_record_screen_presented(route, CACHEABLE_ROUTES.has(route), started_at)
		return
	_retire_current_screen(route)
	var was_cached: bool = _screen_cache.has(route)

	if was_cached:
		_current_screen = _screen_cache[route]
		_current_screen.visible = true
		_current_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_current_screen.offset_left = 0.0
		_current_screen.offset_top = 0.0
		_current_screen.offset_right = 0.0
		_current_screen.offset_bottom = 0.0
		if _current_screen.has_method("on_navigated_to"):
			_current_screen.call("on_navigated_to", params)
	else:
		var scene_path: String = SCREEN_SCENES.get(route, "")
		if scene_path == "":
			scene_path = "res://src/ui/screens/%sScreen.tscn" % _capitalize_first(route)
		var screen_instance: Control = null
		if ResourceLoader.exists(scene_path):
			var scene: PackedScene = load(scene_path)
			if scene:
				screen_instance = scene.instantiate() as Control
		else:
			screen_instance = _create_unavailable_screen(route)
		if screen_instance:
			screen_instance.name = "%sScreenInstance" % route.capitalize()
			# ContentContainer is a plain Control (not a Container), so size flags
			# alone do not expand children. Force full-rect anchors so every
			# production screen fills the available phone viewport.
			screen_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
			if content_container:
				content_container.add_child(screen_instance)
			else:
				add_child(screen_instance)
			# Re-assert after parenting; Godot can reset offsets when reparenting.
			screen_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			screen_instance.offset_left = 0.0
			screen_instance.offset_top = 0.0
			screen_instance.offset_right = 0.0
			screen_instance.offset_bottom = 0.0
			if CACHEABLE_ROUTES.has(route):
				_screen_cache[route] = screen_instance
			_current_screen = screen_instance
			if screen_instance.has_method("on_navigated_to"):
				screen_instance.call("on_navigated_to", params)
		else:
			if ErrorHandler:
				ErrorHandler.handle("SCREEN_LOAD_FAILED", "Failed to load %s" % route, {"route": route})
	_current_route = route
	if _current_screen:
		ResponsiveLayout.prepare_scroll_descendants(_current_screen)
		ResponsiveLayout.enforce_touch_targets(_current_screen)
		_animate_screen_in(route)
	_record_screen_presented(route, was_cached, started_at)

func _record_screen_presented(route: String, was_cached: bool, started_at: int) -> void:
	var duration_ms: float = float(Time.get_ticks_usec() - started_at) / 1000.0
	if AnalyticsService:
		AnalyticsService.log_event("screen_presented", {
			"route": route,
			"cached": was_cached,
			"duration_ms": snappedf(duration_ms, 0.01),
			"memory_mb": snappedf(float(Performance.get_monitor(Performance.MEMORY_STATIC)) / 1048576.0, 0.1)
		})

func _retire_current_screen(next_route: String) -> void:
	if _current_screen == null or _current_route == next_route:
		return
	_current_screen.visible = false
	if not CACHEABLE_ROUTES.has(_current_route):
		_screen_cache.erase(_current_route)
		_current_screen.queue_free()
		_current_screen = null

func _animate_screen_in(route: String) -> void:
	if _current_screen == null:
		return
	if _screen_transition and _screen_transition.is_valid():
		_screen_transition.kill()
	_current_screen.modulate.a = 1.0
	var is_launch_route: bool = route in ["publisher_splash", "title_splash", "splash"]
	if is_launch_route or (AccessibilityService and not AccessibilityService.should_animate()):
		return
	_current_screen.modulate.a = 0.0
	_screen_transition = create_tween()
	_screen_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var base_duration := float(ConfigService.get_value("ui.animation_duration_ms", 200)) / 1000.0 if ConfigService else 0.20
	var duration := AccessibilityService.get_animation_duration(base_duration) if AccessibilityService else base_duration
	_screen_transition.tween_property(_current_screen, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)

func _create_unavailable_screen(route: String) -> Control:
	var ctrl := Control.new()
	ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ctrl.add_child(center)
	var label := Label.new()
	label.text = "This screen is unavailable."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(label, "body", "text_secondary")
	center.add_child(label)
	if ErrorHandler:
		ErrorHandler.handle("SCREEN_UNAVAILABLE", "Route has no screen scene: %s" % route, {"route": route}, ErrorHandler.Severity.WARNING)
	return ctrl

func _update_chrome(route: String) -> void:
	var is_tab := true
	var routes_script = load("res://src/core/navigation/AppRoutes.gd")
	if routes_script:
		is_tab = routes_script.is_tab_route(route)

	# Launch screens remain full-viewport. Active gameplay owns a compact,
	# safe-area-aware exit control so the generic app header and tab bar do not
	# sit between the player and the challenge.
	var is_splash := route in ["publisher_splash", "title_splash", "splash"]
	var is_gameplay := route in ["observation", "memory_question", "result"]

	if nav_bar:
		nav_bar.visible = is_tab and not is_splash and not is_gameplay
		if nav_bar.has_method("set_current_route"):
			nav_bar.set_current_route(route)

	if top_bar:
		top_bar.visible = not is_splash and not is_gameplay
		if top_bar.has_method("set_show_back"):
			var show_back := not is_tab and not is_splash
			if route == "about":
				show_back = true
			top_bar.set_show_back(show_back)
		if top_bar.has_method("set_show_actions"):
			top_bar.set_show_actions(not is_tab and not is_gameplay and route != "tutorial")
		var title_map := {
			"publisher_splash": "",
			"title_splash": "",
			"splash": "",
			"observation": "Observe",
			"memory_question": "Recall",
			"result": "Evidence Reveal",
			"home": "Witness",
			"experiences": "Explore Experiences",
			"profile": "Witness Record",
			"settings": "Settings",
			"about": "About",
			"achievements": "Milestones",
			"programs": "Programs"
		}
		if top_bar.has_method("set_title"):
			top_bar.set_title(title_map.get(route, route.capitalize()))
	# Bar visibility changes the content's bottom inset, so safe areas are
	# resolved after chrome state is final.
	_apply_safe_area()

func _on_phase_changed(_new_phase, _old_phase) -> void:
	if NavigationService:
		_update_chrome(NavigationService.current_route)
	else:
		_update_chrome("home")

func _on_loading_changed(is_loading: bool, message: String) -> void:
	if loading_overlay:
		loading_overlay.visible = is_loading
		if loading_overlay.has_node("Center/VBox/Message"):
			loading_overlay.get_node("Center/VBox/Message").text = message if message != "" else "Preparing…"
		if is_loading:
			_start_loading_pulse()
		else:
			_stop_loading_pulse()

func _start_loading_pulse() -> void:
	_stop_loading_pulse()
	var indicator: Control = loading_overlay.get_node_or_null("Center/VBox/Spinner") as Control
	if indicator == null:
		return
	indicator.modulate.a = 1.0
	indicator.scale = Vector2.ONE
	if AccessibilityService and not AccessibilityService.should_animate():
		return
	_loading_pulse = indicator.create_tween()
	_loading_pulse.set_loops()
	_loading_pulse.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_loading_pulse.tween_property(indicator, "modulate:a", 0.58, 0.7)
	_loading_pulse.parallel().tween_property(indicator, "scale", Vector2(1.035, 1.035), 0.7)
	_loading_pulse.tween_property(indicator, "modulate:a", 1.0, 0.7)
	_loading_pulse.parallel().tween_property(indicator, "scale", Vector2.ONE, 0.7)

func _stop_loading_pulse() -> void:
	if _loading_pulse and _loading_pulse.is_valid():
		_loading_pulse.kill()
	_loading_pulse = null

func _on_user_message(message: String, _severity: int) -> void:
	_show_error(message)

func _on_session_failed(reason: String) -> void:
	_show_error(reason if not reason.is_empty() else "That challenge could not be prepared. Please try again.")

func _show_error(message: String) -> void:
	if error_banner:
		error_banner.visible = true
		if error_banner.has_node("Margin/HBox/Label"):
			error_banner.get_node("Margin/HBox/Label").text = message
		elif error_banner.has_node("Margin/Label"):
			error_banner.get_node("Margin/Label").text = message
	# Auto-hide after 4s, but user can dismiss early
	if is_instance_valid(_error_hide_timer):
		if _error_hide_timer.timeout.is_connected(_hide_error_banner):
			_error_hide_timer.timeout.disconnect(_hide_error_banner)
		_error_hide_timer = null
	_error_hide_timer = get_tree().create_timer(4.0)
	_error_hide_timer.timeout.connect(_hide_error_banner)

var _error_hide_timer: SceneTreeTimer = null

func _hide_error_banner() -> void:
	if is_instance_valid(error_banner):
		error_banner.visible = false

func _apply_theme() -> void:
	if not ThemeService:
		return
	var tokens = ThemeService.tokens
	var bg: Color = tokens.get("background", Color("#0F0F12"))
	if background_layer:
		var style := StyleBoxFlat.new()
		style.bg_color = bg
		background_layer.add_theme_stylebox_override("panel", style)
	# Error banner styling
	if error_banner:
		var err_style := StyleBoxFlat.new()
		err_style.bg_color = tokens.get("error_container", tokens.get("error", Color.RED))
		err_style.corner_radius_bottom_left = 8
		err_style.corner_radius_bottom_right = 8
		error_banner.add_theme_stylebox_override("panel", err_style)
		var label_path := "Margin/HBox/Label"
		if error_banner.has_node(label_path):
			var lbl: Label = error_banner.get_node(label_path)
			lbl.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
			ThemeService.apply_typography(lbl, "body_small")

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_safe_area()
	_apply_theme()
	_setup_loading_overlay()
	_setup_error_banner()

func _on_topbar_back() -> void:
	if NavigationService:
		if NavigationService.can_go_back():
			NavigationService.go_back()
		else:
			NavigationService.navigate_to("home")

func _on_topbar_profile() -> void:
	if NavigationService:
		NavigationService.navigate_to("profile")

func _on_topbar_settings() -> void:
	if NavigationService:
		NavigationService.navigate_to("settings")

func _on_nav_tab_selected(route: String) -> void:
	if NavigationService and NavigationService.current_route != route:
		NavigationService.navigate_to(route)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or not NavigationService:
		return
	get_viewport().set_input_as_handled()
	if NavigationService.current_route == "home":
		return
	if NavigationService.can_go_back():
		NavigationService.go_back()
	else:
		NavigationService.navigate_to("home")

func _apply_safe_area() -> void:
	if not ThemeService:
		return
	var area: Rect2i = DisplayServer.get_display_safe_area()
	var win_size: Vector2i = DisplayServer.window_get_size()
	if area.size.x <= 0 or area.size.y <= 0:
		area = Rect2i(Vector2i.ZERO, win_size)
	var insets: Dictionary = ResponsiveLayout.scale_safe_area_insets(
		area,
		win_size,
		get_viewport_rect().size
	)
	var top: int = int(insets.get("top", 0))
	var bottom: int = int(insets.get("bottom", 0))
	var left: int = int(insets.get("left", 0))
	var right: int = int(insets.get("right", 0))
	# Ensure minimum safe areas for phones with gesture navigation or cutouts.
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		top = max(top, 44)
		bottom = max(bottom, 24)
	else:
		# Editor / desktop fallback – still add a little breathing room
		top = max(top, 12)
		bottom = max(bottom, 12)

	# Measure and explicitly size chrome. These layers are anchored to edges; if
	# their rect height is left at zero, child labels can visually escape the
	# panel and appear as floating navigation text on phones.
	var top_bar_layer := get_node_or_null("TopBarLayer")
	var top_bar_height: float = 0.0
	if top_bar and top_bar.visible:
		top_bar_height = maxf(maxf(top_bar.get_combined_minimum_size().y, top_bar.custom_minimum_size.y), 60.0)
		top_bar.custom_minimum_size.y = top_bar_height
		top_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
		top_bar.offset_left = 0
		top_bar.offset_top = 0
		top_bar.offset_right = 0
		top_bar.offset_bottom = 0
	if top_bar_layer:
		top_bar_layer.offset_top = top
		top_bar_layer.offset_bottom = top + top_bar_height
		top_bar_layer.offset_left = left
		top_bar_layer.offset_right = -right

	var nav_layer := get_node_or_null("NavigationLayer")
	var nav_bar_height: float = 0.0
	if nav_bar and nav_bar.visible:
		nav_bar_height = maxf(maxf(nav_bar.get_combined_minimum_size().y, nav_bar.custom_minimum_size.y), 76.0)
		nav_bar.custom_minimum_size.y = nav_bar_height
		nav_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
		nav_bar.offset_left = 0
		nav_bar.offset_top = 0
		nav_bar.offset_right = 0
		nav_bar.offset_bottom = 0
	if nav_layer:
		nav_layer.offset_top = -(bottom + nav_bar_height)
		nav_layer.offset_bottom = -bottom
		nav_layer.offset_left = left
		nav_layer.offset_right = -right

	# Content container respects safe area and active chrome. Offsets are clamped
	# so tiny phone viewports still leave a usable content rectangle instead of
	# allowing top and bottom bars to intersect.
	if content_container:
		var current_route = NavigationService.current_route if NavigationService else "home"
		var is_splash: bool = current_route in ["publisher_splash", "title_splash", "splash"]
		var top_offset: float = 0.0
		var bottom_inset: float = 0.0
		var content_left: int = 0
		var content_right: int = 0
		if not is_splash:
			# App content respects safe areas and visible chrome. Splash routes are
			# intentionally full-viewport so publisher artwork and the title boot
			# sequence feel native instead of inset or scaled inside a safe-area box.
			top_offset = top + top_bar_height
			bottom_inset = bottom
			content_left = left
			content_right = right
			if nav_bar and nav_bar.visible:
				bottom_inset += nav_bar_height
			var viewport_height: float = get_viewport_rect().size.y
			var min_content_height := 260.0
			if viewport_height > 0.0 and top_offset + bottom_inset > viewport_height - min_content_height:
				var overflow := top_offset + bottom_inset - (viewport_height - min_content_height)
				bottom_inset = maxf(bottom, bottom_inset - overflow)
		content_container.offset_top = top_offset
		content_container.offset_bottom = -bottom_inset
		content_container.offset_left = content_left
		content_container.offset_right = -content_right

	# Store in ThemeService tokens for children to use
	if ThemeService and ThemeService.tokens:
		ThemeService.tokens["safe_area_top"] = top
		ThemeService.tokens["safe_area_bottom"] = bottom

func _ensure_modal_layer() -> void:
	if modal_layer and is_instance_valid(modal_layer):
		return
	if not overlay_layer:
		return
	var script: Script = load("res://src/ui/components/ModalLayer.gd")
	if not script:
		return
	modal_layer = Control.new()
	modal_layer.name = "ModalLayer"
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.set_script(script)
	overlay_layer.add_child(modal_layer)
	overlay_layer.move_child(modal_layer, max(0, overlay_layer.get_child_count() - 1))

func _setup_loading_overlay() -> void:
	if not loading_overlay or not ThemeService:
		return
	var tokens = ThemeService.tokens
	# Style background
	var style := StyleBoxFlat.new()
	style.bg_color = Color(tokens.get("background", Color.BLACK), 0.85)
	loading_overlay.add_theme_stylebox_override("panel", style)

	# Find message label
	var msg_label: Label = null
	if loading_overlay.has_node("Center/VBox/Message"):
		msg_label = loading_overlay.get_node("Center/VBox/Message")
		ThemeService.apply_label_style(msg_label, "body", "text_primary")
		msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Branded eye pulse; no generic spinner and no color-only status.
	var spinner := loading_overlay.get_node_or_null("Center/VBox/Spinner")
	if spinner is TextureRect:
		var eye := spinner as TextureRect
		eye.texture = load("res://assets/brand/witness_eye_glow.png") as Texture2D
		eye.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		eye.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	elif spinner is Label:
		var spinner_label := spinner as Label
		spinner_label.text = "WITNESS"
		ThemeService.apply_typography(spinner_label, "display")
		spinner_label.add_theme_color_override("font_color", tokens.get("primary", Color.WHITE))
		spinner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _setup_error_banner() -> void:
	if not error_banner or not ThemeService:
		return
	# Ensure HBox with label + close button exists
	var margin: MarginContainer = null
	if error_banner.has_node("Margin"):
		margin = error_banner.get_node("Margin")
	if not margin:
		return
	var hbox: HBoxContainer = null
	if margin.has_node("HBox"):
		hbox = margin.get_node("HBox")
	else:
		# Migrate old Label to HBox layout
		var old_label: Label = null
		if margin.has_node("Label"):
			old_label = margin.get_node("Label")
			margin.remove_child(old_label)
		hbox = HBoxContainer.new()
		hbox.name = "HBox"
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.add_child(hbox)
		if old_label:
			old_label.name = "Label"
			old_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			old_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hbox.add_child(old_label)
		else:
			var lbl := Label.new()
			lbl.name = "Label"
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hbox.add_child(lbl)
		var close_btn := Button.new()
		close_btn.name = "CloseButton"
		close_btn.text = "✕"
		close_btn.custom_minimum_size = Vector2(48, 48)
		close_btn.flat = true
		hbox.add_child(close_btn)
		if not close_btn.pressed.is_connected(_hide_error_banner):
			close_btn.pressed.connect(_hide_error_banner)
	# Style close button
	var close_btn_node = hbox.get_node_or_null("CloseButton")
	if close_btn_node is Button:
		var btn: Button = close_btn_node
		btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("body"))
		btn.add_theme_color_override("font_color", ThemeService.get_color("text_primary"))

func _capitalize_first(s: String) -> String:
	if s.is_empty():
		return s
	return s[0].to_upper() + s.substr(1)

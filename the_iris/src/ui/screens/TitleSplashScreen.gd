extends Control
## TitleSplashScreen - Two Second Witness branded boot
## Matches Home screen hero exactly for seamless transition
## Eye motif pulses as loading indicator – no generic spinners

const MIN_DISPLAY_TIME := 1.2
const MAX_BOOT_WAIT_TIME := 6.0
const POLICY_VERSION := "4.0.0-2026-07-13"
const PRIVACY_POLICY_URL := "https://ittybittybites.github.io/two-second-witness/privacy"
const TERMS_OF_SERVICE_URL := "https://ittybittybites.github.io/two-second-witness/terms"

const PrivacyDialogScene := preload("res://src/ui/dialogs/PrivacyTermsDialog.tscn")

@onready var brand_label: Label = $MainMargin/Scroll/Content/Hero/BrandLabel
@onready var you_are_label: Label = $MainMargin/Scroll/Content/Hero/YouAreLabel
@onready var witness_label: Label = $MainMargin/Scroll/Content/Hero/WitnessLabel
@onready var eye_rect: TextureRect = $MainMargin/Scroll/Content/Hero/EyeWrap/Eye
@onready var tagline_label: Label = $MainMargin/Scroll/Content/Hero/Tagline
@onready var status_label: Label = $MainMargin/Scroll/Content/LoadingBlock/StatusLabel
@onready var progress_bar: ProgressBar = $MainMargin/Scroll/Content/LoadingBlock/ProgressBar
@onready var dialog_layer: Control = $PrivacyDialogLayer

var _elapsed: float = 0.0
var _boot_completed: bool = false
var _is_navigating: bool = false
var _privacy_dialog: Control = null
var _eye_tween: Tween = null
var _boot_progress: float = 0.0

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_apply_responsive_layout()
	if not resized.is_connected(_apply_responsive_layout):
		resized.connect(_apply_responsive_layout)
	_apply_theme()
	_start_eye_pulse()
	_connect_boot()
	_animate_in()
	_update_loading_ui("Initializing…", 0.0)

func _apply_responsive_layout() -> void:
	ResponsiveLayout.apply_centered_margin($MainMargin, 24.0)

func _apply_theme() -> void:
	var tokens := {}
	if ThemeService and not ThemeService.tokens.is_empty():
		tokens = ThemeService.tokens

	var bg := get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = tokens.get("background", Color("#0F0F12")) if not tokens.is_empty() else Color("#0F0F12")

	if brand_label:
		if ThemeService:
			ThemeService.apply_label_style(brand_label, "label", "text_tertiary")
			brand_label.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(16))
		else:
			brand_label.add_theme_color_override("font_color", Color("#8A8AA3"))
	if you_are_label:
		if ThemeService:
			ThemeService.apply_label_style(you_are_label, "body", "text_secondary")
	if witness_label:
		if ThemeService:
			ThemeService.apply_label_style(witness_label, "display", "text_primary")
			witness_label.add_theme_font_size_override("font_size", ThemeService.get_scaled_size(42))
		else:
			witness_label.add_theme_font_size_override("font_size", 42)
	if tagline_label:
		if ThemeService:
			ThemeService.apply_label_style(tagline_label, "body_small", "text_secondary")

	if status_label:
		if ThemeService:
			ThemeService.apply_label_style(status_label, "label_small", "text_tertiary")
		status_label.text = "Initializing…"

	if progress_bar:
		progress_bar.max_value = 100.0
		progress_bar.value = 0.0
		# Style the progress bar to match Home CTA purple
		var bg_style := StyleBoxFlat.new()
		bg_style.bg_color = Color("#24242C")
		bg_style.corner_radius_top_left = 99
		bg_style.corner_radius_top_right = 99
		bg_style.corner_radius_bottom_left = 99
		bg_style.corner_radius_bottom_right = 99
		progress_bar.add_theme_stylebox_override("background", bg_style)
		var fill_style := StyleBoxFlat.new()
		var primary := Color("#6A3DFF")
		if not tokens.is_empty():
			primary = tokens.get("primary", primary)
		fill_style.bg_color = primary
		fill_style.corner_radius_top_left = 99
		fill_style.corner_radius_top_right = 99
		fill_style.corner_radius_bottom_left = 99
		fill_style.corner_radius_bottom_right = 99
		progress_bar.add_theme_stylebox_override("fill", fill_style)

func _start_eye_pulse() -> void:
	if not eye_rect:
		return
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	# Respect reduced motion
	if not _should_animate():
		eye_rect.modulate.a = 1.0
		eye_rect.scale = Vector2.ONE
		return
	var breathe := _get_anim_duration(1.2)
	_eye_tween = create_tween()
	_eye_tween.set_loops()
	_eye_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Subtle breathe – scale + glow
	_eye_tween.tween_property(eye_rect, "modulate:a", 0.92, breathe).from(1.0)
	_eye_tween.tween_property(eye_rect, "modulate:a", 1.0, breathe)
	# slight scale pulse
	_eye_tween.parallel()
	_eye_tween.tween_property(eye_rect, "scale", Vector2(1.015, 1.015), breathe).from(Vector2.ONE)
	_eye_tween.tween_property(eye_rect, "scale", Vector2.ONE, breathe)

func _stop_eye_pulse() -> void:
	if _eye_tween and _eye_tween.is_valid():
		_eye_tween.kill()
	_eye_tween = null
	if eye_rect:
		eye_rect.modulate.a = 1.0
		eye_rect.scale = Vector2.ONE

func _update_loading_ui(text: String, progress_0_1: float) -> void:
	if status_label:
		status_label.text = text
	if progress_bar:
		progress_bar.value = clamp(progress_0_1, 0.0, 1.0) * 100.0

func _connect_boot() -> void:
	var boot_node := _find_boot_node()
	if boot_node:
		if boot_node.has_signal("boot_step_started") and not boot_node.boot_step_started.is_connected(_on_boot_step_started):
			boot_node.boot_step_started.connect(_on_boot_step_started)
		if boot_node.has_signal("boot_step_completed") and not boot_node.boot_step_completed.is_connected(_on_boot_step_completed):
			boot_node.boot_step_completed.connect(_on_boot_step_completed)
		if boot_node.has_signal("boot_completed") and not boot_node.boot_completed.is_connected(_on_boot_completed):
			boot_node.boot_completed.connect(_on_boot_completed)
		var boot_already_done := false
		if AppState and AppState.is_initialized:
			boot_already_done = true
		var is_booting = boot_node.get("_is_booting")
		if is_booting == false:
			boot_already_done = true
		if boot_already_done:
			_boot_completed = true
			_update_loading_ui("Ready", 1.0)
	else:
		_boot_completed = true
		_update_loading_ui("Ready", 1.0)

func _find_boot_node() -> Node:
	if has_node("/root/AppShell/AppBoot"):
		return get_node("/root/AppShell/AppBoot")
	var root := get_tree().root
	if root and root.has_node("AppShell/AppBoot"):
		return root.get_node("AppShell/AppBoot")
	if get_tree().root:
		for child in get_tree().root.get_children():
			if child.name == "AppShell" and child.has_node("AppBoot"):
				return child.get_node("AppBoot")
	return null

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func _animate_in() -> void:
	modulate.a = 0.0
	var dur := _get_anim_duration(0.32)
	if not _should_animate():
		modulate.a = 1.0
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, dur).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_elapsed += delta
	# Simulate smooth progress while booting
	if not _boot_completed:
		_boot_progress = min(_boot_progress + delta * 0.15, 0.85)
		if progress_bar:
			progress_bar.value = _boot_progress * 100.0
	if not _boot_completed and _elapsed >= MAX_BOOT_WAIT_TIME:
		_boot_completed = true
		_update_loading_ui("Ready", 1.0)
	if _boot_completed and _elapsed >= MIN_DISPLAY_TIME and not _is_navigating:
		if dialog_layer and dialog_layer.visible:
			return
		_on_ready_to_proceed()
		set_process(false)

func _on_boot_step_started(step: String) -> void:
	_update_loading_ui(step.capitalize().replace("_", " ") + "…", _boot_progress)

func _on_boot_step_completed(step: String, _duration_ms: int) -> void:
	_boot_progress = min(_boot_progress + 0.12, 0.9)
	_update_loading_ui(step.capitalize().replace("_", " ") + " ✓", _boot_progress)

func _on_boot_completed() -> void:
	_boot_completed = true
	_update_loading_ui("Ready", 1.0)

func _on_ready_to_proceed() -> void:
	if _is_navigating:
		return
	if dialog_layer and dialog_layer.visible:
		return
	if _needs_privacy_acknowledgment():
		_show_privacy_dialog()
		return
	if _needs_intro_tutorial():
		_navigate_intro_tutorial()
		return
	_navigate_home()

func _needs_privacy_acknowledgment() -> bool:
	var has_profile_ack := false
	var has_settings_ack := false
	if ProfileService and ProfileService.profile is Dictionary:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		if bool(prefs.get("privacy_acknowledged", false)) and str(prefs.get("privacy_policy_version", "")) == POLICY_VERSION:
			has_profile_ack = true
	if SettingsService:
		if bool(SettingsService.get_value("privacy_acknowledged", false)) and str(SettingsService.get_value("privacy_policy_version", "")) == POLICY_VERSION:
			has_settings_ack = true
	if has_profile_ack or has_settings_ack:
		return false
	if not ProfileService and not SettingsService:
		return false
	return true

func _get_intro_family_id() -> String:
	if not ChallengeFamilyRegistry:
		return ""
	var visible_family_ids: Array[String] = ChallengeFamilyRegistry.get_visible_family_ids()
	return visible_family_ids[0] if not visible_family_ids.is_empty() else ""

func _get_intro_template_id(family_id: String) -> String:
	if not ChallengeFamilyRegistry or family_id.is_empty():
		return ""
	var module = ChallengeFamilyRegistry.get_module(family_id)
	if module == null:
		return ""
	var templates = module.get_templates()
	return templates[0].template_id if not templates.is_empty() else ""

func _needs_intro_tutorial() -> bool:
	if not ProfileService or not ChallengeFamilyRegistry:
		return false
	var prefs: Dictionary = ProfileService.profile.get("preferences", {})
	if bool(prefs.get("onboarding_completed", false)):
		return false
	var intro_family: String = _get_intro_family_id()
	return not intro_family.is_empty() and ChallengeFamilyRegistry.get_family(intro_family) != null

func _navigate_intro_tutorial() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	if _should_animate() and eye_rect:
		if _eye_tween and _eye_tween.is_valid():
			_eye_tween.kill()
		var settle := create_tween()
		settle.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		settle.tween_property(eye_rect, "scale", Vector2.ONE, 0.22).set_ease(Tween.EASE_OUT)
		settle.parallel().tween_property(eye_rect, "modulate:a", 1.0, 0.22)
		await settle.finished
	else:
		_stop_eye_pulse()
	var fade_dur := _get_anim_duration(0.28)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, fade_dur).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		var intro_family: String = _get_intro_family_id()
		var intro_template: String = _get_intro_template_id(intro_family)
		if NavigationService and not intro_family.is_empty():
			NavigationService.navigate_to("tutorial", {
				"family_id": intro_family,
				"pending_template_id": intro_template,
				"launch_source": "first_launch_intro",
				"session_context": {"intro_tutorial": true}
			})
	)

func _show_privacy_dialog() -> void:
	if dialog_layer and dialog_layer.visible:
		return
	if _privacy_dialog == null:
		_privacy_dialog = PrivacyDialogScene.instantiate() as Control
		if dialog_layer:
			dialog_layer.add_child(_privacy_dialog)
		else:
			add_child(_privacy_dialog)
		if _privacy_dialog.has_signal("accepted"):
			_privacy_dialog.accepted.connect(_on_privacy_accepted)
		if _privacy_dialog.has_signal("view_policy"):
			_privacy_dialog.view_policy.connect(_on_view_privacy_policy)
		if _privacy_dialog.has_signal("view_terms"):
			_privacy_dialog.view_terms.connect(_on_view_terms_of_service)
	if dialog_layer:
		dialog_layer.visible = true
		dialog_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		dialog_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		dialog_layer.z_index = 100
		dialog_layer.move_to_front()
	if _privacy_dialog:
		_privacy_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
		_privacy_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
		_privacy_dialog.z_index = 101
		_privacy_dialog.move_to_front()
		_privacy_dialog.visible = true
	set_process(false)

func _on_privacy_accepted() -> void:
	if ProfileService:
		var prefs: Dictionary = ProfileService.profile.get("preferences", {})
		prefs["privacy_acknowledged"] = true
		prefs["privacy_policy_version"] = POLICY_VERSION
		ProfileService.profile["preferences"] = prefs
		ProfileService.save()
	if SettingsService:
		SettingsService.set_value("privacy_acknowledged", true)
		SettingsService.set_value("privacy_policy_version", POLICY_VERSION)
	if AnalyticsService:
		AnalyticsService.log_event("privacy_acknowledged")
	if dialog_layer:
		dialog_layer.visible = false
	if _privacy_dialog:
		_privacy_dialog.visible = false
	# Continue boot flow to Home. Challenge Type tutorials are gated when a family is first entered.
	_is_navigating = false
	_elapsed = MIN_DISPLAY_TIME
	set_process(true)

func _on_view_privacy_policy() -> void:
	if OS.shell_open(PRIVACY_POLICY_URL) != OK:
		pass

func _on_view_terms_of_service() -> void:
	if OS.shell_open(TERMS_OF_SERVICE_URL) != OK:
		pass

func _navigate_home() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	# Eye wake-up: slow the pulse, then settle – "instrument waking up"
	if _should_animate() and eye_rect:
		# Stop the fast breathe loop
		if _eye_tween and _eye_tween.is_valid():
			_eye_tween.kill()
		# Slow settle: 300ms ease to resting state, slight glow up
		var settle := create_tween()
		settle.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		settle.tween_property(eye_rect, "scale", Vector2.ONE, 0.28).set_ease(Tween.EASE_OUT)
		settle.parallel().tween_property(eye_rect, "modulate:a", 1.0, 0.28)
		await settle.finished
	else:
		_stop_eye_pulse()

	var fade_dur := _get_anim_duration(0.28)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# Fade slightly – Home screen has identical hero, so this feels continuous
	tween.tween_property(self, "modulate:a", 0.0, fade_dur).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("home")
	)

func _input(event: InputEvent) -> void:
	if dialog_layer and dialog_layer.visible:
		return
	var should_advance := false
	if event is InputEventScreenTouch and event.pressed:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if event is InputEventKey and event.pressed:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _elapsed > 0.3 and _boot_completed:
			should_advance = true
	if should_advance and not _is_navigating:
		_on_ready_to_proceed()

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
	_boot_progress = 0.0
	if AppState and AppState.is_initialized:
		_boot_completed = true
		_update_loading_ui("Ready", 1.0)
	else:
		_boot_completed = false
		_update_loading_ui("Initializing…", 0.0)
		var boot_node := _find_boot_node()
		if boot_node:
			var is_booting = boot_node.get("_is_booting")
			if is_booting == false:
				_boot_completed = true
				_update_loading_ui("Ready", 1.0)
	_connect_boot()
	modulate.a = 0.0
	if dialog_layer:
		dialog_layer.visible = false
	if _privacy_dialog:
		_privacy_dialog.visible = false
	set_process(true)
	_apply_theme()
	_start_eye_pulse()
	_animate_in()

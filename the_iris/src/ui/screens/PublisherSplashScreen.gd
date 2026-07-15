extends Control
## PublisherSplashScreen - ITTYBITTYBITES publisher intro
## Premium, restrained, matches Home screen typography / theme
## No generic sponsor screen, no "Powered by"

@onready var brand_label: Label = $Center/VBox/Brand
@onready var subtitle_label: Label = $Center/VBox/Subtitle

var _elapsed: float = 0.0
const DISPLAY_DURATION := 1.4
const MAX_WAIT := 3.5
var _is_navigating: bool = false
var _can_advance: bool = false

func _ready() -> void:
	_elapsed = 0.0
	_is_navigating = false
	_can_advance = false
	set_process(true)
	_apply_theme()
	_animate_in()
	if AppState and AppState.is_initialized:
		_can_advance = true

func _apply_theme() -> void:
	if ThemeService and not ThemeService.tokens.is_empty():
		var tokens = ThemeService.tokens
		if brand_label:
			ThemeService.apply_label_style(brand_label, "title", "text_primary")
			brand_label.add_theme_font_size_override("font_size", 28)
			# Letter spacing is simulated via upper case – Godot 4.2+ supports font_spacing if available
		if subtitle_label:
			ThemeService.apply_label_style(subtitle_label, "body_small", "text_tertiary")
		var bg := get_node_or_null("Background") as ColorRect
		if bg:
			bg.color = tokens.get("background", Color("#0F0F12"))
	else:
		# Fallback styling
		if brand_label:
			brand_label.add_theme_font_size_override("font_size", 28)
			brand_label.add_theme_color_override("font_color", Color.WHITE)
		if subtitle_label:
			subtitle_label.add_theme_font_size_override("font_size", 16)
			subtitle_label.add_theme_color_override("font_color", Color("#B8B8CC"))

func _get_anim_duration(base: float) -> float:
	if AccessibilityService and AccessibilityService.has_method("get_animation_duration"):
		return AccessibilityService.get_animation_duration(base)
	return base

func _should_animate() -> bool:
	if AccessibilityService and AccessibilityService.has_method("should_animate"):
		return AccessibilityService.should_animate()
	return true

func notify_boot_completed() -> void:
	_can_advance = true

func _animate_in() -> void:
	# The sponsor is the first engine-drawn frame. Keep it static so a saved
	# Reduced Motion preference is never preceded by an unavoidable animation.
	modulate.a = 1.0

func _process(delta: float) -> void:
	_elapsed += delta
	if not _is_navigating and _elapsed >= DISPLAY_DURATION:
		if _can_advance or _elapsed >= MAX_WAIT:
			_navigate_next()
			set_process(false)

func _input(event: InputEvent) -> void:
	var tap := false
	if event is InputEventScreenTouch and event.pressed:
		tap = true
	elif event is InputEventKey and event.pressed:
		tap = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap = true
	if tap and _elapsed > 0.25 and not _is_navigating:
		_can_advance = true
		_navigate_next()
		set_process(false)

func _navigate_next() -> void:
	if _is_navigating:
		return
	_is_navigating = true
	var fade_dur := _get_anim_duration(0.28)
	if not _should_animate():
		if NavigationService:
			NavigationService.navigate_to("title_splash")
		return
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 0.0, fade_dur).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		if NavigationService:
			NavigationService.navigate_to("title_splash")
	)

func on_navigated_to(_params: Dictionary) -> void:
	_elapsed = 0.0
	_is_navigating = false
	modulate.a = 0.0
	set_process(true)
	_apply_theme()
	_animate_in()

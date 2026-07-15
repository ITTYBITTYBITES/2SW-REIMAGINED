extends PanelContainer
## Premium, data-driven Challenge Type card used by Home and Challenge Library.

signal experience_selected(template_id: String)
signal tutorial_requested(family_id: String)
signal favorite_toggled(family_id: String, favorite: bool)

@export var experience_id: String = ""
var manifest: Dictionary = {}

@onready var artwork: TextureRect = $Margin/VBox/Artwork
@onready var title_label: Label = $Margin/VBox/HeaderRow/Title
@onready var favorite_button: Button = $Margin/VBox/HeaderRow/FavoriteButton
@onready var lock_label: Label = $Margin/VBox/HeaderRow/LockLabel
@onready var description_label: Label = $Margin/VBox/Description
@onready var requirement_label: Label = $Margin/VBox/RequirementLabel
@onready var mastery_label: Label = $Margin/VBox/MasteryRow/MasteryLabel
@onready var mastery_value: Label = $Margin/VBox/MasteryRow/MasteryValue
@onready var mastery_bar: ProgressBar = $Margin/VBox/MasteryBar
@onready var progress_label: Label = $Margin/VBox/MetricsRow/ProgressLabel
@onready var accuracy_label: Label = $Margin/VBox/MetricsRow/AccuracyLabel
@onready var streak_label: Label = $Margin/VBox/MetricsRow/StreakLabel
@onready var tutorial_button: Button = $Margin/VBox/BottomRow/TutorialButton
@onready var play_button: Button = $Margin/VBox/BottomRow/PlayButton

func _ready() -> void:
	_apply_theme()
	_refresh_ui()
	if not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	if not tutorial_button.pressed.is_connected(_on_tutorial_pressed):
		tutorial_button.pressed.connect(_on_tutorial_pressed)
	if not favorite_button.pressed.is_connected(_on_favorite_pressed):
		favorite_button.pressed.connect(_on_favorite_pressed)
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func set_experience(exp_manifest: Dictionary) -> void:
	manifest = exp_manifest.duplicate(true)
	experience_id = str(manifest.get("id", manifest.get("template_id", "")))
	if is_inside_tree():
		_refresh_ui()
		_apply_theme()

func _apply_theme() -> void:
	var tokens: Dictionary = ThemeService.tokens if ThemeService else {}
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	var radius: int = int(tokens.get("radius_lg", 20))
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0, 0, 0, 0.30)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 5)
	style.border_color = (
		tokens.get("warning", Color("#FFC84D"))
		if bool(manifest.get("locked", manifest.get("is_locked", false)))
		else tokens.get("border", Color("#2E2E3A"))
	)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	add_theme_stylebox_override("panel", style)
	if ThemeService:
		ThemeService.apply_label_style(title_label, "title", "text_primary")
		favorite_button.flat = true
		favorite_button.custom_minimum_size = Vector2(56, 56)
		favorite_button.add_theme_font_size_override("font_size", ThemeService.get_font_size("title"))
		favorite_button.add_theme_color_override("font_color", tokens.get("warning", Color("#FFC84D")))
		ThemeService.apply_label_style(lock_label, "label_small", "warning")
		lock_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		lock_label.custom_minimum_size.x = 80.0
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ThemeService.apply_label_style(description_label, "body_small", "text_secondary")
		ThemeService.apply_label_style(requirement_label, "caption", "text_tertiary")
		ThemeService.apply_label_style(mastery_label, "label_small", "text_secondary")
		ThemeService.apply_label_style(mastery_value, "label_small", "text_primary")
		mastery_value.autowrap_mode = TextServer.AUTOWRAP_OFF
		mastery_value.custom_minimum_size.x = 48.0
		mastery_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		for metric: Label in [progress_label, accuracy_label, streak_label]:
			ThemeService.apply_label_style(metric, "caption", "text_secondary")
		_style_button(play_button, true, tokens)
		_style_button(tutorial_button, false, tokens)
	_style_mastery_bar(tokens)

func _style_button(button: Button, primary: bool, tokens: Dictionary) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = (
		tokens.get("primary", Color("#6A3DFF"))
		if primary
		else tokens.get("background_tertiary", Color("#24242C"))
	)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 13
	normal.content_margin_bottom = 13
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = normal.bg_color.lightened(0.08)
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = normal.bg_color.darkened(0.10)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", tokens.get("text_primary", Color.WHITE))
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 60.0)
	button.add_theme_font_size_override(
		"font_size",
		ThemeService.get_font_size("label") if ThemeService else 17
	)

func _style_mastery_bar(tokens: Dictionary) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = tokens.get("background_tertiary", Color("#24242C"))
	background.corner_radius_top_left = 99
	background.corner_radius_top_right = 99
	background.corner_radius_bottom_left = 99
	background.corner_radius_bottom_right = 99
	mastery_bar.add_theme_stylebox_override("background", background)
	var fill: StyleBoxFlat = background.duplicate()
	fill.bg_color = tokens.get("primary_variant", Color("#8A68FF"))
	mastery_bar.add_theme_stylebox_override("fill", fill)

func _refresh_ui() -> void:
	if manifest.is_empty():
		return
	var title: String = str(manifest.get("title", experience_id.capitalize()))
	var description: String = str(manifest.get("short_description", manifest.get("description", "")))
	var required_level: int = int(manifest.get("required_level", 1))
	var locked: bool = bool(manifest.get("locked", manifest.get("is_locked", false)))
	var progress: Dictionary = manifest.get("progress", {})
	var plays: int = int(progress.get("plays", 0))
	var progress_points: int = int(progress.get("progress_points", 0))
	var accuracy: float = clampf(float(progress.get("accuracy", 0.0)), 0.0, 1.0)
	var mastery: float = clampf(float(progress.get("mastery", 0.0)), 0.0, 100.0)
	var best_streak: int = int(progress.get("best_streak", 0))

	title_label.text = title
	var favorite: bool = bool(manifest.get("favorite", false))
	favorite_button.text = "★" if favorite else "☆"
	favorite_button.tooltip_text = "Remove favorite" if favorite else "Add favorite"
	description_label.text = description
	requirement_label.text = "Witness Level %d required" % required_level
	lock_label.text = "LOCKED" if locked else "READY"
	mastery_label.text = "Mastery"
	mastery_value.text = "%d%%" % int(round(mastery))
	mastery_bar.value = mastery
	progress_label.text = "%d rounds · %d progress" % [plays, progress_points]
	accuracy_label.text = "%d%% accuracy" % int(round(accuracy * 100.0))
	streak_label.text = "Best streak %d" % best_streak

	var image_path: String = str(manifest.get("preview_image", manifest.get("image_path", "")))
	artwork.texture = null
	if not image_path.is_empty() and ResourceLoader.exists(image_path):
		artwork.texture = load(image_path) as Texture2D
	artwork.modulate = Color.WHITE if artwork.texture != null else Color(0.42, 0.24, 1.0, 0.28)

	var tutorial_profile: Dictionary = manifest.get("tutorial_profile", {})
	tutorial_button.visible = not tutorial_profile.is_empty()
	tutorial_button.text = "REPLAY TUTORIAL"
	tutorial_button.tooltip_text = str(tutorial_profile.get("replay_label", "Replay tutorial"))
	play_button.disabled = locked or bool(manifest.get("coming_soon", false))
	if bool(manifest.get("coming_soon", false)):
		play_button.text = "COMING SOON"
	elif locked:
		play_button.text = "LEVEL %d" % required_level
	else:
		play_button.text = "PLAY NOW  →"
	modulate = Color(0.82, 0.82, 0.88, 1.0) if locked else Color.WHITE

func _on_play_pressed() -> void:
	if manifest.is_empty() or play_button.disabled:
		return
	if AccessibilityService and AccessibilityService.is_haptics_enabled():
		AccessibilityService.vibrate(30)
	if AudioService:
		AudioService.play_ui("ui_click")
	experience_selected.emit(experience_id)

func _on_tutorial_pressed() -> void:
	var family_id: String = str(manifest.get("family_id", ""))
	if family_id.is_empty():
		return
	if AudioService:
		AudioService.play_ui("ui_click")
	tutorial_requested.emit(family_id)

func _on_favorite_pressed() -> void:
	var family_id: String = str(manifest.get("family_id", ""))
	if family_id.is_empty():
		return
	var favorite: bool = not bool(manifest.get("favorite", false))
	manifest["favorite"] = favorite
	favorite_button.text = "★" if favorite else "☆"
	if AccessibilityService:
		AccessibilityService.vibrate(20)
	favorite_toggled.emit(family_id, favorite)

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

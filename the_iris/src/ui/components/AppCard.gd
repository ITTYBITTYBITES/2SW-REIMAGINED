extends PanelContainer
## AppCard – Premium Witness card
## Matches ExperienceCard / ResultCard / Profile stat cards
## Dark surface, subtle border, radius_lg 20, consistent padding
##
## Usage:
##   var card := preload("res://src/ui/components/AppCard.gd").new()
##   card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
##   # add your content as a child
##
## Or in a .tscn: set script = ExtResource("AppCard.gd") on a PanelContainer

@export var elevated: bool = false
@export var padding: int = 20  # mobile standard; use 28 for hero cards

func _ready() -> void:
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)
	# If the card was instantiated with children already, ensure they expand
	for c in get_children():
		if c is Control:
			c.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_apply_theme()

func _apply_theme() -> void:
	var tokens := ThemeService.tokens if ThemeService else {}
	var bg_key := "surface_elevated" if elevated else "surface"
	var bg: Color = tokens.get(bg_key, Color("#2A2A36") if elevated else Color("#1E1E26")) if not tokens.is_empty() else Color("#1E1E26")
	var border: Color = tokens.get("border", Color("#2E2E3A")) if not tokens.is_empty() else Color("#2E2E3A")
	var radius: int = int(tokens.get("radius_lg", 20)) if not tokens.is_empty() else 20

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding

	add_theme_stylebox_override("panel", style)

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

# Convenience – set padding at runtime and reapply
func set_padding(p: int) -> void:
	padding = p
	_apply_theme()

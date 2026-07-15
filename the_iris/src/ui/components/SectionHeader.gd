extends HBoxContainer
## SectionHeader – Premium section label
## Matches Home "FEATURED CHALLENGE", Profile "CHALLENGE HISTORY"
## style: label_small / text_tertiary, uppercase, letter-spaced
##
## Usage (code):
##   var header := preload("res://src/ui/components/SectionHeader.gd").new()
##   header.text = "FEATURED CHALLENGE"
##   # optional: header.action_text = "See all"
##
## Or in .tscn: add a Label node named "Label" as child, script will find it

@export var text: String = "SECTION":
	set(v):
		text = v
		_update_label()
@export var action_text: String = "":
	set(v):
		action_text = v
		_update_action()

var _label: Label = null
var _action_btn: Button = null

func _ready() -> void:
	_ensure_nodes()
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func _ensure_nodes() -> void:
	# Find or create label
	_label = get_node_or_null("Label") as Label
	if not _label:
		_label = Label.new()
		_label.name = "Label"
		_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(_label)

	# Action button – optional, right-aligned
	if action_text != "":
		if not _action_btn:
			_action_btn = Button.new()
			_action_btn.name = "ActionButton"
			_action_btn.flat = true
			add_child(_action_btn)
	else:
		if _action_btn:
			_action_btn.queue_free()
			_action_btn = null

	_update_label()
	_update_action()

func _update_label() -> void:
	if _label:
		_label.text = text.to_upper()

func _update_action() -> void:
	if _action_btn:
		_action_btn.text = action_text
		_action_btn.visible = action_text != ""

func _apply_theme() -> void:
	if _label and ThemeService:
		ThemeService.apply_label_style(_label, "label_small", "text_tertiary")
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	elif _label:
		_label.add_theme_color_override("font_color", Color("#8A8AA3"))
		_label.add_theme_font_size_override("font_size", 14)

	if _action_btn and ThemeService:
		_action_btn.add_theme_color_override("font_color", ThemeService.get_color("primary"))
		_action_btn.add_theme_font_size_override("font_size", ThemeService.get_font_size("label_small"))

	# Spacing – match Home
	add_theme_constant_override("separation", 8)
	alignment = BoxContainer.ALIGNMENT_CENTER

func _on_theme_changed(_theme: String, _tokens: Dictionary) -> void:
	_apply_theme()

# Signal for action button
signal action_pressed()
func _on_action_pressed() -> void:
	action_pressed.emit()

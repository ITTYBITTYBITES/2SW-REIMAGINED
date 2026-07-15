extends PanelContainer
## EvidenceRevealContainer - Phase 0 structural result wrapper.
##
## This is intentionally not the full Evidence Reveal update. It provides a
## stable, premium host for the existing result reveal view plus concise
## explanation copy so Update 2 can deepen the reveal without rewriting Result.

@onready var _stack: VBoxContainer = null
@onready var _eyebrow: Label = null
@onready var _title: Label = null
@onready var _slot: Control = null
@onready var _explanation: Label = null

func _ready() -> void:
	_ensure_ui()
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func mount_reveal_view(view: Control) -> void:
	_ensure_ui()
	for child: Node in _slot.get_children():
		child.queue_free()
	if view:
		view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		view.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_slot.add_child(view)

func set_explanation(text: String) -> void:
	_ensure_ui()
	_explanation.text = text
	_explanation.visible = not text.strip_edges().is_empty()

func set_heading(title: String, eyebrow: String = "EVIDENCE REVEAL") -> void:
	_ensure_ui()
	_title.text = title
	_eyebrow.text = eyebrow

func _ensure_ui() -> void:
	if _stack:
		return
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	_stack = VBoxContainer.new()
	_stack.name = "Stack"
	_stack.add_theme_constant_override("separation", 10)
	margin.add_child(_stack)

	_eyebrow = Label.new()
	_eyebrow.name = "Eyebrow"
	_eyebrow.text = "EVIDENCE REVEAL"
	_stack.add_child(_eyebrow)

	_title = Label.new()
	_title.name = "Title"
	_title.text = "Look again."
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stack.add_child(_title)

	_slot = Control.new()
	_slot.name = "RevealSlot"
	_slot.custom_minimum_size = Vector2(0, 260)
	_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stack.add_child(_slot)

	_explanation = Label.new()
	_explanation.name = "Explanation"
	_explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stack.add_child(_explanation)

func _apply_theme() -> void:
	_ensure_ui()
	var tokens := ThemeService.tokens if ThemeService else {}
	var style := StyleBoxFlat.new()
	style.bg_color = tokens.get("surface", Color("#1E1E26"))
	style.border_color = tokens.get("border_strong", Color("#3D3D4D"))
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = tokens.get("radius_lg", 20)
	style.corner_radius_top_right = tokens.get("radius_lg", 20)
	style.corner_radius_bottom_left = tokens.get("radius_lg", 20)
	style.corner_radius_bottom_right = tokens.get("radius_lg", 20)
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 14
	style.shadow_offset = Vector2(0, 6)
	add_theme_stylebox_override("panel", style)

	if ThemeService:
		ThemeService.apply_label_style(_eyebrow, "label_small", "primary_variant")
		ThemeService.apply_label_style(_title, "title", "text_primary")
		ThemeService.apply_label_style(_explanation, "body_small", "text_secondary")

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

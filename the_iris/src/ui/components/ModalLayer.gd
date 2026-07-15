extends Control
## ModalLayer - reusable premium overlay host.
##
## Keeps Phase 0 modal preparation inside the existing AppShell layering model.
## It does not introduce new routing; screens may use it later for evidence
## explanations, confirmations, or premium presentation moments.

signal dismissed()

@export var dismiss_on_scrim: bool = true

var _scrim: ColorRect = null
var _panel_host: CenterContainer = null
var _content: Control = null

func _ready() -> void:
	_ensure_nodes()
	_apply_theme()
	if ThemeService and not ThemeService.theme_changed.is_connected(_on_theme_changed):
		ThemeService.theme_changed.connect(_on_theme_changed)

func set_content(content: Control) -> void:
	_ensure_nodes()
	if _content and is_instance_valid(_content):
		_content.queue_free()
	_content = content
	if content:
		_panel_host.add_child(content)

func show_modal() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate.a = 1.0

func hide_modal() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	dismissed.emit()

func _ensure_nodes() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if _scrim == null:
		_scrim = ColorRect.new()
		_scrim.name = "Scrim"
		_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
		_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
		_scrim.gui_input.connect(_on_scrim_input)
		add_child(_scrim)
	if _panel_host == null:
		_panel_host = CenterContainer.new()
		_panel_host.name = "PanelHost"
		_panel_host.set_anchors_preset(Control.PRESET_FULL_RECT)
		_panel_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_panel_host)

func _apply_theme() -> void:
	if _scrim:
		var overlay_color := ThemeService.get_color("overlay", Color(0, 0, 0, 0.6)) if ThemeService else Color(0, 0, 0, 0.6)
		_scrim.color = overlay_color

func _on_scrim_input(event: InputEvent) -> void:
	if dismiss_on_scrim and event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		hide_modal()

func _on_theme_changed(_theme_name: String, _tokens: Dictionary) -> void:
	_apply_theme()

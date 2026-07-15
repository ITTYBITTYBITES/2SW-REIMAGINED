extends Control
class_name IrisAccessibilityPanel

signal action_requested(action: String)

var action_buttons: Array[Button] = []

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _build_panel()
    visible = false

func _build_panel() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.015, 0.025, 0.035, 0.97)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(backdrop)

    var title := Label.new()
    title.text = "IRIS ACCESS PATH"
    title.position = Vector2(42, 72)
    title.size = Vector2(636, 48)
    title.add_theme_font_size_override("font_size", 26)
    title.add_theme_color_override("font_color", Color("#e8faf3"))
    title.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(title)

    var description := Label.new()
    description.text = "An explicit doorway for touch, keyboard, and screen-reader navigation."
    description.position = Vector2(44, 124)
    description.size = Vector2(632, 48)
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.add_theme_font_size_override("font_size", 14)
    description.add_theme_color_override("font_color", Color("#8fb6ad"))
    description.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(description)

    var list := VBoxContainer.new()
    list.position = Vector2(44, 230)
    list.size = Vector2(632, 590)
    list.add_theme_constant_override("separation", 14)
    add_child(list)
    _add_button(list, "LOOK THROUGH THE IRIS", "witness", "Open the Witness experience")
    _add_button(list, "MEMORY ARCHIVE", "archive", "Open the Memory Archive")
    _add_button(list, "DISCOVERY SPACE", "discovery", "Open Discovery Space")
    _add_button(list, "WITNESS RECORD", "profile", "Open the Witness Record")
    _add_button(list, "CALIBRATION", "settings", "Open Iris Calibration")
    _add_button(list, "RETURN TO THE IRIS", "home", "Return to the Living Iris")
    _add_button(list, "CLOSE ACCESS PATH", "close", "Close explicit navigation")

func _add_button(parent: VBoxContainer, label_text: String, action_name: String, description: String) -> void:
    var button := Button.new()
    button.name = action_name.to_upper().replace(" ", "_")
    button.text = label_text
    button.tooltip_text = description
    button.custom_minimum_size = Vector2(0, 58)
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_font_size_override("font_size", 16)
    button.add_theme_color_override("font_color", Color("#dff4ee"))
    button.add_theme_color_override("font_hover_color", Color("#ffffff"))
    button.pressed.connect(_on_button_pressed.bind(action_name))
    parent.add_child(button)
    action_buttons.append(button)

func _on_button_pressed(action_name: String) -> void:
    action_requested.emit(action_name)

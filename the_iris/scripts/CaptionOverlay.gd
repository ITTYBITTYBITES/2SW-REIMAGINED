extends Control
class_name IrisCaptionOverlay

@onready var caption_label: Label = $Caption
var visible_caption := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_landscape(get_viewport_rect().size.x > get_viewport_rect().size.y)
    visible = false

func show_caption(text: String) -> void:
    caption_label.text = text
    visible_caption = true
    visible = true
    caption_label.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(caption_label, "modulate:a", 1.0, 0.18)

func set_landscape(is_landscape: bool) -> void:
    if is_landscape:
        caption_label.position = Vector2(48, get_viewport_rect().size.y - 84.0)
    else:
        caption_label.position = Vector2(48, 1030.0)

func hide_caption() -> void:
    if not visible_caption:
        return
    visible_caption = false
    var tween := create_tween()
    tween.tween_property(caption_label, "modulate:a", 0.0, 0.22)
    tween.tween_callback(func(): visible = false)

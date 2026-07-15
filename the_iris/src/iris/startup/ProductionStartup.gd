extends Control
class_name ProductionStartup

signal finished

@onready var publisher_mark: TextureRect = $PublisherMark
@onready var title_mark: TextureRect = $TitleMark
var active := true

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    publisher_mark.modulate.a = 0.0
    title_mark.modulate.a = 0.0
    _run_sequence()

func is_active() -> bool:
    return active

func _run_sequence() -> void:
    var tween := create_tween()
    tween.tween_property(publisher_mark, "modulate:a", 1.0, 0.30)
    tween.tween_interval(0.55)
    tween.tween_property(publisher_mark, "modulate:a", 0.0, 0.32)
    tween.tween_property(title_mark, "modulate:a", 1.0, 0.42)
    tween.tween_interval(0.72)
    tween.tween_property(title_mark, "modulate:a", 0.0, 0.48)
    tween.tween_callback(_finish_sequence)

func _finish_sequence() -> void:
    active = false
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    visible = false
    finished.emit()

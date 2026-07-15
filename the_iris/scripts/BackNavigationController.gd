extends Node
class_name IrisBackNavigationController

signal back_requested
var back_lock := false

func _ready() -> void:
    set_process_unhandled_input(true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_GO_BACK_REQUEST:
        _request_back()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
        _request_back()

func _request_back() -> void:
    if back_lock:
        return
    back_lock = true
    back_requested.emit()
    get_tree().create_timer(0.85).timeout.connect(func(): back_lock = false)

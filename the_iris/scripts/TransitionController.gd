extends Node
class_name IrisTransitionController

signal transition_started(kind: String)
signal transition_finished(kind: String)

@onready var overlay: IrisTransitionOverlay = $Overlay
var busy := false
var reduced_motion := false
var active_iris: IrisController

func _ready() -> void:
	overlay.visible = false
	overlay.set_aspect(get_viewport().get_visible_rect().size.x / max(get_viewport().get_visible_rect().size.y, 1.0))

func set_reduced_motion(value: bool) -> void:
	reduced_motion = value

func play_enter(iris: IrisController, switch_scene: Callable) -> void:
	if busy:
		return
	busy = true
	active_iris = iris
	Input.vibrate_handheld(18, 0.12)
	transition_started.emit("enter")
	overlay.visible = true
	overlay.modulate.a = 1.0
	overlay.set_mode(0.0)
	overlay.set_progress(0.0)
	iris.visible = true
	iris.set_transition_open(0.0)
	var tween := create_tween()
	var travel_duration := 0.26 if reduced_motion else 0.72
	var reveal_duration := 0.18 if reduced_motion else 0.50
	tween.tween_method(_drive_enter, 0.0, 1.0, travel_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(switch_scene)
	tween.tween_property(overlay, "modulate:a", 0.0, reveal_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_finish_enter.bind(iris))

func play_return(iris: IrisController, switch_scene: Callable) -> void:
	if busy:
		return
	busy = true
	active_iris = iris
	Input.vibrate_handheld(16, 0.10)
	transition_started.emit("return")
	overlay.visible = true
	overlay.modulate.a = 1.0
	overlay.set_mode(1.0)
	overlay.set_progress(0.0)
	iris.visible = true
	iris.set_transition_open(1.0)
	var tween := create_tween()
	var close_duration := 0.22 if reduced_motion else 0.62
	var reform_duration := 0.24 if reduced_motion else 0.68
	var reveal_duration := 0.12 if reduced_motion else 0.25
	tween.tween_method(overlay.set_progress, 0.0, 1.0, close_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(switch_scene)
	tween.tween_method(_drive_return, 1.0, 0.0, reform_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay, "modulate:a", 0.0, reveal_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_finish_return.bind(iris))

func _drive_enter(value: float) -> void:
	if is_instance_valid(active_iris):
		active_iris.set_transition_open(value)
	overlay.set_progress(value)

func _drive_return(value: float) -> void:
	if is_instance_valid(active_iris):
		active_iris.set_transition_open(value)

func _finish_enter(iris: IrisController) -> void:
	_finish("enter", iris)

func _finish_return(iris: IrisController) -> void:
	_finish("return", iris)

func _finish(kind: String, iris: IrisController) -> void:
	overlay.visible = false
	overlay.modulate.a = 1.0
	overlay.set_progress(0.0)
	iris.set_transition_open(0.0)
	busy = false
	active_iris = null
	transition_finished.emit(kind)

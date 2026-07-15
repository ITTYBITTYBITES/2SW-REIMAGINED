extends Node
class_name IrisInputIntentController

signal intent_requested(intent: int, position: Vector2, vector: Vector2, source: String)

var navigation: IrisNavigationController
var back_navigation: IrisBackNavigationController

func set_sources(navigation_source: IrisNavigationController, back_source: IrisBackNavigationController) -> void:
    navigation = navigation_source
    back_navigation = back_source
    navigation.tap.connect(_on_tap)
    navigation.hold.connect(_on_hold)
    navigation.swipe.connect(_on_swipe)
    navigation.return_requested.connect(_on_return)
    back_navigation.back_requested.connect(_on_return)

func _on_tap(position: Vector2) -> void:
    intent_requested.emit(IrisInputIntent.ENTER, position, Vector2.ZERO, "pointer")

func _on_hold(position: Vector2) -> void:
    intent_requested.emit(IrisInputIntent.FOCUS, position, Vector2.ZERO, "pointer")

func _on_swipe(direction: String) -> void:
    var intent := IrisInputIntent.EXPLORE_LEFT
    var vector := Vector2(-1.0, 0.0)
    match direction:
        "right":
            intent = IrisInputIntent.EXPLORE_RIGHT
            vector = Vector2(1.0, 0.0)
        "up":
            intent = IrisInputIntent.EXPLORE_UP
            vector = Vector2(0.0, -1.0)
        "down":
            intent = IrisInputIntent.EXPLORE_DOWN
            vector = Vector2(0.0, 1.0)
    intent_requested.emit(intent, get_viewport().get_mouse_position(), vector, "gesture")

func _on_return() -> void:
    intent_requested.emit(IrisInputIntent.RETURN, Vector2.ZERO, Vector2.ZERO, "system")

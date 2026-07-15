extends Node
class_name IrisNavigationController

signal tap(position: Vector2)
signal hold(position: Vector2)
signal swipe(direction: String)
signal return_requested
signal pointer_started(position: Vector2)
signal pointer_moved(position: Vector2)
signal pointer_ended(position: Vector2)
signal dragged(position: Vector2, delta: Vector2)
signal cursor_moved(position: Vector2)

const SWIPE_DISTANCE := 70.0
const HOLD_TIME := 0.62
const SYSTEM_GESTURE_MARGIN := 36.0
var tracking := false
var start_position := Vector2.ZERO
var current_position := Vector2.ZERO
var start_time := 0
var hold_sent := false
var controller_focus_sent := false
var last_controller_explore_ms := 0

func _viewport_size() -> Vector2:
    return get_viewport().get_visible_rect().size

func _ready() -> void:
    set_process_unhandled_input(true)
    set_process(true)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _begin(event.position)
        else:
            _finish(event.position)
    elif event is InputEventScreenDrag:
        if tracking:
            current_position = event.position
            pointer_moved.emit(current_position)
            dragged.emit(current_position, current_position - start_position)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                _begin(event.position)
            else:
                _finish(event.position)
        elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            return_requested.emit()
    elif event is InputEventMouseMotion:
        cursor_moved.emit(event.position)
        if tracking:
            current_position = event.position
            pointer_moved.emit(current_position)
            dragged.emit(current_position, current_position - start_position)
    elif event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_A:
            tap.emit(_viewport_size() * 0.5)
        elif event.button_index == JOY_BUTTON_B or event.button_index == JOY_BUTTON_BACK:
            return_requested.emit()
    elif event is InputEventJoypadMotion:
        _handle_controller_motion(event)
    elif event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_LEFT: swipe.emit("left")
            KEY_RIGHT: swipe.emit("right")
            KEY_UP: swipe.emit("up")
            KEY_DOWN: swipe.emit("down")
            KEY_SPACE: hold.emit(_viewport_size() * 0.5)
            KEY_ENTER, KEY_KP_ENTER: tap.emit(_viewport_size() * 0.5)
            KEY_ESCAPE: return_requested.emit()

func _handle_controller_motion(event: InputEventJoypadMotion) -> void:
    if event.axis == JOY_AXIS_TRIGGER_LEFT or event.axis == JOY_AXIS_TRIGGER_RIGHT:
        if event.axis_value > 0.45 and not controller_focus_sent:
            controller_focus_sent = true
            hold.emit(_viewport_size() * 0.5)
        elif event.axis_value < 0.25:
            controller_focus_sent = false
        return
    if event.axis != JOY_AXIS_LEFT_X and event.axis != JOY_AXIS_LEFT_Y:
        return
    if absf(event.axis_value) < 0.55:
        return
    var now := Time.get_ticks_msec()
    if now - last_controller_explore_ms < 420:
        return
    last_controller_explore_ms = now
    if event.axis == JOY_AXIS_LEFT_X:
        swipe.emit("right" if event.axis_value > 0.0 else "left")
    else:
        swipe.emit("down" if event.axis_value > 0.0 else "up")

func _process(_delta: float) -> void:
    if tracking and not hold_sent and Time.get_ticks_msec() - start_time >= int(HOLD_TIME * 1000.0):
        if start_position.distance_to(current_position) < SWIPE_DISTANCE * 0.75:
            hold_sent = true
            hold.emit(start_position)

func _begin(position: Vector2) -> void:
    var viewport_size := _viewport_size()
    if position.x <= SYSTEM_GESTURE_MARGIN or position.x >= viewport_size.x - SYSTEM_GESTURE_MARGIN:
        # Leave the outer edge to Android's system Back/gesture navigation.
        tracking = false
        return
    tracking = true
    hold_sent = false
    start_position = position
    current_position = position
    start_time = Time.get_ticks_msec()
    pointer_started.emit(position)
    pointer_moved.emit(position)

func _finish(position: Vector2) -> void:
    if not tracking:
        return
    current_position = position
    tracking = false
    pointer_moved.emit(position)
    pointer_ended.emit(position)
    var delta := position - start_position
    if delta.length() >= SWIPE_DISTANCE:
        if abs(delta.x) > abs(delta.y):
            swipe.emit("right" if delta.x > 0.0 else "left")
        else:
            swipe.emit("down" if delta.y > 0.0 else "up")
    elif not hold_sent:
        tap.emit(position)

extends Node
class_name DeviceCapabilityManager

signal capabilities_changed
signal motion_changed(acceleration: Vector3)

var has_touchscreen := false
var has_mouse := false
var has_keyboard := false
var has_controller := false
var has_motion_sensor := false
var has_audio := true
var platform_name := ""
var preferred_input := "touch"

func _ready() -> void:
    set_process_input(true)
    set_process(true)
    refresh()

func _process(_delta: float) -> void:
    if has_motion_sensor:
        motion_changed.emit(Input.get_accelerometer())

func refresh() -> void:
    platform_name = OS.get_name()
    has_touchscreen = DisplayServer.has_feature(DisplayServer.FEATURE_TOUCHSCREEN)
    has_mouse = DisplayServer.has_feature(DisplayServer.FEATURE_MOUSE)
    has_keyboard = not OS.has_feature("mobile")
    has_controller = not Input.get_connected_joypads().is_empty()
    has_audio = AudioServer.get_bus_count() > 0
    # Godot exposes sensor reads even where a device has no sensor. Mobile is
    # the useful conservative signal for this prototype; individual reads are
    # still available to future instrument behaviors.
    has_motion_sensor = OS.has_feature("mobile")
    preferred_input = "touch" if has_touchscreen else ("controller" if has_controller else "desktop")
    capabilities_changed.emit()

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        if not has_controller:
            has_controller = true
            preferred_input = "controller"
            capabilities_changed.emit()

extends Control
class_name ProductionDestinationHost

signal request_home
signal request_witness

@export var production_route := "experiences"

var bridge: TwoSecondWitnessProductionBridge
var active := false
var mounted_screen: Control

const ROUTE_SCENES := {
    "experiences": "res://src/ui/screens/ExperiencesScreen.tscn",
    "profile": "res://src/ui/screens/ProfileScreen.tscn",
    "settings": "res://src/ui/screens/SettingsScreen.tscn",
    "achievements": "res://src/ui/screens/AchievementsScreen.tscn",
    "programs": "res://src/ui/screens/ProgramsScreen.tscn",
    "about": "res://src/ui/screens/AboutScreen.tscn"
}

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 100
    if NavigationService and not NavigationService.route_changed.is_connected(_on_route_changed):
        NavigationService.route_changed.connect(_on_route_changed)

func set_production_bridge(value: TwoSecondWitnessProductionBridge) -> void:
    bridge = value

func enter() -> void:
    active = true
    visible = true
    if bridge and bridge.is_ready_for_gameplay() and NavigationService:
        NavigationService.navigate_to(production_route)

func exit() -> void:
    active = false
    visible = false
    _clear_screen()

func _on_route_changed(route: String, params: Dictionary) -> void:
    if not active:
        return
    if route in ["tutorial", "observation", "memory_question", "result"]:
        request_witness.emit()
    elif route == "home":
        request_home.emit()
    elif ROUTE_SCENES.has(route):
        _mount(route, params)

func _mount(route: String, params: Dictionary) -> void:
    _clear_screen()
    var path: String = ROUTE_SCENES[route]
    var packed: PackedScene = load(path)
    if packed == null:
        return
    mounted_screen = packed.instantiate() as Control
    if mounted_screen == null:
        return
    mounted_screen.name = "Production_%s" % route
    mounted_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mounted_screen.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(mounted_screen)
    if mounted_screen.has_method("on_navigated_to"):
        mounted_screen.call("on_navigated_to", params)

func _clear_screen() -> void:
    if is_instance_valid(mounted_screen):
        mounted_screen.queue_free()
    mounted_screen = null

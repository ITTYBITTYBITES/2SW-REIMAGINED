extends Node
class_name TwoSecondWitnessProductionBridge

signal ready_for_gameplay
signal boot_failed(reason: String)

var ready_for_gameplay_state := false
var boot_node: Node

func _ready() -> void:
    var boot_script: Script = load("res://src/core/app/AppBoot.gd")
    if boot_script == null:
        boot_failed.emit("Production AppBoot could not be loaded")
        return
    boot_node = boot_script.new()
    add_child(boot_node)
    if boot_node.has_signal("boot_completed"):
        boot_node.boot_completed.connect(_on_boot_completed)
    if boot_node.has_signal("boot_failed"):
        boot_node.boot_failed.connect(_on_boot_failed)
    boot_node.start_boot()

func _on_boot_completed() -> void:
    ready_for_gameplay_state = true
    ready_for_gameplay.emit()

func _on_boot_failed(reason: String) -> void:
    boot_failed.emit(reason)

func is_ready_for_gameplay() -> bool:
    return ready_for_gameplay_state

func return_to_iris() -> void:
    if ChallengeSessionService and ChallengeSessionService.has_active_session():
        ChallengeSessionService.return_home()
    elif NavigationService:
        NavigationService.navigate_to("home")

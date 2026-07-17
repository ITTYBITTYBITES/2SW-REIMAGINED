extends SceneTree
func _init() -> void:
    var scene = load("res://scenes/Main.tscn")
    if scene:
        print("Successfully loaded Main.tscn")
    else:
        print("Failed to load Main.tscn")
    quit()

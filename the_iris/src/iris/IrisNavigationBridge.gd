extends Node
class_name IrisNavigationBridge

## IrisNavigationBridge.gd — Connects existing navigation to Iris focus without owning routing.
## Example: Story Mode target -> Iris looks -> User selects -> Existing navigation executes.

signal destination_focused(key: String)
signal destination_selected(key: String)

func focus_destination(destination_key: String) -> void:
	destination_focused.emit(destination_key)

func select_destination(destination_key: String) -> void:
	destination_selected.emit(destination_key)
	match destination_key:
		"story_mode":
			if NavigationService:
				NavigationService.navigate_to("witness")
		"archive":
			if NavigationService:
				NavigationService.navigate_to("archive")
		"profile":
			if NavigationService:
				NavigationService.navigate_to("profile")
		"calibration":
			if NavigationService:
				NavigationService.navigate_to("settings")
		_:
			if NavigationService:
				NavigationService.navigate_to("home")

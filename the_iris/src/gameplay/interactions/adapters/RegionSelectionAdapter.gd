extends InteractionAdapter
class_name RegionSelectionInteractionAdapter

var _buttons: Array[Button] = []

func get_adapter_id() -> String:
	return "region_selection"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	var interaction_data: Dictionary = challenge_data.get("metadata", {}).get("interaction_data", {})
	var regions_value: Variant = interaction_data.get("regions", [])
	var regions: Array = regions_value if regions_value is Array else []
	for region_value: Variant in regions:
		if not (region_value is Dictionary):
			continue
		var region: Dictionary = region_value
		var button := Button.new()
		button.text = str(region.get("label", region.get("id", "Region")))
		button.custom_minimum_size = Vector2(0, 54)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(submit.bind({"region_id": str(region.get("id", "")), "input": "region_selection"}))
		target_host.add_child(button)
		_buttons.append(button)

func set_disabled(disabled: bool) -> void:
	for button: Button in _buttons:
		button.disabled = disabled

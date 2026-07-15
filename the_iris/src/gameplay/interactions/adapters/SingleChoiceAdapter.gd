extends InteractionAdapter
class_name SingleChoiceInteractionAdapter

var _buttons: Array[Button] = []

func get_adapter_id() -> String:
	return "single_choice"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	_buttons.clear()
	var options_value: Variant = challenge_data.get("answer_options", [])
	var options: Array = options_value if options_value is Array else []
	for option: Variant in options:
		var button := Button.new()
		button.text = str(option)
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ThemeService:
			ThemeService.apply_typography(button, "button")
		button.pressed.connect(_on_selected.bind(option))
		target_host.add_child(button)
		_buttons.append(button)

func _on_selected(option: Variant) -> void:
	submit(option)

func set_disabled(disabled: bool) -> void:
	for button: Button in _buttons:
		button.disabled = disabled

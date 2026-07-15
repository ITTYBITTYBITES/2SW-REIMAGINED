extends InteractionAdapter
class_name MultipleChoiceInteractionAdapter
## Generic exact-set collector. Family data declares only the required count;
## correctness and set meaning remain family-owned.

var _checks: Array[CheckButton] = []
var _submit_button: Button
var _status_label: Label
var _required_count: int = -1

func get_adapter_id() -> String:
	return "multiple_choice"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	_checks.clear()
	var metadata_value: Variant = challenge_data.get("metadata", {})
	var metadata: Dictionary = metadata_value if metadata_value is Dictionary else {}
	var interaction_value: Variant = metadata.get("interaction_data", {})
	var interaction_data: Dictionary = interaction_value if interaction_value is Dictionary else {}
	_required_count = int(interaction_data.get("selection_count", -1))
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var theme_service := target_host.get_node_or_null("/root/ThemeService")
	if theme_service:
		theme_service.call("apply_label_style", _status_label, "body_small", "text_secondary")
	target_host.add_child(_status_label)
	var options_value: Variant = challenge_data.get("answer_options", [])
	var options: Array = options_value if options_value is Array else []
	for option: Variant in options:
		var check := CheckButton.new()
		check.text = str(option)
		check.custom_minimum_size = Vector2(0, 52)
		check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		check.toggled.connect(_on_selection_changed.bind(check))
		if theme_service:
			theme_service.call("apply_typography", check, "body_small")
		target_host.add_child(check)
		_checks.append(check)
	_submit_button = Button.new()
	_submit_button.text = "CONFIRM SELECTION"
	_submit_button.custom_minimum_size = Vector2(0, 56)
	_submit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if theme_service:
		theme_service.call("apply_typography", _submit_button, "button")
	_submit_button.pressed.connect(_on_submit)
	target_host.add_child(_submit_button)
	_refresh_status()

func _on_selection_changed(pressed: bool, changed: CheckButton) -> void:
	var selected_count := _selected_values().size()
	if pressed and _required_count > 0 and selected_count > _required_count:
		changed.set_pressed_no_signal(false)
	_refresh_status()

func _on_submit() -> void:
	var selected := _selected_values()
	if selected.is_empty():
		return
	if _required_count > 0 and selected.size() != _required_count:
		return
	submit(selected)

func _selected_values() -> Array[String]:
	var selected: Array[String] = []
	for check: CheckButton in _checks:
		if check.button_pressed:
			selected.append(check.text)
	return selected

func _refresh_status() -> void:
	var selected_count := _selected_values().size()
	if _required_count > 0:
		_status_label.text = "Select exactly %d · %d selected" % [_required_count, selected_count]
		_submit_button.disabled = selected_count != _required_count
	else:
		_status_label.text = "%d selected" % selected_count
		_submit_button.disabled = selected_count == 0

func set_disabled(disabled: bool) -> void:
	for check: CheckButton in _checks:
		check.disabled = disabled
	if _submit_button:
		_submit_button.disabled = disabled

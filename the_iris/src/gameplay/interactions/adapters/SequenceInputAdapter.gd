extends InteractionAdapter
class_name SequenceInputInteractionAdapter

var _selected: Array[String] = []
var _token_buttons: Array[Button] = []
var _preview: Label
var _undo: Button
var _submit: Button
var _required_length: int = 1

func get_adapter_id() -> String:
	return "sequence_input"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	_selected.clear()
	_token_buttons.clear()
	var interaction_data: Dictionary = challenge_data.get("metadata", {}).get("interaction_data", {})
	var tokens_value: Variant = interaction_data.get("tokens", challenge_data.get("answer_options", []))
	var tokens: Array = tokens_value if tokens_value is Array else []
	_required_length = int(interaction_data.get("required_length", 1))
	_preview = Label.new()
	_preview.text = "Your sequence: —"
	_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if ThemeService:
		ThemeService.apply_label_style(_preview, "body", "text_secondary")
	target_host.add_child(_preview)
	var grid := GridContainer.new()
	grid.columns = mini(4, maxi(tokens.size(), 1))
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_host.add_child(grid)
	for token_value: Variant in tokens:
		var token: String = str(token_value)
		var button := Button.new()
		button.text = token
		button.custom_minimum_size = Vector2(64, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_token.bind(token))
		grid.add_child(button)
		_token_buttons.append(button)
	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_host.add_child(actions)
	_undo = Button.new()
	_undo.text = "UNDO"
	_undo.custom_minimum_size = Vector2(0, 52)
	_undo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_undo.pressed.connect(_on_undo)
	actions.add_child(_undo)
	_submit = Button.new()
	_submit.text = "SUBMIT"
	_submit.custom_minimum_size = Vector2(0, 52)
	_submit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_submit.disabled = true
	_submit.pressed.connect(_on_submit)
	actions.add_child(_submit)
	_refresh()

func _on_token(token: String) -> void:
	if _selected.size() >= _required_length:
		return
	_selected.append(token)
	_refresh()

func _on_undo() -> void:
	if not _selected.is_empty():
		_selected.pop_back()
	_refresh()

func _on_submit() -> void:
	if _selected.size() == _required_length:
		submit(_selected.duplicate())

func _refresh() -> void:
	_preview.text = "Your sequence: %s" % (" → ".join(_selected) if not _selected.is_empty() else "—")
	_submit.disabled = _selected.size() != _required_length
	_undo.disabled = _selected.is_empty()

func set_disabled(disabled: bool) -> void:
	for button: Button in _token_buttons:
		button.disabled = disabled
	if _undo:
		_undo.disabled = disabled
	if _submit:
		_submit.disabled = disabled

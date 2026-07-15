extends InteractionAdapter
class_name OrderingInteractionAdapter

var _items: Array[String] = []
var _list: VBoxContainer
var _submit: Button

func get_adapter_id() -> String:
	return "ordering"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	var interaction_data: Dictionary = challenge_data.get("metadata", {}).get("interaction_data", {})
	var items_value: Variant = interaction_data.get("items", challenge_data.get("answer_options", []))
	if items_value is Array:
		for value: Variant in items_value:
			_items.append(str(value))
	_list = VBoxContainer.new()
	target_host.add_child(_list)
	_submit = Button.new()
	_submit.text = "CONFIRM ORDER"
	_submit.custom_minimum_size = Vector2(0, 56)
	_submit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_submit.pressed.connect(_on_submit)
	target_host.add_child(_submit)
	_rebuild()

func _rebuild() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	for index: int in range(_items.size()):
		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = "%d. %s" % [index + 1, _items[index]]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var up := Button.new()
		up.text = "↑"
		up.disabled = index == 0
		up.pressed.connect(_move.bind(index, -1))
		row.add_child(up)
		var down := Button.new()
		down.text = "↓"
		down.disabled = index == _items.size() - 1
		down.pressed.connect(_move.bind(index, 1))
		row.add_child(down)
		_list.add_child(row)

func _move(index: int, delta: int) -> void:
	var destination: int = index + delta
	if destination < 0 or destination >= _items.size():
		return
	var value: String = _items[index]
	_items[index] = _items[destination]
	_items[destination] = value
	_rebuild()

func _on_submit() -> void:
	submit(_items.duplicate())

func set_disabled(disabled: bool) -> void:
	if _submit:
		_submit.disabled = disabled
	if _list:
		for child: Node in _list.get_children():
			for control: Node in child.get_children():
				if control is Button:
					(control as Button).disabled = disabled

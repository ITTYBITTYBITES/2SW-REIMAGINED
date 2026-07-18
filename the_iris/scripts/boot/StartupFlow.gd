extends Control
class_name StartupFlow

## The only boot sequence in the prototype: publisher mark, then title mark.
signal finished

var elapsed := 0.0
var complete := false
var publisher: TextureRect
var title: TextureRect

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new()
	backdrop.color = Color("#02050a")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	publisher = _mark("res://assets/splash/ittybittybites_splash.png")
	title = _mark("res://assets/splash/two_second_witness_splash.png")
	publisher.modulate.a = 0.0
	title.modulate.a = 0.0

func _process(delta: float) -> void:
	if complete:
		return
	elapsed += delta
	publisher.modulate.a = _fade(elapsed, 0.0, 1.10, 0.28)
	title.modulate.a = _fade(elapsed, 1.02, 2.45, 0.34)
	if elapsed >= 2.55:
		_finish()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_finish()
	elif event is InputEventScreenTouch and event.pressed:
		_finish()

func _mark(path: String) -> TextureRect:
	var mark := TextureRect.new()
	mark.texture = load(path)
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mark)
	return mark

func _fade(time: float, start: float, stop: float, ramp: float) -> float:
	if time < start or time > stop:
		return 0.0
	var in_amount := clampf((time - start) / ramp, 0.0, 1.0)
	var out_amount := clampf((stop - time) / ramp, 0.0, 1.0)
	return minf(in_amount, out_amount)

func _finish() -> void:
	if complete:
		return
	complete = true
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit()

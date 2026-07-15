extends Control
class_name EdgeGlow

var mode := "home"
var time := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_mode(value: String) -> void:
    mode = value
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    var size := get_viewport_rect().size
    var breath := 0.5 + sin(time * 0.75) * 0.18
    if mode == "home":
        draw_rect(Rect2(0, size.y * 0.34, 5, size.y * 0.32), Color(0.25, 0.72, 0.64, 0.035 + breath * 0.025))
        draw_rect(Rect2(size.x - 5, size.y * 0.34, 5, size.y * 0.32), Color(0.25, 0.72, 0.64, 0.035 + breath * 0.025))
        draw_rect(Rect2(size.x * 0.38, 0, size.x * 0.24, 4), Color(0.25, 0.72, 0.64, 0.025 + breath * 0.02))
        draw_rect(Rect2(size.x * 0.38, size.y - 4, size.x * 0.24, 4), Color(0.25, 0.72, 0.64, 0.025 + breath * 0.02))
        for i in range(3):
            var off := fmod(time * 18.0 + i * 23.0, 95.0)
            draw_line(Vector2(12 + off, size.y * 0.50), Vector2(35 + off, size.y * 0.50), Color(0.40, 0.82, 0.73, 0.20 - i * 0.04), 1.0)
            draw_line(Vector2(size.x - 12 - off, size.y * 0.50), Vector2(size.x - 35 - off, size.y * 0.50), Color(0.40, 0.82, 0.73, 0.20 - i * 0.04), 1.0)
    else:
        draw_rect(Rect2(0, 0, size.x, 3), Color(0.25, 0.72, 0.64, 0.025))
        draw_rect(Rect2(0, size.y - 3, size.x, 3), Color(0.25, 0.72, 0.64, 0.025))

extends BaseScreen
class_name FuturePlaceholder

signal request_home
signal request_witness
signal request_moment(moment_id: String)

@export var destination_key := "future"
@export var moment_id := ""
@export var title_text := "FUTURE EXPERIENCE"
@export var eyebrow_text := "A PLACE IS FORMING"
@export var description_text := "A future Witness experience will open here."
@export var progress_text := "SIGNAL UNAVAILABLE"
@export var action_text := "LOOK THROUGH THE IRIS"
@export var accent_color := Color("#63c8b2")
@export var action_enabled := false

var time := 0.0
var title_label: Label
var eyebrow_label: Label
var description_label: Label
var progress_label: Label
var action_label: Label

func _ready() -> void:
    super._ready()
    title_label = make_label(title_text, 27, INK, Vector2(34, 118), Vector2(652, 46), HORIZONTAL_ALIGNMENT_CENTER)
    eyebrow_label = make_label(eyebrow_text, 11, accent_color, Vector2(34, 84), Vector2(652, 26), HORIZONTAL_ALIGNMENT_CENTER)
    description_label = make_label(description_text, 15, MUTED, Vector2(76, 845), Vector2(568, 66), HORIZONTAL_ALIGNMENT_CENTER)
    description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    progress_label = make_label(progress_text, 12, DIM, Vector2(34, 978), Vector2(652, 30), HORIZONTAL_ALIGNMENT_CENTER)
    action_label = make_label(action_text, 13, accent_color, Vector2(34, 1120), Vector2(652, 34), HORIZONTAL_ALIGNMENT_CENTER)
    add_back_label("←  THE IRIS")
    queue_redraw()

func _on_viewport_resized(size: Vector2) -> void:
    if not is_instance_valid(title_label):
        return
    var landscape := size.x > size.y
    title_label.position = Vector2(34, 72 if landscape else 118)
    eyebrow_label.position = Vector2(34, 40 if landscape else 84)
    description_label.position = Vector2(76, maxf(420.0, size.y - 360.0))
    progress_label.position = Vector2(34, maxf(520.0, size.y - 225.0))
    action_label.position = Vector2(34, maxf(620.0, size.y - 82.0))

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    var size := get_viewport_rect().size
    draw_rect(Rect2(Vector2.ZERO, size), Color("#07131a"), true)
    var center := Vector2(size.x * 0.5, size.y * 0.50)
    var breathe := sin(time * 0.7) * 4.0
    draw_circle(center, 166.0 + breathe, Color(accent_color, 0.035))
    draw_arc(center, 142.0 + breathe, time * 0.06, time * 0.06 + 5.2, 96, Color(accent_color, 0.18), 1.0)
    draw_arc(center, 112.0, -time * 0.10, -time * 0.10 + 4.3, 96, Color(accent_color, 0.42), 2.0)
    draw_circle(center, 38.0 + sin(time * 0.9) * 2.0, Color(accent_color, 0.14 if not action_enabled else 0.28))
    draw_circle(center, 12.0, Color(accent_color, 0.65 if action_enabled else 0.38))
    match destination_key:
        "story_mode":
            _draw_story_language(center)
        "daily_witness":
            _draw_daily_language(center)
        "weekly_investigation":
            _draw_weekly_language(center)
        "your_iris":
            _draw_personal_language(center)
        "calibration":
            _draw_calibration_language(center)
        _:
            _draw_future_language(center)

func _draw_future_language(center: Vector2) -> void:
    for i in range(5):
        var angle := time * 0.05 + float(i) / 5.0 * TAU
        var radius := 184.0 + sin(time * 0.4 + i) * 7.0
        var point := center + Vector2(cos(angle), sin(angle)) * radius
        draw_circle(point, 3.5 if action_enabled else 2.5, Color(accent_color, 0.70 if action_enabled else 0.30))

func _draw_story_language(center: Vector2) -> void:
    for rank in range(3):
        var angle := -PI * 0.72 + float(rank) * 0.72 + time * 0.04
        var point := center + Vector2(cos(angle), sin(angle)) * (168.0 + rank * 22.0)
        draw_circle(point, 7.0, Color(accent_color, 0.78 if rank == 0 else 0.32))
        draw_line(center + Vector2(cos(angle), sin(angle)) * 82.0, point, Color(accent_color, 0.20), 1.0)
    draw_arc(center, 78.0, -PI * 0.80, PI * 0.04, 48, Color(accent_color, 0.68), 2.0)

func _draw_daily_language(center: Vector2) -> void:
    var today := Vector2(center.x + sin(time * 0.35) * 8.0, center.y - 12.0)
    draw_circle(today, 30.0 + sin(time * 0.8) * 3.0, Color(accent_color, 0.18))
    draw_circle(today, 9.0, Color(accent_color, 0.76))
    for i in range(7):
        var x := center.x - 72.0 + i * 24.0
        var active := i < 3
        draw_line(Vector2(x, center.y + 62.0), Vector2(x, center.y + 62.0 - (18.0 if active else 8.0)), Color(accent_color, 0.74 if active else 0.22), 3.0)

func _draw_weekly_language(center: Vector2) -> void:
    var points := PackedVector2Array()
    for i in range(5):
        var angle := -PI * 0.78 + float(i) * 0.39
        points.append(center + Vector2(cos(angle), sin(angle)) * (112.0 + i * 18.0))
    draw_polyline(points, Color(accent_color, 0.56), 2.0)
    for i in range(points.size()):
        draw_circle(points[i], 6.0 if i == 0 else 4.0, Color(accent_color, 0.78 if i == 0 else 0.36))

func _draw_personal_language(center: Vector2) -> void:
    for i in range(4):
        var radius := 58.0 + i * 34.0
        draw_arc(center, radius, -PI * 0.75 + i * 0.18, PI * 0.30 + i * 0.18, 64, Color(accent_color, 0.22 + i * 0.05), 1.5)
    draw_circle(center + Vector2(-20, -20), 8.0, Color(accent_color, 0.82))
    draw_line(center + Vector2(-12, -12), center + Vector2(42, 42), Color(accent_color, 0.24), 1.0)

func _draw_calibration_language(center: Vector2) -> void:
    for i in range(5):
        var offset := float(i - 2) * 22.0
        draw_line(center + Vector2(offset, -92.0), center + Vector2(offset, 92.0), Color(accent_color, 0.16), 1.0)
        draw_line(center + Vector2(-92.0, offset), center + Vector2(92.0, offset), Color(accent_color, 0.16), 1.0)
    draw_arc(center, 86.0, time * 0.10, time * 0.10 + PI * 0.65, 36, Color(accent_color, 0.72), 2.0)


func handle_tap(position: Vector2) -> void:
    if position.y < 100.0 and position.x < 330.0:
        request_home.emit()
        return
    var size := get_viewport_rect().size
    var center := Vector2(size.x * 0.5, size.y * 0.50)
    if action_enabled and position.distance_to(center) < minf(size.x, size.y) * 0.20:
        if not moment_id.is_empty():
            request_moment.emit(moment_id)
        else:
            request_witness.emit()

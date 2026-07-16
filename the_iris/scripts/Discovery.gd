extends BaseScreen
class_name DiscoveryScreen

signal request_home
signal request_future_destination(destination: String)

var time := 0.0
var selected := -1
var title_label: Label
var detail_label: Label
var nodes := [Vector2(0.18, 0.34), Vector2(0.42, 0.24), Vector2(0.73, 0.29), Vector2(0.58, 0.48), Vector2(0.28, 0.61), Vector2(0.80, 0.71), Vector2(0.48, 0.79)]
var names := ["STORY MODE", "DAILY WITNESS", "WEEKLY INVESTIGATION", "ARCHIVE", "YOUR IRIS", "CALIBRATION", "FUTURE SIGNAL"]
var destination_ids := ["story_mode", "daily_witness", "weekly_investigation", "archive", "your_iris", "calibration", "future"]

func _ready() -> void:
    super._ready()
    add_back_label("THE IRIS  ·  DISCOVERY")
    title_label = make_label("DISCOVERY SPACE", 26, INK, Vector2(32, 108), Vector2(656, 48))
    make_label("new signals gather where attention moves", 14, MUTED, Vector2(34, 157), Vector2(656, 32))
    detail_label = make_label("select a point to begin following it", 15, MUTED, Vector2(34, 1075), Vector2(656, 42), HORIZONTAL_ALIGNMENT_CENTER)
    queue_redraw()

func _on_viewport_resized(size: Vector2) -> void:
    if not is_instance_valid(detail_label):
        return
    detail_label.position = Vector2(34, maxf(620.0, size.y - 165.0))

func enter() -> void:
    selected = -1
    if ChallengeFamilyRegistry:
        var families: Array[String] = ChallengeFamilyRegistry.get_visible_family_ids()
        detail_label.text = "%02d  FUTURE SIGNALS  ·  challenge families gather behind them" % families.size()
    else:
        detail_label.text = "select a point to begin following it"
    queue_redraw()

func _process(delta: float) -> void:
    time += delta
    queue_redraw()

func _draw() -> void:
    var vs := get_viewport_rect().size
    draw_rect(Rect2(0, 0, size.x, size.y), Color("#07141a"))
    var center := Vector2(size.x * 0.50, size.y * 0.51)
    # Faint constellation connections.
    for i in nodes.size():
        var a := Vector2(nodes[i].x * size.x, nodes[i].y * size.y)
        for j in range(i + 1, nodes.size()):
            if (i + j) % 3 == 0:
                var b := Vector2(nodes[j].x * size.x, nodes[j].y * size.y)
                draw_line(a, b, Color(0.19, 0.51, 0.49, 0.14), 1.0)
    draw_circle(center, size.y * 0.26, Color(0.05, 0.24, 0.24, 0.14))
    draw_arc(center, size.y * 0.26, time * 0.04, time * 0.04 + 4.5, 48, Color(0.25, 0.65, 0.58, 0.25), 1.0)
    for i in nodes.size():
        var p := Vector2(nodes[i].x * size.x, nodes[i].y * size.y)
        var active := i == selected
        var radius := 7.0 if active else 4.0
        var col := Color("#e0b66d") if active else Color("#76d0ba")
        var breath := sin(time * 1.2 + i * 0.8) * 2.0
        draw_circle(p, radius + 13.0 + breath, Color(col, 0.04))
        draw_circle(p, radius + 5.0, Color(col, 0.12))
        draw_circle(p, radius, Color(col, 0.96))
        if active:
            draw_arc(p, 22.0 + breath, -time, -time + 5.2, 32, Color(col, 0.8), 1.0)
            draw_line(p, center, Color(0.80, 0.65, 0.37, 0.35), 1.0)

func handle_tap(position: Vector2) -> void:
    if position.y < 88.0 and position.x < 330.0:
        request_home.emit()
        return
    var vs := get_viewport_rect().size
    for i in nodes.size():
        var p := Vector2(nodes[i].x * size.x, nodes[i].y * size.y)
        if position.distance_to(p) < 58.0:
            selected = i
            detail_label.text = "%s  ·  keep moving toward it" % names[i]
            if destination_ids[i] != "future":
                request_future_destination.emit(destination_ids[i])
            queue_redraw()
            return

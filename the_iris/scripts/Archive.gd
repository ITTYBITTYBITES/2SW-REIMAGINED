extends BaseScreen
class_name ArchiveScreen

signal request_home
signal request_witness

@onready var production_host: ProductionDestinationHost = $ProductionDestinationHost
var production_bridge: TwoSecondWitnessProductionBridge
var production_active := false
var time := 0.0
var selected := -1
var title_label: Label
var detail_label: Label
var count_label: Label
var memory_points := [Vector2(0.23, 0.32), Vector2(0.67, 0.27), Vector2(0.48, 0.52), Vector2(0.76, 0.67), Vector2(0.25, 0.76)]
var memory_names := ["SECOND LIGHT", "QUIET EDGE", "BLUE HOUR", "UNSEEN PAIR", "AFTERIMAGE"]

func _ready() -> void:
    super._ready()
    add_back_label()
    title_label = make_label("MEMORY ARCHIVE", 26, INK, Vector2(32, 108), Vector2(656, 48))
    make_label("what you have seen, held as light", 14, MUTED, Vector2(34, 157), Vector2(656, 32))
    count_label = make_label("05  OPTICAL ARTIFACTS", 12, DIM, Vector2(34, 204), Vector2(656, 28))
    detail_label = make_label("tap a fragment to reopen its atmosphere", 15, MUTED, Vector2(34, 1075), Vector2(656, 42), HORIZONTAL_ALIGNMENT_CENTER)
    production_host.request_home.connect(_on_production_home)
    production_host.request_witness.connect(_on_production_witness)
    queue_redraw()

func set_production_bridge(value: TwoSecondWitnessProductionBridge) -> void:
    production_bridge = value
    production_host.set_production_bridge(value)

func _on_production_home() -> void:
    production_active = false
    production_host.exit()
    queue_redraw()

func _on_production_witness() -> void:
    request_witness.emit()

func _on_viewport_resized(size: Vector2) -> void:
    if not is_instance_valid(detail_label):
        return
    detail_label.position = Vector2(34, maxf(620.0, size.y - 165.0))

func enter() -> void:
    if production_bridge != null:
        production_active = true
        title_label.visible = false
        detail_label.visible = false
        count_label.visible = false
        production_host.enter()
        return
    production_active = false
    title_label.visible = true
    detail_label.visible = true
    count_label.visible = true
    selected = -1
    if PlayerProgressService:
        var history: Array[Dictionary] = PlayerProgressService.get_recent_history(5)
        for i in range(mini(history.size(), memory_names.size())):
            var family_title := str(history[i].get("family_title", "Witness Memory"))
            memory_names[i] = family_title.to_upper()
        detail_label.text = "%02d  WITNESS MEMORIES  ·  tap a fragment" % history.size()
    else:
        detail_label.text = "tap a fragment to reopen its atmosphere"
    queue_redraw()

func _process(delta: float) -> void:
    if production_active:
        return
    time += delta
    queue_redraw()

func _draw() -> void:
    var vs := get_viewport_rect().size
    draw_rect(Rect2(0, 0, vs.x, vs.y), Color("#0b1017"))
    draw_circle(Vector2(size.x * 0.5, size.y * 0.52), size.y * 0.34, Color(0.07, 0.16, 0.16, 0.18))
    for i in memory_points.size():
        var p := Vector2(memory_points[i].x * size.x, memory_points[i].y * size.y)
        var drift := Vector2(sin(time * (0.18 + i * 0.03) + i) * 9.0, cos(time * 0.23 + i) * 7.0)
        p += drift
        var active := i == selected
        var r := 34.0 if active else 25.0
        var base_col := Color("#c99e60") if active else Color("#4d9d91")
        for j in range(3, 0, -1):
            draw_circle(p, r + j * 9.0, Color(base_col, 0.018 * j))
        draw_circle(p, r, Color(base_col, 0.18 if not active else 0.31))
        draw_arc(p, r, time * 0.22 + i, time * 0.22 + i + 3.8, 48, Color(base_col, 0.72), 1.5)
        draw_arc(p, r * 0.63, -time * 0.34, -time * 0.34 + 4.2, 48, Color("#b8e8d5", 0.50), 1.0)
        draw_circle(p + Vector2(-r * 0.22, -r * 0.27), r * 0.18, Color("#e5f8ed", 0.60))
        if active:
            draw_circle(p, 4.0, Color("#ffe7aa"))
            draw_line(p, Vector2(size.x * 0.5, size.y * 0.93), Color(0.79, 0.63, 0.37, 0.32), 1.0)

func handle_tap(position: Vector2) -> void:
    if production_active:
        if position.y < 96.0 and position.x < 320.0:
            request_home.emit()
        return
    if position.y < 88.0 and position.x < 300.0:
        request_home.emit()
        return
    var vs := get_viewport_rect().size
    for i in memory_points.size():
        var p := Vector2(memory_points[i].x * size.x, memory_points[i].y * size.y)
        if position.distance_to(p) < 78.0:
            selected = i
            detail_label.text = "%s  ·  tap again to hold the scene" % memory_names[i]
            queue_redraw()
            return

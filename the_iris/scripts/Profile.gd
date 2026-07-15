extends BaseScreen
class_name ProfileScreen

signal request_home
signal request_witness

@onready var production_host: ProductionDestinationHost = $ProductionDestinationHost
var production_bridge: TwoSecondWitnessProductionBridge
var production_active := false
var time := 0.0
var state_manager: IrisStateManager
var stat_label: Label
var score_label: Label
var footer_label: Label

func _ready() -> void:
    super._ready()
    add_back_label("THE IRIS  ·  RECORD")
    make_label("WITNESS RECORD", 26, INK, Vector2(32, 108), Vector2(656, 48))
    make_label("the instrument grows by what you choose to notice", 14, MUTED, Vector2(34, 157), Vector2(656, 32))
    stat_label = make_label("", 15, INK, Vector2(34, 940), Vector2(656, 50), HORIZONTAL_ALIGNMENT_CENTER)
    score_label = make_label("", 13, MUTED, Vector2(34, 995), Vector2(656, 34), HORIZONTAL_ALIGNMENT_CENTER)
    footer_label = make_label("swipe to move  ·  tap the record to return", 12, DIM, Vector2(34, 1166), Vector2(656, 30), HORIZONTAL_ALIGNMENT_CENTER)
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
    if not is_instance_valid(stat_label):
        return
    stat_label.position = Vector2(34, maxf(500.0, size.y - 255.0))
    score_label.position = Vector2(34, maxf(545.0, size.y - 200.0))
    footer_label.position = Vector2(34, maxf(620.0, size.y - 68.0))

func set_state_manager(value: IrisStateManager) -> void:
    state_manager = value
    _refresh_copy()

func enter() -> void:
    if production_bridge != null:
        production_active = true
        stat_label.visible = false
        score_label.visible = false
        footer_label.visible = false
        production_host.enter()
        return
    production_active = false
    stat_label.visible = true
    score_label.visible = true
    footer_label.visible = true
    _refresh_copy()
    queue_redraw()

func _refresh_copy() -> void:
    if not is_instance_valid(stat_label):
        return
    var observations := state_manager.completed_observations if state_manager else 0
    var score := state_manager.attention_score if state_manager else 0
    var discoveries := state_manager.discovery_count if state_manager else 0
    if PlayerProgressService:
        var record: Dictionary = PlayerProgressService.get_observation_record()
        observations = int(record.get("total_plays", observations))
        discoveries = int(record.get("correct", discoveries))
        score = int(roundf(float(record.get("accuracy", 0.0)) * 100.0))
    stat_label.text = "%02d  OBSERVATIONS       %02d  DISCOVERIES" % [observations, discoveries]
    score_label.text = "ATTENTION  %02d / 100" % score

func _process(delta: float) -> void:
    if production_active:
        return
    time += delta
    queue_redraw()

func _draw() -> void:
    if production_active:
        return
    var size := get_viewport_rect().size
    draw_rect(Rect2(0, 0, size.x, size.y), Color("#09131a"))
    var center := Vector2(size.x * 0.5, size.y * 0.52)
    var score := float(state_manager.attention_score if state_manager else 0) / 100.0
    for i in range(5, 0, -1):
        draw_arc(center, 150.0 + i * 22.0, -PI * 0.78, PI * 0.22, 64, Color(0.25, 0.66, 0.58, 0.05 + i * 0.012), 1.0)
    draw_arc(center, 150.0, -PI * 0.78, -PI * 0.78 + TAU * (0.12 + score * 0.76), 64, Color("#70cdb8"), 4.0)
    draw_circle(center, 116.0, Color(0.06, 0.17, 0.18, 0.72))
    draw_circle(center, 95.0 + sin(time * 0.7) * 3.0, Color(0.08, 0.25, 0.25, 0.65))
    draw_arc(center, 75.0, time * 0.12, time * 0.12 + 4.8, 48, Color("#b5dfc9"), 2.0)
    draw_circle(center + Vector2(-23, -24), 16.0, Color(0.76, 0.96, 0.87, 0.35))
    draw_circle(center, 35.0, Color("#041018"))
    draw_circle(center, 30.0, Color(0.10, 0.35, 0.33, 0.72))
    var node_count := state_manager.discovery_count if state_manager else 0
    for i in range(8):
        var a := float(i) / 8.0 * TAU + time * 0.08
        var r := 198.0 + sin(time * 0.4 + i) * 8.0
        var p := center + Vector2(cos(a), sin(a)) * r
        var node_col := Color("#d1a866") if i < node_count else Color("#3b6765")
        draw_circle(p, 4.0 if i < node_count else 2.5, node_col)
        if i < node_count:
            draw_line(center + Vector2(cos(a), sin(a)) * 135.0, p, Color(node_col, 0.28), 1.0)

extends BaseScreen
class_name WitnessModeScreen

signal request_home
signal request_action(action: String)

@onready var visual: ColorRect = $Visual
@onready var scene_canvas: WitnessCanvas = $WitnessCanvas
@onready var production_host: ProductionWitnessHost = $ProductionWitnessHost
var production_bridge: TwoSecondWitnessProductionBridge
var production_active := false
var runtime_active := false
var elapsed := 0.0
var progress := 0.0
var completed := false
var pulse_count := 0
var title_label: Label
var status_label: Label
var timer_label: Label
var footer_label: Label
var return_label: Label

func _ready() -> void:
    super._ready()
    title_label = make_label("WITNESS MODE", 15, TEAL, Vector2(32, 94), Vector2(300, 30))
    status_label = make_label("Hold steady. Let the field settle.", 20, INK, Vector2(32, 132), Vector2(656, 42))
    timer_label = make_label("OBSERVE", 12, MUTED, Vector2(32, 181), Vector2(656, 26))
    footer_label = make_label("attention is an instrument", 13, DIM, Vector2(32, 1162), Vector2(656, 28), HORIZONTAL_ALIGNMENT_CENTER)
    return_label = make_label("tap here to return  ·  swipe to move", 12, MUTED, Vector2(32, 1200), Vector2(656, 28), HORIZONTAL_ALIGNMENT_CENTER)
    return_label.modulate.a = 0.0
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("aspect", get_viewport_rect().size.x / max(get_viewport_rect().size.y, 1.0))
    production_host.request_home.connect(_on_production_home)

func set_production_bridge(value: TwoSecondWitnessProductionBridge) -> void:
    production_bridge = value
    production_host.set_production_bridge(value)

func get_production_host() -> ProductionWitnessHost:
    return production_host

func set_runtime_active(value: bool) -> void:
    runtime_active = value

func _on_production_home() -> void:
    production_active = false
    production_host.exit()
    visual.visible = true
    scene_canvas.visible = true

func _on_viewport_resized(new_size: Vector2) -> void:
    if not is_instance_valid(title_label):
        return
    var compact_top := 70.0 if new_size.x > new_size.y else 94.0
    title_label.position = Vector2(32, compact_top)
    status_label.position = Vector2(32, compact_top + 38.0)
    timer_label.position = Vector2(32, compact_top + 86.0)
    footer_label.position = Vector2(32, maxf(560.0, new_size.y - 118.0))
    return_label.position = Vector2(32, maxf(600.0, new_size.y - 78.0))

func enter() -> void:
    if production_bridge != null:
        production_active = true
        visual.visible = false
        scene_canvas.visible = false
        title_label.visible = false
        status_label.visible = false
        timer_label.visible = false
        footer_label.visible = false
        return_label.visible = false
        if not runtime_active:
            production_host.enter()
        return
    production_active = false
    visual.visible = true
    scene_canvas.visible = true
    title_label.visible = true
    status_label.visible = true
    timer_label.visible = true
    footer_label.visible = true
    return_label.visible = true
    elapsed = 0.0
    progress = 0.0
    completed = false
    pulse_count = 0
    status_label.text = "Hold steady. Let the field settle."
    timer_label.text = "OBSERVE  ·  05"
    return_label.modulate.a = 0.0
    scene_canvas.set_reveal(0.0)
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("focus", 0.0)
        shader_material.set_shader_parameter("reveal", 0.0)

func _process(delta: float) -> void:
    if not visible or production_active or runtime_active:
        return
    elapsed += delta
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        var viewport_size := get_viewport_rect().size
        shader_material.set_shader_parameter("aspect", viewport_size.x / max(viewport_size.y, 1.0))
        shader_material.set_shader_parameter("time", elapsed)
    if not completed:
        progress = clampf(elapsed / 5.2, 0.0, 1.0)
        var remaining := maxi(0, ceili(5.2 - elapsed))
        timer_label.text = "OBSERVE  ·  %02d" % remaining
        if shader_material:
            shader_material.set_shader_parameter("focus", progress)
        scene_canvas.set_reveal(maxf(0.0, (progress - 0.72) / 0.28))
        if progress >= 1.0:
            _complete()

func _complete() -> void:
    completed = true
    status_label.text = "You noticed what was already there."
    timer_label.text = "DISCOVERY  ·  SECOND LIGHT"
    footer_label.text = "a small detail changed the whole field"
    return_label.modulate.a = 1.0
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("reveal", 1.0)
    request_action.emit("completed")

func handle_tap(tap_position: Vector2) -> void:
    if production_active:
        if tap_position.y < 96.0 and tap_position.x < 320.0:
            request_home.emit()
        return
    if tap_position.y < 90.0 and tap_position.x < 300.0:
        request_home.emit()
    elif completed and tap_position.y > 1080.0:
        request_home.emit()
    else:
        pulse_count += 1
        if pulse_count > 2 and not completed:
            status_label.text = "Good. Keep looking without chasing it."

func pulse_focus() -> void:
    if not completed:
        status_label.text = "Focus held. The aperture is listening."

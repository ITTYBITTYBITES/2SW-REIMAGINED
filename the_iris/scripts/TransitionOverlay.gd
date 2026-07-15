extends Control
class_name IrisTransitionOverlay

@onready var visual: ColorRect = $Visual
var transition_progress := 0.0
var transition_mode := 0.0
var elapsed := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("aspect", get_viewport_rect().size.x / max(get_viewport_rect().size.y, 1.0))
        shader_material.set_shader_parameter("progress", 0.0)
        shader_material.set_shader_parameter("transition_mode", 0.0)

func _process(delta: float) -> void:
    if visible:
        elapsed += delta
        var shader_material := visual.material as ShaderMaterial
        if shader_material:
            shader_material.set_shader_parameter("time", elapsed)

func set_progress(value: float) -> void:
    transition_progress = clampf(value, 0.0, 1.0)
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("progress", transition_progress)

func set_mode(value: float) -> void:
    transition_mode = value
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("transition_mode", transition_mode)

func set_aspect(value: float) -> void:
    var shader_material := visual.material as ShaderMaterial
    if shader_material:
        shader_material.set_shader_parameter("aspect", value)

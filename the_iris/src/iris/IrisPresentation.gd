extends Node
class_name IrisPresentation

## IrisPresentation.gd — Owns mesh animation, shader parameters, and visual responses.
## Connects rank -> shader -> appearance.

@export var target_material: ShaderMaterial
@export var iris_controller: Node

func update_presentation(behavior: Dictionary, progression_level: int) -> void:
	if not target_material:
		return
	var glow := float(behavior.get("glow_multiplier", 1.0)) * (0.8 + float(progression_level) * 0.1)
	var pupil := float(behavior.get("pupil_dilation", 0.105))
	
	target_material.set_shader_parameter("energy", glow)
	target_material.set_shader_parameter("pupil_open", pupil)
	target_material.set_shader_parameter("progression_level", float(progression_level))
	
	if iris_controller and iris_controller.has_method("set_animation_intensity"):
		iris_controller.call("set_animation_intensity", float(behavior.get("breathing_rate", 1.0)))

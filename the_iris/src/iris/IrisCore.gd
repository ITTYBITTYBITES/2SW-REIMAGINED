extends Node
class_name IrisCore

## IrisCore.gd — Manages the behavioral state machine for Living Iris 4.0.
## Owns states: DORMANT, AWARE, FOCUSED, SETTLED.

enum State { DORMANT, AWARE, FOCUSED, SETTLED }

signal state_changed(new_state: State)

@export var current_state: State = State.DORMANT
var state_time := 0.0

func _ready() -> void:
	transition_to(State.DORMANT)

func transition_to(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_time = 0.0
	state_changed.emit(current_state)

func update_behavior(delta: float) -> Dictionary:
	state_time += delta
	var behavior_params := {
		"state": current_state,
		"state_time": state_time,
		"pupil_dilation": 0.105,
		"glow_multiplier": 1.0,
		"breathing_rate": 1.0,
		"idle_movement": 1.0,
		"focus_energy": 0.0
	}
	
	match current_state:
		State.DORMANT:
			behavior_params["pupil_dilation"] = 0.115 + sin(state_time * 0.70) * 0.005
			behavior_params["glow_multiplier"] = 0.75 + sin(state_time * 0.70) * 0.05
			behavior_params["breathing_rate"] = 0.70
			behavior_params["idle_movement"] = 0.4
			behavior_params["focus_energy"] = 0.05
		State.AWARE:
			behavior_params["pupil_dilation"] = 0.100 + sin(state_time * 1.20) * 0.008
			behavior_params["glow_multiplier"] = 1.15 + sin(state_time * 1.20) * 0.1
			behavior_params["breathing_rate"] = 1.20
			behavior_params["idle_movement"] = 1.0
			behavior_params["focus_energy"] = 0.35
		State.FOCUSED:
			behavior_params["pupil_dilation"] = 0.082
			behavior_params["glow_multiplier"] = 1.45
			behavior_params["breathing_rate"] = 1.50
			behavior_params["idle_movement"] = 0.15
			behavior_params["focus_energy"] = 0.62
		State.SETTLED:
			behavior_params["pupil_dilation"] = 0.108 + sin(state_time * 0.85) * 0.006
			behavior_params["glow_multiplier"] = 0.90 + sin(state_time * 0.85) * 0.08
			behavior_params["breathing_rate"] = 0.85
			behavior_params["idle_movement"] = 0.6
			behavior_params["focus_energy"] = 0.18
			
	return behavior_params
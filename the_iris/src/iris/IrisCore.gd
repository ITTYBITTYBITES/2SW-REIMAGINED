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
		"breathing_rate": 1.0
	}
	
	match current_state:
		State.DORMANT:
			behavior_params["pupil_dilation"] = 0.115
			behavior_params["glow_multiplier"] = 0.75
			behavior_params["breathing_rate"] = 0.70
		State.AWARE:
			behavior_params["pupil_dilation"] = 0.100
			behavior_params["glow_multiplier"] = 1.15
			behavior_params["breathing_rate"] = 1.20
		State.FOCUSED:
			behavior_params["pupil_dilation"] = 0.082
			behavior_params["glow_multiplier"] = 1.45
			behavior_params["breathing_rate"] = 1.50
		State.SETTLED:
			behavior_params["pupil_dilation"] = 0.108
			behavior_params["glow_multiplier"] = 0.90
			behavior_params["breathing_rate"] = 0.85
			
	return behavior_params

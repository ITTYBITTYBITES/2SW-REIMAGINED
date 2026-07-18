extends Node
class_name IrisCore

## Small state model for the procedural Living Iris. It describes only the iris' current behavior.
enum State { DORMANT, AWARE, FOCUSED, SETTLED }

signal state_changed(state: State)

var state: State = State.DORMANT
var state_time := 0.0

func transition_to(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_time = 0.0
	state_changed.emit(state)

func tick(delta: float) -> Dictionary:
	state_time += delta
	match state:
		State.DORMANT:
			return {"breath": 0.65, "glow": 0.45, "pupil": 0.32, "gaze": Vector2.ZERO}
		State.AWARE:
			return {"breath": 1.00, "glow": 0.75, "pupil": 0.27, "gaze": Vector2(0.015, -0.008)}
		State.FOCUSED:
			return {"breath": 1.35, "glow": 1.00, "pupil": 0.21, "gaze": Vector2(0.0, -0.02)}
		State.SETTLED:
			return {"breath": 0.78, "glow": 0.60, "pupil": 0.29, "gaze": Vector2(-0.01, 0.006)}
	return {}

extends Node
class_name WitnessMomentOrchestrator

## A compact five-phase player for a completed Witness Moment. It owns only
## the active session; completion is reported to IncidentRegistry by the app.
enum Phase { ARRIVING, OBSERVING, RECONSTRUCTING, INVESTIGATING, REVEALING }

signal phase_changed(phase: Phase, moment: Dictionary)
signal moment_completed(moment_id: String)

var active: Dictionary = {}
var phase: Phase = Phase.ARRIVING

func start(launch: Dictionary) -> bool:
	if launch.is_empty() or not launch.has("moment"):
		return false
	active = launch.duplicate(true)
	phase = Phase.ARRIVING
	phase_changed.emit(phase, current_moment())
	return true

func advance() -> void:
	if active.is_empty():
		return
	if phase == Phase.REVEALING:
		var id := str(active.get("moment_id", ""))
		moment_completed.emit(id)
		return
	phase = (int(phase) + 1) as Phase
	phase_changed.emit(phase, current_moment())

func cancel() -> void:
	active.clear()
	phase = Phase.ARRIVING

func current_moment() -> Dictionary:
	var data: Dictionary = active.get("moment", {})
	return data.duplicate(true)

func phase_name() -> String:
	return ["ARRIVING", "OBSERVING", "RECONSTRUCTING", "INVESTIGATING", "REVEALING"][int(phase)]

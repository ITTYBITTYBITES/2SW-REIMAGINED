extends Node
class_name WitnessExperienceDirector

## The mode-facing selector. It asks the registry for a requested completed
## Witness Moment and returns the small launch contract used by the runtime.
var registry: IncidentRegistry

func configure(value: IncidentRegistry) -> void:
	registry = value

func chapter_moments() -> Array[Dictionary]:
	if registry == null:
		return []
	return registry.chapter_moments()

func launch(moment_id: String) -> Dictionary:
	if registry == null:
		return {}
	var selected := registry.moment(moment_id)
	if selected.is_empty():
		return {}
	return {
		"incident_id": selected["incident_id"],
		"moment_id": selected["id"],
		"moment": selected
	}

extends RefCounted
class_name WitnessFracture

## Canonical Living Iris fracture contract. A legacy anomaly_definition and
## capture_window are adapted into one fracture so old moments remain playable.
var fracture_id := "primary_fracture"
var location := {"x": 350.0, "y": 366.0}
var size := {"x": 94.0, "y": 94.0}
var discovery_state := false
var synchronization_state := false
var reveal_state := false
var truth_fragment_reward := ""
var discovery_text := "Find the impossible detail."
var misstep_text := "Not there. Watch closely."
var synchronization := {
	"hold_duration": 1.0,
	"stability_recovery": 1.0,
	"audio": "res://assets/audio/iris/iris_focus.ogg",
	"haptic": "light"
}

func from_dictionary(data: Dictionary, fallback_id := "primary_fracture") -> void:
	fracture_id = str(data.get("fracture_id", data.get("id", fallback_id)))
	location = _dictionary(data.get("location", location))
	size = _dictionary(data.get("size", size))
	discovery_text = str(data.get("discovery_text", data.get("success_text", discovery_text)))
	misstep_text = str(data.get("misstep_text", misstep_text))
	truth_fragment_reward = str(data.get("truth_fragment_reward", ""))
	if data.get("synchronization", {}) is Dictionary:
		synchronization.merge(data.get("synchronization", {}), true)

static func from_legacy(anomaly_definition: Dictionary, capture_window: Dictionary, fallback_id := "primary_fracture") -> WitnessFracture:
	var fracture := WitnessFracture.new()
	fracture.from_dictionary({
		"fracture_id": fallback_id,
		"location": anomaly_definition.get("location", fracture.location),
		"size": anomaly_definition.get("size", fracture.size),
		"success_text": anomaly_definition.get("success_text", "You found the fracture."),
		"misstep_text": anomaly_definition.get("misstep_text", fracture.misstep_text),
		"synchronization": {
			"hold_duration": float(capture_window.get("hold_duration", 0.26)),
			"stability_recovery": 1.0,
			"audio": "res://assets/audio/iris/iris_focus.ogg",
			"haptic": "light"
		}
	}, fallback_id)
	return fracture

func to_dictionary() -> Dictionary:
	return {
		"fracture_id": fracture_id,
		"location": location.duplicate(true),
		"size": size.duplicate(true),
		"discovery_state": discovery_state,
		"synchronization_state": synchronization_state,
		"reveal_state": reveal_state,
		"truth_fragment_reward": truth_fragment_reward,
		"discovery_text": discovery_text,
		"misstep_text": misstep_text,
		"synchronization": synchronization.duplicate(true)
	}

static func _dictionary(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

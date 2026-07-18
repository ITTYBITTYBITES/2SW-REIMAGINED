extends RefCounted
class_name WitnessMomentResult

## Result contract for a real Witness gameplay loop. The existing protected
## profile accepts this dictionary without requiring runtime changes.
var moment_id := ""
var accuracy := 0.0
var anomalies_found := 0
var anomalies_total := 0
var assistance_used := false
var mastery := false
var observation_style := ""

func _init(id := "", accuracy_value := 0.0, found := 0, total := 0, used_assistance := false, mastery_value := false, style := "") -> void:
	moment_id = id
	accuracy = clampf(accuracy_value, 0.0, 1.0)
	anomalies_found = maxi(found, 0)
	anomalies_total = maxi(total, 0)
	assistance_used = used_assistance
	mastery = mastery_value
	observation_style = style

func to_dictionary() -> Dictionary:
	return {
		"accuracy": accuracy,
		"anomalies_found": anomalies_found,
		"anomalies_total": anomalies_total,
		"assistance_used": assistance_used,
		"mastery": mastery,
		"observation_style": observation_style
	}

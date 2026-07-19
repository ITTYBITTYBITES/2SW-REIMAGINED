extends RefCounted
class_name WitnessMomentDefinition

## Structured, backward-compatible Witness definition. Mission 055 adds Living
## Iris fields while preserving the anomaly/capture contract consumed by legacy data.
var moment_id := ""
var incident_id := ""
var title := ""
var subtitle := ""
var description := ""
var observation_duration := 2.0
var background_path := ""
var action_path := ""
var reveal_path := ""
var asset_manifest: WitnessAssetManifest

# Legacy compatibility fields: do not remove while old JSON is in circulation.
var anomaly_definition: Dictionary = {}
var capture_window: Dictionary = {}

# Living Iris 4.0 additive contract.
var fractures: Array[WitnessFracture] = []
var memory_stability := {
	"initial": 1.0,
	"collapse_at": 0.0,
	"idle_drain_per_second": 0.08,
	"misstep_cost": 0.15,
	"recovery_on_synchronization": 1.0
}
var truth_fragment := {
	"truth_fragment_id": "",
	"title": "Recovered Truth",
	"summary": "Something hidden has returned.",
	"revelation_text": "",
	"revelation_audio_hook": "res://assets/audio/witness/resolution.ogg",
	"archive_entry": ""
}
var iris_guidance := {
	"fracture_discovered_event": "memory_focus",
	"fracture_resolved_event": "truth_fragment_absorbed"
}
# Optional authored presentation tuning. Empty for all non-showcase moments.
var showcase: Dictionary = {}

var evidence_nodes: Array[Dictionary] = []
var resolution_text := ""
var reward_definition: Dictionary = {}

func from_dictionary(dict: Dictionary) -> void:
	moment_id = str(dict.get("moment_id", dict.get("id", "")))
	incident_id = str(dict.get("incident_id", ""))
	title = str(dict.get("title", ""))
	subtitle = str(dict.get("subtitle", ""))
	description = str(dict.get("description", dict.get("introduction", "")))
	observation_duration = float(dict.get("observation_duration", 2.0))
	background_path = str(dict.get("background_path", dict.get("background", "")))
	action_path = str(dict.get("action_path", dict.get("action", "")))
	reveal_path = str(dict.get("reveal_path", dict.get("reveal", "")))

	anomaly_definition = _dictionary(dict.get("anomaly_definition", {}))
	if anomaly_definition.is_empty():
		anomaly_definition = {"location": {"x": 350.0, "y": 366.0}, "size": {"x": 94.0, "y": 94.0}, "misstep_text": "Not there. Watch closely.", "success_text": "You found the fracture."}
	capture_window = _dictionary(dict.get("capture_window", {}))
	if capture_window.is_empty():
		capture_window = {"hold_duration": 0.26, "guidance_text": "HOLD TO STABILIZE THE FRACTURE.", "success_text": "The fracture holds."}

	_load_fractures(dict)
	_merge_contract(memory_stability, dict.get("memory_stability", {}))
	_load_truth_fragment(dict)
	_merge_contract(iris_guidance, dict.get("iris_guidance", {}))
	showcase = _dictionary(dict.get("showcase", {}))

	evidence_nodes.clear()
	var raw_nodes = dict.get("evidence_nodes", [])
	if raw_nodes is Array:
		for node in raw_nodes:
			if node is Dictionary:
				var clean_node: Dictionary = (node as Dictionary).duplicate(true)
				clean_node["asset_reference"] = str(clean_node.get("asset_reference", ""))
				clean_node["visual_effect"] = str(clean_node.get("visual_effect", "default"))
				clean_node["color_modulation"] = str(clean_node.get("color_modulation", "#dff8ef"))
				evidence_nodes.append(clean_node)
	else:
		var attunements = dict.get("attunements", [])
		if attunements is Array:
			for index in range(attunements.size()):
				evidence_nodes.append({"identifier": "node_%d" % index, "description": str(attunements[index]), "relevance": "Detail attunement.", "truth_connection": "Underlying connection restored.", "asset_reference": "", "visual_effect": "default", "color_modulation": "#dff8ef"})

	resolution_text = str(dict.get("resolution_text", dict.get("revelation", "")))
	truth_fragment["revelation_text"] = str(truth_fragment.get("revelation_text", resolution_text))
	if str(truth_fragment.get("revelation_text", "")).is_empty():
		truth_fragment["revelation_text"] = resolution_text
	reward_definition = _dictionary(dict.get("reward_definition", {}))
	if reward_definition.is_empty():
		reward_definition = {"base_resonance": 20, "accuracy_multiplier": 15.0, "unassisted_bonus": 6}

	asset_manifest = WitnessAssetManifest.new()
	if dict.get("asset_manifest", {}) is Dictionary:
		asset_manifest.from_dictionary(dict, moment_id)
	else:
		asset_manifest.build_fallback_manifest(self)

func primary_fracture() -> WitnessFracture:
	return fractures[0] if not fractures.is_empty() else WitnessFracture.from_legacy(anomaly_definition, capture_window, "%s_primary" % moment_id)

func _load_fractures(dict: Dictionary) -> void:
	fractures.clear()
	var raw_fractures = dict.get("fractures", [])
	if raw_fractures is Array:
		for index in range(raw_fractures.size()):
			if raw_fractures[index] is Dictionary:
				var fracture := WitnessFracture.new()
				fracture.from_dictionary(raw_fractures[index], "%s_fracture_%d" % [moment_id, index + 1])
				fractures.append(fracture)
	if fractures.is_empty():
		fractures.append(WitnessFracture.from_legacy(anomaly_definition, capture_window, "%s_primary" % moment_id))

func _load_truth_fragment(dict: Dictionary) -> void:
	var source = dict.get("truth_fragment", {})
	if source is Dictionary:
		_merge_contract(truth_fragment, source)
	truth_fragment["truth_fragment_id"] = str(truth_fragment.get("truth_fragment_id", "%s_truth" % moment_id))
	if str(truth_fragment["truth_fragment_id"]).is_empty():
		truth_fragment["truth_fragment_id"] = "%s_truth" % moment_id
	if str(truth_fragment.get("archive_entry", "")).is_empty():
		truth_fragment["archive_entry"] = str(truth_fragment.get("summary", "Something hidden has returned."))

static func _merge_contract(target: Dictionary, source: Variant) -> void:
	if source is Dictionary:
		target.merge(source, true)

static func _dictionary(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}

extends RefCounted
class_name WitnessMomentDefinition

## Structured representation of a generic, data-driven Witness Moment.
## Generated dynamically by WitnessContentLoader from JSON resources.

var moment_id := ""
var incident_id := ""
var title := ""
var subtitle := ""
var description := ""
var observation_duration := 2.0
var background_path := ""
var action_path := ""
var reveal_path := ""

## Active asset manifest layer
var asset_manifest: WitnessAssetManifest

## Anomaly configuration containing:
## - "location": Dictionary with "x" and "y" floats/ints
## - "size": Dictionary with "x" and "y" floats/ints
## - "misstep_text": String
## - "success_text": String
var anomaly_definition := {}

## Capture timing window configuration containing:
## - "start_time": float
## - "end_time": float
## - "hold_duration": float
## - "guidance_text": String
## - "success_text": String
var capture_window := {}

## Array of dictionaries, each conforming to Evidence Node Data:
## - "identifier": String
## - "location": Dictionary with "x" and "y"
## - "description": String
## - "relevance": String
## - "truth_connection": String
## - "asset_reference": String (custom icon path)
## - "visual_effect": String (pulsing or highlight key)
## - "color_modulation": String (hex color code)
var evidence_nodes: Array[Dictionary] = []

var resolution_text := ""

## Reward multiplier parameters:
## - "base_resonance": int
## - "accuracy_multiplier": float
## - "unassisted_bonus": int
var reward_definition := {}

## Populate this definition from an authored raw dictionary.
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
	
	anomaly_definition = dict.get("anomaly_definition", {
		"location": {"x": 350.0, "y": 366.0},
		"size": {"x": 94.0, "y": 94.0},
		"misstep_text": "Not that. Watch what arrives too soon.",
		"success_text": "You found the anomaly."
	}).duplicate(true)
	
	capture_window = dict.get("capture_window", {
		"start_time": 0.92,
		"end_time": 1.26,
		"hold_duration": 0.26,
		"guidance_text": "HOLD WHEN YOU SEE THE FRACTURE.",
		"success_text": "Clipped the timeline fracture perfectly."
	}).duplicate(true)
	
	evidence_nodes.clear()
	var raw_nodes = dict.get("evidence_nodes", [])
	if raw_nodes is Array:
		for node in raw_nodes:
			if node is Dictionary:
				var clean_node: Dictionary = node.duplicate(true)
				# Extend evidence node definitions with custom visual assets/effects
				clean_node["asset_reference"] = str(clean_node.get("asset_reference", ""))
				clean_node["visual_effect"] = str(clean_node.get("visual_effect", "default"))
				clean_node["color_modulation"] = str(clean_node.get("color_modulation", "#dff8ef"))
				evidence_nodes.append(clean_node)
	else:
		# Compatibility fallback: build default nodes if evidence_nodes is missing
		var attunements = dict.get("attunements", [])
		if attunements is Array:
			for i in range(attunements.size()):
				evidence_nodes.append({
					"identifier": "node_%d" % i,
					"location": {"x": 100.0, "y": 100.0 + i * 50.0},
					"description": str(attunements[i]),
					"relevance": "Detail attunement %d" % i,
					"truth_connection": "Underlying connection restored.",
					"asset_reference": "",
					"visual_effect": "default",
					"color_modulation": "#dff8ef"
				})

	resolution_text = str(dict.get("resolution_text", dict.get("revelation", "")))
	
	reward_definition = dict.get("reward_definition", {
		"base_resonance": 20,
		"accuracy_multiplier": 15.0,
		"unassisted_bonus": 6
	}).duplicate(true)
	
	# Load or construct the asset manifest layer dynamically
	asset_manifest = WitnessAssetManifest.new()
	if dict.has("asset_manifest") and dict["asset_manifest"] is Dictionary:
		asset_manifest.from_dictionary(dict, moment_id)
	else:
		asset_manifest.build_fallback_manifest(self)

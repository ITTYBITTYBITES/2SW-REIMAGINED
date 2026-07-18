extends RefCounted
class_name WitnessAssetManifest

## Defines all external assets required by a data-driven Witness Moment.
## Fully extensible and supports fallback paths for backward compatibility.

var moment_id := ""
var environment_asset := ""
var background_layers: Array[String] = []

## Maps evidence node identifier to its asset/effect configurations:
## e.g., { "paused_brush": { "texture_path": "res://assets/...", "visual_effect": "glow" } }
var evidence_assets := {}

## Maps audio event triggers to sound file paths:
## e.g., { "ambient": "res://...", "anomaly": "res://...", "resolution": "res://..." }
var audio_assets := {}

## Maps visual effect identifiers to shaders, scales, or modulations:
## e.g., { "strobe": "heavy", "pulse_speed": 1.5 }
var visual_effects := {}

## Holds lighting-specific profiles:
## e.g., { "modulate_color": "#ffffff", "vignette_intensity": 0.8 }
var lighting_profile := {}

func from_dictionary(dict: Dictionary, fallback_id := "") -> void:
	moment_id = str(dict.get("moment_id", fallback_id))
	
	var manifest_dict: Dictionary = dict.get("asset_manifest", {})
	environment_asset = str(manifest_dict.get("environment_asset", ""))
	
	background_layers.clear()
	var layers = manifest_dict.get("background_layers", [])
	if layers is Array:
		for layer in layers:
			background_layers.append(str(layer))
			
	evidence_assets = manifest_dict.get("evidence_assets", {}).duplicate(true)
	audio_assets = manifest_dict.get("audio_assets", {}).duplicate(true)
	visual_effects = manifest_dict.get("visual_effects", {}).duplicate(true)
	lighting_profile = manifest_dict.get("lighting_profile", {}).duplicate(true)

## Generate a backward-compatible manifest from standard narrative fields
func build_fallback_manifest(moment_definition: WitnessMomentDefinition) -> void:
	moment_id = moment_definition.moment_id
	environment_asset = moment_definition.background_path
	background_layers = [moment_definition.background_path]
	
	# Fallback evidence assets
	evidence_assets = {}
	for node in moment_definition.evidence_nodes:
		var identifier: String = node.get("identifier", "")
		if not identifier.is_empty():
			evidence_assets[identifier] = {
				"texture_path": "",
				"visual_effect": "default",
				"color_modulation": "#dff8ef"
			}
			
	# Fallback audio assets
	audio_assets = {
		"ambient": "",
		"anomaly": "",
		"resolution": ""
	}
	
	# Fallback visual effects
	visual_effects = {
		"distortion_scale": 1.0,
		"transition_duration": 0.35
	}
	
	# Fallback lighting
	lighting_profile = {
		"modulate_color": "#ffffff",
		"vignette_intensity": 0.48
	}

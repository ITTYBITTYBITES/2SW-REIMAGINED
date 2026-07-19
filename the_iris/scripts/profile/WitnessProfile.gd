extends RefCounted
class_name WitnessProfile

## Local platform identity/save boundary retained through the Witness reset.
## It intentionally carries no moment, fragment, chapter, or progression state.
const SCHEMA_VERSION := 2

signal profile_changed(snapshot: Dictionary)

var witness_name := "Witness"
var created_at := ""
var preferences: Dictionary = {}

static func from_dictionary(data: Dictionary) -> WitnessProfile:
	var profile := WitnessProfile.new()
	profile.witness_name = str(data.get("witness_name", "Witness"))
	profile.created_at = str(data.get("created_at", ""))
	if data.get("preferences", {}) is Dictionary:
		profile.preferences = (data.get("preferences", {}) as Dictionary).duplicate(true)
	return profile

func profile_snapshot() -> Dictionary:
	return {"witness_name": witness_name, "created_at": created_at, "preferences": preferences.duplicate(true)}

func to_dictionary() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "witness_name": witness_name, "created_at": created_at, "preferences": preferences.duplicate(true)}

func notify_changed() -> void:
	profile_changed.emit(profile_snapshot())

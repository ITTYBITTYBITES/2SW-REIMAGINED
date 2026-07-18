extends RefCounted
class_name WitnessContentLoader

## Generic loader and validator for structured, data-driven Witness Moments.
## Ensures compliance with the Witness Moment Data Contract.

## Validates a raw dictionary against the minimum required fields of the data contract.
static func validate_moment_data(data: Dictionary) -> bool:
	var required_keys := [
		"incident_id",
		"title",
		"subtitle"
	]
	
	# Must have either 'id' or 'moment_id'
	if not (data.has("id") or data.has("moment_id")):
		push_error("Validation failed: Missing id or moment_id")
		return false
		
	# Must have either 'description' or 'introduction'
	if not (data.has("description") or data.has("introduction")):
		push_error("Validation failed: Missing description or introduction")
		return false
		
	for key in required_keys:
		if not data.has(key) or str(data[key]).is_empty():
			push_error("Validation failed: Missing required field '%s'" % key)
			return false
			
	return true

## Loads and validates a JSON file, returning a validated WitnessMomentDefinition object.
## If validation fails or the file cannot be read, returns null.
static func load_moment_definition(path: String) -> WitnessMomentDefinition:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: %s" % path)
		return null
		
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Failed to parse JSON file: %s" % path)
		return null
		
	var data_dict: Dictionary = parsed
	if not validate_moment_data(data_dict):
		push_error("JSON failed validation contract: %s" % path)
		return null
		
	var definition := WitnessMomentDefinition.new()
	definition.from_dictionary(data_dict)
	return definition

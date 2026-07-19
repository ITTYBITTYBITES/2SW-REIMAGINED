extends RefCounted
class_name WitnessArchive

## Retained archive authority boundary after the gameplay reset.
## It intentionally contains no retired content or reward data.
static func is_ready() -> bool:
	return false

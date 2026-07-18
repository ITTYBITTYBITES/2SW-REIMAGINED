extends RefCounted
class_name WitnessAssetResolver

## Asset Resolver Layer for 2SW.
## Locates, validates, and resolves asset paths securely.
## Provides safe, automatic fallbacks to protect the runtime from missing asset crashes.

const DEFAULT_BACKDROP := "res://assets/witness/wm_001_studio_background.png"
const DEFAULT_CLUE_ICON := "res://assets/witness/wm_001_prism_reveal.png"

## Safely loads and returns a 2D texture. Falls back to a default backdrop if missing.
static func resolve_texture(path: String, fallback := DEFAULT_BACKDROP) -> Texture2D:
	var clean_path := path.strip_edges()
	if clean_path.is_empty():
		return load(fallback) as Texture2D
		
	if not FileAccess.file_exists(clean_path):
		push_warning("⚠️ [WitnessAssetResolver] Missing texture file: '%s'. Applying default fallback." % clean_path)
		return load(fallback) as Texture2D
		
	var loaded = load(clean_path)
	if loaded is Texture2D:
		return loaded as Texture2D
		
	return load(fallback) as Texture2D

## Resolves hex color strings safely, avoiding parser exceptions.
static func resolve_color(hex_str: String, fallback := Color.WHITE) -> Color:
	var clean_hex := hex_str.strip_edges()
	if clean_hex.is_empty():
		return fallback
		
	if not clean_hex.begins_with("#"):
		clean_hex = "#" + clean_hex
		
	if Color.html_isValid(clean_hex):
		return Color.from_string(clean_hex, fallback)
		
	return fallback

## Safely resolves haptic / audio paths, validating metadata presence.
static func resolve_sound_path(path: String, fallback := "") -> String:
	var clean_path := path.strip_edges()
	if clean_path.is_empty() or not FileAccess.file_exists(clean_path):
		return fallback
	return clean_path

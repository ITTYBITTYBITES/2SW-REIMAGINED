extends RefCounted
class_name VisualStyleSystem
## Centralized asset-based visual style for all challenge family View scripts.
##
## Architecture:
##   - MASTER_MANIFEST maps every visual_kind across all five families to a sprite path
##   - draw_object() renders sprite with consistent shadow, lighting, scale
##   - Vector fallback: any kind without a sprite uses the family's original vector drawing
##   - Spot-the-Difference safety: color values from generator are passed through unmodified
##
## SHADOW RULE (v2):
##   Sprites are transparent cutouts with NO baked shadow. All shadows are drawn
##   in code by draw_shadow() for consistent direction/opacity/scale across both
##   sprite and vector paths. See PROMPT.md for asset generation spec.
##
## All game logic, timing, scoring, and state management remain untouched.

const VERSION := "2"
const SPRITE_DIR := "res://assets/gameplay/sprites/"

# ────────────────────────────────────────────────────────────
# SHADOW SYSTEM
# Single directional light from upper-left, shadows cast lower-right.
# Applied uniformly to all sprites at render time.
# ────────────────────────────────────────────────────────────
const SHADOW_OFFSET_X := 0.007
const SHADOW_OFFSET_Y := 0.010
const SHADOW_OPACITY := 0.32
const SHADOW_COLOR := Color(0.0, 0.0, 0.0, 1.0)
const SHADOW_SCALE := 0.92  # shadow ellipse slightly smaller than object

# ────────────────────────────────────────────────────────────
# ENVIRONMENT
# ────────────────────────────────────────────────────────────
const CANVAS_BASE := Color("#2A2520")  # warm dark neutral

# ────────────────────────────────────────────────────────────
# MASTER MANIFEST — every visual_kind across all families
# Maps visual_kind → {sprite_path, available}
# "available" is false until the sprite file exists on disk.
# ────────────────────────────────────────────────────────────
var MASTER_MANIFEST: Dictionary = {
	# ── Scene Investigation (65 kinds) ──
	"banana":         {"sprite": "banana.png",         "available": true},
	"basket":         {"sprite": "basket.png",         "available": true},
	"block":          {"sprite": "block.png",          "available": true},
	"board":          {"sprite": "board.png",          "available": true},
	"book":           {"sprite": "book.png",           "available": true},
	"bottle":         {"sprite": "bottle.png",         "available": true},
	"bowl":           {"sprite": "bowl.png",           "available": true},
	"bracket":        {"sprite": "bracket.png",        "available": true},
	"bread":          {"sprite": "bread.png",          "available": true},
	"brush":          {"sprite": "brush.png",          "available": true},
	"calculator":     {"sprite": "calculator.png",     "available": true},
	"camera":         {"sprite": "camera.png",         "available": true},
	"clamp":          {"sprite": "clamp.png",          "available": true},
	"clock":          {"sprite": "clock.png",          "available": true},
	"coil":           {"sprite": "coil.png",           "available": true},
	"compass":        {"sprite": "compass.png",        "available": true},
	"double":         {"sprite": "double.png",         "available": true},
	"drill":          {"sprite": "drill.png",          "available": true},
	"flashlight":     {"sprite": "flashlight.png",     "available": true},
	"folder":         {"sprite": "folder.png",         "available": true},
	"fork":           {"sprite": "fork.png",           "available": true},
	"fruit_round":    {"sprite": "fruit_round.png",    "available": true},
	"glass":          {"sprite": "glass.png",          "available": true},
	"glasses":        {"sprite": "glasses.png",        "available": true},
	"gloves":         {"sprite": "gloves.png",         "available": true},
	"grater":         {"sprite": "grater.png",         "available": true},
	"hammer":         {"sprite": "hammer.png",         "available": true},
	"hardware":       {"sprite": "hardware.png",       "available": true},
	"jar":            {"sprite": "jar.png",            "available": true},
	"kettle":         {"sprite": "kettle.png",         "available": true},
	"keys":           {"sprite": "keys.png",           "available": true},
	"lamp":           {"sprite": "lamp.png",           "available": true},
	"level":          {"sprite": "level.png",          "available": true},
	"magnifier":      {"sprite": "magnifier.png",      "available": true},
	"marker":         {"sprite": "marker.png",         "available": true},
	"mask":           {"sprite": "mask.png",           "available": true},
	"measuring_cup":  {"sprite": "measuring_cup.png",  "available": true},
	"mouse":          {"sprite": "mouse.png",          "available": true},
	"mug":            {"sprite": "mug.png",            "available": true},
	"pan":            {"sprite": "pan.png",            "available": true},
	"paper":          {"sprite": "paper.png",          "available": true},
	"pen":            {"sprite": "pen.png",            "available": true},
	"pencil":         {"sprite": "pencil.png",         "available": true},
	"phone":          {"sprite": "phone.png",          "available": true},
	"plant":          {"sprite": "plant.png",          "available": true},
	"plate":          {"sprite": "plate.png",          "available": true},
	"pliers":         {"sprite": "pliers.png",         "available": true},
	"pot":            {"sprite": "pot.png",            "available": true},
	"ruler":          {"sprite": "ruler.png",          "available": true},
	"saw":            {"sprite": "saw.png",            "available": true},
	"scissors":       {"sprite": "scissors.png",       "available": true},
	"screwdriver":    {"sprite": "screwdriver.png",    "available": true},
	"spatula":        {"sprite": "spatula.png",        "available": true},
	"spoon":          {"sprite": "spoon.png",          "available": true},
	"stapler":        {"sprite": "stapler.png",        "available": true},
	"tag":            {"sprite": "tag.png",            "available": true},
	"tape":           {"sprite": "tape.png",           "available": true},
	"tape_measure":   {"sprite": "tape_measure.png",   "available": true},
	"toaster":        {"sprite": "toaster.png",        "available": true},
	"toolbox":        {"sprite": "toolbox.png",        "available": true},
	"towel":          {"sprite": "towel.png",          "available": true},
	"trowel":         {"sprite": "trowel.png",         "available": true},
	"watering_can":   {"sprite": "watering_can.png",   "available": true},
	"whisk":          {"sprite": "whisk.png",          "available": true},
	"wrench":         {"sprite": "wrench.png",         "available": true},
	# Fallback marker drawn when kind is unknown
	"evidence_marker":{"sprite": "evidence_marker.png", "available": false},

	# ── Spot the Difference unique kinds (39 kinds, kebab-case overlapped) ──
	"acorn":     {"sprite": "acorn.png",     "available": false},
	"anchor":    {"sprite": "anchor.png",    "available": false},
	"bell":      {"sprite": "bell.png",      "available": false},
	"boat":      {"sprite": "boat.png",      "available": false},
	"boot":      {"sprite": "boot.png",      "available": false},
	"circle":    {"sprite": "circle.png",    "available": false},
	"cloud":     {"sprite": "cloud.png",     "available": false},
	"comb":      {"sprite": "comb.png",      "available": false},
	"cup":       {"sprite": "cup.png",       "available": false},
	"diamond":   {"sprite": "diamond.png",   "available": false},
	"drum":      {"sprite": "drum.png",      "available": false},
	"flag":      {"sprite": "flag.png",      "available": false},
	"flower":    {"sprite": "flower.png",    "available": false},
	"fruit":     {"sprite": "fruit.png",     "available": false},
	"gem":       {"sprite": "gem.png",       "available": false},
	"glove":     {"sprite": "glove.png",     "available": false},
	"hat":       {"sprite": "hat.png",       "available": false},
	"key":       {"sprite": "key.png",       "available": false},
	"kite":      {"sprite": "kite.png",      "available": false},
	"leaf":      {"sprite": "leaf.png",      "available": false},
	"line":      {"sprite": "line.png",      "available": false},
	"magnet":    {"sprite": "magnet.png",    "available": false},
	"moon":      {"sprite": "moon.png",      "available": false},
	"pill":      {"sprite": "pill.png",      "available": false},
	"ribbon":    {"sprite": "ribbon.png",    "available": false},
	"ring":      {"sprite": "ring.png",      "available": false},
	"shell":     {"sprite": "shell.png",     "available": false},
	"star":      {"sprite": "star.png",      "available": false},
	"umbrella":  {"sprite": "umbrella.png",  "available": false},
	"vase":      {"sprite": "vase.png",      "available": false},
	"watch":     {"sprite": "watch.png",     "available": false},
	"wheel":     {"sprite": "wheel.png",     "available": false},
	"whistle":   {"sprite": "whistle.png",   "available": false},

	# ── Object Recall extra kinds ──
	"feather":   {"sprite": "feather.png",   "available": false},
	"button":    {"sprite": "button.png",    "available": false},
	"candle":    {"sprite": "candle.png",    "available": false},
	"map":       {"sprite": "map.png",       "available": false},

	# ── Pattern Recall symbols (12 kinds) ──
	"Arc":     {"sprite": "symbol_arc.png",     "available": false},
	"Bars":    {"sprite": "symbol_bars.png",    "available": false},
	"Circle":  {"sprite": "symbol_circle.png",  "available": false},
	"Cross":   {"sprite": "symbol_cross.png",   "available": false},
	"Diamond": {"sprite": "symbol_diamond.png", "available": false},
	"Hexagon": {"sprite": "symbol_hexagon.png", "available": false},
	"Plus":    {"sprite": "symbol_plus.png",    "available": false},
	"Square":  {"sprite": "symbol_square.png",  "available": false},
	"Triangle":{"sprite": "symbol_triangle.png","available": false},
	"Wave":    {"sprite": "symbol_wave.png",    "available": false},
	"Ring":    {"sprite": "symbol_ring.png",    "available": false},
	"Star":    {"sprite": "symbol_star.png",    "available": false},
}

# ────────────────────────────────────────────────────────────
# RUNTIME CACHE
# ────────────────────────────────────────────────────────────
var _texture_cache: Dictionary = {}
var _manifest_scanned: bool = false

func _init() -> void:
	pass

# ────────────────────────────────────────────────────────────
# ASSET AVAILABILITY
# ────────────────────────────────────────────────────────────

## Scan the sprite directory and mark available sprites in the manifest.
## Call once at startup or lazily on first draw.
func scan_assets() -> void:
	if _manifest_scanned:
		return
	_manifest_scanned = true
	for kind: String in MASTER_MANIFEST:
		var entry: Dictionary = MASTER_MANIFEST[kind]
		var path := SPRITE_DIR + str(entry.get("sprite", ""))
		if ResourceLoader.exists(path):
			entry["available"] = true
			# Load into cache
			var tex: Texture2D = load(path) as Texture2D
			if tex:
				_texture_cache[kind] = tex

## Returns true if a sprite asset exists for this visual_kind.
func has_sprite(visual_kind: String) -> bool:
	if not _manifest_scanned:
		scan_assets()
	if not MASTER_MANIFEST.has(visual_kind):
		return false
	return bool(MASTER_MANIFEST[visual_kind].get("available", false))

## Returns the cached texture for a visual_kind, or null if not available.
func get_texture(visual_kind: String) -> Texture2D:
	if not _manifest_scanned:
		scan_assets()
	if _texture_cache.has(visual_kind):
		return _texture_cache[visual_kind]
	return null

# ────────────────────────────────────────────────────────────
# DRAWING API — call from family View _draw() methods
# ────────────────────────────────────────────────────────────

## Draw a grounded shadow ellipse under where the object will appear.
## Call BEFORE drawing the object itself.
func draw_shadow(canvas: Control, center: Vector2, object_size: Vector2, canvas_size: Vector2) -> void:
	var shadow_width := object_size.x * SHADOW_SCALE
	var shadow_height := object_size.y * SHADOW_SCALE * 0.45
	var shadow_center := center + Vector2(
		canvas_size.x * SHADOW_OFFSET_X,
		canvas_size.y * SHADOW_OFFSET_Y
	)
	canvas.draw_circle(shadow_center, maxf(shadow_width, shadow_height) * 0.5,
		Color(SHADOW_COLOR, SHADOW_OPACITY * 0.55))
	canvas.draw_circle(shadow_center, maxf(shadow_width, shadow_height) * 0.30,
		Color(SHADOW_COLOR, SHADOW_OPACITY))

## Draw an object using its sprite asset.
## Returns true if a sprite was drawn; false means caller should use vector fallback.
## Caller is responsible for draw_set_transform() before calling this.
func draw_sprite_object(
	canvas: Control,
	visual_kind: String,
	rect: Rect2
) -> bool:
	var tex := get_texture(visual_kind)
	if tex == null:
		return false
	canvas.draw_texture_rect(tex, rect, false)
	return true

## Return the appropriate accent color for reveal highlights.
func accent_color(_family_id: String = "") -> Color:
	return Color("#C8A96E")  # warm gold, replaces purple

## Return the grounded canvas background color.
func canvas_background(_family_id: String = "") -> Color:
	return CANVAS_BASE

## Return the sprite path for a visual kind (for asset pipeline reference).
func sprite_path(visual_kind: String) -> String:
	if not MASTER_MANIFEST.has(visual_kind):
		return ""
	return SPRITE_DIR + str(MASTER_MANIFEST[visual_kind].get("sprite", ""))

## Return all visual_kinds in the master manifest.
func all_manifest_kinds() -> Array[String]:
	var kinds: Array[String] = []
	for kind: String in MASTER_MANIFEST:
		kinds.append(kind)
	return kinds

## Return count of available vs total sprites.
func asset_coverage() -> Dictionary:
	if not _manifest_scanned:
		scan_assets()
	var available: int = 0
	var total: int = MASTER_MANIFEST.size()
	for kind: String in MASTER_MANIFEST:
		if bool(MASTER_MANIFEST[kind].get("available", false)):
			available += 1
	return {"available": available, "total": total}

## Get grounded background overrides per template (muted earth tones).
func ground_background(template_id: String, original: Dictionary) -> Dictionary:
	var grounded := original.duplicate(true)
	var overrides := {
		"office":      {"top": "#B0B8BF", "surface": "#8B7355", "line": "#5C4A3D"},
		"kitchen":     {"top": "#C4BFB0", "surface": "#9B8A7A", "line": "#6B5D4F"},
		"workshop":    {"top": "#A8ADB2", "surface": "#7A6E65", "line": "#4E4640"},
		"travel_desk": {"top": "#B5B0A8", "surface": "#8C7B68", "line": "#5E5042"},
		"garden_bench":{"top": "#A8B5A0", "surface": "#7A8B6E", "line": "#4A5540"},
	}
	var key := ""
	if template_id.begins_with("office"): key = "office"
	elif template_id.begins_with("kitchen"): key = "kitchen"
	elif template_id.begins_with("workshop"): key = "workshop"
	elif template_id.begins_with("travel_desk"): key = "travel_desk"
	elif template_id.begins_with("garden_bench"): key = "garden_bench"
	var ov: Dictionary = overrides.get(key, {})
	if not ov.is_empty():
		for color_key: String in ["top", "surface", "line"]:
			if ov.has(color_key):
				grounded[color_key] = ov[color_key]
	else:
		for color_key: String in ["top", "surface", "line"]:
			if grounded.has(color_key):
				var c := Color(grounded[color_key])
				grounded[color_key] = "#%s" % c.darkened(0.18).to_html(false)
	return grounded

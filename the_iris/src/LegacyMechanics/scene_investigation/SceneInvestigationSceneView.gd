extends Control
class_name SceneInvestigationSceneView
## Family-specific renderer for generated Scene Investigation scene data.
##
## Asset pipeline: uses VisualStyleSystem to render sprite textures for known
## visual_kinds, with full vector fallback for kinds without assets yet.
## Data contract, shape geometry, highlight logic remain unchanged.

var _scene_data: Dictionary = {}
var _highlight_ids: Array[String] = []
var _background_texture: Texture2D = null
var _reveal_elapsed: float = 0.0
var _style: VisualStyleSystem
var _family_id: String = "scene_investigation"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(false)
	_style = VisualStyleSystem.new()
	_style.scan_assets()

func _process(delta: float) -> void:
	_reveal_elapsed += delta
	queue_redraw()

func set_scene_data(scene_data: Dictionary, highlight_ids: Array = []) -> void:
	_scene_data = scene_data.duplicate(true)
	_background_texture = null
	var background_value: Variant = _scene_data.get("background", {})
	if background_value is Dictionary:
		var image_path := str((background_value as Dictionary).get("image_path", ""))
		if not image_path.is_empty() and ResourceLoader.exists(image_path):
			_background_texture = load(image_path) as Texture2D
	_highlight_ids.clear()
	for value: Variant in highlight_ids:
		_highlight_ids.append(str(value))
	_reveal_elapsed = 0.0
	var animate_reveal: bool = not _highlight_ids.is_empty()
	if AccessibilityService and not AccessibilityService.should_animate():
		animate_reveal = false
	set_process(animate_reveal)
	queue_redraw()

func _draw() -> void:
	var canvas_size := size
	if canvas_size.x <= 0.0 or canvas_size.y <= 0.0:
		return
	var background: Dictionary = _scene_data.get("background", {})
	var template_id := str(_scene_data.get("template_id", ""))
	var grounded_bg := _style.ground_background(template_id, background)
	var top_color := Color(str(grounded_bg.get("top", "#B0B8BF")))
	var surface_color := Color(str(grounded_bg.get("surface", "#8B7355")))
	var line_color := Color(str(grounded_bg.get("line", "#5C4A3D")))

	# Warm grounded canvas base
	draw_rect(Rect2(Vector2.ZERO, canvas_size), _style.canvas_background(_family_id), true)

	if _background_texture:
		draw_texture_rect(_background_texture, Rect2(Vector2.ZERO, canvas_size), false)
		# Subtle warm overlay to harmonize background textures with grounded palette
		draw_rect(Rect2(Vector2.ZERO, canvas_size), Color(0.96, 0.92, 0.84, 0.10), true)
	else:
		draw_rect(Rect2(Vector2.ZERO, canvas_size), top_color, true)
		var surface_y := canvas_size.y * float(background.get("surface_y", 0.22))
		draw_rect(Rect2(0, surface_y, canvas_size.x, canvas_size.y - surface_y), surface_color, true)
		draw_line(Vector2(0, surface_y), Vector2(canvas_size.x, surface_y), line_color, 3.0)
		_draw_template_background(canvas_size, line_color)

	var decorations: Array = _scene_data.get("decorations", [])
	for raw_decoration: Variant in decorations:
		if raw_decoration is Dictionary:
			_draw_decoration(raw_decoration as Dictionary, canvas_size, line_color)

	var objects: Array = _scene_data.get("objects", [])
	for raw_object: Variant in objects:
		if raw_object is Dictionary:
			_draw_object(raw_object as Dictionary, canvas_size)

func _draw_template_background(canvas_size: Vector2, line_color: Color) -> void:
	var template_id := str(_scene_data.get("template_id", ""))
	var faint := Color(line_color, 0.22)
	if template_id.begins_with("office"):
		draw_rect(Rect2(canvas_size.x * 0.08, canvas_size.y * 0.05, canvas_size.x * 0.28, canvas_size.y * 0.10), faint, false, 2.0)
		draw_line(Vector2(canvas_size.x * 0.64, canvas_size.y * 0.13), Vector2(canvas_size.x * 0.91, canvas_size.y * 0.13), faint, 5.0)
	elif template_id.begins_with("kitchen"):
		for column: int in range(4):
			draw_line(Vector2(canvas_size.x * (0.1 + column * 0.25), 0), Vector2(canvas_size.x * (0.1 + column * 0.25), canvas_size.y * 0.20), faint, 2.0)
		draw_line(Vector2(0, canvas_size.y * 0.10), Vector2(canvas_size.x, canvas_size.y * 0.10), faint, 2.0)
	elif template_id.begins_with("workshop"):
		for row: int in range(2):
			for column: int in range(8):
				draw_circle(Vector2(canvas_size.x * (0.08 + column * 0.12), canvas_size.y * (0.06 + row * 0.08)), 2.2, faint)

func _draw_decoration(data: Dictionary, canvas_size: Vector2, line_color: Color) -> void:
	var center := Vector2(float(data.get("x", 0.5)) * canvas_size.x, float(data.get("y", 0.5)) * canvas_size.y)
	var scale_value := float(data.get("scale", 1.0))
	var color := Color(line_color, 0.18)
	match str(data.get("kind", "dot")):
		"line":
			var length := 22.0 * scale_value
			var direction := Vector2.RIGHT.rotated(deg_to_rad(float(data.get("rotation_deg", 0.0))))
			draw_line(center - direction * length * 0.5, center + direction * length * 0.5, color, 2.0)
		"paper_corner":
			draw_polyline(PackedVector2Array([center + Vector2(-8, 6) * scale_value, center, center + Vector2(7, 8) * scale_value]), color, 2.0)
		_:
			draw_circle(center, 3.0 * scale_value, color)

func _draw_object(data: Dictionary, canvas_size: Vector2) -> void:
	var center := Vector2(float(data.get("x", 0.5)) * canvas_size.x, float(data.get("y", 0.5)) * canvas_size.y)
	var object_size := Vector2(float(data.get("w", 0.13)) * canvas_size.x, float(data.get("h", 0.11)) * canvas_size.y)
	var object_rotation := deg_to_rad(float(data.get("rotation_deg", 0.0)))
	var body := Color(str(data.get("color", "#6DAEDB")))
	var high_contrast := AccessibilityService.is_high_contrast_enabled() if AccessibilityService else false
	var outline := Color.BLACK if high_contrast else Color("#24242C")
	var detail := body.lightened(0.35 if high_contrast else 0.28)
	var kind := str(data.get("visual_kind", "evidence_marker"))

	# Draw grounding shadow under object (before the object itself)
	if not high_contrast:
		_style.draw_shadow(self, center, object_size, canvas_size)

	# ── ASSET PIPELINE: try sprite texture first ──
	if _style.has_sprite(kind):
		draw_set_transform(center, object_rotation, Vector2.ONE)
		var sprite_rect := Rect2(-object_size * 0.5, object_size)
		_style.draw_sprite_object(self, kind, sprite_rect)
		# Highlight overlay on top of sprite
		if _highlight_ids.has(str(data.get("instance_id", ""))):
			var pulse: float = 0.72 + 0.28 * sin(_reveal_elapsed * 4.5)
			var accent := _style.accent_color(_family_id)
			var focus_rect := sprite_rect.grow(8.0 + pulse * 3.0)
			draw_rect(focus_rect, Color(accent, pulse), false, 5.0)
			draw_rect(focus_rect.grow(5.0), Color(accent, 0.18 * pulse), false, 3.0)
		if high_contrast:
			draw_rect(sprite_rect.grow(6.0), Color.BLACK, false, 3.0)
			draw_rect(sprite_rect.grow(3.0), Color.WHITE, false, 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	# ── VECTOR FALLBACK: original rendering for kinds without sprites ──

	draw_set_transform(center, object_rotation, Vector2.ONE)
	var rect := Rect2(-object_size * 0.5, object_size)

	match kind:
		"book", "folder", "paper", "board", "towel", "block", "toolbox", "toaster", "calculator", "phone", "stapler", "level", "camera", "tag", "grater", "basket":
			_draw_box_kind(kind, rect, body, detail, outline)
		"mug", "bottle", "glass", "jar", "measuring_cup", "kettle", "pot", "watering_can":
			_draw_container_kind(kind, rect, body, detail, outline)
		"pencil", "pen", "marker", "ruler", "spoon", "fork", "whisk", "hammer", "screwdriver", "wrench", "pliers", "brush", "flashlight", "clamp", "scissors", "spatula", "saw", "trowel", "magnifier":
			_draw_long_kind(kind, rect, body, detail, outline)
		"fruit_round", "plate", "bowl", "clock", "tape", "mouse", "compass", "coil", "mask", "banana":
			_draw_round_kind(kind, rect, body, detail, outline)
		"glasses", "double":
			_draw_glasses(rect, body, outline)
		"keys", "hardware":
			_draw_hardware(rect, body, outline)
		"plant":
			_draw_plant(rect, body, outline)
		"pan":
			_draw_pan(rect, body, detail, outline)
		"gloves":
			_draw_gloves(rect, body, outline)
		"drill":
			_draw_drill(rect, body, detail, outline)
		"bracket":
			_draw_bracket(rect, body, outline)
		"bread":
			_draw_bread(rect, body, detail, outline)
		_:
			_draw_evidence_marker(rect, body, detail, outline)

	if high_contrast:
		draw_rect(rect.grow(6.0), Color.BLACK, false, 3.0)
		draw_rect(rect.grow(3.0), Color.WHITE, false, 2.0)
	if _highlight_ids.has(str(data.get("instance_id", ""))):
		var pulse: float = 0.72 + 0.28 * sin(_reveal_elapsed * 4.5)
		var accent := _style.accent_color(_family_id)
		var focus_rect := rect.grow(8.0 + pulse * 3.0)
		draw_rect(focus_rect, Color(accent, pulse), false, 5.0)
		draw_rect(focus_rect.grow(5.0), Color(accent, 0.18 * pulse), false, 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_evidence_marker(rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.42
	var points := PackedVector2Array()
	for index: int in range(6):
		points.append(center + Vector2.UP.rotated(TAU * float(index) / 6.0) * radius)
	draw_colored_polygon(points, body)
	draw_polyline(points, outline, 3.0)
	draw_circle(center, radius * 0.48, Color(detail, 0.42))
	draw_arc(center, radius * 0.48, 0, TAU, 24, outline, 2.0)
	draw_line(center + Vector2(-radius * 0.30, 0), center + Vector2(radius * 0.30, 0), detail, 3.0)
	draw_line(center + Vector2(0, -radius * 0.30), center + Vector2(0, radius * 0.30), detail, 3.0)

func _draw_box_kind(kind: String, rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	draw_rect(rect, body, true)
	draw_rect(rect, outline, false, 3.0)
	if kind in ["book", "folder", "paper"]:
		draw_line(Vector2(rect.position.x + rect.size.x * 0.18, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.18, rect.end.y), detail, 4.0)
		draw_line(Vector2(rect.position.x + rect.size.x * 0.30, rect.position.y + rect.size.y * 0.28), Vector2(rect.end.x - rect.size.x * 0.12, rect.position.y + rect.size.y * 0.28), detail, 3.0)
	elif kind == "calculator":
		draw_rect(Rect2(rect.position + rect.size * 0.15, Vector2(rect.size.x * 0.70, rect.size.y * 0.22)), detail, true)
		for row: int in range(2):
			for column: int in range(3):
				draw_circle(rect.position + Vector2(rect.size.x * (0.25 + column * 0.25), rect.size.y * (0.58 + row * 0.20)), maxf(2.0, rect.size.x * 0.05), detail)
	elif kind == "phone":
		draw_rect(rect.grow(-rect.size.x * 0.12), Color("#DDE5EC"), true)
	elif kind == "level":
		draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.14, detail)
	elif kind == "stapler":
		draw_line(Vector2(rect.position.x + 4, rect.end.y - 5), Vector2(rect.end.x - 4, rect.end.y - 5), outline, 4.0)
	elif kind == "camera":
		draw_circle(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.24, detail)
		draw_arc(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.24, 0, TAU, 20, outline, 3.0)
	elif kind == "grater":
		for row: int in range(2):
			for column: int in range(3):
				draw_circle(rect.position + Vector2(rect.size.x * (0.25 + column * 0.25), rect.size.y * (0.38 + row * 0.28)), 2.5, outline)
	elif kind == "tag":
		draw_circle(rect.position + Vector2(rect.size.x * 0.18, rect.size.y * 0.30), 3.5, outline)
	elif kind == "basket":
		for column: int in range(1, 4):
			draw_line(Vector2(rect.position.x + rect.size.x * column / 4.0, rect.position.y), Vector2(rect.position.x + rect.size.x * column / 4.0, rect.end.y), detail, 2.0)

func _draw_container_kind(kind: String, rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var body_rect := rect.grow(-rect.size.x * 0.12)
	draw_rect(body_rect, body, true)
	draw_rect(body_rect, outline, false, 3.0)
	draw_line(Vector2(body_rect.position.x, body_rect.position.y), Vector2(body_rect.end.x, body_rect.position.y), detail, 4.0)
	if kind in ["mug", "measuring_cup", "kettle", "watering_can"]:
		draw_arc(Vector2(body_rect.end.x, body_rect.get_center().y), body_rect.size.y * 0.24, -PI * 0.5, PI * 0.5, 16, outline, 4.0)
	if kind == "watering_can":
		draw_line(Vector2(body_rect.position.x, body_rect.get_center().y), Vector2(rect.position.x - rect.size.x * 0.16, rect.position.y + rect.size.y * 0.26), outline, 5.0)
	if kind == "bottle":
		draw_rect(Rect2(body_rect.get_center().x - body_rect.size.x * 0.18, rect.position.y, body_rect.size.x * 0.36, body_rect.size.y * 0.20), body, true)
	if kind == "jar":
		draw_line(Vector2(body_rect.position.x, body_rect.position.y + 4), Vector2(body_rect.end.x, body_rect.position.y + 4), outline, 5.0)

func _draw_long_kind(kind: String, rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var start := Vector2(rect.position.x + rect.size.x * 0.12, rect.get_center().y)
	var finish := Vector2(rect.end.x - rect.size.x * 0.12, rect.get_center().y)
	draw_line(start, finish, outline, maxf(7.0, rect.size.y * 0.25))
	draw_line(start, finish, body, maxf(4.0, rect.size.y * 0.15))
	if kind in ["pencil", "pen", "marker", "ruler"]:
		draw_circle(finish, maxf(3.0, rect.size.y * 0.09), detail)
	elif kind == "hammer":
		draw_rect(Rect2(finish - Vector2(rect.size.x * 0.12, rect.size.y * 0.30), Vector2(rect.size.x * 0.22, rect.size.y * 0.60)), detail, true)
	elif kind in ["spoon", "wrench"]:
		draw_circle(finish, rect.size.y * 0.20, detail, false, 4.0)
	elif kind == "fork":
		for offset: float in [-0.12, 0.0, 0.12]:
			draw_line(finish + Vector2(0, rect.size.y * offset), finish + Vector2(rect.size.x * 0.12, rect.size.y * offset), detail, 2.0)
	elif kind in ["pliers", "clamp", "scissors"]:
		draw_line(rect.get_center(), finish + Vector2(0, -rect.size.y * 0.22), detail, 4.0)
		draw_line(rect.get_center(), finish + Vector2(0, rect.size.y * 0.22), detail, 4.0)
		if kind == "scissors":
			draw_circle(start + Vector2(0, -rect.size.y * 0.18), rect.size.y * 0.12, detail, false, 3.0)
			draw_circle(start + Vector2(0, rect.size.y * 0.18), rect.size.y * 0.12, detail, false, 3.0)
	elif kind == "magnifier":
		draw_circle(finish, rect.size.y * 0.25, detail, false, 4.0)
	elif kind == "saw":
		for tooth: int in range(5):
			var tooth_x: float = lerpf(start.x, finish.x, float(tooth) / 4.0)
			draw_line(Vector2(tooth_x, finish.y), Vector2(tooth_x + 3.0, finish.y + rect.size.y * 0.16), detail, 2.0)

func _draw_round_kind(kind: String, rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var radius := minf(rect.size.x, rect.size.y) * 0.42
	draw_circle(rect.get_center(), radius, body)
	draw_arc(rect.get_center(), radius, 0, TAU, 32, outline, 3.0)
	if kind == "clock":
		draw_line(rect.get_center(), rect.get_center() + Vector2(0, -radius * 0.55), outline, 3.0)
		draw_line(rect.get_center(), rect.get_center() + Vector2(radius * 0.45, 0), outline, 3.0)
	elif kind == "fruit_round":
		draw_line(rect.get_center() + Vector2(0, -radius), rect.get_center() + Vector2(radius * 0.18, -radius * 1.20), Color("#4F8A65"), 4.0)
	elif kind in ["plate", "bowl", "tape", "coil"]:
		draw_arc(rect.get_center(), radius * 0.58, 0, TAU, 24, detail, 4.0)
	elif kind == "compass":
		draw_colored_polygon(PackedVector2Array([
			rect.get_center() + Vector2(0, -radius * 0.72),
			rect.get_center() + Vector2(radius * 0.24, radius * 0.48),
			rect.get_center() + Vector2(-radius * 0.24, radius * 0.48)
		]), detail)
	elif kind == "mouse":
		draw_line(rect.get_center(), rect.get_center() + Vector2(0, -radius * 0.75), outline, 2.0)
	elif kind == "mask":
		draw_line(rect.get_center() + Vector2(-radius * 0.55, 0), rect.get_center() + Vector2(radius * 0.55, 0), detail, 3.0)
	elif kind == "banana":
		draw_arc(rect.get_center(), radius * 0.72, 0.25, PI - 0.25, 20, detail, 6.0)

func _draw_glasses(rect: Rect2, body: Color, outline: Color) -> void:
	var radius := minf(rect.size.x * 0.20, rect.size.y * 0.34)
	var left := rect.get_center() + Vector2(-rect.size.x * 0.22, 0)
	var right := rect.get_center() + Vector2(rect.size.x * 0.22, 0)
	draw_circle(left, radius, Color(body, 0.25))
	draw_circle(right, radius, Color(body, 0.25))
	draw_arc(left, radius, 0, TAU, 24, outline, 4.0)
	draw_arc(right, radius, 0, TAU, 24, outline, 4.0)
	draw_line(left + Vector2(radius, 0), right - Vector2(radius, 0), outline, 4.0)

func _draw_hardware(rect: Rect2, body: Color, outline: Color) -> void:
	for index: int in range(3):
		var center := rect.position + Vector2(rect.size.x * (0.25 + index * 0.25), rect.size.y * (0.38 + (index % 2) * 0.25))
		draw_circle(center, minf(rect.size.x, rect.size.y) * 0.12, body)
		draw_arc(center, minf(rect.size.x, rect.size.y) * 0.12, 0, TAU, 16, outline, 3.0)

func _draw_plant(rect: Rect2, body: Color, outline: Color) -> void:
	var pot := Rect2(rect.position + Vector2(rect.size.x * 0.30, rect.size.y * 0.58), Vector2(rect.size.x * 0.40, rect.size.y * 0.35))
	draw_rect(pot, Color("#A98768"), true)
	draw_rect(pot, outline, false, 3.0)
	for offset: Vector2 in [Vector2(-0.20, -0.08), Vector2(0, -0.25), Vector2(0.20, -0.05)]:
		draw_circle(rect.get_center() + rect.size * offset, minf(rect.size.x, rect.size.y) * 0.18, body)

func _draw_pan(rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var center := rect.position + Vector2(rect.size.x * 0.40, rect.size.y * 0.50)
	var radius := minf(rect.size.x, rect.size.y) * 0.32
	draw_circle(center, radius, body)
	draw_arc(center, radius, 0, TAU, 24, outline, 3.0)
	draw_line(center + Vector2(radius, 0), Vector2(rect.end.x, center.y), outline, 7.0)
	draw_circle(center, radius * 0.55, detail, false, 3.0)

func _draw_gloves(rect: Rect2, body: Color, outline: Color) -> void:
	var left := Rect2(rect.position + Vector2(rect.size.x * 0.08, rect.size.y * 0.18), Vector2(rect.size.x * 0.38, rect.size.y * 0.64))
	var right := Rect2(rect.position + Vector2(rect.size.x * 0.54, rect.size.y * 0.18), Vector2(rect.size.x * 0.38, rect.size.y * 0.64))
	draw_rect(left, body, true)
	draw_rect(right, body, true)
	draw_rect(left, outline, false, 3.0)
	draw_rect(right, outline, false, 3.0)

func _draw_drill(rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	var top := Rect2(rect.position + Vector2(0, rect.size.y * 0.10), Vector2(rect.size.x * 0.78, rect.size.y * 0.42))
	var handle := Rect2(rect.position + Vector2(rect.size.x * 0.34, rect.size.y * 0.45), Vector2(rect.size.x * 0.26, rect.size.y * 0.45))
	draw_rect(top, body, true)
	draw_rect(handle, detail, true)
	draw_rect(top, outline, false, 3.0)
	draw_rect(handle, outline, false, 3.0)
	draw_line(Vector2(top.end.x, top.get_center().y), Vector2(rect.end.x, top.get_center().y), outline, 5.0)

func _draw_bracket(rect: Rect2, body: Color, outline: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		Vector2(rect.end.x, rect.position.y + rect.size.y * 0.30),
		Vector2(rect.position.x + rect.size.x * 0.35, rect.position.y + rect.size.y * 0.30),
		Vector2(rect.position.x + rect.size.x * 0.35, rect.end.y),
		Vector2(rect.position.x, rect.end.y)
	])
	draw_colored_polygon(points, body)
	draw_polyline(points, outline, 3.0)

func _draw_bread(rect: Rect2, body: Color, detail: Color, outline: Color) -> void:
	draw_rect(rect, body, true)
	draw_arc(Vector2(rect.get_center().x, rect.position.y + rect.size.y * 0.25), rect.size.x * 0.35, PI, TAU, 20, outline, 3.0)
	draw_rect(rect, outline, false, 3.0)
	for index: int in range(3):
		draw_line(rect.position + Vector2(rect.size.x * (0.28 + index * 0.20), rect.size.y * 0.30), rect.position + Vector2(rect.size.x * (0.22 + index * 0.20), rect.size.y * 0.50), detail, 3.0)

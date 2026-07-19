extends Control
class_name SpatialHub

## Mission 054B — presentation foundation for the Iris-centered spatial hub.
## Node3D layers are deliberately kept separate from the 2D prototype renderer:
## this proves spatial composition and camera intent without requiring final art
## or replacing the existing Application navigation routes.
signal story_requested
signal archive_requested
signal profile_requested
signal active_memory_selected
signal shard_focused(normalized_target: Vector2, shard_id: String)
signal shard_released
signal shard_selected(shard_id: String)

const ORBIT_SPEED := 0.075
const FOCUS_RADIUS := 64.0

var SpatialHubRoot: Node3D
var Foreground_Nav: Node3D
var Midground_Active: Node3D
var Background_Constellation: Node3D
var HubCamera: Camera3D

var profile: WitnessProfile
var registry: IncidentRegistry
var elapsed := 0.0
var focused_shard_id := ""
var selected_shard_id := ""
var camera_focus := Vector3(0.0, 0.0, 8.0)
var camera_target := Vector3(0.0, 0.0, 8.0)
var profile_panel: Label
var journey_label: Label
var hint_label: Label
var nav_buttons: Dictionary = {}
var shards: Array[Dictionary] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_spatial_hierarchy()
	_build_foreground_navigation()
	journey_label = _label("ACTIVE JOURNEY  ·  A MEMORY IS NEAR", 10, Color("#8ac8b9"), Vector2(28, 628), Vector2(330, 18))
	hint_label = _label("Move through the field. The Iris holds the center.", 13, Color("#cce8df"), Vector2(28, 649), Vector2(420, 25))
	profile_panel = _label("", 11, Color("#a9c9be"), Vector2(28, 744), Vector2(484, 44))
	profile_panel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rebuild_shards()

func configure(value_profile: WitnessProfile, value_registry: IncidentRegistry) -> void:
	profile = value_profile
	registry = value_registry
	if is_node_ready():
		_rebuild_shards()

func _build_spatial_hierarchy() -> void:
	# These nodes define the production-facing 3D composition contract.
	SpatialHubRoot = Node3D.new()
	SpatialHubRoot.name = "SpatialHub"
	add_child(SpatialHubRoot)
	Foreground_Nav = Node3D.new()
	Foreground_Nav.name = "Foreground_Nav"
	SpatialHubRoot.add_child(Foreground_Nav)
	Midground_Active = Node3D.new()
	Midground_Active.name = "Midground_Active"
	SpatialHubRoot.add_child(Midground_Active)
	Background_Constellation = Node3D.new()
	Background_Constellation.name = "Background_Constellation"
	SpatialHubRoot.add_child(Background_Constellation)
	HubCamera = Camera3D.new()
	HubCamera.name = "SpatialHubCamera"
	HubCamera.position = camera_focus
	SpatialHubRoot.add_child(HubCamera)

func _build_foreground_navigation() -> void:
	var definitions := [
		{"id": "story", "text": "STORY", "x": 28.0},
		{"id": "archive", "text": "ARCHIVE", "x": 186.0},
		{"id": "profile", "text": "PROFILE", "x": 366.0}
	]
	for definition in definitions:
		var button := Button.new()
		button.name = "Nav_%s" % str(definition.get("id", "")).capitalize()
		button.text = str(definition.get("text", ""))
		button.position = Vector2(float(definition.get("x", 0.0)), 26)
		button.size = Vector2(146, 31)
		button.flat = true
		button.add_theme_font_size_override("font_size", 10)
		button.add_theme_color_override("font_color", Color("#91cbbd"))
		button.add_theme_color_override("font_hover_color", Color("#e3fff5"))
		button.pressed.connect(_on_nav_pressed.bind(str(definition.get("id", ""))))
		add_child(button)
		nav_buttons[str(definition.get("id", ""))] = button

func _on_nav_pressed(nav_id: String) -> void:
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/navigation/ui_click.ogg")
	match nav_id:
		"story": story_requested.emit()
		"archive": archive_requested.emit()
		"profile":
			profile_requested.emit()
			_show_profile_focus()

func _show_profile_focus() -> void:
	if profile == null:
		return
	hint_label.text = "%s · Aperture %d · %d Resonance" % [profile.witness_name, profile.aperture_rank, profile.resonance]
	camera_target = Vector3(0.0, -0.35, 7.25)

func _rebuild_shards() -> void:
	for layer in [Midground_Active, Background_Constellation]:
		if layer != null:
			for child in layer.get_children():
				child.queue_free()
	shards.clear()
	# Midground: the presently actionable thread. It retains the existing
	# Continue Witness behavior, rather than introducing a new story route.
	_add_shard("FM_001", "CURRENT MEMORY", "Follow the living thread", "active", 0.18)
	# Background constellation derives from the one persisted Archive authority.
	var fragments := WitnessArchive.recovered_truth_fragments(profile)
	var by_moment := {}
	for fragment in fragments:
		by_moment[str(fragment.get("moment_id", ""))] = fragment
	var archive_ids := ["WM_001", "WM_002", "WM_003", "WM_004", "WM_005"]
	for index in range(archive_ids.size()):
		var moment_id: String = archive_ids[index]
		var fragment: Dictionary = by_moment.get(moment_id, {})
		var state := "fragment" if not fragment.is_empty() else "dormant"
		var title := str(fragment.get("display_name", "UNRESOLVED MEMORY"))
		var subtitle := "CHAPTER 01 · RECOVERED" if state == "fragment" else moment_id.replace("_", " ")
		_add_shard(moment_id, title, subtitle, state, 2.2 + float(index) * 0.91, fragment)
	_update_labels()
	queue_redraw()

func _add_shard(id: String, title: String, subtitle: String, state: String, angle: float, fragment: Dictionary = {}) -> void:
	var anchor := Node3D.new()
	anchor.name = "Fragment_%s" % str(fragment.get("fragment_id", id)) if state == "fragment" else "Shard_%s" % id
	anchor.set_meta("display_state", state)
	anchor.set_meta("fragment_identity", str(fragment.get("fragment_id", "")))
	anchor.set_meta("chapter_id", str(fragment.get("chapter_id", "chapter_01")))
	if state == "active":
		Midground_Active.add_child(anchor)
	else:
		Background_Constellation.add_child(anchor)
	anchor.position = Vector3(cos(angle) * 2.8, sin(angle) * 1.25, -1.5 if state == "active" else -4.0)
	shards.append({"id": id, "title": title, "subtitle": subtitle, "state": state, "angle": angle, "fragment": fragment.duplicate(true), "anchor": anchor})

func _update_labels() -> void:
	if profile == null:
		profile_panel.text = "PROFILE  ·  The archive is waiting for its first restored pattern."
	else:
		var fragments := WitnessArchive.recovered_truth_fragments(profile)
		var blooms := WitnessArchive.chapter_blooms(profile)
		var chapter_one: Dictionary = blooms.get("chapter_01", {})
		profile_panel.text = "PROFILE  ·  Aperture %d · %s     %d Resonance     %d Truth Fragment%s" % [profile.aperture_rank, profile.aperture_title, profile.resonance, fragments.size(), "s" if fragments.size() != 1 else ""]
		if not fragments.is_empty():
			hint_label.text = "%s is held in the Iris.  Chapter 01 bloom: %d / %d" % [str(fragments[0].get("display_name", "Recovered Truth")), int(chapter_one.get("recovered_count", 0)), int(chapter_one.get("total_count", 5))]

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	elapsed += delta
	camera_focus = camera_focus.lerp(camera_target, minf(1.0, delta * 2.0))
	if HubCamera != null:
		HubCamera.position = camera_focus
	for shard in shards:
		var anchor: Node3D = shard.get("anchor")
		if is_instance_valid(anchor):
			var speed := ORBIT_SPEED * (0.72 if shard.get("state", "") == "active" else 0.36)
			var a: float = shard.get("angle", 0.0) + elapsed * speed
			anchor.position.x = cos(a) * (2.55 if shard.get("state", "") == "active" else 3.7)
			anchor.position.y = sin(a) * (1.12 if shard.get("state", "") == "active" else 1.72)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_update_focus(event.position)
	elif (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_select_at(event.position)

func _update_focus(pointer: Vector2) -> void:
	var nearest := _nearest_shard(pointer)
	var next_id := str(nearest.get("id", ""))
	if next_id == focused_shard_id:
		return
	focused_shard_id = next_id
	if focused_shard_id.is_empty():
		camera_target = Vector3(0.0, 0.0, 8.0)
		shard_released.emit()
	else:
		camera_target = Vector3(0.0, 0.0, 7.35 if next_id == "FM_001" else 7.7)
		IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui/shard_hover.ogg")
		shard_focused.emit(_normalized_target(_shard_position(nearest)), next_id)
	queue_redraw()

func _select_at(pointer: Vector2) -> void:
	var shard := _nearest_shard(pointer)
	if shard.is_empty():
		return
	selected_shard_id = str(shard.get("id", ""))
	shard_selected.emit(selected_shard_id)
	if selected_shard_id == "FM_001":
		active_memory_selected.emit()
	else:
		# Completed/dormant constellation shards prove selection without granting
		# new navigation ownership; Archive remains its established destination.
		archive_requested.emit()

func _nearest_shard(pointer: Vector2) -> Dictionary:
	var result := {}
	var nearest_distance := INF
	for shard in shards:
		var distance := pointer.distance_to(_shard_position(shard))
		if distance <= FOCUS_RADIUS and distance < nearest_distance:
			nearest_distance = distance
			result = shard
	return result

func _shard_position(shard: Dictionary) -> Vector2:
	var center := Vector2(size.x * 0.5, size.y * 0.458)
	var is_active: bool = str(shard.get("state", "")) == "active"
	var radius := 142.0 if is_active else 212.0
	var vertical := 72.0 if is_active else 118.0
	var angle: float = float(shard.get("angle", 0.0)) + elapsed * ORBIT_SPEED * (0.72 if is_active else 0.36)
	return center + Vector2(cos(angle) * radius, sin(angle) * vertical)

func _normalized_target(position_value: Vector2) -> Vector2:
	var safe_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	return (position_value - safe_size * 0.5) / safe_size

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.002, 0.015, 0.021, 0.29))
	var center := Vector2(size.x * 0.5, size.y * 0.458)
	# Spatial depth bands: the actual Iris remains visible beneath these layers.
	for index in range(4, 0, -1):
		var amount := float(index) / 4.0
		draw_arc(center, 150.0 + amount * 100.0, 0.0, TAU, 64, Color(0.15, 0.64, 0.54, 0.025 * (1.0 - amount * 0.55)), 1.0, true)
	for shard in shards:
		var position_value := _shard_position(shard)
		var state: String = shard.get("state", "")
		var focused := str(shard.get("id", "")) == focused_shard_id
		var selected := str(shard.get("id", "")) == selected_shard_id
		var radius := 15.0 if state == "active" else (12.0 if state == "fragment" else 9.0)
		radius += 4.0 if focused else 0.0
		var alpha := 0.82 if state == "active" else (0.88 if state == "fragment" else 0.30)
		var tint := Color("#6ce1be") if state == "active" else (Color("#f2c86f") if state == "fragment" else Color("#477a73"))
		if state != "active":
			draw_line(center, position_value, Color(tint, alpha * 0.13), 0.8, true)
		for ring in range(3, 0, -1):
			var spread := 1.0 + float(ring) * 0.58
			draw_circle(position_value, radius * spread, Color(tint, alpha * (0.035 + (0.04 if focused else 0.0))))
		draw_circle(position_value, radius, Color(tint, alpha))
		draw_circle(position_value + Vector2(-radius * 0.18, -radius * 0.18), radius * 0.28, Color(0.92, 1.0, 0.96, alpha))
		var label_color := Color(0.86, 1.0, 0.94, alpha) if focused or state == "active" else Color(0.48, 0.72, 0.66, alpha)
		draw_string(ThemeDB.fallback_font, position_value + Vector2(-66, radius + 17), str(shard.get("title", "")), HORIZONTAL_ALIGNMENT_CENTER, 132, 9, label_color)
		if focused or selected:
			draw_arc(position_value, radius + 8.0, 0.0, TAU, 28, Color(tint, 0.72), 1.0, true)

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

extends Node3D
class_name ClockWitnessExperience

## Clock Witness — the first Diorama-powered memory.
##
## This scene is rendered by the Diorama Engine. It represents the same original
## idea as the retired "Missing Second" (a station waiting room where a clock
## holds one missing second), but it is a NEW Diorama experience — it does not
## inherit the old Control-based scene, its assets, or its input model.
##
## ┌──────────────────────────────────────────────────────────────────────┐
## │ SCAFFOLD STATE                                                        │
## │ The launch path (Iris → Diorama Engine → 3D experience → return) is  │
## │ real and tested here. The 3D content is intentionally minimal          │
## │ placeholder geometry: a room shell, a bench, and a placeholder clock   │
## │ with a rotating second-hand box so the engine is demonstrably 3D and  │
## │ animated. Production environment/clock/traveler/props arrive per the   │
## │ MISSION_073D asset gate and the 073E stylized-cinematic-3D direction. │
## └──────────────────────────────────────────────────────────────────────┘

signal completed
signal return_requested

const ENTRY_LINE := "A memory is forming behind the Iris."
const SCAFFOLD_NOTE := "DIORAMA SCAFFOLD · production art pending"

var _floor_mesh: MeshInstance3D
var _clock_pivot: Node3D
var _entry_label: Label
var _scaffold_label: Label
var _return_action: Button
var _ui_canvas: CanvasLayer
var _elapsed := 0.0

# Clock composition (centered, eye-level on the back wall so it is clearly
# visible and its rotating second-hand reads at portrait mobile size).
const CLOCK_CENTER := Vector3(0.0, 1.75, -2.92)
const DIAL_SIZE := Vector3(1.7, 1.7, 0.08)
const HAND_OFFSET := Vector2(0.0, 0.34)  # hand extends upward from pivot
const HAND_SIZE := Vector3(0.10, 0.70, 0.05)
const HAND_SPEED := 1.35

func begin() -> void:
	_build_stage()
	_build_ui()
	_elapsed = 0.0

func close() -> void:
	# Scaffold: nothing persistent (audio/anim) to tear down yet.
	pass

func _process(delta: float) -> void:
	_elapsed += delta
	# Rotate the placeholder second-hand around the dial center so the engine is
	# demonstrably 3D and animated.
	if _clock_pivot != null:
		_clock_pivot.rotation.z = _elapsed * HAND_SPEED

# ---------------------------------------------------------------------------
# Stage: minimal placeholder 3D geometry (room shell + bench + clock), centered
# and lit so the Diorama render is clearly visible. Replaced by 073D art.
# ---------------------------------------------------------------------------
func _build_stage() -> void:
	if _floor_mesh != null:
		return  # stage already built

	var slate := _flat_material(Color(0.20, 0.24, 0.28))
	var wall := _flat_material(Color(0.26, 0.28, 0.32))
	var wood := _flat_material(Color(0.40, 0.28, 0.18))
	var rim := _flat_material(Color(0.12, 0.12, 0.13))
	var ivory := _flat_material(Color(0.94, 0.90, 0.78))
	var accent := _flat_material(Color(0.80, 0.20, 0.16))

	# Floor + back wall + side wall (room shell).
	_floor_mesh = _box(Vector3(11.0, 0.1, 9.0), Vector3(0.0, 0.0, 0.0), slate)
	add_child(_floor_mesh)
	add_child(_box(Vector3(11.0, 4.0, 0.1), Vector3(0.0, 2.0, -3.0), wall))
	add_child(_box(Vector3(0.1, 4.0, 9.0), Vector3(-5.0, 2.0, 0.0), wall))

	# Bench (wooden station bench placeholder), lower-mid frame.
	add_child(_box(Vector3(3.0, 0.14, 0.8), Vector3(0.0, 0.6, -0.6), wood))
	add_child(_box(Vector3(0.14, 0.6, 0.7), Vector3(-1.4, 0.3, -0.6), wood))
	add_child(_box(Vector3(0.14, 0.6, 0.7), Vector3(1.4, 0.3, -0.6), wood))

	# Clock on the back wall: dark rim + ivory dial + accent second-hand on a
	# pivot at the dial center.
	add_child(_box(DIAL_SIZE + Vector3(0.18, 0.18, 0.0), CLOCK_CENTER, rim))
	add_child(_box(DIAL_SIZE, CLOCK_CENTER, ivory))
	_clock_pivot = Node3D.new()
	# Place the hand pivot slightly in front of the dial face so the dial does
	# not occlude the second-hand as it rotates.
	_clock_pivot.position = CLOCK_CENTER + Vector3(0.0, 0.0, 0.14)
	add_child(_clock_pivot)
	var hand := _box(HAND_SIZE, Vector3(HAND_OFFSET.x, HAND_OFFSET.y, 0.0), accent)
	_clock_pivot.add_child(hand)

func _build_ui() -> void:
	if _ui_canvas != null:
		return
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.name = "ExperienceUI"
	add_child(_ui_canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_canvas.add_child(root)

	_entry_label = _label(ENTRY_LINE, 17, Color("#ecf8f2"), Vector2(32, 70), Vector2(476, 40), HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(_entry_label)

	_scaffold_label = _label(SCAFFOLD_NOTE, 11, Color("#7a9a92"), Vector2(32, 110), Vector2(476, 22), HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(_scaffold_label)

	_return_action = Button.new()
	_return_action.text = "RETURN TO IRIS"
	_return_action.position = Vector2(42, 822)
	_return_action.size = Vector2(456, 50)
	_return_action.add_theme_font_size_override("font_size", 14)
	_return_action.add_theme_color_override("font_color", Color("#f3fff9"))
	_return_action.mouse_filter = Control.MOUSE_FILTER_STOP
	# Wire the real handler (not a direct signal shortcut) so the interactive
	# path is structurally sound; graphical validation confirms real taps land.
	_return_action.pressed.connect(_on_return_pressed)
	root.add_child(_return_action)

func _on_return_pressed() -> void:
	return_requested.emit()

# ---------------------------------------------------------------------------
# Helpers.
# ---------------------------------------------------------------------------
func _box(half_extents_or_size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	# Build a box of the given full size at position.
	var mesh := BoxMesh.new()
	mesh.size = half_extents_or_size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	return instance

func _flat_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mat.metallic = 0.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return mat

func _label(text_value: String, font_size: int, color: Color, position_value: Vector2, size_value: Vector2, alignment := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

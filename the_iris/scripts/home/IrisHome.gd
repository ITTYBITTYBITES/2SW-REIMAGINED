extends Control
class_name IrisHome

## Retained Home host. Witness entry is intentionally an empty reset state
## until the one bespoke experience is implemented.
signal witness_requested
signal iris_requested

var spatial_hub: SpatialHub
var profile: WitnessProfile

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	spatial_hub = SpatialHub.new()
	spatial_hub.name = "SpatialHub"
	spatial_hub.witness_requested.connect(witness_requested.emit)
	spatial_hub.profile_requested.connect(_on_profile_requested)
	add_child(spatial_hub)
	spatial_hub.configure(profile)

func configure(value_profile: WitnessProfile) -> void:
	profile = value_profile
	if spatial_hub != null:
		spatial_hub.configure(profile)

func _on_profile_requested() -> void:
	if spatial_hub != null:
		spatial_hub.hint_label.text = "Witness: %s" % (profile.witness_name if profile != null else "Unknown")

func update_profile_presentation(value_profile: WitnessProfile) -> void:
	configure(value_profile)

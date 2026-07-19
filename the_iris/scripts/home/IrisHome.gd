extends Control
class_name IrisHome

## Mission 054B host for the Spatial Hub. Existing Application routes remain
## authoritative; this layer only changes how the player encounters them.
signal continue_witness_requested
signal iris_requested
signal memory_intent_focused(normalized_target: Vector2)
signal memory_intent_released
signal memory_selected
signal archive_requested
signal witness_chapters_requested

var spatial_hub: SpatialHub
var profile: WitnessProfile
var registry: IncidentRegistry

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	spatial_hub = SpatialHub.new()
	spatial_hub.name = "SpatialHub"
	spatial_hub.story_requested.connect(_on_story_requested)
	spatial_hub.archive_requested.connect(_on_archive_requested)
	spatial_hub.profile_requested.connect(_on_profile_requested)
	spatial_hub.active_memory_selected.connect(_on_active_memory_selected)
	spatial_hub.shard_focused.connect(_on_shard_focused)
	spatial_hub.shard_released.connect(memory_intent_released.emit)
	spatial_hub.shard_selected.connect(_on_shard_selected)
	add_child(spatial_hub)
	spatial_hub.configure(profile, registry)

func configure(value_profile: WitnessProfile, value_registry: IncidentRegistry) -> void:
	profile = value_profile
	registry = value_registry
	if spatial_hub != null:
		spatial_hub.configure(profile, registry)

func _on_active_memory_selected() -> void:
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/navigation/portal_open.ogg")
	# Selection presence was already emitted by shard_selected before this route.
	continue_witness_requested.emit()

func _on_story_requested() -> void:
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/navigation/portal_open.ogg")
	witness_chapters_requested.emit()

func _on_archive_requested() -> void:
	IrisAudioConsumer.play_manifest_sound("res://assets/audio/navigation/ui_click.ogg")
	archive_requested.emit()

func _on_profile_requested() -> void:
	# Profile is intentionally an in-place foreground view for this foundation.
	# It uses the existing profile authority and does not create a parallel screen.
	if spatial_hub != null:
		spatial_hub._show_profile_focus()

func _on_shard_focused(normalized_target: Vector2, _shard_id: String) -> void:
	memory_intent_focused.emit(normalized_target)

func _on_shard_selected(_shard_id: String) -> void:
	memory_selected.emit()

func update_profile_presentation(value_profile: WitnessProfile) -> void:
	profile = value_profile
	if spatial_hub != null:
		spatial_hub.configure(profile, registry)

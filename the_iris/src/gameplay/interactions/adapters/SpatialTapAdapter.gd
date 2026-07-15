extends InteractionAdapter
class_name SpatialTapInteractionAdapter

var _surface: SpatialTapSurface

func get_adapter_id() -> String:
	return "spatial_tap"

func mount(target_host: Control) -> void:
	super.mount(target_host)
	_surface = SpatialTapSurface.new()
	_surface.configure(challenge_data)
	_surface.payload_collected.connect(_on_payload)
	target_host.add_child(_surface)

func _on_payload(payload: Dictionary) -> void:
	submit(payload)

func set_disabled(disabled: bool) -> void:
	if _surface:
		_surface.set_disabled(disabled)

extends RefCounted
class_name InteractionAdapter
## Generic interaction collector. Adapters emit payloads only; family scoring
## decides what those payloads mean and whether they are correct.

signal interaction_submitted(payload: Variant)

var profile: InteractionProfile
var challenge_data: Dictionary = {}
var host: Control
var _submitted: bool = false

func get_adapter_id() -> String:
	return ""

func configure(interaction_profile: InteractionProfile, instance_data: Dictionary) -> void:
	profile = interaction_profile
	challenge_data = instance_data.duplicate(true)
	_submitted = false

func mount(target_host: Control) -> void:
	host = target_host

func unmount() -> void:
	if host:
		for child: Node in host.get_children():
			child.queue_free()
	host = null

func set_disabled(_disabled: bool) -> void:
	pass

func submit(payload: Variant) -> void:
	if _submitted:
		return
	_submitted = true
	set_disabled(true)
	interaction_submitted.emit(payload)

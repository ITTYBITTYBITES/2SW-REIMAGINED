extends RefCounted
class_name WitnessMomentEvents

signal phase_changed(phase: int, moment_id: String)
signal enter_requested(moment_id: String)
signal production_start_requested(moment_id: String)
signal result_received(result: Dictionary)
signal archive_update_requested(moment_id: String, result: Dictionary)
signal return_requested(moment_id: String)
signal runtime_completed(moment_id: String)
signal runtime_failed(moment_id: String, reason: String)

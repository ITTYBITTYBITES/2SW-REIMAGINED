extends Node
class_name IrisProgressionAdapter

## IrisProgressionAdapter.gd — Connects PlayerProgressService to Iris appearance.
## Observer: quiet, simple. Witness: brighter, active fibers. Archivist: advanced patterns.

func get_current_progression() -> Dictionary:
	if PlayerProgressService:
		var state: Dictionary = PlayerProgressService.get_player_state()
		var witness: Dictionary = state.get("witness_progress", {})
		var rank := str(witness.get("witness_rank", "Observer"))
		var level := int(witness.get("witness_level", 1))
		var completed_count := 0
		var ids: Variant = witness.get("completed_moment_ids", [])
		if ids is Array:
			completed_count = (ids as Array).size()
		return {
			"rank": rank,
			"level": level,
			"completed_moment_count": completed_count
		}
	return {
		"rank": "Observer",
		"level": 1,
		"completed_moment_count": 0
	}

func get_rank_tier() -> String:
	var prog := get_current_progression()
	var rank := str(prog.get("rank", "Observer"))
	if rank.contains("Archivist") or prog.get("completed_moment_count", 0) >= 5:
		return "ARCHIVIST"
	elif rank.contains("Witness") or prog.get("completed_moment_count", 0) >= 2:
		return "WITNESS"
	return "OBSERVER"

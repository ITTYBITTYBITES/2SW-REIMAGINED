extends Node

## MISSION 014 — The Unfinished Canvas validation checks.
## Covers content validation for INC_UNFINISHED_CANVAS / WM_001:
##   1. Incident Definition & Narrative Context
##   2. Observation Phase Profile & 2s Cinematic Parameters
##   3. Reconstruction Fragment Palette & Ghost Outlines
##   4. Investigation Attunements & Discovery Threshold
##   5. Revelation & Archive Mapping Contract
##   6. Runtime Orchestrator Integration & Result Submission
## Returns number of failed checks; 0 = GREEN.

var _passed := 0
var _failed := 0

func _check(label: String, condition: bool, detail: String = "") -> void:
	if condition:
		_passed += 1
		print("PASS | %s" % label)
	else:
		_failed += 1
		print("FAIL | %s | %s" % [label, detail])

func run_checks(_tree: SceneTree) -> int:
	print("=== MISSION 014 UNFINISHED CANVAS CONTENT & LOOP VALIDATION ===")

	var registry := get_tree().root.get_node_or_null("IncidentRegistry")
	_check("C1 IncidentRegistry autoload present", registry != null)
	if registry == null:
		return _finish()

	# --- 1. Incident Definition ---------------------------------------------
	var incident := registry.get_incident("INC_UNFINISHED_CANVAS")
	_check("I1 INC_UNFINISHED_CANVAS loaded from registry", incident != null)
	if incident == null:
		return _finish()

	_check("I2 incident title correct", incident.title == "The Unfinished Canvas", incident.title)
	_check("I3 incident difficulty correct", incident.difficulty.get("baseline", 0) == 1)
	_check("I4 incident required rank is 1", incident.required_rank == 1)
	_check("I5 incident has primary memory case", incident.primary_memory_case_id == "MC_UNFINISHED_CANVAS")

	# --- 2. Witness Moment 001 Contract -------------------------------------
	var director := WitnessExperienceDirector.new()
	get_tree().root.add_child(director)
	var moment := director.select_moment("WM_001")
	_check("M1 WM_001 loaded successfully", moment != null)
	if moment == null:
		director.queue_free()
		return _finish()

	_check("M2 moment title correct", moment.title == "The Unfinished Canvas")
	_check("M3 moment chapter ID correct", moment.chapter_id == "chapter_01_learning_to_notice")
	_check("M4 narrative introduction authored", not moment.narrative_introduction.is_empty(), moment.narrative_introduction)

	# --- 3. Observation Phase Contract --------------------------------------
	var blueprint := moment.to_blueprint()
	var obs := blueprint.get("observation", {})
	_check("O1 observation duration is 2.0s", float(obs.get("duration_seconds", 0.0)) == 2.0)
	var noticeable := obs.get("noticeable_details", {})
	_check("O2 surface details authored", (noticeable.get("surface", []) as Array).size() > 0)
	_check("O3 subtle details authored (prism & light)", (noticeable.get("subtle", []) as Array).size() > 0)

	# --- 4. Reconstruction Phase Contract -----------------------------------
	var recon := blueprint.get("reconstruction", {})
	var palette := recon.get("fragment_palette", [])
	var ghosts := recon.get("ghost_outlines", [])
	_check("R1 fragment palette populated (>5 items)", palette.size() >= 5, "count=%d" % palette.size())
	_check("R2 ghost outlines defined", ghosts.size() >= 4, "count=%d" % ghosts.size())
	_check("R3 iris reconstruction prompt authored", not str(recon.get("iris_prompt", "")).is_empty())

	# --- 5. Investigation Phase Contract ------------------------------------
	var inv := blueprint.get("investigation", {})
	var attunements := inv.get("attunements", [])
	_check("V1 attunements defined (>=3)", attunements.size() >= 3, "count=%d" % attunements.size())
	_check("V2 discovery threshold set", int(inv.get("discovery_threshold", 0)) > 0)
	_check("V3 iris intervention authored", not str(inv.get("iris_intervention", "")).is_empty())

	# --- 6. Revelation & Archive Mapping Contract ---------------------------
	var rev := blueprint.get("revelation", {})
	_check("E1 revelation iris response authored", not str(rev.get("iris_response", "")).is_empty())
	var archive := moment.archive_mapping
	_check("E2 archive mapping title present", archive.get("title", "") == "The Unfinished Canvas")
	_check("E3 archive mapping category present", archive.get("category", "") == "chapter_01")
	_check("E4 archive mapping iris note present", not str(archive.get("iris_note", "")).is_empty())

	# --- 7. Rewards Contract ------------------------------------------------
	var rewards := moment.rewards
	_check("W1 progress points awarded (>0)", int(rewards.get("progress_points", 0)) > 0)
	_check("W2 mastery delta attached", (rewards.get("mastery", {}) as Dictionary).size() > 0)
	_check("W3 achievements attached", (rewards.get("achievements", []) as Array).size() > 0)

	# --- 8. Runtime Simulation ---------------------------------------------
	var orchestrator := WitnessMomentOrchestrator.new()
	get_tree().root.add_child(orchestrator)
	orchestrator.set_director(director)

	var selection := director.get_next_incident({"mode": "story"})
	orchestrator.start_incident(selection)
	await get_tree().process_frame
	await get_tree().process_frame

	_check("S1 orchestrator started INC_UNFINISHED_CANVAS successfully", orchestrator.is_active())
	
	orchestrator.queue_free()
	director.queue_free()

	return _finish()

func _finish() -> int:
	print("=== MISSION 014 VALIDATION RESULT: %d passed, %d failed ===" % [_passed, _failed])
	return _failed

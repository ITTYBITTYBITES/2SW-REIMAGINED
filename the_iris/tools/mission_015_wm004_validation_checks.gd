extends Node

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
	print("=== WM_004 THE FAULTY REACTOR CONTENT & LOOP VALIDATION ===")

	var registry := get_tree().root.get_node_or_null("IncidentRegistry")
	_check("C1 IncidentRegistry autoload present", registry != null)
	if registry == null:
		return _finish()

	var incident := registry.get_incident("INC_FAULTY_REACTOR")
	_check("I1 INC_FAULTY_REACTOR loaded from registry", incident != null)
	if incident == null:
		return _finish()

	_check("I2 incident title correct", incident.title == "The Faulty Reactor")
	_check("I3 incident primary memory case correct", incident.primary_memory_case_id == "MC_FAULTY_REACTOR")

	var director := WitnessExperienceDirector.new()
	get_tree().root.add_child(director)
	var moment := director.select_moment("WM_004")
	_check("M1 WM_004 loaded successfully", moment != null)
	if moment == null:
		director.queue_free()
		return _finish()

	_check("M2 moment title correct", moment.title == "The Faulty Reactor")
	_check("M3 moment chapter ID correct", moment.chapter_id == "chapter_01_learning_to_notice")

	var blueprint := moment.to_blueprint()
	var obs := blueprint.get("observation", {})
	_check("O1 observation duration is 2.0s", float(obs.get("duration_seconds", 0.0)) == 2.0)

	var recon := blueprint.get("reconstruction", {})
	_check("R1 fragment palette populated", (recon.get("fragment_palette", []) as Array).size() >= 5)
	_check("R2 ghost outlines defined", (recon.get("ghost_outlines", []) as Array).size() >= 4)

	var inv := blueprint.get("investigation", {})
	_check("V1 attunements defined", (inv.get("attunements", []) as Array).size() >= 3)

	var rev := blueprint.get("revelation", {})
	_check("E1 revelation response present", not str(rev.get("iris_response", "")).is_empty())

	var orchestrator := WitnessMomentOrchestrator.new()
	get_tree().root.add_child(orchestrator)
	orchestrator.set_director(director)

	var selection := director.get_next_incident({"mode": "story", "incident_id": "INC_FAULTY_REACTOR"})
	orchestrator.start_incident(selection)
	await get_tree().process_frame
	await get_tree().process_frame

	_check("S1 orchestrator started INC_FAULTY_REACTOR successfully", orchestrator.is_active())

	orchestrator.queue_free()
	director.queue_free()

	return _finish()

func _finish() -> int:
	print("=== WM_004 VALIDATION RESULT: %d passed, %d failed ===" % [_passed, _failed])
	return _failed

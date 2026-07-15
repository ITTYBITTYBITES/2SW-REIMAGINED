extends RefCounted
class_name ChallengeResult
## Standard result contract emitted by ResultService.

const CONTRACT_VERSION: int = 1

var session_id: String = ""
var instance_id: String = ""
var family_id: String = ""
var template_id: String = ""
var title: String = "Challenge"
var outcome: String = "incorrect"
var player_response: Variant = null
var correct_answer: Variant = null
var explanation: String = ""
var gameplay_focus: Array[String] = []
var score: int = 0
var progress_earned: Dictionary = {}
var difficulty_performance: Dictionary = {}
var reaction_ms: int = 0
var reveal_data: Dictionary = {}
var recommendation: Dictionary = {}
var replay_metadata: Dictionary = {}
var metadata: Dictionary = {}

func is_correct() -> bool:
	return outcome == "correct"

func to_dictionary() -> Dictionary:
	return {
		"contract_version": CONTRACT_VERSION,
		"session_id": session_id,
		"instance_id": instance_id,
		"family_id": family_id,
		"template_id": template_id,
		"title": title,
		"outcome": outcome,
		"player_response": player_response,
		"correct_answer": correct_answer,
		"explanation": explanation,
		"gameplay_focus": gameplay_focus.duplicate(),
		"score": score,
		"progress_earned": progress_earned.duplicate(true),
		"difficulty_performance": difficulty_performance.duplicate(true),
		"reaction_ms": reaction_ms,
		"reveal_data": reveal_data.duplicate(true),
		"recommendation": recommendation.duplicate(true),
		"replay_metadata": replay_metadata.duplicate(true),
		"metadata": metadata.duplicate(true)
	}

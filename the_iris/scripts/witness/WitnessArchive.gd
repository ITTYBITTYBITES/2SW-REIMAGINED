extends RefCounted
class_name WitnessArchive

## The one Archive Authority for 2SW.
## Tracks and updates completed moment records, calculates mastery levels, and 
## ensures local profile synchronization without creating a duplicate save system.

enum MasteryLevel { NONE, DISCOVERY, UNDERSTANDING, INSIGHT, MASTERY }

## Retrieve a formatted string of the mastery level.
static func mastery_title_for(level: MasteryLevel) -> String:
	match level:
		MasteryLevel.DISCOVERY:
			return "Discovery"
		MasteryLevel.UNDERSTANDING:
			return "Understanding"
		MasteryLevel.INSIGHT:
			return "Insight"
		MasteryLevel.MASTERY:
			return "Mastery"
		_:
			return "None"

## Calculate the mastery level based on the moment record details.
static func calculate_mastery(record: Dictionary) -> MasteryLevel:
	var completion_cnt: int = record.get("completion_count", 0)
	if completion_cnt <= 0:
		return MasteryLevel.NONE
		
	var best_acc: float = float(record.get("best_accuracy", 0.0))
	var unassisted: int = record.get("assistance_free_completions", 0)
	var clues: Array = record.get("discovered_clues", [])
	
	# Discovery: Completed at least once
	var level := MasteryLevel.DISCOVERY
	
	# Understanding: Accuracy >= 0.8 and found at least 1 clue
	if best_acc >= 0.8 and clues.size() >= 1:
		level = MasteryLevel.UNDERSTANDING
		
	# Insight: Accuracy >= 0.9, unassisted, and found at least 2 clues
	if best_acc >= 0.9 and unassisted >= 1 and clues.size() >= 2:
		level = MasteryLevel.INSIGHT
		
	# Mastery: Replayed at least once (completion_count >= 2), accuracy >= 0.95, unassisted, and fully explored (3 clues)
	if completion_cnt >= 2 and best_acc >= 0.95 and unassisted >= 1 and clues.size() >= 3:
		level = MasteryLevel.MASTERY
		
	return level

## Updates a profile's moment record with new archive parameters.
## This operates in-place inside the profile's moment_records dictionary.
static func update_archive_entry(profile: WitnessProfile, moment_id: String, result: Dictionary, resonance_award: int) -> void:
	if profile == null or moment_id.is_empty():
		return
		
	var records: Dictionary = profile.moment_records
	var record: Dictionary = records.get(moment_id, {})
	
	# Ensure basic fields exist
	record["moment_id"] = moment_id
	record["completion_count"] = int(record.get("completion_count", 0)) # updated by profile already, or set here
	
	# First completed date (standard ISO representation)
	if not record.has("first_completed_date") or str(record["first_completed_date"]).is_empty():
		var datetime := Time.get_datetime_dict_from_system()
		record["first_completed_date"] = "%04d-%02d-%02d %02d:%02d" % [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute]
		
	# Best accuracy
	if result.has("accuracy"):
		var accuracy := float(result["accuracy"])
		record["best_accuracy"] = maxf(float(record.get("best_accuracy", 0.0)), accuracy)
		
	# Highest resonance
	record["highest_resonance"] = maxi(int(record.get("highest_resonance", 0)), resonance_award)
	
	# Times replayed
	var completion_count: int = record.get("completion_count", 0)
	record["times_replayed"] = maxi(0, completion_count - 1)
	
	# Discovered clues tracking
	var discovered_clues: Array = record.get("discovered_clues", [])
	if result.has("discovered_clues") and result["discovered_clues"] is Array:
		for clue in result["discovered_clues"]:
			var clue_str := str(clue)
			if not discovered_clues.has(clue_str):
				discovered_clues.append(clue_str)
	else:
		# Fallback if specific clue arrays aren't provided: if accuracy is perfect or the player completed contexts
		# we infer they found the standard 3 clues
		if float(record.get("best_accuracy", 0.0)) >= 0.9 and discovered_clues.size() < 3:
			for i in range(1, 4):
				var default_clue := "clue_%d" % i
				if not discovered_clues.has(default_clue):
					discovered_clues.append(default_clue)
		elif discovered_clues.is_empty():
			discovered_clues.append("clue_1") # at least 1 clue found on completion
			
	record["discovered_clues"] = discovered_clues
	
	# Best mastery level
	var computed_mastery := calculate_mastery(record)
	record["best_mastery"] = maxi(int(record.get("best_mastery", int(MasteryLevel.DISCOVERY))), int(computed_mastery))
	
	# Write back to profile
	profile.moment_records[moment_id] = record

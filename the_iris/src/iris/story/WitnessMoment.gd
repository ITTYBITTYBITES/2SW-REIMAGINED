extends Resource
class_name WitnessMoment

## Placeholder contract for future Story Mode moments.
## This resource contains no gameplay logic and does not replace the production
## ChallengeSessionService or family contracts.

@export var moment_id := ""
@export var chapter_id := ""
@export var title := ""
@export var setting := ""
@export var theme := ""
@export var rank_requirement := 1
@export_multiline var narrative_introduction := ""
@export var observation_mechanic := "Observation Mechanic TBD"
@export var memory_mechanic := "Memory Reconstruction Mechanic TBD"
@export var discovery_mechanic := "Discovery Mechanic TBD"
@export var evidence_mechanic := "Evidence Connection Mechanic TBD"
@export var reflection_mechanic := "Reflection Mechanic TBD"
@export var environment: Dictionary = {}
@export var observation: Dictionary = {}
@export var reconstruction: Dictionary = {}
@export var investigation: Dictionary = {}
@export var revelation: Dictionary = {}
@export var rewards: Dictionary = {}
@export var archive_mapping: Dictionary = {}

static func from_dictionary(data: Dictionary) -> WitnessMoment:
    var moment := WitnessMoment.new()
    moment.moment_id = str(data.get("moment_id", ""))
    moment.chapter_id = str(data.get("chapter_id", ""))
    moment.title = str(data.get("title", ""))
    moment.setting = str(data.get("setting", ""))
    moment.theme = str(data.get("theme", ""))
    moment.rank_requirement = int(data.get("rank_requirement", 1))
    moment.narrative_introduction = str(data.get("narrative_introduction", ""))
    var mechanics: Dictionary = data.get("mechanics", {})
    moment.observation_mechanic = str(mechanics.get("observation", "Observation Mechanic TBD"))
    moment.memory_mechanic = str(mechanics.get("memory", "Memory Reconstruction Mechanic TBD"))
    moment.discovery_mechanic = str(mechanics.get("discovery", "Discovery Mechanic TBD"))
    moment.evidence_mechanic = str(mechanics.get("evidence", "Evidence Connection Mechanic TBD"))
    moment.reflection_mechanic = str(mechanics.get("reflection", "Reflection Mechanic TBD"))
    moment.environment = (data.get("environment", {}) as Dictionary).duplicate(true)
    moment.observation = (data.get("observation", {}) as Dictionary).duplicate(true)
    moment.reconstruction = (data.get("reconstruction", {}) as Dictionary).duplicate(true)
    moment.investigation = (data.get("investigation", {}) as Dictionary).duplicate(true)
    moment.revelation = (data.get("revelation", {}) as Dictionary).duplicate(true)
    moment.rewards = (data.get("rewards", {}) as Dictionary).duplicate(true)
    moment.archive_mapping = (data.get("archive_mapping", {}) as Dictionary).duplicate(true)
    return moment

func is_placeholder() -> bool:
    return false

func to_blueprint() -> Dictionary:
    return {
        "moment_id": moment_id,
        "chapter_id": chapter_id,
        "title": title,
        "setting": setting,
        "theme": theme,
        "rank_requirement": rank_requirement,
        "narrative_introduction": narrative_introduction,
        "mechanics": {
            "observation": observation_mechanic,
            "memory": memory_mechanic,
            "discovery": discovery_mechanic,
            "evidence": evidence_mechanic,
            "reflection": reflection_mechanic
        },
        "environment": environment.duplicate(true),
        "observation": observation.duplicate(true),
        "reconstruction": reconstruction.duplicate(true),
        "investigation": investigation.duplicate(true),
        "revelation": revelation.duplicate(true),
        "rewards": rewards.duplicate(true),
        "archive_mapping": archive_mapping.duplicate(true)
    }

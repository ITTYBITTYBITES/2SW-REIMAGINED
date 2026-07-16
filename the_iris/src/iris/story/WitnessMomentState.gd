extends RefCounted
class_name WitnessMomentState

# Lifecycle state for one moment. It contains transient orchestration only.
enum Phase {
    DORMANT,
    ARRIVING,
    ATTUNING,
    OBSERVING,
    RECONSTRUCTING,
    INVESTIGATING,
    REVEALING,
    REFLECTING,
    REWARDING,
    ARCHIVING,
    RETURNING,
    COMPLETED,
    FAILED
}

var moment_id: String = ""
var moment_version: int = 1
var phase: int = Phase.DORMANT
var beat_index: int = 0
var production_route: String = ""
var production_session_id: String = ""
var started_at_ms: int = 0
var result_committed: bool = false
var resume_allowed: bool = true

func snapshot() -> Dictionary:
    return {
        "moment_id": moment_id,
        "moment_version": moment_version,
        "phase": phase,
        "beat_index": beat_index,
        "production_route": production_route,
        "production_session_id": production_session_id,
        "started_at_ms": started_at_ms,
        "result_committed": result_committed,
        "resume_allowed": resume_allowed
    }

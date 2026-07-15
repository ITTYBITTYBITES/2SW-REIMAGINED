extends RefCounted
class_name FutureWitnessMechanics

## Names are temporary design containers, not player-facing challenge types.
const OBSERVATION := "Observation Mechanic TBD"
const MEMORY := "Memory Reconstruction Mechanic TBD"
const DISCOVERY := "Discovery Mechanic TBD"
const EVIDENCE := "Evidence Connection Mechanic TBD"
const REFLECTION := "Reflection Mechanic TBD"

static func all() -> Array[String]:
    return [OBSERVATION, MEMORY, DISCOVERY, EVIDENCE, REFLECTION]

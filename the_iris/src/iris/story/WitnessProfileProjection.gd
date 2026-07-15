extends Resource
class_name WitnessProfileProjection

## Presentation-only projection contract for the future Your Iris space.
## Production ProfileService and PlayerProgressService remain authoritative.

@export var rank_name := "Observer"
@export var rank_progress := 0.0
@export var completed_moments := 0
@export var mastery: Dictionary = {}
@export var discoveries := 0
@export var achievements := 0
@export var personal_records: Dictionary = {}
@export var calibration: Dictionary = {}

func to_dictionary() -> Dictionary:
    return {
        "rank_name": rank_name,
        "rank_progress": rank_progress,
        "completed_moments": completed_moments,
        "mastery": mastery.duplicate(true),
        "discoveries": discoveries,
        "achievements": achievements,
        "personal_records": personal_records.duplicate(true),
        "calibration": calibration.duplicate(true)
    }

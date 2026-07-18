# Witness Moment Content Architecture Pass Report

## 1. Executive Summary
This report summarizes the design and implementation of the scalable foundation for data-driven Witness Moments. In accordance with Mission 027, the architecture transitions from hardcoded interactive loops to a fully modular, data-driven loading and generic experience flow.

A new Witness Moment can now be created completely via a structured JSON definition file. The new Generic Witness Gameplay controller reads this configuration to dynamically construct the gameplay phases, interactive hotspots, capture timelines, evidence node lists, and reward structures.

---

## 2. Deliverables Status

| Deliverable | File Path | Status |
| :--- | :--- | :---: |
| **Audit Report** | `WITNESS_CONTENT_ARCHITECTURE_AUDIT.md` | **COMPLETED** |
| **Data Contract** | `the_iris/scripts/witness/WitnessMomentDefinition.gd` | **COMPLETED** |
| **Content Loader** | `the_iris/scripts/witness/WitnessContentLoader.gd` | **COMPLETED** |
| **Test Data Moment** | `the_iris/content/witness/wm_test.json` | **COMPLETED** |
| **Generic Experience Flow** | `the_iris/scripts/gameplay/GenericWitnessGameplay.gd` | **COMPLETED** |
| **Application Integration** | `the_iris/scripts/Application.gd` & `WitnessChapters.gd` | **COMPLETED** |
| **Implementation Report** | `WITNESS_CONTENT_ARCHITECTURE_PASS_REPORT.md` | **COMPLETED** |

---

## 3. Witness Moment Data Contract

The data contract is formally defined as a typed RefCounted object in `the_iris/scripts/witness/WitnessMomentDefinition.gd`. It maps raw dictionary/JSON entries into strongly typed configurations:

```gdscript
extends RefCounted
class_name WitnessMomentDefinition

var moment_id: String
var incident_id: String
var title: String
var subtitle: String
var description: String
var observation_duration: float
var background_path: String
var action_path: String
var reveal_path: String

# Dynamic interactive configurations
var anomaly_definition: Dictionary  # { location: {x,y}, size: {x,y}, misstep_text, success_text }
var capture_window: Dictionary      # { start_time, end_time, hold_duration, guidance_text, success_text }
var evidence_nodes: Array[Dictionary] # Array of Evidence Node Data { identifier, location: {x,y}, description, relevance, truth_connection }
var resolution_text: String
var reward_definition: Dictionary   # { base_resonance, accuracy_multiplier, unassisted_bonus }
```

---

## 4. Witness Content Loader

The loader is implemented inside `the_iris/scripts/witness/WitnessContentLoader.gd`. It is a utility class responsible for:
1. **Validation:** Assuring that raw files adhere to the mandatory schema keys (`id`/`moment_id`, `incident_id`, `title`, `subtitle`, and `description`/`introduction`).
2. **Translation:** Mapping file properties into structured `WitnessMomentDefinition` instances.
3. **Compatibility/Fallbacks:** Seamlessly generating default configurations and evidence nodes if older formats (or incomplete telemetry JSON files) are loaded, ensuring absolute stability.

---

## 5. Generic Experience Flow

The reusable gameplay controller is implemented in `the_iris/scripts/gameplay/GenericWitnessGameplay.gd`. It is fully data-driven and steps players through 8 dynamic phases:

1. **Briefing (`BRIEFING`):** Dynamically loads briefing metadata and background texture.
2. **Observation (`OBSERVATION`):** Spawns a countdown clock matching the specific `observation_duration` parameter.
3. **Anomaly Identification (`ANOMALY`):** Places the interactive round button at the coordinates from `anomaly_definition.location` with dimensions from `anomaly_definition.size`. Reduces accuracy per click outside the hotspot using custom `misstep_text`.
4. **Capture (`CAPTURE`):** Tracks input holds against the precise timeline start/end boundaries declared in `capture_window`.
5. **Timeline Review (`REVIEW`):** Empowers the player to scrub a slider through time, unlocking the next phase as they approach the center of the anomaly window.
6. **Clue Gathering (`CONTEXT`):** Dynamically builds an interactive list of buttons matching the `evidence_nodes` array. Each button displays its unique description, and clicking it unlocks unique guidance text.
7. **Resolution (`RESOLUTION`):** Shows the full, restored memory text. Emits a structured `WitnessMomentResult` summarizing the player's accuracy, mastery, and unassisted status.
8. **Progression Reward (`REWARD`):** Shows progression awards (Resonance, Aperture Rank/Title) from the profile, and returns the player to the settled Iris Hub.

---

## 6. Integration and Validation

### 6.1. Registration
The test moment `the_iris/content/witness/wm_test.json` has been appended to the playable catalogue in `IncidentRegistry.gd` (`MOMENT_PATHS`), allowing it to load automatically at boot.

### 6.2. Interception & Compatibility Layer
To preserve the original narrative viewer for the 5 existing moments, `WitnessChapters.gd` was updated to support a clean routing hook:
```gdscript
func open_moment(moment_id: String) -> void:
	if moment_id == "WM_TEST":
		generic_moment_requested.emit(moment_id)
		return
	# Existing narrative orchestrator code...
```
This is monitored by `Application.gd`, which immediately activates the `GenericWitnessGameplay` screen when `WM_TEST` is selected, loads the configuration using `WitnessContentLoader`, steps through the full interactive flow, persists reward resonance to the profile, and gracefully returns to the Home Hub.

---

## 7. Protection and Boundaries Compliance
No protected systems were modified during this pass. All core files including `IrisCore`, `LivingIris`, `IrisPersonalityResolver`, `IrisResponseIntent`, `WitnessMomentOrchestrator`, and `WitnessExperienceDirector` were preserved exactly as they were.

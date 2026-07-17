# Incident Registry — Content Authoring (MISSION 012)

This directory is the data authority for the **Incident Registry**
(`res://src/iris/story/registry/IncidentRegistry.gd`, autoload `IncidentRegistry`).

Architecture law (MISSION 008 contract):

- **Content is data. Runtime is universal.**
- No incident may require custom controller code.
- A new incident is valid only if it can be added as data plus existing
  registered mechanics.
- Chapters are content grouping only. Rank is evaluated by the progression
  authority (`PlayerProgressService`), never by content routes.

## Adding an incident

1. Author a new `incident_*.json` file using the schema below.
2. Add its `res://` path to `registry_manifest.json` → `incidents`.
3. Ship. No code changes are required.

## Files

| File | Role |
|---|---|
| `registry_manifest.json` | Lists every incident definition file the registry loads, plus manifest/schema versions. |
| `incident_*.json` | One Incident definition each, with embedded Memory Case blocks. |

## Incident schema (schema_version 1)

Required fields: `incident_id`, `title`, `mode_eligibility`, `memory_cases`
(with `memory_case_id` and `witness_moment_ids`), `mechanics_used`, `version`.

Full contract fields: `schema_version`, `incident_id`, `title`, `subtitle`,
`description`, `status` (`active`/`draft`/`retired`), `mode_eligibility`
(`story`, `daily`, `challenge`, `training`, `archive_replay`), `memory_cases`,
`primary_memory_case_id`, `chapter_arc_association`, `narrative_thread_ids`,
`difficulty`, `required_rank`, `mechanics_used`, `observation_data_ref`,
`reconstruction_data_ref`, `reasoning_challenge_data_ref`, `audio_refs`,
`visual_refs`, `scoring_rules_ref`, `mastery_tags`, `archive_metadata`,
`iris_evolution_hooks`, `availability_rules`, `replay_rules`,
`training_slices`, `version`, `authoring_metadata`, `validation`,
`selection_priority`.

Rules:

- `incident_id` must be stable, unique, and must not encode finite chapter
  dependency.
- `availability_rules` supported keys: `requires_completed_incident_ids`,
  `min_completed_incidents`, `enabled_from_date`, `enabled_until_date`
  (ISO dates).
- `replay_rules.allow_replay` (default `true`) controls whether completed
  incidents stay eligible.
- `validation.requires_source_content: true` verifies that
  `authoring_metadata.source_content` resolves to a real file, which is how
  the seed migrations stay wired to the authored witness moments.
- Deterministic selection order: uncompleted before completed, then
  `selection_priority`, then `incident_id`. No progression branches.

## Lifecycle states

`REGISTERED → VALIDATED → AVAILABLE → SELECTED → ACTIVE → COMPLETED → ARCHIVED`
with `INVALID` (failed validation) and `FAILED` (runtime failure, decaying)
as terminal/transient side states. Completion history is derived from
`PlayerProgressService`; the registry never writes progression.

Runtime path:

```
WitnessExperienceDirector
        ↓ get_next_incident(context)
IncidentRegistry (this directory = data)
        ↓ selected incident + primary memory case
WitnessMomentOrchestrator.start_incident(selection)
        ↓
Witness Runtime (WM_001–WM_005 validation fixtures)
        ↓ WitnessRuntimeResult
PlayerProgressService (authority) → Iris transition feedback
```

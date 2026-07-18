# Witness Game Loop Foundation Audit

## Scope

This audit covers the fresh `a71c575` repository state before gameplay-foundation implementation. The Living Iris, Iris personality layer, Witness runtime, content, and existing routing were inspected but not changed during this audit.

## Current Witness Runtime

```text
Memory Field
→ IrisHome.witness_requested
→ Application.show_witness()
→ WitnessChapters
→ WitnessExperienceDirector
→ IncidentRegistry
→ WitnessMomentOrchestrator
→ WM_001–WM_005
```

### Current responsibilities

| System | Current responsibility |
| --- | --- |
| `IncidentRegistry` | Loads five authored JSON moments and holds a session-only `completed` dictionary. |
| `WitnessExperienceDirector` | Resolves a selected moment to a small launch contract. |
| `WitnessMomentOrchestrator` | Runs the five current phases: arriving, observing, reconstructing, investigating, revealing. Emits `moment_completed(moment_id)`. |
| `WitnessChapters` | Presents Chapter 01 and the five existing authored moments. |
| `Application` | Routes into Witness, responds to completion with Iris reflection, and returns Home. |

### Existing moment structure

Each `wm_001` through `wm_005` JSON contains authored narrative, observation, reconstruction, attunement, revelation, and asset references. The current runtime treats completion as a successful moment event; it does not currently pass accuracy, anomaly count, assistance use, or replay-mastery result data.

## Existing Persistence and Profile State

There is no current save service, profile, autoload, account, local JSON profile, rank, resonance, archive persistence, daily rotation, mastery score, or Iris evolution data.

The only current completion record is `IncidentRegistry.completed`, which is in-memory and is lost when the process ends.

`project.godot` has no autoload section.

## Existing Navigation and Content Registry

- Application routing is direct and intentionally small: Iris, Iris Hub, and Witness.
- One real Memory Field destination emits the existing `witness_requested` signal.
- `IncidentRegistry` has a static five-file content list.
- No daily moment selector, archive screen, discovery route, replay score model, or expansion registry exists.

## What Works

- Iris Hub → Memory Field → Witness routing
- All five authored moments load and complete
- Iris reflection and Hub return behavior
- Iris expression response intents
- One Iris instance and one Iris lifecycle authority

## Missing Gameplay Foundation

1. **Local Witness Profile** — no persistent identity, name, rank, resonance, completion history, accuracy record, observation-style summary, or Iris-evolution snapshot.
2. **Progression math** — no scalable resonance award model or Aperture Rank mapping.
3. **Result ingestion contract** — current moment completion has no result payload. A profile model must accept optional accuracy, anomaly, assistance, and mastery data without requiring the protected runtime to generate it yet.
4. **Iris evolution hook** — no profile-derived data is available to future Iris visual consumers.
5. **Retention policy** — Daily Witness, Archive, Mastery, and Discovery are not defined as product systems.

## Safe Implementation Boundary

The smallest correct foundation does not alter Witness runtime behavior:

```text
WitnessMomentOrchestrator.moment_completed(moment_id)
→ Application observer
→ WitnessProfile.record_completion(moment_id, {})
→ WitnessProgression
→ IrisEvolutionData hook
→ local WitnessProfileStore persistence
```

This retains the protected `moment_completed(moment_id)` contract. Future runtime changes may pass a result dictionary when real anomaly/accuracy mechanics exist, but the initial profile system must not invent or report false accuracy.

## Required New Foundation Components

| Component | Purpose |
| --- | --- |
| `WitnessProfile` | Local, serializable player identity and cumulative moment records. |
| `WitnessProgression` | Deterministic resonance award and Aperture Rank rules. |
| `WitnessProfileStore` | Small local JSON read/write boundary under `user://`. |
| `IrisEvolutionData` | Derived profile data for future Iris visual consumers; no current Iris modification. |

These components are profile data and local persistence only. They are not accounts, social systems, monetization, daily content, or new navigation frameworks.

## Implementation Order

1. Add serializable profile, progression, evolution-data, and local-store foundation classes.
2. Connect Application as an observer of existing `moment_completed(moment_id)`.
3. Save completion and emit a future Iris-evolution hook without modifying IrisCore, LivingIris, resolver, or intent code.
4. Add deterministic profile/progression tests using an isolated local test path.
5. Add design documents for Daily Witness, Archive, Mastery, and Discovery without implementing those systems.
6. Re-run the full Iris Hub → Memory Field → Witness → completion → return smoke path.

## Protected Systems

The following must remain unchanged:

- `IrisCore`
- `LivingIris`
- `IrisPersonalityResolver`
- `IrisResponseIntent`
- `IncidentRegistry`
- `WitnessExperienceDirector`
- `WitnessMomentOrchestrator`
- Witness runtime UI and behavior
- `WM_001`–`WM_005`
- Existing Witness content and assets

## Audit Validation Baseline

The audit clone opened with Godot `4.6.3.stable.official.7d41c59c4` and passed:

```text
LIVING_IRIS_PRESENCE_PASS: boot, emergence, attention, home, witness, return, and WM_001–WM_005 loaded.
```

## Audit Conclusion

The product has a stable Iris and Witness foundation but no persistent player identity or progression. A small local profile observer can establish retention data without modifying protected Witness systems. Daily Witness, Archive, Mastery, and Discovery should remain design proposals until the core local profile loop has been validated.

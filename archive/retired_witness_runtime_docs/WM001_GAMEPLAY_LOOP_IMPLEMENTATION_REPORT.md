# WM_001 Witness Gameplay Loop — Implementation Report

## Scope

WM_001 is now the reference gameplay loop launched by the existing Continue Witness Memory Shard. The implementation uses existing authored WM_001 text and images and completes through the existing protected director and orchestrator.

No new content registry, Iris architecture, portal, monetization, store, social, multiplayer, or generation pipeline was added.

## Player Flow

```text
Iris Hub
→ Continue Witness Memory
→ Iris briefing
→ two-second observation
→ anomaly discovery
→ capture the moment
→ context collection
→ truth resolution
→ Resonance reward
→ profile update
→ Iris reflection
→ Iris Hub return
```

The first-time instructions are intentionally simple:

1. Watch carefully.
2. Something does not belong.
3. Find the changed detail.
4. Gather context and reveal the truth.

## WM_001 Gameplay Phases

| Phase | Player action |
| --- | --- |
| Briefing | Read the short Iris framing and begin observation. |
| Observation | Watch the action image for two seconds without input. |
| Discovery | Identify the prism anomaly; incorrect attempts affect accuracy. |
| Context | Collect the paused brush, prism, and color-note evidence. |
| Resolution | Read the authored revelation and restore the memory. |
| Reward | See Resonance and Aperture result, then return to Iris Hub. |

## Scoring and Result Contract

`WitnessMomentResult` carries:

- moment ID
- accuracy
- anomalies found / total
- assistance use
- mastery
- observation style

WM_001 uses one real anomaly, accuracy based on discovery missteps, no assistance, and a deliberate observation style.

The result enters the profile only after the existing protected `WitnessMomentOrchestrator` completion event is emitted. Existing generic moments remain completion-only until they receive their own real gameplay result loops.

## Files Added or Modified

| File | Change |
| --- | --- |
| `the_iris/scripts/gameplay/WitnessMomentResult.gd` | Gameplay result data contract. |
| `the_iris/scripts/gameplay/WM001GameplayLoop.gd` | WM_001 reference loop presentation and interactions. |
| `the_iris/scripts/Application.gd` | WM_001 launch, result handoff, reward presentation, and Hub return integration. |
| `the_iris/scripts/home/IrisHome.gd` | Continue Witness Memory now starts the WM_001 reference loop. |
| `the_iris/tests/prototype_smoke.gd` | Automated reference-loop completion and protected WM_002–WM_005 validation. |
| `WITNESS_MOMENT_RESULT_CONTRACT.md` | Result/scoring contract. |
| `WM001_GAMEPLAY_LOOP_IMPLEMENTATION_REPORT.md` | This report. |

## Protected Systems Confirmed Unchanged

- IrisCore
- LivingIris
- IrisPersonalityResolver
- IrisResponseIntent
- WitnessProfile architecture
- IncidentRegistry
- WitnessExperienceDirector
- WitnessMomentOrchestrator
- Existing Witness content
- `WM_001`–`WM_005` authored JSON and assets

## Validation Results

| Validation | Result |
| --- | --- |
| Iris Hub → Continue Witness Memory | Pass |
| Iris attention and guiding response | Pass |
| WM_001 briefing | Pass |
| Two-second observation | Pass |
| Anomaly discovery | Pass |
| Context/evidence interaction | Pass |
| Truth resolution | Pass |
| Resonance result and profile update | Pass |
| Iris reflection and Hub return | Pass |
| WM_002–WM_005 generic runtime completion | Pass |
| Godot 4.6.3 editor and runtime path | Pass |

## Deferred Work

- Real gameplay loops for WM_002–WM_005
- Multiple anomaly types
- Assistance UI
- Mastery presentation
- Archive/profile presentation UI
- Daily Witness
- Portal transitions
- Gameplay expansion beyond the reference loop

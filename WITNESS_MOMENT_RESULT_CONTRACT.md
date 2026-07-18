# Witness Moment Result Contract

## Purpose

A completed gameplay loop produces one result object. The object is passed to the existing local profile foundation after the protected Witness orchestrator emits its existing completion event.

## Current Contract

```text
WitnessMomentResult
├── moment_id
├── accuracy            # 0.0–1.0
├── anomalies_found
├── anomalies_total
├── assistance_used
├── mastery
└── observation_style
```

## WM_001 Prototype

WM_001 produces:

- one anomaly found after the prism discovery
- accuracy reduced only by incorrect discovery attempts
- no assistance used
- deliberate observation style
- no mastery flag on the standard first completion

The result becomes a dictionary consumed by `WitnessProfile.record_completion()`. The protected `WitnessMomentOrchestrator` remains unchanged and continues to emit only `moment_completed(moment_id)`.

## Award Path

```text
WM001GameplayLoop
→ WitnessMomentResult
→ Application pending result map
→ existing orchestrator completion event
→ WitnessProfile.record_completion(moment_id, result)
→ WitnessProgression award
→ local profile save
→ Iris evolution hook
```

No result is fabricated for existing generic moments. They continue to receive the profile foundation's completion-only award until real gameplay results are implemented for them.

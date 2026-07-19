# IRIS_DEV_LOG.md

## Mission 071B — Witness Runtime Reset Execution

Date: 2026-07-19

The retired Witness content/runtime branch was removed from the active project after a verified pre-reset archive snapshot was created. The active application now contains the Living Iris platform and an intentional empty Witness entry state while the first bespoke experience is planned.

See:

- `WITNESS_RUNTIME_RESET_REPORT.md`
- `MISSION_071_FIRST_WITNESS_EXPERIENCE_PLAN.md`
- `archive/retired_witness_runtime_docs/`

## Mission 073 — The Missing Second Production Build

Date: 2026-07-19

A bespoke first experience was built without restoring any retired Witness runtime, moment IDs, content registry, generic phase system, old result object, or old progression/Archive interpretation.

### Active route

```text
Iris Home WITNESS
→ Iris portal
→ MissingSecondExperience
→ local truth resolution
→ RETURN TO IRIS
→ Iris Home
```

### Scene-local implementation

- `scenes/MissingSecondExperience.tscn`
- `scripts/experience/MissingSecondExperience.gd`
- `scripts/experience/MissingSecondClock.gd`
- `scripts/experience/MissingSecondProps.gd`

The waiting room uses layered new assets, an independent clock hand, traveler motion, tea steam, platform light, photograph reveal, scene-native physical examinations, station tone, clock tick, and resolution cue.

### Status

Godot runtime validation reaches completion and return. Human graphical acceptance is still pending; no commercial-quality or release claim is made until graphical evidence confirms player comprehension and visual quality.

See `MISSION_073_PRODUCTION_BUILD_REPORT.md`.

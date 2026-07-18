# FM_001 Experience Polish Audit

## Scope

This audit reviews the existing FM_001 — The Borrowed Light prototype before polish. No Iris architecture, profile architecture, Witness runtime, authored WM content, or gameplay code was changed during this audit.

## Current Player Path

```text
Iris Hub
→ Continue Witness Memory
→ Iris briefing
→ automatic two-second observation
→ anomaly hotspot
→ repeat / hold capture
→ review slider
→ three evidence selections
→ resolution
→ Resonance reward
→ reflective Hub return
```

## What Is Already Clear

- The Iris briefing establishes that the player is entering a broken moment.
- Observation is intentionally short and non-interactive.
- The anomaly has a distinct discovery target.
- The hold capture is a different action from ordinary tapping.
- The review slider introduces the idea that the player can revisit a two-second truth.
- Evidence, resolution, Resonance, profile update, and reflection all exist in one complete loop.

## Friction Points

| Stage | Current friction | Polish requirement |
| --- | --- | --- |
| Briefing | The lower action panel contains little contextual reinforcement. | Add one short, human instruction without extra lore. |
| Observation | The countdown ends cleanly but does not acknowledge the player’s viewing task. | Add a light transition from watching to noticing. |
| Anomaly | The target can be found, but the causal impossibility is not reinforced until after selection. | State the simple contrast: light arrives before its source. |
| Capture | The player must infer the timing from a timer and button alone. | Add a clear fracture window, hold progress, and success/failure feedback. |
| Review | The slider can unlock the phase but has no readable before / fracture / after landmarks. | Add minimal timeline labels and causal feedback at the exact instant. |
| Context | Evidence can be collected but the relationship between the clues is not surfaced until resolution. | Give a one-line cause/effect summary as each clue is carried. |
| Resolution | The truth is present but can land as a text block. | Separate what was wrong from why it mattered. |
| Reward | Resonance and rank are shown, but the Iris relationship is not explicit. | Add a concise line showing that the Iris carried the pattern forward. |
| Return | Existing reflective return is correct. | Preserve it; do not add portal work. |

## First-Time Player Guidance

The reference loop should use only these guidance concepts:

1. Watch carefully.
2. Something does not belong.
3. Hold when the fracture appears.
4. Review why it is impossible.

No tutorial scene, glossary, investigation vocabulary, or repeated instruction layer is required.

## Safe Polish Boundary

Polish may modify only `FlagshipWitnessMoment` presentation and its associated smoke assertions. It may use existing Iris personality events and existing profile reward data, but it must not alter:

- IrisCore
- LivingIris
- IrisPersonalityResolver
- IrisResponseIntent
- WitnessProfile or WitnessProgression architecture
- IncidentRegistry
- WitnessExperienceDirector
- WitnessMomentOrchestrator
- existing WM runtime
- authored WM content

## Implementation Order

1. Add lightweight capture-window and hold-progress feedback.
2. Add review timeline landmarks and exact-fracture confirmation.
3. Improve evidence and resolution copy with cause/effect clarity.
4. Improve reward copy using existing Resonance and Aperture fields.
5. Preserve current result contract and reflective return.
6. Validate the full fresh boot → Hub → FM_001 → reward → Hub flow, plus existing WM_001–WM_005 generic validation.

## Audit Conclusion

FM_001 already proves the correct mechanics. The remaining work is presentation clarity: make the player feel the fracture, understand the cause, and feel that the Iris learned from what they saw. No architecture redesign is needed.

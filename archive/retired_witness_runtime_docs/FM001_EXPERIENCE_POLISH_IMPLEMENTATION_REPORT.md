# FM_001 Experience Polish Implementation Report

## Scope

This pass polishes the existing FM_001 loop only. It does not add a Moment, content pipeline, progression system, Iris system, portal, monetization, social feature, or gameplay architecture.

## First-Time Player Flow

FM_001 now uses short phase guidance rather than tutorial infrastructure:

```text
WATCH CAREFULLY.
→ LET THE MOMENT ARRIVE.
→ SOMETHING ARRIVED TOO SOON.
→ HOLD WHEN YOU SEE THE FRACTURE.
→ FIND THE FRACTURE.
→ THE CLUES EXPLAIN EACH OTHER.
→ YOU RESTORED THE ORDER OF THE MOMENT.
```

The copy stays inside the existing loop and does not introduce investigation terminology or a separate tutorial screen.

## Capture Moment Polish

The existing hold capture mechanic remains unchanged in purpose. Presentation improvements add:

- a visible capture-progress bar,
- a clear inactive state: `WAIT FOR THE LIGHT`,
- a distinct active state: `HOLD NOW · CATCH THE FRACTURE`,
- progress text while holding,
- an explicit fracture cue when the capture window opens,
- a gentle reset cue when the two-second moment repeats.

The player now receives readable feedback that the target is a timing event, not a normal button press.

## Review and Truth Resolution Polish

### Timeline review

The two-second slider now presents:

```text
BEFORE  ·  FRACTURE  ·  AFTER
```

Landing on the causal break confirms that the player stopped the moment at the instant the effect arrived before its cause.

### Evidence relationship

Each clue now explains part of the causal relationship:

- the brush paused before the color could be true,
- the prism had not received the sun,
- the note was waiting for the real light.

Collecting all clues explicitly states that cause and effect have been reversed.

### Resolution

The final reveal now separates:

```text
What was wrong
+
Why it mattered
```

This makes the resolution about restored causality rather than a generic successful interaction.

## Reward Presentation

The existing `WitnessMomentResult → WitnessProfile → WitnessProgression` path is unchanged.

The reward surface now adds:

> Your Iris carried this pattern forward.

Resonance and Aperture Rank remain the only progression presentation. No new progression or profile system was added.

## Files Modified

| File | Change |
| --- | --- |
| `FM001_EXPERIENCE_POLISH_AUDIT.md` | Audit-first player experience review. |
| `the_iris/scripts/gameplay/FlagshipWitnessMoment.gd` | Guidance, capture feedback, review landmarks, evidence relationship copy, resolution clarity, and reward presentation. |
| `FM001_EXPERIENCE_POLISH_IMPLEMENTATION_REPORT.md` | This report. |

## Protected Systems Confirmed Unchanged

- IrisCore
- LivingIris architecture
- IrisPersonalityResolver
- IrisResponseIntent contract
- WitnessProfile architecture
- WitnessProgression architecture
- IncidentRegistry
- WitnessExperienceDirector
- WitnessMomentOrchestrator
- existing WM runtime
- authored WM content

## Validation Results

| Validation | Result |
| --- | --- |
| Fresh boot and Iris awakening | Pass |
| Iris Hub and Memory selection | Pass |
| FM_001 briefing | Pass |
| Two-second observation | Pass |
| Anomaly discovery | Pass |
| Hold capture window | Pass |
| Timeline review | Pass |
| Context/evidence interaction | Pass |
| Truth resolution | Pass |
| Resonance and profile update | Pass |
| Iris reflection and Hub return | Pass |
| Generic WM_001–WM_005 runtime validation | Pass |

## Remaining Limits

- Capture visual feedback is presentation-only; no audio or haptic cue has been added.
- The prototype uses existing temporary studio/prism staging assets.
- Target-device performance and player observation remain required before building more Moment content.

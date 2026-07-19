# Flagship Witness Moment Design

## Audit Scope

This document audits the current WM_001 gameplay prototype and defines one separate flagship reference moment before implementation. No existing WM content, Witness runtime, Iris behavior, or profile architecture was changed during the audit.

## Current WM Gameplay Flow

The current direct WM_001 prototype provides:

```text
Briefing
→ automatic two-second observation
→ prism hotspot discovery
→ three evidence selections
→ authored revelation
→ Resonance reward
→ Iris reflection
```

### What currently works

- Simple first-player language
- A two-second observation timer
- One anomaly target
- Evidence collection
- Existing profile/resonance handoff
- Existing Iris reflection and Hub return

### What is missing from the flagship vision

| Desired experience | Current gap |
| --- | --- |
| Something impossible | The prism target is a detail, not a clearly time-impossible event. |
| Hold to capture the exact truth | Observation ends automatically; there is no timing-based capture input. |
| Manipulate/review the moment | There is no review or timeline control. |
| Emotional hook | The briefing establishes a broken moment but not a personal consequence. |
| Distinct reference content | WM_001 uses existing validation content and should remain technical validation material. |

## Flagship Prototype: FM_001 — The Borrowed Light

### Emotional hook

A painter has one last chance to see the afternoon spectrum that gives a memorial canvas its meaning. The moment returns wrong: the rainbow reaches the canvas before the prism receives the light.

The player is not looking for a generic mistake. They are witnessing a causal impossibility in a memory that is trying to repair itself.

### Player truth

> The light on the canvas appears before the prism can cast it.

### Prototype visual staging

The prototype may use the existing studio/prism visual assets only as temporary staging. FM_001 is a separate design reference and does not redefine WM_001 authored content.

## Reference Gameplay Loop

```text
Iris briefing
→ natural two-second observation
→ notice impossible light order
→ hold during the exact capture window
→ scrub the two-second review
→ collect three context clues
→ resolve the causal truth
→ receive Resonance
→ Iris reflects
→ return to Iris Hub
```

## Phase Design

### 1. Iris Briefing

Player instruction:

> The Iris has held a moment that cannot keep its order. Watch for what arrives too soon.

### 2. Natural Observation

The action plays for two seconds with no input. The player sees the brush, prism, and spectrum moment.

### 3. Impossible Anomaly

The player identifies that the spectrum appears before the prism receives light.

### 4. Capture the Two-Second Truth

The moment repeats. The player holds the capture control only when the impossible order occurs. Holding outside the narrow window fails softly and the memory repeats.

### 5. Review

The player scrubs a two-second timeline to the impossible instant. Reaching the causal break unlocks context.

### 6. Context

The player collects:

- the paused brush
- the prism
- the color note

### 7. Resolution

The player understands that the memory is not showing inspiration; it is showing the moment the light order was broken.

### 8. Reward

The flagship result reports real prototype inputs:

- capture accuracy
- one anomaly found
- no assistance
- deliberate observation style

## Minimal System Boundary

The flagship moment requires only:

- a standalone reference presentation control
- the existing `WitnessMomentResult` contract
- existing local profile recording
- existing Iris personality events
- existing reflective Hub return

It must not modify the protected Witness runtime or authored WM_001–WM_005 content.

## Implementation Order

1. Add one `FlagshipWitnessMoment` presentation control.
2. Route Continue Witness Memory to FM_001 while retaining generic WM runtime access for technical validation.
3. Implement observation, hold capture, review slider, context, resolution, and reward.
4. Record a real result through the existing profile foundation.
5. Re-run existing generic WM_001–WM_005 validation separately.

## Success Criteria

A new player can understand without external explanation:

1. Watch the moment.
2. Notice what arrives too soon.
3. Hold to catch it.
4. Review why it is impossible.
5. Restore the truth.

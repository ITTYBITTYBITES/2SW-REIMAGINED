# Mission 067 — Restore Playable WM_001
# Human Runtime Investigation

**Date:** 2026-07-18  
**Godot runtime used:** `4.6.3.stable.official.7d41c59c4` (headless)  
**Scope:** Runtime investigation and minimal repair only.

## Executive conclusion

The observed WM-001 failure was **not** a missing scene, missing timer, missing interaction object, or broken profile/return system.

The active production path does create the required UI and state machine. The critical defect was a race in `GenericWitnessGameplay.start()`:

1. `start()` set `in_intro_cinematic = true`.
2. `start()` immediately called `_set_phase(BRIEFING)`.
3. `_set_phase(BRIEFING)` made **BEGIN OBSERVATION** visible and interactive while the intro was still active.
4. A human could press it immediately, entering `OBSERVATION` and starting the timer.
5. When the intro timer later expired, `_process()` unconditionally called `_set_phase(BRIEFING)`.
6. That reset the observation state, hid the timer/action sequence, and returned the user to briefing.

This explains the human report that no stable Observe countdown/objective flow appeared even though runtime logs showed WM-001 observation and Fracture events.

A second observed behavior—repeated **Memory Collapse** haptics—means the player reached `SYNCHRONIZATION` but did not sustain the `HOLD FOCUS` action. The existing design drains stability while focus is not held, so it repeatedly resets. This is not a missing state; it is a UX/tuning concern to verify visually after the critical briefing-gate fix.

---

## 1. Actual normal runtime flow

### Production WM-001 path

```text
Spatial Hub / existing Story route
→ WitnessChapters.open_moment("WM_001")
→ WitnessChapters.generic_moment_requested
→ Application.request_memory_portal("WM_001")
→ IrisPortalTransition.begin_entry
→ IrisPortalTransition.entry_arrived
→ Application.start_generic_gameplay("WM_001")
→ WitnessContentLoader.load_moment_definition
→ GenericWitnessGameplay.start
```

### Actual state owner

`GenericWitnessGameplay` is the canonical active production state machine:

```text
BRIEFING
→ OBSERVATION
→ FRACTURE
→ SYNCHRONIZATION
→ CONTEXT
→ REVELATION
→ TRUTH_FRAGMENT
→ REWARD
→ return_requested
→ Application._begin_portal_return
→ Iris Home
```

### Important reconciliation

The requested historical path:

```text
WitnessExperienceDirector → WitnessMomentOrchestrator → WM_001 scene
```

is **not** the active normal player path for production WM-001.

`WitnessExperienceDirector` supplies chapter catalogue data. `WitnessMomentOrchestrator`, `WM001GameplayLoop`, and `FlagshipWitnessMoment` are retained legacy/prototype paths. The normal Chapter selection explicitly emits `generic_moment_requested` for WM-001 through WM-012 and routes them to `GenericWitnessGameplay`.

The earlier headless smoke result was therefore insufficient: it directly forced phases/methods and did not exercise the real intro/action timing sequence a player experiences.

---

## 2. Runtime evidence

### Active scene tree

A real Godot runtime scene-tree capture contained these active controls/controllers:

```text
Application
├── IncidentRegistry
├── WitnessExperienceDirector
├── WitnessMomentOrchestrator
├── IrisController
├── IrisHome / SpatialHub
├── WitnessChapters
├── GenericWitnessGameplay
│   ├── GameplayAction
│   ├── FractureTarget
│   ├── synchronization ProgressBar
│   ├── stability ProgressBar
│   └── evidence VBoxContainer
├── WitnessArchiveUI
├── WM001GameplayLoop              (legacy/prototype, inactive)
├── FlagshipWitnessMoment          (legacy/prototype, inactive)
├── IrisPortalTransition
└── StartupFlow
```

This proves the active production gameplay UI objects are instantiated as children of `GenericWitnessGameplay`.

### Signal connections

The Application connects:

```text
WitnessChapters.generic_moment_requested
  → Application.request_memory_portal

IrisPortalTransition.entry_arrived
  → Application._on_portal_entry_arrived
  → Application.start_generic_gameplay

GenericWitnessGameplay.completion_requested
  → Application._on_generic_completion_requested

GenericWitnessGameplay.return_requested
  → Application._on_generic_return_requested
```

The active controls connect:

```text
GameplayAction.pressed     → GenericWitnessGameplay._advance
GameplayAction.button_down → GenericWitnessGameplay._begin_synchronization_hold
GameplayAction.button_up   → GenericWitnessGameplay._end_synchronization_hold
FractureTarget.pressed     → GenericWitnessGameplay._find_fracture
```

### Timer execution and transitions after repair

The new runtime validation exercised real timers and actual Button signals through the normal Application/portal path:

```text
M067_AFTER_PORTAL
  visible=true
  phase=BRIEFING
  intro=true
  action=false

M067_BRIEFING
  phase=BRIEFING
  intro=false
  action=true

M067_OBSERVE_ENTER
  phase=OBSERVATION
  timer=2.0

M067_FRACTURE
  phase=FRACTURE
  target=true

M067_DISCOVERED
  phase=FRACTURE
  discovered=true
  action=true

M067_SYNC_ENTER
  phase=SYNCHRONIZATION
  action=true
  syncbar=true
  stability=0.82

M067_AFTER_HOLD
  phase=CONTEXT
  synchronized=true
  evidence=true
  stability=1.0

M067_REVELATION
  phase=REVELATION

M067_FRAGMENT
  phase=TRUTH_FRAGMENT

M067_REWARD
  phase=REWARD
  completed=true
  fragment=fragment_borrowed_light

M067_RETURN
  home=true
  iris=true
  generic=false
```

The runtime emitted expected authored observation, Fracture, Synchronization, Revelation, Truth Fragment, absorption, and portal-return sensory hooks.

---

## 3. Root cause and repair

### Root cause

File: `the_iris/scripts/gameplay/GenericWitnessGameplay.gd`

The intro cinematic and first action button were active simultaneously. The intro completion callback reset the phase to briefing after a premature action had already advanced the state.

### Required repair applied

During intro formation:

```text
BRIEFING copy remains visible
BEGIN OBSERVATION is hidden/non-interactive
```

After intro completion:

```text
BRIEFING state is set
BEGIN OBSERVATION becomes visible
```

This removes the state-reset race and ensures the observation timer cannot be bypassed/reset by an early human click.

### Scope of repair

- No gameplay system added.
- No state machine replaced.
- No persistence, Archive, navigation, or portal authority changed.
- The existing canonical generic runtime remains the player path.

---

## 4. Phase-by-phase answer

| Required question | Actual answer |
| --- | --- |
| Which script owns state? | `GenericWitnessGameplay.gd` owns the active production state machine. |
| Is Observe entered? | Yes, after the visible post-intro **BEGIN OBSERVATION** action. |
| Is Observe UI instantiated? | Yes: `phase_label`, `timer_label`, scene image, and action controls exist under `GenericWitnessGameplay`. |
| Does timer start? | Yes. Runtime evidence recorded `timer=2.0` on OBSERVATION entry. |
| Does timer completion work? | Yes. After 2.3 seconds runtime advanced to `FRACTURE`. |
| Is Recall/Selection entered? | There is no active production phase named Recall. The equivalent selection is `FRACTURE`, followed by evidence selection in `CONTEXT`. |
| Are interaction objects registered? | Yes: `FractureTarget`, `GameplayAction`, ProgressBars, and evidence buttons are instantiated and signal-connected. |
| Are selections evaluated? | Yes. Fracture selection sets `discovery_state`; evidence button selections unlock Revelation. |
| Is completion emitted? | Yes. `TRUTH_FRAGMENT` emits `completion_requested`; runtime reached REWARD and persisted `fragment_borrowed_light`. |
| Is return reachable? | Yes. REWARD action emits `return_requested`, triggering existing pupil return; runtime ended at visible Iris Home. |

---

## 5. Legacy path audit

| Path | Status | Normal player use |
| --- | --- | --- |
| `GenericWitnessGameplay` | **Canonical** | WM-001–WM-012 Chapter selection and production moment flow. |
| `WitnessMomentOrchestrator` | Legacy compact phase engine | Not used for normal production WM-001 route. |
| `WM001GameplayLoop` | Legacy WM-001 prototype | Instantiated but not reached by normal current chapter/portal route. |
| `FlagshipWitnessMoment` | Legacy FM-001 prototype | Instantiated but the Hub’s active FM-001 path now routes through generic loader/portal. |
| `MemoryField` | Historical Home shard | Not hosted by current `IrisHome`; SpatialHub is active. |

### Recommendation

Keep legacy paths for now because they may be referenced by older validation/prototype work. Do not extend them. The canonical runtime for future fixes and human play is `GenericWitnessGameplay` via `Application.request_memory_portal()`.

---

## 6. Remaining human-play considerations

### TUNE

- Synchronization can repeatedly collapse when the player does not hold `HOLD FOCUS`; the supplied human log demonstrates this. After the repair, verify the now-visible post-intro objective and HOLD FOCUS control in the graphical runtime.
- Headless runtime proves state/input connections, not visual readability, touch ergonomics, or player comprehension.
- Existing legacy smoke tests should be updated later to avoid claiming the legacy paths are current production behavior.

### BLOCKER

No remaining code-level blocker was found in the complete WM-001 production interaction path after the briefing-gate repair.

A graphical desktop or device confirmation remains required before asserting that a human visually experiences the repaired loop successfully.

---

## 7. Verification status

The real Godot runtime, with actual timers and control signals, now completed:

```text
Portal entry
→ briefing gate
→ Observe timer
→ Fracture target
→ Synchronization hold
→ evidence selection
→ Revelation
→ Truth Fragment
→ profile/Archive completion
→ pupil return
→ Iris Home
```

The repaired path is executable end-to-end. The next human test should verify the same sequence visually with the player-facing controls.
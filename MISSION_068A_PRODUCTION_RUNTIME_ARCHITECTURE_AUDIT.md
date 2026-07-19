# Mission 068A — Verify Production Runtime Architecture

**Date:** 2026-07-19  
**Scope:** Read-only history, scene-structure, route, and script-intent audit. No gameplay architecture, content, persistence, Archive, navigation, or runtime behavior was changed.

## Required answer

# `GenericWitnessGameplay` is: **Production runtime**

It is a deliberately adopted data-driven production runtime, not an abandoned test harness and not a transitional fallback awaiting a hidden authored WM-001 `.tscn` scene.

That does **not** mean its current generated presentation is final-quality. The human report of an image plus empty panel is a valid player-experience problem. It means the correct response is to inspect/fix the canonical production runtime’s visual composition and input UX—not to search for a missing finished WM-001 gameplay scene that the repository was supposed to load.

---

## Evidence 1 — Commit history and original purpose

`GenericWitnessGameplay.gd` was introduced in commit:

```text
465516d — feat: implement data-driven Witness Moment architecture (Mission 027)
```

That commit added both:

```text
Application.gd
GenericWitnessGameplay.gd
```

Later commits expanded the same runtime rather than replacing it:

| Commit | Mission | Evidence of intended role |
| --- | --- | --- |
| `55e4142` | Mission 031 | Elevated Witness visual and sensory presentation in `GenericWitnessGameplay`. |
| `0ae6530` | Mission 032 | Connected Iris sensory presence to the generic runtime. |
| `73c1e41` | Mission 033 | Implemented data-driven Witness Moment asset pipeline. |
| `8168175` | Mission 035 | Added cinematic asset/emotional polish to generic gameplay. |
| `1c3d1bb` | Mission 046 | Integrated Chapter 1 production audio through generic gameplay. |
| `6a9f259` | Mission 050 | Witness Moment discovery/runtime integration. |
| `e0a3845` | Mission 055 | Explicitly identified `GenericWitnessGameplay` as the active Witness Engine evolution target. |
| `2d1fd5a` | Mission 055B | Added WM-001 authored showcase presentation through the generic runtime. |
| `c0cb943`–`adba893` | Missions 058–062 | Migrated WM-002–WM-005 through the same runtime contract. |

The repository’s own production reports explicitly say:

```text
WM_001–WM_005 are played dynamically under GenericWitnessGameplay.
```

and:

```text
GenericWitnessGameplay (Active phase transitions)
```

This is sustained architectural intent, not an accidental test promotion.

---

## Evidence 2 — Scene structure

The repository contains one committed `.tscn` scene:

```text
res://scenes/Application.tscn
```

There are **no** per-moment gameplay `.tscn` scenes for WM-001, WM-002, or any other Witness Moment.

The Application scene intentionally constructs persistent presentation controls programmatically:

```text
Application
├── IrisController
├── IrisHome / SpatialHub
├── WitnessChapters
├── GenericWitnessGameplay
├── WitnessArchiveUI
├── WM001GameplayLoop          # legacy/prototype
├── FlagshipWitnessMoment      # legacy/prototype
└── IrisPortalTransition
```

The current WM-001 visual is therefore not a separately authored scene that has failed to load. The easel/canvas image is supplied through the data definition’s asset paths and rendered by `GenericWitnessGameplay.scene_image`.

---

## Evidence 3 — Canonical production route

Normal production Chapter selection does this:

```text
WitnessChapters.open_moment("WM_001")
→ generic_moment_requested.emit("WM_001")
→ Application.request_memory_portal("WM_001")
→ IrisPortalTransition.entry_arrived
→ Application.start_generic_gameplay("WM_001")
→ WitnessContentLoader.load_moment_definition
→ GenericWitnessGameplay.start(definition)
```

This route is explicit in current code. It bypasses `WitnessMomentOrchestrator` for WM-001 through WM-012.

---

## Evidence 4 — Legacy/prototype paths are distinct

| Path | Introduction / purpose | Current player-route status |
| --- | --- | --- |
| `GenericWitnessGameplay` | Mission 027 data-driven Witness architecture | **Canonical production route** for WM-001–WM-012. |
| `WM001GameplayLoop` | Commit `c2717cb` — “Add WM001 witness gameplay loop prototype” | Legacy WM-001 reference prototype; constructed but not normal route. |
| `FlagshipWitnessMoment` | Commit `02331b5` — “Add flagship witness moment prototype” | Legacy FM-001 prototype; constructed but not normal production WM route. |
| `WitnessMomentOrchestrator` | Compact legacy phase driver | Used by legacy/prototype flows, not direct normal Chapter WM routing. |
| `MemoryField` | Early Home shard implementation | Not hosted by current `IrisHome`; `SpatialHub` is active. |

The legacy paths should not be deleted during this audit. They are evidence of prototype history and may still be referenced by old smoke tests. They should also not be extended: doing so would create a second production runtime.

---

## Evidence 5 — Generated UI is intentional, but visually weakly authored

`GenericWitnessGameplay` constructs its own controls:

```text
GenericWitnessGameplay
├── phase_label
├── title_label
├── body_label
├── timer_label
├── guidance_label
├── Panel                    # likely the observed empty box
├── GameplayAction
├── FractureTarget
├── synchronization_progress
├── stability_progress
└── evidence_container
```

The `Panel` is created at runtime as a visual backing panel. It is not an empty placeholder node waiting for a missing external scene to instantiate.

However, a generated Control hierarchy can still create a poor player experience if label visibility, ordering, sizing, alpha, panel composition, input gating, or display layering are wrong. The observed empty-panel report therefore remains a valid **visual runtime investigation** target.

---

## Architecture classification

| Question | Answer |
| --- | --- |
| Was Generic introduced to validate data-driven loading? | Yes. |
| Was it subsequently adopted for active production moment execution? | Yes. |
| Was it enhanced repeatedly with cinematic, asset, sensory, audio, Fracture, Synchronization, fragment, and showcase work? | Yes. |
| Is there evidence of a missing intended WM-001 authored gameplay `.tscn`? | No. |
| Are current generated controls production UI? | Yes, architecturally. They are procedurally constructed production UI, though their player-facing quality must be validated/fixed. |
| Are older WM-001/flagship loops the intended final player runtime? | No; history and current routes label them prototypes/legacy paths. |

---

## Recommendation

Do **not** replace `GenericWitnessGameplay` or introduce a per-WM scene architecture based on the assumption that one was lost.

The next investigation should be tightly focused on the canonical runtime’s **graphical composition**:

1. Capture a graphical WM-001 state tree after portal arrival.
2. Inspect CanvasItem visibility, `modulate`, z-index, global rectangles, and mouse filters for each generated gameplay control.
3. Capture screenshots at:
   - post-intro briefing;
   - observation countdown;
   - Fracture selection;
   - Synchronization;
   - context/evidence;
   - Revelation;
   - reward.
4. Confirm whether the observed empty panel is the generated `Panel` and whether its sibling labels/buttons are hidden, behind another layer, offscreen, transparent, or visually unreadable.
5. Improve only the canonical runtime presentation if graphical evidence confirms the issue.

## Final conclusion

The problem is not that the repository loads a generic test chamber instead of an intended hidden WM-001 authored scene. The problem is that the **intended data-driven production runtime may still be presenting itself like a scaffold in the actual graphical player experience**.

That is a player-facing production/UI problem, not an architecture-replacement mandate.
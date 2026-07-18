# MISSION 018.5 — LIVING IRIS ARTIFACT AUDIT & CLEANUP — COMPLETE

**Repository:** https://github.com/ITTYBITTYBITES/2SW-REIMAGINED
**Approach:** Full artifact audit against repository contents. Removed only what was verified retired; kept everything current with documented evidence.
**Date:** 2026-07-18
**Cleanup commit:** `ba97d37b6464b54a3f62ddda5c52b6d1ca92eb67` (pushed to `origin/main`)

---

## 0. Executive summary

After the Mission 018 recovery, I searched the entire repository for every requested Iris token (`PortalVoid`, `PupilPortal`, `IrisVisual`, `GlowLayer`, `CalibrationRings`, `IrisDisplay`, `LivingIris`, `IrisCore`, `IrisController`, `iris.gdshader`, plus related portal-layer names). The result: **there is exactly one Living Iris implementation, and it is the current one.** Mission 018 had already eliminated the duplicate iris from `IrisHomeScreen`.

**Exactly one genuine legacy artifact remained**, and it has been removed:

> `the_iris/src/iris/IrisAudioController.gd` (+ `.uid`) — an orphaned audio wrapper referenced by **zero** files, superseded by direct `ProceduralIrisSound` calls inside `IrisController`.

Everything else the mission flagged as "suspicious" (notably **PortalVoid** and the **PupilPortal** system) is **current and load-bearing** — it is the destination-lens navigation that `MainController` depends on. Removing it would break navigation and create exactly the transparency artifacts the mission warns against. So those were **kept**, with evidence below.

**Total change: 2 files deleted, 33 lines removed. No other files modified.**

---

## 1. Legacy Iris artifacts found

| Artifact | Location | Status | Classification |
|---|---|---|---|
| `IrisVisual` | — | **0 occurrences** (removed in Mission 018) | already gone |
| `GlowLayer` | — | **0 occurrences** (removed in Mission 018) | already gone |
| `CalibrationRings` | — | **0 occurrences** (removed in Mission 018) | already gone |
| `IrisDisplay` | — | **0 occurrences** (removed in Mission 018) | already gone |
| `IrisAudioController` | `src/iris/IrisAudioController.gd` | **0 external references** | **REMOVED** |
| `PortalVoid` | `scenes/Iris.tscn` (1×, no script ref) | part of current destination lens | **KEPT** |
| `PupilPortal` / `PupilPortalLayer` | `Iris.tscn`, `IrisController.gd`, `LivingIris3D.gd` | current navigation system | **KEPT** |
| `PortalContainer` / `DestinationPreview` | `Iris.tscn`, `IrisController.gd` | current destination lens | **KEPT** |
| `IrisCore` | `src/iris/IrisCore.gd` | current state machine (used by IrisController) | **KEPT** |
| `LivingIris3D` | `src/iris/LivingIris3D.gd` | current 3D eye layer | **KEPT** |
| `IrisHapticController` | `src/iris/IrisHapticController.gd` | current haptics (instantiated in `_ready`) | **KEPT** |
| `iris.gdshader` | `shaders/iris.gdshader` | the single iris shader (only `Iris.tscn` uses it) | **KEPT** |
| `memory_portal.gdshader` | `shaders/memory_portal.gdshader` | current pupil-portal shader | **KEPT** |

**Duplicate-stack check:** exactly one of each visual layer in `Iris.tscn` — `OuterEnergyLayer`, `Visual`, `LivingIris3D`, `PupilPortalLayer/PortalContainer/PortalVoid/DestinationPreview`, `CorneaLayer`, `MemoryFragmentsContainer`, `Particles`. No competing render stacks.

**Shader check:** only `iris.gdshader` and `memory_portal.gdshader` are Iris shaders (both used solely by `Iris.tscn`). The other shaders (`AttunementShader`, `ObservationMomentShader`, `witness`, `transition`) belong to the **Witness experience screens / TransitionController** — not the Iris, and explicitly out of scope (mission: do not touch Witness Runtime).

---

## 2. Why `PortalVoid` was KEPT (the "suspicious" item)

The mission asked to remove PortalVoid *only if* it belongs to an older portal-style Iris. Evidence says it does **not**:

- **Owner:** `scenes/Iris.tscn` → `PupilPortalLayer/PortalContainer/PortalVoid` — a `TextureRect` (texture `res://assets/iris/pupil_portal.png`, which exists, 3.0 MB) rendered *beneath* the live `DestinationPreview`.
- **Role:** it is the idle portal-ring backing. When the player is not focusing, `DestinationPreview`'s `memory_portal` shader is transparent (alpha is gated by `memory_visibility`), so `PortalVoid` provides the visible aperture ring. When focusing, the shader reveals the memory fragment over it.
- **Why not "legacy":** the entire `PupilPortalLayer` is the **current destination-lens navigation**. `IrisController._update_destination_lens()`, `_apply_destination_preview()`, `_update_portal_shader()` drive it, and `MainController` depends on `iris.active_destination_key`, `iris.destination_title`/`destination_prompt`, and `iris.set_transition_open()` for navigation. The shader's own header reads *"The Living Lens Pupil Portal Shader."*
- **Risk of removal:** would create the transparency/missing-visual artifacts the mission explicitly wants to avoid.

Per the mission's own rule — *"Do not delete anything without confirming it is a retired implementation"* — PortalVoid is **not retired**, so it stays.

---

## 3. Files removed/modified

```
deleted: the_iris/src/iris/IrisAudioController.gd        (32 lines)
deleted: the_iris/src/iris/IrisAudioController.gd.uid    (1 line)
```

`git diff --stat ba97d37`: **2 files changed, 33 deletions(+), 0 insertions(+).**

No scene, no controller, no shader was modified. Per the constraints, the following were **not** touched: Witness Runtime, IncidentRegistry, chapter content (`src/iris/story/...`), Save/Profile systems, and `MainController` architecture.

### Why the removal was safe
`IrisAudioController` was an older wrapper (`class_name IrisAudioController`) that merely delegated to `ProceduralIrisSound` (`set_ambient_state`, `awakening_tone`, `focus_notice_tone`, `settling_tone`). A whole-repository search found **zero** references to the class outside its own file — no scene instantiates it, no script holds a typed var of that class, no autoload uses it. The current Living Iris performs all audio **inline** inside `IrisController` via the `sound_service: ProceduralIrisSound` member. Removing it therefore changes no runtime behavior.

---

## 4. Final Iris architecture (verified)

```
Main (Node2D, MainController)
└── Interface (CanvasLayer)
    └── ScreenRoot (Control)
        ├── IrisScreen  →  scenes/Iris.tscn  →  IrisController.gd   ← THE ONE LIVING IRIS
        │   ├── Visual (ColorRect, iris.gdshader)        ← current iris shader
        │   ├── LivingIris3D                              ← 3D eye (IrisCore-driven)
        │   ├── OuterEnergyLayer / CorneaLayer            ← glow + reflection
        │   ├── PupilPortalLayer/
        │   │   └── PortalContainer/
        │   │       ├── PortalVoid (idle ring)            ← current destination lens
        │   │       └── DestinationPreview (memory_portal.gdshader)
        │   ├── MemoryFragmentsContainer                  ← progression shards
        │   ├── Particles (CPUParticles2D)
        │   └── IrisCore (DORMANT/AWARE/FOCUSED/SETTLED)  ← state machine
        │       + IrisHapticController, ProceduralIrisSound (audio)
        │
        └── IrisHomeScreen  →  IrisHomeScreen.tscn  →  IrisController? NO — `extends Control`
            └── UI ONLY (Header, WelcomePanel, NavigationCards, UtilityBar)
                (zero iris nodes; confirmed by grep)
```

- `IrisScreen` contains the **only** Iris visualization.
- `IrisHomeScreen` contains **only** UI (0 iris nodes, set `MOUSE_FILTER_IGNORE`).
- No second Iris scene exists anywhere in the project.
- All 15 public methods of `IrisController` are externally called → no dead methods.
- `IrisController` still wires its current subsystems (`IrisCore.new()`, `IrisHapticController.new()`, `$LivingIris3D`) — untouched.

---

## 5. Validation results

### Static / structural (performed in this environment)
| Check | Result |
|---|---|
| All 48 project scenes — header + reference integrity | ✅ ALL VALID (re-run after removal) |
| `IrisAudioController` references after removal | ✅ 0 remaining |
| Single iris shader; no duplicate iris shaders | ✅ `iris.gdshader` + `memory_portal.gdshader` only, both in `Iris.tscn` |
| No duplicate visual layers (one of each in `Iris.tscn`) | ✅ confirmed |
| `IrisController` public API dead-method scan | ✅ 0 dead (all 15 external) |
| `IrisController` still references current subsystems | ✅ IrisCore / IrisHapticController / LivingIris3D intact |
| `IrisHomeScreen.tscn` iris-node count | ✅ 0 |
| `pupil_portal.png` (PortalVoid texture) exists | ✅ 3.0 MB present |

### Godot editor / runtime (NOT performed here)
⚠️ Godot 4.6.3 is not installed in this sandbox. The structural audit gives high confidence the experience is unchanged (the only change deletes an unreferenced script), but the runtime checklist below must be confirmed in Godot by you:
- Startup: `ProductionStartup → ExperienceReadiness → Iris Home`
- One Iris only; no PortalVoid duplication; no checkerboard/transparency artifacts
- Gaze tracking, navigation, Witness Chapters opens, WM_001 launches, return-to-Iris

Because the only change removes a file that **nothing referenced**, runtime behavior is expected to be identical to the post-018 state.

---

## 6. Final Git state

```
Branch : main  (in sync with origin/main)
HEAD   : ba97d37b6464b54a3f62ddda5c52b6d1ca92eb67   (pushed)
Parent : e6f1450 (Mission 018 recovery report)
Files  : 2 deleted, 33 deletions(+), 0 insertions(+)
         the_iris/src/iris/IrisAudioController.gd
         the_iris/src/iris/IrisAudioController.gd.uid
```

`git log -1 --oneline`:
```
ba97d37 Mission 018.5: remove orphaned legacy IrisAudioController
```

Push confirmed on GitHub: `e6f1450..ba97d37  main -> main` (fast-forward, no force).

---

## 7. Note on scope / honesty

The mission brief implied many legacy remnants would be found. The audit, performed against actual repository contents (not prior reports), found that Mission 018 had already removed the duplicate iris from `IrisHomeScreen`, leaving **one** true dead artifact (`IrisAudioController`). I did not delete current, load-bearing systems (PortalVoid / PupilPortal / shaders) merely to match the checklist — doing so would have broken the destination-lens navigation and reintroduced the artifacts this mission exists to prevent. The principle *“Do not delete anything without confirming it is a retired implementation”* was applied throughout.

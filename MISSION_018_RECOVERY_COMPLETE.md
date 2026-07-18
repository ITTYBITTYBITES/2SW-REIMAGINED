# MISSION 018 — RECOVERY COMPLETE

**Repository:** https://github.com/ITTYBITTYBITES/2SW-REIMAGINED
**Recovered by:** Fresh agent pass — audited repository contents directly, did **not** trust prior Mission 018 completion reports.
**Date:** 2026-07-18
**Source-fix commit:** `4c70847f6b9d09252eb48bb5617720efa2b22e9f`

---

## 0. Executive summary

The project path in the mission brief (`src/…`, `scenes/…`, `scripts/…`) does **not** exist at the repo root. The real Godot project lives under **`the_iris/`**. All paths below are relative to `the_iris/`.

Two genuine defects blocked the build, both now fixed:

1. **`scenes/Main.tscn` was structurally corrupted** — not merely "missing a header." A scripted edit during the architecture-split commit (`ab25a8d`) left it with a missing `[gd_scene]` header, a deleted-but-still-referenced `AccessibilityPanel` resource, off-by-one resource-id drift, and orphan property lines. This produced the `Unrecognized file type 'ext_resource'` parse error.
2. **`src/ui/screens/IrisHomeScreen.gd` extended `IrisController`** and redeclared `particles`, `iris_core`, `elapsed`, `awakening_level` — the reported duplicate-member errors. Its `.tscn` also rendered its own iris, conflicting with the persistent `IrisScreen`.

The fix is **3 files, +68/−482 lines**. `MainController.gd`, `IrisController.gd`, and `scenes/Iris.tscn` (the Living Iris) were **deliberately left untouched** — they were already correct.

---

## 1. How reality differed from prior reports

The existing `MISSION_018_COMPLETION_SUMMARY.md` claims Mission 018 was complete. The repository disagreed:

| Claimed (prior reports) | Actual repository state (HEAD = `a66207b`) |
|---|---|
| Mission 018 complete, project runnable | `Main.tscn` unparseable (no header); `IrisHomeScreen.gd` had 4 duplicate-member errors |
| Architecture split delivered cleanly | The split commit (`ab25a8d`) introduced the split **and** the scene corruption in the same commit |
| Single clean commit | The good structure and the damage arrived together; there was **no** commit where `Main.tscn` was both valid *and* had the split |

**Consequence:** neither `git checkout ab25a8d -- …` (corrupted) nor `git checkout b57a50e -- …` (valid scene but *old* single-iris architecture) yields the target. The correct path was to reconstruct one clean `Main.tscn` that keeps the (correct) split architecture with a fully consistent resource table.

---

## 2. Root causes (verified against repository contents)

### 2.1 `scenes/Main.tscn` corruption
Confirmed via `git diff b57a50e..HEAD` and a declared-vs-referenced id cross-check:

- **Missing `[gd_scene]` header** — file began with `[ext_resource …]`. Godot rejects this: *"Unrecognized file type 'ext_resource'."*
- **Deleted `AccessibilityPanel` ext_resource** — its declaration was removed during renumbering, but the node still read `instance=ExtResource("16_accessibility")`. That id was never declared (and `16_device` already points to `DeviceCapabilityManager`).
- **Off-by-one id drift** — declarations were `26_director` / `27_runtime`, but nodes referenced `27_director` / `28_runtime`.
- **2 orphan `visible = false` lines** floated between node blocks (no owning `[node]`).

### 2.2 `src/ui/screens/IrisHomeScreen.gd`
- `extends IrisController` + `class_name IrisHomeScreen`, then **redeclared** `particles`, `iris_core`, `elapsed`, `awakening_level` (all exist in `IrisController`) → *"member already exists in parent class."*
- The home screen duplicated navigation/state/shader logic that `MainController` already owns.

### 2.3 `src/ui/screens/IrisHomeScreen.tscn`
- Rendered its **own** iris (`IrisDisplay/IrisContainer/IrisVisual` + `GlowLayer` + `CalibrationRings` + `AwakeningAnimation/PupilPortal` + `Particles`), which would visually collide with the persistent `IrisScreen` → the "two irises / duplicate layers" risk.

---

## 3. Files changed (the entire source diff)

Only these three. `git show --stat 4c70847` confirms **3 files changed, 68 insertions(+), 482 deletions(-)**.

### `the_iris/scenes/Main.tscn` — reconstructed
- Restored `[gd_scene load_steps=30 format=3]` header.
- 29 `ext_resource` declarations, **all referenced and all resolvable**; every file path verified to exist on disk.
- Corrected references: `27_director→26_director`, `28_runtime→27_runtime`, `16_accessibility→29_accessibility` (AccessibilityPanel restored as a real, declared resource).
- Removed both orphan `visible = false` lines.
- Preserved the intended node tree exactly as `MainController` expects (all 28 `@onready` paths resolve):
  ```
  Main (Node2D, MainController)
  ├── StateManager, DeviceCapabilityManager, InputIntentController,
  │   OrientationManager, NavigationController, BackNavigationController,
  │   ProductionBridge, WitnessExperienceDirector, WitnessMomentRuntime,
  │   ProceduralSound
  └── Interface (CanvasLayer)
      ├── ScreenRoot (Control)
      │   ├── IrisScreen           ← Living Iris (instance Iris.tscn), ALWAYS visible
      │   ├── IrisHomeScreen       ← UI only (instance IrisHomeScreen.tscn), visible on Home only
      │   ├── WitnessMode, Archive, Discovery, Profile, Settings,
      │   │   DailyWitness, WeeklyInvestigation, Calibration, TutorialAwakening
      ├── HUD/EdgeGlow
      ├── TransitionController, VoiceGuide, CaptionOverlay,
      │   AccessibilityPanel, ExperienceReadiness, ProductionStartup
  ```

### `the_iris/src/ui/screens/IrisHomeScreen.gd` — rewritten as pure UI
- Now `extends Control` / `class_name IrisHomeScreen`.
- Removed every IrisController member and method (no `particles`, `iris_core`, `elapsed`, `awakening_level`, shader/iris-core/navigation code).
- Holds only UI references + a null-guarded `_process` that gently bobs the welcome copy. Local clock deliberately named `ui_time` to avoid any shadowing of `IrisController.elapsed`.
- Root set to `MOUSE_FILTER_IGNORE` so the overlay never intercepts the Iris's gaze/focus pointer events.

### `the_iris/src/ui/screens/IrisHomeScreen.tscn` — stripped to UI
- Removed `IrisDisplay` subtree (`IrisVisual`, `GlowLayer`, `CalibrationRings`, `PupilPortal`) and the `Particles` node.
- Removed now-unused iris resources (`base.png`, `fibers.png`, `pupil_portal.png`, `iris.gdshader`, `iris_particle.svg`, `ShaderMaterial_iris`, `ParticleProcessMaterial_dust`).
- Kept all UI nodes (Background/DarkGradient/AmbientGlow, Header, WelcomePanel, NavigationCards, UtilityBar) with original styling intact.
- Every node set `mouse_filter = 2` (IGNORE) → purely presentational, non-blocking.
- Removed the malformed `uid="uid://iris_home_screen"` (non-standard uid) so Godot can assign a real one on first open.

---

## 4. Files deliberately NOT changed

- **`the_iris/scripts/MainController.gd`** — already implements the Phase 3 architecture correctly:
  `@onready var iris: IrisController = $Interface/ScreenRoot/IrisScreen` and
  `@onready var iris_home: Control = $Interface/ScreenRoot/IrisHomeScreen`, with `IrisScreen` persistent and `IrisHomeScreen` visible only on Home. `iris_home` is referenced **only** for `.visible` toggling — no IrisController methods are called on it — so decoupling it was safe. Modifying it would have violated *"do not modify unless required."*
- **`the_iris/scripts/IrisController.gd`** — the Living Iris brain; untouched.
- **`the_iris/scenes/Iris.tscn`** — the Living Iris visualization (IrisScreen); untouched and re-validated.

---

## 5. Validation results

### Static / structural (performed in this environment)
| Check | Tool | Result |
|---|---|---|
| `Main.tscn` header present | validator | ✅ `[gd_scene load_steps=30 format=3]` |
| `Main.tscn` every `ExtResource()` resolves | validator (declared ∩ referenced) | ✅ 29 declared / 29 referenced / **0 undeclared** |
| `Main.tscn` orphan property lines | validator | ✅ **0** |
| `IrisHomeScreen.tscn` references resolve | validator | ✅ 2/2, 0 undeclared, 0 orphans |
| `Iris.tscn` still valid (untouched) | validator | ✅ 11/11 |
| **All 48 project scenes** header + references | validator sweep | ✅ **all 48 valid** |
| `IrisHomeScreen.gd` banned members absent | grep | ✅ no `extends IrisController`, no `particles/iris_core/elapsed/awakening_level`, no iris-render tokens |
| `MainController` `@onready` paths all exist in repaired `Main.tscn` | manual cross-check | ✅ all 28 resolve |
| `MainController` typed-var class_names all declared | grep | ✅ all 25 present |
| No external caller depends on removed home-screen members | grep of `iris_home`/`IrisHomeScreen` | ✅ only `.visible` used |

### Godot editor / runtime (NOT performed here)
⚠️ **Godot 4.6.3 is not installed in this sandbox, so editor parse + the runtime startup sequence (ProductionStartup → ExperienceReadiness → IrisHomeScreen) and the Home → Witness → … → Home test loop were NOT executed.** The above static checks give high confidence the project will open and run, but a real Godot pass is required to fully close the mission. See §7.

### Push (NOT completed)
⚠️ `git push origin main` failed: `fatal: could not read Username for 'https://github.com'`. The sandbox has no GitHub credentials. The commit is correct and local; only the network push remains. See §7.

---

## 6. Final Git state

```
Branch : main
HEAD   : 4c70847f6b9d09252eb48bb5617720efa2b22e9f  (local; NOT yet pushed)
Parent : a66207b "a"
Author : Mission 018 Recovery <mission-recovery@arena.local>
Files  : 3 changed, 68 insertions(+), 482 deletions(-)
         the_iris/scenes/Main.tscn
         the_iris/src/ui/screens/IrisHomeScreen.gd
         the_iris/src/ui/screens/IrisHomeScreen.tscn
```

Confirm with:
```bash
git show --stat HEAD
git diff a66207b..HEAD -- the_iris/scenes/Main.tscn the_iris/src/ui/screens/IrisHomeScreen.gd the_iris/src/ui/screens/IrisHomeScreen.tscn
```

---

## 7. Remaining steps to fully close the mission (require your environment)

1. **Push** (needs your GitHub auth):
   ```bash
   cd 2SW-REIMAGINED
   git pull --rebase origin main   # in case the repo moved
   git push origin main
   ```
2. **Open in Godot 4.6.3** and confirm: no parse errors, no missing resources, no broken inheritance. On first open Godot will (re)generate `.godot/` and `.uid` files and may assign a uid to `IrisHomeScreen.tscn` — that is expected.
3. **Runtime smoke test:** Home → Witness Chapters → Experience → Return Home → Profile → Settings → Home. Verify: exactly one Iris, no checkerboard/duplicate layers, gaze tracking works, navigation works.

If any of those surface a real error, it is a *new* defect — not the corruption this recovery addressed — and should be filed separately rather than attributed to Mission 018.

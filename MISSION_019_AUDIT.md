# MISSION 019 — REPOSITORY BASELINE AUDIT (read-only, pre-deletion)

**Repository:** https://github.com/ITTYBITTYBITES/2SW-REIMAGINED
**Branch/HEAD:** `main` @ `ec12eb5`
**Mode:** Audit only. No files deleted in this document. This satisfies the mission requirement: *"Before deleting anything: Create MISSION_019_AUDIT.md."*
**Date:** 2026-07-18

---

## 0. Headline finding (read this first)

The repository does **not** contain "one live system + removable legacy." It contains **two interwoven architectures**, plus the Iris image-overlay problem identified in Mission 018.6. The dependency graph makes a naïve "delete legacy" **unsafe** — several files that look like legacy are lazily reached from the live KEEP-list screens. This audit classifies every candidate into three buckets so the cleanup can be executed without breaking the boot or the screens the mission explicitly wants preserved.

```
ARCHITECTURE A — "Live Iris shell" (boot path)
  scenes/Main.tscn → MainController.gd → direct $node refs
  Iris-driven gaze navigation, scenes/*Placeholder screens
  ↓ delegates (conditionally) via production_bridge ↓

ARCHITECTURE B — "Production UI/challenge layer" (lazily mounted)
  ProductionDestinationHost/ProductionWitnessHost → NavigationService/AppRoutes
  src/ui/screens/*Screen.tscn  (Profile, Settings, Experiences, Achievements, Programs, About)
  Witness phase screens (Investigation/Observation/Reconstruction/Revelation)  ← ACTIVE Witness runtime
  25 autoloads (registries + services) — a MIX of live and inert
  src/LegacyMechanics/* (FlashWords, ObjectRecall, PatternRecall, SceneInvestigation, SpotDifference)

IRIS VISUAL OVERLAYS (Mission 018.6 finding)
  5 photograph layers stacked over a complete procedural iris in scenes/Iris.tscn
```

**The decision the mission author needs to make** is in §6: Architecture B cannot be removed by file deletion alone — it requires a refactor of the KEEP-list Placeholder screens (`Profile/Settings/Archive/WitnessMode` all call `set_production_bridge()` / `production_host.enter()`).

---

## 1. Current repository map

### Top-level (repo root) — 27 Markdown history documents (all legacy cruft)
`ANDROID_TEST_BUILD_GUIDE.md`, `ANDROID_TEST_PIPELINE_REPORT.md`, `ASSET_GENERATION_PROGRESS.md`, `CHAPTER_1_*` (4), `FIRST_EXPERIENCE_DESIGN.md`, `IRIS_AUDIO_DESIGN_BIBLE.md`, `IRIS_HOME_RECONSTRUCTION_REPORT.md`, `IRIS_LIVING_LENS_IMPLEMENTATION.md`, `IRIS_PERSONALITY_AND_EXPRESSION_GUIDE.md`, `LIVING_LENS_*` (2), `MISSION_018*` (4), `RANK_1_OBSERVER_IMPLEMENTATION_REPORT.md`, `RETURNING_PLAYER_EXPERIENCE_PLAN.md`, `RUNTIME_ACCEPTANCE_REPORT.md`, `SENSORY_SYSTEM_ROADMAP.md`, `STATIC_VERIFICATION_REPORT.md`, `TWO_SECOND_WITNESS_COMPLETE_GAME_ARCHITECTURE_AND_READINESS_REPORT.md/.txt`, `UI_AUDIT_REPORT.md`, `VERTICAL_SLICE_PLAYER_EXPERIENCE_REVIEW.md`, `WM001_*` (2).

### `the_iris/` — the Godot project
- `scenes/` (22 scenes) — Architecture-A shells (Placeholder screens, Iris, Main, transitions, startup)
- `scripts/` (≈45 scripts) — Architecture-A controllers (MainController, IrisController, StateManager, screen scripts)
- `shaders/` (6) — `iris`, `memory_portal` (Iris); `Attunement`, `ObservationMoment`, `witness`, `transition` (Witness/transition)
- `src/iris/` — Iris subsystem + Witness story/runtime/content (`moment_001..015.json`, incidents, registry)
- `src/ui/screens/` — Architecture-B Screen.tscn files (mostly unreachable from Main)
- `src/ui/components/`, `src/ui/dialogs/` — UI cards/dialogs
- `src/LegacyMechanics/` — 5 retired challenge families
- `src/core/`, `src/systems/`, `src/gameplay/`, `src/services/` — autoload services/registries
- `assets/` (15 subdirs), `audio/`, `documentation/` (19 more legacy docs)
- `tests/`, `tools/` — validation harnesses
- `project.godot` — **25 autoloads** + main scene `scenes/Main.tscn`

---

## 2. Active systems (KEEP — verified live on the boot path)

| System | Evidence |
|---|---|
| **Startup flow** | `scenes/ProductionStartup.tscn` → `ExperienceReadinessScreen.tscn` (both reachable from Main; MainController wires `_on_startup_finished` → readiness → home) |
| **MainController shell** | `scenes/Main.tscn` root script; boot entry point |
| **Living Iris — procedural core** | `scenes/Iris.tscn` (IrisScreen) → `IrisController.gd`; `iris.gdshader` computes the full iris procedurally; `IrisCore` (state machine), `IrisHapticController` |
| **Living Iris — 3D layer** | `LivingIris3D.gd` (fully procedural, 0 textures) |
| **Home experience** | `IrisHomeScreen.tscn/.gd` (UI-only since M018), `scenes/Archive/Profile/Settings/Discovery/WitnessMode.tscn` (the live Placeholder shells) |
| **Witness Runtime** | `WitnessMomentRuntime.tscn` → `WitnessMomentOrchestrator.gd` + `WitnessExperienceDirector.gd`; `IncidentRegistry` (autoload, live) |
| **Witness content** | `src/iris/story/content/moment_001..015.json`, incidents incl. the WM_001–005 art (`assets/gameplay/wm_00*.png`) |
| **Witness phase screens** | `WitnessInvestigation/Observation/Reconstruction/RevelationScreen.tscn` — loaded by orchestrator (dynamically, hence "unreachable" from Main's scene graph but LIVE) |
| **Live autoloads** | `IncidentRegistry`, `PlayerProgressService`, `ExperienceReadinessService`, `AppState`, `AnalyticsService`, `SettingsService`, `NavigationService`, `ChallengeFamilyRegistry` (only for a count display) |

---

## 3. Legacy systems found (candidates for removal)

### 3.1 Iris photograph overlays (Mission 018.6 — confirmed picture-substitutes)
- `assets/iris/base.png`, `fibers.png` → blended over procedural `teal` when `has_textures=1` (controller sets this)
- `assets/iris/outer_glow.png` → `OuterEnergyLayer` node (shader already computes `halo`)
- `assets/iris/cornea_reflection.png` → `CorneaLayer` node (shader already computes 2 glass reflections)
- `assets/iris/pupil_portal.png` → `PortalVoid` node (pupil is already procedural `pupil_col`)
- `assets/iris/reflections/*.png` (5) → `DestinationPreview` node — **portal/preview navigation concept**, coupled to MainController (see §6)
- `shaders/memory_portal.gdshader` → drives DestinationPreview

### 3.2 Legacy challenge mechanics (clearly retired)
`src/LegacyMechanics/{flash_words,object_recall,pattern_recall,scene_investigation,spot_the_difference}/` — each has a `*Family.gd` + tutorial scene. The `*Family` classes have **0 external references**. `Discovery.gd` references `ChallengeFamilyRegistry` **only to display a count** ("%02d FUTURE SIGNALS"); no legacy challenge is ever instantiated or played (the live game plays Witness Moments only).

### 3.3 Documentation drift
~27 root `.md` + ~19 `the_iris/documentation/*.md` + ~16 `the_iris/*.md` = **~62 historical documents**. Mission wants these replaced by `/docs/{CURRENT_ARCHITECTURE, CURRENT_PROJECT_STATE, BUILD_AND_RUN}.md`.

### 3.4 Possibly-dead autoloads (NOT referenced from the live path)
`EventBus, ConfigService, ErrorHandler, SaveService, ProfileService, AchievementService, ThemeService, AudioService, AccessibilityService, ContentService, ExperienceRegistry, ChallengeRegistry, InteractionAdapterRegistry, RecommendationService, ProgramService, ResultService, ChallengeSessionService`. ⚠️ **Caveat:** several are consumed by Architecture-B screens, which are conditionally live — see §6.

---

## 4. Files removed (planned — not yet executed)

Presented as a **staged plan** because the audit revealed entanglement. Nothing is deleted until the approach in §6 is confirmed.

**Bucket 1 — SAFE (no ripple, will not touch any KEEP file or autoload):**
- All ~62 historical Markdown docs (root + `the_iris/*.md` + `documentation/`), replaced by `/docs/*` (3 files)
- Iris anatomy photograph overlays: `outer_glow.png`, `cornea_reflection.png` (image-substitute overlays whose effects the shader already computes) + their `OuterEnergyLayer`/`CorneaLayer` nodes
- Iris shader-input photographs: set `has_textures=0` (1 line) and remove `base.png`/`fibers.png` + sampler code
- `PortalVoid` node + `pupil_portal.png` (pupil already procedural)
- `src/LegacyMechanics/` entirety (5 families + tutorials — 0 external refs, never played)

**Bucket 2 — CONDITIONAL (requires the §6 decision; touches KEEP-list screens or autoloads):**
- Architecture-B `src/ui/screens/*Screen.tscn` (Profile/Settings/Experiences/Achievements/Programs/About) — lazily live via ProductionDestinationHost
- `ProductionDestinationHost`, `ProductionWitnessHost`, `AppRoutes`, `NavigationService`
- `DestinationPreview` + 5 reflection previews + `memory_portal.gdshader` (portal/preview navigation concept — MainController reads `active_destination_key`)
- Possibly-dead autoloads (3.4) + their removal from `project.godot`

**Bucket 3 — MUST KEEP:**
- All of §2, all Witness content/screens, the procedural Iris shader + 3D layer, all 24 Main-reachable scenes.

---

## 5. Files retained and why (summary)

- **Iris procedural core** (`iris.gdshader`, `IrisController`, `IrisCore`, `LivingIris3D`, `IrisHapticController`) — this IS the designed Iris.
- **Witness runtime + content + 4 phase screens** — explicitly preserved; the orchestrator depends on them.
- **All Main-reachable scenes** (24) — the boot graph.
- **Live autoloads** — boot would fail without them in `project.godot`.
- **Procedural Iris rim-cue navigation** — already present in the shader (`cue_left/right/up/down`); this is the intended replacement for the image-preview navigation once Bucket 2 is approved.

---

## 6. Dependency verification + the decision required

### The entanglement
`MainController._ready()` calls `set_production_bridge(production_bridge)` on **Profile, Settings, Archive, WitnessMode** (all KEEP-list). Each of those, in `enter()`, calls `production_host.enter()`, which calls `NavigationService.navigate_to(route)`, which mounts `src/ui/screens/<Route>Screen.tscn`. So:

> **Removing Architecture B (Bucket 2) breaks Profile/Settings/Archive/WitnessMode unless those screens are first refactored to drop their production-bridge delegation.**

That refactor touches the KEEP-list "Home Experience" screens — which the mission says to preserve and not rewrite.

### The fork (needs the mission author's call)
- **Option 1 — Conservative (Bucket 1 only):** Remove legacy docs, Iris photograph overlays, and LegacyMechanics. Architecture B stays as a lazily-loaded layer. Leaves the production-host navigation intact. Lowest risk; fully reversible-safe; does not touch any KEEP file's logic. **Does not fully achieve "one architecture"** but is a clean, safe baseline.
- **Option 2 — Full reset (Bucket 1 + 2):** Additionally refactor `Profile/Settings/Archive/WitnessMode/BaseScreen` to remove production-bridge delegation (restore their self-drawn standalone behavior), then delete Architecture B + dead autoloads. Achieves "one architecture" but **rewrites KEEP-list screens** and carries real regression risk I cannot validate without Godot.
- **Option 3 — Staged:** Execute Bucket 1 now (safe), defer Bucket 2 to a follow-up mission with Godot validation available.

### Validation status
⚠️ Godot 4.6.3 is **not available** in this sandbox. All conclusions are from static dependency analysis. A live Godot boot test is required to confirm any removal (especially autoload removal, which is boot-fatal if wrong).

---

## 7. Recommendation

Execute **Bucket 1** now (safe, no ripple, no KEEP-list logic changes), commit as "MISSION 019: Legacy cleanup", then decide Option 1 vs Option 2 for Architecture B with Godot validation available. This honors the mission's own rule — *"Do not delete blindly. Every removal must be based on dependency analysis"* — by not deleting the entangled Architecture B until its removal path is confirmed safe.

**This audit is commit 1 of 3. Awaiting direction on §6 before executing the cleanup commit(s).**

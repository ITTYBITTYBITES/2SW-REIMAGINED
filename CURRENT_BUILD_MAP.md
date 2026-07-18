# CURRENT BUILD MAP

**Two Second Witness** — present-tense baseline.
This is the only handoff document. No mission history, no archaeology, no abandoned plans.
If something is not described here, it is either load-bearing infrastructure or should be removed.

---

## Boot Path

```
START
  │  Godot runs main_scene = res://scenes/Main.tscn  (MainController.gd)
  │
  ├── 25 autoloads initialize (services + registries)        ← see Autoloads below
  │
  ├── ProductionStartup          (publisher/readiness splash) → finished signal
  │      │
  │      └── ExperienceReadinessScreen   (privacy/readiness gate) → readiness_finished
  │             │
  │             └── MainController._on_readiness_finished()
  │                    │
  │                    └── voice_guide.begin_session()
  │                    └── first-launch intro if first_launch
  │
  ▼
HOME (IrisHomeScreen visible + IrisScreen visible)
  │
  │  Iris gaze → active_destination_key → _on_pointer_ended → navigate
  │
  ├── Iris center → STORY MODE → WitnessRuntime → WM incident
  ├── Iris left   → ARCHIVE
  ├── Iris right  → DISCOVERY (daily/weekly placeholders)
  ├── Iris up     → PROFILE
  └── Iris down   → SETTINGS (calibration)
```

---

## Scene Tree (Main.tscn)

```
Main (Node2D) — scripts/MainController.gd
├── StateManager, DeviceCapabilityManager, InputIntentController,
│   OrientationManager, NavigationController, BackNavigationController,
│   ProductionBridge, WitnessExperienceDirector, WitnessMomentRuntime,
│   ProceduralSound
└── Interface (CanvasLayer)
    ├── ScreenRoot (Control)
    │   ├── IrisScreen              ← scenes/Iris.tscn (Living Iris, always visible)
    │   ├── IrisHomeScreen          ← src/ui/screens/IrisHomeScreen.tscn (UI only, home)
    │   ├── WitnessMode             ← scenes/WitnessMode.tscn
    │   ├── Archive / Discovery / Profile / Settings   (live placeholder shells)
    │   ├── DailyWitness / WeeklyInvestigation / Calibration
    │   └── TutorialAwakening
    ├── HUD / EdgeGlow
    ├── TransitionController, VoiceGuide, CaptionOverlay,
    │   AccessibilityPanel, ExperienceReadiness, ProductionStartup
```

---

## Living Iris (the one perception instrument)

`scenes/Iris.tscn` (IrisScreen) → `scripts/IrisController.gd`:

| Layer | Source | Status |
|---|---|---|
| `Visual` (ColorRect) | `shaders/iris.gdshader` | **Procedural core** — hippus, breathing, fibers, sclera, pupil, limbal, gaze cues. `has_textures=0` (pure procedural path active). |
| `LivingIris3D` | `src/iris/LivingIris3D.gd` | Procedural 3D eye (colored materials, 0 image textures). |
| `PupilPortalLayer` | destination-lens nodes | Live navigation. `DestinationPreview` + `DestinationTitle`/`Prompt` driven by `active_destination_key`. Read by `MainController._on_pointer_ended`. |
| `MemoryFragmentsContainer` | `wm_00*.png` shards | Progression visualization (count = completed moments). |
| `Particles` | `assets/iris_particle.svg` | Ambient dust. |

State machine: `src/iris/IrisCore.gd` (DORMANT / AWARE / FOCUSED / SETTLED).
Haptics: `src/iris/IrisHapticController.gd`. Audio: inline via `ProceduralIrisSound`.

> **Known incomplete area:** the destination-lens (`DestinationPreview` + 5 `assets/iris/reflections/*.png` + `memory_portal.gdshader`) is a portal-style navigation concept layered into the pupil. The procedural shader already encodes rim-light navigation cues. Migrating nav from the in-pupil preview to the procedural rim is a *future* design decision, not a bug.

---

## Witness Runtime (the one gameplay path)

```
WitnessMomentRuntime (scene) → WitnessMomentOrchestrator.gd
   ← start_incident(incident) from WitnessExperienceDirector.get_next_incident()
   │
   ├── loads incident from IncidentRegistry (src/iris/story/registry/)
   ├── runs 4 phases via dynamically-loaded phase screens:
   │     WitnessInvestigationScreen → WitnessObservationScreen
   │       → WitnessReconstructionScreen → WitnessRevelationScreen
   └── records result via PlayerProgressService → IncidentRegistry.notify_*
```

**Playable moments:** WM_001–WM_005. Art: `assets/gameplay/wm_00*.png`.
Content: `src/iris/story/content/moment_001..015.json`, `src/iris/story/incidents/*.json`.

---

## Autoloads (project.godot — 25 services/registries)

`EventBus, ConfigService, ErrorHandler, AnalyticsService, SettingsService, SaveService, ProfileService, AchievementService, ThemeService, AudioService, AccessibilityService, ContentService, ExperienceRegistry, IncidentRegistry, ChallengeRegistry, ChallengeFamilyRegistry, InteractionAdapterRegistry, PlayerProgressService, RecommendationService, ProgramService, ResultService, ChallengeSessionService, NavigationService, AppState, ExperienceReadinessService`

> **Known incomplete area:** several of these (Challenge*, InteractionAdapterRegistry, ProgramService, RecommendationService, ContentService, ExperienceRegistry) belong to a **second, challenge-library architecture** that is wired in but not on the active play path (the prototype plays Witness Moments only). They are entangled with `PlayerProgressService` (which the Iris depends on), so they cannot be deleted without care. This is the #1 remaining reduction target.

---

## Active Assets

| Purpose | Assets |
|---|---|
| Iris destination previews (nav) | `assets/iris/reflections/{story_mode,archive,profile,daily_witness,calibration}.png` |
| Iris particle | `assets/iris_particle.svg` |
| Witness moment art (WM_001–005) | `assets/gameplay/wm_001..005_*.png` |
| Memory shards | `assets/gameplay/wm_00*_*.png` (also used as fragments) |
| Shaders | `iris.gdshader`, `memory_portal.gdshader`, `witness.gdshader`, `transition.gdshader`, `AttunementShader.gdshader`, `ObservationMomentShader.gdshader` |
| Boot icon | `assets/brand/app_icon_1024.png` |
| Audio bus | `audio/default_bus_layout.tres` |

---

## Known Working Features (current prototype)

- Boot → ProductionStartup → Readiness gate → Home
- Living Iris renders procedurally (gaze tracking, breathing, blinking, awakening, state transitions)
- Iris-gaze navigation to all screens (center=story, left=archive, right=discovery, up=profile, down=settings)
- Witness Moment runtime: WM_001–WM_005 playable, progression recorded
- Profile/Settings/Archive screens (self-drawn procedural mode)

## Known Incomplete / Deferred (not bugs — future decisions)

1. **Challenge-library architecture** (Architecture B): `src/ui/screens/*Screen.tscn`, `AppRoutes`, several Challenge* autoloads. Wired in via `production_bridge` on Profile/Settings/Archive/WitnessMode but not on the active play path. **Reduction target #1** — needs Godot validation to remove safely.
2. **LegacyMechanics** (`src/LegacyMechanics/` — flash_words, object_recall, pattern_recall, scene_investigation, spot_the_difference): retired challenge families registered in `ChallengeFamilyRegistry`. Never played in current prototype. Entangled with the progression mesh. **Reduction target #2.**
3. **Destination-lens → procedural rim navigation migration** (design decision).
4. **`tests/`, `tools/`** validation harnesses reference some to-be-reduced systems.

---

## Build & Run

```
git clone https://github.com/ITTYBITTYBITES/2SW-REIMAGINED
Open the_iris/project.godot in Godot 4.6.3
Press Play (main scene: res://scenes/Main.tscn)
```

Renderer: `gl_compatibility`. Viewport: 540×960 (portrait, expand stretch).

---

*This document supersedes all prior reports. Update it when the architecture changes — do not add historical sections.*

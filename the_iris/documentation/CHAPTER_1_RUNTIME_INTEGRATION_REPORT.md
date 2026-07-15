# Two Second Witness 4.0 — Chapter 1 Runtime Integration Report (`CHAPTER_1_RUNTIME_INTEGRATION_REPORT.md`)

## Executive Summary

As detailed in our chapter architecture pass, *Two Second Witness 4.0* must avoid the "content swamp" of building five completely separate mini-games or hardcoding individual moment logic into runtime controllers.

We have executed the **Chapter 1 Runtime Integration Pass**, transforming our chapter skeleton into a universal, playable runtime grammar across all five master moments of **Chapter 1: Learning to Notice (`WM_001` through `WM_005`)**.

```
                       [WitnessExperienceDirector]
                                    │
                                    ▼
                         [WitnessMomentRuntime]
               (WitnessMomentOrchestrator Shared Container)
                                    │
        ┌──────────────┬────────────┼────────────┬──────────────┐
        ▼              ▼            ▼            ▼              ▼
   [WM_001 Data]  [WM_002 Data] [WM_003 Data] [WM_004 Data]  [WM_005 Data]
      Studio         Museum        Dressing     Cleanroom      Internal
      Canvas        Corridor        Table        Console        Stroma
```

Every chapter moment (`WM_001` through `WM_005`) now runs through our exact shared runtime controllers and shaders (`WitnessObservationScreen.gd`, `WitnessReconstructionScreen.gd`, `WitnessInvestigationScreen.gd`, `WitnessRevelationScreen.gd`, and `ObservationMomentShader.gdshader`). Each moment JSON definition supplies its own environment background texture, observation targets, meaningful details, reconstruction rules, reveal sequences, and orbital memory shard without a single hardcoded `if moment_id == "WM_00X"` branch inside the phase screens.

---

## 1. Shared Runtime Phase Architecture

### Phase 1: Arrival & Attunement (`WitnessObservationScreen.gd`)
- **Shared Controller Behavior**: Reads `environment.background_image` and `observation.duration_seconds` directly from the moment blueprint.
- **Dynamic Atmosphere Shader (`ObservationMomentShader.gdshader`)**:
  - `WM_001` (`effect_mode = 1.0`): Golden dust motes swirling in the window shaft & linseed vapor rising near the easel.
  - `WM_002` (`effect_mode = 2.0`): Archival museum dust drifting above the halogen security spotlight & parquet floor reflections.
  - `WM_003` (`effect_mode = 3.0`): Amber rosin dust settling across the Stradivarius strings & tungsten vanity mirror bulb flicker.
  - `WM_004` (`effect_mode = 4.0`): Monochromatic `488nm` teal diagnostic laser beam deflection & cleanroom laminar airflow shimmer.
  - `WM_005` (`effect_mode = 5.0`): Bioluminescent stroma breathing & orbiting starlight reflections inside the deepest plane of the lens.

### Phase 2: Memory Reconstruction (`WitnessReconstructionScreen.gd`)
- **Shared Controller Behavior**: Automatically constructs interactive ghost outlines (`_ghost_outlines`) from `reconstruction.ghost_outlines` and `reconstruction.fragment_palette`.
- **Universal Grammar**:
  - If exact normalized coordinates (`pos`/`size`) are provided in the JSON, they are mounted directly.
  - If a simple string ID list is provided (e.g. `["paused_brush", "crystal_prism", "cerulean_tube"]`), the runtime automatically calculates clean 2.5D perspective grid coordinates across the scene (`Vector2(0.22 + col * 0.28, 0.35 + row * 0.24)`).
- **Core Philosophy**: No penalty, no right/wrong arcade score (`"Place what stayed with you. Leave what didn't. There is no wrong answer — only what you carry."`).

### Phase 3: Investigation & Attunement (`WitnessInvestigationScreen.gd`)
- **Shared Controller Behavior**: Automatically iterates over `investigation.attunements` to mount interactive attunement hotspots across the scene (`_create_hotspots`).
- **Universal Grammar**:
  - Tapping an object (`thermal`, `skeletal`, `text`, `forensic`, `trajectory`, `spectral`) reveals that object's unique sensory perspective.
  - Upon reaching `discovery_threshold` (default `3`), the Living Iris intervenes with deep synthesis (`investigation.iris_intervention`).

### Phase 4: Discovery, Revelation & Reflection (`WitnessRevelationScreen.gd`)
- **Shared Controller Behavior**: Stepwise reveal of carried fragments (`☑` vs `☐`), completed attunements formatted with dynamic titles (`Object Name (Type)`), and the underlying truth note (`archive_mapping.iris_note`).
- **Archive Handoff**: `WitnessMomentOrchestrator._commit_to_archive()` embeds the completed moment inside `ProfileService.profile.witness_archive` and triggers `StateManager.complete_observation()`.

---

## 2. Chapter 1 Production Content Matrix

| Moment ID | Title & High-Res Background | Key Observation Target | Reconstruction Palette (`fragment_palette`) | Attunement Hotspots (`attunements`) | Iris Reflection Note (`iris_note`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`WM_001`** | **The Unfinished Canvas**<br>`wm_001_studio_background.png` | Painter's hand pauses over blank linen without touching it. | `paused_brush`, `crystal_prism`, `cerulean_tube`, `spectrum_beam`, `color_notes`, `linseed_jar`, `linen_underdrawing` | `crystal_prism` (Spectral)<br>`canvas_edge` (Forensic)<br>`paused_brush` (Trajectory)<br>`color_notes` (Text) | *"The brush paused not in hesitation, but in reverence for the light across the linen."* |
| **`WM_002`** | **The Forgotten Museum**<br>`wm_002_museum_corridor.png` | Night guard rests his palm on the mahogany case frame for 1.0s. | `mahogany_case`, `brass_watch`, `palm_imprint`, `ammonite_fossil`, `exhibition_stub`, `marble_bust` | `pocket_watch` (Forensic)<br>`display_case` (Text)<br>`palm_imprint` (Thermal) | *"Every night, the guard touched the mahogany frame where his grandfather's name was etched."* |
| **`WM_003`** | **The Last Performance**<br>`wm_003_dressing_room.png` | Solo violinist lowers frayed bow & rests fingers on yellow telegram. | `wooden_bow`, `crimson_case`, `yellow_telegram`, `rosin_cake`, `bach_score`, `mirror_bulbs` | `yellow_telegram` (Text)<br>`wooden_bow` (Forensic)<br>`bach_score` (Spectral) | *"When the bow settled into the velvet, the final note was already safely across the sea."* |
| **`WM_004`** | **The Faulty Reactor**<br>`wm_004_cleanroom_console.png` | Diagnostic laser beam shifts `0.2mm` across quartz sensor target. | `quartz_sensor`, `calibration_key`, `teal_laser`, `magnetic_seal`, `physics_logbook`, `vacuum_gauge` | `quartz_sensor` (Spectral)<br>`vacuum_gauge` (Thermal)<br>`magnetic_seal` (Trajectory) | *"A fraction of a millimeter on the quartz grid stood between routine calibration and structural loss."* |
| **`WM_005`** | **The Witness**<br>`wm_005_internal_stroma.png` | Stroma breathes while 4 memory shards orbit & cornea reflects observer. | `canvas_shard`, `museum_shard`, `performance_shard`, `reactor_shard`, `golden_collarette`, `pupil_portal` | `canvas_shard` (Spectral)<br>`museum_shard` (Thermal)<br>`performance_shard` (Trajectory)<br>`reactor_shard` (Forensic) | *"The instrument and the observer looked into each other and discovered they were holding the same light."* |

---

## 3. Seamless Runtime Routing & Rank Evolution

### Dynamic Chapter Progression (`MainController.gd` & `WitnessExperienceDirector.gd`)
When the observer touches Center (`Story Mode`) on the Living Iris (`active_screen == "home"`):
1. `WitnessExperienceDirector.get_current_chapter_moment(state_manager.completed_observations)` evaluates their exact position in the chapter (`0 -> WM_001`, `1 -> WM_002`, `2 -> WM_003`, `3 -> WM_004`, `4 -> WM_005`).
2. Tapping center sweeps the camera straight through "The Threshold" (`transition.play_enter`) into `WitnessMomentRuntime.start_moment(current_moment.moment_id)` without routing through static text placeholders or menu screens.
3. Upon completing each moment, `IrisController._sync_progression()` physically evolves the stroma (`progression_level: 1 -> 2 -> 3 -> 4 -> 5`) and mounts the newly earned memory shard inside `$MemoryFragmentsContainer`.
4. Completing `WM_005` unlocks **Rank 2: Witness** and sets the center pupil portal (`DestinationPreview`) to displaying **`PRESERVED MOMENTS & DAILY ATTUNEMENT`** over `wm_archive_horizon.png`.

---

## 4. Verification & Developer Testing Hotkeys (`MobileSimulator.gd`)

During development or quality assurance, the entire Chapter 1 shared runtime grammar can be tested across any moment using keys `5` through `8`:
- **`KEY_5` (Dev Shortcut — New Observer / Tutorial)**: Sets `first_launch = true`, `onboarding_tutorial_completed = false`, `completed_obs = 0`. Tapping center enters **The Awakening (`TutorialAwakeningScreen.tscn`)**.
- **`KEY_6` (Dev Shortcut — Mid-Chapter 1 Playable Runtime)**: Sets `onboarding_tutorial_completed = true`, `completed_obs = 3`. Center viewfinder displays **`CHAPTER 1: THE FAULTY REACTOR (`WM_004`)`** over `wm_004_cleanroom_console.png` with 3 orbiting shards (`WM_001`–`WM_003`). Tapping center launches `WM_004` directly into our shared runtime.
- **`KEY_7` (Dev Shortcut — Reset Progression)**: Resets all observations and returns stroma to `Rank 0 / Clean`.
- **`KEY_8` (Dev Shortcut — Chapter 1 Complete / Rank 2)**: Previews `completed_obs = 10`, forcing `progression_level = 5` (**Rank 2: Witness**) with full `glow_strength = 1.0` and all 5 orbital memory shards.

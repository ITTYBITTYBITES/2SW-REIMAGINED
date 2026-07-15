# Two Second Witness 4.0 — Rank 1 Chapter Production Report (`RANK_1_OBSERVER_IMPLEMENTATION_REPORT.md`)

## Executive Summary

This report documents the completion of the **Rank 1 Chapter Production Pass (`Chapter 1: Learning to Notice`)** for *Two Second Witness 4.0*.

Without redesigning the Living Lens, replacing existing runtime architecture, or introducing redundant navigation mechanics, we have integrated the five master production moments (`WM_001` through `WM_005`), established the dynamic `WitnessExperienceDirector` chapter framework, and connected the five-tier physical Iris evolution ladder directly to player progression.

The core design mandate of Chapter 1 has been fulfilled:
> *"Witnessing is not finding errors. Witnessing is discovering meaningful details others overlook. The player should finish Chapter 1 feeling: 'I did not solve five puzzles. I learned how to see.'"*

---

## 1. Chapter 1 Content Integration & Asset Pipeline

All five Chapter 1 moments have been authored into complete production JSON definitions (`res://src/iris/story/content/moment_00X.json`) and paired with final, high-resolution 2.5D environment textures (`generate_image` Batch 1 through Batch 6):

| Moment ID | Title | Theme & Setting | High-Res Production Background Asset | Physical Iris Evolution (`_sync_progression`) |
| :--- | :--- | :--- | :--- | :--- |
| **`WM_001`** | **The Unfinished Canvas** | Beauty and hidden inspiration.<br>*Sunlit artist studio loft (`5:14 PM`).* | `res://assets/gameplay/wm_001_studio_background.png` (3.3 MB) | **Evolution 1**: First golden collarette starlight filament ignites (`progression_level = 1`), `MemoryFragment_0` enters orbit. |
| **`WM_002`** | **The Forgotten Museum** | History hiding in plain sight.<br>*Hushed museum corridor after hours (`9:30 PM`).* | `res://assets/gameplay/wm_002_museum_corridor.png` (2.9 MB) | **Evolution 2**: Second orbital memory reflection (`MemoryFragment_1` / museum shard) joins the outer ciliary ring. |
| **`WM_003`** | **The Last Performance** | Human emotion and intention.<br>*Concert hall dressing room (`10:45 PM`).* | `res://assets/gameplay/wm_003_dressing_room.png` (3.1 MB) | **Evolution 3**: New pupil depth (`distortion_intensity` / limbal refraction increases, `MemoryFragment_2` joins orbit). |
| **`WM_004`** | **The Faulty Reactor** | Scientific observation & consequence.<br>*Optical physics cleanroom (`3:22 AM`).* | `res://assets/gameplay/wm_004_cleanroom_console.png` (3.2 MB) | **Evolution 4**: Stroma complexity (`radial_ridges` and `fbm` fibers catch vibrant emerald/gold light, `MemoryFragment_3` joins). |
| **`WM_005`** | **The Witness** | Awareness of the Living Iris itself.<br>*Deep internal stroma plane (`Midnight`).* | `res://assets/gameplay/wm_005_internal_stroma.png` (3.7 MB) | **Evolution 5**: Rank Transition. **Rank 2: Witness** unlocks. Orbiting ring of all 5 shards complete. |

---

## 2. Production Witness Moment Framework (`WitnessExperienceDirector.gd`)

We upgraded `WitnessExperienceDirector.gd` from a static, single-file loader into a dynamic, chapter-aware runtime container:
1. **Dynamic Roster Loading (`_load_moments`)**: Automatically scans and parses `moment_001.json` through `moment_005.json` into fully deserialized `WitnessMoment` resources (`is_placeholder() -> false`).
2. **Contextual Horizon Resolution (`get_current_chapter_moment`)**:
   - When the player touches Center on the Living Iris (`MainController._on_tap`), the controller does not hardcode `"WM_001"`. It queries `get_current_chapter_moment(state_manager.completed_observations)`.
   - `completed_observations == 0` -> loads `WM_001`
   - `completed_observations == 1` -> loads `WM_002`
   - `completed_observations == 2` -> loads `WM_003`
   - `completed_observations == 3` -> loads `WM_004`
   - `completed_observations == 4` -> loads `WM_005`
3. **Seamless Phase Routing**: Every moment executes through our strict, player-facing 8-phase progression:
   ```
   Arrival ──> Attunement ──> Two Second Witness ──> Memory Reconstruction ──> Investigation ──> Discovery ──> Reflection ──> Archive
   ```
   Zero legacy puzzle labels (`Spot the Difference`, `Object Recall`) or challenge family names are ever surfaced to the observer.

---

## 3. Player Experience Validation (`PHASE 6`)

### A. New Player Verification (`onboarding_tutorial_completed == false`)
- **First Launch & Awakening**: Cold launch loads into total darkness (`awakening_level = 0.0`), initiating the 4-scene **"The Awakening"** tutorial sequence (`TutorialAwakeningScreen.tscn`).
- **Rank 1 Attainment**: Completing Scene 3 (`What Changed? -> The reflection shifted`) stores the first observation fragment in the Archive, marks `onboarding_tutorial_completed = true`, elevates stroma to `progression_level = 1`, and unlocks **Rank 1: Observer**.
- **Chapter 1 Discovery**: The central pupil portal (`DestinationPreview`) switches immediately from "The Awakening" to displaying `wm_001_studio_background.png` with the title **`CHAPTER 1: THE UNFINISHED CANVAS`**. Touching center dilates straight into `WM_001`.

### B. Returning Player Verification (`onboarding_tutorial_completed == true`)
- **Tutorial Bypass**: When `MainController._ready()` detects `onboarding_tutorial_completed == true`, it completely skips `_start_first_launch_intro()`, immediately rendering the fully awake, breathing Living Lens at the exact rank of the returning observer.
- **Dynamic Chapter Continuation**: If the returning player has `completed_observations == 2` (having finished `WM_001` and `WM_002`), the center viewfinder automatically centers on **`WM_003: The Last Performance`** (`wm_003_dressing_room.png`). The eye displays 2 orbiting memory shards (`MemoryFragment_0` and `MemoryFragment_1`) corresponding to their prior observations.

### C. Chapter Completion & Rank 2 Transition (`completed_observations >= 5`)
When the observer completes `WM_005` (**The Witness**):
1. **Archive Embedment**: `WitnessMomentOrchestrator._commit_to_archive()` permanently stores `the_witness` in `ProfileService.profile.witness_archive`.
2. **Rank 2 Unlock Banner**: `MainController._show_rank_reveal("RANK 2 : THE WITNESS UNLOCKED", "You learned how to see. Chapter 1 Complete.")` illuminates across the optical limbal atmosphere.
3. **Physical Eye Completion**: `IrisController._sync_progression()` sets `progression_level = 5` (`Rank 2: Witness`). All five orbiting memory shards rotate in harmonious phase around the pupil while the full **Atmospheric Phase Lock chord** (`C-G-E harmonic`) sustains.
4. **Preserved Horizons**: When resting at center moving forward, the pupil no longer shows empty potential; it displays **`PRESERVED MOMENTS & DAILY ATTUNEMENT`** over `res://assets/gameplay/wm_archive_horizon.png`.

---

## 4. Developer Shortcuts for Instant Verification (`MobileSimulator.gd`)

During development, all stages of Chapter 1 and Rank evolution can be verified instantly using numeric hotkeys:
- **`KEY_5`**: Forces New Observer state (`first_launch = true`, `onboarding_tutorial_completed = false`, `completed_obs = 0`). Launches **The Awakening Tutorial**.
- **`KEY_6`**: Forces Mid-Chapter 1 state (`onboarding_tutorial_completed = true`, `completed_obs = 3`). Loads `WM_004: The Faulty Reactor` onto the center portal with 3 orbiting shards.
- **`KEY_7`**: Resets all progression (`completed_obs = 0`, `onboarding_tutorial_completed = false`).
- **`KEY_8`**: Previews maximum Chapter 1 / Rank 2 completion (`completed_obs = 10`, `progression_level = 5`, `glow_strength = 1.0`, 5+ orbital shards).

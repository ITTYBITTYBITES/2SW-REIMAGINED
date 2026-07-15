# Two Second Witness 4.0 — Chapter 1 Production Specification (`CHAPTER_1_LEARNING_TO_NOTICE_SPEC.md`)

## Executive Summary

**Chapter 1: Learning to Notice** is the first true player progression chapter of *Two Second Witness 4.0*. Having unlocked **Rank 1: Observer** by completing "The Awakening" onboarding tutorial (`FIRST_EXPERIENCE_DESIGN.md`), the player embarks on five interconnected production Witness Moments (`WM_001` through `WM_005`).

The foundational purpose of this chapter is to establish the core philosophy of the Two Second Witness universe:
> *"Witnessing is not finding errors or solving spot-the-difference puzzles. Witnessing is discovering meaningful details and hidden human intention that others overlook."*

Throughout these five moments, every observation literally and permanently evolves the physical appearance of the **Living Iris** (`IrisController.gd`), igniting golden collarette starlight fibers, deepening stroma ridges, and collecting orbiting memory shards inside `$MemoryFragmentsContainer` until the player completes `WM_005` and unlocks **Rank 2: Witness**.

---

## 1. Chapter 1 Master Moment Roster & Evolution Roadmap

```
[Rank 1: Observer Unlocked (`onboarding_tutorial_completed == true`)]
                 │
                 ▼
[WM_001: The Unfinished Canvas] ─────> Evolution 1: First golden collarette filament ignites (`starlight > 0.15`).
                 │
                 ▼
[WM_002: The Forgotten Museum] ──────> Evolution 2: Additional memory reflection (`archive_shard_1` joins orbit).
                 │
                 ▼
[WM_003: The Last Performance] ──────> Evolution 3: New pupil depth (`pupil_portal` lens refraction intensifies).
                 │
                 ▼
[WM_004: The Faulty Reactor] ────────> Evolution 4: Additional stroma complexity (`radial_ridges` catch emerald light).
                 │
                 ▼
[WM_005: The Witness] ───────────────> Evolution 5: Rank Transition. **Rank 2: Witness** unlocks.
                                        The Iris now physically contains preserved moments instead of empty potential.
```

---

## 2. Production Definitions by Moment

### Witness Moment 001 (`WM_001`): The Unfinished Canvas
- **Theme**: Beauty and hidden inspiration.
- **Environment**: A sunlit artist studio loft overlooking a quiet courtyard. Late afternoon golden hour (`5:14 PM`). Stretched linen canvas on an easel beside a wooden window sill.
- **Camera Framing**: Locked-off medium close-up (`4:3` aspect ratio), shallow depth of field with the canvas surface and sable brush sharp. Desaturated cool shadows contrasted with warm golden highlights.
- **Two-Second Observation Event**: The painter's hand lifts a sable hair brush from the glass palette (`0.7s`), pauses midway looking right toward the window (`0.8s`), and lowers the brush back down untouched (`0.5s`).
- **Hidden Detail**: A crystal glass prism sitting on the wooden window sill catches the direct `5:14 PM` sun beam, refracting a vibrant cyan and amber rainbow directly across the blank linen canvas.
- **Player Discovery Objective**: Discover that the painter did not pause from creative block or self-doubt, but because the refracted spectrum beam perfectly completed the composition they were preparing to paint.
- **Reconstruction Interaction**: Spatial fragment placement across the easel desk (`reconstruction.fragment_palette`). Drag sensory fragments (`paused_brush`, `crystal_prism`, `cerulean_tube`, `spectrum_beam`, `color_notes`, `linseed_jar`, `linen_underdrawing`) to their exact ghost coordinates.
- **Reveal Sequence**: Attuning to the crystal prism and canvas edge reveals the charcoal underdrawing tracing the exact path of the rainbow. Atmospheric Phase Lock chord (`256 Hz C-G-E`) resonates while the canvas illuminates.
- **Iris Commentary (`VoiceGuide` / `revelation.iris_response`)**:
  > *"You noticed the paused brush. You noticed the crystal prism on the sill. You noticed the spectrum beam striking the blank linen. The painter did not stop from doubt. They stopped because the light completed the composition. This is what it means to Witness."*
- **Archive Entry**: **`The Unfinished Canvas`** (*"The brush paused not in hesitation, but in reverence for the light across the linen."*)
- **Required Assets (`Batch 1`)**: `res://assets/gameplay/wm_001_studio_background.png`, `res://assets/gameplay/wm_001_prism_highlight.png`, fragment sprites (`paused_brush`, `crystal_prism`, `cerulean_tube`).

---

### Witness Moment 002 (`WM_002`): The Forgotten Museum
- **Theme**: History hiding in plain sight.
- **Environment**: A hushed natural history archive corridor after hours (`9:30 PM`). Polished parquet floors, mahogany glass display cases containing fossil specimens, and marble naturalist busts under halogen security lighting.
- **Camera Framing**: Locked-off wide corridor angle (`4:3`), deep depth of field with polished parquet floor reflections crisp. Cool museum blues (`4000K`) contrasted against warm mahogany amber.
- **Two-Second Observation Event**: An elderly night guard walks into frame past a glass display case (`0.5s`), rests his palm on the wooden frame for exactly one second (`1.0s`), checks his pocket watch (`0.5s`), and continues walking.
- **Hidden Detail**: A distinct, warm palm imprint on the display case glass exactly matches decades of daily touch marks, and the brass pocket watch lid bears an engraving matching the donor plaque on the fossil case.
- **Player Discovery Objective**: Uncover the unspoken family bond: the night guard is Thomas Holloway, grandson of the naturalist who unearthed and donated the ammonite specimen eighty years ago.
- **Reconstruction Interaction**: Reconstruct the display corridor (`mahogany_case`, `brass_watch`, `palm_imprint`, `ammonite_fossil`, `exhibition_stub`, `marble_bust`).
- **Reveal Sequence**: Attuning to the pocket watch and display plaque aligns the two engravings. The residual thermal warmth of the palm imprint glows on the glass.
- **Iris Commentary (`VoiceGuide` / `revelation.iris_response`)**:
  > *"You noticed the palm imprint on the glass. You noticed the engraved pocket watch. You noticed the Holloway family name shared between guard and artifact. History is not dead stone under glass; it lives through those who remember."*
- **Archive Entry**: **`The Forgotten Museum`** (*"Every night, the guard touched the mahogany frame where his grandfather's name was etched."*)
- **Required Assets (`Batch 2`)**: `res://assets/gameplay/wm_002_museum_corridor.png`, `res://assets/gameplay/wm_002_palm_imprint.png`, fragment sprites (`mahogany_case`, `brass_watch`, `ammonite_fossil`).

---

### Witness Moment 003 (`WM_003`): The Last Performance
- **Theme**: Human emotion and intention.
- **Environment**: An intimate concert hall backstage dressing room (`10:45 PM`). Warm `2700K` tungsten vanity mirror bulbs, deep crimson velvet curtains, and amber rosin dust floating around a violin case.
- **Camera Framing**: Locked-off intimate vanity table shot (`4:3`), shallow depth of field focusing on the violin bow, crimson velvet case, and a folded yellow Western Union telegram.
- **Two-Second Observation Event**: A solo violinist gently lowers her bow into the crimson velvet case (`0.8s`), rests her fingertips on the folded telegram beside the mirror (`0.7s`), and closes the brass case latch (`0.5s`).
- **Hidden Detail**: The horsehair on the violin bow is frayed near the frog from an impassioned, unrepeated cadenza, and the manuscript of Bach's *Chaconne* bears a penciled dedication over the final chord: *"For Elena, who taught me how to listen."*
- **Player Discovery Objective**: Discover that the violinist played the breathtaking encore not for the cheering auditorium audience, but across the distance for the name signed on the yellow telegram.
- **Reconstruction Interaction**: Reconstruct the dressing table (`wooden_bow`, `crimson_case`, `yellow_telegram`, `rosin_cake`, `bach_score`, `mirror_bulbs`).
- **Reveal Sequence**: Attuning to the telegram (`"I heard every note from across the sea. — Elena"`) and the circled Bach score triggers a pure E-string violin harmonic fading into acoustic space.
- **Iris Commentary (`VoiceGuide` / `revelation.iris_response`)**:
  > *"You noticed the frayed bow hair. You noticed the telegram beside the vanity mirror. You noticed the dedication on the final chord. She did not play for applause; she played across the distance to the one who truly listened."*
- **Archive Entry**: **`The Last Performance`** (*"When the bow settled into the velvet, the final note was already safely across the sea."*)
- **Required Assets (`Batch 3`)**: `res://assets/gameplay/wm_003_dressing_room.png`, `res://assets/gameplay/wm_003_telegram_detail.png`, fragment sprites (`wooden_bow`, `crimson_case`, `bach_score`).

---

### Witness Moment 004 (`WM_004`): The Faulty Reactor
- **Theme**: Scientific observation and consequence.
- **Environment**: A high-precision optical physics cleanroom (`3:22 AM`). Stainless steel optical breadboards, digital vacuum gauges (`1.0e-7 Torr`), and monochromatic `488nm` teal diagnostic laser beams.
- **Camera Framing**: Locked-off technical console shot (`4:3`), deep depth of field across the entire quartz sensor array and isolation seal levers. Crisp laboratory cyan and silver grading.
- **Two-Second Observation Event**: A research physicist taps a stainless steel calibration key (`0.5s`), watches a diagnostic laser beam shift `0.2 millimeters` across a quartz sensor target (`0.8s`), and immediately pulls down the magnetic isolation seal lever (`0.7s`).
- **Hidden Detail**: The `0.2mm` deflection across the quartz reticle matched the exact differential equation predicted in the open research logbook, signaling that thermal expansion was about to fracture the crystalline core.
- **Player Discovery Objective**: Witness that scientific observation is not passive recording; the physicist's split-second recognition of the micro-deflection caught the divergence and prevented a catastrophic core cascade.
- **Reconstruction Interaction**: Reconstruct the cleanroom breadboard (`quartz_sensor`, `calibration_key`, `teal_laser`, `magnetic_seal`, `physics_logbook`, `vacuum_gauge`).
- **Reveal Sequence**: Attuning to the quartz sensor and research logbook highlights the exact `0.18mm` lattice strain boundary alongside an `800 Hz` electronic diagnostic confirmation tone.
- **Iris Commentary (`VoiceGuide` / `revelation.iris_response`)**:
  > *"You noticed the micro-deflection across the quartz reticle. You noticed the vacuum flicker. You noticed the exact timing of the magnetic isolation seal. True observation catches the divergence before the cascade."*
- **Archive Entry**: **`The Faulty Reactor`** (*"A fraction of a millimeter on the quartz grid stood between routine calibration and structural loss."*)
- **Required Assets (`Batch 4`)**: `res://assets/gameplay/wm_004_cleanroom_console.png`, `res://assets/gameplay/wm_004_laser_deflection.png`, fragment sprites (`quartz_sensor`, `teal_laser`, `magnetic_seal`).

---

### Witness Moment 005 (`WM_005`): The Witness
- **Theme**: The player becoming aware of the Iris itself.
- **Environment**: The deepest internal plane of the **Living Iris** itself (`Midnight`). Bioluminescent seafoam and emerald stroma fibers, crystal cornea reflections, and four orbiting memory shards (`WM_001`–`WM_004`) rotating around the central pupil void.
- **Camera Framing**: Intimate internal optical macro lens shot (`4:3`), infinite optical depth across all multi-spectral stroma layers (`Iris.tscn`). Deep space cyan grading with radiant golden collarette starbursts.
- **Two-Second Observation Event**: The living iris breathes slowly (`0.8s` inhalation, `1.2s` exhalation), the central pupil aperture dilates to reveal the four orbiting memory shards rotating in phase, and the transparent cornea glass reflects the observer's own silhouette looking back into the eye.
- **Hidden Detail**: Every single moment witnessed throughout Chapter 1 literally altered the physical stroma of the eye—the golden prism light from `WM_001`, the palm warmth from `WM_002`, the harmonic resonance from `WM_003`, and the precision calibration from `WM_004` are physically embedded inside the stroma fibers.
- **Player Discovery Objective**: Discover the ultimate truth of Two Second Witness: the observer and the instrument are one unified consciousness. The eye did not just record memory; the eye *became* the memory.
- **Reconstruction Interaction**: Reconstruct the Living Lens (`canvas_shard`, `museum_shard`, `performance_shard`, `reactor_shard`, `golden_collarette`, `pupil_portal`).
- **Reveal Sequence**: Attuning to all four memory shards creates a complete, unbroken ring of light circling the pupil while the full **Atmospheric Phase Lock chord** (`C-G-E harmonic`) sustains into infinity.
- **Iris Commentary (`VoiceGuide` / `revelation.iris_response`)**:
  > *"You noticed the four memory shards orbiting the aperture. You noticed the golden collarette born from your attention. You noticed that every moment you carried became a physical part of this living eye. You did not solve five puzzles. You learned how to see. Rank 2: Witness unlocked."*
- **Archive Entry**: **`The Witness`** (*"The instrument and the observer looked into each other and discovered they were holding the same light."*)
- **Required Assets (`Batch 5 & 6`)**: `res://assets/gameplay/wm_005_internal_stroma.png`, `res://assets/gameplay/wm_005_observer_reflection.png`, fragment sprites (`canvas_shard`, `museum_shard`, `performance_shard`, `reactor_shard`).

---

## 3. Chapter 1 Emotional Loop & Verification Criteria

To verify Phase 6 requirements, the player experience must satisfy the exact continuous emotional loop:
1. **New Player Flow**: Completes "The Awakening" (`TutorialAwakeningScreen.tscn`) -> earns **Rank 1: Observer** -> `WitnessExperienceDirector` loads `WM_001` (`The Unfinished Canvas`) right into the pupil portal.
2. **Dynamic Chapter Progression**: As each moment (`WM_001` -> `WM_002` -> `WM_003` -> `WM_004` -> `WM_005`) is completed, `WitnessMomentOrchestrator` automatically loads the next JSON blueprint, `StateManager` increments `completed_observations`, and `IrisController._sync_progression()` physically evolves the eye (`progression_level: 1 -> 2 -> 3 -> 4`).
3. **Rank 2 Transition**: Completing `WM_005` unlocks **Rank 2: Witness**. The central pupil portal switches permanently from empty potential to displaying preserved archive horizons and daily attunements.
4. **Emotional Deliverable**: The player finishes Chapter 1 feeling:
   > *"I did not solve five puzzles. I learned how to see."*

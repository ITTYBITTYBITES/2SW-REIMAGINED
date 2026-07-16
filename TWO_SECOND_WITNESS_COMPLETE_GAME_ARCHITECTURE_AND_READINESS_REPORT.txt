# TWO SECOND WITNESS — COMPLETE GAME ARCHITECTURE AND PRODUCTION READINESS REPORT

**Project:** Two Second Witness 4.0 (`2SW-REIMAGINED`)
**Publisher:** ITTYBITTYBITES
**Engine:** Godot 4.6.3 — GL Compatibility (OpenGL ES 3.0 class)
**Package:** `com.ittybittybites.the2secondwitness` · version `4.0.0` · version code `40000`
**Audit date:** 2026-07-16
**Audit method:** Read-only repository inspection. No code was modified, added, refactored, or deleted.
**Evidence basis:** 800 tracked files: 171 GDScript files, 55 scenes, 23 JSON data files, 6 shaders, 179 PNGs, 106 Markdown documents (~10,900 lines in `the_iris/documentation/` alone, plus 23 root-level production reports).

---

## 1. EXECUTIVE SUMMARY

Two Second Witness is not a puzzle game with a menu. It is intended to be a **cognitive mystery experience**: the player becomes someone who can witness moments others cannot accurately remember, guided by a living perception instrument called **IRIS**.

The repository today contains something rare and valuable: **a genuinely working vertical-slice of that fantasy, built on top of a complete, mature challenge engine inherited from the 3.x production app** — but the two halves are only partially connected, and most of what would make this a *complete, professional, retainable game* (chapter sequencing, Daily Witness, Training, content pipeline scale, store/release infrastructure, human validation) is still ahead.

### 1.1 What is undeniably built and working

| Area | State | Evidence |
|---|---|---|
| **The Living IRIS itself** | ✅ Implemented | `scripts/IrisController.gd` (571 lines), `shaders/iris.gdshader`, breathing, saccades, blinks, gaze-following, rim cues, memory-shard orbits, progression-synced physical evolution |
| **Gesture-free navigation shell** | ✅ Implemented | `scripts/MainController.gd` (583 lines), tap/hold/swipe zones, pupil "Threshold" enter / "Blink" return transitions, Android Back |
| **Witness Moment runtime machine** | ✅ Implemented | `src/iris/story/WitnessMomentOrchestrator.gd` (321 lines), 8-phase state machine + 4 phase screens + 5 moment JSONs |
| **Chapter 1 content (5 moments)** | ✅ Authored + assets complete | `src/iris/story/content/moment_001..005.json`, 15 generated production images in `assets/gameplay/wm_*` |
| **Legacy challenge engine** | ✅ Complete | `ChallengeSessionService` deterministic generate→validate→score→progress pipeline, 5 challenge families, 6 interaction adapters, 9 programs, 26 achievements |
| **Persistence** | ✅ Implemented | Versioned atomic-save `SaveService`, `ProfileService`, + Iris state (3 save domains) |
| **Android identity/export config** | ✅ Configured | Two presets (dev APK / Play AAB), Gradle custom build, arm64, portrait |
| **Multimodal guidance** | ✅ Implemented | `VoiceGuide` (7 prototype voice clips + OS TTS fallback), captions overlay, haptics, procedural sound synthesis, accessibility panel |

### 1.2 The five most important findings of this audit

1. **Only 1 of 5 authored moments is reachable in the current build.** `MainController._on_tap` hardcodes `_on_moment_requested("WM_001")`. `WitnessExperienceDirector.get_current_chapter_moment()` and `get_next_moment_id()` exist but are *never called by any gameplay path*. WM_002–WM_005 are fully authored (JSON + art) but unreachable without code changes. The root reports (`RANK_1_OBSERVER_IMPLEMENTATION_REPORT.md`) describe a wired sequencing that the current code does not contain.
2. **"The Awakening" tutorial is implemented but orphaned.** `TutorialAwakeningScreen` exists, is instanced in `Main.tscn`, its return flow awards Rank 1 — but *no code path ever calls `_show_screen("tutorial_awakening")`*. The designed first-launch flow (Awakening → Rank 1 → Chapter 1) currently bypasses the Awakening entirely: new players go straight into WM_001, and the Rank 1 reveal never displays.
3. **Two parallel progression authorities now exist.** The legacy engine records `ChallengeResult`s through `PlayerProgressService` (mastery, streaks, witness level). The new `WitnessMomentOrchestrator` bypasses all of that and writes its own fields (`witness_archive`, `witness_moments_completed`, `witness_discoveries`) directly into `ProfileService.profile` with raw `add_xp()`. This is exactly the "second progress model" the foundation governance documents forbid — it must be reconciled before content scales.
4. **Documentation drift is real.** The README documents `MobileSimulator.tscn` as the desktop main scene — **no simulator file exists in the repository** (0 tracked matches) and `project.godot` points to `scenes/Main.tscn`. The README states a 720×1280 viewport — `project.godot` says 540×960. `ANDROID_TEST_PIPELINE_REPORT.md` documents a GitHub Actions workflow `.github/workflows/android-test-build.yml` — **the file is not in the repository**. Repo hygiene: Godot editor artifacts (`.config/godot/`, `.local/share/godot/` logs) are committed to git.
5. **Retention is aspirational.** Daily Witness is a disabled placeholder ("THE DAILY MOMENT IS NOT YET BUILT"), Weekly Investigation is a placeholder, Training Mode does not exist, there are zero notifications, zero remote content, zero automated tests, zero device-test results, and zero store assets. The long-term loop (daily return → improve → unlock) is designed on paper, unbuilt in software.

### 1.3 Readiness verdict

| Assessment | Value |
|---|---|
| Creative vision clarity | ★★★★★ Exceptional — 50+ design docs, coherent voice |
| Foundation architecture quality | ★★★★☆ Strong — clean ownership rules, real state machines |
| Vertical slice completeness (1 moment) | ★★★★☆ Playable end-to-end, unvalidated on device |
| Full game completeness vs. vision | ★★☆☆☆ ~35% — see Section 10 |
| Professional release readiness | ★☆☆☆☆ Not ready — no device tests, no store assets, no retention loop, no crash reporting |

**Bottom line:** The project has a solid, *protected* foundation and a proven creative formula for one moment. It is at the end of "vertical slice," not the beginning of "beta." The next phase must be: **wire what already exists, then industrialize the content pipeline.** Nothing needs to be rewritten; several things need to be *connected*, and a great deal needs to be *planned and built* on top.

---

## 2. PRODUCT IDENTITY AND HARD FACTS

| Fact | Value | Source |
|---|---|---|
| Application name | Two Second Witness | `project.godot` |
| Description | "A premium observation game built around short, fair, replayable challenges, navigated through the Living Iris." | `project.godot` |
| Version / code | 4.0.0 / 40000 | `project.godot`, `export_presets.cfg` |
| Package | `com.ittybittybites.the2secondwitness` | `export_presets.cfg` |
| Engine | Godot 4.6.3 stable | `RUNTIME_ACCEPTANCE_REPORT.md` |
| Renderer | `gl_compatibility` (GLES3) | `project.godot` |
| Main scene | `res://scenes/Main.tscn` | `project.godot` |
| Logical viewport | **540×960** portrait, `canvas_items`/`expand` stretch | `project.godot` (README's 720×1280 claim is stale) |
| Handheld orientation policy | `6` (sensor) in project; Android preset `screen/orientation=1` (portrait) | policy conflict, see §14 |
| Autoload singletons | 23 | `project.godot` |
| Permissions (PlayStore preset) | VIBRATE only; INTERNET=false | `export_presets.cfg` |
| Architectures | arm64 only | `export_presets.cfg` |
| Keystores | Not in repo (by design); debug + release fields empty | `export_presets.cfg` |
| Monetization | None present (no IAP, no ads, no store SDK) | full-tree inspection |
| Network code | None. Offline-first. | `export_presets.cfg`, services |
| i18n | None. English-only strings, no TranslationServer usage, no .po files | full-tree grep |
| Automated tests | **None tracked in repo.** Validation is headless boot + static scan + written reports | `git ls-files` ∩ test = 0 |

---

## 3. COMPLETE ARCHITECTURE DIAGRAM

This is the architecture **as it exists in the code today**, with intended-but-unimplemented layers marked `◌`.

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                      TWO SECOND WITNESS 4.0 (Godot 4.6.3)                    │
│                     Main scene: scenes/Main.tscn  ("Main")                   │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────────┐
        ▼                           ▼                               ▼
┌───────────────┐       ┌────────────────────┐          ┌────────────────────┐
│  COLD START   │       │   23 AUTOLOADS     │          │   PERSISTENCE      │
│ Production-   │       │  (always alive)    │          │  user://           │
│ Startup.tscn  │       │                    │          │                    │
│ (publisher +  │       │ CORE               │          │ profile_v2.json ◄──┼─ SaveService (atomic, .bak, v2)
│  title marks) │       │  EventBus          │          │ settings_v2.json ◄─┼─ SaveService
└───────┬───────┘       │  ConfigService     │          │ the_iris_state.cfg ┼─ Iris StateManager
        │               │  ErrorHandler      │          │ the_iris_voice.cfg ┼─ VoiceGuide milestones
        ▼               │  AppState          │          │ analytics_buffer   │
┌───────────────────┐   │  NavigationService │          └────────────────────┘
│ AppBoot (8 phases)│   │                    │
│ config→save→set-  │   │ PLAYER             │
│ tings→theme→con-  │   │  SettingsService   │     ┌─────────────────────────┐
│ tent→audio→nav    │   │  SaveService       │     │  ANALYTICS (local only) │
│  ProductionBridge │   │  ProfileService    │     │  AnalyticsService       │
│  boots this graph │   │  PlayerProgressSvc │     │  JSONL buffer, 200 max, │
│  inside the Iris  │   │  AccessibilitySvc  │     │  opt-out, NO endpoint ◌ │
└───────────────────┘   │  AchievementSvc(26)│     └─────────────────────────┘
                        │                    │
                        │ CONTENT            │     ┌─────────────────────────┐
                        │  ContentService    │     │  PRESENTATION           │
                        │  ExperienceRegistry│     │  ThemeService           │
                        │  ChallengeRegistry │     │  AudioService (4 buses, │
                        │  FamilyRegistry    │     │   ducking, 28 wavs)     │
                        │  AdapterRegistry(6)│     │  ProceduralSound (synth)│
                        │                    │     └─────────────────────────┘
                        │ GAMEPLAY           │
                        │  RecommendationSvc │     ┌─────────────────────────┐
                        │  ProgramService(9) │     │  IRIS GUIDANCE          │
                        │  ResultService     │     │  VoiceGuide (mp3+TTS)   │
                        │  ChallengeSession- │     │  CaptionOverlay         │
                        │   Service ★        │     │  AccessibilityPanel     │
                        └────────────────────┘     │  EdgeGlow               │
                                                   └─────────────────────────┘
┌──────────────────────────────────────────────────────────────────────────────┐
│ IRIS EXPERIENCE LAYER  (MainController orchestrates; "The Iris is the        │
│ permanent navigation anchor — never replaced by a page")                     │
│                                                                              │
│  LivingIris.tscn ─ IrisController.gd ─ shaders: iris / memory_portal /       │
│  transition / witness.  Breathing, saccades, blinks, rim cues, gaze,         │
│  portal previews (story/archive/profile/daily/calibration), memory-shard     │
│  orbits, progression_level 0-5, awakening sequence.                          │
│                                                                              │
│  InputIntentController → intents: ENTER / FOCUS / RETURN / EXPLORE ×4        │
│  NavigationController (touch/mouse gestures) · BackNavigationController      │
│  TransitionController ("Threshold" in, "Blink" out) · OrientationManager     │
│  DeviceCapabilityManager · StateManager (Iris-only progress + prefs)         │
│                                                                              │
│  Screens in ScreenRoot (one visible at a time):                              │
│   IrisScreen(home) │ WitnessMode │ TutorialAwakening ◌(orphaned) │ Archive  │
│   Discovery │ Profile │ Settings │ StoryMode(ph) │ DailyWitness(ph,disabled)│
│   WeeklyInvestigation(ph) │ YourIris(ph) │ Calibration(ph)                   │
└───────────────┬──────────────────────────────────────────────────────────────┘
                │ center tap ── currently hardcoded "WM_001"
                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ WITNESS ENGINE — two stacks                                                  │
│                                                                              │
│ (A) NEW WITNESS MOMENT RUNTIME  (Story Mode)                                 │
│  WitnessExperienceDirector ─ loads moment_001..005.json, chapter order       │
│   (select_moment / get_current_chapter_moment ◌unused / get_next ◌unused)    │
│  WitnessMomentOrchestrator ─ 8 phases:                                       │
│   arriving→attuning→observing→reconstructing→investigating→revealing→        │
│   archiving→returning   (WitnessMomentState: 12-state enum + snapshot ◌)     │
│  Phase screens (WitnessMomentPhase base):                                    │
│   WitnessObservationScreen  (2.0s locked cinematic, SubViewport +            │
│    ObservationMomentShader effect_mode 1-5, voice intro)                     │
│   WitnessReconstructionScreen (drag fragments→ghost outlines, NO validation) │
│   WitnessInvestigationScreen (attunement hotspots, discovery_threshold,      │
│    iris_intervention)                                                        │
│   WitnessRevelationScreen (stepwise archive entry: carried ☐/☑,              │
│    attunements, iris_note, Insight)                                          │
│  Commit: ProfileService.add_xp + witness_archive entry + counters            │
│  (LEGACY path: WitnessMomentRuntime + ProductionWitnessAdapter →             │
│   ProductionWitnessHost — marked LEGACY_SUPPORT, not used by WM_001+)        │
│                                                                              │
│ (B) LEGACY CHALLENGE RUNTIME  (authoritative, complete)                      │
│  ChallengeSessionService ★: recommend→template→difficulty→exposure→          │
│   generate→validate (3 attempts + fallback + anti-repeat signature)→         │
│   present (route) → respond → score (family policy) → progress →             │
│   recommend next → result                                                    │
│  Contracts: ChallengeFamily/Template/Instance/Result/ValidationResult/       │
│   InteractionProfile/PresentationProfile/TutorialProfile                     │
│  Families (manifest.json v3): scene_investigation, flash_words,              │
│   spot_the_difference, object_recall, pattern_recall + fixtures(regression)  │
│  Adapters: SingleChoice, MultipleChoice, Ordering, RegionSelection,          │
│   SequenceInput, SpatialTap                                                  │
│  Screens (LEGACY_SUPPORT): Tutorial / ObservationChallenge /                 │
│   MemoryQuestion / Result — mounted by ProductionWitnessHost                 │
│  Rooms via ProductionDestinationHost: Archive→Experiences(Observation        │
│   Library) │ Profile→Witness Record │ Settings→Settings/Calibration          │
└──────────────────────────────────────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│ SCENARIO CONTENT LAYER                                                       │
│  Moment JSONs (5): identity/setting/theme/narrative_introduction/mechanics/  │
│   environment(light,camera,animation,audio)/observation(duration,detail      │
│   tiers)/reconstruction(ghosts,palette)/investigation(attunements,threshold)/│
│   revelation/rewards/archive_mapping                                         │
│  Images: 5 backgrounds + 5 reveals + 4 actions + archive frame/horizon       │
│  Legacy content: 5 scenes×24 objects, 373 flash words, 48 recall objects,    │
│   2 procedural families; programs.json (9), achievements.json (26)           │
│  ◌ No schema validator; ◌ no authoring tooling; ◌ WM_006+ not started        │
└──────────────────────────────────────────────────────────────────────────────┘

Legend: ✅ exists & wired · (ph) placeholder scene · ◌ exists un-wired / not built
```

---

## 4. IRIS EXPERIENCE LAYER — SYSTEM-BY-SYSTEM

*IRIS is the player's guide and the perception system: onboarding, guidance, investigation presentation, progression, discovery explanation, recommendations, improvement feedback, and the feeling of an intelligent observation system.*

### 4.1 The Living Iris (the instrument itself)

**What exists (implemented):** `scripts/IrisController.gd` + `scenes/LivingIris.tscn` + `shaders/iris.gdshader` — procedural fibers, limbal rings, aperture, reflections, moisture; 4–6s breathing cycle, micro-saccades (2.2–4.3s), partial blinks (9–15s), inactivity center-invitation, directional anticipation during drags, gaze-follow toward pointer, mouse-follow on desktop; `memory_portal.gdshader` pupil portal that shows destination previews (`assets/iris/reflections/*.png`: story_mode, archive, profile, daily_witness, calibration); `_sync_progression()` maps `completed_observations` → `progression_level` (0–5) → glow strength 0.40→1.0 → orbiting `MemoryFragment_N` shards (radius 162px); awakening sequence for first launch; deep-focus hold state; `remember_recent_activity()` post-return alert memory (0.65 for 5.5s) + 3.4s directional learning sweep; sensor parallax; Reduced Motion + animation intensity scaling.

**Current role:** home screen, navigation anchor, emotional mirror, progression embodiment.

**Intended final role (per `IRIS_LIVING_LENS_IMPLEMENTATION.md`, `IRIS_PERSONALITY_AND_EXPRESSION_GUIDE.md`, `RETURNING_PLAYER_EXPERIENCE_PLAN.md`):** a persistent *character* — it recognizes returning players, remembers evidence, physically evolves rank-to-rank, speaks sparingly with a consistent personality, and is the frame through which every other system is perceived. The foundation for all of this is in code; the *personality depth* (expression matrix, returning-player recognition states, per-rank acoustic signatures) is partially implemented (Rule-based expressions `NEW_PLAYER`, `RETURN`, `WITNESS_COMPLETE`, `FOCUS` in `VoiceGuide`).

**Gaps:** gaze-direction previews and tap destinations are misaligned in two zones (right side previews DAILY WITNESS but tap/swipe opens DISCOVERY; bottom previews CALIBRATION but opens Settings) — `IrisController._update_destination_lens` zones (0.38/0.62) vs `MainController` tap zones (0.28/0.72); no expression states for streaks, daily availability, or archive review; the Returning Player recognition spec exists but the differentiated cold-start behavior is only partly wired.

### 4.2 Navigation & input

**What exists:** hardware-neutral intent layer `InputIntent.gd`/`InputIntentController.gd` (touch, mouse, keyboard, controller, Escape, Android Back → ENTER/FOCUS/RETURN/EXPLORE×4); `NavigationController.gd` gestures with safe margins; `BackNavigationController.gd`; destination switchboard in `MainController._switch_screen` (12 screens, one visible); `_show_screen` enforces "every lateral move returns through the Iris" (avoids page-stack mental models); optical transitions `TransitionController.gd`+`TransitionOverlay.gd`+`transition.gdshader` (pupil travel in, circular vignette out, reduced-motion aware); `OrientationManager` (750ms stability, 480ms settle, state-preserving rotation); `DeviceCapabilityManager` (touch/audio/motion detection).

**Current role:** complete, protected navigation foundation.

**Intended role:** unchanged — this layer is considered done and protected by governance docs. Remaining work is *content for the destinations it opens*, not the navigation.

### 4.3 Home experience

**What exists:** the Iris *is* home. HUD is minimal: brand + descriptor labels only (all directional text labels are instantiated but permanently hidden per `_update_hud`); destination meanings are encoded in rim cues + pupil previews + per-direction lens titles ("CHAPTER 1 : …", "MEMORY ARCHIVE", "YOUR IRIS & PROFILE", "DAILY WITNESS", "INSTRUMENT CALIBRATION").

**Intended role:** IRIS Home as the emotional switchboard: continue investigation (center), daily signal, archive, record, calibration. The *skeleton* is complete; *home intelligence* (rotate center preview between chapter progress and daily witness per `RETURNING_PLAYER_EXPERIENCE_PLAN.md` §4) is designed but not implemented (the daily/armed alternation doesn't exist because Daily doesn't exist).

### 4.4 Onboarding / first-run guidance

**What exists:** `ProductionStartup.tscn` (ITTYBITTYBITES publisher mark → Two Second Witness title mark, ~2.5s); first-launch awakening intro (8.4s timed intro in `MainController`, `iris.start_awakening()`, `voice_guide.begin_session()`); VoiceGuide milestones persisted in `user://the_iris_voice.cfg` ("Initializing" → "Touch the center" → first-touch ack → first-witness framing → hidden-detail ack → return memory → "more to explore"); prototype voice mp3s in `the_iris/audio/` (7 clips) + `DisplayServer` TTS fallback; non-audio equivalents (visual prompts, rim cues, captions via `CaptionOverlay.tscn`); `TutorialAwakeningScreen.tscn` — the 4-scene "Awakening" mini-moment (10s memory, one question "WHAT CHANGED?", gentle wrong-answer dimming, chord + golden reveal on "THE REFLECTION SHIFTED", lesson line, auto-return) — **fully implemented but currently unreachable (see Finding #2)**; Rank 1 reveal (`_show_rank_reveal("RANK 1 : OBSERVER")`) fires only on tutorial return, so it currently never fires.

**Intended role:** the exact first-launch flow in §7.1. The gap is *sequencing wiring*, not missing screens.

### 4.5 Discovery & destinations

**What exists:** `DiscoveryScreen` (swipe right) — constellation of 7 nodes (STORY MODE, DAILY WITNESS, WEEKLY INVESTIGATION, ARCHIVE, YOUR IRIS, CALIBRATION, FUTURE SIGNAL) routing to `FuturePlaceholder` scenes; each placeholder (`FuturePlaceholder.gd`, 130 lines) is a themed procedural animation with destination-specific glyphs (story arc, daily bars, weekly polyline, personal rings, calibration grid), title/eyebrow/description/progress/action copy, and an optional focus-point action. Current configs: **StoryModePlaceholder** (`action_enabled=true`, `moment_id="WM_001"`), **DailyWitnessPlaceholder** (`action_enabled=false`, "THE DAILY MOMENT IS NOT YET BUILT"), **WeeklyInvestigationPlaceholder** (disabled), **YourIrisPlaceholder** (disabled, "PROFILE AND CALIBRATION ARE GATHERING HERE"), **CalibrationPlaceholder** (disabled).

**Current role:** honest "a place is forming" signals that map the future product without fake functionality.

**Intended role:** each placeholder is the *named front door* of a real mode (see §6). The placeholder system is a good scaffold: it already supports progression copy, accent color, and a moment deep-link (`request_moment`).

### 4.6 Profile / record

**What exists, two surfaces:** (a) Iris-room `scripts/Profile.gd` ("WITNESS RECORD") — lightweight progress display from `IrisStateManager`; (b) production `src/ui/screens/ProfileScreen.gd` (779 lines) mounted in the same room through `ProductionDestinationHost(production_route="profile")` — full production profile (XP, level, stats, achievements, programs, history). `WitnessProfileProjection.gd` defines the *future* presentation-only projection (rank name, rank progress, completed moments, mastery, discoveries, records, calibration) for the "Your Iris" space.

**Intended role:** one coherent "Your Iris" personal space: Witness Rank, rank chapters, perception mastery, discoveries, milestones, records, calibration — per `PROFILE_AND_PROGRESSION_EVOLUTION.md`, `PERSONAL_HUB_DESIGN.md`, `RANK_PROGRESSION_EVOLUTION.md`. Not yet unified; two rooms and a disabled placeholder all compete for this role today.

### 4.7 Recommendations & guidance intelligence

**What exists:** `RecommendationService` (260 lines) — start/continue/next recommendations across families with unplayed-type priority, mastery+plays+recency balancing, repeat penalty, weight bonus, unlock gating by Witness Level; `ProgramService` curated runs; `WitnessExperienceDirector` (60 lines) — currently a moment *loader + fixed chapter sequencer*, not yet the director of `WITNESS_EXPERIENCE_ARCHITECTURE.md` §6 (skill/novelty/pacing/variety balancing, continue-thread/shift-perception/rest decisions, anti-randomness policy).

**Intended role:** the Director is the brain of IRIS's guidance: it should choose the next *moment* (not family), balancing mastery, novelty, narrative pacing, incorrect-streak recovery, time-since-play, accessibility, and Iris state. Today it selects by static index only, and even that isn't wired to the entry point.

### 4.8 Calibration (settings framed as instrument calibration)

**What exists:** production `SettingsScreen` (622 lines) mounted in the swipe-up room via `ProductionDestinationHost(production_route="settings")`: sound, comfortable timing, reading comfort, color assist, tutorials toggle, analytics opt-out, privacy; Iris-level `Settings.gd` panel in the same room: animation intensity, high contrast, reduced motion, accessible navigation (explicit access path), captions, orientation lock, parallax; `AccessibilityPanel.tscn` labeled alternate navigation; CalibrationPlaceholder (future dedicated room).

**Intended role:** unified "Instrument Calibration" room per `WITNESS_STORY_ARCHITECTURE.md`; today the functionality is complete but split across two layers again.

### 4.9 Analytics IRIS can use

**What exists:** `AnalyticsService` — versioned JSONL local buffer (200 events/1MB cap), session IDs, events for cold start timing, challenge prepared/rejected/response, respecing opt-out & buffer wipe; `AppBoot` logs boot timing + memory; orchestrator phase prints (debug `print()` calls in `MainController`).

**Intended role:** Director observability (selection reasons inspectable per spec §6 determinism), funnel measurement (first touch → witness entry → completion → next-beat acceptance per `WITNESS_EXPERIENCE_ARCHITECTURE.md` §11). No remote endpoint exists; no dashboards; no crash reporting.

---

## 5. WITNESS ENGINE — THE REASONING LAYER

*Observation challenges, player responses, evaluation, scoring, mastery, difficulty, validation.*

The repository contains **two engines**, and understanding their relationship is the single most important architectural fact of this project.

### 5.1 Engine A — the legacy challenge runtime (complete, authoritative, partially shelved)

Origin: the production Two Second Witness 3.x app, integrated in the 4.0 merge (`documentation/PRODUCTION_APP_AUDIT.md`, `TWO_SECOND_WITNESS_4_INTEGRATION_REPORT.md`).

**Pipeline (all implemented):** `ChallengeSessionService` (444 lines) orchestrates: recommendation/template selection → difficulty resolution (`DifficultyPolicy`) → exposure duration (`ExposurePolicy`) → seeded generation (`ChallengeGenerator`) → fairness validation (`ChallengeValidator`, up to 3 attempts, module fallback, recent-signature rejection) → presentation route → response capture → family-owned scoring (`ScoringPolicy` via `ResultService.build_result`) → progress record (`PlayerProgressService.record_result`) → program/achievement evaluation → next recommendation → result route; replay/continue/return-home; pipeline trace for inspection; analytics hooks. Tutorial gating by per-family tutorial versions + `show_tutorials` setting.

**Content contracts (all implemented):** family/template/instance/result/validation/interaction/presentation/tutorial resources with `get_contract_errors()` self-validation at registration (8 registration-gate checks in `ChallengeFamilyRegistry`).

**Families (manifest.json v3):**

| Family | Focus | Content | Status |
|---|---|---|---|
| `scene_investigation` | Notice what changed | 5 scene JSONs × 24 objects (office, kitchen, workshop, travel desk, garden bench), 6 question types, generated 2D renderer | production |
| `flash_words` | Catch a fleeting signal | 373 reviewed words + templates, timing/hook policies | production |
| `object_recall` | Hold a set in mind | 48 objects, set/sequence scoring | production |
| `pattern_recall` | Recognize connection/order | fully procedural generator (colors/shapes/sequences) | production |
| `spot_the_difference` | Detect meaningful change | fully procedural paired-state generator | production |
| `scene_investigation_fixtures` | deterministic regression | fixture policies | marked `regression_compatibility`, excluded from player rotation |

**Interaction adapters (6):** SingleChoice, MultipleChoice, Ordering, RegionSelection, SequenceInput, SpatialTap (+SpatialTapSurface) — each with accessible-adapter pairing.

**Progression:** `PlayerProgressService` — per-family plays/mastery/accuracy/streaks/history (50 entries)/recent seeds (20), `witness_level` + rank naming, `add_xp` curve in `ProfileService`; 26 achievements (data-driven); 9 programs (daily rotation, bootcamp, rapid recall, mixed rotation, favorites, etc.).

**Current role:** still boots, still authoritative behind `ProductionWitnessHost` (marked `LEGACY_SUPPORT`), reachable via the Archive room → Observation Library → play any family. **It no longer serves the main center-tap experience** (that path was replaced by Engine B), and `ProductionWitnessHost` itself carries a header: *"NOT used by Witness Moment Story Mode (WM_001+). Replaced by: WitnessMomentOrchestrator + Phase Screens."*

**Future intended role (per `CHALLENGE_TO_WITNESS_MOMENT_MAPPING.md`, `FUTURE_WITNESS_MECHANICS_FRAMEWORK.md`, `WITNESS_EXPERIENCE_ARCHITECTURE.md`):** the 5 families become *internal perception mechanics* the Director can embed inside future Witness Moments ("ChallengeSequenceEntry"), plus the practice/training surface for Challenge Mode, Daily Witness, and Weekly Investigation. They are *not* to be deleted — they are the content safety net and the skill-measurement backbone.

### 5.2 Engine B — the Witness Moment runtime (new, Chapter-1 scope)

**Lifecycle implementation (all real code):**

| Beat | Implementation |
|---|---|
| Arrival | `WitnessMomentOrchestrator` phase ARRIVING; `TransitionController.play_enter` ("The Threshold") |
| Attunement | ATTUNING phase; `WitnessObservationScreen` adaptive intro (`maxf(3.2, intro_len×0.055)`), Iris voice reads `narrative_introduction`, breathing prompt, pre-field shader ambience |
| Observation | OBSERVING; locked 2.0s (`observation.duration_seconds` from JSON), no input, acoustic start/end markers + haptic, `ObservationMomentShader` per-moment effect modes (dust motes / museum haze / rosin / laser / stroma), 0.35s optical dissolve out |
| Memory/reconstruction | RECONSTRUCTING; `WitnessReconstructionScreen` (583 lines): ghost outlines (explicit coords or auto 2.5D grid), drag cards from palette, magnetic hover glow, 15ms haptics, background recolor proportional to placed fragments, *no validation, no wrong answers* ("Place what you carry") |
| Investigation | INVESTIGATING; `WitnessInvestigationScreen` (424 lines): attunement hotspots from JSON (spectral/forensic/trajectory/text/thermal/skeletal types), per-object reveals, `discovery_threshold` (3) triggers `iris_intervention` synthesis line |
| Evaluation / truth | REVEALING; `WitnessRevelationScreen` (432 lines): stepwise archive card — carried fragments ☑/☐, attunement list, `iris_note` emotional reframe, Insight (+XP), "memory preserved" achievements |
| Narrative consequence | the `iris_note` itself + physical Iris evolution on return (`_sync_progression`, shard enters orbit) + rank reveal at chapter end (`RANK 2 : THE WITNESS UNLOCKED` at ≥5 observations) |
| Progression reward | `_commit_to_archive()`: `ProfileService.add_xp(rewards.progress_points)`, achievement ids appended, `witness_archive` entry (id/title/category/completed_at/carried_fragments/attunements/iris_note), counters, save |
| Return | ARCHIVING→COMPLETED; `NavigationService.navigate_to("home")` via orchestrator; MainController return polish (reflection tone, `RETURN` expression) |

**Current capabilities:** one continuous, cinematic, penalty-free witness loop; data-driven per moment; resume-safe in the sense that phase state is transient and idempotent (no partial-commit duplication risk).

**What Engine B does NOT yet do (the "reasoning" gap):**
- **No evaluation of correctness.** By design, reconstruction is unvalidated ("there is no wrong answer") — the fiction is "what you carry," but that means the engine currently *cannot measure skill improvement*, which the vision's "presenting player improvement" promise requires. The design docs resolve this by routing measurable mechanics through Engine A sequences inside moments (`ChallengeSequenceEntry`) — that bridge is specified but **not implemented**: Engine B never calls `ChallengeSessionService`.
- **No difficulty adaptation.** `WITNESS_MOMENT_DIFFICULTY_MODEL.md` defines narrative tiers (Attunement/Recognition/Investigation) and 11 scalable dimensions; the JSONs have no difficulty fields; no moment variant selection exists.
- **No resume/snapshot.** `WitnessMomentState.snapshot()` exists, but nothing persists or restores snapshots mid-moment; the spec's save/resume requirements (§"Save and resume") are unimplemented. Rotation/backgrounding mid-moment restarts the phase.
- **No selection intelligence.** Director is index-based; no mastery/history/variety inputs; no fail-soft selection ("A failed Director selection falls back to a valid recommendation").
- **No failure/variant paths.** `fail()` only handles asset/script errors; there are no alternate reveals for low-notice players, no reinforcement beats.
- **No moment-level accessibility variants** (comfortable timing does extend nothing in Engine B; captions exist globally but moment audio has no transcript delivery).
- **No analytics events** from the moment funnel (only stdout debug prints).

### 5.3 Engine A vs Engine B — the reconciliation that must happen

| Dimension | Engine A (legacy) | Engine B (moments) |
|---|---|---|
| Records `ChallengeResult` | ✅ yes | ❌ never |
| Family mastery / streaks / witness level | ✅ updated | ❌ untouched (raw `add_xp` only) |
| Validation/fairness | ✅ contract-enforced | ➖ none by design |
| Difficulty scaling | ✅ policies | ❌ none |
| Save authority | ✅ schema-owned | ⚠️ ad-hoc fields appended to profile dict |
| Analytics | ✅ events | ❌ prints only |

This is the project's central technical risk (see §15): *two progression writers* in one profile. Governance anticipated this ("Do not create a second production save or profile model in Iris scripts" — `PROJECT_FOUNDATION.md`), and Engine B currently violates the spirit of that rule with `witness_archive`/`witness_moments_completed`/`witness_discoveries` ad-hoc fields. It works, but it must be formalized into the profile schema (versioned migration through `SaveService`) before more content lands on it.

---

## 6. SCENARIO CONTENT LAYER

*Environments, characters, events, observation periods, hidden inconsistencies, clues, questions, outcomes, narrative meaning.*

### 6.1 Content architecture as built

```text
Authoring format          Runtime load                 Presentation
────────────────────────────────────────────────────────────────────
moment_00X.json    ──►    WitnessExperienceDirector ──►  WitnessMoment (Resource)
(env/obs/recon/             FileAccess+JSON.parse          from_dictionary()
 inv/rev/rewards)          (5 hardcoded filenames)        to_blueprint()
                                                    ──►  phase screens read dicts
LegacyMechanics/*           ChallengeFamilyRegistry ──►  ChallengeFamilyModule(s)
 content/*.json    ──►      manifest v3 (6 modules)        templates carry content_data
programs.json      ──►    ProgramService
achievements.json  ──►    AchievementService
experiences/manifest ──►    ContentService (user:// OTA override path exists, unused)
```

**Moment definition schema (actual, from `moment_001.json`):** `moment_id`, `chapter_id`, `title`, `setting`, `theme`, `rank_requirement`, `narrative_introduction`, `mechanics` (5 prose mechanic descriptions), `environment` (background/action/reveal image paths, location, time, lighting, camera, animation beats, ambient_details, audio layers), `observation` (duration, input=false, transition, 4-tier noticeable_details: surface/subtle/deep/intentionally_missed_first_view), `reconstruction` (ghost_outlines, fragment_palette w/ emoji icons, validation="none", iris_prompt), `investigation` (attunements array w/ object/type/reveals, discovery_threshold, iris_intervention), `revelation` (iris_response, archive_entry fields), `rewards` (progress_points, archive_entry, mastery delta, achievements), `archive_mapping`.

### 6.2 The five moments of Chapter 1: "Learning to Notice"

| ID | Title | 2-second event | Hidden truth | Attunements | Runtime status |
|---|---|---|---|---|---|
| WM_001 | The Unfinished Canvas | Painter lifts brush, pauses, lowers it untouched | Prism splits the 5:14 light; the *light* completed the composition | 4 (spectral/forensic/trajectory/text) | ✅ reachable (center tap) |
| WM_002 | The Forgotten Museum | Guard rests palm on case 1.0s, checks pocket watch | He touches where his grandfather's name is etched | 3 (forensic/text/thermal) | ⚠️ authored, unreachable |
| WM_003 | The Last Performance | Violinist lowers bow, touches telegram, closes latch | The final note was already safely across the sea | 3 (text/forensic/spectral) | ⚠️ authored, unreachable |
| WM_004 | The Faulty Reactor | Physicist watches laser shift 0.2mm, pulls seal | A fraction of a millimeter vs structural loss | 3 (spectral/thermal/trajectory) | ⚠️ authored, unreachable |
| WM_005 | The Witness | The Iris turns inward; four shards orbit; observer reflected | Observer and instrument hold the same light | 4 (one per prior moment) | ⚠️ authored, unreachable |

Each has complete env/reveal/action art (Batch 1–9 per `ASSET_GENERATION_PROGRESS.md`) bound into its JSON.

### 6.3 Characters / events / hidden inconsistencies — how the content model maps the vision

The vision calls for *characters, events, hidden inconsistencies, clues, questions, outcomes*. The current schema supports: **environment** ✅, **event** (the 2s action, as prose + one action still + shader FX) ⚠️, **hidden truth** (iris_note + attunement reveals) ✅, **clues** (attunements) ✅, **questions** (reconstruction prompt only — no interrogative mechanics) ⚠️, **characters** (present in art/copy but no character/relationship model — no recurring-cast schema) ❌, **outcomes that alter later content** (chapter sequence is linear; no branching/version flags) ❌, **inconsistency between observation and "official" account** (the core mystery-fantasy mechanic — *unreliable events*) — **not yet modeled anywhere**. Today's model is *"hidden meaning,"* not yet *"unreliable memory."* That is the single largest content-design gap between the built game and the stated vision ("reconstruct unreliable events").

### 6.4 How future scenarios would be created (today's pipeline)

1. Author from `WITNESS_MOMENT_TEMPLATE.md` (249-line authoring template with quality gates).
2. Create `moment_00N.json` matching the `WitnessMoment.from_dictionary` schema (bind art paths).
3. Generate/acquire 2–3 key images (background, action, reveal) per `ASSET_PIPELINE_PLAN.md`; add `effect_mode` support in `ObservationMomentShader.gdshader` if new ambience is needed — **note:** `WitnessObservationScreen._on_configure` matches `moment_id` → `effect_mode` in a hardcoded `match` for WM_001..005, so a 6th moment requires a code edit (contradicts the "no hardcoded branch" claim in `CHAPTER_1_RUNTIME_INTEGRATION_REPORT.md`).
4. Register the id in `WitnessExperienceDirector.CONTENT_DIR` file list **and** `CHAPTER_MOMENTS` (both are hardcoded arrays).
5. Ensure sequencing code can reach it (currently impossible — §1.2 Finding 1).
6. Rewards: choose `progress_points`, achievements (must exist in `achievements.json` for proper display), archive mapping.
7. Validate manually — **no schema validator, no content lint, no automated check exists.**
8. Voice: add narrative audio or rely on TTS at runtime (`_speak` uses VoiceGuide/TTS).

**Chapter 2 & beyond:** `ASSET_GENERATION_PROGRESS.md` names "Chapter 2: The Silent Signal (WM_006–WM_010)" as the next batch point; `FIRST_100_WITNESS_MOMENTS.md` provides 100 directional one-liners across 10 chapters; `CHAPTER_ONE_DESIGN.md` describes a *different* 10-moment Chapter 1 (documentation drift — the shipped 5-moment chapter superseded it); root `WM001_DESIGN.md` contains a *different WM_001 story* (tea cup / grief) than the shipped Unfinished Canvas — superseded design, should be archived to avoid authoring confusion.

### 6.5 Asset systems

| Bucket | Contents | Evidence |
|---|---|---|
| `assets/gameplay/` | 162 files: `wm_*` 15 chapter images, legacy per-family folders (`scene_investigation/`, `flash_words/`, `object_recall/`, `pattern_recall/`, `sprites/`), `featured_desk_scene*.png`, 5 `observation_challenge_*.png`, preview SVGs | tracked files |
| `assets/audio/` | 28 wavs: 5 BGM (home/gameplay/publisher/results/tutorial) + 23 SFX (reveal/mastery/ui/flash/pattern/object) | listing |
| `the_iris/audio/` | 7 Iris voice mp3 prototypes + `default_bus_layout.tres` | listing |
| `assets/iris/` | base, fibers, cornea_reflection, outer_glow, pupil_portal + 5 reflection previews | listing |
| `assets/brand/`, `assets/splash/` | app icon 1024, adaptive icons, publisher + title splash marks | `export_presets.cfg` |
| `assets/programs/` | 9 program SVG artworks | listing |
| Empty buckets | `assets/home/`, `assets/scenes/`, `assets/record/`, `assets/evidence/`, `assets/branding/`, `assets/backgrounds/` (1 legacy menu bg) | reserved for future |
| Shaders | 6: iris, memory_portal, transition, witness, ObservationMoment, Attunement | `shaders/` |

**Asset truth the docs gloss over:** the "2-second cinematic moment" is currently **a still image + shader ambience** (dust/haze/laser), not motion art. The JSON `animation` blocks (hand lifts 0.7s → pauses 0.8s → lowers 0.5s) are *descriptive prose*, not executed animation. For 100 moments this is a major production decision: stay with living stills (achievable, coherent) or fund true 2s motion cinematics (animation pipeline, rig/cutout or video, ~5–10× asset cost). This must be planned *now* because it defines the entire content budget.

---

## 7. GAME MODES

### 7.1 Story Mode (the narrative campaign)

**Intended structure:** Chapter → Investigation → Witness Moment → Deduction → Story progression → New discovery. Ranks: 1 Observer ("I Notice"), 2 Investigator/Witness ("I See"), 3 Archivist/Chronicler ("I Preserve"), 4 Weaver ("I Connect") (`RANK_PROGRESSION_EVOLUTION.md`, `STORY_MODE_FOUNDATION.md`).

**Current architecture:** Iris center = Story Mode threshold; chapter = fixed 5-moment sequence ("chapter_01_learning_to_notice"); investigation = attunement phase inside each moment; deduction = reconstruction (unvalidated by design); progression = XP + witness_archive + iris physical evolution + rank reveal.

**What exists:** complete per-moment machinery; one complete chapter's *data and art*; rank reveal banners; archive persistence; chapter-completion unlock state at 5 observations.

**What remains:** (1) wire the sequencer (use `get_current_chapter_moment` at entry; end-of-chapter redirect to Daily/Archive as the lens already advertises); (2) the *Investigation* and *Deduction* layers as distinct product beats (currently sub-beats inside a moment); (3) chapter select/chapter map for Rank 2+; (4) Chapter 2 content (WM_006–010 designed only as names); (5) the Director's narrative pacing (continue/shift/rest); (6) the "unreliable account" mystery layer (§6.3); (7) chapter resume (mid-chapter interruption outside a moment is fine; mid-moment is not).

### 7.2 Challenge Mode (replayable skill mode)

**Intended:** practice, mastery, scoring, replayability.

**Existing support:** the entire legacy stack *is* a challenge mode — Observation Library (`ExperiencesScreen`), per-family tutorials (5 scenes), free play with scoring/ranks/records, 9 Programs (structured runs), favorites, personal stat records. It is reachable today: Iris left → Archive room → production Experiences screen.

**Missing pieces:** it is not *framed* as Challenge Mode; no visible mastery targets or score-chase presentation in the Iris layer; no daily variant integration; governance docs want it repositioned as the Archive/Training secondary room rather than a first-class mode; decision needed: does Challenge Mode keep legacy screens (fast) or get Iris-framed presentation (slow but coherent)? UX debt: the legacy screens use the production ThemeService visual language (cards/buttons) which is stylistically different from the optical Iris layer.

### 7.3 Daily Witness (retention system)

**Intended:** one short offline personal moment per day; deterministic; streaks; personal best; no server/leaderboard (`DAILY_WEEKLY_EXPERIENCE_ARCHITECTURE.md`).

**Current foundation:** placeholder room (disabled, "THE DAILY MOMENT IS NOT YET BUILT"); `programs.json` has a `daily_witness` program (3-round daily rotation, `schedule:"daily"`); `ProgramService._is_scheduled_now` daily logic; `DailyExperienceCard` component (start/continue UI, mastery/duration display, locked states); streak fields (`streak_current`/`streak_best`) in profile stats; lens preview + copy for DAILY WITNESS already exist on the Iris; spec contract (local date, deterministic seed, completion, best, streak, evidence ref, accessibility context).

**Remaining requirements:** (a) a `DailyWitnessService` (deterministic date→seed→moment/family selection with recent-signature avoidance); (b) daily completion/best/streak persistence fields + migration; (c) IRIS home integration (center alternation chapter↔daily per returning-player spec); (d) streak visual language on the Iris (rim/mark); (e) the daily *moment itself* — reuse Engine A rounds (fast) or a rotating moment pool (needs content); (f) local reminders decision (notifications permission is off; no code); (g) timezone/week boundary rules; (h) analytics events.

### 7.4 Training Mode (skill exercises)

**Intended:** short exercises to improve observation skills.

**Current status:** no mode exists. De facto components: 5 family tutorials, the Observation Library (untimed replay), comfortable-timing accessibility setting, exposure policies that lengthen observation for accessibility. Concepts for skill-targeted drills live in `FUTURE_WITNESS_MECHANICS_EXPLORATION.md` (689 lines) and `SENSORY_SYSTEM_ROADMAP.md`.

**To build it:** define 4–6 drill types mapped to perception abilities (notice-a-field, fleeting-signal, meaningful-change, hold-a-set, recognize-order — the mapping already exists in `WITNESS_EXPERIENCE_ARCHITECTURE.md` §8), wrap Engine A sessions in a training frame, surface skill deltas on Your Iris, unlock via Rank 2.

### 7.5 Weekly Investigation (bonus mode in docs, not in the task list but designed)

Placeholder room + full data contract spec (weekly case, ordered moments, progress, resume, archive reward, deterministic local week). Zero implementation.

---

## 8. PLAYER EXPERIENCE FLOW — INTENDED vs ACTUAL

### 8.1 FIRST LAUNCH

| Stage | Intended (vision docs) | What exists TODAY (code-verified) | Missing / broken |
|---|---|---|---|
| Sponsor screen | ITTYBITTYBITES mark → title mark | ✅ `ProductionStartup.tscn` (~2.5s, both marks, skippable-by-design) | device unverified |
| Loading | service boot behind splash | ✅ `AppBoot` 8 phases behind `ProductionBridge`; boot telemetry event | no progress UI for slow devices |
| IRIS introduction | awakening sequence, "Attention is the beginning of memory" | ✅ 8.4s intro, awakening animation, VoiceGuide init, "Initializing/Touch the center" | voice is prototype TTS-recorded mp3s; no localization |
| First calibration witness (The Awakening) | 4-scene mini-moment: gaze→lens→question→archive→**RANK 1** | ⚠️ `TutorialAwakeningScreen` fully implemented — **but never entered**; center tap goes straight to WM_001; Rank 1 reveal dead code | the route into it (one `if` at center-tap: `onboarding_tutorial_completed==false` → awakening) — *currently missing* |
| IRIS home (as post-onboarding state) | pupil shows Chapter 1, shard orbits | ✅ works (lens title logic, shard spawn after obs≥1) | gaze/tap zone mismatch on 2 directions |
| First story experience | Chapter 1 moment 1 | ✅ WM_001 end-to-end | intro vs. awakening order inversion (player witnesses *before* being taught witnessing) |

### 8.2 RETURNING PLAYER

| Stage | Intended | Exists today | Missing |
|---|---|---|---|
| Open app | instant awake instrument, recognition | ✅ bypasses intro when `first_launch==false`; `RETURN` voice expression | differentiated returning visuals partially coded (`awakening_level` concept) — verify on device |
| IRIS Home remembers | recent-activity memory, directional pulse, rank visuals | ✅ `remember_recent_activity`, shards, glow by obs count | streak/day-based differences |
| Continue investigation | lens shows next chapter moment; tap enters it | ⚠️ lens *titles* advance with obs; **tap always launches WM_001** | sequencing wiring (Finding 1) |
| Daily Witness | center/destination offers today's moment | ❌ placeholder only | entire mode (§7.3) |
| Training | drills | ❌ | entire mode (§7.4) |
| Archive | reopen preserved moments | ⚠️ `witness_archive` data is saved; the Archive room shows production Experiences; **no UI renders the witness_archive entries** | archive reading room UI (moments list, entry cards with carried fragments + iris_note) |
| Progress | Your Iris personal space | ❌ placeholder | unified profile/rank/records room |

---

## 9. WITNESS MOMENT ARCHITECTURE — LIFECYCLE MAPPING

Intended 7-stage lifecycle vs current runtime:

| # | Lifecycle stage | Runtime support today | Evidence / gap |
|---|---|---|---|
| 1 | **Context** | ✅ narrative intro + attunement phase, voice + breathing prompt | `WitnessObservationScreen` adaptive intro; no chapter-context screen (investigation brief) |
| 2 | **Observation** | ✅ locked 2.0s window, no input, shader ambience, haptic/acoustic markers, dissolve out | still-image-based; no motion; no `input_accepted` variants despite JSON flag |
| 3 | **Memory / reflection** | ✅ spatial fragment placement, no validation, recolor feedback | `WitnessReconstructionScreen`; no timing pressure options; no accessibility variant of dragging (comfortable alternatives?) |
| 4 | **Reasoning challenge** | ⚠️ investigation attunements + threshold | present but *exploratory* (free taps), not a *reasoning challenge*; no deduction questions; Engine A integration (the measurable reasoning) is spec'd, unbuilt |
| 5 | **Evaluation** | ⚠️ reveal compares carried vs. available (☑/☐) | qualitative only; no skill score from moments; no difficulty feedback loop |
| 6 | **Narrative consequence** | ✅ iris_note reframe + physical iris evolution + rank reveal | strong for chapter arc; no consequence *within* a larger investigation narrative (no case state) |
| 7 | **Progression reward** | ✅ Insight XP, achievements, archive entry, shard orbit | ad-hoc profile fields (§5.3); no streak/mastery interaction; no unlock of harder content tied to moment performance |

**ProductionWitnessHost:** the original bridge mounting legacy Tutorial→Observation→Recall→Result into the Witness doorway. Now marked `LEGACY_SUPPORT`; kept for non-Story modes (Daily/Weekly/Discovery per `LEGACY_SUPPORT.md`) and as the fallback if Engine B must be bypassed. Retain.

**Moment definitions:** see §6. **Chapter integration:** `chapter_id` on every moment + Director's fixed `CHAPTER_MOMENTS` order + lens title ladder + rank reveal at 5 completions.

**Remaining content requirements:** ~95 moments of the published 100-moment roadmap; chapter 2–10 themes; a definition schema v2 (difficulty axes, engine-A sequence refs, character/case fields, localization keys, content version, accessibility variants, resume checkpoints); a validator; an authoring checklist (`WITNESS_MOMENT_TEMPLATE.md` exists but isn't enforced by tooling).

---

## 10. COMPLETION PERCENTAGES

Percentages are the auditor's judgment against the *stated final vision*, each backed by named evidence above.

| System | % | Basis |
|---|---|---|
| Living Iris / navigation shell | 85% | Feature-complete + polished; docs drift (simulator), gaze/tap mismatch, device-untested |
| Onboarding / Awakening | 55% | Fully built, but orphaned from the flow (never entered in normal play) |
| IRIS guidance (voice/haptics/captions) | 70% | Milestones + TTS fallback work; prototype voice assets; no final VO; no localization |
| Witness Moment runtime (Engine B) | 60% | 8-phase machine + 4 screens + commit; no resume, no difficulty, no engine-A sequences, no variants |
| Chapter 1 content | 80% (of one chapter) | 5/5 authored+art, 1/5 reachable |
| Story Mode (multi-chapter campaign) | 30% | 1 of ~10 planned chapters; no chapter map; sequencing unwired; no case/investigation layer |
| Legacy challenge engine (Engine A) | 90% | Complete pipeline; needs product framing + regression test automation |
| Challenge Mode (skill play) | 60% | Works via Archive; unframed, unadvertised, style clash |
| Daily Witness | 12% | Spec + program + card UI + streak fields; no daily service/content/completion |
| Weekly Investigation | 8% | Spec + placeholder only |
| Training Mode | 12% | Concept mapping + reusable primitives; no mode |
| Scenario content pipeline | 25% | 5/100 moments; manual authoring; no validator; art strategy undecided (still vs motion) |
| Save / profile system | 80% | Atomic+backup+migration solid; moment fields ad-hoc (needs schema v3) |
| Accessibility | 65% | Broad feature set; never user-validated; Engine B variants missing |
| Audio | 55% | Buses/ducking/28 wavs + synth + voice proto; no final VO, no moment BGM, no mixing pass |
| Analytics | 35% | Local event buffer only; no backend, dashboards, crash reporting |
| Android pipeline | 45% | Presets+gradle configured; no device matrix executed; no CI in tree; signing external |
| Store / release readiness | 5% | No listing assets, privacy page, rating, monetization decision, support site |
| **Overall vs. "100% professional game"** | **≈35%** | weighted product judgment |

---

## 11. MISSING COMPONENTS (CONCRETE INVENTORY)

**Immediate wiring (days, not weeks):**
1. Chapter sequencing at entry: use `WitnessExperienceDirector.get_current_chapter_moment(completed_observations)` (and post-chapter-5 → Daily/Archive route) in `MainController._on_tap` and Story Mode placeholder; remove the hardcoded `"WM_001"` default in both `WitnessMomentOrchestrator.start_moment()` and `WitnessMomentRuntime.start_moment()`.
2. First-launch route: `onboarding_tutorial_completed == false` → center tap enters `tutorial_awakening` before any moment; on return, existing rank-reveal + `complete_onboarding_tutorial()` already work.
3. Align `IrisController` gaze preview zones with `MainController` tap zones (or normalize the copy so right = Discover matches).
4. Data-driven moment registry: replace hardcoded filename array + `CHAPTER_MOMENTS` with a directory scan/`chapter_01.json` manifest; replace `effect_mode` `match` on `moment_id` with a JSON field.

**Story Mode depth (weeks):**
5. Persist/restore `WitnessMomentState.snapshot()` (resume mid-moment; version check per runtime spec).
6. Chapter shell: chapter card/brief screen, chapter map, end-of-chapter ceremony, Rank 2 content gate message.
7. Director v2: inputs (mastery/history/streaks/recency/variety/settings) → moment selection with logged reasons + fail-soft fallback.
8. Moment schema v2 + validator script (required keys, asset existence, threshold sanity, achievement id refs).
9. Engine-A sequence embedding (`challenge_sequence` field) so moments can contain measurable reasoning rounds — unlocking evaluation, mastery, difficulty.
10. Archive reading room: render `witness_archive` entries (title, carried fragments, attunements, iris_note, date), replay affordance.

**Modes:**
11. `DailyWitnessService` + completion/streak persistence + Iris home alternation + streak visuals.
12. Training Mode frame over Engine A drills + skill-delta surfacing.
13. Weekly Investigation alpha (local deterministic case).
14. Challenge Mode framing pass (naming, entry copy, optionally Iris-styled wrapper).

**Professional polish:**
15. Final voice: choose TTS-per-device vs. recorded VO (9+ needed phrases/moment × language), then produce.
16. Moment music beds (5 legacy BGM exist; moments currently have no per-moment score beyond synthesized tones).
17. Reconstruction accessibility alternative to drag (tap-to-place), dynamic type validation in phase screens, color-assist in reveal card.
18. Performance: texture memory budget (five ~3MB PNGs + full-screen shaders), GLES3 low-end validation, battery/thermal soak, 60fps target on 2019-class devices.
19. Crash reporting (e.g., Godot-compatible reporter) + analytics backend decision + privacy review.
20. Store kit: icon final, feature graphic, screenshots (device-captured), short description/full description, data-safety form (analytics local-only = favorable), IARC questionnaire, privacy policy URL + in-app terms content review (`PrivacyTermsDialog` exists), support channel.
21. CI: restore or rewrite the documented `android-test-build.yml` (currently absent); add headless parse-check + export smoke on PRs; consider a minimal GUT/test harness for registries and save migrations.
22. Repo hygiene: drop tracked `.config/.local` Godot editor logs; add/refresh `.gitignore`; reconcile README with reality (main scene, viewport, simulator).

**Undecided-by-design items that REQUIRE a decision before production scales:** monetization (premium vs. IAP chapter packs vs. subscription vs. none-at-launch), art strategy (living stills vs. motion cinematics), notification policy, account/cloud-save policy (currently single-device only; no migration path if a player changes phones), age-rating target and content policy for "mystery" themes.

---

## 12. THE PROFESSIONAL-GAME GAP: EVERYTHING LEFT TO PLAN

*This section directly answers: what must still be planned for a 100% professional game.*

### 12.1 Product & design planning
- **Full season narrative bible:** 10 chapters × ~10 moments: theme continuity, recurring characters, the unreliable-account mystery grammar (who mis-remembered, and what the player corrects), ending states per chapter.
- **Moment authoring workflow:** writer→art→integration→review pipeline with the existing template; per-moment cost estimate; weekly production quota; review gates (fairness, accessibility, comprehension tests).
- **Difficulty & measurement design:** which moments are measurable (Engine A sequences) vs. contemplative; how "improvement" is quantified and *shown* to the player (the vision's promise); onboarding-vs-mastery exposure curves.
- **Director behavior spec v2:** concrete selection algorithm, cooldowns, recovery beats, rest logic, daily interplay.
- **Retention economy:** streak rules, forgiveness (streak freeze?), comeback flow, long-term mastery ceiling (Ranks 5+), endgame for completers.
- **Accessibility validation plan:** low-vision, motor, cognitive, color-blind users; caption/transcript coverage for every spoken moment; external audit.
- **Localization strategy:** language list, string extraction (all strings are currently inline English), narrative translation quality bar, TTS per locale.

### 12.2 Content production planning
- Art direction guide (palette, framing, light grammar per chapter) + AI-asset disclosure review for store policy compliance.
- Motion decision & pipeline (still + shader vs. cutout animation vs. video) with per-moment budget.
- Audio production: final VO casting/direction or TTS voice curation; per-moment ambient beds; mix/master pass; loudness targets for mobile.
- Asset capacity plan: ~100 moments × 2–3 images = 200–300 production images + reveals + icons; storage/bundle-size strategy (100 PNGs × ~3MB ≈ 300MB → needs compression, streaming, or OTA packs — `ContentService`'s `user://content/` override exists but no downloader/CDN/versioning is planned).

### 12.3 Engineering planning
- Save schema v3: formalize witness fields, daily state, chapter state; migration tests; corrupted-save UX.
- Engine A↔B unification: moments reporting through `ChallengeResult`-compatible records, or an explicit "moment record" contract; one progress authority.
- Automated testing: registry contract tests (the 8 registration gates exist — wrap them), save migration tests, golden-path integration test (boot→awakening→WM_001→archive), CI wiring.
- Crash/logger strategy for release builds (current debug `print()` funnel must become structured events).
- Performance budgets & device matrix define-and-test loop.
- OTA content system design (if content ships post-launch without app updates).

### 12.4 Release & business planning
- Monetization model + price tests; Play policy mapping (no loot boxes/ads simplifies compliance).
- Store listing production, A/B tests, localized listings, age ratings (IARC/ESRB/PEGI), privacy policy hosting + data safety (favorable: offline, no PII), terms review.
- Release ops: Play signing key custody, release tracks (internal→closed→open), staged rollout, rollback criteria, support inbox/FAQ, community channel decision.
- Marketing: trailer (the 2-second hook is inherently trailer-friendly), press kit, creator outreach, soft-launch geography, KPI targets (D1/D7/D30, moment completion, awakening completion, daily streak adoption).
- Live-ops calendar: daily content rotation rules, weekly investigations, seasonal chapters, content versioning & save-compat policy.

### 12.5 Team/process planning
- Ownership map per system (design/code/content), bus-factor mitigation, the docs-as-governance process formalized (this repo already runs on documented passes; keep it), milestone schedule against the phases in §16.

---

## 13. DEPENDENCIES

**Internal (must-keep-healthy chains):**
- Everything visual → `iris.gdshader` + GLES3 compatibility (GL Compatibility renderer is a hard constraint).
- Story Mode → `WitnessExperienceDirector` moment availability → JSON schema stability → asset paths under `assets/gameplay/`.
- Progress → `ProfileService` shape consumed by: `PlayerProgressService`, `AchievementService`, `ProgramService`, `RecommendationService`, orchestrator commit, Profile/Your Iris screens.
- All non-story modes → Engine A contracts (8 registration gates) + `ChallengeSessionService` + interaction adapters.
- Any future OTA → `ContentService`'s user:// override (exists) + a not-yet-existent downloader/versioner.
- Rank reveals/shards → `IrisStateManager.completed_observations` (Iris-side counter) — note it is incremented by *both* legacy witness flow and moment completion; unify counters when reconciling engines.

**External:**
- Godot 4.6.3 + matching Android export templates; JDK 17 + Android SDK for Gradle builds; Play Console account + private release keystore (external by design); device TTS engine availability (Android DisplayServer TTS varies by OEM — voice fallback design must degrade gracefully); Play policies (data safety, AI-content disclosure); hardware variance for full-screen shaders and 3MB textures on low-end ES3 devices.

---

## 14. DISCREPANCIES & DOCUMENTATION DRIFT (AUDIT FINDINGS)

| # | Claim (document) | Reality (code/tree) | Action |
|---|---|---|---|
| 1 | README: desktop main scene is `MobileSimulator.tscn`; hotkeys F1–F10, 5–8 | No simulator file exists anywhere (0 tracked); main scene is `Main.tscn` | restore tool or rewrite README + all report references |
| 2 | README: 720×1280 viewport | `project.godot`: 540×960 | fix README |
| 3 | `ANDROID_TEST_PIPELINE_REPORT`: workflow `.github/workflows/android-test-build.yml` validated | No `.github/` in repo | add workflow or mark report aspirational |
| 4 | `RANK_1_OBSERVER_IMPLEMENTATION_REPORT`: center tap "does not hardcode WM_001; it queries get_current_chapter_moment" | `_on_tap` → `_on_moment_requested("WM_001")`; helpers uncalled | wire sequencer (Finding 1) |
| 5 | `FIRST_EXPERIENCE_DESIGN`: center tap while `onboarding==false` opens The Awakening; Rank 1 reveal | No caller of `_show_screen("tutorial_awakening")`; reveal unreachable | restore route (Finding 2) |
| 6 | `CHAPTER_1_RUNTIME_INTEGRATION_REPORT`: "no hardcoded `if moment_id` branch inside phase screens" | `WitnessObservationScreen._on_configure` `match moment_definition.moment_id` → effect_mode | move effect_mode into JSON |
| 7 | `CHAPTER_ONE_DESIGN.md`: 10-moment Chapter 1 starting "The Forgotten Museum" | Shipped chapter: 5 moments, starts "The Unfinished Canvas" | mark design doc superseded |
| 8 | Root `WM001_DESIGN.md`: WM_001 = tea cup/grief story | Shipped WM_001 = painter/prism | archive superseded |
| 9 | Governance: "no second progress model in Iris scripts" | Orchestrator appends 3 ad-hoc profile fields + raw add_xp | schema v3 migration |
| 10 | Orientation: project runtime sensor(6)+OrientationManager; Android preset portrait(1) | policy conflict unresolved ("final sensor-orientation policy requires device approval" — baseline doc) | decide at device testing |
| 11 | Repo hygiene: `.config/godot`, `.local/share/godot` logs tracked in git | committed artifacts | untrack + ignore |
| 12 | `LEGACY_SUPPORT.md` swaps `ChallengeSessionService` location (`src/gameplay/session/`) vs actual `src/gameplay/runtime/` | stale path in doc | doc fix |

---

## 15. RISKS

| Risk | Severity | Notes |
|---|---|---|
| Content unreachable (WM_002–005) | 🔴 Critical | 80% of finished chapter content invisible to players; first fix of next phase |
| Dual progression authority | 🔴 Critical | Two writers to one profile; every new moment deepens the debt; reconcile before Chapter 2 |
| No device validation of anything | 🔴 High | All reports are headless/static; shader perf, timing feel, safe areas, haptics, TTS, Back all unproven |
| Retention loop absent | 🔴 High | Without Daily Witness the game is a 25-minute one-shot; the business case depends on §7.3 |
| Content economics un proven | 🟠 Medium-High | A moment = ~3 premium images + writing for ~3 minutes of play; 100-moment ambition needs the art-strategy decision *now* |
| Documentation drift | 🟠 Medium | Reports describe behavior code lacks; new contributors (human or AI) will build on false claims — this report exists partly to re-baseline truth |
| Single-platform, offline, single-device saves | 🟠 Medium | Lost phone = lost witness record; cloud save decision pending; Android-only reach |
| Store/policy unknowns | 🟠 Medium | AI-generated imagery disclosure, privacy page hosting, age rating, support requirements unaddressed |
| Low-end GLES3 performance | 🟠 Medium | Full-screen multi-layer shaders + large textures untested on 2019-class hardware |
| Two visual languages coexist | 🟡 Low-Medium | optical Iris layer vs. card-based production screens; acceptable during transition, must converge |
| Orphaned legacy screens/tests | 🟡 Low | Fixture family and legacy host are intentionally retained; keep regression value, avoid player exposure |

---

## 16. RECOMMENDED NEXT PRODUCTION PHASE

*Principle (from governance): migrate the doorway, protect the rooms. No rewrites — connect, formalize, then scale.*

### Phase A — "Reconnect the slice" (stabilization; ~1–2 weeks)
1. Wire chapter sequencing + first-launch Awakening route + post-chapter redirection (findings 1–2).
2. Fix gaze/tap zone mismatch; data-drive moment registry & shader effect_mode.
3. Device pass #1: install export templates, build dev APK, run human hands-on matrix (timing, shaders, Back, rotation, haptics, TTS); record results into an acceptance report.
4. Repo hygiene: untrack editor artifacts, refresh `.gitignore`, reconcile README; add CI parse-check (+ optionally restore Android workflow).
5. Playtest #1 (5 people, cold): validate the 30-second comprehension contract from `UX_STRESS_TEST.md`.

**Exit criteria:** a new player experiences Awakening → Rank 1 → WM_001→WM_005→ Rank 2 in order, on a physical phone, with no dead ends.

### Phase B — "Formalize the foundation" (~2–3 weeks)
1. Save schema v3 + migration: witness_archive/counters/daily state; unify observation counters.
2. Moment resume snapshots; moment analytics events; remove debug prints.
3. Director v2 minimum: next-moment selection by progress + variety with logged reasons; fail-soft fallback.
4. Archive reading room for witness entries; Your Iris v1 (rank, records, calibration hub).
5. Content validator script + moment template enforcement in CI.

### Phase C — "Retention" (~3–4 weeks)
1. DailyWitnessService (deterministic, offline) + completion/best/streaks + Iris alternation + streak visuals.
2. Training Mode frame over Engine A + skill-delta display.
3. Weekly Investigation alpha (one authored 3-moment case).
4. Notifications decision + (if yes) opt-in local reminders.
5. Playtest #2 (return-focused: 7-day protocol).

### Phase D — "Content industrialization" (parallel, ongoing)
1. Art-strategy decision (still vs motion) + art direction guide.
2. Voice strategy (VO vs curated TTS) + moment audio beds.
3. Chapter 2 (WM_006–010) through the now-enforced pipeline; difficulty tiers via Engine A sequences inside moments.
4. Engine A↔B result unification so moments feed mastery/streaks.

### Phase E — "Professional release readiness"
Monetization decision → store kit → privacy/rating/legal → crash reporting + analytics backend → closed testing track → soft launch → live-ops calendar. (Full checklist: §12.4.)

---

## 17. FINAL ASSESSMENT OF READINESS

**As a foundation:** *Ready, protected, and unusually well-governed.* The Iris experience layer, the moment runtime machine, the legacy engine, and the persistence stack are real, coherent, and documented. The creative north star is precise and consistently expressed across 100+ documents. Treat everything in the KEEP category of `CURRENT_STATE_PRODUCT_AUDIT.md` as load-bearing.

**As a game:** *A beautiful, fragile vignette.* Today a player can have one complete magical experience (WM_001), then unknowingly replay it forever while four finished episodes sit unreachable, with no daily reason to return, no training, no measurable growth, and no archive reading room. That is ~35% of the stated product.

**As a professional product:** *Not yet.* Zero device-verified hours, zero automated tests, zero store presence assets, zero monetization/analytics/crash infrastructure, and open policy questions (AI imagery, privacy, saves across devices).

**The fastest path to "professional" is not more vision documents — the vision is finished.** It is: (1) reconnect the finished content into the finished flow, (2) prove it on hardware with humans, (3) formalize the one true progression schema, (4) build the retention trio (Daily/Training/Archive), and (5) industrialize the moment factory with enforced tooling. Every one of those steps builds *on* the existing IRIS and Witness architecture, exactly as the foundation documents intended.

---

## APPENDIX A — KEY FILE REFERENCE (evidence index)

| System | Files |
|---|---|
| Project config | `the_iris/project.godot`, `the_iris/export_presets.cfg`, `the_iris/android/README.md` |
| Iris shell | `the_iris/scripts/MainController.gd`, `IrisController.gd`, `NavigationController.gd`, `InputIntent*.gd`, `BackNavigationController.gd`, `TransitionController.gd`, `TransitionOverlay.gd`, `OrientationManager.gd`, `DeviceCapabilityManager.gd`, `StateManager.gd` |
| Iris scenes | `scenes/Main.tscn`, `LivingIris.tscn`, `WitnessExperience.tscn`, `*Placeholder.tscn` (7), `TutorialAwakeningScreen.tscn`, `ProductionStartup.tscn`, `VoiceGuide.tscn`, `CaptionOverlay.tscn`, `AccessibilityPanel.tscn` |
| Shaders | `the_iris/shaders/iris.gdshader`, `memory_portal.gdshader`, `transition.gdshader`, `witness.gdshader`, `ObservationMomentShader.gdshader`, `AttunementShader.gdshader` |
| Moment runtime | `the_iris/src/iris/story/` (11 scripts + 5 JSONs), phase screens in `src/ui/screens/Witness*.gd` |
| Integration | `the_iris/src/iris/integration/Production{Bridge,WitnessHost,DestinationHost}.gd`, `src/iris/startup/ProductionStartup.gd` |
| Engine A | `the_iris/src/gameplay/**`, `the_iris/src/LegacyMechanics/**` (6 families + manifest) |
| Services | `the_iris/src/systems/**`, `src/core/**` (AppBoot, AppState, EventBus, ErrorHandler, NavigationService, AppRoutes) |
| Production UI | `the_iris/src/ui/screens/` (16 + 4 witness screens), `src/ui/shell/` (AppShell preserved), `src/ui/components/` |
| Content data | `src/iris/story/content/moment_001..005.json`, `src/LegacyMechanics/*/content/*.json`, `src/gameplay/programs/programs.json`, `src/gameplay/progression/achievements.json` |
| Audio/art | `the_iris/assets/audio/` (28), `the_iris/audio/` (7+bus), `the_iris/assets/gameplay/` (162), `assets/iris/`, `assets/brand/`, `assets/splash/` |
| Design docs (canon) | `documentation/WITNESS_MOMENT_DESIGN_BIBLE.md`, `WITNESS_EXPERIENCE_ARCHITECTURE.md`, `WITNESS_STORY_ARCHITECTURE.md`, `WITNESS_MOMENT_RUNTIME_SPECIFICATION.md`, `STORY_MODE_FOUNDATION.md`, root: `CHAPTER_1_LEARNING_TO_NOTICE_SPEC.md`, `FIRST_EXPERIENCE_DESIGN.md`, `RETURNING_PLAYER_EXPERIENCE_PLAN.md` |
| Governance | `documentation/PROJECT_FOUNDATION.md`, `TWO_SECOND_WITNESS_4_BASELINE.md`, `DEVELOPMENT_RULES.md`, `AI_DEVELOPMENT_GUIDE.md`, `CURRENT_STATE_PRODUCT_AUDIT.md`, `TECHNICAL_DEBT_AUDIT.md` |

*Report compiled from read-only inspection of the repository at branch `arena/019f6ca1-2sw-reimagined` (base `29800c0`). No implementation changes were made.*

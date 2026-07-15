# Two Second Witness 4.0 Current-State Product Audit

**Scope:** discovery/classification only
**Implementation changes:** none
**Product:** Two Second Witness 4.0 powered by the Living Iris

## Executive summary

The current workspace is a hybrid foundation with three layers already present:

1. **Iris Foundation** — Living Iris, navigation, optical transitions, guidance, input intents, device/orientation adaptation, and Mobile Simulator.
2. **Production Game Foundation** — the integrated production Two Second Witness service graph, challenge runtime, five challenge families, scoring, results, and progression.
3. **Product Shell / Presentation** — production screens and older prototype destination screens that still contain assumptions from the previous “choose a challenge, then play” product model.

The architecture is viable for Story Mode, but the player-facing hierarchy has not yet been fully migrated. The current challenge families, services, saves, content registries, and accessibility/audio systems are valuable foundations. The main work ahead is to change the doorway and narrative framing without breaking those systems.

## Classification legend

- **KEEP:** permanent foundation; authoritative and protected.
- **MODIFY:** technically useful, but presentation or assumptions must evolve.
- **REPLACE:** the current player-facing idea conflicts with Story Mode; replace the experience layer while preserving mechanics/data where possible.
- **REMOVE EVENTUALLY:** obsolete, duplicate, generated, or prototype-only material that should remain until dependency verification and migration are complete.

# KEEP — permanent foundations

## Iris Foundation

### Living Iris and optical behavior

**Keep:** `IrisController.gd`, Iris shaders, living-state behavior, breathing, gaze response, micro-saccades, blinking, invitation, recent-activity memory, and rim cues.

**Why:** This is the product’s new navigation and relationship language. It is not a challenge family and should remain independent from gameplay rules.

### Navigation and input intents

**Keep:** `NavigationController.gd`, `InputIntent.gd`, `InputIntentController.gd`, `BackNavigationController.gd`.

**Why:** These create a stable hardware-neutral intent layer. Story Mode should react to `Enter`, `Focus`, `Return`, and directional intents rather than raw touch or screen coordinates.

### Transitions and spatial adaptation

**Keep:** `TransitionController.gd`, `TransitionOverlay.gd`, `OrientationManager.gd`, `DeviceCapabilityManager.gd`, posture/parallax support.

**Why:** Story Mode depends on every moment opening and closing through the same instrument. These systems protect continuity across desktop, phone, controller, rotation, and accessibility settings.

### Guidance and accessibility

**Keep:** `VoiceGuide.gd`, `VoiceProfile.gd`, `CaptionOverlay.gd`, `AccessibilityPanel.gd`, reduced motion, high contrast, captions, explicit access, haptic behavior.

**Why:** The Iris must teach multimodally and must not depend on audio or subtle gestures alone.

### Mobile Device Simulation Mode

**Keep:** `MobileSimulator.tscn`, `MobileSimulator.gd`, `MobileFrameOverlay.gd`, `TouchIndicator.gd`.

**Why:** This is required for the 4.0 development workflow. It is development tooling, not product navigation. Its conditional mobile bypass must remain isolated.

## Production application boot and services

### Boot and global service graph

**Keep:** `src/core/app/AppBoot.gd`, `AppState.gd`, `EventBus.gd`, production autoload configuration.

**Why:** The boot graph initializes configuration, saves, settings, theme, content, audio, navigation, and runtime services in dependency order.

### Save, profile, and settings authority

**Keep:**

- `SaveService.gd`
- `ProfileService.gd`
- `PlayerProgressService.gd`
- `SettingsService.gd`
- `AccessibilityService.gd`

**Why:** These are the authoritative sources of durable player state. Story Mode must not create a parallel progress or profile system.

### Audio, theme, analytics, and content services

**Keep:**

- `AudioService.gd`
- `ThemeService.gd`
- `AnalyticsService.gd`
- `ContentService.gd`
- `ExperienceRegistry.gd`

**Why:** They provide the common runtime foundation for future chapters, assets, sound profiles, accessibility, and instrumentation.

## Production challenge framework

**Keep:**

- `ChallengeFamilyRegistry.gd`
- `ChallengeSessionService.gd`
- challenge contracts;
- generators;
- validators;
- difficulty/exposure policies;
- interaction adapters;
- family-owned scoring policies;
- `ResultService.gd`;
- `RecommendationService.gd`;
- `ProgramService.gd`;
- `AchievementService.gd`.

**Why:** This is the scalable game engine. Story Mode should choose and frame these mechanics, not rewrite them.

## Production content and assets

**Keep:**

- `src/LegacyMechanics/` and manifests;
- `src/gameplay/*/content/` data;
- `src/experiences/` metadata;
- `assets/gameplay/`;
- `assets/audio/`;
- `assets/brand/`;
- `assets/splash/`;
- `android/` and production export presets.

**Why:** Existing content and future update capacity depend on them. Apparent visual placeholders must not be deleted until content references and roadmap dependencies are verified.

## Production identity

**Keep unchanged:**

- Two Second Witness;
- ITTYBITTYBITES;
- `com.ittybittybites.the2secondwitness`;
- version continuity;
- release signing path;
- Android export configuration.

# MODIFY — useful systems with old experience assumptions

## `MainController.gd`

**Current assumption:** named screens are the primary navigation model.

**Future role:** Iris shell and Story Mode coordinator. It should eventually delegate selection to a Witness Experience Director rather than hardcoding family/destination decisions.

## `ProductionWitnessHost.gd`

**Current role:** mounts production Tutorial/Observation/Recall/Result screens inside Witness Mode.

**Modify toward:** a Story Mode host that understands beats, chapters, scene framing, evidence, reward, and return-to-Iris memory while still delegating challenge mechanics to `ChallengeSessionService`.

## `ProductionDestinationHost.gd`

**Current role:** mounts production Library, Profile, Settings, Achievements, Programs, and About rooms.

**Modify toward:** secondary rooms accessed from Archive/Discover/Profile/Settings Iris destinations. The host should remain a doorway adapter, not become a second navigation service.

## `NavigationService.gd`

**Current assumption:** production route history represents the visible product shell.

**Future role:** internal room/gameplay routing beneath the Iris layer. Story Mode should add a story/beat context without replacing stable gameplay routes.

## Production `AppShell.gd`

**Current assumption:** AppShell is the visible root and its top/tab bars are always the primary hierarchy.

**Future role:** preserve as a production room/screen infrastructure reference and compatibility surface, but do not mount it as a second root shell in Story Mode.

## `AppRoutes.gd`

**Current assumption:** `home`, `experiences`, `profile`, `settings`, and gameplay routes are directly player-facing.

**Future role:** keep route names stable for compatibility, while Iris destinations and Story Mode become the default doorway. Add story context as params or an additive director state rather than renaming working gameplay routes.

## `ProfileScreen.gd`

**Current assumption:** profile is a conventional record screen.

**Future role:** Witness Record, Witness Rank, mastery, chapters, archive, and discoveries. Preserve all underlying production data.

## `SettingsScreen.gd`

**Current assumption:** settings are a conventional settings room.

**Future role:** Calibration/Instrument settings with the existing production settings schema, expanded only through a presentation layer.

## `ResultScreen.gd`

**Current assumption:** the result is the end of a challenge route.

**Future role:** Evidence and Reward beat inside a Witness Moment, followed by return-to-Iris memory. Preserve `ChallengeResult`, scoring, history, and replay/continue actions.

## Tutorials

**Current assumption:** each family has a standalone tutorial screen that teaches a mode before the challenge.

**Future role:** first introduction is a Story Mode beat. Tutorials remain replayable in the secondary Library/Training room and accessible explicit path.

## Progression and recommendation systems

**Modify:** XP, levels, achievements, programs, and recommendations should be framed as Witness Rank, Story Chapters, Discoveries, Archive entries, and Mastery. Do not remove their persistence or contracts.

## Challenge presentation screens

**Modify:** Observation, Memory Question, and Result screens need to become story-aware and Iris-framed. The shared routes and adapters remain useful; their default copy, transition framing, and evidence pacing should evolve.

# REPLACE — old player-facing assumptions

These are experience ideas to replace, not necessarily files to delete immediately.

## Challenge-type-first navigation

**Old:** player chooses Scene Investigation, Flash Words, Object Recall, Pattern Recall, or Spot the Difference as the first major decision.

**New:** player enters a Witness Moment. The Experience Director selects the internal family and explains only what the moment requires.

## Conventional Home product hub as the first destination

**Old:** Play Now, Continue, Daily, Library, Programs, Profile, and Settings are presented as a dashboard hierarchy.

**New:** the Iris is the first meaningful product state. Home data becomes inputs to Iris curiosity and Story Mode selection.

## Bottom/tab navigation as the primary mental model

**Old:** production top bar/tab bar navigation is always visible.

**New:** Iris center/left/right/up/down are the primary doorway meanings. Explicit controls remain available through accessibility and secondary rooms.

## Family names as primary product language

**Old:** family names appear before the player understands the perception goal.

**New:** perception abilities are introduced first: “Notice what changes,” “Remember what was present,” “Recognize what connects.” Family names remain available in Archive/Library.

## Result as a terminal screen

**Old:** result leads to Home, replay, continue, or Library as conventional buttons.

**New:** result is the Evidence and Reward beat inside a Witness Moment, then closes through the Iris.

## Tutorial as a prerequisite page flow

**Old:** tutorial is a route the player may experience as a mode explanation.

**New:** first family introduction is integrated into a guided Witness Moment. Replayable tutorials remain in the secondary Library.

# REMOVE EVENTUALLY — do not delete yet

## Regression fixture family from player-facing registries

`scene_investigation_fixtures` is useful for automated compatibility tests but should remain clearly excluded from player-facing Story Mode selection and recommendation.

## Legacy Iris sample Witness fallback

The old procedural Witness timer/reveal presentation is useful as a fallback while production hosts are being hardened. Once production Witness failure states are complete, remove it from normal player flow but retain any focused regression coverage required.

## Duplicate prototype destination presentation

The current Iris Archive/Profile/Settings fallback drawing remains useful during migration, but production destination hosts should eventually be the sole room presentations. Remove fallback presentation only after production host error handling and accessibility parity are proven.

## Unmounted production AppShell root flow

`AppShell.tscn` and production screen infrastructure remain valuable compatibility rooms. If Story Mode becomes the only supported root flow, review which AppShell-only root behaviors are still needed before removal.

## Historical migration documents

Keep audit/history records for traceability, but mark the baseline/foundation documents as the current source of truth. Do not let old Phase 1–7 prototype descriptions override current governance.

## Generated artifacts

Never retain `.godot`, `.import`, build, APK, AAB, or temporary test artifacts in the source baseline.

# Content and asset notes

- Production assets are not “unused” merely because Story Mode has not mounted every room yet.
- The five families and roadmap require the current content tree.
- Asset replacement belongs to the Asset Pipeline Plan, not this classification phase.

# Final classification summary

| Category | Direction |
|---|---|
| KEEP | Iris foundation, production services, challenge runtime, content, saves, Android identity, simulator, accessibility/audio/analytics |
| MODIFY | MainController, route mapping, production hosts, profile/settings/results, tutorials, progression framing, challenge presentation |
| REPLACE | challenge-first home hierarchy, conventional default menu/tab assumptions, terminal result flow, family-first onboarding |
| REMOVE EVENTUALLY | fixture exposure, legacy fallback presentation, duplicate prototype rooms, obsolete migration scaffolding, generated artifacts |

No files were deleted or gameplay behavior modified during this audit.

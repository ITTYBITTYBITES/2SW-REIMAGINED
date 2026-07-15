# Two Second Witness Production Application Audit

**Source:** `https://github.com/ITTYBITTYBITES/2-second-witness-mobile`
**Audited commit:** `1d666fed75fc07b38a73aa90f732025499a3d1ea`
**Source engine:** Godot 4.6.3
**Audit date:** 2026-07-15
**Destination:** local Iris workspace only; the GitHub repository was cloned read-only into a temporary directory and was not modified.

## Executive summary

The production repository is a real, data-driven Godot application rather than a visual mockup. Its strongest reusable asset is the generic Challenge Runtime: family modules generate, validate, score, persist, and recommend challenges through contracts and services. Its second major asset is the production shell and boot/service graph, which supplies save migration, profile/progress, settings, accessibility, audio, analytics, content discovery, programs, achievements, and Android export configuration.

The current Iris workspace already contains a separate navigation/interaction foundation: Living Iris, optical transitions, Back behavior, input intents, orientation, device simulation, voice, captions, and accessibility paths. The safe integration strategy is therefore an **adapter boundary**, not a wholesale replacement of either project:

- Production services and gameplay remain under a clearly named `src/` / `assets/` boundary.
- The Iris remains the visual/application doorway.
- The production ChallengeSessionService remains the authority for challenge creation, observation, recall, result, progress, and replay.
- The production AppShell is not mounted as a second root shell; its services and screen scenes are reused where useful.
- Iris Back always returns through the Iris, while production session state is closed through `ChallengeSessionService.return_home()`.

## Product identity and Android continuity

The production configuration identifies:

- Application: **Two Second Witness**
- Publisher: **ITTYBITTYBITES**
- Android package: `com.ittybittybites.the2secondwitness`
- Production version: `4.0.0`
- Production version code: `40000`
- Android architecture: ARM64
- Android export: custom Gradle build under `app/android`
- Store identity/signing: release keystore paths are intentionally empty in the public repository and must not be replaced by a new package or new signing identity.

The local Iris project previously used a prototype package and name. The integration must update the local project identity and export presets to the production values while preserving the production version code baseline. A real Play Store update still requires the private release keystore outside this repository.

## Boot and application shell

### Entry

- `src/ui/shell/AppShell.tscn` is the production main scene.
- `AppShell.gd` owns content mounting, screen caching, route changes, safe-area layout, loading overlay, error banner, chrome visibility, and screen transition fades.
- `AppBoot.gd` runs the explicit initialization order:
  1. Config
  2. Save/Profile/Achievement
  3. Settings/Analytics/Accessibility
  4. Theme
  5. Content/Challenge registries and runtime services
  6. Audio
  7. Navigation
  8. Finalization
- Production uses a publisher splash followed by a title/loading route and then a Home route.

### Iris integration point

The existing Iris `Main.tscn` remains the application-facing root for the hybrid prototype. A small `ProductionBridge` can instantiate the production `AppBoot` sequence behind the Iris startup overlay. The production AppShell should not be nested inside the Iris because that would create two competing navigation shells.

## Navigation architecture

### Production

- `AppRoutes.gd` defines stable route names for splash, tutorial, observation, memory question, result, home, experiences/library, profile, settings, achievements, programs, and about.
- `NavigationService.gd` owns route history, back behavior, route validation, screen-view analytics, and route-to-AppState phase mapping.
- AppShell listens to `NavigationService.route_changed` and mounts/caches the corresponding screen.
- Back never returns into splash history and returns to Home when history is exhausted.

### Iris destination mapping

| Production route/system | Iris doorway | Integration behavior |
|---|---|---|
| `observation` → `memory_question` → `result` | Iris center / Witness | Start through `ChallengeSessionService`; mount production gameplay screens inside an Iris Witness host. |
| `experiences` / Challenge Library | Iris left / Archive | Preserve production challenge catalog, favorites, programs, and history; expose as an Archive/Library view. |
| Production `home` snapshot / recommendations | Iris center state | Use recommendation data to modulate Iris curiosity and Witness-entry emphasis; do not show a second Home screen first. |
| `profile`, achievements, mastery | Iris down / Profile | Reuse `ProfileService`, `PlayerProgressService`, and achievement data. |
| `settings`, calibration, accessibility | Iris up / Settings | Reuse `SettingsService`, `AccessibilityService`, audio, theme, and reduced-motion preferences. |
| future content / programs / collections | Iris right / Discover | Preserve `ContentService`, `ExperienceRegistry`, `ProgramService`, and recommendation data for future routes. |
| production Back | Iris return transition | Close production session through `ChallengeSessionService.return_home()` then allow the Iris reverse transition to complete. |

## Gameplay and challenge systems

The production runtime is the primary system to preserve.

### Shared contracts

- `ChallengeFamily`
- `ChallengeTemplate`
- `ChallengeInstance`
- `ChallengeValidationResult`
- `ChallengeResult`
- `InteractionProfile`
- `PresentationProfile`
- `TutorialProfile`

### Runtime services

- `ChallengeFamilyRegistry` loads family modules from `src/LegacyMechanics/manifest.json`.
- `ChallengeSessionService` resolves family/template, difficulty, exposure, generator, validator, presentation profile, response, result, progress, recommendation, replay, and return-home behavior.
- `ChallengeGenerator` creates seeded instances.
- `ChallengeValidator` rejects unfair candidates and supplies fallback instances.
- `ResultService` maps family-owned scoring into the canonical result contract.
- `PlayerProgressService` adapts results into profile/progress data.
- `RecommendationService` supplies Play Now, Continue, Featured, Next, unlock, and Home snapshot data.
- `ProgramService` manages curated runs and program progress.
- `AchievementService` evaluates persisted achievements.

### Current families

The source README documents five production challenge families:

1. Scene Investigation
2. Flash Words
3. Spot the Difference
4. Object Recall
5. Pattern Recall

Each family is modular and owns its generator, validator, difficulty, exposure, scoring, tutorial, presentation, and interaction profiles. This is an excellent fit for an Iris Witness host because the Iris does not need to know the family rules.

## Content registry and assets

- `src/gameplay/challenges.json` contains legacy/minimal challenge registry data used by the foundation path.
- `src/LegacyMechanics/manifest.json` and family `content/*.json` are the production runtime content source.
- `src/experiences/manifest.json` and `ExperienceRegistry.gd` support experience-level catalog metadata.
- `src/gameplay/programs/programs.json` defines curated programs.
- `src/gameplay/progression/achievements.json` defines achievements.
- `assets/gameplay/` contains observation scenes, family previews, recall backgrounds, icons, and a large scene-investigation sprite library.
- `assets/audio/` contains BGM and UI/gameplay SFX.
- `assets/brand/` and `assets/splash/` contain the ITTYBITTYBITES and Two Second Witness identity assets.

Migration should copy/adapt the production `src/` and `assets/` trees into the local workspace, while retaining Iris-specific assets and not mounting the production home shell as the root.

## Save, profile, progression, settings

### Save

`SaveService.gd` provides:

- versioned JSON wrappers
- atomic temporary-file replacement
- `.bak` recovery copies
- stale temp cleanup
- migration from older profile versions
- separate profile/settings files

### Profile

`ProfileService.gd` owns:

- display name and profile ID
- level, XP, Witness progress
- session count and play time
- unlocked experiences
- per-family progress
- achievements and achievement progress
- favorites
- program progress
- preference storage

### Settings and accessibility

- `SettingsService.gd` stores application settings.
- `AccessibilityService.gd` stores text size, high contrast, color assistance, reduced motion, and animation duration behavior.
- `ThemeService.gd` owns tokens, styles, fonts, and theme application.
- `AudioService.gd` owns SFX/BGM, mute/volume, route music, and ducking.

The Iris must not introduce a second persistent progress model for production challenges. Its existing prototype state can remain for Iris-specific awakening/voice state, but production challenge progress must be read/written through the production services.

## Audio

Production audio is service-based and includes:

- home/gameplay/results/tutorial BGM tracks
- observation/reveal/result SFX
- UI navigation and feedback SFX
- mastery and achievement sounds
- settings-aware mute/volume behavior

The existing Iris VoiceGuide is additive. It should respect `SettingsService`/`AudioService` mute and remain a guidance layer, not replace gameplay audio.

## Analytics

`AnalyticsService.gd` is an offline/local analytics hook with screen views, gameplay events, performance/startup instrumentation, and sanitization in navigation. The public repository does not expose an external monetization SDK or live commerce implementation.

Iris-specific events should be additive and namespaced, for example:

- `iris_awakened`
- `iris_destination_opened`
- `iris_witness_entry`
- `iris_return_to_anchor`

They should not replace production challenge/result events.

## Monetization hooks

A source scan found no active AdMob, billing, purchase, subscription, or leaderboard SDK implementation in `app/src` or the project configuration. The repository contains release/store documentation and future product placeholders, but there is no runtime monetization service to migrate. No monetization behavior should be invented during this integration.

## Android/export configuration

- `app/export_presets.cfg` contains Android development and Play Store presets.
- Both presets use package `com.ittybittybites.the2secondwitness` and version `4.0.0` / code `40000`.
- ARM64 is enabled; custom Gradle build is enabled under `app/android`.
- Vibration permission is enabled.
- Release keystore values are intentionally absent from the public repository.
- Production project is portrait-only (`screen/orientation=1`), while the Iris project has orientation simulation/sensor support. The hybrid should preserve the production package/version/signing continuity but keep orientation behavior behind a controlled Iris/device layer until physical Android validation.

## Dependencies

- Godot 4.6.3
- No external paid runtime assets or network services are required by the source runtime.
- Local Godot Android export templates, Android SDK/JDK, and private signing key are required to export.
- Production services depend on autoload singletons and must be registered in dependency order.
- Family modules depend on interaction adapters and shared contracts.

## Migration risks

1. **Duplicate roots:** Mounting production AppShell inside Iris would create competing route and Back systems. Use production services/screens inside Iris hosts instead.
2. **Autoload order:** Production boot expects Config, Save/Profile, Settings, Theme, Content, Audio, and Navigation services in a known dependency order.
3. **Path conflicts:** Production scripts assume `res://src/...` and `res://assets/...`; copy them to those root paths or rewrite every resource reference consistently.
4. **Class-name collisions:** Audit global class names after copying production `src/` into the Iris project.
5. **Save continuity:** Do not replace production `profile_v2.json` / `settings_v2.json` with Iris prototype ConfigFile state.
6. **Route duality:** Production `NavigationService` and Iris `MainController` must have a one-way adapter boundary. The Iris owns the visible doorway; production NavigationService owns gameplay route state inside the Witness host.
7. **Tutorial behavior:** First family use may route to production TutorialScreen before observation. The host must support tutorial → observation → recall → result without resetting Iris state.
8. **Android identity:** The local prototype's prior package identity must be replaced by the production package only with explicit awareness that signing compatibility depends on the private release keystore.
9. **Asset size:** Production assets are approximately 36 MB before import artifacts. Copy only needed assets for the first integration, or maintain a clearly isolated production asset tree.
10. **Settings duplication:** Iris settings and production settings can drift. Production SettingsService remains the authority; Iris calibration should write through it.
11. **Analytics duplication:** Existing Iris and production screen-view logging can double-count events unless routed through an adapter.
12. **Orientation divergence:** Production is portrait-oriented while Iris supports sensor/orientation simulation. Keep the production gameplay view responsive but validate Android orientation policy before release.

## Migration decision

The production repository passed a read-only Godot 4.6.3 editor scan and headless startup audit. This migration decision has now been executed in the local workspace. The resulting hardening boundary is documented in `documentation/PROJECT_FOUNDATION.md` and `documentation/PRODUCTION_HARDENING_REPORT.md`. The original slice was:

1. copy production `src/` and required `assets/` into the local workspace;
2. register production autoloads and identity/export values;
3. add a `ProductionBridge` that runs `AppBoot`;
4. add an Iris `ProductionWitnessHost` that mounts production Tutorial/Observation/Recall/Result scenes;
5. route Iris Profile and Settings into production services/screens;
6. leave production source contracts and family modules unmodified wherever possible;
7. run both local Godot validation and production runtime regression checks.

This keeps **Two Second Witness** as the product and **The Iris** as its living navigation foundation.

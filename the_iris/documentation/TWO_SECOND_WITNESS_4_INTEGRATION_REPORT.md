# Two Second Witness 4.0 Iris Integration Report

**Status:** Local hybrid integration complete
**Engine:** Godot 4.6.3
**Product:** Two Second Witness
**Publisher:** ITTYBITTYBITES
**Android package:** `com.ittybittybites.the2secondwitness`
**Version:** `4.0.0`
**Version code baseline:** `40000`

## Result

The local workspace now contains a hybrid architecture:

```text
Two Second Witness 4.0
│
├── Production service and gameplay layer
│   ├── AppBoot / AppState / NavigationService
│   ├── SaveService / ProfileService / SettingsService
│   ├── Accessibility / Theme / Audio / Analytics services
│   ├── Content and Experience registries
│   ├── Challenge Family Registry
│   ├── Challenge Session Runtime
│   ├── generators / validators / scoring / results
│   ├── programs / recommendations / achievements
│   └── production Tutorial / Observation / Recall / Result screens
│
└── Living Iris foundation
    ├── Mobile Simulator development shell
    ├── startup / publisher activation
    ├── Living Iris navigation anchor
    ├── optical transitions and Back behavior
    ├── input intents / device capabilities
    ├── orientation / posture awareness
    ├── VoiceGuide / captions / accessibility doorway
    └── Iris destination hosts
```

The Iris is now the doorway to the production application. It is not the product name and it does not replace the game.

## Migrated systems

The production `app/src` tree was copied into the local workspace under `src/`, and production assets were merged into `assets/`. The source repository was used as a read-only reference and was not modified.

Migrated production systems include:

- `AppBoot.gd` dependency-ordered startup
- `AppState.gd`
- `EventBus.gd`
- `NavigationService.gd` and stable route definitions
- `ConfigService.gd`
- `SaveService.gd` with versioned atomic JSON persistence and recovery copies
- `ProfileService.gd`
- `SettingsService.gd`
- `AccessibilityService.gd`
- `ThemeService.gd`
- `AudioService.gd`
- `AnalyticsService.gd`
- `ContentService.gd`
- `ExperienceRegistry.gd`
- `ChallengeRegistry.gd`
- `ChallengeFamilyRegistry.gd`
- `InteractionAdapterRegistry.gd`
- `ChallengeSessionService.gd`
- `ChallengeGenerator`, `ChallengeValidator`, `DifficultyPolicy`, `ExposurePolicy`, `ScoringPolicy`, and `ResultService`
- `PlayerProgressService.gd`
- `RecommendationService.gd`
- `ProgramService.gd`
- `AchievementService.gd`
- production Challenge Family modules and content
- production UI screens and gameplay scenes
- production assets, challenge scenes, sprites, BGM, SFX, brand, and splash resources
- Android custom-build support files and export configuration

## Preserved Iris systems

The following Iris systems remain active and are not replaced by the production AppShell:

- `LivingIris` / procedural iris shader
- `NavigationController.gd`
- `InputIntent.gd` / `InputIntentController.gd`
- `TransitionController.gd`
- `BackNavigationController.gd`
- `OrientationManager.gd`
- `DeviceCapabilityManager.gd`
- `VoiceGuide.gd`
- caption and explicit-accessibility layers
- `MobileSimulator.tscn`
- simulator profiles, shortcuts, safe areas, frame, and touch indicator

## New integration files

- `documentation/PRODUCTION_APP_AUDIT.md` — read-only production repository audit
- `src/iris/integration/ProductionBridge.gd` — starts the production AppBoot/service graph behind the Iris
- `src/iris/integration/ProductionWitnessHost.gd` — mounts production Tutorial/Observation/Recall/Result scenes inside Witness Mode
- `src/iris/integration/ProductionDestinationHost.gd` — mounts production Library, Profile, Settings, Achievements, Programs, and About screens through Iris destinations
- `src/iris/startup/ProductionStartup.gd` — ITTYBITTYBITES / Two Second Witness activation overlay
- `scenes/ProductionStartup.tscn`
- production source under `src/`
- production content and assets under `assets/`
- production Android custom-build files under `android/`

## Changed navigation

### Before

```text
Publisher splash
→ production AppShell
→ Home product hub
→ Challenge Library / Profile / Settings
→ Observation / Recall / Result
```

### Now

```text
ITTYBITTYBITES activation
→ Living Iris
   ├── Tap center → production Witness Session
   │   ├── production Tutorial when required
   │   ├── production Observation
   │   ├── production Recall
   │   └── production Result
   ├── Left → production Challenge Library / Archive doorway
   ├── Right → Iris Discover space / future content doorway
   ├── Down → production Profile / Witness Record
   └── Up → production Settings / Accessibility
```

The production `NavigationService` remains authoritative inside production screens. `MainController` remains authoritative for the Iris doorway and its optical return transition. Production Back/session cleanup is invoked through `ProductionBridge.return_to_iris()` before the Iris reverse transition completes.

## Save and profile continuity

- Production profile and settings files remain owned by `SaveService`.
- No production save file is reset or replaced by Iris state.
- Profile presentation now reads production `PlayerProgressService.get_observation_record()` when available.
- Archive reads production recent witness history for its memory labels.
- Discover reads production visible Challenge Family IDs.
- Settings writes sound and accessibility changes through `SettingsService` where production settings exist, while Iris-only preferences remain in the Iris state layer.
- The current Iris `user://the_iris_state.cfg` and `user://the_iris_voice.cfg` remain limited to Iris awakening/interface state.

## Android continuity

The local project identity and export presets now use:

- `config/name="Two Second Witness"`
- `config/version="4.0.0"`
- `com.ittybittybites.the2secondwitness`
- version code `40000`
- ARM64 Android export
- production launcher icon paths
- production Android custom build directory
- production Play Store preset names

The public repository does not contain the private release keystore. Play Store update compatibility still depends on using the original signing key when exporting a release artifact.

## Development behavior

Desktop `Play Project` still launches `MobileSimulator.tscn`, which embeds the Iris application in a phone shell. The simulator supports:

- phone profiles
- portrait / landscape left / landscape right
- safe areas and notch simulation
- mouse-as-touch input
- F1–F10 development shortcuts
- developer overlay

On Android/mobile runtime, the simulator shell is bypassed and `Main.tscn` is instantiated directly.

## Validation completed

- Production repository was cloned read-only at commit `1d666fed75fc07b38a73aa90f732025499a3d1ea`.
- Production repository passed an independent Godot 4.6.3 editor scan and headless startup audit before migration.
- Local hybrid project passed a Godot 4.6.3 editor scan after source/assets/autoload integration.
- Local hybrid project passed a headless startup run with the production AppBoot bridge active.
- Scene/resource/preload references were checked after migration.
- Android identity/version/export values were checked against the production export preset.

The local integration runtime smoke test confirmed production boot readiness before the temporary test scene was removed. The remaining physical-device validation is still required for actual Android orientation, signing, audio, haptics, safe areas, and Play Store update behavior.

## Known limitations and risks

1. The production AppShell is intentionally not mounted; the Iris is the visible shell. Production screens are reused inside Iris hosts.
2. The right-side Discover space remains an Iris future-content surface; production Library and Programs are exposed through the left/archive destination and production service layer.
3. Production profile/settings screens are mounted through the Iris destination host, but their native AppShell top bar is not used; Android Back and Iris return remain the exit language.
4. The production repository's portrait Android export preset is preserved. The Iris orientation simulation remains available in development; physical sensor-orientation policy should be decided before a release export.
5. The private signing key is not available in the public source and was not copied or generated.
6. Monetization hooks were not found as active runtime systems in the source repository; no monetization behavior was invented.
7. The full production asset tree adds approximately 36–37 MB before Godot import artifacts.
8. Production AppBoot and Iris startup are now both present. The Iris startup overlay is the visible activation layer; production service initialization runs underneath it.

## Future update compatibility

The integration keeps the production extension boundaries intact:

- New challenge families register through `ChallengeFamilyRegistry` and manifests.
- New interactions register through `InteractionAdapterRegistry`.
- New content remains data-driven under family/content manifests.
- Programs and recommendations remain service-owned.
- Profile/progress/result persistence remains production-owned.
- New Iris destinations can be added without changing challenge mechanics.
- New gameplay experiences can be mounted by extending `ProductionWitnessHost` route mappings.
- Analytics remains service-owned, with Iris events additive rather than replacing production events.
- Accessibility and settings remain service-owned wherever a production equivalent exists.

## Final product statement

This workspace is now a local **Two Second Witness 4.0** foundation: the existing production game systems remain intact, while the Living Iris becomes the way users enter, leave, and emotionally understand those systems.

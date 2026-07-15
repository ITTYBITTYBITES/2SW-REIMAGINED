# Two Second Witness 4.0 — Production Hardening Report

**Date:** 2026-07-15
**Engine:** Godot 4.6.3
**Product:** Two Second Witness 4.0
**Publisher:** ITTYBITTYBITES
**Package:** `com.ittybittybites.the2secondwitness`

## Summary

The integrated workspace was audited and hardened without removing the production challenge platform or the Living Iris foundation. The production source tree remains authoritative for gameplay, profile, settings, saves, progression, content, accessibility, audio, and analytics. The Iris remains the visible navigation foundation.

## Files and generated artifacts removed

- Removed copied/generated `.import` metadata from the production asset tree; Godot regenerates these files on import.
- Removed generated `.godot/` editor/import cache before packaging.
- Removed temporary integration smoke scripts and test scenes after validation.
- Did not remove production gameplay assets, challenge family assets, production audio, brand assets, or Android build support.
- Preserved rollback backup outside the project at `/home/user/the_iris_phase7_backup`.

## Systems merged or hardened

- Moved permanent Iris/production boundary scripts from the loose root `scripts/` folder into `src/iris/`:
  - `src/iris/integration/ProductionBridge.gd`
  - `src/iris/integration/ProductionWitnessHost.gd`
  - `src/iris/integration/ProductionDestinationHost.gd`
  - `src/iris/startup/ProductionStartup.gd`
- Kept `MainController` as the Iris application orchestrator and `ProductionBridge` as the one production boot boundary.
- Kept `ChallengeSessionService` authoritative for challenge lifecycle and results.
- Kept `SaveService` / `ProfileService` / `SettingsService` authoritative for production persistence.
- Connected Iris Profile, Archive, Discover, and Settings surfaces to production data/services where applicable.
- Preserved the production AppShell and production screens as reusable rooms without mounting a competing root shell.
- Preserved the Mobile Simulator as a desktop-only development behavior with an Android runtime bypass.
- Added `.gitignore` rules for generated Godot/import/build artifacts.

## Architecture improvements

- Established explicit Iris / Game / Player / Content ownership in `documentation/PROJECT_FOUNDATION.md`.
- Added `documentation/AI_DEVELOPMENT_GUIDE.md` with safe modification areas, protected systems, testing, and release rules.
- Added `documentation/TECHNICAL_DEBT_AUDIT.md` with KEEP/REFACTOR/REMOVE decisions.
- Consolidated product identity and integration guidance in `README.md`.
- Updated production integration paths after moving bridge files.
- Preserved package and version identity:
  - `Two Second Witness`
  - `ITTYBITTYBITES`
  - `com.ittybittybites.the2secondwitness`
  - `4.0.0`
  - version code `40000`
- Added explicit documentation that Iris state is for Iris relationship/awakening behavior only and must not replace production progress/save state.

## Performance and startup improvements

- Production services initialize through the existing ordered `AppBoot` graph rather than through a second shell.
- Startup now presents the ITTYBITTYBITES / Two Second Witness activation layer while service initialization runs underneath.
- Production BGM/SFX and Iris voice/procedural audio remain separate responsibilities.
- Headless audio startup avoids creating the procedural generator on the headless test driver, preventing false audio resource leaks.
- Generated editor/import artifacts are excluded from the source package.
- Iris idle animation remains low-count/procedural; production challenge screens use their existing optimized runtime/content paths.

## Validation performed

- Read-only production repository audit completed at commit `1d666fed75fc07b38a73aa90f732025499a3d1ea`.
- Production repository independently passed Godot 4.6.3 editor scan and headless startup before migration.
- Local integrated workspace passed Godot 4.6.3 editor scan after cleanup and file moves.
- Local integrated workspace passed a headless startup run with Dummy audio.
- No final editor/runtime output contained:
  - `ERROR`
  - `SCRIPT ERROR`
  - `Parse Error`
  - `WARNING`
  - missing-resource failures
  - invalid-call failures
  - object/resource leak messages
- Resource/preload reference audit returned zero missing references.
- Production package/version/export values were checked against the audited production preset.

## Remaining risks

1. Physical Android validation remains required for sensor orientation, safe areas, haptics, audio, custom Gradle build, and real Back behavior.
2. Play Store update continuity requires the private existing signing key; it is not present in the public source.
3. The production repository's Play Store preset is portrait-oriented while the Iris development foundation supports simulated sensor orientation. Final release orientation policy must be confirmed on device.
4. The full production asset tree is intentionally retained for the existing five families and future roadmap; unused-looking content must not be deleted without content ownership review.
5. The production AppShell is not mounted as the root UI. Its screens are reused through Iris hosts, so any future production screen that assumes AppShell-specific parent nodes must be adapted at the host boundary.
6. Full human playtesting of every challenge family after the Iris entry path remains a release-gate activity.
7. Monetization runtime hooks were not present in the audited public source; no monetization behavior was invented.

## Foundation lock decision

The workspace is suitable as the foundation repository for future Two Second Witness updates, provided future work follows `documentation/PROJECT_FOUNDATION.md` and `documentation/AI_DEVELOPMENT_GUIDE.md`. New updates should add production content/contracts first, then expose them through an Iris destination without creating a second navigation hierarchy or persistence system.

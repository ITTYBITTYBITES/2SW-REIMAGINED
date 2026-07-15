# AI Development Guide — Two Second Witness 4.0

## Repository purpose

This repository is the local Two Second Witness 4.0 foundation. It combines the production observation-game runtime with the Living Iris as its navigation and experience doorway.

Use the Iris to help users enter and understand the game. Use the production systems to define what the game does.

## Important folders

```text
project.godot / export_presets.cfg  product identity and Android continuity
scenes/                         Iris root, destinations, simulator, transitions
scripts/                        Iris controllers, input, guidance, and compatibility entry points
src/iris/                       permanent Iris-to-production integration boundaries
src/core/                       production app state, boot, events, navigation
src/systems/                    production save, profile, settings, audio, accessibility, content
src/gameplay/contracts/         stable challenge contracts
src/gameplay/runtime/           generic challenge session runtime
src/LegacyMechanics/          production challenge family modules and content
src/gameplay/interactions/      reusable interaction adapters
src/gameplay/progression/       achievements
src/gameplay/programs/          curated programs
src/ui/screens/                 production rooms mounted through Iris destinations
assets/                         production and Iris assets
android/                        production custom Android build support
```

## Important systems

### Iris

- `MainController.gd` owns visible Iris routing and optical return flow.
- `IrisController.gd` owns living-eye behavior.
- `InputIntentController.gd` translates hardware into Focus/Enter/Return/Explore intents.
- `TransitionController.gd` owns Iris entry/return choreography.
- `OrientationManager.gd` owns stable orientation adaptation.
- `DeviceCapabilityManager.gd` owns device capability detection.
- `VoiceGuide.gd` owns milestone voice/caption guidance.
- `MobileSimulator.gd` is desktop development tooling.

### Production

- `ProductionBridge.gd` starts `AppBoot.gd`.
- `ChallengeSessionService.gd` owns the challenge lifecycle.
- `ChallengeFamilyRegistry.gd` loads registered families.
- `PlayerProgressService.gd` adapts results into saved progress.
- `SaveService.gd` owns versioned atomic persistence.
- `ProfileService.gd` owns the production profile.
- `SettingsService.gd` owns production settings.
- `AccessibilityService.gd` owns reduced motion, text scale, contrast, and haptics.
- `AudioService.gd` owns production audio buses and BGM/SFX.

## Safe modification areas

- New challenge content: `src/LegacyMechanics/**/content/` and manifests.
- New challenge family: add a module, contracts, policies, interaction profile, tutorial, presentation profile, and manifest entry.
- New Iris visual behavior: `scripts/IrisController.gd` and Iris shaders, without changing production data.
- New destination presentation: extend `ProductionDestinationHost.gd` route mapping or add a room scene; keep Back-to-Iris behavior.
- New guidance: add milestone events to `VoiceGuide`/Iris visual behavior, never a chatbot or permanent tutorial UI.
- New device support: `DeviceCapabilityManager`, `InputIntentController`, and `OrientationManager`.
- Documentation: update `documentation/PROJECT_FOUNDATION.md`, the relevant product doc, and the integration/hardening reports.

## Protected systems

Do not casually modify:

- Android package `com.ittybittybites.the2secondwitness`.
- application name `Two Second Witness` and publisher identity ITTYBITTYBITES.
- version code continuity or release export presets.
- `SaveService`, profile schema, settings schema, and migration logic.
- challenge contracts and generic runtime ownership boundaries.
- production family scoring/validation/generation behavior.
- InteractionAdapterRegistry contracts.
- production accessibility/audio initialization order.
- Iris Back semantics: every production room returns through the Iris.

## Testing requirements

After any change:

1. Delete generated `.godot/` only when a clean class/import scan is needed.
2. Run Godot 4.6.3 editor scan with the project path and `--editor --quit`.
3. Run a headless project startup with Dummy audio and a finite frame budget.
4. Search logs for `ERROR`, `SCRIPT ERROR`, `Parse Error`, `WARNING`, missing resources, and leaks.
5. Run the production runtime regression tests when gameplay/content changes.
6. Run the Mobile Simulator for phone profiles, orientation, Back, and touch/mouse input.
7. Verify production profile/settings files are not reset.

For challenge changes, validate:

- generation determinism
- fairness validation
- fallback generation
- interaction submission
- scoring/result
- progress persistence
- recommendation/continue behavior
- tutorial behavior
- accessibility/reduced motion

## Release requirements

- Godot 4.6.3.
- Use the production Android export preset.
- Keep package `com.ittybittybites.the2secondwitness`.
- Keep `Two Second Witness` / ITTYBITTYBITES identity.
- Increment version code from the established baseline; do not reset it.
- Use the private existing signing key; never add it to the repository.
- Validate a signed artifact on a physical Android device.
- Test Back, safe areas, audio mute, haptics, orientation policy, saves, and upgrade from the existing Play Store build.
- Review analytics/privacy/store behavior before release.

## What not to do

- Do not copy a second repository root into this project.
- Do not mount the production AppShell as a second root shell.
- Do not make Iris aware of concrete family rules.
- Do not replace real production systems with prototype dictionaries.
- Do not remove assets because they are not currently visible in the Iris; future roadmap content depends on the production asset tree.
- Do not package generated `.godot` caches or `.import` metadata.

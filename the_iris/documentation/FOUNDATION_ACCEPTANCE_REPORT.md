# Two Second Witness 4.0 — Foundation Acceptance Report

**Date:** 2026-07-15
**Engine:** Godot 4.6.3
**Mode:** local desktop / headless validation
**Product:** Two Second Witness 4.0 powered by the Living Iris

## Executive verdict

**The foundation passes the automated and structural acceptance gate.** It is ready for a real-device / stranger-test gate before Update 1 begins.

The local project opens under Godot 4.6.3, preserves production identity and version continuity, initializes the production AppBoot/service graph, retains the Iris simulator and orientation/input systems, and contains the production challenge runtime/content tree behind Iris integration hosts.

The remaining acceptance work is human/device validation rather than a known parser, resource, or startup failure.

## PASS — working systems

### Product identity

- PASS — Application name is `Two Second Witness`.
- PASS — Publisher identity remains ITTYBITTYBITES.
- PASS — Android package remains `com.ittybittybites.the2secondwitness`.
- PASS — Version is `4.0.0`.
- PASS — Version code baseline remains `40000`.

### Startup and Iris arrival

- PASS — `MobileSimulator.tscn` is the desktop development entry.
- PASS — `ProductionStartup.tscn` contains the ITTYBITTYBITES / Two Second Witness activation sequence.
- PASS — Production `AppBoot.gd` is initialized behind the startup layer by `ProductionBridge.gd`.
- PASS — Iris remains the visible navigation foundation after activation.
- PASS — Voice, visual, haptic, and caption guidance systems remain in the Iris layer.

### Navigation architecture

- PASS — Iris center enters the production Witness doorway.
- PASS — Archive, Profile, and Settings have production destination hosts.
- PASS — Discover remains the Iris future-content surface.
- PASS — Production route state stays inside `NavigationService`; visible doorway transitions stay inside `MainController` / Iris transitions.
- PASS — Android Back and desktop Escape remain mapped to the Iris return behavior.
- PASS — No second AppShell is mounted as the root application shell.

### Production systems

- PASS — Production source tree exists under `src/`.
- PASS — Challenge contracts, runtime, family registry, interaction adapters, content, progression, programs, saves, profile, settings, accessibility, audio, analytics, and theme services are present.
- PASS — Production assets and Android custom-build files are present.
- PASS — Production Witness host maps Tutorial, Observation, Recall, and Result screens.
- PASS — Production destination host maps Library/Experiences, Profile, Settings, Achievements, Programs, and About rooms.

### Persistence and identity

- PASS — Production `SaveService` / `ProfileService` remain authoritative.
- PASS — Iris-specific state remains separate from production challenge progress.
- PASS — No generated `.godot` or `.import` files are included in the source package.
- PASS — A rollback backup exists outside the project at `/home/user/the_iris_phase7_backup`.

### Godot validation

- PASS — Clean Godot 4.6.3 editor scan completed with exit code 0.
- PASS — Warm headless runtime startup completed with exit code 0.
- PASS — Final scan showed no parser errors, script errors, missing resources, invalid calls, warnings, or leak messages.
- PASS — Static resource/preload reference audit returned zero missing references.
- PASS — Production repository independently passed a Godot 4.6.3 editor scan and headless startup before integration.

### Development environment

- PASS — Mobile Device Simulation Mode remains available.
- PASS — Compact, Standard, Large, and Tablet profiles remain available.
- PASS — Portrait, Landscape Left, and Landscape Right simulation remains available.
- PASS — Touch, mouse, keyboard, controller, Back, orientation, captions, and accessibility layers remain present.
- PASS — Android export presets remain present with production identity and version values.

## CONCERNS — verify during human/device acceptance

1. **Human first launch:** Automated startup verifies that the activation and Iris scenes load, but only a first-time human can confirm that the product identity and first interaction are understood immediately.
2. **Production challenge flow:** Production challenge services and screen hosts are present and boot successfully. The full Tutorial → Observation → Recall → Result flow must still be played on desktop and a physical Android device.
3. **Production screens without AppShell:** Production Profile, Settings, and Library rooms are mounted through Iris hosts instead of the production AppShell. Their AppShell-specific assumptions should be exercised by hand.
4. **Orientation policy:** The Iris foundation supports orientation simulation, while the production Android export preset remains portrait-oriented. Confirm whether 4.0 release behavior should remain portrait-only or move to sensor orientation before exporting.
5. **Audio coexistence:** Production BGM/SFX and Iris VoiceGuide/procedural audio coexist by design. Test volume/mute transitions on a physical device.
6. **Fresh import timing:** The first clean editor import creates Godot import artifacts. Warm startup is clean; first-run import duration should be measured on a normal developer machine and must not be confused with product startup.
7. **Save migration:** The public source contains production migrations, but an actual upgrade test requires a copy of a real pre-4.0 profile and the existing Play Store package/signing path.
8. **Mobile Simulator fidelity:** The simulator approximates safe areas, touch, and orientation. It is not a substitute for real notch, gesture navigation, audio, haptics, or Android Back testing.

## BLOCKERS — before Update 1 / release decision

### Foundation Update 1 blocker

- **Physical-device / stranger test is still required.** Install the local 4.0 build on an actual Android device and have a person unfamiliar with the Iris use it without explanation for 15 minutes.

### Store release blockers

- Private release signing key has not been provided to this workspace.
- Signed APK/AAB has not been produced or tested as an update over the existing Play Store installation.
- Physical Android validation has not yet covered safe areas, Back, orientation, haptics, audio, accessibility, and save migration.

No known local code/parser/resource blocker was found in the automated acceptance pass.

## Recommended final gate before Update 1

1. Export a signed local 4.0 artifact using the existing private key.
2. Install over the current Two Second Witness build on a test Android device.
3. Run the first-launch and returning-user journeys with sound on and off.
4. Exercise Iris → Witness → Observation → Recall → Result → Iris.
5. Exercise Archive/Library, Discover, Profile, Settings, Back, rotation, reduced motion, captions, and explicit access path.
6. Run the 15-minute stranger test without verbal guidance.
7. Record observations separately from code defects.
8. Only then begin the first roadmap update.

## Final acceptance statement

The local Two Second Witness 4.0 foundation is structurally and automatically accepted. The final remaining question is human: whether the Living Iris makes the existing production game feel immediately discoverable and continuous on the real phone.

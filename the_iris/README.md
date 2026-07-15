# Two Second Witness 4.0 — powered by the Living Iris

A Godot 4.6.3 hybrid workspace that preserves the Two Second Witness production challenge platform behind the Living Iris navigation foundation. The Iris is the doorway and relationship layer; production challenges, scenarios, scoring, saves, profile, settings, accessibility, audio, and analytics remain the destination systems.

## Run immediately

1. Open the `the_iris` folder in Godot 4.6 or newer.
2. Press **Play Project**. Desktop launches `scenes/MobileSimulator.tscn`, which embeds the existing `Main.tscn` inside a phone shell. Mobile exports bypass the shell and launch `Main.tscn` directly.
3. For desktop testing, click/drag or use the arrow keys. For Android, touch and swipe.

The project is set for a 720 × 1280 portrait logical viewport and uses the Compatibility renderer for broad mobile support. The Android preset is included in `export_presets.cfg`; choose **Project → Export → Android** after installing Godot's Android export templates and configuring a local debug keystore.

## Interaction map

- Tap the center of the eye: enter **Witness Mode**.
- Hold the eye: enter a quiet **deep-focus calibration** state; release, then tap to enter Witness Mode.
- Swipe left: **Memory Archive**.
- Swipe right: **Discovery Space**.
- Swipe down: **Witness Record / Profile**.
- Swipe up: **Calibration / Settings**.
- In Witness Mode, wait 5.2 seconds. The small second light is revealed and the record is persisted.
- Tap floating archive fragments or discovery points to reopen/select them.

The first launch teaches through short voice moments and the Iris's own responses. After that awakening, navigation is communicated by living rim cues rather than persistent labels.

## Phase 2 navigation architecture

The Iris is now a permanent navigation anchor rather than a screen that is replaced by pages. Every destination is entered through a pupil-opening optical transition and every destination returns through a reverse circular-vignette transition.

- `scenes/Main.tscn` — application shell and single navigation anchor.
- `scenes/LivingIris.tscn` — named Phase 2 entry scene, backed by the existing procedural Iris implementation.
- `scenes/WitnessExperience.tscn` — named experience scene, backed by Witness Mode.
- `scenes/ArchivePlaceholder.tscn` — left direction placeholder.
- `scenes/DiscoverPlaceholder.tscn` — right direction placeholder.
- `scenes/ProfilePlaceholder.tscn` — down direction placeholder.
- `scenes/SettingsPlaceholder.tscn` — up direction placeholder.
- `scripts/MainController.gd` — routes all entrances/exits through the Iris.
- `scripts/NavigationManager.gd` — Phase 2 naming layer over touch/mouse gesture recognition.
- `scripts/BackNavigationController.gd` — Android Back and desktop Escape handling.
- `scripts/TransitionController.gd` — pupil travel, circular vignette, and reverse return choreography.
- `scripts/TransitionOverlay.gd` — shader-driven optical transition surface.
- `scripts/StateManager.gd` — IDLE/CURIOUS/FOCUS/MEMORY states and persisted progress.
- `scripts/IrisController.gd` — shader parameter animation, living-eye energy, and pupil travel aperture.
- `shaders/iris.gdshader` — procedural fibers, limbal rings, aperture, reflections, moisture.
- `shaders/witness.gdshader` — lens distortion atmosphere, focus scan, grain, reveal wash.
- `shaders/transition.gdshader` — circular optical tunnel and closing vignette.
- `scripts/ProceduralSound.gd` — optional generator-based breathing/focus/discovery tone.

Android Back behavior is intentionally native: inside any destination it returns to the Living Iris with the reverse transition; while on the Iris it exits normally. Directional destinations remain subtle, gesture-led placeholders rather than menus or cards.

## Phase 3 living behavior

The Iris now communicates without persistent arrow or destination text. The shader adds four rim lights that softly breathe and brighten toward an in-progress drag. Touches shift the optical highlight toward the user's contact point. The controller adds slow 4–6 second breathing, infrequent micro-saccades, partial inactivity blinks, directional anticipation, supported-device haptic pulses synchronized with pupil travel, and a short-lived alert memory after returning from Witness Mode. Interaction suppresses blinking and all visual changes are eased rather than snapped.

## Phase 4 interaction language calibration

The Iris now performs a quiet center invitation during idle periods, previews directional intent through flowing rim/fiber responses, distinguishes Tap from Hold, and performs a text-free four-direction learning moment after the first Witness return. Android gesture tracking leaves a safe outer margin for system navigation. Calibration includes Reduced Motion and an Explicit Access Path with labeled controls for touch, keyboard, and screen-reader-oriented navigation.

## Phase 5 voice guidance

`scenes/VoiceGuide.tscn` and `scripts/VoiceGuide.gd` add a restrained milestone-based voice layer. The first session can speak “Initializing,” invite center touch, acknowledge the first touch, frame the first Witness, acknowledge the hidden detail, remember the return, and reveal that more exists. These moments are persisted in `user://the_iris_voice.cfg`; completed guidance is not replayed. Generated prototype clips live in `audio/`, with Godot DisplayServer text-to-speech fallback for the calibration phrase and future phrases. Voice is disabled automatically with the existing sound preference, never starts during active touch, and uses a short onboarding gap followed by a multi-minute returning-user cooldown.

## Phase 6 multimodal and cross-device foundation

The voice layer is no longer the only teacher. Visual invitation, deep-focus contraction, directional learning, existing haptics, and optional captions share the same milestone events. `scripts/InputIntent.gd` and `scripts/InputIntentController.gd` translate touch, mouse, keyboard, controller, Escape, right-click, and Android Back into Focus, Enter, Return, and Explore intents. `scripts/DeviceCapabilityManager.gd` detects the available interaction channels and the Iris follows mouse hover on desktop. `CaptionOverlay.tscn` remains hidden by default and can be enabled from Calibration for transcripts. The Explicit Access Path provides labeled controls for users who cannot or do not want to rely on gestures.

## Phase 7 spatial continuity

The project now uses sensor orientation (`Portrait`, `Landscape Left`, `Landscape Right`) with a 750 ms stability threshold and a 480 ms optical settling phase. Orientation changes do not instantiate or reload scenes; active timers, selections, living state, voice progress, and navigation context remain in place. The Iris shader updates its aspect and chamber motion continuously, Witness recomputes its lens aspect without resetting its timer, and the HUD/caption layer reflows to the active window. Calibration includes an Orientation Lock preference and Reduced Motion suppresses the orientation motion layer while preserving state changes.

## Documentation

The documentation index is at `documentation/README.md`. Foundation, integration, challenge, Story Mode, ecosystem, cleanup, and release documents are organized there.

## Two Second Witness 4.0 production integration

The production repository has been audited in `documentation/PRODUCTION_APP_AUDIT.md` and its Godot 4.6.3 source tree is integrated under `src/` with production assets under `assets/`. The Android identity is now `com.ittybittybites.the2secondwitness`, application name `Two Second Witness`, version `4.0.0`, version code `40000`, and the publisher is ITTYBITTYBITES.

`ProductionBridge.gd` runs the production AppBoot/service graph. `ProductionWitnessHost.gd` mounts the production Tutorial, Observation, Recall, and Result screens inside the Iris Witness doorway. `ProductionDestinationHost.gd` mounts production Experiences/Library, Profile, Settings, Achievements, Programs, and About screens through Iris destinations. The production ChallengeSessionService remains authoritative for challenge generation, validation, scoring, recommendations, persistence, and results.

The current Iris prototype state remains only for Iris-specific awakening and interface behavior; production gameplay/profile/settings persistence stays on the production services and save files.

See `documentation/TWO_SECOND_WITNESS_4_INTEGRATION_REPORT.md` for the migration map, preserved systems, risks, and validation status.

## Phase 7 development device simulator

`scenes/MobileSimulator.tscn` is now the desktop development main scene. It embeds the unchanged `Main.tscn` inside a resizable SubViewport and draws a development-only modern phone shell. Android/mobile runtime bypasses the shell and instantiates `Main.tscn` directly, so the simulator does not become part of the exported mobile experience.

Desktop shortcuts:

- F1 — show/hide phone frame
- F2 — portrait
- F3 — landscape left
- F4 — simulate Android Back
- F5 — restart current test session
- F6 — clear onboarding/progress data and restart
- F7 — toggle sound
- F8 — cycle Compact / Standard / Large / Tablet profiles
- F9 — landscape right
- F10 — show/hide developer overlay
- 1 / 2 / 3 / 4 — select Compact / Standard / Large / Tablet directly

The overlay reports simulated profile, resolution, orientation, current screen, Iris state, and FPS. Mouse input is forwarded through the SubViewport as touch-like input, with a temporary development touch indicator.

## Performance notes

The integrated workspace combines the Iris full-screen shaders and low-count particles with the production content/runtime asset tree. It does not require network services or paid runtime assets. Production BGM/SFX and VoiceGuide remain local assets. Animation intensity and Reduced Motion are available in Calibration, and the renderer remains configured for mobile compatibility.

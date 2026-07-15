# Two Second Witness 4.0 Foundation Baseline

**Baseline status:** Foundation locked for measured development
**Baseline date:** 2026-07-15
**Engine:** Godot 4.6.3

## Product identity

- **Application:** Two Second Witness
- **Publisher:** ITTYBITTYBITES
- **Android package:** `com.ittybittybites.the2secondwitness`
- **Version:** `4.0.0`
- **Android version code baseline:** `40000`

The Living Iris is the navigation and experience foundation inside Two Second Witness. It is not the application name, replacement brand, or separate product.

## Architectural vision

```text
Two Second Witness 4.0
│
├── Iris Foundation
│   ├── Living Iris
│   ├── Navigation and Input Intents
│   ├── Optical Transitions and Android Back
│   ├── Voice / Visual / Haptic / Caption Guidance
│   ├── Device and Orientation Adaptation
│   └── Mobile Device Simulation Mode
│
├── Production Game
│   ├── Challenge Families
│   ├── Observation
│   ├── Recall
│   ├── Scoring and Results
│   └── Progression / Recommendations
│
├── Player Systems
│   ├── Profile
│   ├── Settings and Accessibility
│   └── Versioned Saves
│
└── Content Systems
    ├── Challenge Data and Scenarios
    ├── Family Modules
    ├── Production Assets and Audio
    └── Experiences / Programs / Achievements
```

## Current state

### Iris foundation

- Living Iris procedural shader and living state system
- Tap, hold, swipe, keyboard, mouse, controller, and Android Back intent paths
- Iris entry/return transitions
- Orientation stability handling and sensor/posture parallax
- Device capability detection
- VoiceGuide with milestone persistence and TTS fallback
- Visual guidance when audio is disabled
- Optional captions and explicit accessibility navigation
- Desktop Mobile Simulator with phone profiles and orientation shortcuts

### Production integration

- Production AppBoot/service graph initializes behind the Iris
- Production ChallengeSessionService remains authoritative
- Production Tutorial, Observation, Recall, and Result screens mount inside the Witness doorway
- Production Experiences/Library, Profile, Settings, Achievements, Programs, and About screens mount through Iris destinations
- Production Challenge Family Registry and content tree are present
- Production ProfileService / PlayerProgressService / SaveService remain authoritative for player progress
- Production SettingsService / AccessibilityService remain authoritative for production settings
- Production AudioService and AnalyticsService remain available

### Current validation state

- Production repository audited read-only
- Godot 4.6.3 editor scans pass
- Local headless startup passes
- Resource/preload audit passes with zero missing references
- Automated acceptance report completed
- Physical device, signed artifact, Play Store upgrade, and stranger testing remain release-process work

## Protected systems

Future changes must not break or replace these systems without an explicit migration plan:

- Iris navigation foundation
- Iris transition and Back behavior
- Input Intent layer
- Device and Orientation managers
- Voice and multimodal guidance
- Mobile Simulator development workflow
- Production ChallengeSessionService
- Challenge Family Registry and challenge contracts
- Generators, validators, difficulty, exposure, scoring, and result systems
- Scenario/content manifests and production assets
- SaveService and profile schema/migrations
- ProfileService and PlayerProgressService
- SettingsService and AccessibilityService
- AudioService
- AnalyticsService
- Android package, export presets, version continuity, and signing/update path

## Ownership rules

- Iris owns the doorway, not gameplay rules.
- Production runtime owns challenge behavior, results, and progression.
- Production save/profile/settings services own durable player state.
- Content is data-driven and registered through production manifests/contracts.
- The production AppShell is not a second visible root shell.
- New updates must plug into the existing boundaries instead of introducing parallel managers.

## Known limitations

- Physical Android validation has not been completed in this workspace.
- The public source does not include the private release keystore.
- The Android export preset retains the production portrait policy; final sensor-orientation policy requires device approval.
- Full human playtesting of all production challenge families through the Iris doorway remains required.
- The Mobile Simulator approximates hardware and is not a substitute for real safe-area, haptic, audio, and Back testing.

## Baseline lock

This document marks the current workspace as the **Two Second Witness 4.0 Foundation Baseline**. Future work must be incremental, documented, tested, and reversible.

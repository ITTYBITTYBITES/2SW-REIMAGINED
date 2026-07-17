# Two Second Witness 4.0 Development Rules

## Purpose

These rules protect the locked Two Second Witness 4.0 foundation while allowing the planned roadmap to evolve it safely.

## Required before changing code

1. Read `PROJECT_FOUNDATION.md`, `TWO_SECOND_WITNESS_4_BASELINE.md`, and `AI_DEVELOPMENT_GUIDE.md`.
2. Inspect the existing system and its tests before proposing a replacement.
3. Identify the current source of truth for the feature.
4. Check whether the feature already exists in the production source tree.
5. Record the affected ownership boundary and persistence implications.

## Architecture rules

- Preserve the Iris / Game / Player / Content separation.
- Do not create duplicate navigation, save, profile, settings, accessibility, audio, or challenge services.
- Do not mount the production AppShell as a second visible root shell.
- Do not place family-specific gameplay logic in Iris scripts.
- Do not replace production progress with prototype ConfigFile state.
- Do not bypass `ChallengeSessionService` for production challenge starts/results.
- Keep all new destination entry and exit behavior routed through the Iris.
- Keep Android Back behavior natural and reversible.

## Change rules

Future changes must:

- preserve the existing product name, publisher, package, and version continuity;
- preserve existing saves and provide migrations when schemas change;
- preserve content and future roadmap extension points;
- use additive changes where possible;
- keep bridges small and permanent integration boundaries explicit;
- avoid unnecessary rewrites of validated production systems;
- update documentation when architecture, contracts, settings, or release behavior changes;
- add or update automated validation before claiming completion;
- test sound-on, sound-off, reduced-motion, captions, explicit-access, desktop, and Android paths when relevant;
- leave the workspace free of generated `.godot`, `.import`, build, or APK artifacts unless explicitly requested.

## Future agent rules

Future agents must:

- inspect first;
- audit dependencies and ownership;
- avoid replacing working architecture with a new framework;
- avoid copying a second repository root;
- avoid inventing monetization, analytics, or persistence systems;
- avoid treating the Iris as a separate product;
- preserve the ITTYBITTYBITES / Two Second Witness identity;
- use the existing Mobile Simulator before requesting physical-device validation;
- stop at phase boundaries and document remaining risks.

## Testing gate

Every meaningful change should pass:

1. clean Godot 4.6.3 editor scan;
2. headless startup with Dummy audio;
3. resource/preload reference audit;
4. relevant production runtime tests;
5. Mobile Simulator test for affected interaction paths;
6. save/progress persistence check;
7. documentation and release-impact review.

Do not call a roadmap item complete if the project only passes a syntax scan while its user journey is untested.

## Release gate

Before a release candidate:

- package and signing identity must remain unchanged;
- version code must advance from the baseline;
- a signed artifact must be installed over the existing app;
- saves, Back, safe areas, audio, haptics, orientation, and accessibility must be tested on physical Android hardware;
- a human stranger test must be recorded for the Iris entry/navigation language.

## Architecture Freeze v1.0
The following systems are considered stable and should not be modified unless a production bug requires it:
- Startup flow
- MainController boot lifecycle
- Experience Readiness Gate
- Living Iris initialization
- Witness Runtime core
- Save/Profile architecture
- Routing framework
- Audio/Haptic services

Future work should consume these systems rather than redesign them.

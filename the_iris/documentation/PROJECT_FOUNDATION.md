# Two Second Witness 4.0 — Project Foundation

## Product identity

- **Application:** Two Second Witness
- **Publisher:** ITTYBITTYBITES
- **Version:** 4.0.0
- **Android package:** `com.ittybittybites.the2secondwitness`
- **Iris role:** Living navigation and relationship foundation inside the existing product

The Iris is not the product name and must not replace the Two Second Witness brand. A returning player should recognize the game while feeling that the doorway has evolved.

## Architecture

```text
Two Second Witness 4.0
│
├── Iris Foundation
│   ├── Living Iris
│   ├── Navigation / Input Intent
│   ├── Optical transitions / Android Back
│   ├── Voice / Multimodal Guidance
│   ├── Device / Orientation / Parallax
│   └── Desktop Mobile Simulator
│
├── Game Systems
│   ├── Challenge Family Registry
│   ├── Challenge Session Runtime
│   ├── Generators / Validators
│   ├── Difficulty / Exposure policies
│   ├── Family-owned scoring
│   └── Results / Recommendations
│
├── Player Systems
│   ├── ProfileService / PlayerProgressService
│   ├── SettingsService / AccessibilityService
│   ├── SaveService
│   ├── Achievements / Programs
│   └── Analytics / Audio / Theme
│
└── Content Systems
    ├── `src/LegacyMechanics/` manifests and content
    ├── `src/experiences/` catalog metadata
    ├── `assets/gameplay/` production scenes and sprites
    ├── `assets/audio/` production BGM/SFX
    └── `assets/brand/` and `assets/splash/`
```

## Ownership rules

### Iris Layer

The Iris layer owns:

- startup activation
- the visual navigation anchor
- tap/hold/swipe/input-intent interpretation
- optical entry and return transitions
- Android Back visual language
- device/orientation adaptation
- voice, haptics, captions, and nonverbal guidance
- the desktop Mobile Simulator
- Iris-only awakening and relationship state

The Iris layer must not generate, score, or persist production challenge results.

### Game Layer

The production layer under `src/gameplay/` owns:

- challenge families and templates
- deterministic generation
- fairness validation and fallback
- interaction adapters
- difficulty and exposure
- family-owned scoring
- result contracts
- challenge sessions and recommendations

`ChallengeSessionService` is the authority for gameplay lifecycle.

### Player Layer

Production services own:

- `SaveService` persistence and migration
- `ProfileService` profile and saved progress
- `PlayerProgressService` Witness progress/history
- `SettingsService` settings
- `AccessibilityService` accessibility behavior
- `AchievementService` milestones
- `ProgramService` curated progress

Do not create a second production save or profile model in Iris scripts.

### Content Layer

Content is data-driven. New challenge families, scenarios, assets, and programs must register through production manifests/contracts rather than requiring new branches in Iris navigation.

## Integration boundaries

- `src/iris/integration/ProductionBridge.gd` starts production AppBoot behind the Iris.
- `src/iris/integration/ProductionWitnessHost.gd` mounts Tutorial → Observation → Recall → Result screens inside the Iris Witness doorway.
- `src/iris/integration/ProductionDestinationHost.gd` mounts production Library, Profile, Settings, Achievements, Programs, and About rooms through Iris destinations.
- `src/iris/startup/ProductionStartup.gd` presents the ITTYBITTYBITES / Two Second Witness activation sequence.

These are permanent integration boundaries, not temporary test shims. Keep them small and route-oriented.

## Navigation rules

- Iris center opens the production Witness flow.
- Iris left opens the production Challenge Library/Archive room.
- Iris right opens Discover/future content space.
- Iris down opens the production Profile/Record room.
- Iris up opens the production Settings/Accessibility room.
- Back inside any room returns through the Iris.
- Back on the Iris exits normally.
- Production gameplay may move between Tutorial, Observation, Recall, and Result internally, but leaving the production flow must return to the Iris.

## Future update workflow

1. Add or update production contracts/content first.
2. Add a family module and manifest entry if the update introduces a challenge family.
3. Add assets under the production content tree.
4. Register the family through `ChallengeFamilyRegistry` and interaction adapters.
5. Verify `ChallengeSessionService` can start, validate, score, result, save, and recommend it.
6. Expose it through the Iris destination that owns the relevant room; do not add a new home dashboard.
7. Add accessibility, reduced-motion, audio, and save migration behavior.
8. Run the editor scan, headless startup, runtime regression tests, and Mobile Simulator checks.
9. Update the relevant product documentation and integration report.

## Rules future developers and agents must preserve

- Do not rename Two Second Witness or change the Android package.
- Do not replace the production save/profile/settings services.
- Do not mount a second AppShell as the visible root.
- Do not put family-specific gameplay logic into Iris scripts.
- Do not use Iris ConfigFile state for challenge progress.
- Do not add conventional dashboard navigation as the default.
- Do not remove existing challenge families, scenarios, assets, or accessibility behavior without an approved migration.
- Do not commit private signing keys, generated `.godot` files, or editor import artifacts.
- Keep production Android version continuity; release signing remains external.

## Development and release

- Desktop: run `scenes/MobileSimulator.tscn` through the project main scene.
- Simulator shortcuts are documented in `README.md`.
- Android: the simulator shell bypasses itself and instantiates `Main.tscn` directly.
- Godot version: 4.6.3.
- Before release, export with the production Android preset and the private existing signing key. Physical device and Play Store update validation are mandatory.

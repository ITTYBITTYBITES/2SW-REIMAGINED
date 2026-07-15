# Technical Debt Audit — Two Second Witness 4.0

**Audit date:** 2026-07-15
**Scope:** local hybrid workspace after Iris / Two Second Witness production integration
**Baseline:** Godot 4.6.3, package `com.ittybittybites.the2secondwitness`, version `4.0.0` / code `40000`

## Decision vocabulary

- **KEEP:** required production capability or protected foundation.
- **REFACTOR:** keep behavior, improve ownership, naming, or boundaries.
- **REMOVE:** generated, duplicate, dead, or superseded material.
- **REPLACE:** a temporary prototype implementation should be replaced by the authoritative production system.

## Findings

| Area / item | Classification | Finding and action |
|---|---|---|
| `src/` production services and gameplay runtime | KEEP | Authoritative Two Second Witness systems: boot, navigation, saves, profile, settings, content, challenge families, runtime, scoring, progression, audio, accessibility, analytics. Do not remove or duplicate. |
| `assets/` production content and brand | KEEP | Required for current challenge families, production screens, future roadmap, Android identity, and publisher continuity. Do not prune by filename alone. |
| `android/` custom build support | KEEP | Required for the production Android export path. Private signing keys remain external. |
| `scripts/IrisController.gd`, navigation, transitions, orientation, device, guidance | KEEP / REFACTOR | These are now the Iris Foundation. Keep behavior; document ownership and remove prototype-only coupling where safe. |
| `src/iris/integration/ProductionBridge.gd` | REFACTOR | It is no longer temporary migration glue. Make it the permanent Iris-to-production boot boundary and document its single responsibility. |
| `src/iris/integration/ProductionWitnessHost.gd` | REFACTOR | It is the permanent Witness experience adapter. Keep, but isolate under the Iris integration namespace and keep production route mapping centralized. |
| `src/iris/integration/ProductionDestinationHost.gd` | REFACTOR | Permanent destination adapter. Keep; centralize route/screen ownership and avoid adding per-destination bridges. |
| `src/iris/startup/ProductionStartup.gd` | KEEP / REFACTOR | Permanent product activation layer. Rename/document as the Two Second Witness activation sequence rather than a temporary overlay. |
| `scripts/MobileSimulator.gd`, frame, touch indicator | KEEP | Development-only tool. Keep isolated, with mobile bypass and export documentation. Do not let simulator state enter production saves. |
| `MobileSimulator.tscn` as project main scene | REFACTOR | Needed for Ctrl+F5 desktop simulation but currently sits in the production run path. Keep the conditional bypass for Android and document the limitation; add export exclusion rules for future release tooling if safe. |
| current prototype `Archive.gd`, `Profile.gd`, `Settings.gd` presentation | REFACTOR / REPLACE | They remain Iris-facing fallbacks and adapters. Production screens/services are now authoritative; keep only the Iris doorway and fallback state, not duplicate production business logic. |
| current prototype `WitnessMode.gd` | REPLACE | Legacy sample Witness timer/reveal remains as a fallback but production WitnessHost is authoritative. Remove the fallback only after the production host has an explicit offline/error fallback. |
| `StateManager.gd` Iris state/config | KEEP | Own only Iris awakening, living-eye state, and Iris preferences. Do not store production challenge progress here. |
| `src/core/navigation/NavigationService.gd` plus Iris MainController | REFACTOR | Two navigation owners are intentional at different layers, but the boundary must remain explicit: Iris owns doorway transitions; production owns gameplay route state. No cross-layer direct screen swapping. |
| production `AppShell` screens | KEEP | Production rooms remain available through Iris destination hosts and future routes. Do not mount AppShell as a second root shell. |
| generated `.godot/` | REMOVE | Generated editor/import cache. Never package or treat as source. |
| copied `.import` metadata under production assets | REMOVE | Generated import metadata; Godot regenerates it. Removing reduces noise and avoids stale imported paths. |
| root `assets/icon.svg` and `assets/iris_particle.svg` | KEEP | Iris foundation assets. Production launcher assets under `assets/brand` are authoritative for product identity. |
| `audio/` voice clips and local bus layout | KEEP | Iris VoiceGuide assets and local procedural audio. Production audio under `assets/audio` remains authoritative for gameplay. |
| `UX_STRESS_TEST.md` | KEEP | Product validation record; not runtime code. |
| `documentation/PRODUCTION_APP_AUDIT.md` | KEEP | Source audit and migration rationale. |
| `documentation/TWO_SECOND_WITNESS_4_INTEGRATION_REPORT.md` | KEEP / SUPERSEDE | Keep as migration history; this hardening report and foundation docs become the current source of truth. |
| `README.md` | REFACTOR | Consolidate product identity, run instructions, architecture, and development workflow. Remove stale prototype-only language. |
| `the_iris_phase7_backup` outside project | KEEP OUTSIDE SOURCE | Preserve as rollback safety copy; do not include in project/export/archive. |
| empty `.gitkeep` placeholder folders in production assets | KEEP | Some are intentional content extension points; do not remove without roadmap decision. |
| duplicated `app/` production tree | REMOVE / NOT PRESENT | The source repository was not copied as an `app/` nested destination. This avoids a second project root and duplicate project settings. |
| monetization SDK/hooks | KEEP AS ABSENCE | Audit found no active monetization implementation. Do not invent one during hardening. |
| hardcoded Iris coordinates and timing constants | REFACTOR | Keep visual tuning values but group/label them as design constants; production gameplay values remain in production contracts/data. |
| ad hoc `user://the_iris_state.cfg` and `user://the_iris_voice.cfg` | KEEP / REFACTOR | Valid for Iris-specific relationship state. Explicitly prevent these files from becoming production progress storage. |
| `export_presets.cfg` | KEEP / REFACTOR | Production package/version identity is authoritative. Preserve Android Development and Play Store presets; keep private keystore values external. |
| temporary integration test scripts | REMOVE | No temporary `integration_*` test scenes/scripts remain in the source tree after validation. |

## Duplicate-source-of-truth risks

1. **Challenge progress:** must remain in `ProfileService` / `PlayerProgressService`, never Iris `StateManager`.
2. **Settings:** production `SettingsService` is authoritative for production settings. Iris-only options are explicitly named and synchronized where applicable.
3. **Gameplay navigation:** `NavigationService` owns production routes inside hosts; `MainController` owns Iris doorway transitions.
4. **Audio:** production `AudioService` owns gameplay BGM/SFX; Iris procedural sound and VoiceGuide are additive and obey production mute settings where connected.
5. **Profile presentation:** production `ProfileScreen` is the room; Iris Profile is the doorway/host, not a second profile data model.
6. **Android identity:** `project.godot` and `export_presets.cfg` must agree on name/package/version; private signing material is never copied.

## Hardening priorities

### P0 — complete before foundation lock

- Remove generated import/editor artifacts from the source package.
- Consolidate documentation and update root README.
- Add explicit production/Iris ownership comments and a permanent integration report.
- Run clean Godot 4.6.3 import/editor/runtime scans after cleanup.

### P1 — complete during foundation lock

- Reduce bridge scripts to permanent, named integration boundaries.
- Add a single production route-to-host mapping source.
- Add safe audio/settings synchronization and controlled error fallback.
- Document the Mobile Simulator desktop-only behavior and Android bypass.

### P2 — roadmap follow-up

- Replace the legacy sample Witness fallback with a production failure-state host.
- Add automated integration tests for tutorial → observation → recall → result.
- Add save migration tests against a copy of the production profile schema.
- Validate release APK/AAB with the private signing key and physical Play Store update path.

## Audit conclusion

The workspace is structurally viable for hardening. The production source is not a disposable migration payload: its runtime contracts, data, saves, and service graph are the foundation to preserve. The main cleanup task is boundary clarity and removal of generated/development noise, not deletion of production capability.

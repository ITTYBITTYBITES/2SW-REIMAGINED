# IRIS_DEV_LOG.md

## Mission 054B — Living Iris Spatial Hub

Date: 2026-07-18
Scope: interaction-architecture prototype following Mission 054A. No Witness Moments, chapters, or final visual content were added.

### Objective

Move the Home experience from a single navigation fragment toward a living memory field: the existing Living Iris remains the artifact at the center while memory shards and existing routes arrange themselves around it.

### Implemented foundation

#### 1. Spatial Hub hierarchy

Added `the_iris/scripts/home/SpatialHub.gd`, hosted by the existing `IrisHome` container.

It declares the requested Node3D composition contract:

```text
SpatialHub
├── Foreground_Nav
├── Midground_Active
├── Background_Constellation
└── SpatialHubCamera
```

The project still uses its established procedural 2D renderer for the prototype visual layer. The Node3D hierarchy and `Camera3D` are deliberately present as the transition-safe spatial/camera foundation; no final art, scene migration, or competing navigation scene was introduced.

#### 2. Three experiential layers

| Layer | Current prototype role |
| --- | --- |
| `Foreground_Nav` | Always-present **Story**, **Archive**, and **Profile** controls. Story and Archive preserve their existing Application routes; Profile is an in-place view of the existing `WitnessProfile` data. |
| `Midground_Active` | One selectable current-memory shard (`FM_001`) retaining the pre-existing Continue Witness route. |
| `Background_Constellation` | Placeholder constellation shards for existing `WM_001`–`WM_005` identifiers. Profile-completed IDs are styled as restored truth fragments; the rest remain dormant placeholders. |

No new moment definition, chapter, or content data was created. Existing identifiers are used only as spatial placeholders.

#### 3. Spatial interaction proof

The hub includes:

- low-frequency orbit behavior, with distinct active and constellation bands;
- procedural prototype shard visuals and connecting field lines;
- pointer proximity focus and selected states;
- focus camera target movement using `SpatialHubCamera`;
- selection of the active shard through the existing flagship route;
- selection of constellation placeholders through the existing Archive route;
- focus signals carrying a normalized target to the pre-existing Iris attention path.

#### 4. Iris and route preservation

`IrisHome` forwards hub focus/select events to its original `memory_intent_*` signals. `Application.gd` therefore continues to call the existing `IrisCore.acquire_attention()`, personality resolution, audio, haptic, and settle behavior. The 054A awakening ritual and its authored Iris lifecycle were not changed.

The existing `Application.gd` routes remain authoritative:

- Story → `show_witness()`
- Archive → `show_archive()`
- current-memory shard → existing `start_flagship_moment()` path

#### 5. Validation

Added `the_iris/tests/spatial_hub_validation.gd`.

It asserts the Node3D layer names, Camera3D foundation, orbit and selection contracts, pre-existing content IDs, existing IrisHome route forwarding, and Application profile/registry configuration.

Run when Godot is available:

```bash
godot --headless -s tests/spatial_hub_validation.gd
```

### Current limitations

1. The Node3D graph is an intentional foundation, while the mobile prototype still renders its shards procedurally in 2D.
2. Camera motion records live spatial intent; a later art/portal pass can attach a `SubViewport` or move this contract into a rendered 3D scene without changing hub routing.
3. Profile is deliberately a foreground in-place data view, not a new profile navigation screen.
4. Constellation nodes are placeholders, not access to new or expanded Witness content.

---

## Mission 054A — Living Iris Awakening Ritual

Date: 2026-07-18
Scope: first authored Living Iris presence milestone after Mission 053C production audio foundation.

### Objective

Make the first 30–60 seconds of the prototype feel like the artifact noticed the player.

This pass does **not** add Witness Moments, menus, chapters, or navigation complexity. It extends existing Living Iris rendering, Iris state, audio, haptic, personality, and application flow into an authored awakening experience.

---

## DONE

### 1. Controlled Iris wake sequence

Startup now preserves the existing `StartupFlow` splash architecture, then enters an authored Living Iris ritual:

```text
Application launch
  ↓
StartupFlow splash
  ↓
Iris screen enters dark/quiet state
  ↓
Iris breath ambience begins
  ↓
Iris calibration lifecycle starts
  ↓
Awakening sound + blink/opening animation
  ↓
Transition cue
  ↓
Welcome dialogue
  ↓
Ready dialogue
  ↓
AWARE state / first interaction prompt
```

Implemented in `IrisController.begin_awakening_ritual()` and `_update_awakening_ritual()`.

Key authored timing details:

- initial dark veil prevents instant appearance
- ambience enters before the Iris becomes visible
- the existing `IrisCore` lifecycle still owns state transitions and animation
- labels fade in only after the artifact has visibly awakened
- low haptic pulses mark awakening and ready beats

### 2. Iris attention behavior

Extended `IrisCore` without replacing it.

Added first-pass simulated awareness behavior:

- idle gaze drift remains procedural
- small saccadic gaze movements are slightly more perceptible in `WELCOMING`, `AWARE`, `SETTLED`, and `REFLECTIVE`
- occasional focus changes pulse the Iris subtly without real tracking
- player tap still transitions through `ATTENDING` / `FOCUSED`
- player interaction now gets a soft Iris attention sound and light haptic acknowledgment

No real eye tracking was added.

### 3. Event-driven dialogue foundation

Created data-driven dialogue content:

- `the_iris/content/iris/iris_dialogue_events.json`

Created registry:

- `the_iris/scripts/iris/IrisDialogueRegistry.gd`

Added authored events:

| Event | Text |
|---|---|
| `iris_welcome` | “I remember your perspective.” |
| `iris_idle` | “I am still here.” |
| `iris_ready` | “A memory is waiting.” |
| `iris_return` | “You came back with more of the pattern.” |

The registry stores:

- display text
- accessibility text
- expression mode
- audio hook
- haptic hook
- placeholder voice key

`IrisPersonalityResolver` now checks this registry before falling back to older expression-mode defaults.

### 4. Audio integration

No new audio assets were created.

Mission 053C assets are now used for the ritual:

| Ritual/event role | Asset |
|---|---|
| wake ambience | `res://assets/audio/iris/iris_breath_loop.ogg` |
| Iris activation | `res://assets/audio/iris/iris_awaken.ogg` |
| transition cue | `res://assets/audio/iris/iris_transition.ogg` |
| welcome/focus cue | `res://assets/audio/iris/iris_focus.ogg` |
| ready cue | `res://assets/audio/iris/iris_confirm.ogg` |
| return/idle presence | `res://assets/audio/iris/iris_presence.ogg` |
| interaction attention | `res://assets/audio/iris/iris_attention.ogg` |

### 5. Haptic integration

Added low-intensity haptic hooks for:

- Iris welcome pulse
- Iris idle/breath presence
- Iris ready pulse
- Iris return acknowledgment
- player interaction acknowledgment

All new authored haptic events use `IrisHapticConsumer.Pattern.LIGHT` or direct short light pulses. No heavy rumble was added to the startup ritual.

### 6. Automated validation

Created:

- `the_iris/tests/iris_awakening_validation.gd`

Validation coverage:

- dialogue JSON exists
- required events are registered
- dialogue text exists
- dialogue audio references resolve to existing Iris audio assets
- `IrisController` exposes ritual API
- `IrisCore` exposes simulated attention behavior
- low-intensity haptic hooks exist

---

## Files changed for Mission 054A

Primary 054A files:

- `IRIS_DEV_LOG.md`
- `the_iris/content/iris/iris_dialogue_events.json`
- `the_iris/scripts/iris/IrisDialogueRegistry.gd`
- `the_iris/scripts/iris/IrisController.gd`
- `the_iris/scripts/iris/IrisCore.gd`
- `the_iris/scripts/iris/IrisPersonalityResolver.gd`
- `the_iris/scripts/iris/IrisExpressionOverlay.gd`
- `the_iris/scripts/iris/IrisAccessibilityConsumer.gd`
- `the_iris/scripts/iris/IrisAudioConsumer.gd`
- `the_iris/scripts/iris/IrisHapticConsumer.gd`
- `the_iris/scripts/Application.gd`
- `the_iris/tests/iris_awakening_validation.gd`

Mission 053C audio foundation files are also present in this working branch because 054A builds directly on them.

---

## Current limitations

1. **No real eye tracking.**  
   Awareness is simulated through procedural gaze/saccade/focus behavior.

2. **No final voice assets.**  
   Voice hooks exist as placeholder `voice_placeholder_*` keys. Dialogue currently appears as text and uses existing Iris audio cues.

3. **No video or screenshot captured.**  
   This sandbox does not provide a Godot visual runtime capture path.

4. **Godot CLI validation not run in this sandbox.**  
   `godot` / `godot4` is not installed here. Static validation was performed where practical.

5. **The ritual is first-pass authored timing.**  
   It should be tuned with actual device playback and human feel review.

6. **Not the full Signature Loop.**  
   Spatial Hub and portal transition work are intentionally deferred to later missions.

---

## Validation notes

Static checks performed:

- `git diff --check`
- audio reference existence scan
- dialogue JSON/audio reference scan
- script reference scan

Godot command to run when available:

```bash
godot --headless -s tests/iris_awakening_validation.gd
```

---

## Mission status

DONE:

- Iris no longer instantly appears after splash
- first authored wake ritual exists
- Iris starts in dark/quiet state
- breath ambience begins before visible emergence
- activation / transition / ready cues are connected
- welcome and ready text hooks are data-driven
- light haptics are connected
- simulated attention makes the Iris feel more observant

REMAINING:

- tune timings with real Godot playback
- validate on Android device
- add real voice assets later if desired
- build 054B Spatial Hub separately
- build 054C Portal Transition separately

---

## Mission 054C — Through the Pupil Portal

Date: 2026-07-18
Scope: physical transition foundation between the existing Spatial Hub and existing Witness Moment loading. No Witness content, chapter, or navigation authority was added.

### Implemented

- Added `IrisPortalTransition.gd` with an authored portal lifecycle:
  `READY → FOCUSING → DILATING → ENTERING → TRANSITIONING → ARRIVED`.
- Added temporary `LivingIris.portal_dilation`, consumed exclusively by the pupil renderer. This presentation value enlarges the actual existing pupil without modifying `IrisCore` state authority.
- Added a current-memory preview using existing moment title/subtitle data and abstract procedural refraction bands; no new visual asset/content dependency was introduced.
- Added focus/dilation/transition audio and light haptic hooks using the production Iris audio foundation.
- Routed existing Home, chapter, and Archive replay moment entry through `Application.request_memory_portal()` before calling the unchanged `start_generic_gameplay()` loader route.
- Added a return foundation: after the existing reward return request, gameplay closes, the memory collapses through the portal, and the original home/archive destination resumes. Home return continues through the existing reflective return timing and `iris_return` personality event.
- Added `tests/iris_portal_validation.gd` for portal state, preview, pupil, route-preservation, no-content-dependency, and return-path contract checks.

### Limitations

1. The portal uses procedural refraction and a pupil-window prototype rather than a final shader or memory-art composition.
2. Camera approach is represented by the portal camera amount/visual scale foundation; a later rendering pass can bind it to a SubViewport or full 3D camera without changing Application routing.
3. Runtime Godot/device playback is still required for timing, visual intensity, and accessibility review.

---

## Mission 055 — Witness Engine Evolution

Date: 2026-07-18
Scope: additive production evolution of the active generic Witness runtime. Existing registries, loaders, profile persistence, Archive authority, Application routing, and Iris portal remain authoritative.

### Implemented

- Added `WitnessFracture`, a canonical runtime contract with fracture identity, location/size, discovery/synchronization/reveal state, and truth-fragment reward reference.
- Extended `WitnessMomentDefinition` with backward-compatible `fractures`, `memory_stability`, `truth_fragment`, and `iris_guidance` fields. When absent, a safe primary Fracture is synthesized from existing `anomaly_definition` and `capture_window` fields.
- Refactored the active `GenericWitnessGameplay` presentation into:

```text
Observe → Locate Fracture → Synchronize → Reveal Truth → Truth Fragment → Reward / portal return
```

- Implemented the synchronization prototype: hold-focus input, progress indicator, stability indicator, haptic/audio feedback, collapse/reset foundation, and successful stability recovery.
- Extended `WitnessMomentResult`, `WitnessProfile.moment_records`, and `WitnessArchive` with optional synchronization, stability, revelation, and truth-fragment outcomes—without a second progression or save system.
- Migrated **WM_001 only** with authored fracture, stability, truth-fragment, and Iris-guidance fields. WM_002–WM_012 remain unchanged and use compatibility defaults.
- Added the data-driven `truth_fragment_absorbed` Iris dialogue/audio/haptic/expression event. `Application` emits it after existing profile completion persistence succeeds.
- Added `tests/witness_engine_evolution_validation.gd` to validate all twelve production definitions, WM_001 authored data, result/archive persistence, runtime phases, and Iris feedback wiring.

### Compatibility notes

- Legacy `anomaly_definition` and `capture_window` remain supported and are not removed.
- The existing `WitnessContentLoader` and `Application.start_generic_gameplay()` path remain unchanged as the content/runtime authority.
- Existing Archive data remains in `WitnessProfile.moment_records`.
- Legacy `WM001GameplayLoop`, `FlagshipWitnessMoment`, and `WitnessMomentOrchestrator` were not expanded; Mission 055 targets the active generic path only.

### Validation

Run when Godot is available:

```bash
cd the_iris
godot --headless -s tests/witness_engine_evolution_validation.gd
```

### Limitations

- The first pass supports one active fracture at a time; the data contract can carry multiple future fractures.
- Synchronization is deliberately a short hold-focus proof rather than a balanced minigame.
- Truth Fragment presentation is runtime text/feedback and record persistence; constellation/Archive visual redesign remains later work.

---

## Mission 055B — WM-001 Showcase Pass

Date: 2026-07-18
Scope: authored player-experience pass for `WM_001` / *The Unfinished Canvas*. The Mission 055 engine, Application routing, profile persistence, Archive authority, and pupil portal were preserved.

### Implemented

- Added optional `showcase` data to `WitnessMomentDefinition`; it is empty by default and does not alter other moments.
- Authored WM-001 presentation data for deliberate observation prompts, fracture language, meaningful false leads, synchronization language, studio pacing, and a short reconstruction duration.
- Added data-driven WM-001 Iris guidance events for observation, fracture prompting, discovery, synchronization, and revelation. They use the existing personality resolver, expression overlay, production audio, haptic consumer, and Application ownership.
- Added procedural WM-001-only atmosphere in the active generic runtime: late studio-light rays, dust motes, a living fracture halo, coherence rings during synchronization, and a brief reconstruction sweep during revelation. No final art assets were required.
- Improved Fracture discovery feedback with custom audio, haptics, guidance, visual halo, and authored false-lead responses.
- Improved synchronization presentation with authored focus language, Iris guidance, completion cue, coherence visuals, and the existing stability/recovery mechanic.
- Strengthened revelation using a short reconstruction pass, Iris reaction, existing transition/resolution audio, and the existing `fragment_borrowed_light` absorption/Archive/portal return flow.
- Added `tests/wm001_showcase_validation.gd` for WM-001 data, audio, Iris guidance events, generic runtime presentation hooks, existing persistence, and return-route wiring.

### Limitations

- Studio atmosphere and reconstruction are procedural prototype effects layered over existing WM-001 assets, not final production art or shaders.
- Reveal pacing, ambient mix, haptic feel, and visual contrast require device review in a real Godot build.
- The Archive retains fragment data; its constellation presentation remains Mission 056 work.

Run when Godot is available:

```bash
cd the_iris
godot --headless -s tests/wm001_showcase_validation.gd
```

---

## Mission 056 — Living Iris Archive Foundation

Date: 2026-07-18
Scope: first persistent Living Archive proof. Existing `WitnessProfile.moment_records` remains the save authority, and `WitnessArchive` remains the public Archive authority.

### Implemented

- Added a read-only `LivingArchiveProjection` behind new `WitnessArchive.recovered_truth_fragments()` and `WitnessArchive.chapter_blooms()` APIs. It derives fragment and Chapter Bloom state from existing persisted moment records; it stores no separate data.
- Extended `IrisEvolutionProfile` with archive-derived recovered-fragment and chapter-bloom presentation values.
- Extended `IrisEvolutionVisualConsumer` and `LivingIris` with a permanent recovered-memory layer: a warm internal fragment detail, increased glow/fiber response, and a Chapter 01 bloom arc. The first completion remains visible after return and after relaunch because it is derived from the profile record.
- Added transient `LivingIris.absorb_truth_fragment()` feedback for the completion moment. Application calls it after the existing profile record succeeds, then uses the existing dialogue/audio/haptic `truth_fragment_absorbed` path.
- Extended `SpatialHub.Background_Constellation` to derive nodes from `WitnessArchive`: recovered entries carry fragment identity, display state, chapter metadata, and a distinct gold Truth Fragment presentation. WM-001 appears as **Borrowed Light** when recovered.
- Added Chapter 01 bloom data foundation (`WM_001`–`WM_005` membership) while proving only `Borrowed Light`.
- Updated the Hub profile/hint language to show recovered fragment count and Chapter 01 bloom state without changing navigation.
- Added `tests/living_archive_validation.gd` for persistence, fragment identity, Chapter Bloom, Iris visual projection, constellation metadata, and WM-002–WM-012 compatibility.

### Limitations

- This is a first persistent visual language, not the final constellation/archive UI.
- Only Chapter 01 membership is defined; future chapters can add data without changing persistence or Iris projection.
- The internal Iris detail and bloom are procedural prototype effects; final art direction and richer archive interactions remain later work.

Run when Godot is available:

```bash
cd the_iris
godot --headless -s tests/living_archive_validation.gd
```

---

## Mission 057 — Living Archive Experience Integration

Date: 2026-07-18
Scope: make the existing Living Archive meaningful in the player experience without adding a save system, progression framework, navigation route, or Witness content.

### Implemented

- Added `LivingArchiveProjection.presentation_state()` and the public `WitnessArchive.living_presentation()` API. It derives `awareness_level`, `recovered_fragment_count`, `confirmed_truth_count`, `memory_stability`, and `relationship_state` exclusively from existing profile/archive records.
- Extended `IrisEvolutionProfile` with those derived relationship presentation values and fed them through the existing `IrisEvolutionVisualConsumer`.
- Extended `LivingIris` with subtle temporary responses: `unsettled`, `stabilized`, and `remembering`. They affect brief breathing cadence, color temperature/arc treatment, and response rhythm while permanent evolution remains profile-derived.
- Connected existing generic Witness discovery/synchronization events through Application to the one Living Iris instance. False details briefly unsettle it; discovery and successful stabilization make it respond without new gameplay ownership.
- Reframed Spatial Hub relationship text around what the Iris remembers instead of raw progression data. Recovered constellation nodes remain Archive-derived and preserve fragment identity/chapter metadata.
- Extended the existing Archive UI—no new route—with recovered-memory inspection. Selecting WM-001 after recovery presents **Borrowed Light**, its Chapter 01 association, restored truth, and the Iris reflection. Inspecting it triggers the existing Iris personality/audio/haptic path and a subtle remembering response behind the translucent Archive.
- Added data-driven `archive_fragment_viewed` Iris reflection event.
- Added `tests/living_archive_experience_validation.gd` covering fresh profiles, recovered/multiple fragment derivation, serialization persistence, constellation identity, Iris response hooks, Archive inspection wiring, and WM-002–WM-012 compatibility.

### Limitations

- Archive inspection is a focused first interaction for recovered fragments, not a full archive encyclopedia or constellation UI overhaul.
- Relationship state is currently derived from fragment count, chapter bloom, and recorded stability; its authored emotional range will expand only as additional real fragments exist.
- Iris response visuals are subtle procedural presentation and require real device tuning for timing, contrast, audio mix, and accessibility.

Run when Godot is available:

```bash
cd the_iris
godot --headless -s tests/living_archive_experience_validation.gd
```

---

## Mission 058 — WM-002 Production Migration Pass

Date: 2026-07-18
Scope: author `WM_002` / *The Forgotten Museum* through the established Living Iris 4.0 production contract. No new gameplay, persistence, progression, navigation, Archive, or chapter system was added.

### Production audit

Before authoring, confirmed WM-002 already had a distinct museum corridor/action/palm-reveal asset triplet, existing evidence/revelation content, museum ambience, and a valid legacy anomaly/capture definition. It lacked authored Fracture, stability, showcase, Truth Fragment, Iris guidance/reflection, and manifest cue data.

Detailed audit: `MISSION_058_WM002_PRODUCTION_AUDIT.md`.

### Implemented

- Authored WM-002 Fracture `inherited_warmth`: museum glass remembers Arthur's warmth before he touches it.
- Authored WM-002 stability pressure, 1.18-second synchronization hold, investigation false leads, and existing Iris audio/haptic guidance hooks.
- Authored optional showcase pacing and cool museum atmosphere values through existing `showcase` data. The generic renderer now reads authored light/mote color values; WM-001 preserves its current defaults.
- Authored Truth Fragment **Inherited Warmth** (`fragment_inherited_warmth`) with recovered-memory summary, truth statement, revelation, Archive entry, Iris reflection, and reflection event.
- Added WM-002 observation, fracture, synchronization, revelation, and Archive reflection dialogue events using existing Iris audio/haptic/expression architecture.
- Added `tests/wm002_production_validation.gd` covering loader/runtime contract, authored audio/events, Archive persistence/projection, Chapter 01 membership, serialization, and WM-001 / WM-003–WM-012 compatibility.

### Limitations

- WM-002 uses existing museum assets and procedural showcase atmosphere; final scene animation, bespoke shaders, and device-tuned pacing remain future production polish.
- The existing generic runtime supports one active Fracture; this migration intentionally does not expand that system.

Run when Godot is available:

```bash
cd the_iris
godot --headless -s tests/wm002_production_validation.gd
```

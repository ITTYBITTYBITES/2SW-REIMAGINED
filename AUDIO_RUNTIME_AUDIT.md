# AUDIO_RUNTIME_AUDIT.md

Mission: **053C — Living Iris Production Audio Identity Pass**  
Date: 2026-07-18  
Project root: `the_iris/`

## Scope

This audit covers the current audio runtime after Mission 053B validation and the Mission 053C production identity pass.

Inspected areas:

- `the_iris/scripts/iris/IrisAudioConsumer.gd`
- runtime audio calls in `Application.gd`
- Living Iris intent routing through `IrisPersonalityResolver` / `IrisController`
- hub and navigation UI audio calls
- Witness chapter navigation audio calls
- Generic Witness runtime audio hooks
- Witness JSON manifests under `the_iris/content/witness/`
- validation tests under `the_iris/tests/`
- audio files under `the_iris/assets/audio/`

This is an audio integration audit only. No UI redesign, gameplay redesign, or Witness Engine architecture change was performed.

---

## DONE — Current Audio System State

### Audio runtime owner

`IrisAudioConsumer.gd` remains the central audio consumer.

Current supported paths:

- `play_manifest_sound(path)` — safe one-shot playback with missing-file fallback.
- `play_presence_sound(event_name)` — maps named Iris presence events to production audio paths.
- `play_ambient_loop(path)` — persistent loop player for ambient audio.
- `stop_ambient_loop()` — cleanup for active ambient loop.
- `consume(intent)` — resolves direct audio paths or expression modes from Iris response intents.

No new audio manager layer was introduced. Mission 053C reused the repaired Mission 053A runtime instead of redesigning it.

### Production folder structure

Created and populated:

```text
the_iris/assets/audio/
├── environments/
├── iris/
├── navigation/
├── test/
├── ui/
└── witness/
```

Validation sounds from Mission 053B were retained but moved to:

```text
the_iris/assets/audio/test/
├── test_ambient_loop.ogg
├── test_resolution.ogg
└── test_ui_click.wav
```

Those test assets are no longer referenced by runtime manifests or gameplay/navigation scripts. They remain only for automated validation coverage.

### Living Iris presence and expression events

`IrisAudioConsumer.PRESENCE_AUDIO` now resolves to production identity files:

| Event | Production file |
|---|---|
| `iris_awaken` | `res://assets/audio/iris/iris_awaken.ogg` |
| `hub_return` | `res://assets/audio/iris/iris_presence.ogg` |
| `idle` | `res://assets/audio/iris/iris_breath_loop.ogg` |
| `evolution_detected` | `res://assets/audio/iris/iris_transition.ogg` |
| `new_aperture_reached` | `res://assets/audio/iris/iris_confirm.ogg` |

Expression-mode routing now resolves:

| Expression mode | Production file |
|---|---|
| `INTRODUCING` | `res://assets/audio/iris/iris_focus.ogg` |
| `IDLE` | `res://assets/audio/iris/iris_breath_loop.ogg` |
| `CURIOUS` | `res://assets/audio/iris/iris_attention.ogg` |
| `ATTENTIVE` | `res://assets/audio/iris/iris_attention.ogg` |
| `GUIDING` | `res://assets/audio/iris/iris_focus.ogg` |
| `REFLECTIVE` | `res://assets/audio/iris/iris_presence.ogg` |

### Navigation and hub audio events

Current navigation/hub events now resolve to production assets:

| Runtime event | File |
|---|---|
| Home: Rest with Iris | `res://assets/audio/navigation/ui_click.ogg` |
| Home: Open Archive | `res://assets/audio/navigation/ui_click.ogg` |
| Home: Chapter Portal | `res://assets/audio/navigation/portal_open.ogg` |
| Memory shard hover | `res://assets/audio/ui/shard_hover.ogg` |
| Chapter card selected | `res://assets/audio/navigation/chapter_enter.ogg` |
| Chapter action advance | `res://assets/audio/navigation/ui_click.ogg` |
| Chapter back / portal close | `res://assets/audio/navigation/portal_close.ogg` |
| Archive card click | `res://assets/audio/navigation/ui_click.ogg` |
| Archive back | `res://assets/audio/navigation/portal_close.ogg` |
| Chapter / moment complete reward | `res://assets/audio/navigation/chapter_complete.ogg` |

### Generic Witness runtime audio events

`GenericWitnessGameplay.gd` now has production audio hooks for the existing gameplay loop:

| Gameplay event | File |
|---|---|
| Ambient start | manifest `audio_assets.ambient` |
| Observation phase starts | `res://assets/audio/witness/observation_start.ogg` |
| Incorrect anomaly tap / misstep | `res://assets/audio/witness/incorrect_detection.ogg` |
| Correct anomaly detection | manifest `audio_assets.anomaly` |
| Review phase starts | `res://assets/audio/witness/recall_start.ogg` |
| Context/reveal phase starts | `res://assets/audio/witness/reveal.ogg` |
| Evidence/clue locked | `res://assets/audio/witness/memory_lock.ogg` |
| Resolution phase starts | manifest `audio_assets.resolution` |
| Reward presentation | `res://assets/audio/navigation/chapter_complete.ogg` |
| Return/close | `stop_ambient_loop()` |

### Witness manifest audio references

All production Witness manifests that declare audio now point to existing production assets.

Replaced removed/temporary references:

- `res://assets/audio/test_ambient_loop.ogg`
- `res://assets/audio/test_resolution.ogg`
- per-moment missing paths such as `wm001_ambient.ogg`, `wm002_resolution.ogg`, etc.
- `res://assets/audio/fm001_ambient.ogg`, `fm001_anomaly.ogg`, `fm001_resolution.ogg`

Current manifest strategy:

- ambient paths use one of the four environment foundation loops.
- anomaly paths use `res://assets/audio/witness/correct_detection.ogg`.
- resolution paths use `res://assets/audio/witness/resolution.ogg`.

This gives all current content a working production-safe audio path without pretending each moment has a final bespoke soundscape.

---

## DONE — Current Production Audio Library

Mission 053C created a coherent first-pass Living Iris sonic language:

- organic sine/partial clusters
- soft membrane-like transients
- low biological pulse loops
- restrained room-tone environment foundations
- no harsh sci-fi lasers, alarms, or UI bleeps
- mono 44.1 kHz OGG Vorbis assets for mobile-safe playback
- low file sizes suitable for Android prototype builds

See `PRODUCTION_AUDIO_INVENTORY.md` for file-level inventory.

---

## Current Placeholder Assets

These are production-safe placeholders, not final bespoke score/sound design:

| Placeholder | Role |
|---|---|
| `museum_ambient.ogg` | reusable museum/archive room tone |
| `canvas_room_ambient.ogg` | reusable studio/canvas room tone |
| `performance_ambient.ogg` | reusable performance/stage memory tone |
| `reactor_ambient.ogg` | reusable low mechanical/reactor tone |

They are intentionally subtle and loopable. They prevent silent/broken runtime paths while future chapters receive bespoke identity passes.

---

## Missing Assets / Remaining Audio Gaps

### No missing files for current runtime references

Static validation found **0 missing referenced audio files** in:

- production scripts
- Witness content manifests
- generated production inventory
- retained validation test folder

### Remaining gaps are creative/compositional, not broken references

1. **No bespoke per-moment soundtrack yet.**  
   `WM_001` through `WM_012` and `FM_001` reuse the production foundation library. That is intentional for this pass.

2. **Legacy custom gameplay classes still are not independently audio-rich.**  
   `WM001GameplayLoop.gd` and `FlagshipWitnessMoment.gd` still do not have the same direct audio event coverage as `GenericWitnessGameplay.gd`. Current app flow routes chapter launches and FM_001 through `GenericWitnessGameplay`, but the legacy classes remain a future cleanup/wiring target if they are kept.

3. **Startup splash itself is still silent.**  
   `Application._on_startup_finished()` plays `iris_awaken` after `StartupFlow` finishes. No audio was added inside `StartupFlow.gd`.

4. **No device speaker mix check was possible in this sandbox.**  
   File integrity and references were validated with Python. Godot CLI/runtime and Android device playback were not available here.

5. **The Living Iris identity is first-pass, not final commercial audio.**  
   The layer is coherent and usable, but future polish should include human listening review, loudness balancing on device speakers, and bespoke chapter scoring.

---

## Production Requirements Going Forward

Future production audio work should keep these constraints:

- Preserve `IrisAudioConsumer` fallback safety.
- Keep validation assets in `assets/audio/test/`; do not reference them from runtime content.
- Use OGG Vorbis for loops, ambiences, and tonal cues.
- Use WAV only when a short UI sound truly needs uncompressed transient detail.
- Keep mobile size budgets small.
- Normalize peaks conservatively; avoid clipping and harsh high-frequency material.
- Mark loop assets as looping in `.import` metadata and through `play_ambient_loop()`.
- Add bespoke per-moment assets by updating manifest `audio_assets`, not by branching gameplay logic.
- Keep DONE and REMAINING clearly separated in reports.

---

## Validation Summary

Static validation performed in sandbox:

- production audio files exist: **pass**
- local `.import` metadata generated but not committed due to existing `the_iris/.gitignore`: **not tracked by repo convention**
- OGG/WAV files readable by `soundfile`: **pass**
- mono 44.1 kHz format: **pass**
- referenced runtime paths exist: **pass**
- Witness manifest audio paths exist: **pass**
- runtime manifests no longer reference Mission 053B test assets: **pass**

Godot CLI validation:

- `godot --headless -s tests/audio_production_validation.gd`: **not run** — Godot executable is not installed in this sandbox.
- Godot `.import` sidecars are ignored by the project; Godot should regenerate them in an editor/import environment.

Android/device validation:

- **not run** — requires Godot export/device environment.

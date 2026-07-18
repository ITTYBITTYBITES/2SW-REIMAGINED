# MISSION 053 — AUDIO ASSET INVENTORY

Full audit of the audio system in Two Second Witness.

Date: 2026-07-18
Scope: Every code path that references a sound file or triggers audio playback.

---

## 1. EXISTING AUDIO TRIGGER CODE PATHS

Every location in the codebase that calls audio playback is listed below.
Each entry shows the file, line/function, the trigger condition, and the expected asset path.

### 1.1. IrisAudioConsumer (core audio routing)

| Method | Trigger | Path Called |
| :--- | :--- | :--- |
| `play_manifest_sound()` | Any caller passes a path | Dynamic — resolves caller-provided path |
| `play_presence_sound("hub_return")` | Hub return / settle | No file path — logs placeholder only |
| `play_presence_sound("idle")` | Idle presence loop | No file path — logs placeholder only |
| `play_presence_sound("evolution_detected")` | Stage evolution event | No file path — logs placeholder only |
| `play_presence_sound("new_aperture_reached")` | Rank promotion | No file path — logs placeholder only |
| `consume()` → `_play_introduction_tone()` | IrisResponseIntent with INTRODUCING | No file path — logs placeholder only |
| `consume()` → `_play_curious_tone()` | IrisResponseIntent with CURIOUS | No file path — logs placeholder only |
| `consume()` → `_play_attentive_tone()` | IrisResponseIntent with ATTENTIVE | No file path — logs placeholder only |
| `consume()` → `_play_guiding_tone()` | IrisResponseIntent with GUIDING | No file path — logs placeholder only |
| `consume()` → `_play_reflective_tone()` | IrisResponseIntent with REFLECTIVE | No file path — logs placeholder only |
| `consume()` → `_play_fallback_tone()` | Unknown expression mode | No file path — logs placeholder only |

**Note:** `IrisAudioConsumer` also defines an `AUDIO_ASSETS` constant dictionary mapping keys to paths. These paths are **never called** by any code path in the repository — they are dead references in a lookup table that no consumer reads.

The constant `AUDIO_ASSETS` maps:
- `iris_introducing_audio` → `res://assets/audio/iris_intro.ogg`
- `iris_curious_audio` → `res://assets/audio/iris_curious.ogg`
- `iris_attentive_audio` → `res://assets/audio/iris_attentive.ogg`
- `iris_guiding_audio` → `res://assets/audio/iris_guiding.ogg`
- `iris_reflective_audio` → `res://assets/audio/iris_reflective.ogg`

**None of these are ever loaded or played by any code path.**

### 1.2. Application.gd (application-level triggers)

| Event | Code Call | Asset Path |
| :--- | :--- | :--- |
| Hub return / settle | `IrisAudioConsumer.play_presence_sound("hub_return")` | No file — print-only fallback |
| Evolution detected | `IrisAudioConsumer.play_presence_sound("evolution_detected")` | No file — print-only fallback |
| New aperture reached | `IrisAudioConsumer.play_presence_sound("new_aperture_reached")` | No file — print-only fallback |

### 1.3. MemoryField.gd (hub memory shard)

| Event | Code Call | Asset Path |
| :--- | :--- | :--- |
| Shard hover focus | `IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui_shard_hover.ogg")` | `res://assets/audio/ui_shard_hover.ogg` |

### 1.4. WitnessArchiveUI.gd (archive navigation)

| Event | Code Call | Asset Path |
| :--- | :--- | :--- |
| Archive card press | `IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui_click.wav")` | `res://assets/audio/ui_click.wav` |
| Back button | `IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui_back.wav")` | `res://assets/audio/ui_back.wav` |

### 1.5. GenericWitnessGameplay.gd (generic WM loop)

| Event | Code Call | Asset Path |
| :--- | :--- | :--- |
| Moment launch (ambient) | `IrisAudioConsumer.play_manifest_sound(ambient_path)` | Reads from JSON `asset_manifest.audio_assets.ambient` |
| Anomaly found | `IrisAudioConsumer.play_manifest_sound(anomaly_path)` | Reads from JSON `asset_manifest.audio_assets.anomaly` |
| Resolution phase entry | `IrisAudioConsumer.play_manifest_sound(resolution_path)` | Reads from JSON `asset_manifest.audio_assets.resolution` |
| Misstep / wrong click | `IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui_misstep_error.wav")` | `res://assets/audio/ui_misstep_error.wav` |
| Evidence attuned | `IrisAudioConsumer.play_manifest_sound("res://assets/audio/ui_clue_attuned.wav")` | `res://assets/audio/ui_clue_attuned.wav` |

### 1.6. WitnessAssetResolver.gd (sound path validation)

| Method | Purpose | Notes |
| :--- | :--- | :--- |
| `resolve_sound_path()` | Validates audio file existence | Returns empty string on missing file |

**Status:** Exists but is **never called** by any other script. Dead code.

### 1.7. WM001GameplayLoop.gd and FlagshipWitnessMoment.gd

**Status:** Neither file contains any audio trigger calls. The WM001 and flagship gameplay loops are completely silent — they do not call `play_manifest_sound()`, `play_presence_sound()`, or `IrisAudioConsumer` at all. All Witness audio routing runs exclusively through `GenericWitnessGameplay.gd`.

---

## 2. MANIFEST-REFERENCED AUDIO PATHS

All Witness Moment JSON definitions in `content/witness/` declare audio paths in their `asset_manifest.audio_assets` object.

| Moment | ambient | anomaly | resolution |
| :--- | :--- | :--- | :--- |
| WM_001 | `res://assets/audio/wm001_ambient.ogg` | `res://assets/audio/wm001_anomaly.ogg` | `res://assets/audio/wm001_resolution.ogg` |
| WM_002 | `res://assets/audio/wm002_ambient.ogg` | `res://assets/audio/wm002_anomaly.ogg` | `res://assets/audio/wm002_resolution.ogg` |
| WM_003 | `res://assets/audio/wm003_ambient.ogg` | `res://assets/audio/wm003_anomaly.ogg` | `res://assets/audio/wm003_resolution.ogg` |
| WM_004 | `res://assets/audio/wm004_ambient.ogg` | `res://assets/audio/wm004_anomaly.ogg` | `res://assets/audio/wm004_resolution.ogg` |
| WM_005 | `res://assets/audio/wm005_ambient.ogg` | `res://assets/audio/wm005_anomaly.ogg` | `res://assets/audio/wm005_resolution.ogg` |

**All 15 Witness Moment audio files are physically missing.** The `asset_manifest.audio_assets` paths are valid in JSON but point to files that do not exist on disk.

---

## 3. MISSING PHYSICAL ASSETS

### 3.1. UI Sounds (hardcoded in gameplay scripts)

| File | Expected Path | Status |
| :--- | :--- | :--- |
| `ui_shard_hover.ogg` | `res://assets/audio/ui_shard_hover.ogg` | **MISSING** |
| `ui_click.wav` | `res://assets/audio/ui_click.wav` | **MISSING** |
| `ui_back.wav` | `res://assets/audio/ui_back.wav` | **MISSING** |
| `ui_clue_attuned.wav` | `res://assets/audio/ui_clue_attuned.wav` | **MISSING** |
| `ui_misstep_error.wav` | `res://assets/audio/ui_misstep_error.wav` | **MISSING** |

### 3.2. Witness Moment Audio (declared in JSON manifests)

| File | Expected Path | Status |
| :--- | :--- | :--- |
| `wm001_ambient.ogg` | `res://assets/audio/wm001_ambient.ogg` | **MISSING** |
| `wm001_anomaly.ogg` | `res://assets/audio/wm001_anomaly.ogg` | **MISSING** |
| `wm001_resolution.ogg` | `res://assets/audio/wm001_resolution.ogg` | **MISSING** |
| `wm002_ambient.ogg` | `res://assets/audio/wm002_ambient.ogg` | **MISSING** |
| `wm002_anomaly.ogg` | `res://assets/audio/wm002_anomaly.ogg` | **MISSING** |
| `wm002_resolution.ogg` | `res://assets/audio/wm002_resolution.ogg` | **MISSING** |
| `wm003_ambient.ogg` | `res://assets/audio/wm003_ambient.ogg` | **MISSING** |
| `wm003_anomaly.ogg` | `res://assets/audio/wm003_anomaly.ogg` | **MISSING** |
| `wm003_resolution.ogg` | `res://assets/audio/wm003_resolution.ogg` | **MISSING** |
| `wm004_ambient.ogg` | `res://assets/audio/wm004_ambient.ogg` | **MISSING** |
| `wm004_anomaly.ogg` | `res://assets/audio/wm004_anomaly.ogg` | **MISSING** |
| `wm004_resolution.ogg` | `res://assets/audio/wm004_resolution.ogg` | **MISSING** |
| `wm005_ambient.ogg` | `res://assets/audio/wm005_ambient.ogg` | **MISSING** |
| `wm005_anomaly.ogg` | `res://assets/audio/wm005_anomaly.ogg` | **MISSING** |
| `wm005_resolution.ogg` | `res://assets/audio/wm005_resolution.ogg` | **MISSING** |

### 3.3. Iris Presence Sounds (dead constants in AUDIO_ASSETS)

| File | Expected Path | Status |
| :--- | :--- | :--- |
| `iris_intro.ogg` | `res://assets/audio/iris_intro.ogg` | **MISSING** — and no code path loads it |
| `iris_curious.ogg` | `res://assets/audio/iris_curious.ogg` | **MISSING** — and no code path loads it |
| `iris_attentive.ogg` | `res://assets/audio/iris_attentive.ogg` | **MISSING** — and no code path loads it |
| `iris_guiding.ogg` | `res://assets/audio/iris_guiding.ogg` | **MISSING** — and no code path loads it |
| `iris_reflective.ogg` | `res://assets/audio/iris_reflective.ogg` | **MISSING** — and no code path loads it |

### 3.4. Iris Presence Helper Events (print-only, no file path)

| Event Name | Status |
| :--- | :--- |
| `hub_return` | **No audio file path defined.** Only a `print()` call exists. |
| `idle` | **No audio file path defined.** Only a `print()` call exists. |
| `evolution_detected` | **No audio file path defined.** Only a `print()` call exists. |
| `new_aperture_reached` | **No audio file path defined.** Only a `print()` call exists. |

---

## 4. REQUIRED FILE LOCATIONS

All audio files go in a single flat directory:

```
the_iris/assets/audio/
```

The directory now exists in the repository (created this mission).
Physical `.ogg` / `.wav` files must be placed here to match the `res://assets/audio/` paths that the code and JSON manifests already reference.

No code changes are needed for integration — `IrisAudioConsumer.play_manifest_sound()` already handles `FileAccess.file_exists()` checks and will load and play any valid `AudioStream` placed at these paths.

---

## 5. SUMMARY COUNTS

| Category | Count | Status |
| :--- | :---: | :--- |
| UI sound files referenced by code | 5 | 0 exist |
| Witness Moment audio files in JSON manifests | 15 | 0 exist |
| Iris presence files in dead constant | 5 | 0 exist (and unreachable by code) |
| Iris presence events (print-only) | 4 | No path defined, no file expected |
| Dead code references (`AUDIO_ASSETS` dict, `resolve_sound_path`) | 2 | Never called |
| `WM001GameplayLoop.gd` audio triggers | 0 | Silent — no audio integration |
| `FlagshipWitnessMoment.gd` audio triggers | 0 | Silent — no audio integration |
| **Total physical audio files needed for code-path triggers** | **20** | **0 exist** |
| **Total physical audio files to make this a hearing game** | **25** | **0 exist** |

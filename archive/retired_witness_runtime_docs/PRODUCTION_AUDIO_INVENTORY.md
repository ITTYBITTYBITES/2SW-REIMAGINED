# PRODUCTION_AUDIO_INVENTORY.md

Mission: **053C — Living Iris Production Audio Identity Pass**  
Date: 2026-07-18

## Summary

Mission 053C adds the first coherent production audio foundation for the prototype.

This is **not** a final soundtrack and does **not** complete all future chapter audio. It replaces validation sounds with a reusable Living Iris identity layer that current runtime hooks can resolve.

Production library count:

- **24 production audio files**
- **23 required Mission 053C files** created
- **1 additional runtime support file** created: `ui/shard_hover.ogg`
- **3 validation files retained** under `assets/audio/test/`

All production files are:

- OGG Vorbis
- mono
- 44.1 kHz
- small enough for mobile prototype use
- source assets that Godot can import/regenerate on open

---

## Sonic Identity Direction

The Living Iris first-pass identity is designed to be:

- organic
- intelligent
- subtle
- biological
- non-cliché sci-fi
- aligned with a living perception system rather than a mechanical computer UI

The asset design favors:

- soft membrane-like clicks
- low biological pulses
- harmonic partial clusters
- restrained tonal blooms
- quiet room-tone foundations
- gentle confirmation cues rather than loud reward stingers

---

## Production Audio Files

| File | Duration | Format | Size |
|---|---:|---|---:|
| `res://assets/audio/environments/canvas_room_ambient.ogg` | 8.00s | 44.1 kHz mono OGG | 14.5 KiB |
| `res://assets/audio/environments/museum_ambient.ogg` | 8.00s | 44.1 kHz mono OGG | 15.0 KiB |
| `res://assets/audio/environments/performance_ambient.ogg` | 8.00s | 44.1 kHz mono OGG | 14.8 KiB |
| `res://assets/audio/environments/reactor_ambient.ogg` | 8.00s | 44.1 kHz mono OGG | 14.7 KiB |
| `res://assets/audio/iris/iris_attention.ogg` | 0.55s | 44.1 kHz mono OGG | 5.2 KiB |
| `res://assets/audio/iris/iris_awaken.ogg` | 2.40s | 44.1 kHz mono OGG | 7.8 KiB |
| `res://assets/audio/iris/iris_breath_loop.ogg` | 4.00s | 44.1 kHz mono OGG | 9.3 KiB |
| `res://assets/audio/iris/iris_confirm.ogg` | 0.52s | 44.1 kHz mono OGG | 5.4 KiB |
| `res://assets/audio/iris/iris_focus.ogg` | 0.75s | 44.1 kHz mono OGG | 4.8 KiB |
| `res://assets/audio/iris/iris_presence.ogg` | 6.00s | 44.1 kHz mono OGG | 12.0 KiB |
| `res://assets/audio/iris/iris_transition.ogg` | 1.15s | 44.1 kHz mono OGG | 5.7 KiB |
| `res://assets/audio/navigation/chapter_complete.ogg` | 1.55s | 44.1 kHz mono OGG | 6.6 KiB |
| `res://assets/audio/navigation/chapter_enter.ogg` | 1.00s | 44.1 kHz mono OGG | 6.2 KiB |
| `res://assets/audio/navigation/portal_close.ogg` | 0.85s | 44.1 kHz mono OGG | 5.2 KiB |
| `res://assets/audio/navigation/portal_open.ogg` | 1.25s | 44.1 kHz mono OGG | 6.1 KiB |
| `res://assets/audio/navigation/ui_click.ogg` | 0.10s | 44.1 kHz mono OGG | 4.2 KiB |
| `res://assets/audio/ui/shard_hover.ogg` | 0.16s | 44.1 kHz mono OGG | 4.3 KiB |
| `res://assets/audio/witness/correct_detection.ogg` | 0.74s | 44.1 kHz mono OGG | 6.0 KiB |
| `res://assets/audio/witness/incorrect_detection.ogg` | 0.48s | 44.1 kHz mono OGG | 4.4 KiB |
| `res://assets/audio/witness/memory_lock.ogg` | 0.58s | 44.1 kHz mono OGG | 5.4 KiB |
| `res://assets/audio/witness/observation_start.ogg` | 1.00s | 44.1 kHz mono OGG | 5.1 KiB |
| `res://assets/audio/witness/recall_start.ogg` | 1.05s | 44.1 kHz mono OGG | 5.3 KiB |
| `res://assets/audio/witness/resolution.ogg` | 2.05s | 44.1 kHz mono OGG | 7.4 KiB |
| `res://assets/audio/witness/reveal.ogg` | 1.45s | 44.1 kHz mono OGG | 6.2 KiB |

---

## Living Iris Core

| Asset | Runtime role |
|---|---|
| `iris/iris_awaken.ogg` | boot completion / Iris awakening |
| `iris/iris_breath_loop.ogg` | IDLE expression route / breathing identity layer |
| `iris/iris_focus.ogg` | INTRODUCING and GUIDING expression route |
| `iris/iris_attention.ogg` | CURIOUS and ATTENTIVE expression route |
| `iris/iris_confirm.ogg` | aperture/rank confirmation |
| `iris/iris_transition.ogg` | evolution transition cue |
| `iris/iris_presence.ogg` | hub return and reflective presence cue |

Loop-capable identity assets:

- `iris_breath_loop.ogg`
- `iris_presence.ogg`

---

## Navigation

| Asset | Runtime role |
|---|---|
| `navigation/ui_click.ogg` | hub button click, archive card click, chapter action advance |
| `navigation/portal_open.ogg` | Chapter Portal button from Iris Home |
| `navigation/portal_close.ogg` | back/close from chapter portal or archive |
| `navigation/chapter_enter.ogg` | selecting a Witness Moment from chapter list |
| `navigation/chapter_complete.ogg` | reward/completion presentation |

---

## Witness Runtime

| Asset | Runtime role |
|---|---|
| `witness/observation_start.ogg` | observation phase begins |
| `witness/memory_lock.ogg` | evidence/clue attuned, legacy attunement action |
| `witness/recall_start.ogg` | review/timeline phase starts |
| `witness/correct_detection.ogg` | anomaly detection cue via manifest `audio_assets.anomaly` |
| `witness/incorrect_detection.ogg` | incorrect anomaly tap / misstep |
| `witness/reveal.ogg` | context/reveal phase begins |
| `witness/resolution.ogg` | resolution cue via manifest `audio_assets.resolution` |

---

## Environment Foundation

| Asset | Loop | Current manifest usage |
|---|---|---|
| `environments/museum_ambient.ogg` | yes | museum/archive-like moments |
| `environments/canvas_room_ambient.ogg` | yes | canvas, letter, sundial, FM_001 foundation |
| `environments/performance_ambient.ogg` | yes | performance / bell / waterfall foundation |
| `environments/reactor_ambient.ogg` | yes | reactor foundation |

These are intentionally reusable placeholders. They are production-safe but not final bespoke moment ambiences.

---

## Validation Assets Retained

Validation files were moved to `res://assets/audio/test/`:

| File | Purpose |
|---|---|
| `test/test_ui_click.wav` | Mission 053B WAV one-shot validation |
| `test/test_ambient_loop.ogg` | Mission 053B OGG loop validation |
| `test/test_resolution.ogg` | Mission 053B OGG one-shot validation |

Runtime scripts and Witness manifests should not reference these files. They remain only for `audio_runtime_validation.gd` and regression testing.

---

## Import / Loop Notes

Local `.ogg.import` sidecars were generated during the pass, but this repository intentionally ignores `*.import` files in `the_iris/.gitignore`. The committed contract is the source OGG library plus runtime loop enforcement.

Loop-capable source assets:

- `iris/iris_breath_loop.ogg`
- `iris/iris_presence.ogg`
- `environments/museum_ambient.ogg`
- `environments/canvas_room_ambient.ogg`
- `environments/performance_ambient.ogg`
- `environments/reactor_ambient.ogg`

`IrisAudioConsumer.play_ambient_loop()` defensively enables looping for `AudioStreamOggVorbis`, so loop behavior is protected when Godot regenerates import metadata.

---

## Remaining Inventory Gaps

DONE:

- current runtime hooks resolve
- validation sounds are no longer heard in normal runtime paths
- all manifest audio paths point to existing production files
- first Living Iris sonic language exists

REMAINING:

- no bespoke per-Witness-Moment soundtrack yet
- no final mastered mix pass
- no Android hardware speaker test yet
- no Godot editor import/load verification in this sandbox
- legacy custom gameplay classes still need audio parity if they remain active paths

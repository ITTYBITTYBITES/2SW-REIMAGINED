# Chapter 01 Asset Production Audit

This audit outlines the visual and auditory production standards, requirements, and mappings established for the five moments of Chapter 01: "The First Fractures". Each moment is visually structured through a standardized `WitnessAssetManifest` block.

---

## 1. Production Asset Schema Requirements
The asset pipeline enforces structured JSON data inputs to map experiences procedurally.

```text
WitnessAssetManifest
├── environment_asset       # Background scene path
├── background_layers       # Array of layer assets
├── evidence_assets         # Custom visuals & colors per clue button
├── audio_assets            # Ambient, Anomaly, and Resolution audio
├── visual_effects          # Sinnusoidal breathing and drift speeds
└── lighting_profile        # Room atmosphere color modulation Tints
```

---

## 2. Momement-by-Moment Production Assets Mapping

### 2.1. WM_001 — The Unfinished Canvas
- **Environment Backdrop:** `wm_001_studio_background.png`
- **Lighting Profile Tint:** `"#f2ebd5"` (warm, late-afternoon sunlit gold)
- **Atmosphere:** Soft sunlit painter's studio
- **Evidence Visuals:**
  - `paused_brush` (`#8de8c7` - teal highlight icon)
  - `crystal_prism` (`#8ee9c8` - light green icon)
  - `color_notes` (`#8fc8b8` - medium slate green icon)
- **Audio Requirements:**
  - `ambient`: `wm001_ambient.ogg` (soft rustling canvas)
  - `anomaly`: `wm001_anomaly.ogg` (prism refraction frequency)
  - `resolution`: `wm001_resolution.ogg` (satisfying composition chord)

### 2.2. WM_002 — The Forgotten Museum
- **Environment Backdrop:** `wm_002_museum_corridor.png`
- **Lighting Profile Tint:** `"#dccbb7"` (antique brown and deep mahogany)
- **Atmosphere:** Dusty, quiet, wood-paneled exhibit hall
- **Evidence Visuals:**
  - `pocket_watch` (`#caa48e` - warm copper icon)
  - `case_frame` (`#b68e71` - medium brown oak icon)
  - `ticket` (`#a37e5c` - deep sepia paper icon)
- **Audio Requirements:**
  - `ambient`: `wm002_ambient.ogg` (distant clock ticks)
  - `anomaly`: `wm002_anomaly.ogg` (subtle spatial glass touch chime)
  - `resolution`: `wm002_resolution.ogg` (warm string crescendo)

### 2.3. WM_003 — The Last Performance
- **Environment Backdrop:** `wm_003_dressing_room.png`
- **Lighting Profile Tint:** `"#c3b1e3"` (deep violet and stage light velvet)
- **Atmosphere:** Quiet, backstage theatrical dressing room
- **Evidence Visuals:**
  - `violin_bow` (`#a98ec5` - violet satin icon)
  - `telegram_desk` (`#9476ab` - lavender ink icon)
  - `travel_case` (`#825d94` - dark plum brass case icon)
- **Audio Requirements:**
  - `ambient`: `wm003_ambient.ogg` (hollow concert hall applause tail)
  - `anomaly`: `wm003_anomaly.ogg` (unlatching mechanical metallic click)
  - `resolution`: `wm003_resolution.ogg` (sustained solo violin vibrato)

### 2.4. WM_004 — The Faulty Reactor
- **Environment Backdrop:** `wm_004_cleanroom_console.png`
- **Lighting Profile Tint:** `"#a2ebd6"` (sterile cyan and cold laboratory white)
- **Atmosphere:** Cleanroom nuclear laboratory console display
- **Evidence Visuals:**
  - `calibration_key` (`#8ee9c8` - light diagnostic green icon)
  - `quartz_grid` (`#78d4ab` - laboratory cyan icon)
  - `laser_sensor` (`#5ebf91` - cobalt laser indicator icon)
- **Audio Requirements:**
  - `ambient`: `wm004_ambient.ogg` (steady computer cooling fan hum)
  - `anomaly`: `wm004_anomaly.ogg` (stretching crystal grid frequency)
  - `resolution`: `wm004_resolution.ogg` (clean digital diagnostic boot sweep)

### 2.5. WM_005 — The Witness
- **Environment Backdrop:** `wm_005_internal_stroma.png`
- **Lighting Profile Tint:** `"#a7b8eb"` (cobalt biological stroma blue)
- **Atmosphere:** Microscopic internal stroma iris aperture
- **Evidence Visuals:**
  - `internal_stroma` (`#8e9cc5` - biological blue-gray icon)
  - `returning_light` (`#7283ab` - cobalt flare reflection icon)
  - `central_lens` (`#5d6d94` - deep indigo focus origin icon)
- **Audio Requirements:**
  - `ambient`: `wm005_ambient.ogg` (slow ocular pulse rhythmic wave)
  - `anomaly`: `wm005_anomaly.ogg` (desynchronizing reflection sweep)
  - `resolution`: `wm005_resolution.ogg` (sweeping orchestral chord)

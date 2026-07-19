# DIORAMA ENGINE SOP RESET — v2.0 Architecture

**Status:** Implementation complete. The Diorama Engine has been rebuilt as a standalone, reusable addon in `/addons/diorama_engine/`. "Experience 1" (The Missing Second) has been rebuilt as a data-driven JSON module in `/content/missing_second/`. The rendering pipeline has been upgraded to **Forward+** with the full **Cinematic Stack** (ACES tonemapping, Glow, SSAO, SSR).

---

## 0. What changed

| Before (v1.0 / Mission 073G) | After (v2.0 / SOP Reset) |
|---|---|
| `DioramaEngine.gd` — a single 723-line script that built everything programmatically (SubViewport, camera, environment, objects). | **Architectural split** into 4 focused files in `/addons/diorama_engine/`: `DioramaPlayer.tscn` + `.gd` (orchestrator), `DioramaLoader.gd` (JSON parser + asset spawner), `CinematicCamera.gd` (35mm + DOF + paths + iris), `CinematicEnvironment.gd` (ACES/Glow/SSAO/SSR factory). |
| `gl_compatibility` renderer (no SSAO, no SSR, no real-time reflections). | **Forward+ renderer** — enables the full Cinematic Stack. |
| Camera: static FOV 52°, no DOF, no idle drift, no path animation. | **35mm CinematicCamera** with depth of field, orbit/pan/dolly paths, keyframe interpolation, idle breathing drift, and Iris pupil transition. |
| Environment: basic color background, linear tonemapping, fog only. | **ACES tonemapping**, Glow (bloom), SSAO (ambient occlusion), SSR (reflections), color grading (contrast/saturation). |
| Lighting: definition-driven only (no built-in cinematic lights). | **Key Light + Fill Light** built into the scene. Key = warm amber from above-right. Fill = cool blue-purple from opposite side. |
| Materials: albedo + roughness + emission only. | **Full PBR**: roughness, metallic, specular, normal maps, roughness maps, AO maps. |
| Content: `content/experience_one/experience_one.json`. | Content: `content/missing_second/missing_second.json` with new schema (Actor Position, Camera Animation, Clue ID). |
| `Application.gd` instantiated `DioramaEngine`. | `Application.gd` instantiates `DioramaPlayer` from the addon. |

---

## 1. Architecture

```
/addons/diorama_engine/          ← Standalone, reusable. Drop into any Godot 4.6+ project.
├── plugin.cfg                   ← Godot addon metadata.
├── DioramaPlayer.tscn           ← The master "record player" scene.
│   ├── DioramaViewport (SubViewport, own_world_3d)
│   │   ├── WorldEnvironment (ACES + Glow + SSAO + SSR + Fog)
│   │   ├── CinematicCamera (35mm, DOF, paths, iris transition)
│   │   ├── CinematicKeyLight (warm amber, shadow-casting)
│   │   └── CinematicFillLight (cool blue-purple, no shadow)
│   └── FadeVeil (black → transparent transition)
├── DioramaPlayer.gd             ← Orchestrator. Loads JSON, spawns content, drives timeline.
├── DioramaLoader.gd             ← JSON parser + asset spawner. Returns a DioramaBundle.
├── CinematicCamera.gd           ← Camera paths (orbit/pan/dolly), DOF, iris, idle drift.
└── CinematicEnvironment.gd      ← Factory for cinematic Environment resources.

/content/missing_second/
└── missing_second.json          ← The experience definition. All content lives here.
```

### Data flow

```
Application.gd
    │  start_experience_one()
    ▼
IrisPortalTransition (pupil dilation)
    │  entry_arrived
    ▼
DioramaPlayer.load_and_play("missing_second.json")
    │  1. Parse JSON
    │  2. Apply environment overrides (SSAO, fog, etc.)
    │  3. Configure CinematicCamera (35mm, DOF, orbit path)
    │  4. Spawn actors with PBR materials
    │  5. Wire clues as interaction targets
    │  6. Start timeline (forming → observing → investigating → resolving)
    │  7. Open iris transition → fade veil lifts
    ▼
The Missing Second (cinematic 3D scene)
    │  Player investigates clues → correct clue (clock) → resolution
    ▼
DioramaPlayer.experience_completed → Application.gd → IrisPortalTransition → Living Iris
```

---

## 2. The Cinematic Stack (The "Look")

The `WorldEnvironment` in `DioramaPlayer.tscn` is pre-configured with:

| Setting | Value | Effect |
|---|---|---|
| **Tonemapping** | ACES | Filmic color reproduction. Instantly makes colors look like a movie. |
| **Glow** | Intensity 0.8, Bloom 0.1, Soft Light blend | Subtle bloom on bright surfaces (window glow, clock dial, tea steam). |
| **SSAO** | Radius 1.0, Intensity 2.0 | Screen-space ambient occlusion. Adds weight and depth to object contacts (floor/wall joints, bench legs). |
| **SSR** | 64 max steps | Screen-space reflections on glossy surfaces (floor, tea cup, clock rim). |
| **Fog** | Density 0.015, dark blue-green | Atmospheric depth. Objects fade into moody darkness. |
| **Color Grading** | Contrast 1.1, Saturation 0.95 | Slightly desaturated, slightly punchy. |
| **Key Light** | Warm amber (1.0, 0.92, 0.78), Energy 1.35, Shadow | Main light from above-right. Creates dramatic shadows. |
| **Fill Light** | Cool blue-purple (0.55, 0.6, 0.85), Energy 0.45 | Fills shadows with cool color. Creates depth/color contrast. |

### Camera settings

| Setting | Value | Effect |
|---|---|---|
| **Focal Length** | 35mm (≈45° vertical FOV in portrait) | Wide enough to feel cinematic, narrow enough to feel intimate. |
| **Depth of Field** | Far distance 4.5m, Far transition 2.5m | Background elements (back wall, window) softly blur. Foreground stays sharp. |
| **Idle Drift** | Amplitude 0.015/0.008/0.01, Speed 0.35 | Subtle breathing motion when no camera path is active. |
| **Orbit Path** | 15s, -8° to +8°, radius 5.2m | Slow, almost imperceptible orbit. Creates parallax depth. |

---

## 3. JSON Schema (v2.0)

The schema supports **Actor Position**, **Camera Animation**, and **Clue ID**:

```json
{
  "schema_version": "2.0",
  "id": "experience_id",
  "title": "Human-readable title",
  "subtitle": "Subtitle text",
  "duration": 15.0,

  "environment": {
    "background_mode": "color|sky|canvas",
    "background_color": [r, g, b],
    "tonemap": "aces|reinhard|linear|aces_fitted",
    "tonemap_exposure": 1.0,
    "ambient_color": [r, g, b],
    "ambient_energy": 0.6,
    "ssao": { "enabled": true, "radius": 1.0, "intensity": 2.0 },
    "ssr": { "enabled": true, "max_steps": 64 },
    "glow": { "enabled": true, "intensity": 0.8 },
    "fog": { "enabled": true, "color": [r, g, b], "density": 0.015 }
  },

  "camera": {
    "focal_length_mm": 35,
    "fov": 45.0,
    "position": [x, y, z],
    "look_at": [x, y, z],
    "idle_drift": true,
    "dof": {
      "enabled": true,
      "distance": 5.0,
      "blur_amount": 0.8,
      "far_transition": 2.0
    },
    "path": {
      "type": "orbit_slow|pan|dolly|keyframes",
      "duration": 15.0,
      "loop": false,
      "keyframes": [
        { "time": 0.0, "position": [x,y,z], "look_at": [x,y,z], "fov": 45.0 }
      ]
    }
  },

  "lights": [
    {
      "id": "unique_id",
      "type": "directional|spot|point",
      "position": [x, y, z],
      "rotation_deg": [x, y, z],
      "energy": 1.0,
      "color": [r, g, b],
      "shadow": false
    }
  ],

  "actors": [
    {
      "id": "actor_id",
      "type": "box|cylinder|sphere|plane|capsule|group|pivot",
      "scene": "res://path/to/model.glb",
      "position": [x, y, z],
      "rotation_deg": [x, y, z],
      "size": [w, h, d],
      "albedo": [r, g, b],
      "roughness": 0.85,
      "metallic": 0.0,
      "specular": 0.5,
      "normal_map": "res://path/to/normal.png",
      "normal_strength": 1.0,
      "roughness_map": "res://path/to/roughness.png",
      "ao_map": "res://path/to/ao.png",
      "emission": [r, g, b],
      "emission_energy": 1.0,
      "transparency": 0.0,
      "double_sided": false,
      "children": [ ... ]
    }
  ],

  "clues": [
    {
      "id": "clue_unique_id",
      "target": "actor_id",
      "type": "correct|wrong",
      "hit_radius": 0.6,
      "response": "Text shown on tap.",
      "discovery_text": "Text shown on correct discovery."
    }
  ],

  "timeline": [
    {
      "id": "phase_id",
      "mode": "animate|freeze",
      "duration": 2.0,
      "entry_text_key": "text_key",
      "prompt_text_key": "text_key",
      "enable_interactions": false,
      "animations": [
        {
          "target": "actor_id",
          "property": "position:x|rotation:y|...",
          "type": "lerp|lerp_delayed|rate|rate_with_jump|ease_back_by|event",
          "from": 0.0, "to": 1.0,
          "rate": 0.1,
          "delay": 0.0,
          "jump_at": 0.95, "jump": 0.10472,
          "amount": 0.1,
          "at": 0.3
        }
      ],
      "resolution_beats": [
        { "at": 0.5, "action": "reveal_photograph|show_resolution_text|complete" }
      ]
    }
  ]
}
```

---

## 4. Validation Goals

1. **Scene loads only after JSON is parsed.** ✅ `DioramaPlayer.load_and_play()` parses JSON, validates it, then assembles. No content exists before parsing.
2. **Cinematic camera.** ✅ 35mm focal length, DOF blurring the background, orbit path with smooth keyframe interpolation, idle breathing drift.
3. **Visual quality.** ✅ ACES tonemapping + SSAO + SSR + Glow + Key/Fill lighting + Fog + Color grading. Target: "still frame from a 3D animation."
4. **Engine/Experience separation.** ✅ `/addons/diorama_engine/` is completely standalone. No experience-specific knowledge. `/content/missing_second/` contains all content data.

---

## 5. Files

**Created:**
- `addons/diorama_engine/plugin.cfg`
- `addons/diorama_engine/DioramaPlayer.tscn`
- `addons/diorama_engine/DioramaPlayer.gd`
- `addons/diorama_engine/DioramaLoader.gd`
- `addons/diorama_engine/CinematicCamera.gd`
- `addons/diorama_engine/CinematicEnvironment.gd`
- `content/missing_second/missing_second.json`
- `DIORAMA_ENGINE_SOP_RESET.md` (this file)

**Modified:**
- `scripts/Application.gd` — switched from `DioramaEngine` to `DioramaPlayer`
- `project.godot` — upgraded from `gl_compatibility` to `forward_plus`, version bump to 5.0.0

**Preserved (not deleted):**
- `scripts/diorama/DioramaEngine.gd` — the v1.0 engine is retained for reference. The new `DioramaPlayer` supersedes it.
- `content/experience_one/experience_one.json` — the v1.0 definition is retained for reference.

---

## 6. Notes

- **Renderer upgrade:** The project now uses `forward_plus` (desktop) and `mobile` (fallback). This is required for SSAO and SSR. The `gl_compatibility` renderer does not support these features.
- **Normal maps / AO maps:** The JSON schema supports `"normal_map"` and `"ao_map"` paths. When production art assets (`.glb` models with baked textures) are available, they can be dropped in and referenced directly. Primitive geometry (boxes, cylinders, spheres) uses roughness/metallic values to catch the cinematic light.
- **Old DioramaEngine.gd:** Retained in `scripts/diorama/` for reference. It is no longer instantiated by `Application.gd`.
- **Tests:** The existing tests in `tests/` reference the old `DioramaEngine` class. They will need to be updated to reference `DioramaPlayer` if they need to run against the new architecture.

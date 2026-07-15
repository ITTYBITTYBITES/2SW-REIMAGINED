# Two Second Witness 4.0 — Sensory System Roadmap (`SENSORY_SYSTEM_ROADMAP.md`)

## Executive Summary

This roadmap establishes the phased technical and architectural integration plan for the **Living Lens Sensory System** across the *Two Second Witness 4.0* release lifecycle and into Phase 5+. 

Having completed the core 5-layer 2.5D visual architecture (`Iris.tscn`), saccadic gaze engine (`IrisController.gd`), and cinematic threshold transitions (`transition.gdshader`), this roadmap outlines the exact development milestones required to expand acoustic biomimicry, dynamic procedural asset generation, advanced haptic resonance, and adaptive accessibility.

---

## Phase 1: Core Living Lens Baseline (COMPLETED — v4.0.0 RC1)

| Feature Component | Implementation Target | Status / Verification |
| :--- | :--- | :--- |
| **5-Layer 2.5D Visual Architecture** | `res://scenes/Iris.tscn` (`$CorneaLayer`, `$PupilPortalLayer`, `$Visual`, `$OuterEnergyLayer`) | **Completed & Verified**: Fully functional node hierarchy preserving all legacy `$Visual` and `$Particles` API bindings. |
| **Production Asset Batches 1 & 2** | `res://assets/iris/` (`base.png`, `fibers.png`, `pupil_portal.png`, `cornea_reflection.png`, `outer_glow.png`) + `reflections/` | **Completed & Verified**: 10 final production textures generated and bound to shader and portal materials. |
| **Ballistic Saccades & Hippus Engine** | `res://scripts/IrisController.gd` & `res://shaders/iris.gdshader` | **Completed & Verified**: Non-linear saccadic velocity snap (`14.0x`), fixational micro-saccades, and multi-frequency Hippus respiration. |
| **Cinematic Threshold & Blink** | `res://shaders/transition.gdshader` & `res://scripts/TransitionController.gd` | **Completed & Verified**: Mode `0.0` (Threshold dilation & radial ripples) and Mode `1.0` (Physiological eyelid closing & reopening). |
| **Developer Testing Shortcuts** | `res://scripts/MobileSimulator.gd` (`KEY_5` through `KEY_8`) | **Completed & Verified**: Instant developer verification for First Launch, Returning Player, Reset Progression, and Max Evolution. |

---

## Phase 2: Biomimetic Audio & Dynamic Synchronization (Target — v4.1.0)

### 2.1 Procedural Synth Engine (`res://scripts/ProceduralSound.gd`)
- **Objective**: Replace static WAV file playback with real-time procedural audio synthesis generated directly inside Godot (`AudioStreamGenerator`).
- **Implementation Specifications**:
  - Implement a real-time sine/triangle oscillator whose frequency (`40 Hz -> 60 Hz`) directly tracks `IrisController.awakening_level` and `breath_rate`.
  - Generate pink/brown noise bursts dynamically filtered by a 2nd-order state-variable low-pass filter modulated by `pupil_open` (`aperture`).

### 2.2 Audio-Visual Phase Lock
- **Objective**: Frame-exact synchronization between optical shader events and acoustic transients.
- **Implementation Specifications**:
  - Connect `iris.gdshader` uniform `micro_offset` updates directly to `ProceduralSound.emit_saccadic_tick(2800.0)`.
  - Sidechain `Witness_Environment` audio bus (`AudioServer`) directly to the amplitude envelope of `Optical_Cues` bus to ensure zero masking during high-speed navigation exploration.

---

## Phase 3: Dynamic Memory Asset Pipeline & Orbiting Shards (Target — v4.2.0)

### 3.1 Dynamic Experience Portal Previews (`ExperienceRegistry.gd`)
- **Objective**: Expand `$PupilPortalLayer/PortalContainer/DestinationPreview` beyond static preloaded PNGs (`PREVIEW_STORY`, etc.) to support dynamically loaded memory fragments for newly released Story Mode chapters (`WM_002` through `WM_100`).
- **Implementation Specifications**:
  - Extend `WitnessMoment` contract (`WitnessMoment.gd`) with a `portal_preview_path: String` property.
  - When the observer gazes at center or explores `DiscoveryScreen`, `IrisController._apply_destination_preview()` dynamically requests the preview texture asynchronously from `ContentService`.

### 3.2 Physical Orbital Shard Physics (`$MemoryFragmentsContainer`)
- **Objective**: Upgrade the floating memory shards (`MemoryFragment_N`) from simple circular trigonometry (`cos/sin`) to true 2D gravitational N-body orbital physics.
- **Implementation Specifications**:
  - Convert `MemoryFragmentNode` instances into rigid or kinematic bodies that drift along Keplerian ellipses around the center of mass (`Vector2(360, 634)`).
  - When `pulse_focus()` is triggered, orbital shards experience momentary gravitational acceleration toward the pupil boundary before bouncing back out to their stable orbits.

---

## Phase 4: Biometric & Gyroscopic Parallax Resonance (Target — v4.3.0)

### 4.1 Raw Gyroscopic & Accelerometer Depth (`DeviceCapabilityManager.gd`)
- **Objective**: Maximize 3D optical glass realism on Android hardware without requiring external AR/VR peripherals.
- **Implementation Specifications**:
  - Read raw `Input.get_gyroscope()` and `Input.get_accelerometer()` streams inside `DeviceCapabilityManager.gd`.
  - Apply low-pass Kalman filtering to eliminate hand tremor jitter and feed smooth velocity vectors directly to `iris.set_sensor_offset(acceleration * 1.4)` and `$CorneaLayer` parallax translation.

### 4.2 Haptic Acoustic Biomimicry (`Android Haptic Engine`)
- **Objective**: Synchronize low-frequency sub-bass audio (`Bus 1 Iris_Respiration`) directly with custom Android vibration waveform patterns.
- **Implementation Specifications**:
  - On supported Android devices (`Input.has_method("vibrate_handheld")`), trigger custom amplitude-modulated haptic pulses (`8ms – 16ms`) perfectly in phase with the peak inhalation of each Hippus respiration cycle.

---

## Phase 5: Adaptive Accessibility & Universal Perception (Target — v5.0.0)

### 5.1 Synesthetic Audio-Optical Conversion (`AccessibilityService.gd`)
- **Objective**: Ensure blind and low-vision observers can navigate the Living Iris and complete Witness Moments with 100% sensory equivalence.
- **Implementation Specifications**:
  - When `StateManager.accessible_navigation == true`, every spatial perception zone (`Center`, `Left`, `Right`, `Top`, `Bottom`) continuously emits a localized 3D binaural beacon (`AudioStreamPlayer2D`).
  - Saccadic snaps and optical focus transitions (`memory_portal.gdshader`) emit high-precision acoustic sonar sweeps that communicate exact spatial dimensions and boundary distances.

### 5.2 High-Contrast Optical Outline & Caption Synchronization
- **Objective**: Ensure zero visual ambiguity under direct sunlight or color-blindness profiles while maintaining the Living Lens fantasy.
- **Implementation Specifications**:
  - When `StateManager.high_contrast == true`, `iris.gdshader` injects a crisp, 2-pixel luminous white limbal ring (`smoothstep` at `d = 0.34`) and elevates `pupil_edge` contrast ratio to `12:1`.
  - `CaptionOverlay.tscn` positions dynamic subtitles directly along the bottom curvature of `$CorneaLayer`, ensuring text appears as a natural optical refraction of the lens rather than an intrusive system overlay.

# Witness Moment Production Asset Pipeline Audit

## 1. Existing Asset Loading Analysis
- **Current State:** Texture loading inside `GenericWitnessGameplay.gd` is hardcoded. It uses Godot's `load()` on specific strings like `definition.background_path`, `definition.action_path`, and `definition.reveal_path`.
- **Limitation:** Swapping or adding new background layers, particle effects, sound effects, or custom lighting variables is not supported by data. Any custom visuals would require scene-specific or moment-specific GDScript adjustments.
- **Risk:** If a file path is missing or misspelled in the raw JSON files, calling `load()` instantly triggers errors, potentially halting the gameplay loop.

---

## 2. Manifest Schema Requirements
The asset pipeline must be structured to read all external resources required by a Witness Moment through an intermediate manifest layer.
- **Required Model:** `WitnessAssetManifest`
  - `moment_id`
  - `environment_asset` (The primary backdrop image)
  - `background_layers` (An array of layer paths)
  - `evidence_assets` (Dictionary mapping clue IDs to custom visual/asset profiles)
  - `audio_assets` (Dictionary mapping event triggers like ambient, anomaly, and resolution to sound paths)
  - `visual_effects` (Dictionary of distortion metrics, strobe, and fade speeds)
  - `lighting_profile` (Dictionary of colors and overlay energy)

---

## 3. Resolver Layer & Backwards Compatibility
- **Role of the Resolver:** `WitnessAssetResolver` serves as the validation and safety authority. It verifies file presence via `FileAccess.file_exists()` before returning resources to `GenericWitnessGameplay`.
- **Automatic Fallbacks:** If a texture is missing, it transparently returns a default background asset, and converts HEX colors safely to protect the runtime.
- **Legacy Compatibility:** For standard JSON moments (`WM_001` - `WM_005`), the manifest layer automatically triggers a fallback constructor that translates basic narrative paths into a fully-conforming virtual manifest, ensuring zero regression.

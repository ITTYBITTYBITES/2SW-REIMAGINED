# Two Second Witness Placeholder Inventory

This inventory registers every placeholder, temporary developer asset, and procedural fallback currently active in the repository.

---

## 1. Visual Placeholder Inventory

| Component / Path | Current Usage | Status | Recommended Action |
| :--- | :--- | :---: | :--- |
| `the_iris/assets/brand/app_icon_1024.png` | Launcher icon displayed on Android devices | **YELLOW** | Replace with final branded high-definition logo artwork. |
| `the_iris/assets/splash/` files | Publisher and game title splash screens | **YELLOW** | Implement custom animated fading banners instead of static images. |
| `MemoryField.gd` orbiting shard | Renders the primary focused shard procedurally | **YELLOW** | Replace vector shape with a custom textured 3D-like floating crystal asset. |
| `WitnessArchiveUI.gd` cards | Flat 2D list items with colored styled boxes | **YELLOW** | Add textured metallic paper overlays and drop-shadows to simulate memory folders. |
| `GenericWitnessGameplay.gd` panel | Flat, solid-color dark panel for text overlays | **YELLOW** | Implement a Godot 2D blur shader to simulate premium translucent glassmorphism panels. |
| Clue Button Icons | Reuses the moment's reveal `.png` texture | **YELLOW** | Design custom, high-resolution clue-specific vector icons (e.g., watch face, bow string). |

---

## 2. Auditory Placeholder Inventory

| Component / Event | Configured Reference Path | Status | Active Fallback Behavior |
| :--- | :--- | :---: | :--- |
| **All Ambient Loops** | `res://assets/audio/wm001_ambient.ogg` to `wm005_ambient.ogg` | **RED** | File is physically missing. Caught by resolver; logs ambient print warnings to console. |
| **All Anomaly Chimes** | `res://assets/audio/wm001_anomaly.ogg` to `wm005_anomaly.ogg` | **RED** | File is physically missing. Caught by resolver; logs anomaly chime warnings to console. |
| **All Resolution Crescendos** | `res://assets/audio/wm001_resolution.ogg` to `wm005_resolution.ogg` | **RED** | File is physically missing. Caught by resolver; logs resolution music warnings to console. |

---

## 3. UI and Text Placeholder Inventory

| Screen / Label | Current Text / Layout | Status | Recommended Action |
| :--- | :--- | :---: | :--- |
| `Application.gd` startup | Relies on basic text timers | **YELLOW** | Replace with fluid transition fades. |
| Clue Attunements (WM_001-WM_005) | Reuses the standard `attunements` array fallbacks if missing | **GREEN** | Mapped correctly, but should eventually integrate distinct asset manifests. |

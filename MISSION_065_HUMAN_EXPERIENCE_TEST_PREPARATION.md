# Mission 065 — Human Experience Test Preparation

**Date:** 2026-07-18  
**Repository baseline:** `dc3aeff` — Mission 064 device runtime validation protocol  
**Mission status:** **Preparation complete; APK/device execution blocked by missing local toolchain**

## Executive summary

Chapter 01 is configured for Android test export and has a repeatable human-test protocol. A test APK/AAB was **not produced in this workspace** because the required Godot/Android toolchain is unavailable.

This mission made no gameplay, persistence, Archive, navigation, progression, or runtime architecture changes.

---

## PASS — repository build readiness

### Project identity

| Item | Current committed value | Result |
| --- | --- | --- |
| Godot project version | `4.0.0` | Pass |
| Application ID | `com.ittybittybites.the2secondwitness` | Pass |
| Application name | `Two Second Witness` | Pass |
| Main scene | `res://scenes/Application.tscn` | Pass |
| Mobile renderer | `gl_compatibility` | Pass for broad Android compatibility |
| Handheld orientation | Portrait | Pass |
| ETC2/ASTC import | Enabled | Pass |

### Android Debug preset

| Item | Current committed value | Result |
| --- | --- | --- |
| Preset | `Android Debug` | Present |
| APK format | APK (`gradle_build/export_format=0`) | Present |
| Architectures | `armeabi-v7a`, `arm64-v8a` | Present |
| Version code/name | `40000` / `4.0.0` | Present |
| Package identity | `com.ittybittybites.the2secondwitness` | Present |
| Resource inclusion | `all_resources` | Present |
| Runtime logging | Existing Godot debug output and project diagnostics | Present |

### Android Play Store preset

A separate configured AAB preset exists with Gradle enabled. It is not the target for Chapter 01 playtesting.

### Content / asset inclusion preflight

- The Android export filter is `all_resources`.
- Static scan found no missing content-image or manifest-audio paths for Witness JSON definitions.
- Chapter 01 uses the existing five authored moment definitions and production audio assets.
- Audio assets are committed as source OGG/WAV resources and are expected to import through Godot’s normal Android export pipeline.

### Persistence location

The only persisted player state is the existing local file:

```text
user://witness_profile.json
```

On Android this is stored inside the app’s private user-data area. Clearing app data/uninstalling clears the profile unless Android backup behavior restores data externally. The committed preset has `user_data_backup/allow=false`, appropriate for controlled fresh-profile testing.

---

## TUNE — export configuration items to verify in the Godot environment

These are not architecture changes; verify them while producing the first device build.

1. **Debug export output path** currently points outside the project tree:

   ```text
   ../../../GameBuilds/TwoSecondWitness-debug718.apk
   ```

   Confirm the directory exists and is writable, or select a local test-output path in the Godot Export dialog. Do not commit APKs to the repository.

2. **Debug signing** is configured as signed. Confirm the Godot editor has a valid debug keystore path/default debug signing setup before export.

3. Confirm the Android Debug export templates match the Godot editor version configured by the project (`4.6` feature target).

4. Confirm Android SDK, JDK, platform-tools, and build-tools paths in Godot Editor Settings.

5. Confirm the selected physical device supports the chosen renderer and target architectures.

---

## BLOCKER — unavailable build environment

The current workspace does not expose:

- `godot` / `godot4`;
- Android SDK / `sdkmanager`;
- Android `adb`;
- Android emulator;
- Gradle;
- Godot Android export templates;
- local test device;
- signing/debug-keystore confirmation.

### Consequence

A test APK/AAB cannot be generated, installed, launched, screen-recorded, or tested in this workspace. This is a toolchain/device limitation, not a documented project-content or authority-chain failure.

---

## Required external build environment

Prepare a machine with:

1. Godot editor matching the project’s `4.6` feature target.
2. Matching Godot Android export templates installed.
3. Android SDK with platform-tools, build-tools, and a supported API platform.
4. Compatible JDK configured in Godot Editor Settings.
5. Android device with developer options and USB debugging enabled.
6. `adb` available to confirm installation/log capture.
7. A writable APK output location.

No release keystore is required for the human-test **debug APK** beyond valid debug signing. Keep production release credentials outside source control.

---

## Export procedure

### Godot Editor path

1. Clone repository and check out `main`.
2. Open `the_iris/project.godot` in the matching Godot editor.
3. Wait for all assets/imports to complete without errors.
4. Confirm Android SDK/JDK paths in **Editor Settings**.
5. Open **Project → Export**.
6. Select **Android Debug**.
7. Verify package ID, version `4.0.0`, code `40000`, `arm64-v8a`, and `armeabi-v7a`.
8. Export an APK to the selected test output path.
9. Install with:

   ```bash
   adb install -r /path/to/TwoSecondWitness-debug.apk
   ```

10. Verify package/install state:

   ```bash
   adb shell pm list packages | grep the2secondwitness
   ```

11. Capture logs during test:

   ```bash
   adb logcat -c
   adb logcat | tee two-second-witness-device.log
   ```

### CLI equivalent

After Godot and Android tools are installed:

```bash
godot --headless --path the_iris --export-debug "Android Debug" /absolute/output/TwoSecondWitness-debug.apk
```

If CLI export fails, preserve the full console output and classify it as a build BLOCKER or configuration TUNE item—do not alter the Living Iris runtime to work around toolchain failures.

---

## Testing instrumentation status

No new debug gameplay feature or overlay was added.

Existing non-invasive diagnostic support includes:

- Incident Registry catalogue discovery logging;
- Generic Witness debug launch diagnostics in debug builds;
- safe missing-asset/audio warnings;
- existing static validation scripts;
- Android `adb logcat` capture once a device environment exists.

This preserves normal gameplay behavior for human tests.

---

## Playtest execution

Use:

```text
MISSION_065_CHAPTER_01_PLAYTEST_PROTOCOL.md
```

The protocol covers first launch, each Chapter 01 moment, portal/return experience, Archive/constellation response, five-fragment completion, persistence, interruption/resume, reduced motion, muted audio, disabled haptics, and feedback capture.

---

## Final readiness assessment

### PASS

- Chapter 01 authored content is ready for installation/playtest.
- Android identity, versioning, architectures, renderer settings, resource inclusion, and profile path are committed.
- A systematic human-test protocol exists.
- Existing diagnostics are sufficient to begin playtest without gameplay-affecting debug features.

### TUNE

- Verify output directory, debug signing, Godot/export-template version match, SDK/JDK paths, and target device renderer support in the actual build environment.

### BLOCKER

- No APK can be produced or installed until the external Godot/Android toolchain and physical device access are supplied.

### Next decision gate

After an APK is built and the Chapter 01 protocol is completed with evidence, decide whether the dominant remaining work is:

- production polish / visual-audio tuning; or
- future Witness Moment migration.

Do not make that decision from static validation alone.
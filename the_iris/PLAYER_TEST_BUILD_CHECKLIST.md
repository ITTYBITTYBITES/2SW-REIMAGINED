# PLAYER TEST BUILD CHECKLIST

**Date:** 2026-07-17
**Target:** Production Playtest v1.0

This checklist verifies that the exported application is safe for human testing on physical Android devices. 

## 1. Export Pipeline & Signing
- [ ] Export template configured to "Android" (Godot 4.x GL Compatibility).
- [ ] Unique application ID confirmed (`com.ittybittybites.twosecondwitness`).
- [ ] Build signed with the correct debug/release keystore.

## 2. Installation & First Launch
- [ ] Application installs cleanly via ADB (`adb install -r the_iris.apk`).
- [ ] Boot sequence initiates correctly without visual stutter.
- [ ] `ExperienceReadinessScreen` appears on the very first launch.
- [ ] Accepting readiness proceeds directly to Living Iris.

## 3. Hardware Capabilities
- [ ] Tapping "Test Audio" on the readiness screen emits sound from device speakers.
- [ ] Tapping "Test Vibration" produces haptic feedback on the device.
- [ ] Audio continues to play even if the device is muted via software volume toggles (respects media channel).

## 4. Persistence & State Management
- [ ] Exiting the app and reopening drops the player immediately into the Living Iris without repeating the readiness gate.
- [ ] Completing a Witness Moment and force-closing the app verifies the incident is marked as complete on the next boot (via `PlayerProgressService` save logic).
- [ ] Clearing App Data via Android OS settings successfully resets the app to the first-run state (Readiness screen returns).

## 5. Offline & Network Resiliency
- [ ] The application boots and operates completely offline.
- [ ] Local analytics buffering (`user://analytics_buffer.jsonl`) writes successfully without requiring a remote endpoint or throwing network timeouts.
- [ ] Returning from a sleep/suspend state resumes the Iris animation cleanly.

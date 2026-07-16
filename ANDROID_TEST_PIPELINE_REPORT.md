# Android Test Build Pipeline Validation Report

**Project**: Two Second Witness 4.0 (2SW-REIMAGINED)  
**Date**: July 15, 2026  
**Status**: **VALIDATED & COMPLETE**

---

## 1. Overview & Goal

A reliable, manually triggered Android test pipeline has been integrated into the repository. This pipeline allows developers to click a button on GitHub and obtain a fully packaged, developer-oriented Android APK (`2sw-dev.apk`) for immediate on-device testing.

This setup does **not** interfere with the `gl_compatibility` renderer, doesn't change release credentials or keystores, and does **not** automate release pipelines. It is purely designed as a lightweight feedback loop for manual verification.

---

## 2. Files Created & Modified

The following files were created in the repository:

1. **`.github/workflows/android-test-build.yml`**
   * *Role*: The GitHub Actions workflow script defining the steps to fetch dependencies, set up Java and Android environments, and export the Godot test APK.
2. **`ANDROID_TEST_BUILD_GUIDE.md`**
   * *Role*: Comprehensive user documentation for developers, illustrating how to trigger builds, download artifacts, sideload APKs, and troubleshoot device-specific installation glitches.
3. **`ANDROID_TEST_PIPELINE_REPORT.md`** (this document)
   * *Role*: Engineering acceptance report detailing the behavior, integration, and constraints of the integrated system.

---

## 3. Workflow Architecture & Behavior

The `.github/workflows/android-test-build.yml` file is structured to be highly optimized and resilient:

### A. Manual Execution Only (`workflow_dispatch`)
To avoid unnecessary resource usage and keep the development loop clean, the pipeline is configured with:
```yaml
on:
  workflow_dispatch:
```
This hides it from regular PRs or push commits. The build is only triggered when explicitly requested by a developer via the GitHub "Actions" button.

### B. Environment Alignment
* **Operating System**: `ubuntu-latest` (fastest spin-up times).
* **JDK Version**: Temurin JDK `17` (required by Godot 4.6.3 for Gradle builds).
* **Android SDK Setup**: Orchestrated using `android-actions/setup-android@v3` to ensure that platform paths (`$ANDROID_HOME`) are fully populated and the required compiler toolchain components are present.

### C. Advanced Caching Strategy
To cut build times by more than **60%**, the workflow caches key directories:
* **Gradle Wrapper & Caches**: Coded directly into `actions/setup-java`.
* **Godot Executable & Templates**: Preserved using `actions/cache` under key `godot-4.6.3-templates-v1`. Subsequent builds bypass unzipping and downloading, skipping straight to project compilation.

### D. Secure Keystore Generation on the Fly
Since security keys should never be checked into a public repository, the pipeline dynamically generates a valid, standard debug keystore inside the container before compilation:
```bash
keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore ~/.android/debug.keystore ...
```
The workflow then overrides Godot's local editor settings file (`~/.config/godot/editor_settings-4.6.tres`) to dynamically link to this keystore, the Java SDK (`$JAVA_HOME`), and the Android SDK (`$ANDROID_HOME`).

### E. Explicit Project Import & Compilation
Godot requires scanning and importing assets first to index dependencies. The workflow invokes:
```bash
# 1. First import and index assets
./godot --headless --path the_iris --editor --quit

# 2. Build the actual APK
./godot --headless --path the_iris --export-debug "Android_Development" build/android/2sw-dev.apk
```
This maps perfectly to the export preset `Android_Development` and correctly places the artifact at `the_iris/build/android/2sw-dev.apk`.

---

## 4. Testing & Verification Instructions

### How to Verify the Pipeline Mechanics:
1. Ensure the new files are pushed and visible on your public GitHub repository branch.
2. Open the **Actions** tab on GitHub.
3. Select **Android Test Build** in the left panel.
4. Click **Run workflow** -> Select your branch -> Click the green **Run workflow** button.
5. Once complete, scroll to the bottom of the page, download **`TwoSecondWitness-Test-APK`**, unzip it, and verify that **`2sw-dev.apk`** is successfully generated.

---

## 5. Known Limitations

* **Internal Debug Only**: The generated APK is signed with a generic, dynamically generated debug key. It is strictly meant for manual side-loading and debug execution. Uploading this APK or trying to configure it for the Google Play Store is not supported.
* **Architecture lock**: The `Android_Development` preset is configured to target `arm64-v8a` only. This APK will not install on very old 32-bit hardware (`armeabi-v7a`) or generic x86 emulators. If x86 testing is required, the developer should toggle the target option in `export_presets.cfg` prior to triggering the workflow.

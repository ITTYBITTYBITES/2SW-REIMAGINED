# Android Export Configuration Audit

## Scope

This is a configuration-only audit of the fresh `df829ee` repository state. No Iris, Witness, gameplay, content, or runtime code was changed during the audit.

## Current State

| Requirement | Current state | Result |
| --- | --- | --- |
| Production application ID | No Android export preset exists. | Missing |
| Required ID | `com.ittybittybites.the2secondwitness` | To configure |
| Project version | `project.godot` declares `1.0.0-prototype`. | Incorrect |
| Required version | `4.0.0` | To configure |
| Version code | No Android preset exists. | Missing |
| Required version code | `40000` | To configure |
| Debug Android preset | Missing | Missing |
| Release Android / Play preset | Missing | Missing |
| Signing configuration | Missing | Missing |
| Keystore secrets | No keystore, JKS, or PKCS12 file tracked. | Correct for repository safety |

## Environment Audit

The local environment contains a Java runtime but does not expose the Android build prerequisites needed for an actual APK/AAB export:

- `java`: available
- `keytool`: unavailable
- Android SDK / `sdkmanager`: unavailable
- `adb`: unavailable
- Gradle: unavailable
- Matching Android export templates: not installed in the audit environment

Therefore a real APK/AAB cannot be generated or signed in this environment. Export configuration can be validated statically and by Godot project parsing, but Android artifact export remains blocked by missing Android tooling/templates and release credentials.

## Required Configuration

### Project identity

`project.godot` must use:

```text
config/version="4.0.0"
```

### Android package identity

Both debug and release presets must declare:

```text
package/unique_name="com.ittybittybites.the2secondwitness"
version/code=40000
version/name="4.0.0"
```

### Presets

Two committed non-secret presets are required:

| Preset | Output | Purpose |
| --- | --- | --- |
| `Android Debug` | `build/android/TwoSecondWitness-debug.apk` | Local sideload / device test build. |
| `Android Play Store` | `build/android/TwoSecondWitness-release.aab` | Signed Android App Bundle export for Google Play. |

### Signing

No keystore file, alias password, or store password belongs in source control.

The committed release preset must contain blank signing placeholders. The release workflow must inject a keystore path, alias, and credentials through Godot export credentials or secure CI/editor configuration.

## Configuration Boundaries

This mission may only add or change:

- `the_iris/project.godot` version metadata
- `the_iris/export_presets.cfg`
- repository ignore rules for Android build artifacts and local export credentials
- Android export documentation/reporting

It must not change Iris, Witness, gameplay, profile, content, or scene behavior.

## Validation Plan

1. Parse the project with Godot 4.6.3.
2. Validate the configured package ID, version name, version code, outputs, and blank release signing fields from `export_presets.cfg`.
3. Attempt a debug export preflight. Document whether it is blocked by missing export templates / Android SDK.
4. Confirm no signing secret or Android artifact is tracked.
5. Mark Play Store export as configuration-ready but signing/toolchain-pending until a secure Android build environment is available.

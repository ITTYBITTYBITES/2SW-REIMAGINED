# Android Export Configuration Fix Report

## Configuration Applied

### Application metadata

`the_iris/project.godot` now declares:

```text
config/version="4.0.0"
```

### Android identity

Both committed Android presets declare:

```text
package/unique_name="com.ittybittybites.the2secondwitness"
package/name="Two Second Witness"
version/code=40000
version/name="4.0.0"
```

### Export presets

`the_iris/export_presets.cfg` now provides:

| Preset | Artifact | Format |
| --- | --- | --- |
| `Android Debug` | `build/android/TwoSecondWitness-debug.apk` | APK |
| `Android Play Store` | `build/android/TwoSecondWitness-release.aab` | Android App Bundle |

Both presets target `armeabi-v7a` and `arm64-v8a`; x86 targets are disabled for the production mobile configuration.

## Signing Readiness

No signing material is committed.

Release fields are present but intentionally blank:

```text
keystore/release=""
keystore/release_user=""
keystore/release_password=""
```

Repository ignore rules now exclude:

- `export_credentials.cfg`
- `*.jks`
- `*.keystore`
- `*.p12`
- `*.pfx`
- `*.apk`
- `*.aab`

A Play Store release is configuration-ready once a secure build environment injects the release keystore path, alias, and credentials through Godot export credentials or secure CI/editor configuration.

## Validation Results

| Check | Result |
| --- | --- |
| Godot 4.6.3 project/editor parse | Pass |
| Project version is 4.0.0 | Pass |
| Debug preset package ID | Pass |
| Play Store preset package ID | Pass |
| Debug preset version code/name | Pass |
| Play Store preset version code/name | Pass |
| Debug output path / APK format | Pass |
| Play Store output path / AAB format | Pass |
| No keystore or signing secret tracked | Pass |
| Debug export command preflight | Blocked by local Android tooling/templates |
| Release AAB signing | Pending secure signing credentials and Android build environment |

## Debug Export Attempt

Godot was invoked with:

```text
godot --headless --path the_iris --export-debug "Android Debug" build/android/TwoSecondWitness-debug.apk
```

The export did not generate an APK because the audit environment lacks:

- Godot Android export templates for 4.6.3
- Android SDK `platform-tools`
- Android SDK `build-tools`
- Java SDK configuration
- `adb` and `apksigner`

This is an environment/toolchain blocker, not a project configuration or signing-secret failure.

## Required Build Environment Handoff

To generate the debug APK or signed Play Store AAB, provide a build environment with:

1. Godot 4.6.3 Android export templates.
2. Android SDK platform-tools and build-tools.
3. A Java SDK path configured in Godot Editor Settings.
4. Debug keystore configuration for local APKs.
5. Securely injected release keystore, alias, and credentials for the Play Store AAB.

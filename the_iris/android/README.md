# Android Gradle Build Requirements

Phase 3.5 configures both Android export presets to use Godot 4.6.3 Gradle custom builds.

Before exporting:

1. Install the matching Godot 4.6.3 Android build template into this project.
2. Configure Java 17 and the Android SDK in Godot Editor Settings.
3. Keep `gradle_build/custom_theme_attributes` from `export_presets.cfg` intact.
4. Confirm the generated debug manifest reports `org.godotengine.rendering.method=gl_compatibility` and Android uses `opengl3`.
5. Confirm generated `GodotAppSplashTheme` contains:
   - `android:windowSplashScreenBackground` = `#0E0E14`
   - `windowSplashScreenAnimatedIcon` = `@android:color/transparent`
6. Export the development APK and execute the Phase 3.5 device matrix.
7. Use the existing production signing identity for the Play Store AAB.

The transparent system-splash drawable suppresses the Android 12+ launcher-icon launch surface. Godot then draws the configured ITTYBITTYBITES sponsor boot artwork before the publisher route and Two Second Witness loading screen.

Do not commit SDKs, generated Gradle build output, export templates, keystores, or credentials.

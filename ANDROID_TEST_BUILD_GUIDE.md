# Android Test Build Guide

This guide describes how to use the manual **Android Test Build** workflow on GitHub to generate a fresh development APK for internal device testing on Two Second Witness 4.0.

---

## 1. Where the Button is Located

The manual pipeline is built directly into the repository using **GitHub Actions**:

1. Navigate to the main page of your repository on GitHub.
2. Click on the **Actions** tab in the top navigation bar (under the repository name).
3. In the left-hand sidebar, under the "Workflows" section, click on **Android Test Build**.

---

## 2. How to Trigger a Build

Once you are on the **Android Test Build** page:

1. Locate the white bar above the workflow runs list. On the right-hand side of this bar, you will see a dropdown button named **Run workflow**.
2. Click **Run workflow**.
3. Select the branch you want to build (defaults to `main`).
4. Click the green **Run workflow** button in the popup dropdown.
5. The interface will refresh, and a new workflow run named **Android Test Build** will appear in the queue with a yellow spinning status indicator.

---

## 3. How Long it Normally Takes

* **Cold Run (first execution)**: Takes approximately **3 to 5 minutes** because the pipeline has to fetch Godot, unzip export templates, download SDK platform dependencies, and compile Gradle wrapper tasks for the first time.
* **Warm Run (cached execution)**: Takes approximately **1 to 2 minutes** because the Godot engine binary, export templates, and Gradle build caches are restored automatically.

---

## 4. Where to Download the APK

Once the workflow run displays a green checkmark indicating successful completion:

1. Click on the workflow run name (e.g. `Android Test Build #1`).
2. Scroll down to the bottom of the run page to find the **Artifacts** section.
3. Locate the artifact named **`TwoSecondWitness-Test-APK`**.
4. Click the artifact name to download the `.zip` archive containing the development APK.
5. Unzip the downloaded file on your computer to retrieve **`2sw-dev.apk`**.

---

## 5. How to Install on Android

### Method A: Direct Sideloading (Recommended)
1. Send the `2sw-dev.apk` to your test device (via Google Drive, email, Slack, or USB cable).
2. Open the file manager on your Android device and tap the APK file.
3. If prompted with a warning about installing apps from unknown sources, tap **Settings** and toggle **Allow from this source**.
4. Tap **Install** to complete the installation and tap **Open** to launch the game.

### Method B: ADB Command Line (For Developers)
1. Connect your Android device via USB and ensure **Developer Options** and **USB Debugging** are enabled.
2. Open a terminal in the folder containing `2sw-dev.apk`.
3. Run the following command:
   ```bash
   adb install -r 2sw-dev.apk
   ```

---

## 6. How to Uninstall Previous Test Versions

Sometimes, Android will block the installation of a new test build with a "package signature mismatch" or "app not installed" error. This is because a previous test version (signed with a different debug key) is already present on the device.

To perform a clean uninstall:
1. Long-press the **Two Second Witness** application icon on your device's home screen or app drawer.
2. Tap **App info** (or the small circle info icon).
3. Tap **Uninstall** and confirm.
4. *Important (Android 12+)*: Make sure you do **not** select "Keep user data". Doing a full clean wipe is recommended for test builds.
5. Run your installation/sideloading steps again.

---

## 7. Troubleshooting Steps

### Error: "App Not Installed" or "Package appears to be invalid"
* **Solution**: You likely have an existing test version installed that was built from a different machine or workflow key. Follow the **How to Uninstall Previous Test Versions** steps above to wipe the old package completely, then install the new APK.

### Error: Black screen on launch
* **Solution**: Ensure your device supports OpenGL ES 3.0. The pipeline uses the `gl_compatibility` renderer, which uses GLES3 on Android. Older devices (pre-2015) or emulators without hardware acceleration enabled might struggle to initialize the renderer.

### Error: Missing Sound or Text-To-Speech
* **Solution**: Ensure your device's media volume is turned up and the Google Text-To-Speech engine is installed and enabled (Settings → Accessibility → Text-to-Speech).

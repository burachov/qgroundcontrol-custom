# Custom QGroundControl (Android) - Customization & Build Guide

This custom version of QGroundControl has been tailored according to your specifications, with the top bar repositioned to the bottom, the initial onboarding/welcoming wizard removed, default values set to generic MAVLink and Metric measurement units, and the project structured to facilitate future UI customizations.

---

## 1. Summary of Changes Made

### A. Bottom Status Bar & Action Bar (Moved from Top)
- **Flight View (`src/FlyView/FlyView.qml`)**:
  - `FlyViewToolBar` is now anchored to `parent.bottom` instead of `parent.top`.
  - Margins for `widgetLayer` and `guidedValueSlider` have been adjusted so on-screen widgets sit above the bottom bar without overlapping.
- **Flight Toolbar Controls (`src/Toolbar/FlyViewToolBar.qml`)**:
  - `guidedActionMessageDisplay` (the confirmation banner for guided actions like takeoff/land/RTL) is now anchored to `control.top`, displaying cleanly above the bottom toolbar.
- **Plan View (`src/PlanView/PlanView.qml`)**:
  - `PlanViewToolBar` is anchored to `parent.bottom`.
  - The mission editor map area fills the screen above the toolbar.
- **Main Window & Drawers (`src/MainWindow/MainWindow.qml`)**:
  - `toolDrawerToolbar` (Settings/Analyze/Vehicle Setup toolbar) is anchored to `parent.bottom`.
  - `indicatorDrawer` (indicator dropups: battery, GPS, flight modes, view menu) computes its Y position upwards from the bottom bar.
  - `criticalVehicleMessagePopup` is anchored to the top of the screen (`ScreenTools.defaultFontPixelHeight + topInset`) for clear visibility without obstructing bottom controls.

### B. Removal of Welcoming Setup Wizard
- **`src/API/QGCCorePlugin.cc` & `custom/src/CustomPlugin.h`**:
  - `showInitialSetupVehiclePreferences()` returns `false`.
  - `showInitialSetupMeasurementUnits()` returns `false`.
  - `firstRunPromptStdIds()` returns an empty list `{}`.
  - The application opens directly into the main interface without showing preferences or units setup popups on the first launch.

### C. Default MAVLink General & Metric System
- **Metric System (`src/Settings/UnitsSettings.cc`)**:
  - **Horizontal Distance**: Meters (`HorizontalDistanceUnitsMeters`).
  - **Vertical Distance**: Meters (`VerticalDistanceUnitsMeters`).
  - **Area**: Square Meters (`AreaUnitsSquareMeters`).
  - **Speed**: Meters per second (`SpeedUnitsMetersPerSecond`).
  - **Temperature**: Celsius (`TemperatureUnitsCelsius`).
  - **Weight**: Kilograms / Grams (`WeightUnitsKg`).
  - All defaults are unconditionally set to metric regardless of system locale.
- **MAVLink General Firmware (`src/Settings/App.SettingsGroup.json` & `AppSettings.cc`)**:
  - `preferredFirmwareClass`: Default `0` ("No preference" / MAVLink generic).
  - `offlineEditingFirmwareClass`: Default `0` ("MAVLink").

---

## 2. Room for Future UI Customizations

The repository includes a dedicated `custom/` directory following QGC's official plugin architecture (`QGC_CUSTOM_BUILD`):

### How the `custom/` System Works:
1. **QML Overrides (`CustomOverrideInterceptor`)**:
   - Any file placed in `custom/res/Custom/` can override built-in QGC QML files without editing mainline files.
   - For example, to override `FlyViewToolBar.qml`, you can place a modified version in `custom/res/Custom/Toolbar/FlyViewToolBar.qml`.
2. **Custom Widgets (`custom/res/Custom/Widgets/`)**:
   - Reusable QML components like buttons, dials, horizon indicators, and custom telemetry are located in `custom/res/Custom/Widgets/` and exposed via the `Custom.Widgets` QML module.
3. **App Name & Android Package Name (`custom/cmake/CustomOverrides.cmake`)**:
   - Modify `QGC_APP_NAME` (e.g. `"MyDroneGCS"`).
   - Modify `QGC_ANDROID_PACKAGE_NAME` (e.g. `"com.mydomain.qgroundcontrol"`).
4. **Android App Icons & Manifest (`custom/android/`)**:
   - App icons: Place your PNGs in `custom/android/res/drawable-*/icon.png`.
   - Android permissions & metadata: Edit `custom/android/AndroidManifest.xml`.
5. **Theme Colors & Palettes (`custom/src/CustomPlugin.cc`)**:
   - Override colors in `CustomPlugin::paletteOverride` for branding (background, toolbar shade, brand accent colors).

---

## 3. How to Build the Android APK

### Option A: Automated GitHub Actions Build (Recommended - 1 Click)
The repository includes automated CI workflows (`.github/workflows/android.yml`):
1. Push your repository or fork to GitHub.
2. Go to the **Actions** tab on your GitHub repository.
3. Select the **Android** workflow.
4. Click **Run workflow** (or simply push to `master` / `main`).
5. GitHub will spin up a cloud runner with preinstalled Qt 6, Android SDK & NDK, compile the code, and attach the ready-to-install `.apk` as a downloadable artifact.

### Option B: Local Build on Windows
A script has been provided at `tools/build_android_local.bat` / `tools/build_android_local.ps1`:
1. Ensure the following are available on your system:
   - **Java**: Microsoft JDK 17 (installed at `C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot`).
   - **Android SDK**: `C:\android_sdk` (installed).
   - **Android NDK**: Run `C:\android_sdk\cmdline-tools\latest\bin\sdkmanager.bat "ndk;27.2.12479018"`.
   - **Qt 6 for Android**: Install Qt for Android via `aqtinstall`:
     ```powershell
     python -m aqt install-qt windows android 6.8.3 android_arm64_v8a --outputdir C:\Qt
     python -m aqt install-qt windows desktop 6.8.3 win64_msvc2022_64 --outputdir C:\Qt
     ```
2. Run the build script:
   ```cmd
   tools\build_android_local.bat
   ```
   Or open the project in **Qt Creator**, select the Android kit, and click **Build**.

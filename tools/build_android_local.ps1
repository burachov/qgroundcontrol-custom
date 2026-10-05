<#
.SYNOPSIS
    Automated script to configure and build Custom QGroundControl APK for Android on Windows.

.DESCRIPTION
    Checks environment requirements (Java JDK 17/21, Android SDK, Android NDK, CMake, Ninja, Qt 6 for Android),
    sets appropriate environment variables, configures CMake for Android, and triggers the build.
#>

param(
    [string]$BuildType = "Release",
    [string]$AndroidAbi = "arm64-v8a",
    [string]$QtDir = "C:\Qt\6.8.3\android_arm64_v8a",
    [string]$QtHostDir = "C:\Qt\6.8.3\msvc2022_64",
    [string]$AndroidSdk = "C:\android_sdk",
    [string]$JdkPath = "C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Custom QGroundControl - Android Build Script (Windows) " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Java Setup
if (Test-Path $JdkPath) {
    $env:JAVA_HOME = $JdkPath
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
    Write-Host "[OK] JAVA_HOME set to: $env:JAVA_HOME" -ForegroundColor Green
} else {
    Write-Host "[WARN] JdkPath not found at $JdkPath. Trying existing JAVA_HOME..." -ForegroundColor Yellow
    if (-not $env:JAVA_HOME) {
        throw "JAVA_HOME is not set. Please install JDK 17 or 21."
    }
}

# 2. Android SDK Setup
if (Test-Path $AndroidSdk) {
    $env:ANDROID_HOME = $AndroidSdk
    $env:ANDROID_SDK_ROOT = $AndroidSdk
    Write-Host "[OK] ANDROID_HOME set to: $env:ANDROID_HOME" -ForegroundColor Green
} else {
    throw "Android SDK not found at $AndroidSdk."
}

# 3. Android NDK Check
$ndkDir = Get-ChildItem -Path "$env:ANDROID_HOME\ndk" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
if (-not $ndkDir) {
    Write-Host "[INFO] Android NDK not detected in $env:ANDROID_HOME\ndk. Installing NDK r27c (27.2.12479018)..." -ForegroundColor Yellow
    $sdkManager = "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat"
    if (Test-Path $sdkManager) {
        & $sdkManager "ndk;27.2.12479018"
        $ndkDir = Get-ChildItem -Path "$env:ANDROID_HOME\ndk" | Sort-Object Name -Descending | Select-Object -First 1
    } else {
        throw "sdkmanager not found at $sdkManager. Please install NDK manually."
    }
}
$env:ANDROID_NDK_ROOT = $ndkDir.FullName
$env:ANDROID_NDK_HOME = $ndkDir.FullName
Write-Host "[OK] ANDROID_NDK_ROOT set to: $env:ANDROID_NDK_ROOT" -ForegroundColor Green

# 4. CMake & Ninja detection
$cmakeBin = (Get-Command cmake -ErrorAction SilentlyContinue).Source
$ninjaBin = (Get-Command ninja -ErrorAction SilentlyContinue).Source

if (-not $cmakeBin) {
    $vsCmake = "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    if (Test-Path $vsCmake) {
        $cmakeBin = $vsCmake
        $env:PATH = "$(Split-Path $vsCmake -Parent);$env:PATH"
    }
}

if (-not $ninjaBin) {
    $vsNinja = "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
    if (Test-Path $vsNinja) {
        $ninjaBin = $vsNinja
        $env:PATH = "$(Split-Path $vsNinja -Parent);$env:PATH"
    }
}

Write-Host "[OK] CMake: $cmakeBin" -ForegroundColor Green
Write-Host "[OK] Ninja: $ninjaBin" -ForegroundColor Green

# 5. Build Directory Setup
$sourceDir = Resolve-Path "$PSScriptRoot\.."
$buildDir = "$sourceDir\build-android-$AndroidAbi"

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Write-Host "Configuring CMake for Android ($AndroidAbi, $BuildType)..." -ForegroundColor Cyan

# 6. Check Qt installation
if (-not (Test-Path $QtDir)) {
    Write-Host "[NOTICE] Qt for Android target directory not found at $QtDir." -ForegroundColor Yellow
    Write-Host "To install Qt for Android quickly, run:" -ForegroundColor Yellow
    Write-Host "  python -m aqt install-qt windows android 6.8.3 android_arm64_v8a --outputdir C:\Qt" -ForegroundColor White
    Write-Host "  python -m aqt install-qt windows desktop 6.8.3 win64_msvc2022_64 --outputdir C:\Qt" -ForegroundColor White
    Write-Host "Or open the project in Qt Creator with an Android Kit configured." -ForegroundColor Yellow
    Write-Host "Or push to GitHub to build automatically using the GitHub Actions workflow!" -ForegroundColor Cyan
    exit 0
}

$toolchainFile = "$QtDir\lib\cmake\Qt6\qt.toolchain.cmake"

& $cmakeBin -B $buildDir -S $sourceDir `
    -G "Ninja" `
    -DCMAKE_BUILD_TYPE="$BuildType" `
    -DCMAKE_TOOLCHAIN_FILE="$toolchainFile" `
    -DQT_HOST_PATH="$QtHostDir" `
    -DQT_ANDROID_ABIS="$AndroidAbi" `
    -DQGC_CUSTOM_BUILD=ON `
    -DANDROID_SDK_ROOT="$env:ANDROID_HOME" `
    -DANDROID_NDK_ROOT="$env:ANDROID_NDK_ROOT"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Building APK..." -ForegroundColor Cyan
    & $cmakeBin --build $buildDir --target QGroundControl
    Write-Host "Build finished. APK located in $buildDir\android-build" -ForegroundColor Green
}

param(
    [ValidateSet("debug", "release")]
    [string]$Mode = "debug",
    [string]$AdbPath = "C:\tmp\android-platform-tools\platform-tools\adb.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $AdbPath)) {
    throw "adb not found at: $AdbPath"
}

$apkPath = switch ($Mode) {
    "release" { Join-Path $PSScriptRoot "..\build\app\outputs\flutter-apk\app-release.apk" }
    default { Join-Path $PSScriptRoot "..\build\app\outputs\flutter-apk\app-debug.apk" }
}

$resolvedApkPath = (Resolve-Path -LiteralPath $apkPath).Path

& $AdbPath devices
& $AdbPath install -r $resolvedApkPath

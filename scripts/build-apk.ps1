param(
    [ValidateSet("auto", "release", "debug")]
    [string]$Mode = "auto",

    [switch]$SplitPerAbi,

    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$keyPropertiesPath = Join-Path $repoRoot "android\key.properties"
$flutterGitConfigPath = Join-Path $repoRoot ".gitconfig-flutter"

function Resolve-FlutterCommand {
    $localPropertiesPath = Join-Path $repoRoot "android\local.properties"
    if (Test-Path -LiteralPath $localPropertiesPath) {
        $flutterSdkLine = Get-Content -LiteralPath $localPropertiesPath |
            Where-Object { $_ -like "flutter.sdk=*" } |
            Select-Object -First 1
        if ($flutterSdkLine) {
            $flutterSdk = $flutterSdkLine.Substring("flutter.sdk=".Length).Replace("\\", "\")
            $candidate = Join-Path $flutterSdk "bin\flutter.bat"
            if (Test-Path -LiteralPath $candidate) {
                return $candidate
            }
        }
    }

    $pathCandidate = Get-Command "flutter" -ErrorAction SilentlyContinue
    if ($pathCandidate) {
        return $pathCandidate.Source
    }

    throw "Flutter was not found. Add it to PATH or set flutter.sdk in android/local.properties."
}

$flutterCmd = Resolve-FlutterCommand
$flutterBin = Split-Path -Parent $flutterCmd

function Assert-FlutterAvailable {
    if (-not (Test-Path -LiteralPath $flutterCmd)) {
        throw "Flutter was not found at $flutterCmd"
    }
}

function Resolve-BuildMode {
    param([string]$RequestedMode)

    if ($RequestedMode -eq "release") {
        if (-not (Test-Path -LiteralPath $keyPropertiesPath)) {
            throw "Release build requested but android/key.properties does not exist."
        }
        return "release"
    }

    if ($RequestedMode -eq "debug") {
        return "debug"
    }

    if (Test-Path -LiteralPath $keyPropertiesPath) {
        return "release"
    }

    return "debug"
}

function Ensure-FlutterGitSafeDirectory {
    $flutterRoot = Split-Path -Parent $flutterBin
    $env:GIT_CONFIG_GLOBAL = $flutterGitConfigPath
    if (-not (Test-Path -LiteralPath $flutterGitConfigPath)) {
        New-Item -ItemType File -Path $flutterGitConfigPath -Force | Out-Null
    }

    $existingEntries = @(
        git config --file $flutterGitConfigPath --get-all safe.directory 2>$null
    ) | Where-Object { $_ }

    if ($existingEntries -notcontains $flutterRoot) {
        git config --file $flutterGitConfigPath --add safe.directory $flutterRoot
    }
}

function Invoke-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $env:Path += ";$flutterBin"
    & $flutterCmd @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter command failed: flutter $($Arguments -join ' ')"
    }
}

function Get-GoogleDriveDartDefines {
    $defines = @()

    if ($env:GOOGLE_DRIVE_SERVER_CLIENT_ID) {
        $defines += "--dart-define=GOOGLE_DRIVE_SERVER_CLIENT_ID=$($env:GOOGLE_DRIVE_SERVER_CLIENT_ID)"
    }

    if ($env:GOOGLE_DRIVE_IOS_CLIENT_ID) {
        $defines += "--dart-define=GOOGLE_DRIVE_IOS_CLIENT_ID=$($env:GOOGLE_DRIVE_IOS_CLIENT_ID)"
    }

    return $defines
}

Assert-FlutterAvailable
Ensure-FlutterGitSafeDirectory

$resolvedMode = Resolve-BuildMode -RequestedMode $Mode

if (-not $SkipPubGet) {
    Invoke-Flutter -Arguments @("pub", "get")
}

$buildArgs = @("build", "apk", "--$resolvedMode")
if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
}
$buildArgs += Get-GoogleDriveDartDefines

Invoke-Flutter -Arguments $buildArgs

$apkDir = Join-Path $repoRoot "build\app\outputs\flutter-apk"

Write-Host ""
Write-Host "APK build finished." -ForegroundColor Green
Write-Host "Mode: $resolvedMode"
Write-Host "Output: $apkDir"

Get-ChildItem -LiteralPath $apkDir -Filter "*.apk" |
    Sort-Object LastWriteTime -Descending |
    Select-Object LastWriteTime, Length, Name

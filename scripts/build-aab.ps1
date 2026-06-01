param(
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

if (-not (Test-Path -LiteralPath $keyPropertiesPath)) {
    throw "Release AAB requested but android/key.properties does not exist."
}

$env:Path += ";$flutterBin"
$env:GIT_CONFIG_GLOBAL = $flutterGitConfigPath
if (-not (Test-Path -LiteralPath $flutterGitConfigPath)) {
    New-Item -ItemType File -Path $flutterGitConfigPath -Force | Out-Null
}

$flutterRoot = Split-Path -Parent $flutterBin
$existingEntries = @(
    git config --file $flutterGitConfigPath --get-all safe.directory 2>$null
) | Where-Object { $_ }

if ($existingEntries -notcontains $flutterRoot) {
    git config --file $flutterGitConfigPath --add safe.directory $flutterRoot
}

function Invoke-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

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

if (-not $SkipPubGet) {
    Invoke-Flutter -Arguments @("pub", "get")
}

$buildArgs = @("build", "appbundle", "--release")
$buildArgs += Get-GoogleDriveDartDefines
Invoke-Flutter -Arguments $buildArgs

$aabDir = Join-Path $repoRoot "build\app\outputs\bundle\release"

Write-Host ""
Write-Host "AAB release build finished." -ForegroundColor Green
Write-Host "Output: $aabDir"

Get-ChildItem -LiteralPath $aabDir -Filter "*.aab" |
    Sort-Object LastWriteTime -Descending |
    Select-Object LastWriteTime, Length, Name

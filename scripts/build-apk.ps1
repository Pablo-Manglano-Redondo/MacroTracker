param(
    [ValidateSet("auto", "release", "debug")]
    [string]$Mode = "auto",

    [switch]$SplitPerAbi,

    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$flutterBin = "C:\Users\pxblx\Documents\flutter\bin"
$flutterCmd = Join-Path $flutterBin "flutter.bat"
$keyPropertiesPath = Join-Path $repoRoot "android\key.properties"

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

Assert-FlutterAvailable

$resolvedMode = Resolve-BuildMode -RequestedMode $Mode

if (-not $SkipPubGet) {
    Invoke-Flutter -Arguments @("pub", "get")
}

$buildArgs = @("build", "apk", "--$resolvedMode")
if ($SplitPerAbi) {
    $buildArgs += "--split-per-abi"
}

Invoke-Flutter -Arguments $buildArgs

$apkDir = Join-Path $repoRoot "build\app\outputs\flutter-apk"

Write-Host ""
Write-Host "APK build finished." -ForegroundColor Green
Write-Host "Mode: $resolvedMode"
Write-Host "Output: $apkDir"

Get-ChildItem -LiteralPath $apkDir -Filter "*.apk" |
    Sort-Object LastWriteTime -Descending |
    Select-Object LastWriteTime, Length, Name

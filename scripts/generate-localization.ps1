param(
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

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

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "== $Name ==" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE"
    }
}

$flutterCmd = Resolve-FlutterCommand
$env:Path += ";" + (Split-Path -Parent $flutterCmd)

Push-Location $repoRoot
try {
    Invoke-Checked -Name "Shared i18n build" -Command {
        node (Join-Path $repoRoot "scripts\i18n\sync-i18n.mjs") build
    }

    if (-not $SkipPubGet) {
        Invoke-Checked -Name "flutter pub get" -Command {
            & $flutterCmd pub get
        }
    }

    Invoke-Checked -Name "dart run intl_utils:generate" -Command {
        dart run intl_utils:generate
    }

    Invoke-Checked -Name "Localization audit" -Command {
        & (Join-Path $PSScriptRoot "audit-localization.ps1") -FailOnFindings
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "Localization generation finished successfully." -ForegroundColor Green

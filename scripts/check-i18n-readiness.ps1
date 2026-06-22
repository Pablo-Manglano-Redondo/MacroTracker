param(
    [switch]$SkipPubGet,
    [switch]$SkipPortalSmoke,
    [switch]$SkipSupabaseSmoke,
    [switch]$SkipGeneratedDiffCheck
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

$generatedPaths = @(
    "lib/l10n",
    "lib/core/i18n/generated_supported_locales.dart",
    "professional_portal/src/lib/generated/i18n.ts",
    "supabase/functions/_shared/generated_i18n.ts",
    "shared/i18n/supported-locales.json",
    "shared/i18n/locales",
    "shared/i18n/flutter-meta.json"
)

Push-Location $repoRoot
try {
    if (-not $SkipPubGet) {
        Invoke-Checked -Name "flutter pub get" -Command {
            & $flutterCmd pub get
        }
    }

    Invoke-Checked -Name "Shared i18n build" -Command {
        node (Join-Path $repoRoot "scripts\i18n\sync-i18n.mjs") build
    }

    Invoke-Checked -Name "dart run intl_utils:generate" -Command {
        dart run intl_utils:generate
    }

    Invoke-Checked -Name "Localization audit" -Command {
        & (Join-Path $PSScriptRoot "audit-localization.ps1") -FailOnFindings
    }

    if (-not $SkipGeneratedDiffCheck) {
        Invoke-Checked -Name "Generated i18n diff check" -Command {
            git diff --exit-code -- @generatedPaths
        }
    }

    if (-not $SkipPortalSmoke) {
        Invoke-Checked -Name "Portal i18n smoke test" -Command {
            npm --prefix professional_portal run test -- src/lib/date.test.ts
        }
    }

    if (-not $SkipSupabaseSmoke) {
        Invoke-Checked -Name "Supabase i18n smoke test" -Command {
            & (Join-Path $repoRoot "supabase\test.functions.ps1")
        }
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "i18n readiness checks finished successfully." -ForegroundColor Green

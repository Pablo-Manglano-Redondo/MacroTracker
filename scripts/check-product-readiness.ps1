param(
    [switch]$SkipDiffCheck,
    [switch]$SkipFocusedTests,
    [switch]$SkipAndroidBuild
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

function Invoke-CheckedCommand {
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
$flutterBin = Split-Path -Parent $flutterCmd
$env:Path += ";$flutterBin"

if (-not $SkipDiffCheck) {
    Invoke-CheckedCommand -Name "git diff --check" -Command {
        git diff --check
    }
}

if (-not $SkipFocusedTests) {
    Invoke-CheckedCommand -Name "Focused Flutter tests" -Command {
        & $flutterCmd test `
            test/unit_test/cloud_account_deletion_service_test.dart `
            test/unit_test/conversion_analytics_service_test.dart `
            test/unit_test/monetization_service_test.dart `
            test/unit_test/meal_interpretation_remote_data_source_test.dart `
            test/unit_test/bmr_calc_test.dart `
            test/unit_test/bmi_calc_test.dart `
            test/unit_test/macro_calc_test.dart `
            test/unit_test/pal_calc_test.dart `
            test/unit_test/unit_calc_test.dart `
            test/unit_test/gym_target_calc_test.dart `
            test/unit_test/build_weekly_insights_usecase_test.dart `
            test/unit_test/home_bloc_test.dart `
            test/unit_test/intake_repository_crud_test.dart `
            test/unit_test/apply_weekly_kcal_adjustment_usecase_test.dart `
            test/unit_test/scanner_bloc_test.dart `
            test/unit_test/save_body_measurement_usecase_test.dart `
            test/unit_test/professional_usecases_test.dart
    }
}

if (-not $SkipAndroidBuild) {
    Invoke-CheckedCommand -Name "Android debug build" -Command {
        & (Join-Path $PSScriptRoot "check-android-debug.ps1") -SkipPubGet
    }
}

Write-Host ""
Write-Host "Product readiness checks finished successfully." -ForegroundColor Green

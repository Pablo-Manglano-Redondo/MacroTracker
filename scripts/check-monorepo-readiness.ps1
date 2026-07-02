param(
    [switch]$SkipFlutter,
    [switch]$SkipPortal,
    [switch]$SkipSupabase,
    [switch]$SkipAndroidBuild
)

$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $scriptDir

function Invoke-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host " RUNNING: $Name" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE"
    }
}

Push-Location $repoRoot
try {
    # 1. Flutter readiness (calls check-product-readiness.ps1)
    if (-not $SkipFlutter) {
        Invoke-Section "Flutter & Mobile Readiness" {
            $args = @()
            if ($SkipAndroidBuild) {
                $args += "-SkipAndroidBuild"
            }
            & (Join-Path $scriptDir "check-product-readiness.ps1") @args
        }
    }

    # 2. Portal verify
    if (-not $SkipPortal) {
        Invoke-Section "Professional Portal Verification" {
            # Check npm is installed
            $npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
            if (-not $npmCmd) {
                throw "npm was not found. Install Node.js to run portal checks."
            }
            # Run verify command
            npm --prefix professional_portal run verify
        }
    }

    # 3. Supabase tests
    if (-not $SkipSupabase) {
        Invoke-Section "Supabase Edge Functions Tests" {
            & powershell -ExecutionPolicy Bypass -File (Join-Path $repoRoot "supabase\test.functions.ps1")
        }
    }

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host " SUCCESS: Monorepo is fully verified!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
}
finally {
    Pop-Location
}

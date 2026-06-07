param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRef,

    [switch]$SkipSecrets
)

$ErrorActionPreference = "Stop"

$supabaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $supabaseDir
$envFile = Join-Path $supabaseDir ".env.functions"
$exampleEnvFile = Join-Path $supabaseDir ".env.functions.example"

function Assert-CommandAvailable {
    param([string]$Command)

    $null = & $Command --version
}

function Assert-EnvFileReady {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing $Path. Copy $exampleEnvFile to .env.functions and replace the placeholder values."
    }

    $raw = Get-Content -Raw -LiteralPath $Path
    if ($raw -match "YOUR_GEMINI_API_KEY") {
        throw "supabase/.env.functions still contains placeholder values. Set GEMINI_API_KEY before deploying."
    }
    if ($raw -match "YOUR_STRIPE_SECRET_KEY|YOUR_WEBHOOK_SECRET|YOUR_STARTER_PRICE|YOUR_GROWTH_PRICE|YOUR_STUDIO_PRICE") {
        throw "supabase/.env.functions still contains Stripe placeholder values. Set Stripe Pro secrets before deploying."
    }
}

function Assert-SupabaseAuthReady {
    if (-not $env:SUPABASE_ACCESS_TOKEN) {
        Write-Host "SUPABASE_ACCESS_TOKEN is not set. The CLI can still work if you previously ran 'npx supabase login'." -ForegroundColor Yellow
    }
}

Assert-CommandAvailable "npx"
Assert-SupabaseAuthReady

if (-not $SkipSecrets) {
    Assert-EnvFileReady $envFile

    & npx supabase secrets set --env-file $envFile --project-ref $ProjectRef --workdir $repoRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push function secrets."
    }
}

$functions = @(
    "meal-interpretations-text",
    "meal-interpretations-photo",
    "delete-current-account",
    "stripe-pro-checkout",
    "stripe-pro-webhook"
)

foreach ($functionName in $functions) {
    & npx supabase functions deploy $functionName --project-ref $ProjectRef --workdir $repoRoot --use-api
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to deploy $functionName."
    }
}

Write-Host "Supabase functions deployed successfully for project '$ProjectRef'." -ForegroundColor Green

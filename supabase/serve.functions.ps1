param(
    [switch]$NoVerifyJwt
)

$ErrorActionPreference = "Stop"

$supabaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $supabaseDir
$envFile = Join-Path $supabaseDir ".env.functions"

$args = @(
    "--yes",
    "supabase",
    "functions",
    "serve",
    "--env-file",
    $envFile,
    "--workdir",
    $repoRoot
)

if ($NoVerifyJwt) {
    $args += "--no-verify-jwt"
}

& npx @args
exit $LASTEXITCODE

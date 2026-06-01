param()

$ErrorActionPreference = "Stop"

$supabaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $supabaseDir

$denoCommand = Get-Command "deno" -ErrorAction SilentlyContinue
if (-not $denoCommand) {
    throw "Deno was not found. Install Deno or add deno.exe to PATH."
}

& $denoCommand.Source test (Join-Path $supabaseDir "functions\_shared")
exit $LASTEXITCODE

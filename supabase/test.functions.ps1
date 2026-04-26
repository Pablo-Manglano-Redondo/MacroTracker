param()

$ErrorActionPreference = "Stop"

$supabaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $supabaseDir
$denoPath = "C:\Users\pxblx\AppData\Local\Microsoft\WinGet\Packages\DenoLand.Deno_Microsoft.Winget.Source_8wekyb3d8bbwe\deno.exe"

if (Test-Path -LiteralPath $denoPath) {
    & $denoPath test (Join-Path $supabaseDir "functions\_shared")
    exit $LASTEXITCODE
}

& deno test (Join-Path $supabaseDir "functions\_shared")
exit $LASTEXITCODE

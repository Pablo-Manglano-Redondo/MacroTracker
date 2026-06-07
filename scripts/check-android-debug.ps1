param(
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "android"
$daemonDir = Join-Path $env:USERPROFILE ".gradle\daemon\8.14.5"

function Resolve-FlutterCommand {
    $localPropertiesPath = Join-Path $androidDir "local.properties"
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

function Resolve-GradleCommand {
    $distRoot = Join-Path $env:USERPROFILE ".gradle\wrapper\dists\gradle-8.14.5-all"
    if (Test-Path -LiteralPath $distRoot) {
        $candidate = Get-ChildItem -LiteralPath $distRoot -Recurse -Filter gradle.bat -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($candidate) {
            return $candidate.FullName
        }
    }

    return (Join-Path $androidDir "gradlew.bat")
}

function Get-DaemonSnapshots {
    if (-not (Test-Path -LiteralPath $daemonDir)) {
        return @{}
    }

    $snapshot = @{}
    Get-ChildItem -LiteralPath $daemonDir -Filter "daemon-*.out.log" | ForEach-Object {
        $snapshot[$_.FullName] = $_.Length
    }
    return $snapshot
}

function Show-NewDaemonOutput {
    param(
        [hashtable]$Before
    )

    if (-not (Test-Path -LiteralPath $daemonDir)) {
        Write-Host "No Gradle daemon directory found at $daemonDir" -ForegroundColor Yellow
        return
    }

    $updatedLogs = Get-ChildItem -LiteralPath $daemonDir -Filter "daemon-*.out.log" |
        Where-Object {
            -not $Before.ContainsKey($_.FullName) -or $_.Length -gt $Before[$_.FullName]
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3

    foreach ($log in $updatedLogs) {
        Write-Host ""
        Write-Host "==== $($log.Name) ====" -ForegroundColor Cyan
        Get-Content -LiteralPath $log.FullName -Tail 220
    }
}

$flutterCmd = Resolve-FlutterCommand
$gradleCmd = Resolve-GradleCommand
$env:Path += ";" + (Split-Path -Parent $flutterCmd)

if (-not $SkipPubGet) {
    & $flutterCmd pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter command failed: flutter pub get"
    }
}

$before = Get-DaemonSnapshots
Push-Location $androidDir
try {
    & $gradleCmd -p $androidDir :app:assembleDebug --stacktrace --console=plain
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Show-NewDaemonOutput -Before $before
    throw "Android debug build failed with exit code $exitCode"
}

Write-Host ""
Write-Host "Android debug build succeeded." -ForegroundColor Green

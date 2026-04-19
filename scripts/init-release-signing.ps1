param(
    [string]$KeyAlias = "macrotracker-local",
    [string]$StoreFile = "upload-keystore.jks",
    [string]$StorePassword,
    [string]$KeyPassword,
    [string]$DName = "CN=MacroTracker Local, OU=Personal Build, O=MacroTracker, L=Madrid, ST=Madrid, C=ES",
    [int]$ValidityDays = 10000,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "android"
$keyPropertiesPath = Join-Path $androidDir "key.properties"
$storeFilePath = Join-Path $androidDir $StoreFile
$storeFileReference = if ([System.IO.Path]::IsPathRooted($StoreFile)) { $StoreFile.Replace('\', '/') } else { "../$StoreFile" }

function Find-Keytool {
    $candidates = @(
        "C:\Program Files\Java\jdk-21\bin\keytool.exe",
        "C:\Program Files\Java\jdk-19\bin\keytool.exe",
        "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw "keytool.exe not found in expected locations."
}

function New-RandomPassword {
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()
    $random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $buffer = New-Object byte[] 24
    $random.GetBytes($buffer)

    $passwordChars = foreach ($byte in $buffer) {
        $chars[$byte % $chars.Length]
    }

    return -join $passwordChars
}

if (-not $StorePassword) {
    $StorePassword = New-RandomPassword
}

if (-not $KeyPassword) {
    $KeyPassword = $StorePassword
}

$keytool = Find-Keytool

if ($Force -and (Test-Path -LiteralPath $storeFilePath)) {
    Remove-Item -LiteralPath $storeFilePath -Force
}

if (-not (Test-Path -LiteralPath $storeFilePath)) {
    & $keytool -genkeypair `
        -v `
        -keystore $storeFilePath `
        -storetype JKS `
        -storepass $StorePassword `
        -alias $KeyAlias `
        -keyalg RSA `
        -keysize 2048 `
        -validity $ValidityDays `
        -keypass $KeyPassword `
        -dname $DName

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to generate keystore."
    }
}

$keyProperties = @"
storePassword=$StorePassword
keyPassword=$KeyPassword
keyAlias=$KeyAlias
storeFile=$storeFileReference
"@

Set-Content -LiteralPath $keyPropertiesPath -Value $keyProperties -NoNewline

Write-Host "Release signing prepared." -ForegroundColor Green
Write-Host "Keystore: $storeFilePath"
Write-Host "Key properties: $keyPropertiesPath"
Write-Host ""
Write-Host "Keep both files safe. If you lose them, you will not be able to update installs signed with this key." -ForegroundColor Yellow

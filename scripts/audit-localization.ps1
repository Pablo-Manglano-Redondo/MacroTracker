param(
    [switch]$FailOnFindings
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

function Show-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "== $Title ==" -ForegroundColor Cyan
}

function Get-TrackedTextFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Roots,

        [string[]]$ExcludePrefixes = @()
    )

    $files = foreach ($root in $Roots) {
        $absRoot = Join-Path $repoRoot $root
        if (-not (Test-Path -LiteralPath $absRoot)) {
            continue
        }

        Get-ChildItem -LiteralPath $absRoot -Recurse -File | Where-Object {
            $relative = $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
            $excluded = $false
            foreach ($prefix in $ExcludePrefixes) {
                if ($relative.StartsWith($prefix)) {
                    $excluded = $true
                    break
                }
            }
            -not $excluded
        }
    }

    return @($files)
}

function Get-FilesContainingPatternCount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files
    )

    $matchingPaths = foreach ($file in $Files) {
        if (Select-String -Path $file.FullName -Pattern $Pattern -SimpleMatch -Quiet) {
            $file.FullName
        }
    }

    return @($matchingPaths | Sort-Object -Unique).Count
}

function Get-RegexMatches {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo[]]$Files
    )

    $results = foreach ($file in $Files) {
        Select-String -Path $file.FullName -Pattern $Pattern -Encoding UTF8
    }

    return @($results)
}

Show-Section "Generator configuration"
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$pubspec = Get-Content -Raw $pubspecPath
$hasFlutterGenerate = $pubspec -match "(?m)^\s*generate:\s*true\s*$"
$hasFlutterIntl = $pubspec -match "(?m)^flutter_intl:\s*$"
$hasL10nYaml = Test-Path -LiteralPath (Join-Path $repoRoot "l10n.yaml")
$hasIntlClassName = $pubspec -match "(?m)^\s*class_name:\s*S\s*$"
$hasIntlMainLocale = $pubspec -match "(?m)^\s*main_locale:\s*en\s*$"
$hasIntlArbDir = $pubspec -match "(?m)^\s*arb_dir:\s*lib/l10n\s*$"
$hasIntlOutputDir = $pubspec -match "(?m)^\s*output_dir:\s*lib/generated\s*$"

Write-Host ("flutter.generate: {0}" -f $hasFlutterGenerate)
Write-Host ("flutter_intl.enabled block: {0}" -f $hasFlutterIntl)
Write-Host ("l10n.yaml present: {0}" -f $hasL10nYaml)
Write-Host ("flutter_intl.class_name=S: {0}" -f $hasIntlClassName)
Write-Host ("flutter_intl.main_locale=en: {0}" -f $hasIntlMainLocale)
Write-Host ("flutter_intl.arb_dir=lib/l10n: {0}" -f $hasIntlArbDir)
Write-Host ("flutter_intl.output_dir=lib/generated: {0}" -f $hasIntlOutputDir)

Show-Section "Import surface"
$libAndTestFiles = Get-TrackedTextFiles -Roots @("lib", "test")
$generatedImports = Get-FilesContainingPatternCount -Pattern "package:macrotracker/generated/l10n.dart" -Files $libAndTestFiles
$legacyImports = Get-FilesContainingPatternCount -Pattern "package:macrotracker/l10n/s.dart" -Files $libAndTestFiles
Write-Host ("generated/l10n.dart imports: {0}" -f $generatedImports)
Write-Host ("l10n/s.dart imports: {0}" -f $legacyImports)

Show-Section "ARB parity"
$en = Get-Content -Raw (Join-Path $repoRoot "lib/l10n/intl_en.arb") | ConvertFrom-Json
$es = Get-Content -Raw (Join-Path $repoRoot "lib/l10n/intl_es.arb") | ConvertFrom-Json
$enKeys = @($en.PSObject.Properties.Name | Where-Object { $_ -notlike '@*' })
$esKeys = @($es.PSObject.Properties.Name | Where-Object { $_ -notlike '@*' })
$enMeta = @($en.PSObject.Properties.Name | Where-Object { $_ -like '@*' })
$esMeta = @($es.PSObject.Properties.Name | Where-Object { $_ -like '@*' })
$missingInEs = @($enKeys | Where-Object { $_ -notin $esKeys })
$missingInEn = @($esKeys | Where-Object { $_ -notin $enKeys })
$metaMissingInEs = @($enMeta | Where-Object { $_ -notin $esMeta })
$metaMissingInEn = @($esMeta | Where-Object { $_ -notin $enMeta })

Write-Host ("EN keys: {0}" -f $enKeys.Count)
Write-Host ("ES keys: {0}" -f $esKeys.Count)
Write-Host ("Missing keys in ES: {0}" -f $missingInEs.Count)
Write-Host ("Missing keys in EN: {0}" -f $missingInEn.Count)
Write-Host ("Missing metadata in ES: {0}" -f $metaMissingInEs.Count)
Write-Host ("Missing metadata in EN: {0}" -f $metaMissingInEn.Count)

Show-Section "Residual bilingual patterns"
$residualFiles = Get-TrackedTextFiles -Roots @("lib") -ExcludePrefixes @("lib/generated/", "lib/l10n/")
$residualPattern = "\buiText\(|_copy\(|_homeCopy\(|\bisEs\b|Localizations\.localeOf\(context\)\.languageCode == 'es'"
$residualMatches = Get-RegexMatches -Pattern $residualPattern -Files $residualFiles
Write-Host ("Residual matches: {0}" -f $residualMatches.Count)
if ($residualMatches.Count -gt 0) {
    foreach ($match in $residualMatches) {
        $relative = $match.Path.Substring($repoRoot.Length + 1)
        Write-Host ("{0}:{1}: {2}" -f $relative, $match.LineNumber, $match.Line.Trim())
    }
}

Show-Section "Status"
$findings = @()
if ($hasFlutterGenerate -or $hasL10nYaml) {
    $findings += "Legacy or dual l10n generator configuration is still present."
}
if (-not $hasFlutterIntl) {
    $findings += "flutter_intl configuration block is missing."
}
if (-not $hasIntlClassName -or -not $hasIntlMainLocale -or -not $hasIntlArbDir -or -not $hasIntlOutputDir) {
    $findings += "flutter_intl configuration does not fully match the generated/l10n.dart pipeline."
}
if ($legacyImports -gt 0) {
    $findings += "Legacy l10n/s.dart imports still exist."
}
if ($missingInEs.Count -gt 0 -or $missingInEn.Count -gt 0 -or $metaMissingInEs.Count -gt 0 -or $metaMissingInEn.Count -gt 0) {
    $findings += "ARB parity is broken."
}
if ($residualMatches.Count -gt 0) {
    $findings += "Residual ad hoc bilingual patterns still exist."
}

if ($findings.Count -eq 0) {
    Write-Host "Localization audit passed." -ForegroundColor Green
    exit 0
}

$findings | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }

if ($FailOnFindings) {
    throw "Localization audit found issues."
}

<#
.SYNOPSIS
    Generates a Markdown manifest (sizes + SHA-256 hashes) for a locally
    downloaded and extracted Phase 2A GitHub Actions artifact directory.

.DESCRIPTION
    This is a read-only, local helper: it scans a directory you have already
    downloaded and extracted (e.g. the "phase2a-firmware-artifacts" or
    "phase2a-validation-reports" zip from a Phase 2A Windows Validation
    workflow run, from the Actions tab's Artifacts section), looks for
    firmware.dfu, the updater .tgz, and any validation JSON/Markdown reports,
    and writes a Markdown table of their real, independently-computed sizes
    and SHA-256 hashes.

    It does not download anything itself, does not modify firmware, does not
    flash hardware, and does not require administrator privileges. It only
    reads files under -ArtifactDir and writes one new file at -OutFile.

.PARAMETER ArtifactDir
    Path to the already-downloaded-and-extracted artifact directory to scan.

.PARAMETER OutFile
    Path to write the generated Markdown manifest to. Parent directory is
    created if missing. Overwrites if the file already exists.

.EXAMPLE
    .\phase2a_artifact_manifest.ps1 -ArtifactDir "C:\Downloads\phase2a-firmware-artifacts" -OutFile .\phase2a_artifact_hashes.md

.EXAMPLE
    .\phase2a_artifact_manifest.ps1 -ArtifactDir "C:\Downloads\phase2a-validation-reports" -OutFile .\phase2a_report_hashes.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ArtifactDir,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ArtifactDir)) {
    throw "ArtifactDir '$ArtifactDir' does not exist. Download and extract a Phase 2A workflow artifact zip first (Actions tab -> the run -> Artifacts section)."
}
$ArtifactDir = (Resolve-Path $ArtifactDir).Path

$outDir = Split-Path -Parent $OutFile
if ($outDir -and -not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# Files this manifest specifically looks for, by name, anywhere under
# -ArtifactDir. Anything else present is still listed (see "Other files"
# below) so nothing is silently omitted from the manifest, but these are
# called out by their well-known role.
$namedTargets = @('firmware.dfu', 'flipper-z-f7-update-local.tgz')

Write-Host "Scanning $ArtifactDir ..."
$allFiles = Get-ChildItem -Path $ArtifactDir -Recurse -File

$rows = New-Object System.Collections.Generic.List[object]
foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($ArtifactDir.TrimEnd('\', '/').Length).TrimStart('\', '/')
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $role = if ($namedTargets -contains $file.Name) { 'firmware/updater artifact' }
            elseif ($file.Extension -eq '.json' -or $file.Extension -eq '.md') { 'validation report' }
            elseif ($file.Extension -eq '.log') { 'build log' }
            else { 'other' }
    $rows.Add([ordered]@{
        RelativePath = $relPath
        Role         = $role
        SizeBytes    = $file.Length
        Sha256       = $hash
    }) | Out-Null
    Write-Host ("  {0,-12} {1,12:N0} bytes  {2}" -f $role, $file.Length, $relPath)
}

if ($rows.Count -eq 0) {
    Write-Warning "No files found under $ArtifactDir - nothing to write."
}

# Two separate pipelines (not nested Where-Object blocks) so each has its own
# unambiguous $_ - a nested Where-Object sharing $_ with its outer scope is a
# real bug (the inner $_ shadows the outer one), not just a style choice.
# Wrapped in @(...): a Where-Object result matching zero items is $null, not
# an empty array, and $null.Count throws under Set-StrictMode -Version Latest.
$foundFileNames = @($rows | ForEach-Object { Split-Path -Leaf $_.RelativePath })
$missingNamedTargets = @($namedTargets | Where-Object { $foundFileNames -notcontains $_ })

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Phase 2A Local Artifact Hash Manifest') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("Generated: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))") | Out-Null
$lines.Add("Source directory scanned: $ArtifactDir") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('This manifest was generated locally by tools/phase2a_artifact_manifest.ps1') | Out-Null
$lines.Add('against a directory you downloaded and extracted yourself from a GitHub') | Out-Null
$lines.Add('Actions run artifact - it does not download anything, does not modify') | Out-Null
$lines.Add('firmware, and does not flash hardware.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| Role | File | Size (bytes) | SHA-256 |') | Out-Null
$lines.Add('|---|---|---|---|') | Out-Null
foreach ($row in $rows) {
    $lines.Add("| $($row.Role) | ``$($row.RelativePath)`` | $($row.SizeBytes.ToString('N0')) | ``$($row.Sha256)`` |") | Out-Null
}
$lines.Add('') | Out-Null
if ($missingNamedTargets.Count -gt 0) {
    $lines.Add("**Note**: expected file(s) not found under this directory: $($missingNamedTargets -join ', '). This may be expected if you pointed -ArtifactDir at only one of the two Phase 2A artifacts (firmware artifacts vs. validation reports).") | Out-Null
    $lines.Add('') | Out-Null
}
$lines.Add('This manifest reflects only the files actually present in the scanned') | Out-Null
$lines.Add('directory at generation time - it does not claim anything about hardware') | Out-Null
$lines.Add('testing, firmware correctness, or release-readiness.') | Out-Null

($lines -join "`n") | Set-Content -Path $OutFile -Encoding UTF8

Write-Host ''
Write-Host "Wrote manifest to $OutFile ($($rows.Count) file(s))."

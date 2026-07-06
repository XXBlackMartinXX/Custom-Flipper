<#
.SYNOPSIS
    Phase 2A automated validation runner for the Custom-Flipper firmware project.

.DESCRIPTION
    Validates the Phase 2A app-integration batch (network_subnet, programmer_calc,
    vin_decoder, flipper95, chess) on integration/phase2a-first-batch, without
    assuming a physical Flipper Zero is present, and without flashing anything
    unless the caller explicitly opts into HardwareAssisted mode AND passes
    -ConfirmHardwareFlash.

    Three modes:
      Static           (default) - repo/source/config checks only. No build, no
                        hardware interaction, no network access required beyond
                        git itself.
      Build            - runs Static checks, then attempts .\fbt.cmd builds and
                        verifies artifacts. Requires a Windows machine with the
                        real Flipper toolchain (or fbt's own toolchain bootstrap
                        to succeed). If the toolchain/build cannot run, this mode
                        reports BLOCKED with the exact reason - it never fakes a
                        PASS.
      HardwareAssisted - runs Static checks, then looks for a connected Flipper
                        Zero. If none is found, hardware checks are reported
                        NOT RUN. If one is found, the script prints a preflight
                        summary and performs only non-destructive, read-only
                        checks unless -ConfirmHardwareFlash is also passed. This
                        mode never tests RF/Sub-GHz/NFC/RFID/iButton/BadUSB/
                        BLE/GPIO/IR functionality, and never performs anything
                        resembling unauthorized access, cloning, brute force,
                        jamming, or credential handling - by design, this script
                        contains no code paths for any of that, for any app.

    This script does not, and cannot, prove GUI-level app behavior (menu
    rendering, on-screen navigation, in-app correctness) without a human
    watching the device screen. Those checks are explicitly reported as
    REQUIRES HUMAN OBSERVATION or NOT AUTOMATABLE WITH CURRENT TOOLING rather
    than silently skipped or guessed at. See docs/PHASE2A_AUTOMATION_LIMITATIONS.md.

.PARAMETER Mode
    Static (default), Build, or HardwareAssisted.

.PARAMETER ExpectedCommit
    Optional. The exact commit hash you expect HEAD to be at. If supplied and it
    does not match, this is reported as a FAIL for the commit-verification check
    (it does not stop the rest of the run).

.PARAMETER ReportDir
    Directory to write JSON/Markdown reports into. Defaults to reports\phase2a
    under the repo root. Created if it does not exist.

.PARAMETER RepoRoot
    Path to the repository root. Defaults to the parent directory of this
    script's own location (tools\..).

.PARAMETER ConfirmHardwareFlash
    Switch. Only meaningful with -Mode HardwareAssisted. Required in addition to
    -Mode HardwareAssisted before this script will attempt ANY write/flash
    operation against a connected device. Without it, HardwareAssisted mode is
    strictly read-only (detection + preflight summary only).

.PARAMETER SkipBuild
    Switch. With -Mode Build, skip actually invoking fbt.cmd and only verify
    already-existing artifacts (useful for re-running artifact/keyword checks
    without a full rebuild).

.EXAMPLE
    .\phase2a_validate.ps1
    Runs Static mode with defaults. Safe to run anywhere, any time.

.EXAMPLE
    .\phase2a_validate.ps1 -Mode Build -ExpectedCommit 5e5e0ecf225be947a754e537670a6421838b939b
    Runs Static checks, then builds firmware + updater package, then verifies
    artifacts against the expected commit.

.EXAMPLE
    .\phase2a_validate.ps1 -Mode HardwareAssisted
    Runs Static checks, then looks for a connected Flipper Zero. If found, prints
    a preflight summary and performs read-only checks only (no flash, since
    -ConfirmHardwareFlash was not passed).
#>

[CmdletBinding()]
param(
    [ValidateSet('Static', 'Build', 'HardwareAssisted')]
    [string]$Mode = 'Static',

    [string]$ExpectedCommit = '',

    [string]$ReportDir = '',

    [string]$RepoRoot = '',

    [switch]$ConfirmHardwareFlash,

    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

$ScriptRoot = $PSScriptRoot
if (-not $RepoRoot) {
    $RepoRoot = Resolve-Path (Join-Path $ScriptRoot '..')
}
$RepoRoot = (Resolve-Path $RepoRoot).Path

if (-not $ReportDir) {
    $ReportDir = Join-Path $RepoRoot 'reports\phase2a'
}
if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$ConfigPath = Join-Path $ScriptRoot 'phase2a_validate_config.json'
if (-not (Test-Path $ConfigPath)) {
    throw "Config file not found at '$ConfigPath'. This script requires tools\phase2a_validate_config.json to exist alongside it."
}
$Config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json

$RunTimestampUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$RunTimestampForFilename = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss')

# Ordered list of check results. Each entry: Name, Status, Detail, Evidence.
# Status is one of: PASS, FAIL, NEEDS_REVIEW, NOT_RUN, BLOCKED
$script:Results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('PASS', 'FAIL', 'NEEDS_REVIEW', 'NOT_RUN', 'BLOCKED')][string]$Status,
        [string]$Detail = '',
        [object]$Evidence = $null
    )
    $entry = [ordered]@{
        Name     = $Name
        Status   = $Status
        Detail   = $Detail
        Evidence = $Evidence
    }
    $script:Results.Add($entry) | Out-Null

    $color = switch ($Status) {
        'PASS'         { 'Green' }
        'FAIL'         { 'Red' }
        'NEEDS_REVIEW' { 'Yellow' }
        'BLOCKED'      { 'Yellow' }
        default        { 'Gray' }
    }
    Write-Host ("[{0,-12}] {1}" -f $Status, $Name) -ForegroundColor $color
    if ($Detail) {
        Write-Host ("             {0}" -f $Detail) -ForegroundColor DarkGray
    }
}

function Invoke-GitCapture {
    param([Parameter(Mandatory)][string[]]$GitArgs)
    Push-Location $RepoRoot
    try {
        $output = & git @GitArgs 2>&1
        $exitCode = $LASTEXITCODE
        return [ordered]@{ Output = ($output -join "`n"); ExitCode = $exitCode }
    }
    finally {
        Pop-Location
    }
}

Write-Host ''
Write-Host '=== Phase 2A Automated Validation ===' -ForegroundColor Cyan
Write-Host "Mode: $Mode"
Write-Host "Repo: $RepoRoot"
Write-Host "Timestamp (UTC): $RunTimestampUtc"
Write-Host ''

# ---------------------------------------------------------------------------
# Git status BEFORE
# ---------------------------------------------------------------------------

$gitStatusBefore = Invoke-GitCapture -GitArgs @('status', '--porcelain')
$gitStatusBeforeClean = ($gitStatusBefore.Output.Trim() -eq '')

# ---------------------------------------------------------------------------
# STATIC CHECKS (always run, in every mode)
# ---------------------------------------------------------------------------

Write-Host '--- Static checks ---' -ForegroundColor Cyan

# 1. Branch verification
$branchResult = Invoke-GitCapture -GitArgs @('rev-parse', '--abbrev-ref', 'HEAD')
$currentBranch = $branchResult.Output.Trim()
if ($currentBranch -eq $Config.expectedBranch) {
    Add-Result -Name 'Branch verification' -Status 'PASS' -Detail "On expected branch '$currentBranch'"
}
else {
    Add-Result -Name 'Branch verification' -Status 'NEEDS_REVIEW' -Detail "Expected '$($Config.expectedBranch)', found '$currentBranch'. Not automatically a failure if you are intentionally validating a different branch, but confirm this is intended."
}

# 2. Commit verification
$commitResult = Invoke-GitCapture -GitArgs @('rev-parse', 'HEAD')
$currentCommit = $commitResult.Output.Trim()
if ($ExpectedCommit) {
    if ($currentCommit -eq $ExpectedCommit) {
        Add-Result -Name 'Commit verification' -Status 'PASS' -Detail "HEAD matches expected commit $ExpectedCommit"
    }
    else {
        Add-Result -Name 'Commit verification' -Status 'FAIL' -Detail "HEAD is $currentCommit, expected $ExpectedCommit"
    }
}
else {
    Add-Result -Name 'Commit verification' -Status 'NEEDS_REVIEW' -Detail "No -ExpectedCommit supplied; recording actual HEAD ($currentCommit) without comparison. Pass -ExpectedCommit to make this a real PASS/FAIL check."
}

# 3. Working tree cleanliness (before)
if ($gitStatusBeforeClean) {
    Add-Result -Name 'Git status before (clean working tree)' -Status 'PASS' -Detail 'No uncommitted changes at start of run'
}
else {
    Add-Result -Name 'Git status before (clean working tree)' -Status 'NEEDS_REVIEW' -Detail 'Uncommitted changes present before this run started - review before trusting a subsequent build.' -Evidence $gitStatusBefore.Output
}

# 4. Submodule initialization
$submoduleStatusResult = Invoke-GitCapture -GitArgs @('submodule', 'status', '--recursive')
$submoduleLines = $submoduleStatusResult.Output -split "`n" | Where-Object { $_.Trim() -ne '' }
$uninitializedSubmodules = $submoduleLines | Where-Object { $_.TrimStart().StartsWith('-') }
$outOfSyncSubmodules = $submoduleLines | Where-Object { $_.TrimStart().StartsWith('+') }
if ($submoduleLines.Count -eq 0) {
    Add-Result -Name 'Submodule initialization' -Status 'NEEDS_REVIEW' -Detail 'git submodule status returned no lines - is .gitmodules present and populated?'
}
elseif ($uninitializedSubmodules.Count -gt 0) {
    Add-Result -Name 'Submodule initialization' -Status 'FAIL' -Detail "$($uninitializedSubmodules.Count) submodule(s) not initialized. Run: git submodule update --init --recursive" -Evidence ($uninitializedSubmodules -join "`n")
}
elseif ($outOfSyncSubmodules.Count -gt 0) {
    Add-Result -Name 'Submodule initialization' -Status 'NEEDS_REVIEW' -Detail "$($outOfSyncSubmodules.Count) submodule(s) checked out at a different commit than pinned. Run: git submodule update --init --recursive" -Evidence ($outOfSyncSubmodules -join "`n")
}
else {
    Add-Result -Name 'Submodule initialization' -Status 'PASS' -Detail "All $($submoduleLines.Count) submodule(s) initialized and pinned as expected"
}

# 5. Phase 2A app directories exist
$missingApps = New-Object System.Collections.Generic.List[string]
foreach ($app in $Config.expectedApps) {
    $appPath = Join-Path $RepoRoot ($app.path -replace '/', '\')
    if (-not (Test-Path $appPath)) {
        $missingApps.Add($app.id) | Out-Null
    }
}
if ($missingApps.Count -eq 0) {
    Add-Result -Name 'Phase 2A app directories present' -Status 'PASS' -Detail "All $($Config.expectedApps.Count) app directories found"
}
else {
    Add-Result -Name 'Phase 2A app directories present' -Status 'FAIL' -Detail "Missing: $($missingApps -join ', ')"
}

# 6. Application manifest checks (application.fam parses, has appid/name)
$manifestIssues = New-Object System.Collections.Generic.List[string]
$discoveredAppIds = New-Object System.Collections.Generic.List[string]
foreach ($app in $Config.expectedApps) {
    $famPath = Join-Path $RepoRoot (($app.path -replace '/', '\') + '\application.fam')
    if (-not (Test-Path $famPath)) {
        $manifestIssues.Add("$($app.id): application.fam missing at $famPath") | Out-Null
        continue
    }
    $famContent = Get-Content -Raw -Path $famPath
    if ($famContent -notmatch 'appid\s*=\s*"([^"]+)"') {
        $manifestIssues.Add("$($app.id): no appid= found in application.fam") | Out-Null
        continue
    }
    $foundAppId = $Matches[1]
    $discoveredAppIds.Add($foundAppId) | Out-Null
    if ($foundAppId -ne $app.appid) {
        $manifestIssues.Add("$($app.id): expected appid '$($app.appid)', found '$foundAppId'") | Out-Null
    }
    if ($famContent -notmatch 'name\s*=\s*"([^"]+)"') {
        $manifestIssues.Add("$($app.id): no name= found in application.fam") | Out-Null
    }
}
if ($manifestIssues.Count -eq 0) {
    Add-Result -Name 'Application manifests valid' -Status 'PASS' -Detail "All $($Config.expectedApps.Count) application.fam files present and parse as expected"
}
else {
    Add-Result -Name 'Application manifests valid' -Status 'FAIL' -Detail ($manifestIssues -join '; ') -Evidence $manifestIssues
}

# 7. App ID uniqueness (across the 5 Phase 2A apps, and against base applications/)
$duplicateAppIds = $discoveredAppIds | Group-Object | Where-Object { $_.Count -gt 1 }
if ($duplicateAppIds.Count -gt 0) {
    Add-Result -Name 'App ID uniqueness (within Phase 2A batch)' -Status 'FAIL' -Detail "Duplicate appid(s): $(($duplicateAppIds | ForEach-Object { $_.Name }) -join ', ')"
}
else {
    Add-Result -Name 'App ID uniqueness (within Phase 2A batch)' -Status 'PASS' -Detail 'All 5 appids are unique within this batch'
}

$baseApplicationsPath = Join-Path $RepoRoot 'applications'
$collisions = New-Object System.Collections.Generic.List[string]
if (Test-Path $baseApplicationsPath) {
    foreach ($appId in $discoveredAppIds) {
        $pattern = "appid\s*=\s*`"$([regex]::Escape($appId))`""
        $hits = Get-ChildItem -Path $baseApplicationsPath -Recurse -Filter 'application.fam' -ErrorAction SilentlyContinue |
            Select-String -Pattern $pattern -SimpleMatch:$false
        if ($hits) {
            $collisions.Add("$appId collides with $($hits.Path -join ', ')") | Out-Null
        }
    }
    if ($collisions.Count -eq 0) {
        Add-Result -Name 'App ID collision check vs base applications/' -Status 'PASS' -Detail 'No Phase 2A appid collides with a base-firmware app'
    }
    else {
        Add-Result -Name 'App ID collision check vs base applications/' -Status 'FAIL' -Detail ($collisions -join '; ')
    }
}
else {
    Add-Result -Name 'App ID collision check vs base applications/' -Status 'NEEDS_REVIEW' -Detail "Base applications/ directory not found at '$baseApplicationsPath' - is this a full firmware checkout?"
}

# 8. SAM removal sweep (chess)
$samScanPath = Join-Path $RepoRoot ($Config.samRemovalScanPath -replace '/', '\')
$samMatches = New-Object System.Collections.Generic.List[string]
if (Test-Path $samScanPath) {
    $extensions = $Config.samRemovalFileExtensions
    $files = Get-ChildItem -Path $samScanPath -Recurse -File | Where-Object { $extensions -contains $_.Extension }
    $samPattern = ($Config.samRemovalForbiddenKeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
    foreach ($file in $files) {
        $lineHits = Select-String -Path $file.FullName -Pattern "\b($samPattern)\b" -AllMatches
        foreach ($hit in $lineHits) {
            $samMatches.Add("$($hit.Path):$($hit.LineNumber): $($hit.Line.Trim())") | Out-Null
        }
    }
    if ($samMatches.Count -eq 0) {
        Add-Result -Name 'SAM removal verification (chess)' -Status 'PASS' -Detail "Zero matches for sam/stm32_sam/flipchess_voice/speech/voice in $($Config.samRemovalScanPath)"
    }
    else {
        Add-Result -Name 'SAM removal verification (chess)' -Status 'FAIL' -Detail "$($samMatches.Count) forbidden reference(s) found - SAM removal appears incomplete or reverted" -Evidence ($samMatches -join "`n")
    }
}
else {
    Add-Result -Name 'SAM removal verification (chess)' -Status 'NEEDS_REVIEW' -Detail "Scan path '$samScanPath' not found - is chess present?"
}

# 9. Risky keyword scan (all 5 Phase 2A app dirs, substring, not word-bounded)
$riskyMatches = New-Object System.Collections.Generic.List[string]
$riskyExtensions = $Config.riskyKeywordScanFileExtensions
$riskyPattern = ($Config.forbiddenRiskyKeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'
foreach ($app in $Config.expectedApps) {
    $appPath = Join-Path $RepoRoot ($app.path -replace '/', '\')
    if (-not (Test-Path $appPath)) { continue }
    $files = Get-ChildItem -Path $appPath -Recurse -File | Where-Object { $riskyExtensions -contains $_.Extension }
    foreach ($file in $files) {
        $lineHits = Select-String -Path $file.FullName -Pattern $riskyPattern -AllMatches
        foreach ($hit in $lineHits) {
            $riskyMatches.Add("$($hit.Path):$($hit.LineNumber): $($hit.Line.Trim())") | Out-Null
        }
    }
}
if ($riskyMatches.Count -eq 0) {
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'PASS' -Detail 'Zero substring matches for any forbidden keyword across all 5 Phase 2A app directories'
}
else {
    # Deliberately NEEDS_REVIEW, not FAIL: this is a broad substring scan and is
    # expected to hit benign false positives (e.g. "ble" inside "possible",
    # "variable", "double"). Every match is listed, none are hidden or
    # auto-dismissed - a human must confirm each one is benign.
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'NEEDS_REVIEW' -Detail "$($riskyMatches.Count) substring match(es) found - review each one below; this scan is intentionally broad and commonly flags benign words (e.g. 'possible', 'variable', 'double', 'enabled', 'disable', 'table' all contain 'ble'). NEVER auto-classify this as PASS without reviewing the evidence." -Evidence ($riskyMatches -join "`n")
}

# ---------------------------------------------------------------------------
# BUILD CHECKS (only in Build or HardwareAssisted mode)
# ---------------------------------------------------------------------------

$buildRan = $false
if ($Mode -eq 'Build' -or $Mode -eq 'HardwareAssisted') {
    Write-Host ''
    Write-Host '--- Build checks ---' -ForegroundColor Cyan

    $fbtPath = Join-Path $RepoRoot 'fbt.cmd'
    if (-not (Test-Path $fbtPath)) {
        Add-Result -Name 'fbt.cmd present' -Status 'BLOCKED' -Detail "fbt.cmd not found at repo root ($fbtPath). Build mode cannot proceed on this checkout - are you sure this is a full firmware clone, not a docs-only checkout?"
    }
    elseif ($SkipBuild) {
        Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'NOT_RUN' -Detail '-SkipBuild was passed; only checking pre-existing artifacts.'
        Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'NOT_RUN' -Detail '-SkipBuild was passed; only checking pre-existing artifacts.'
    }
    else {
        $buildLogPath = Join-Path $ReportDir "build_firmware_$RunTimestampForFilename.log"
        Push-Location $RepoRoot
        try {
            & .\fbt.cmd COMPACT=1 DEBUG=0 *> $buildLogPath
            $buildExit = $LASTEXITCODE
        }
        catch {
            $buildExit = 1
            Add-Content -Path $buildLogPath -Value "EXCEPTION: $($_.Exception.Message)"
        }
        finally {
            Pop-Location
        }
        if ($buildExit -eq 0) {
            Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'PASS' -Detail "Exit code 0. Full log: $buildLogPath"
            $buildRan = $true
        }
        else {
            Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'FAIL' -Detail "Exit code $buildExit. Full log: $buildLogPath. Check the log for the real root cause (e.g. blocked toolchain download vs. an actual source error) before assuming this is a firmware defect."
        }

        if ($buildExit -eq 0) {
            $updaterLogPath = Join-Path $ReportDir "build_updater_$RunTimestampForFilename.log"
            Push-Location $RepoRoot
            try {
                & .\fbt.cmd COMPACT=1 DEBUG=0 updater_package *> $updaterLogPath
                $updaterExit = $LASTEXITCODE
            }
            catch {
                $updaterExit = 1
                Add-Content -Path $updaterLogPath -Value "EXCEPTION: $($_.Exception.Message)"
            }
            finally {
                Pop-Location
            }
            if ($updaterExit -eq 0) {
                Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'PASS' -Detail "Exit code 0. Full log: $updaterLogPath"
            }
            else {
                Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'FAIL' -Detail "Exit code $updaterExit. Full log: $updaterLogPath"
            }
        }
        else {
            Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'NOT_RUN' -Detail 'Skipped because the firmware build did not exit 0.'
        }
    }

    # Artifact verification (runs regardless of whether we just built, in case
    # -SkipBuild was used to check a prior build's output)
    foreach ($artifactKey in @('firmwareDfu', 'updaterPackage')) {
        $artifactConfig = $Config.expectedArtifacts.$artifactKey
        $artifactPath = Join-Path $RepoRoot $artifactConfig.relativePath
        if (-not (Test-Path $artifactPath)) {
            Add-Result -Name "Artifact present: $($artifactConfig.relativePath)" -Status 'FAIL' -Detail 'File does not exist.'
            continue
        }
        $actualSize = (Get-Item $artifactPath).Length
        $knownSize = $artifactConfig.knownGoodSizeBytes
        $detail = "Size: $actualSize bytes (previously recorded good size at commit $($artifactConfig.knownGoodAtCommit): $knownSize bytes)"
        if ($actualSize -le 0) {
            Add-Result -Name "Artifact present: $($artifactConfig.relativePath)" -Status 'FAIL' -Detail "File exists but is empty or unreadable ($actualSize bytes)."
        }
        elseif ($currentCommit -eq $artifactConfig.knownGoodAtCommit -and $actualSize -ne $knownSize) {
            Add-Result -Name "Artifact present: $($artifactConfig.relativePath)" -Status 'NEEDS_REVIEW' -Detail "$detail - size differs from the previously recorded value AT THE SAME COMMIT. Investigate before trusting this artifact."
        }
        else {
            Add-Result -Name "Artifact present: $($artifactConfig.relativePath)" -Status 'PASS' -Detail $detail
        }
    }

    # Expected FAP outputs per app
    $fapDir = Join-Path $RepoRoot $Config.expectedFapOutputDir
    if (-not (Test-Path $fapDir)) {
        Add-Result -Name 'Per-app FAP output verification' -Status 'NOT_RUN' -Detail "FAP output directory not found at $fapDir - build may not have run, or fbt's output layout differs from this config's assumption ($($Config.expectedFapOutputDir)). If the build itself PASSED above, verify the real output path manually."
    }
    else {
        $missingFaps = New-Object System.Collections.Generic.List[string]
        foreach ($app in $Config.expectedApps) {
            $fapPath = Join-Path $fapDir ("$($app.appid).fap")
            if (-not (Test-Path $fapPath)) {
                $missingFaps.Add($app.appid) | Out-Null
            }
        }
        if ($missingFaps.Count -eq 0) {
            Add-Result -Name 'Per-app FAP output verification' -Status 'PASS' -Detail "All 5 expected .fap files found in $fapDir"
        }
        else {
            Add-Result -Name 'Per-app FAP output verification' -Status 'FAIL' -Detail "Missing .fap for: $($missingFaps -join ', ') in $fapDir"
        }
    }
}
else {
    Add-Result -Name 'Firmware build' -Status 'NOT_RUN' -Detail "Mode is '$Mode' - Build was not requested."
    Add-Result -Name 'Updater package build' -Status 'NOT_RUN' -Detail "Mode is '$Mode' - Build was not requested."
}

# ---------------------------------------------------------------------------
# HARDWARE-ASSISTED CHECKS (only in HardwareAssisted mode)
# ---------------------------------------------------------------------------

if ($Mode -eq 'HardwareAssisted') {
    Write-Host ''
    Write-Host '--- Hardware-assisted checks ---' -ForegroundColor Cyan

    # Detect a connected Flipper Zero via Windows PnP device enumeration.
    # Flipper enumerates as a USB CDC-ACM serial device; look for it by name
    # rather than assuming a fixed COM port.
    $flipperDevice = $null
    try {
        $flipperDevice = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue |
            Where-Object { $_.FriendlyName -match 'Flipper' -or $_.InstanceId -match 'VID_0483&PID_5740' }
    }
    catch {
        Add-Result -Name 'Flipper Zero detection' -Status 'NEEDS_REVIEW' -Detail "Get-PnpDevice failed ($($_.Exception.Message)) - this cmdlet requires Windows. If you are not on Windows, hardware-assisted detection via this method is not available; use a Windows machine for this mode."
    }

    if (-not $flipperDevice) {
        Add-Result -Name 'Flipper Zero detection' -Status 'NOT_RUN' -Detail 'No connected Flipper Zero detected. Hardware-assisted checks cannot proceed. Connect the device (in normal, not DFU, mode) and re-run with -Mode HardwareAssisted if you want to attempt them.'
    }
    else {
        Add-Result -Name 'Flipper Zero detection' -Status 'PASS' -Detail "Detected: $($flipperDevice.FriendlyName) ($($flipperDevice.InstanceId))"

        Write-Host ''
        Write-Host '=== HARDWARE-ASSISTED PREFLIGHT SUMMARY ===' -ForegroundColor Yellow
        Write-Host "Device detected: $($flipperDevice.FriendlyName)"
        Write-Host "Commit under test: $currentCommit"
        Write-Host 'Apps in scope (only these 5, per Phase 2A):'
        foreach ($app in $Config.expectedApps) { Write-Host "  - $($app.displayName) ($($app.appid))" }
        Write-Host ''
        Write-Host 'This script will NOT flash, modify, or write to the device unless you' -ForegroundColor Yellow
        Write-Host 'passed -ConfirmHardwareFlash AND confirm again at the prompt below.' -ForegroundColor Yellow
        Write-Host 'Before proceeding, make sure you have completed:' -ForegroundColor Yellow
        Write-Host '  - docs/PHASE2A_FLASHING_PRECHECK.md (backup, rollback path identified)' -ForegroundColor Yellow
        Write-Host ''

        Add-Result -Name 'Hardware scope confirmation' -Status 'PASS' -Detail 'This run is scoped only to the 5 Phase 2A apps listed above. No RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR feature testing is performed by this script, for any app, under any flag.'

        if (-not $ConfirmHardwareFlash) {
            Add-Result -Name 'Hardware flash/write operations' -Status 'NOT_RUN' -Detail '-ConfirmHardwareFlash was not passed. This run performed detection and preflight summary only - strictly read-only. No data was written to the device.'
        }
        else {
            $confirmation = Read-Host 'Type CONFIRM to proceed with a hardware-assisted flash of the artifacts built above. Anything else cancels.'
            if ($confirmation -ne 'CONFIRM') {
                Add-Result -Name 'Hardware flash/write operations' -Status 'NOT_RUN' -Detail 'User did not type CONFIRM at the interactive prompt. No flash was performed.'
            }
            else {
                Add-Result -Name 'Hardware flash/write operations' -Status 'NEEDS_REVIEW' -Detail 'Flashing was confirmed by the operator, but this script does not itself implement device flashing (that remains a manual qFlipper/fbt flash_usb step by design, so that the human stays in the loop for the one truly irreversible-ish action in this whole workflow). Perform the flash manually now, following docs/PHASE2A_FLASHING_PRECHECK.md, then use the checklist and results template to record what you observe.'
            }
        }

        # GUI-level app checks: explicitly not automated. Listed here so the
        # report is honest about what was and was not attempted, rather than
        # silently omitting them.
        foreach ($app in $Config.expectedApps) {
            Add-Result -Name "App menu/launch/navigation check: $($app.displayName)" -Status 'NOT_RUN' -Detail 'REQUIRES HUMAN OBSERVATION - menu appearance, launch success, on-screen navigation, and in-app behavior cannot be verified by this script without either a human watching the device screen or a dedicated RPC/screen-capture test harness that does not currently exist for this firmware. See docs/PHASE2A_AUTOMATION_LIMITATIONS.md. Use docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md for this app instead.'
        }
        Add-Result -Name 'Chess save/load private-path check' -Status 'NOT_RUN' -Detail 'NOT AUTOMATABLE WITH CURRENT TOOLING from this script alone - verifying that a save file appears only under /ext/apps_data/flipchess/ during actual gameplay requires driving the game (human observation) and then inspecting the SD card, which this script does not do automatically. See docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md, chess section.'
    }
}
else {
    Add-Result -Name 'Flipper Zero detection' -Status 'NOT_RUN' -Detail "Mode is '$Mode' - HardwareAssisted was not requested."
}

# ---------------------------------------------------------------------------
# Git status AFTER
# ---------------------------------------------------------------------------

$gitStatusAfter = Invoke-GitCapture -GitArgs @('status', '--porcelain')
$gitStatusAfterClean = ($gitStatusAfter.Output.Trim() -eq '')

if ($Mode -eq 'Static') {
    if ($gitStatusAfterClean -eq $gitStatusBeforeClean -and ($gitStatusAfter.Output.Trim() -eq $gitStatusBefore.Output.Trim())) {
        Add-Result -Name 'Git status after (unchanged by this run)' -Status 'PASS' -Detail 'Static mode made no changes to the working tree, as expected'
    }
    else {
        Add-Result -Name 'Git status after (unchanged by this run)' -Status 'NEEDS_REVIEW' -Detail 'Working tree changed during a Static run - this should not happen; investigate what wrote to the tree.' -Evidence $gitStatusAfter.Output
    }
}
else {
    # Build/HardwareAssisted modes are expected to produce build artifacts
    # (typically gitignored); just record the state rather than asserting
    # equality.
    Add-Result -Name 'Git status after (recorded)' -Status 'PASS' -Detail 'Recorded for the report. Build/HardwareAssisted modes are expected to produce untracked build output; review the evidence if anything tracked changed unexpectedly.' -Evidence $gitStatusAfter.Output
}

# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

function Get-TrackClassification {
    param([object[]]$Entries)
    if (-not $Entries -or $Entries.Count -eq 0) { return 'NOT_RUN' }
    if ($Entries | Where-Object { $_.Status -eq 'FAIL' }) { return 'FAIL' }
    if ($Entries | Where-Object { $_.Status -eq 'BLOCKED' }) { return 'BLOCKED' }
    if ($Entries | Where-Object { $_.Status -eq 'NEEDS_REVIEW' }) { return 'NEEDS_REVIEW' }
    if ($Entries | Where-Object { $_.Status -eq 'PASS' }) { return 'PASS' }
    return 'NOT_RUN'
}

$staticCheckNames = @(
    'Branch verification', 'Commit verification', 'Git status before (clean working tree)',
    'Submodule initialization', 'Phase 2A app directories present', 'Application manifests valid',
    'App ID uniqueness (within Phase 2A batch)', 'App ID collision check vs base applications/',
    'SAM removal verification (chess)', 'Risky keyword scan (Phase 2A app dirs only)'
)
$staticEntries = $script:Results | Where-Object { $staticCheckNames -contains $_.Name }
$staticClassification = Get-TrackClassification -Entries $staticEntries

if ($Mode -eq 'Static') {
    $buildClassification = 'NOT_RUN'
}
else {
    $buildCheckNames = @(
        'fbt.cmd present', 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)',
        'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)',
        'Per-app FAP output verification'
    )
    $buildArtifactEntries = $script:Results | Where-Object { $_.Name -like 'Artifact present:*' }
    $buildEntries = ($script:Results | Where-Object { $buildCheckNames -contains $_.Name }) + $buildArtifactEntries
    $buildClassification = Get-TrackClassification -Entries $buildEntries
}

if ($Mode -eq 'HardwareAssisted') {
    $hardwareEntries = $script:Results | Where-Object { $_.Name -like '*Hardware*' -or $_.Name -like 'Flipper Zero detection' -or $_.Name -like 'App menu/launch/navigation check:*' -or $_.Name -eq 'Chess save/load private-path check' }
    $deviceDetected = ($script:Results | Where-Object { $_.Name -eq 'Flipper Zero detection' -and $_.Status -eq 'PASS' })
    if (-not $deviceDetected) {
        $hardwareClassification = 'NOT_RUN'
    }
    else {
        $hardwareClassification = Get-TrackClassification -Entries $hardwareEntries
    }
}
else {
    $hardwareClassification = 'NOT_RUN'
}

$overallHasFail = ($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count -gt 0
$overallHasBlocked = ($script:Results | Where-Object { $_.Status -eq 'BLOCKED' }).Count -gt 0
$overallHasNeedsReview = ($script:Results | Where-Object { $_.Status -eq 'NEEDS_REVIEW' }).Count -gt 0

if ($overallHasFail) {
    $overallClassification = 'AUTOMATED VALIDATION FAILED'
    $exitCode = 1
}
elseif ($overallHasBlocked -or $overallHasNeedsReview) {
    $overallClassification = 'NEEDS REVIEW'
    $exitCode = 2
}
else {
    $overallClassification = 'AUTOMATED VALIDATION PASS'
    $exitCode = 0
}

Write-Host ''
Write-Host '=== Classification ===' -ForegroundColor Cyan
Write-Host "Static:   $staticClassification"
Write-Host "Build:    $buildClassification"
Write-Host "Hardware: $hardwareClassification"
Write-Host "Overall:  $overallClassification" -ForegroundColor $(if ($overallClassification -eq 'AUTOMATED VALIDATION PASS') { 'Green' } elseif ($overallClassification -eq 'NEEDS REVIEW') { 'Yellow' } else { 'Red' })
Write-Host ''
Write-Host 'REMINDER: Hardware flashing/testing is NOT PERFORMED unless HardwareAssisted' -ForegroundColor Yellow
Write-Host 'mode actually detected a device and you completed a manual flash + the' -ForegroundColor Yellow
Write-Host 'smoke-test checklist yourself. This script never claims hardware testing on' -ForegroundColor Yellow
Write-Host 'your behalf.' -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------

$reportObject = [ordered]@{
    timestampUtc          = $RunTimestampUtc
    repoPath              = $RepoRoot
    mode                  = $Mode
    branch                = $currentBranch
    commit                = $currentCommit
    expectedCommit        = $ExpectedCommit
    gitStatusBefore        = $gitStatusBefore.Output
    gitStatusBeforeClean   = $gitStatusBeforeClean
    gitStatusAfter         = $gitStatusAfter.Output
    gitStatusAfterClean    = $gitStatusAfterClean
    checks                 = $script:Results
    classification         = [ordered]@{
        static   = $staticClassification
        build    = $buildClassification
        hardware = $hardwareClassification
        overall  = $overallClassification
    }
    nextActions             = @(
        'Review every NEEDS_REVIEW and BLOCKED entry above before treating this run as a clean pass.',
        'Static PASS/NEEDS_REVIEW only validates repository/source state, not runtime behavior.',
        'Build PASS only validates that the firmware compiles and produces artifacts, not that apps behave correctly on hardware.',
        'Hardware PASS/NOT_RUN never implies GUI-level app behavior was verified - see docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md for the manual steps that remain human-only.',
        'Do not proceed to Phase 2B until a human has reviewed this report per docs/PHASE2A_NEXT_GATE.md.'
    )
}

$jsonReportPath = Join-Path $ReportDir "phase2a_validation_$RunTimestampForFilename.json"
$reportObject | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonReportPath -Encoding UTF8

$mdLines = New-Object System.Collections.Generic.List[string]
$mdLines.Add('# Phase 2A Automated Validation Report') | Out-Null
$mdLines.Add('') | Out-Null
$mdLines.Add("Generated: $RunTimestampUtc") | Out-Null
$mdLines.Add("Mode: $Mode") | Out-Null
$mdLines.Add("Repo: $RepoRoot") | Out-Null
$mdLines.Add("Branch: $currentBranch") | Out-Null
$mdLines.Add("Commit: $currentCommit") | Out-Null
$mdLines.Add('') | Out-Null
$mdLines.Add('## Classification') | Out-Null
$mdLines.Add('') | Out-Null
$mdLines.Add("- Static: **$staticClassification**") | Out-Null
$mdLines.Add("- Build: **$buildClassification**") | Out-Null
$mdLines.Add("- Hardware: **$hardwareClassification**") | Out-Null
$mdLines.Add("- Overall: **$overallClassification**") | Out-Null
$mdLines.Add('') | Out-Null
$mdLines.Add('## Checks') | Out-Null
$mdLines.Add('') | Out-Null
$mdLines.Add('| Check | Status | Detail |') | Out-Null
$mdLines.Add('|---|---|---|') | Out-Null
foreach ($entry in $script:Results) {
    $detailEscaped = ($entry.Detail -replace '\|', '\|') -replace "`n", ' '
    $mdLines.Add("| $($entry.Name) | $($entry.Status) | $detailEscaped |") | Out-Null
}
$mdLines.Add('') | Out-Null
$mdLines.Add('## Evidence (only for checks that produced multi-line evidence)') | Out-Null
$mdLines.Add('') | Out-Null
foreach ($entry in $script:Results) {
    if ($entry.Evidence) {
        $mdLines.Add("### $($entry.Name)") | Out-Null
        $mdLines.Add('') | Out-Null
        $mdLines.Add('```') | Out-Null
        $evidenceText = if ($entry.Evidence -is [string]) { $entry.Evidence } else { ($entry.Evidence -join "`n") }
        $mdLines.Add($evidenceText) | Out-Null
        $mdLines.Add('```') | Out-Null
        $mdLines.Add('') | Out-Null
    }
}
$mdLines.Add('## Next actions') | Out-Null
$mdLines.Add('') | Out-Null
foreach ($action in $reportObject.nextActions) {
    $mdLines.Add("- $action") | Out-Null
}
$mdLines.Add('') | Out-Null
$mdLines.Add('**Hardware flashing/testing is NOT PERFORMED unless explicitly run in HardwareAssisted mode with a detected device and a manually-confirmed flash.** This report does not claim hardware testing on your behalf.') | Out-Null

$mdReportPath = Join-Path $ReportDir "phase2a_validation_$RunTimestampForFilename.md"
($mdLines -join "`n") | Set-Content -Path $mdReportPath -Encoding UTF8

Write-Host ''
Write-Host "JSON report: $jsonReportPath"
Write-Host "Markdown report: $mdReportPath"

exit $exitCode

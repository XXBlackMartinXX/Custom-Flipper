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

.PARAMETER ConfigPath
    Optional. Path to an alternate config JSON (same schema as
    phase2a_validate_config.json). Defaults to tools\phase2a_validate_config.json
    alongside this script - existing invocations without this parameter are
    unaffected. Added so later batches (e.g. Phase 2B) can validate their own
    app list/branch/reviewed-false-positives without touching the frozen Phase 2A
    config.

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

    [switch]$SkipBuild,

    [string]$ConfigPath = ''
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

if (-not $ConfigPath) {
    $ConfigPath = Join-Path $ScriptRoot 'phase2a_validate_config.json'
}
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
        [Parameter(Mandatory)][ValidateSet('PASS', 'PASS_WITH_REVIEWED_FALSE_POSITIVES', 'FAIL', 'NEEDS_REVIEW', 'NOT_RUN', 'BLOCKED')][string]$Status,
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
        'PASS'                                { 'Green' }
        'PASS_WITH_REVIEWED_FALSE_POSITIVES'  { 'Green' }
        'FAIL'                                { 'Red' }
        'NEEDS_REVIEW'                        { 'Yellow' }
        'BLOCKED'                             { 'Yellow' }
        default                               { 'Gray' }
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

# Used by the reviewed-false-positive mechanism below: a match is only ever
# treated as reviewed when file + line number + keyword + this hash of the
# exact trimmed line text all match an entry in the config's
# reviewedFalsePositives list. Any edit to the matched line changes the hash
# and the match reverts to unreviewed automatically - there is no way for a
# stale allowlist entry to keep silently covering changed code.
function Get-LineSha256 {
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Text)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $hashBytes = $sha256.ComputeHash($bytes)
        return -join ($hashBytes | ForEach-Object { $_.ToString('x2') })
    }
    finally {
        $sha256.Dispose()
    }
}

function Get-RepoRelativePath {
    param([Parameter(Mandatory)][string]$FullPath)
    $repoRootFull = $RepoRoot.TrimEnd('\', '/')
    $rel = $FullPath.Substring($repoRootFull.Length).TrimStart('\', '/')
    return ($rel -replace '\\', '/')
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
# Wrapped in @(...): a Where-Object pipeline that matches zero items returns $null,
# not an empty array, and $null.Count throws under Set-StrictMode -Version Latest.
# @(...) guarantees an array (possibly empty) so .Count is always safe below.
$submoduleLines = @($submoduleStatusResult.Output -split "`n" | Where-Object { $_.Trim() -ne '' })
$uninitializedSubmodules = @($submoduleLines | Where-Object { $_.TrimStart().StartsWith('-') })
$outOfSyncSubmodules = @($submoduleLines | Where-Object { $_.TrimStart().StartsWith('+') })
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
$duplicateAppIds = @($discoveredAppIds | Group-Object | Where-Object { $_.Count -gt 1 })
if ($duplicateAppIds.Count -gt 0) {
    Add-Result -Name 'App ID uniqueness (within Phase 2A batch)' -Status 'FAIL' -Detail "Duplicate appid(s): $(($duplicateAppIds | ForEach-Object { $_.Name }) -join ', ')"
}
else {
    Add-Result -Name 'App ID uniqueness (within Phase 2A batch)' -Status 'PASS' -Detail "All $($discoveredAppIds.Count) appids are unique within this batch"
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
#
# Reviewed-false-positive mechanism (tools/phase2a_validate_config.json's
# reviewedFalsePositives): a live match only counts as "reviewed" when ALL
# FOUR of (file path, line number, keyword, SHA-256 hash of the exact
# trimmed line text) match an allowlist entry exactly. This is deliberately
# not a blanket suppression of a keyword or a directory - if a matched line
# is edited, moved, or renamed, the match reverts to unreviewed automatically.
#
# Three-way split, most severe first:
#   - unreviewed match on a highConfidenceUnsafeKeywords keyword -> hard FAIL
#   - unreviewed match on any other forbidden keyword           -> NEEDS_REVIEW
#   - every match accounted for by a reviewed entry              -> PASS_WITH_REVIEWED_FALSE_POSITIVES
#   - zero matches at all                                        -> PASS
$riskyExtensions = $Config.riskyKeywordScanFileExtensions
$riskyKeywordList = @($Config.forbiddenRiskyKeywords)
$highConfidenceKeywords = @($Config.highConfidenceUnsafeKeywords)

$reviewedLookup = @{}
foreach ($r in @($Config.reviewedFalsePositives)) {
    $key = "$($r.file)|$($r.line)|$($r.keyword)|$($r.lineSha256)"
    $reviewedLookup[$key] = $r
}

$reviewedMatches = New-Object System.Collections.Generic.List[string]
$genericUnreviewed = New-Object System.Collections.Generic.List[string]
$highConfidenceUnreviewed = New-Object System.Collections.Generic.List[string]

foreach ($app in $Config.expectedApps) {
    $appPath = Join-Path $RepoRoot ($app.path -replace '/', '\')
    if (-not (Test-Path $appPath)) { continue }
    $files = Get-ChildItem -Path $appPath -Recurse -File | Where-Object { $riskyExtensions -contains $_.Extension }
    foreach ($file in $files) {
        $relPath = Get-RepoRelativePath -FullPath (Resolve-Path $file.FullName).Path
        $lines = @(Get-Content -Path $file.FullName)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $lineText = $lines[$i]
            $lineNumber = $i + 1
            foreach ($kw in $riskyKeywordList) {
                if ($lineText -imatch [regex]::Escape($kw)) {
                    $trimmed = $lineText.Trim()
                    $hash = Get-LineSha256 -Text $trimmed
                    $key = "$relPath|$lineNumber|$kw|$hash"
                    if ($reviewedLookup.ContainsKey($key)) {
                        $entry = $reviewedLookup[$key]
                        $reviewedMatches.Add("${relPath}:${lineNumber} [$kw]: $($entry.reason)") | Out-Null
                    }
                    elseif ($highConfidenceKeywords -contains $kw) {
                        $highConfidenceUnreviewed.Add("${relPath}:${lineNumber} [$kw]: $trimmed") | Out-Null
                    }
                    else {
                        $genericUnreviewed.Add("${relPath}:${lineNumber} [$kw]: $trimmed") | Out-Null
                    }
                }
            }
        }
    }
}

$totalRiskyMatches = $reviewedMatches.Count + $genericUnreviewed.Count + $highConfidenceUnreviewed.Count

if ($highConfidenceUnreviewed.Count -gt 0) {
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'FAIL' -Detail "$($highConfidenceUnreviewed.Count) UNREVIEWED high-confidence unsafe API/capability match(es) found (of $totalRiskyMatches total match(es)). These keywords ($($highConfidenceKeywords -join ', ')) require an explicit, narrowly-justified entry in tools/phase2a_validate_config.json's reviewedFalsePositives before they can pass - none currently covers these specific line(s). This is a hard FAIL, not a review item." -Evidence ($highConfidenceUnreviewed -join "`n")
}
elseif ($genericUnreviewed.Count -gt 0) {
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'NEEDS_REVIEW' -Detail "$($genericUnreviewed.Count) unreviewed substring match(es) found (of $totalRiskyMatches total). Review each one below and, if benign, add a reviewedFalsePositives entry (file + line + keyword + line-content hash + reason) to tools/phase2a_validate_config.json. This scan is intentionally broad and commonly flags benign words (e.g. 'possible', 'variable', 'double' all contain 'ble'). NEVER auto-classify this as PASS without reviewing the evidence." -Evidence ($genericUnreviewed -join "`n")
}
elseif ($totalRiskyMatches -gt 0) {
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'PASS_WITH_REVIEWED_FALSE_POSITIVES' -Detail "$totalRiskyMatches substring match(es) found; all $($reviewedMatches.Count) matched an exact, individually-reviewed entry in tools/phase2a_validate_config.json (file + line + keyword + line-content hash - any future edit to a matched line reverts it to unreviewed automatically). Zero unreviewed matches, zero high-confidence-unsafe matches." -Evidence ($reviewedMatches -join "`n")
}
else {
    Add-Result -Name 'Risky keyword scan (Phase 2A app dirs only)' -Status 'PASS' -Detail "Zero substring matches for any forbidden keyword across all $($Config.expectedApps.Count) configured app directories"
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
        # Phase 2F.2A diagnostics: printed once, before the firmware build
        # even starts, purely additive (no pass/fail logic changed) - added
        # to investigate why build\f7-firmware-C\.extapps was found empty
        # of all expected .fap outputs on 2 of 2 real Phase 2F.2 CI
        # attempts, immediately after a firmware build that itself reported
        # exit code 0 both times. Narrow in scope: no secrets printed, no
        # behavior changed.
        Write-Host ''
        Write-Host '--- Pre-firmware-build diagnostics (Phase 2F.2A) ---' -ForegroundColor Cyan
        try {
            $cmdCommand = Get-Command cmd.exe -ErrorAction Stop
            Write-Host "cmd.exe resolved to: $($cmdCommand.Source)"
            cmd /c "ver" 2>&1 | ForEach-Object { Write-Host "  $_" }
        }
        catch {
            Write-Host "cmd.exe resolution check unavailable: $($_.Exception.Message)"
        }
        Write-Host "Runner image: ImageOS=$env:ImageOS ImageVersion=$env:ImageVersion"
        Write-Host "ComSpec=$env:ComSpec NUMBER_OF_PROCESSORS=$env:NUMBER_OF_PROCESSORS TEMP=$env:TEMP TMP=$env:TMP"
        $fbtItemPre = Get-Item $fbtPath
        Write-Host "fbt.cmd metadata: Length=$($fbtItemPre.Length) LastWriteTime=$($fbtItemPre.LastWriteTime) Attributes=$($fbtItemPre.Attributes)"
        Write-Host 'fbt.cmd first 5 lines:'
        Get-Content -Path $fbtPath -TotalCount 5 | ForEach-Object { Write-Host "  $_" }
        try {
            $fbtAcl = Get-Acl -Path $fbtPath -ErrorAction Stop
            Write-Host "fbt.cmd owner: $($fbtAcl.Owner)"
            $aclSummary = ($fbtAcl.Access | ForEach-Object { "$($_.IdentityReference):$($_.FileSystemRights)" }) -join '; '
            Write-Host "fbt.cmd access rules: $aclSummary"
        }
        catch {
            Write-Host "fbt.cmd ACL check unavailable: $($_.Exception.Message)"
        }
        foreach ($newAppPath in @('applications_user\qrcode', 'applications_user\hex_viewer', 'applications_user\barcode_gen')) {
            $fullNewAppPath = Join-Path $RepoRoot $newAppPath
            Write-Host "Listing ${newAppPath}:"
            if (Test-Path $fullNewAppPath) {
                Get-ChildItem -Path $fullNewAppPath -Recurse -File | ForEach-Object { Write-Host "  $($_.FullName.Substring($RepoRoot.Length + 1)) ($($_.Length) bytes)" }
            }
            else {
                Write-Host "  NOT FOUND at $fullNewAppPath"
            }
        }
        Write-Host 'Parsed appids for all expected apps (from application.fam):'
        foreach ($appEntry in $Config.expectedApps) {
            $appFamPath = Join-Path $RepoRoot (Join-Path $appEntry.path 'application.fam')
            if (Test-Path $appFamPath) {
                $famContent = Get-Content -Raw -Path $appFamPath
                $appidMatch = [regex]::Match($famContent, 'appid\s*=\s*"([^"]+)"')
                $parsedAppid = if ($appidMatch.Success) { $appidMatch.Groups[1].Value } else { '(could not parse)' }
                Write-Host "  $($appEntry.path): expected='$($appEntry.appid)' parsed='$parsedAppid' $(if ($parsedAppid -ne $appEntry.appid) { '<<< MISMATCH' })"
            }
            else {
                Write-Host "  $($appEntry.path): application.fam NOT FOUND"
            }
        }
        Write-Host '--- End pre-firmware-build diagnostics ---'
        Write-Host ''
        # Distinguish two different failure kinds, which need different
        # classifications: the *process could not be launched at all* (a
        # native "failed to start" exception - an environment problem, e.g.
        # fbt.cmd isn't natively executable on this OS, or a permissions
        # issue) versus the *process launched and exited non-zero* (a real
        # build failure worth investigating as a possible source defect).
        # Conflating these into one generic FAIL would misclassify an
        # environment problem as a firmware problem.
        $buildLogPath = Join-Path $ReportDir "build_firmware_$RunTimestampForFilename.log"
        $buildLaunchFailed = $false
        Push-Location $RepoRoot
        try {
            & .\fbt.cmd COMPACT=1 DEBUG=0 *> $buildLogPath
            $buildExit = $LASTEXITCODE
        }
        catch {
            $buildLaunchFailed = $true
            $buildExit = 1
            $buildLaunchExceptionText = "LAUNCH EXCEPTION (process could not be started - this is an environment problem, not evidence of a source defect): $($_.Exception.GetType().FullName): $($_.Exception.Message)"
            Add-Content -Path $buildLogPath -Value $buildLaunchExceptionText
            # Phase 2F.2A: also print to console (not just the log file),
            # since the log file only exists inside a workflow artifact that
            # may not always be downloadable for inspection.
            Write-Host $buildLaunchExceptionText -ForegroundColor Red
        }
        finally {
            Pop-Location
        }
        if ($buildExit -eq 0) {
            Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'PASS' -Detail "Exit code 0. Full log: $buildLogPath"
            $buildRan = $true
        }
        elseif ($buildLaunchFailed) {
            Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'BLOCKED' -Detail "fbt.cmd could not be launched as a process on this machine/OS (see $buildLogPath for the exact exception). This is an environment limitation, not a build failure or firmware defect - it means this environment cannot run the build at all, so nothing about the source was actually tested."
        }
        else {
            Add-Result -Name 'Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)' -Status 'FAIL' -Detail "fbt.cmd launched and exited $buildExit. Full log: $buildLogPath. Check the log for the real root cause (e.g. blocked toolchain download vs. an actual source error) before assuming this is a firmware defect."
        }

        if ($buildExit -eq 0) {
            # Phase 2D.2A diagnostics: the updater_package sub-invocation of
            # fbt.cmd proved reproducibly unable to launch as a process in
            # real CI (2 of 3 attempts, 2 different runner instances) even
            # though the firmware build immediately above it succeeded every
            # time with the identical invocation style. Print narrow,
            # non-secret diagnostics here - immediately before the
            # updater_package attempt - so a future failure carries the
            # evidence needed to root-cause it, instead of just the generic
            # "could not be launched" catch-all message.
            Write-Host ''
            Write-Host '--- Pre-updater_package diagnostics (Phase 2D.2A) ---' -ForegroundColor Cyan
            Write-Host "Current directory: $(Get-Location)"
            Write-Host "Repo root: $RepoRoot"
            $fbtExists = Test-Path $fbtPath
            Write-Host "fbt.cmd exists: $fbtExists"
            if ($fbtExists) {
                $fbtItem = Get-Item $fbtPath
                Write-Host "fbt.cmd metadata: Length=$($fbtItem.Length) LastWriteTime=$($fbtItem.LastWriteTime) Attributes=$($fbtItem.Attributes)"
                $fbtCmdCommand = Get-Command $fbtPath -ErrorAction SilentlyContinue
                Write-Host "Get-Command .\fbt.cmd: $($fbtCmdCommand | Out-String)"
            }
            cmd /c "dir `"$fbtPath`"" 2>&1 | ForEach-Object { Write-Host "  $_" }
            Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
            # Phase 2F.2A diagnostic: the workflow declares `shell: pwsh`
            # (PowerShell 7/Core), but $PSVersionTable.PSVersion alone
            # doesn't distinguish engines cleanly across all reporting
            # contexts - print PSEdition and the full table explicitly so a
            # human reviewing the log can conclusively confirm which engine
            # (Desktop = Windows PowerShell 5.1, Core = PowerShell 7) is
            # actually executing this diagnostic block, immediately before
            # the updater_package attempt.
            Write-Host "PowerShell edition: $($PSVersionTable.PSEdition)"
            Write-Host "Full PSVersionTable: $($PSVersionTable | Out-String)"
            Write-Host "`$PID of this process: $PID"
            try {
                $parentProc = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$PID" -ErrorAction Stop
                Write-Host "This process's own image: $($parentProc.ExecutablePath)"
                $grandParent = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$($parentProc.ParentProcessId)" -ErrorAction SilentlyContinue
                if ($grandParent) { Write-Host "Parent process image: $($grandParent.ExecutablePath)" }
            }
            catch {
                Write-Host "Process image check unavailable: $($_.Exception.Message)"
            }
            Write-Host "OS version: $([System.Environment]::OSVersion.VersionString)"
            $diagGitStatus = (Invoke-GitCapture -GitArgs @('status', '--porcelain')).Output
            Write-Host "git status --short (diagnostic, immediately pre-updater_package):"
            Write-Host $(if ([string]::IsNullOrWhiteSpace($diagGitStatus)) { '(clean)' } else { $diagGitStatus })
            $firmwareDfuPath = Join-Path $RepoRoot 'build\f7-firmware-C\firmware.dfu'
            $extappsPath = Join-Path $RepoRoot 'build\f7-firmware-C\.extapps'
            Write-Host "build\f7-firmware-C\firmware.dfu exists: $(Test-Path $firmwareDfuPath)"
            Write-Host "build\f7-firmware-C\.extapps exists: $(Test-Path $extappsPath)"

            # Phase 2F.2A diagnostics: on 2 of 2 real Phase 2F.2 CI attempts,
            # build\f7-firmware-C\.extapps was found empty of all 19 expected
            # .fap files at this exact checkpoint, immediately after a
            # firmware build that itself reported exit code 0. Purely
            # additive - no pass/fail logic changed here, only console
            # visibility into where (if anywhere) real .fap files actually
            # exist on this runner.
            $f7BuildDir = Join-Path $RepoRoot 'build\f7-firmware-C'
            if (Test-Path $f7BuildDir) {
                Write-Host "Recursive listing of build\f7-firmware-C\ (top-level entries):"
                Get-ChildItem -Path $f7BuildDir | ForEach-Object {
                    $entryDesc = if ($_.PSIsContainer) { 'dir' } else { "$($_.Length) bytes" }
                    Write-Host "  $($_.Name) [$entryDesc]"
                }
            }
            else {
                Write-Host "build\f7-firmware-C\ does not exist at all."
            }
            if (Test-Path $extappsPath) {
                Write-Host "Recursive listing of build\f7-firmware-C\.extapps\:"
                Get-ChildItem -Path $extappsPath -Recurse -Force | ForEach-Object { Write-Host "  $($_.FullName.Substring($RepoRoot.Length + 1)) ($($_.Length) bytes)" }
            }
            $buildDirPath = Join-Path $RepoRoot 'build'
            # The outer @(...) here is load-bearing, not decorative: an `if`
            # expression whose taken branch is itself `@(Get-ChildItem ...)`
            # still collapses to $null on assignment when that Get-ChildItem
            # produces zero pipeline output - the inner @() alone does not
            # survive being returned through the if-expression. Reproduced
            # locally (this exact inner-only pattern assigns $null, not an
            # empty array, causing a PropertyNotFoundException on .Count
            # under Set-StrictMode -Version Latest). Wrapping the entire
            # if/else in an outer @() is what actually guarantees an array.
            $fapsUnderBuild = @(if (Test-Path $buildDirPath) { @(Get-ChildItem -Path $buildDirPath -Recurse -Filter '*.fap' -File -ErrorAction SilentlyContinue) } else { @() })
            Write-Host "Real .fap files found anywhere under build\ (recursive): $($fapsUnderBuild.Count)"
            $fapsUnderBuild | ForEach-Object { Write-Host "  $($_.FullName.Substring($RepoRoot.Length + 1)) ($($_.Length) bytes)" }
            $fapsRepoWide = @(Get-ChildItem -Path $RepoRoot -Recurse -Filter '*.fap' -File -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\\.git\\' })
            Write-Host "Real .fap files found anywhere in the repo (recursive, excluding .git): $($fapsRepoWide.Count)"
            $fapsRepoWide | ForEach-Object { Write-Host "  $($_.FullName.Substring($RepoRoot.Length + 1)) ($($_.Length) bytes)" }
            foreach ($namedFap in @('qrcode.fap', 'hex_viewer.fap', 'barcode_app.fap')) {
                $found = $fapsRepoWide | Where-Object { $_.Name -eq $namedFap }
                if ($found) {
                    Write-Host "$namedFap FOUND at: $(($found | ForEach-Object { $_.FullName.Substring($RepoRoot.Length + 1) }) -join ', ')"
                }
                else {
                    Write-Host "$namedFap NOT FOUND anywhere in the repo."
                }
            }
            $uploadGlobPath = Join-Path $RepoRoot 'build\f7-firmware-C\.extapps'
            # Same load-bearing outer @() as $fapsUnderBuild above - see that
            # comment for the reproduced-locally explanation.
            $uploadGlobMatches = @(if (Test-Path $uploadGlobPath) { @(Get-ChildItem -Path $uploadGlobPath -Filter '*.fap' -File -ErrorAction SilentlyContinue) } else { @() })
            Write-Host "Files the workflow's own upload-artifact glob (build/f7-firmware-C/.extapps/*.fap) would match: $($uploadGlobMatches.Count)"
            try {
                $repoDriveLetter = (Get-Item $RepoRoot).PSDrive.Name
                $repoDrive = Get-PSDrive -Name $repoDriveLetter -ErrorAction Stop
                Write-Host "Disk space on ${repoDriveLetter}: free=$([math]::Round($repoDrive.Free/1GB,2))GB used=$([math]::Round($repoDrive.Used/1GB,2))GB"
            }
            catch {
                Write-Host "Disk space check unavailable: $($_.Exception.Message)"
            }
            try {
                $mpStatus = Get-MpComputerStatus -ErrorAction Stop
                Write-Host "Windows Defender real-time protection enabled: $($mpStatus.RealTimeProtectionEnabled)"
            }
            catch {
                Write-Host "Windows Defender status check unavailable (not present or inaccessible on this runner): $($_.Exception.Message)"
            }
            Write-Host "PATH (first 500 chars): $($env:PATH.Substring(0, [Math]::Min(500, $env:PATH.Length)))"
            Write-Host '--- End pre-updater_package diagnostics ---'
            Write-Host ''

            $updaterLogPath = Join-Path $ReportDir "build_updater_$RunTimestampForFilename.log"
            $updaterLaunchFailed = $false
            Push-Location $RepoRoot
            $previousUpdaterErrorActionPreference = $ErrorActionPreference
            try {
                # Phase 2D.2A fix: launch via an explicit `cmd /c` wrapper
                # rather than PowerShell's own `&` call operator. This is
                # the narrowest change that alters only *how* the same
                # command (identical fbt.cmd, identical arguments) is
                # launched, not the build target, not the pass/fail
                # criteria, and not any other call site (the firmware build
                # invocation above is deliberately left untouched, since it
                # has a 3-for-3 real-CI success record). `cmd /c` hands the
                # actual process creation to cmd.exe itself, sidestepping
                # whatever PowerShell-level process-creation condition was
                # producing a native launch exception specifically for the
                # second fbt.cmd invocation in the same job.
                #
                # Phase 2F.2A root-cause fix: real CI run 29003824450 caught,
                # for the first time, the actual exception behind every prior
                # "fbt.cmd could not be launched" classification - it was
                # never a process-launch failure. It was a
                # System.Management.Automation.RemoteException wrapping the
                # first line of native stderr emitted while compiling
                # applications_user\barcode_gen\views\create_view.c ("In
                # function 'text_input_callback':"). Under
                # $ErrorActionPreference = 'Stop' (script scope, line ~109),
                # Windows PowerShell wraps a native command's stderr output in
                # NativeCommandError records; the first such record becomes a
                # terminating exception, aborting the whole updater_package
                # invocation before it can finish emitting that diagnostic,
                # let alone complete the FAP build - regardless of whether
                # the stderr text represents a real fatal compiler error or
                # an ordinary diagnostic/warning. This is the direct, evidenced
                # explanation for why build\f7-firmware-C\.extapps has been
                # empty and zero .fap files have ever been produced anywhere
                # in this project's Phase 2F.2/2F.2A CI history: the
                # FAP-compiling step of updater_package never got to run to
                # completion. Scoping $ErrorActionPreference to 'Continue' for
                # just this external invocation lets native stderr text land
                # in the log like any other output instead of being escalated
                # to a terminating exception; $LASTEXITCODE (captured below)
                # remains the real, authoritative pass/fail signal, exactly as
                # it already is for the firmware build above.
                $ErrorActionPreference = 'Continue'
                cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0 updater_package" *> $updaterLogPath
                $updaterExit = $LASTEXITCODE
            }
            catch {
                $updaterLaunchFailed = $true
                $updaterExit = 1
                $updaterLaunchExceptionText = "LAUNCH EXCEPTION (process could not be started - this is an environment problem, not evidence of a source defect): $($_.Exception.GetType().FullName): $($_.Exception.Message)"
                Add-Content -Path $updaterLogPath -Value $updaterLaunchExceptionText
                # Phase 2F.2A: also print to console (not just the log
                # file), since the log file only exists inside a workflow
                # artifact that may not always be downloadable for
                # inspection - this is the single most important missing
                # piece of evidence from the 2 real Phase 2F.2 CI failures.
                Write-Host $updaterLaunchExceptionText -ForegroundColor Red
                if ($_.Exception.InnerException) {
                    Write-Host "Inner exception: $($_.Exception.InnerException.GetType().FullName): $($_.Exception.InnerException.Message)" -ForegroundColor Red
                }
            }
            finally {
                $ErrorActionPreference = $previousUpdaterErrorActionPreference
                Pop-Location
            }
            # Phase 2F.2A: the updater_package log file only exists inside a
            # workflow artifact that has proven repeatedly undownloadable for
            # direct inspection this phase. Now that the stderr/exception fix
            # above lets the real build run to a real exit code instead of
            # aborting early, print the log's own tail directly to console so
            # the actual compiler/scons output (not just the exit code) is
            # visible here - this is required to tell a genuine compile
            # defect apart from any other non-zero-exit cause, without
            # guessing.
            if (Test-Path $updaterLogPath) {
                $updaterLogTail = Get-Content -Path $updaterLogPath -Tail 150
                Write-Host '--- Tail of updater_package build log (last 150 lines) ---'
                $updaterLogTail | ForEach-Object { Write-Host $_ }
                Write-Host '--- End tail of updater_package build log ---'
            }
            else {
                Write-Host "updater_package build log not found at $updaterLogPath"
            }
            if ($updaterExit -eq 0) {
                Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'PASS' -Detail "Exit code 0. Full log: $updaterLogPath"
            }
            elseif ($updaterLaunchFailed) {
                Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'BLOCKED' -Detail "fbt.cmd could not be launched as a process on this machine/OS (see $updaterLogPath). Environment limitation, not a build failure."
            }
            else {
                Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'FAIL' -Detail "fbt.cmd launched and exited $updaterExit. Full log: $updaterLogPath"
            }
        }
        else {
            Add-Result -Name 'Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)' -Status 'NOT_RUN' -Detail 'Skipped because the firmware build did not exit 0.'
        }
    }

    # Artifact verification. Only meaningful if either this run's build
    # actually succeeded ($buildRan), or the caller explicitly asked to check
    # pre-existing artifacts via -SkipBuild. If the build was BLOCKED (couldn't
    # even launch) or FAILED (launched but exited non-zero) and -SkipBuild was
    # NOT passed, checking Test-Path here would either report a misleading
    # FAIL ("file does not exist", as if today's build should have produced it
    # when it never really tried) or a misleading PASS on a stale artifact
    # left over from a previous, unrelated run - reports must record this
    # run's own results, not stale values. So: skip with NOT_RUN instead.
    $artifactCheckApplicable = $SkipBuild -or $buildRan
    if (-not $artifactCheckApplicable) {
        foreach ($artifactKey in @('firmwareDfu', 'updaterPackage')) {
            $artifactConfig = $Config.expectedArtifacts.$artifactKey
            Add-Result -Name "Artifact present: $($artifactConfig.relativePath)" -Status 'NOT_RUN' -Detail "Not checked - this run's own build did not succeed (see the build check above), so any file found here would be stale from a prior run, not evidence about this run. Re-run with a working build, or pass -SkipBuild if you intend to check a pre-existing artifact deliberately."
        }
    }
    else {
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
    }

    # Expected FAP outputs per app
    $fapDir = Join-Path $RepoRoot $Config.expectedFapOutputDir
    if (-not $artifactCheckApplicable) {
        Add-Result -Name 'Per-app FAP output verification' -Status 'NOT_RUN' -Detail "Not checked - this run's own build did not succeed, so .fap files found here (if any) would be stale from a prior run. See the build check above."
    }
    elseif (-not (Test-Path $fapDir)) {
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
            Add-Result -Name 'Per-app FAP output verification' -Status 'PASS' -Detail "All $($Config.expectedApps.Count) expected .fap files found in $fapDir"
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

        Add-Result -Name 'Hardware scope confirmation' -Status 'PASS' -Detail "This run is scoped only to the $($Config.expectedApps.Count) app(s) listed in the active config. No RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR feature testing is performed by this script, for any app, under any flag."

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
    # Checked before plain PASS so a track that includes a reviewed-false-positive
    # entry (and nothing worse) is labeled accurately rather than collapsed into
    # an indistinguishable plain PASS.
    if ($Entries | Where-Object { $_.Status -eq 'PASS_WITH_REVIEWED_FALSE_POSITIVES' }) { return 'PASS_WITH_REVIEWED_FALSE_POSITIVES' }
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

$overallHasFail = @($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count -gt 0
$overallHasBlocked = @($script:Results | Where-Object { $_.Status -eq 'BLOCKED' }).Count -gt 0
$overallHasNeedsReview = @($script:Results | Where-Object { $_.Status -eq 'NEEDS_REVIEW' }).Count -gt 0

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

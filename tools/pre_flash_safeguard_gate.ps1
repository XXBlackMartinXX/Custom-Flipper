<#
.SYNOPSIS
    Pre-Flash Anti-Brick Safeguard Gate for the final 20-app accepted
    baseline (Custom-Flipper, integration/fcc-id-lookup-one-app-import).

.DESCRIPTION
    This script contains NO flashing code path of any kind, under any
    mode, flag, or combination — not even a gated one. It is strictly a
    pre-condition checker, run BEFORE a real flash is even considered, to
    reduce (not eliminate) flashing risk. Unlike
    tools/final_hardware_gate.ps1 (which has a read-only "flash
    confirmation gate" that records an operator's intent to flash
    manually afterward), this script has no confirmation gate, no
    -AllowFlashPrompt equivalent, and no code path that could be extended
    into one without editing this file. Flashing, if it ever happens, is
    performed entirely outside this script, by a human, using qFlipper or
    `fbt flash_usb`, only after this gate, the physical checklist in
    docs/PRE_FLASH_PHYSICAL_CHECKLIST.md, and the decision tree in
    docs/SAFE_FLASH_DECISION_TREE.md have all been worked through
    honestly.

    It validates the accepted final baseline via a strict ancestry and
    forbidden-diff check (not a fragile exact-HEAD-equality check — a
    later, docs/tools-only commit is expected and permitted, but any
    difference outside docs/ or tools/ is not), and the real,
    GitHub-Actions-generated artifact hashes from
    docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md, and, only when specifically
    requested, attempts safe, read-only detection of a connected Flipper
    Zero in either normal (Windows Serial/CDC-ACM) mode or DFU/recovery
    (STM32 bootloader) mode, and detection of installed qFlipper.

    CORRECTNESS PATCH (this revision): fixes two defects found via real
    hardware evidence review.
      1. FALSE DFU POSITIVE: the prior RecoveryReadiness implementation
         matched on FriendlyName substrings ("STM32 BOOTLOADER", "DFU")
         OR a loosely-escaped VID:PID substring, which could accept an
         unrelated device (e.g. "Camera DFU Device",
         USB\VID_04F2&PID_B83E...) as if it were the Flipper Zero's
         bootloader. FriendlyName is now NEVER used to determine a
         PASS/BLOCKED identity result - identity is determined solely by
         an exact InstanceId substring match against VID_0483&PID_DF11
         (Flipper's DFU identity) or VID_0483&PID_5740 (Flipper's normal
         identity), each checked independently. Device enumeration
         (touches real hardware APIs) is now separated from identity
         evaluation (pure functions, unit-testable with synthetic device
         fixtures, no hardware required) - see
         tools/pre_flash_safeguard_gate.tests.ps1.
      2. BASELINE COMMIT RELATIONSHIP: the prior "Commit verification"
         check required HEAD to equal the accepted baseline commit
         exactly, which fails (as NEEDS_REVIEW) for every legitimate
         docs/tools-only commit added after baseline acceptance -
         including this gate's own tooling commits. Replaced with a
         strict ancestry check (`git merge-base --is-ancestor`) plus a
         forbidden-diff check: the accepted baseline commit must exist
         locally and be an ancestor of HEAD, and every file that differs
         between the baseline and HEAD must fall under docs/ or tools/ -
         any other path (applications/, applications_user/, core
         firmware source, .github/workflows/, build/, dist/, toolchain/,
         or anything else) forces a FAIL. This never implies that HEAD
         itself produced the accepted firmware artifacts - those remain
         bound to the accepted baseline commit, CI run, sizes, and
         hashes, which are unchanged by this patch.

    This script contains NO code path for Sub-GHz/RF, NFC/RFID/iButton,
    BadUSB/HID injection, BLE, GPIO, or IR interaction, and no code path
    for cloning, brute force, jamming, deauth, bypass, credential
    extraction, or any other unauthorized-access/security-abuse behavior,
    for any app, under any mode or flag. This is not a configuration
    toggle to disable - it is simply not implemented anywhere in this
    file.

    Report-filename collision resistance: uses a millisecond-precision
    timestamp plus a short random hex suffix (yyyyMMdd_HHmmss_fff_XXXX),
    the same scheme used by tools/final_hardware_gate.ps1 and every
    tools/phaseX_hardware_gate.ps1 script since Phase 2C.4.

    Testability: this file can be dot-sourced (`. .\tools\pre_flash_safeguard_gate.ps1`)
    to load only its function definitions, without running the main gate
    body or touching any hardware API - detected via
    `$MyInvocation.InvocationName -eq '.'`. This is how
    tools/pre_flash_safeguard_gate.tests.ps1 exercises the identity and
    ancestry/diff logic with synthetic fixtures, with no real device and
    no network access required.

    PowerShell 5.1 compatibility: deliberately avoids PowerShell-7-only
    syntax (ternary `?:`, null-coalescing `??`/`??=`, pipeline chain
    operators `&&`/`||`) so this script runs unchanged on Windows
    PowerShell 5.1 as well as PowerShell 7+.

.PARAMETER Mode
    Preflight (default)  - repo/branch/ancestry checks and environment
                            checks only, no hardware, no artifact
                            directory required.
    ArtifactHashVerify    - Preflight checks, plus verifying a downloaded
                            artifact directory's firmware.dfu and updater
                            .tgz against the accepted baseline's real
                            SHA-256 hashes. Requires -ArtifactDir.
    DeviceDetect          - Preflight checks, plus safe PnP-based
                            detection of a connected Flipper Zero in
                            normal mode (exact VID_0483&PID_5740 match)
                            and installed qFlipper. Read-only; no serial
                            communication with the device.
    RecoveryReadiness     - Preflight checks, plus safe PnP-based
                            detection of a connected Flipper Zero in
                            EITHER normal mode OR DFU/recovery
                            (bootloader) mode (exact VID_0483&PID_DF11
                            match only - never FriendlyName-based), so a
                            user can safely confirm their device is
                            reachable in recovery mode before they might
                            ever need it for real - without performing
                            any recovery action itself. Read-only.
    ReportOnly            - Regenerates a report from repo/environment
                            state only, without attempting device
                            detection or artifact hashing even if
                            -ArtifactDir is supplied.

.PARAMETER ArtifactDir
    Path to an already-downloaded artifact directory (containing
    firmware.dfu and/or flipper-z-f7-update-local.tgz somewhere under
    it). Required for a real result in ArtifactHashVerify mode; optional
    elsewhere.

.PARAMETER ReportDir
    Directory to write JSON/Markdown reports into. Defaults to
    reports\pre_flash_safeguard under the repo root. Created if missing.

.PARAMETER RepoRoot
    Path to the repository root. Defaults to the parent directory of this
    script's own location (tools\..). If the path does not look like a
    git repository, repo/branch/commit checks are marked NOT_RUN rather
    than failing the whole script - this gate is also meant to be usable
    from a plain artifact-download folder with no repo present.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\pre_flash_safeguard_gate.ps1 -Mode Preflight

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\pre_flash_safeguard_gate.ps1 -Mode ArtifactHashVerify -ArtifactDir "<artifact-dir>"

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\pre_flash_safeguard_gate.ps1 -Mode DeviceDetect

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\pre_flash_safeguard_gate.ps1 -Mode RecoveryReadiness
#>

[CmdletBinding()]
param(
    [ValidateSet('Preflight', 'ArtifactHashVerify', 'DeviceDetect', 'RecoveryReadiness', 'ReportOnly')]
    [string]$Mode = 'Preflight',

    [string]$ArtifactDir = '',

    [string]$ReportDir = '',

    [string]$RepoRoot = ''
)

# ---------------------------------------------------------------------------
# Embedded accepted-baseline constants (no separate config file for this
# narrow, single-purpose gate - matches this task's own requested deliverable
# list, which asks for one script, not a script+config pair).
# ---------------------------------------------------------------------------

$AcceptedBranch = 'integration/fcc-id-lookup-one-app-import'
$AcceptedCommit = '86265727b5b8cfce5086eb88f8bb93d0169ab9a9'
$AcceptedCiRunId = '29068148596'
$AcceptedFinalizationRunId = '29096377711'

$ExpectedFirmware = [ordered]@{
    FileName          = 'firmware.dfu'
    ExpectedSizeBytes = 862833
    ExpectedSha256    = 'e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d'
}
$ExpectedUpdater = [ordered]@{
    FileName          = 'flipper-z-f7-update-local.tgz'
    ExpectedSizeBytes = 2891859
    ExpectedSha256    = 'eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55'
}

# Flipper Zero in normal (application firmware) mode enumerates as a USB
# CDC-ACM serial device under ST Microelectronics's VID and a
# Flipper-specific PID. Flipper Zero's STM32 bootloader, when the device is
# held into DFU/recovery mode, enumerates under ST Microelectronics's
# GENERIC DFU bootloader VID:PID (0483:DF11) - the same generic identity
# shared by many other STM32-based devices (this is the exact false-positive
# risk this patch fixes: FriendlyName strings like "DFU", "STM", or
# "Bootloader" are shared across unrelated devices; only the exact
# VID_0483&PID_DF11 InstanceId is Flipper-specific enough, and even that is
# a generic STM32 DFU identity, not literally unique to Flipper - but it is
# the correct, documented identity for this device in DFU mode, per
# Flipper's own hardware).
$NormalModeVidPid = 'VID_0483&PID_5740'
$DfuModeVidPid = 'VID_0483&PID_DF11'

# Allow-list (fail-closed) of path prefixes permitted to differ between the
# accepted baseline commit and HEAD. Anything NOT under one of these
# prefixes - applications/, applications_user/, core firmware source,
# .github/workflows/, build/, dist/, toolchain/, or any other path - is
# treated as a forbidden difference, UNLESS it exactly matches one of the
# pinned exceptions below.
$AllowedPostBaselinePathPrefixes = @('docs/', 'tools/')

# Narrow, individually-reviewed exception: exactly one post-baseline
# .github/workflows/ file is permitted, and only if its current content
# still hashes to this exact pinned value. This does NOT permit the
# .github/workflows/ directory in general - any other workflow file, or
# any change to this one file's content, remains forbidden. See
# docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md for the full audit that
# justified this exception (confirmed: no firmware/app source
# modification, no build replacement, no flash/device operation, no
# artifact-content mutation, no release publication - only artifact
# download, hashing, documentation update, and baseline-tag operations).
# The pinned hash below was computed directly from the file as committed
# at 22167ac ("fcc: baseline acceptance record and finalization
# workflow") and has not changed since.
$PinnedWorkflowExceptions = @(
    [ordered]@{
        Path           = '.github/workflows/fcc-id-lookup-finalize-baseline.yml'
        ExpectedSha256 = '3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5'
    }
)

$ReleaseStatusWording = 'TEST-READY ONLY / NOT RELEASE-READY'

# ---------------------------------------------------------------------------
# Pure / testable functions - identity evaluation
#
# These never call Get-PnpDevice or any other hardware API themselves; they
# operate only on the InstanceId/FriendlyName strings they are given, so
# tools/pre_flash_safeguard_gate.tests.ps1 can call them directly with
# synthetic fixture objects, with no real device and no Windows required.
# FriendlyName is accepted as a parameter for display purposes only in the
# calling code below - it is never inspected here and never determines a
# PASS or BLOCKED result.
# ---------------------------------------------------------------------------

function Test-FlipperDfuIdentity {
    [CmdletBinding()]
    param(
        [AllowNull()][AllowEmptyString()][string]$InstanceId
    )
    if ([string]::IsNullOrEmpty($InstanceId)) { return $false }
    return $InstanceId.ToUpperInvariant().Contains($DfuModeVidPid)
}

function Test-FlipperNormalModeIdentity {
    [CmdletBinding()]
    param(
        [AllowNull()][AllowEmptyString()][string]$InstanceId
    )
    if ([string]::IsNullOrEmpty($InstanceId)) { return $false }
    return $InstanceId.ToUpperInvariant().Contains($NormalModeVidPid)
}

# ---------------------------------------------------------------------------
# Pure / testable functions - detection-result classification
#
# Each takes an "enumeration result" object (see Get-PresentPnpDevices
# below) rather than calling Get-PnpDevice itself, so these can be unit
# tested with a synthetic enumeration result too.
# ---------------------------------------------------------------------------

function Get-NormalModeDetectionResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$EnumerationResult
    )
    if (-not $EnumerationResult.Success) {
        if ($EnumerationResult.ErrorType -eq 'ApiUnavailable') {
            return [ordered]@{
                Status = 'BLOCKED - WINDOWS DEVICE API UNAVAILABLE'
                Detail = "Get-PnpDevice is unavailable: $($EnumerationResult.ErrorMessage) - this cmdlet requires Windows."
            }
        }
        return [ordered]@{
            Status = 'NEEDS_REVIEW'
            Detail = "Get-PnpDevice query failed: $($EnumerationResult.ErrorMessage)"
        }
    }

    $matches = @($EnumerationResult.Devices | Where-Object { Test-FlipperNormalModeIdentity -InstanceId $_.InstanceId })
    if ($matches.Count -gt 0) {
        $first = $matches | Select-Object -First 1
        return [ordered]@{
            Status = 'PASS'
            Detail = "Exact Flipper normal-mode identity $NormalModeVidPid detected: InstanceId=$($first.InstanceId), FriendlyName='$($first.FriendlyName)' (FriendlyName shown for information only - it did not determine this PASS)."
        }
    }
    return [ordered]@{
        Status = 'BLOCKED - FLIPPER NORMAL MODE NOT DETECTED'
        Detail = "No device matching the exact Flipper normal-mode identity $NormalModeVidPid is present. Connect the device in normal (not DFU) mode and re-run."
    }
}

function Get-DfuDetectionResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$EnumerationResult
    )
    if (-not $EnumerationResult.Success) {
        if ($EnumerationResult.ErrorType -eq 'ApiUnavailable') {
            return [ordered]@{
                Status = 'BLOCKED - WINDOWS DEVICE API UNAVAILABLE'
                Detail = "Get-PnpDevice is unavailable: $($EnumerationResult.ErrorMessage) - this cmdlet requires Windows."
            }
        }
        return [ordered]@{
            Status = 'NEEDS_REVIEW'
            Detail = "Get-PnpDevice query failed: $($EnumerationResult.ErrorMessage)"
        }
    }

    $exactMatches = @($EnumerationResult.Devices | Where-Object { Test-FlipperDfuIdentity -InstanceId $_.InstanceId })
    if ($exactMatches.Count -gt 0) {
        $first = $exactMatches | Select-Object -First 1
        return [ordered]@{
            Status = 'PASS'
            Detail = "Exact Flipper DFU identity $DfuModeVidPid detected: InstanceId=$($first.InstanceId), FriendlyName='$($first.FriendlyName)' (FriendlyName shown for information only - it did not determine this PASS; no generic 'DFU'/'STM'/'Bootloader'/'Camera' string match is ever sufficient)."
        }
    }

    # Report any DFU-shaped-but-non-matching devices purely for operator
    # awareness (e.g. "your webcam's DFU mode is not your Flipper") - this
    # broader, FriendlyName-based lookup NEVER contributes to a PASS.
    $genericDfuLike = @($EnumerationResult.Devices | Where-Object {
        ($_.InstanceId -match '(?i)DF11') -or ($_.FriendlyName -match '(?i)dfu|bootloader')
    })
    if ($genericDfuLike.Count -gt 0) {
        $names = ($genericDfuLike | ForEach-Object { "$($_.FriendlyName) ($($_.InstanceId))" }) -join '; '
        return [ordered]@{
            Status = 'BLOCKED - EXACT FLIPPER DFU ID NOT DETECTED'
            Detail = "Generic or unrelated DFU-like device(s) present but none matched the exact Flipper identity $DfuModeVidPid : $names. FriendlyName and generic DFU-related strings (DFU, STM, Bootloader, Camera, etc.) never determine a PASS - only an exact InstanceId match against $DfuModeVidPid does."
        }
    }
    return [ordered]@{
        Status = 'BLOCKED - EXACT FLIPPER DFU ID NOT DETECTED'
        Detail = "No device matching the exact Flipper DFU identity $DfuModeVidPid is present. This is expected if you have not deliberately put the device into DFU mode (hold Back while connecting USB) - only do so if you specifically want to test recovery-mode reachability now, per docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md."
    }
}

# ---------------------------------------------------------------------------
# Enumeration function - the ONLY function in this file that touches a real
# hardware/OS API (Get-PnpDevice). Kept deliberately separate from the pure
# evaluation functions above so tests never need to call this.
# ---------------------------------------------------------------------------

function Get-PresentPnpDevices {
    [CmdletBinding()]
    param()
    try {
        $devices = @(Get-PnpDevice -PresentOnly -ErrorAction Stop)
        return [ordered]@{ Success = $true; Devices = $devices; ErrorType = $null; ErrorMessage = $null }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        return [ordered]@{ Success = $false; Devices = @(); ErrorType = 'ApiUnavailable'; ErrorMessage = $_.Exception.Message }
    }
    catch {
        return [ordered]@{ Success = $false; Devices = @(); ErrorType = 'QueryError'; ErrorMessage = $_.Exception.Message }
    }
}

# ---------------------------------------------------------------------------
# Pure-ish function - baseline ancestry and forbidden-diff evaluation.
# Shells out to git (so it needs a real or scratch repository to run
# against), but takes RepoRoot/AcceptedBaselineCommit/AllowedPathPrefixes as
# parameters rather than reading script-level constants directly, so
# tools/pre_flash_safeguard_gate.tests.ps1 can point it at a disposable
# scratch repository to prove the forbidden-diff detection works, without
# touching this repository's own applications_user/ or any other real path.
# ---------------------------------------------------------------------------

function Get-BaselineAncestryDiffResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$AcceptedBaselineCommit,
        [string[]]$AllowedPathPrefixes = @('docs/', 'tools/'),
        # Each entry: @{ Path = '<exact repo-relative path, forward slashes>'; ExpectedSha256 = '<lowercase hex>' }.
        # A file outside $AllowedPathPrefixes is permitted ONLY if its path
        # matches one of these EXACTLY (no wildcards, no directory-level
        # exceptions - the whole .github/workflows/ directory stays
        # forbidden except for this exact, individually-reviewed path) AND
        # its current byte content hashes to the pinned ExpectedSha256.
        # Fail-closed: missing file or hash mismatch is still forbidden.
        [object[]]$PinnedFileExceptions = @()
    )

    if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
        return [ordered]@{ Status = 'NOT_RUN'; Detail = "$RepoRoot does not look like a git repository root (.git not found)."; ForbiddenFiles = @() }
    }

    Push-Location $RepoRoot
    try {
        # Step 1: accepted baseline commit exists locally.
        & git cat-file -e "$AcceptedBaselineCommit^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            return [ordered]@{
                Status = 'BLOCKED - ACCEPTED BASELINE NOT FOUND LOCALLY'
                Detail = "Accepted baseline commit $AcceptedBaselineCommit does not exist in this local repository. Fetch it (e.g. git fetch origin) before proceeding."
                ForbiddenFiles = @()
            }
        }

        $headCommit = (& git rev-parse HEAD 2>&1)
        if ($LASTEXITCODE -ne 0) {
            return [ordered]@{ Status = 'NEEDS_REVIEW'; Detail = "git rev-parse HEAD failed: $headCommit"; ForbiddenFiles = @() }
        }
        $headCommit = "$headCommit".Trim()

        if ($headCommit -eq $AcceptedBaselineCommit) {
            return [ordered]@{
                Status = 'PASS - HEAD IS THE ACCEPTED BASELINE COMMIT EXACTLY'
                Detail = "HEAD ($headCommit) is exactly the accepted baseline commit."
                ForbiddenFiles = @()
            }
        }

        # Step 2: ancestry.
        & git merge-base --is-ancestor $AcceptedBaselineCommit HEAD 2>$null
        if ($LASTEXITCODE -ne 0) {
            return [ordered]@{
                Status = 'BLOCKED - ACCEPTED BASELINE NOT AN ANCESTOR OF HEAD'
                Detail = "git merge-base --is-ancestor $AcceptedBaselineCommit HEAD did not confirm ancestry - HEAD ($headCommit) does not descend from the accepted baseline commit. This may indicate a rebase, a different branch, or a diverged checkout. Do not treat this HEAD as validating the accepted baseline."
                ForbiddenFiles = @()
            }
        }

        # Steps 3-5: diff scope, allow-list based (fail-closed).
        $diffOutputRaw = (& git diff --name-only "$AcceptedBaselineCommit..HEAD" 2>&1)
        if ($LASTEXITCODE -ne 0) {
            return [ordered]@{ Status = 'NEEDS_REVIEW'; Detail = "git diff --name-only $AcceptedBaselineCommit..HEAD failed: $diffOutputRaw"; ForbiddenFiles = @() }
        }
        $changedFiles = @($diffOutputRaw -split "`n" | Where-Object { $_ -and $_.Trim() -ne '' })

        $forbidden = New-Object System.Collections.Generic.List[string]
        $pinnedMatched = New-Object System.Collections.Generic.List[string]
        foreach ($file in $changedFiles) {
            $isAllowedByPrefix = $false
            foreach ($prefix in $AllowedPathPrefixes) {
                if ($file -like "$prefix*") { $isAllowedByPrefix = $true; break }
            }
            if ($isAllowedByPrefix) { continue }

            # Not covered by the docs/tools allow-list - check for an exact,
            # individually-reviewed, pinned-hash exception before treating it
            # as forbidden. This never widens to the whole directory the
            # file lives in (e.g. .github/workflows/) - only this literal
            # path, and only if its current bytes still match the pinned
            # hash exactly.
            $pinnedException = $PinnedFileExceptions | Where-Object { $_.Path -eq $file } | Select-Object -First 1
            if ($pinnedException) {
                $exceptionFullPath = Join-Path $RepoRoot $file
                if (-not (Test-Path $exceptionFullPath)) {
                    $forbidden.Add("$file (PINNED EXCEPTION FAILED - file missing at HEAD, expected sha256 $($pinnedException.ExpectedSha256))") | Out-Null
                    continue
                }
                $exceptionActualHash = Get-LineSha256 -Path $exceptionFullPath
                if ($exceptionActualHash -eq $pinnedException.ExpectedSha256) {
                    $pinnedMatched.Add($file) | Out-Null
                    continue
                }
                else {
                    $forbidden.Add("$file (PINNED EXCEPTION FAILED - hash mismatch: expected sha256 $($pinnedException.ExpectedSha256), found $exceptionActualHash. Any modification to this pinned file requires a new review and a new pinned hash.)") | Out-Null
                    continue
                }
            }

            $forbidden.Add($file) | Out-Null
        }

        if ($forbidden.Count -gt 0) {
            return [ordered]@{
                Status = 'FAIL - FORBIDDEN PATH CHANGES BETWEEN ACCEPTED BASELINE AND HEAD'
                Detail = "HEAD ($headCommit) descends from the accepted baseline ($AcceptedBaselineCommit) but changes files outside the permitted $($AllowedPathPrefixes -join '/') scope (and outside any pinned exception, or a pinned exception's integrity check failed): $($forbidden -join ', '). Do not treat this HEAD as validating the accepted firmware artifacts."
                ForbiddenFiles = @($forbidden)
            }
        }

        if ($changedFiles.Count -eq 0) {
            return [ordered]@{
                Status = 'PASS - HEAD IS THE ACCEPTED BASELINE COMMIT EXACTLY'
                Detail = "No file differences found between $AcceptedBaselineCommit and HEAD ($headCommit) despite differing commit hashes (e.g. an empty/no-op commit)."
                ForbiddenFiles = @()
            }
        }

        if ($pinnedMatched.Count -gt 0) {
            return [ordered]@{
                Status = 'PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND PINNED FINALIZATION WORKFLOW'
                Detail = "HEAD ($headCommit) descends from the accepted baseline commit ($AcceptedBaselineCommit) with $($changedFiles.Count) changed file(s): the rest confined to $($AllowedPathPrefixes -join ' / '), plus $($pinnedMatched.Count) exact, individually-reviewed, pinned-hash-verified exception file(s): $($pinnedMatched -join ', '). The accepted firmware artifacts (firmware.dfu / updater .tgz) were built from the accepted baseline commit itself, NOT from current HEAD - this classification does not rebind them to HEAD. The pinned finalization workflow only downloaded, hashed, documented, and tagged the already-built accepted artifacts; it did not and could not alter their bytes. Any future modification to a pinned file's content requires a new review and a new pinned hash before it will be accepted again."
                ForbiddenFiles = @()
            }
        }

        return [ordered]@{
            Status = 'PASS - ACCEPTED BASELINE WITH TOOLING/DOCS-ONLY DESCENDANT'
            Detail = "HEAD ($headCommit) descends from the accepted baseline commit ($AcceptedBaselineCommit) with $($changedFiles.Count) changed file(s) confined entirely to $($AllowedPathPrefixes -join ' / '): $($changedFiles -join ', '). This confirms HEAD is a documentation/tooling-only descendant - it does NOT imply HEAD itself produced the accepted firmware artifacts. Those remain bound to the accepted baseline commit, CI run $AcceptedCiRunId, and the hashes verified separately below."
            ForbiddenFiles = @()
        }
    }
    finally {
        Pop-Location
    }
}

function Get-LineSha256 {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Add-Result {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Status,
        [string]$Detail = '',
        [object]$Evidence = $null
    )
    $entry = [ordered]@{
        Category = $Category
        Name     = $Name
        Status   = $Status
        Detail   = $Detail
        Evidence = $Evidence
    }
    $script:Results.Add($entry) | Out-Null

    $color = 'Gray'
    if ($Status -like 'PASS*') { $color = 'Green' }
    elseif ($Status -like 'FAIL*') { $color = 'Red' }
    elseif ($Status -like 'BLOCKED*') { $color = 'Yellow' }
    elseif ($Status -like 'NEEDS_REVIEW*') { $color = 'Yellow' }

    Write-Host ("[{0,-24}] [{1,-45}] {2}" -f $Category, $Status, $Name) -ForegroundColor $color
    if ($Detail) {
        Write-Host ("{0}{1}" -f (' ' * 4), $Detail) -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------------------
# Dot-source guard: everything above this line is safe to load with no
# hardware, no network, and no strict-mode/error-preference side effects on
# the caller. Everything below only runs when this file is executed
# directly (not dot-sourced), so tools/pre_flash_safeguard_gate.tests.ps1
# can `. .\tools\pre_flash_safeguard_gate.ps1` to get the functions above
# without triggering a real gate run.
# ---------------------------------------------------------------------------

$script:IsDotSourced = ($MyInvocation.InvocationName -eq '.')

if (-not $script:IsDotSourced) {

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
    $ReportDir = Join-Path $RepoRoot 'reports\pre_flash_safeguard'
}
if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$RunTimestampUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$RandomSuffix = -join ((1..4) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
$RunTimestampForFilename = "$((Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss_fff'))_$RandomSuffix"

$script:Results = New-Object System.Collections.Generic.List[object]

Write-Host ''
Write-Host '=== Pre-Flash Anti-Brick Safeguard Gate ===' -ForegroundColor Cyan
Write-Host 'This script never flashes a device. It has no flashing code path.' -ForegroundColor Yellow
Write-Host "Mode: $Mode"
Write-Host "Repo root (expected): $RepoRoot"
Write-Host "Timestamp (UTC): $RunTimestampUtc"
if ($ArtifactDir) { Write-Host "ArtifactDir: $ArtifactDir" }
Write-Host ''

# ---------------------------------------------------------------------------
# Category: Automated checks - PowerShell environment
# ---------------------------------------------------------------------------

Write-Host '--- Automated checks ---' -ForegroundColor Cyan

$psVersion = $PSVersionTable.PSVersion
Add-Result -Category 'Environment' -Name 'PowerShell version' -Status 'PASS' -Detail "PowerShell $psVersion ($($PSVersionTable.PSEdition))"

$osDescription = try { [System.Runtime.InteropServices.RuntimeInformation]::OSDescription } catch { 'unknown' }
$isWindowsEnv = $false
try { $isWindowsEnv = [bool]$IsWindows } catch { $isWindowsEnv = $osDescription -match 'Windows' }
if ($isWindowsEnv) {
    Add-Result -Category 'Environment' -Name 'Operating system check' -Status 'PASS' -Detail "Windows confirmed: $osDescription. Device-detection modes (DeviceDetect/RecoveryReadiness) require Windows and will work here."
}
else {
    Add-Result -Category 'Environment' -Name 'Operating system check' -Status 'NEEDS_REVIEW' -Detail "Non-Windows OS detected: $osDescription. Get-PnpDevice (used by DeviceDetect/RecoveryReadiness) is a Windows-only cmdlet and will report BLOCKED, not a fabricated result, on this platform."
}

# ---------------------------------------------------------------------------
# Category: Automated checks - report directory
# ---------------------------------------------------------------------------

if (Test-Path $ReportDir) {
    $testFile = Join-Path $ReportDir ".writetest_$RunTimestampForFilename.tmp"
    try {
        Set-Content -Path $testFile -Value 'ok' -Encoding UTF8 -ErrorAction Stop
        Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
        Add-Result -Category 'Environment' -Name 'Report directory writable' -Status 'PASS' -Detail "Confirmed writable: $ReportDir"
    }
    catch {
        Add-Result -Category 'Environment' -Name 'Report directory writable' -Status 'FAIL' -Detail "Could not write to $ReportDir : $($_.Exception.Message)"
    }
}
else {
    Add-Result -Category 'Environment' -Name 'Report directory writable' -Status 'FAIL' -Detail "$ReportDir does not exist and could not be created."
}

# ---------------------------------------------------------------------------
# Category: Automated checks - repo/branch state and baseline ancestry/diff
# (best-effort; this gate is also meant to be usable from a plain
# artifact-download folder with no repo present, so absence of a repo is
# NOT_RUN, not a failure)
# ---------------------------------------------------------------------------

$gitAvailable = $false
try {
    $null = & git --version 2>&1
    if ($LASTEXITCODE -eq 0) { $gitAvailable = $true }
}
catch { $gitAvailable = $false }

if (-not $gitAvailable) {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NOT_RUN' -Detail 'git is not available in this environment - repo/branch/ancestry checks skipped. This gate can still be used from a plain artifact-download folder.'
    Add-Result -Category 'Automated' -Name 'Baseline ancestry and diff-scope verification' -Status 'NOT_RUN' -Detail 'git is not available in this environment.'
}
elseif (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NOT_RUN' -Detail "$RepoRoot does not look like a git repository root (.git not found) - repo/branch/ancestry checks skipped. Pass -RepoRoot explicitly if this repo lives elsewhere."
    Add-Result -Category 'Automated' -Name 'Baseline ancestry and diff-scope verification' -Status 'NOT_RUN' -Detail "$RepoRoot does not look like a git repository root."
}
else {
    Push-Location $RepoRoot
    try {
        $currentBranch = (& git rev-parse --abbrev-ref HEAD 2>&1)
        $gitStatus = (& git status --short 2>&1) -join "`n"
    }
    finally {
        Pop-Location
    }

    if ($currentBranch -eq $AcceptedBranch) {
        Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'PASS' -Detail "On expected branch '$currentBranch'"
    }
    else {
        Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NEEDS_REVIEW' -Detail "Expected '$AcceptedBranch', found '$currentBranch'."
    }

    $ancestryResult = Get-BaselineAncestryDiffResult -RepoRoot $RepoRoot -AcceptedBaselineCommit $AcceptedCommit -AllowedPathPrefixes $AllowedPostBaselinePathPrefixes -PinnedFileExceptions $PinnedWorkflowExceptions
    Add-Result -Category 'Automated' -Name 'Baseline ancestry and diff-scope verification' -Status $ancestryResult.Status -Detail $ancestryResult.Detail -Evidence $ancestryResult.ForbiddenFiles

    if ($gitStatus.Trim() -eq '') {
        Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'PASS' -Detail 'No uncommitted changes'
    }
    else {
        Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'NEEDS_REVIEW' -Detail 'Uncommitted changes present' -Evidence $gitStatus
    }
}

Add-Result -Category 'Automated' -Name 'Accepted baseline reference' -Status 'PASS' -Detail "Branch $AcceptedBranch, commit $AcceptedCommit, CI validation run $AcceptedCiRunId, finalization run $AcceptedFinalizationRunId. Artifact verification below is always bound to these exact values, never to whatever commit HEAD happens to be."

# ---------------------------------------------------------------------------
# Category: Automated checks - artifact hash verification
# ---------------------------------------------------------------------------

if ($Mode -eq 'ReportOnly') {
    Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail 'Mode is ReportOnly - live artifact hashing is never attempted in this mode by design, even if -ArtifactDir was supplied.'
}
elseif ($Mode -ne 'ArtifactHashVerify') {
    Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail "Mode is $Mode - artifact hash verification was not requested. Use -Mode ArtifactHashVerify -ArtifactDir <path>."
}
elseif (-not $ArtifactDir) {
    Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail 'Mode is ArtifactHashVerify but -ArtifactDir was not supplied - nothing to hash.'
}
elseif (-not (Test-Path $ArtifactDir)) {
    Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'FAIL' -Detail "ArtifactDir '$ArtifactDir' does not exist."
}
else {
    $allFiles = Get-ChildItem -Path $ArtifactDir -Recurse -File
    $firmware = $allFiles | Where-Object { $_.Name -eq $ExpectedFirmware.FileName } | Select-Object -First 1
    $updater = $allFiles | Where-Object { $_.Name -eq $ExpectedUpdater.FileName } | Select-Object -First 1

    if (-not $firmware) {
        Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'FAIL' -Detail "'$($ExpectedFirmware.FileName)' not found under $ArtifactDir. DO NOT FLASH an artifact that has not been hash-verified."
    }
    else {
        $actualSize = $firmware.Length
        $actualHash = Get-LineSha256 -Path $firmware.FullName
        if ($actualSize -eq $ExpectedFirmware.ExpectedSizeBytes -and $actualHash -eq $ExpectedFirmware.ExpectedSha256) {
            Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'PASS' -Detail "Size $actualSize bytes, SHA-256 $actualHash matches the accepted baseline exactly."
        }
        else {
            Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'FAIL' -Detail "MISMATCH - expected size $($ExpectedFirmware.ExpectedSizeBytes) / sha256 $($ExpectedFirmware.ExpectedSha256), found size $actualSize / sha256 $actualHash. DO NOT FLASH THIS ARTIFACT."
        }
    }

    if (-not $updater) {
        Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'FAIL' -Detail "'$($ExpectedUpdater.FileName)' not found under $ArtifactDir. DO NOT FLASH an artifact that has not been hash-verified."
    }
    else {
        $actualSize = $updater.Length
        $actualHash = Get-LineSha256 -Path $updater.FullName
        if ($actualSize -eq $ExpectedUpdater.ExpectedSizeBytes -and $actualHash -eq $ExpectedUpdater.ExpectedSha256) {
            Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'PASS' -Detail "Size $actualSize bytes, SHA-256 $actualHash matches the accepted baseline exactly."
        }
        else {
            Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'FAIL' -Detail "MISMATCH - expected size $($ExpectedUpdater.ExpectedSizeBytes) / sha256 $($ExpectedUpdater.ExpectedSha256), found size $actualSize / sha256 $actualHash. DO NOT FLASH THIS ARTIFACT."
        }
    }
}

# ---------------------------------------------------------------------------
# Category: Hardware-connected checks - qFlipper detection (DeviceDetect and
# RecoveryReadiness modes only)
# ---------------------------------------------------------------------------

$deviceCheckApplicable = ($Mode -eq 'DeviceDetect' -or $Mode -eq 'RecoveryReadiness')

if (-not $deviceCheckApplicable) {
    Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'NOT_RUN' -Detail "Mode is $Mode - tooling detection was not requested."
}
else {
    $qFlipperFound = $null
    try {
        $cmd = Get-Command -Name 'qFlipper.exe' -ErrorAction SilentlyContinue
        if ($cmd) { $qFlipperFound = $cmd.Source }
    }
    catch { }

    if (-not $qFlipperFound) {
        $commonDirs = @(
            "$env:ProgramFiles\qFlipper",
            "${env:ProgramFiles(x86)}\qFlipper",
            "$env:LOCALAPPDATA\Programs\qFlipper",
            "$env:LOCALAPPDATA\qFlipper"
        )
        foreach ($dir in $commonDirs) {
            if ($dir -and (Test-Path $dir)) {
                $found = Get-ChildItem -Path $dir -Filter 'qFlipper.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) { $qFlipperFound = $found.FullName; break }
            }
        }
    }

    if (-not $qFlipperFound) {
        try {
            $uninstallKeys = @(
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            )
            $match = Get-ItemProperty -Path $uninstallKeys -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like '*qFlipper*' } | Select-Object -First 1
            if ($match) { $qFlipperFound = "$($match.DisplayName) $($match.DisplayVersion) (registry)" }
        }
        catch { }
    }

    if ($qFlipperFound) {
        Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'PASS' -Detail "Detected: $qFlipperFound"
    }
    else {
        Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'BLOCKED - QFLIPPER NOT DETECTED' -Detail 'qFlipper not found via PATH, common install directories, or the Windows uninstall registry. This is best-effort detection - it may still be installed under a nonstandard path. Per this gate''s design, do not proceed toward flashing until qFlipper is confirmed installed.'
    }
}

# ---------------------------------------------------------------------------
# Category: Hardware-connected checks - normal-mode and DFU/recovery-mode
# device detection (single enumeration, evaluated by the pure functions
# above - identity is decided by exact InstanceId match only, never by
# FriendlyName).
# ---------------------------------------------------------------------------

if (-not $deviceCheckApplicable) {
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status 'NOT_RUN' -Detail "Mode is $Mode - device detection was not requested."
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'NOT_RUN' -Detail "Mode is $Mode - DFU/recovery-mode detection is only attempted in -Mode RecoveryReadiness."
}
else {
    $enumeration = Get-PresentPnpDevices

    $normalResult = Get-NormalModeDetectionResult -EnumerationResult $enumeration
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status $normalResult.Status -Detail $normalResult.Detail

    if ($Mode -ne 'RecoveryReadiness') {
        Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'NOT_RUN' -Detail "Mode is $Mode - DFU/recovery-mode detection is only attempted in -Mode RecoveryReadiness."
    }
    else {
        $dfuResult = Get-DfuDetectionResult -EnumerationResult $enumeration
        Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status $dfuResult.Status -Detail $dfuResult.Detail
    }
}

# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host '=== Classification ===' -ForegroundColor Cyan

$hasFail = @($script:Results | Where-Object { $_.Status -like 'FAIL*' }).Count -gt 0
$hasBlocked = @($script:Results | Where-Object { $_.Status -like 'BLOCKED*' }).Count -gt 0
$hasNeedsReview = @($script:Results | Where-Object { $_.Status -like 'NEEDS_REVIEW*' }).Count -gt 0

# Per this gate's own design requirement: if ANY required pre-flash safety
# check fails, final classification must be BLOCKED/FAILED - never a looser
# result.
if ($hasFail) {
    $classification = 'PRE-FLASH SAFEGUARD FAILED'
}
elseif ($hasBlocked) {
    $classification = 'PRE-FLASH SAFEGUARD BLOCKED'
}
elseif ($hasNeedsReview) {
    $classification = 'PRE-FLASH SAFEGUARD NEEDS REVIEW'
}
elseif ($Mode -eq 'Preflight' -or $Mode -eq 'ReportOnly') {
    $classification = 'PREFLIGHT OK - HARDWARE NOT ATTEMPTED'
}
else {
    $classification = 'PRE-FLASH SAFEGUARD PASS'
}

Write-Host "Classification: $classification" -ForegroundColor $(if ($classification -like '*FAILED*') { 'Red' } elseif ($classification -like '*BLOCKED*' -or $classification -like '*NEEDS REVIEW*') { 'Yellow' } else { 'Cyan' })
Write-Host ''
Write-Host 'REMINDER: This script never flashes a device under any circumstance and' -ForegroundColor Yellow
Write-Host 'has no code path that could do so. Passing every check here does not mean' -ForegroundColor Yellow
Write-Host 'release-ready and does not force flashing - see docs/SAFE_FLASH_DECISION_TREE.md' -ForegroundColor Yellow
Write-Host 'for the explicit human decision that must still follow.' -ForegroundColor Yellow
Write-Host "Flashing: NOT PERFORMED. Release status: $ReleaseStatusWording." -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------

$reportObject = [ordered]@{
    timestampUtc   = $RunTimestampUtc
    mode           = $Mode
    repoRoot       = $RepoRoot
    artifactDir    = $ArtifactDir
    acceptedBaseline = [ordered]@{
        branch                    = $AcceptedBranch
        commit                    = $AcceptedCommit
        ciValidationRunId         = $AcceptedCiRunId
        finalizationWorkflowRunId = $AcceptedFinalizationRunId
    }
    checks         = $script:Results
    classification = $classification
    flashStatus    = [ordered]@{
        flashingPerformed = 'NOT_PERFORMED'
        flashingCodePath  = 'NONE - this script contains no flashing code path under any mode or flag'
        releaseStatus     = $ReleaseStatusWording
    }
    nextActions    = @(
        'Review every FAIL, BLOCKED, and NEEDS_REVIEW entry above before treating this run as clean.',
        'Complete docs/PRE_FLASH_PHYSICAL_CHECKLIST.md in full (human items this script cannot check: physical battery charge, cable quality, microSD backup, user comfort/consent).',
        'Walk docs/SAFE_FLASH_DECISION_TREE.md before any real flash attempt.',
        'This report alone never authorizes a flash, constitutes hardware-tested status, or constitutes release-ready status.'
    )
}

$jsonPath = Join-Path $ReportDir "pre_flash_safeguard_$RunTimestampForFilename.json"
$reportObject | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Pre-Flash Anti-Brick Safeguard Gate Report') | Out-Null
$md.Add('') | Out-Null
$md.Add("Generated: $RunTimestampUtc") | Out-Null
$md.Add("Mode: $Mode") | Out-Null
$md.Add("Repo root (expected): $RepoRoot") | Out-Null
if ($ArtifactDir) { $md.Add("Artifact directory: $ArtifactDir") | Out-Null }
$md.Add('') | Out-Null
$md.Add("## Classification: $classification") | Out-Null
$md.Add('') | Out-Null
$md.Add('## Checks') | Out-Null
$md.Add('') | Out-Null
$md.Add('| Category | Check | Status | Detail |') | Out-Null
$md.Add('|---|---|---|---|') | Out-Null
foreach ($r in $script:Results) {
    $detailEscaped = ($r.Detail -replace '\|', '\|') -replace "`n", ' '
    $md.Add("| $($r.Category) | $($r.Name) | $($r.Status) | $detailEscaped |") | Out-Null
}
$md.Add('') | Out-Null
$md.Add('## Status') | Out-Null
$md.Add('') | Out-Null
$md.Add('- Flashing: NOT PERFORMED. This script contains no flashing code path under any mode or flag.') | Out-Null
$md.Add("- Release status: $ReleaseStatusWording") | Out-Null
$md.Add('') | Out-Null
$md.Add('**This report never authorizes a flash, and never claims hardware-tested or release-ready status.**') | Out-Null

$mdPath = Join-Path $ReportDir "pre_flash_safeguard_$RunTimestampForFilename.md"
($md -join "`n") | Set-Content -Path $mdPath -Encoding UTF8

Write-Host ''
Write-Host "JSON report: $jsonPath"
Write-Host "Markdown report: $mdPath"

if ($hasFail) { exit 1 }
elseif ($hasBlocked -or $hasNeedsReview) { exit 2 }
else { exit 0 }

} # end: if (-not $script:IsDotSourced)

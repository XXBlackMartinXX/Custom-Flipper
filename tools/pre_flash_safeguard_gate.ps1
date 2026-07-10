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

    It validates the accepted final baseline (branch, commit, and the
    real, GitHub-Actions-generated artifact hashes from
    docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md), and, only when specifically
    requested, attempts safe, read-only detection of a connected Flipper
    Zero in either normal (Windows Serial/CDC-ACM) mode or DFU/recovery
    (STM32 bootloader) mode, and detection of installed qFlipper.

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

.PARAMETER Mode
    Preflight (default)  - repo/branch/commit checks and environment
                            checks only, no hardware, no artifact
                            directory required.
    ArtifactHashVerify    - Preflight checks, plus verifying a downloaded
                            artifact directory's firmware.dfu and updater
                            .tgz against the accepted baseline's real
                            SHA-256 hashes. Requires -ArtifactDir.
    DeviceDetect          - Preflight checks, plus safe PnP-based
                            detection of a connected Flipper Zero in
                            normal mode and installed qFlipper. Read-only;
                            no serial communication with the device.
    RecoveryReadiness     - Preflight checks, plus safe PnP-based
                            detection of a connected Flipper Zero in
                            EITHER normal mode OR DFU/recovery
                            (bootloader) mode, so a user can safely
                            confirm their device is reachable in
                            recovery mode before they might ever need it
                            for real - without performing any recovery
                            action itself. Read-only.
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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
# CDC-ACM serial device with ST Microelectronics's VID and a Flipper-specific
# PID.
$NormalModeFriendlyNameSubstring = 'Flipper'
$NormalModeVidPid = 'VID_0483&PID_5740'

# Flipper Zero's STM32 bootloader, when the device is held into DFU/recovery
# mode, enumerates under ST Microelectronics's generic DFU bootloader VID:PID
# (0483:DF11) rather than the normal-mode Flipper-specific PID - this is a
# standard STM32 DFU identity, not something specific to this project's
# firmware. Detecting it does not itself perform any recovery action.
$DfuModeFriendlyNameSubstring = 'STM32 BOOTLOADER|DFU'
$DfuModeVidPid = 'VID_0483&PID_DF11'

$ReleaseStatusWording = 'TEST-READY ONLY / NOT RELEASE-READY'

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

function Add-Result {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('PASS', 'FAIL', 'BLOCKED', 'NOT_RUN', 'NEEDS_REVIEW')][string]$Status,
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

    $color = switch ($Status) {
        'PASS'         { 'Green' }
        'FAIL'         { 'Red' }
        'BLOCKED'      { 'Yellow' }
        'NEEDS_REVIEW' { 'Yellow' }
        default        { 'Gray' }
    }
    Write-Host ("[{0,-24}] [{1,-12}] {2}" -f $Category, $Status, $Name) -ForegroundColor $color
    if ($Detail) {
        Write-Host ("{0}{1}" -f (' ' * 42), $Detail) -ForegroundColor DarkGray
    }
}

function Get-LineSha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

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
# Category: Automated checks - repo/branch/commit state (best-effort; this
# gate is also meant to be usable from a plain artifact-download folder with
# no repo present, so absence of a repo is NOT_RUN, not a failure)
# ---------------------------------------------------------------------------

$gitAvailable = $false
try {
    $null = & git --version 2>&1
    if ($LASTEXITCODE -eq 0) { $gitAvailable = $true }
}
catch { $gitAvailable = $false }

if (-not $gitAvailable) {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NOT_RUN' -Detail 'git is not available in this environment - repo/branch/commit checks skipped. This gate can still be used from a plain artifact-download folder.'
    Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted baseline)' -Status 'NOT_RUN' -Detail 'git is not available in this environment.'
}
elseif (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NOT_RUN' -Detail "$RepoRoot does not look like a git repository root (.git not found) - repo/branch/commit checks skipped. Pass -RepoRoot explicitly if this repo lives elsewhere."
    Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted baseline)' -Status 'NOT_RUN' -Detail "$RepoRoot does not look like a git repository root."
}
else {
    Push-Location $RepoRoot
    try {
        $currentBranch = (& git rev-parse --abbrev-ref HEAD 2>&1)
        $currentCommit = (& git rev-parse HEAD 2>&1)
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

    if ($currentCommit -eq $AcceptedCommit) {
        Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted baseline)' -Status 'PASS' -Detail "HEAD matches accepted baseline commit $currentCommit"
    }
    else {
        Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted baseline)' -Status 'NEEDS_REVIEW' -Detail "HEAD is $currentCommit, accepted baseline is $AcceptedCommit. This is expected NEEDS_REVIEW behavior when this gate is run from a later docs-only commit (e.g. after this gate's own tooling was added); confirm intentional before treating a flash of a different commit as validating the accepted baseline."
    }

    if ($gitStatus.Trim() -eq '') {
        Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'PASS' -Detail 'No uncommitted changes'
    }
    else {
        Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'NEEDS_REVIEW' -Detail 'Uncommitted changes present' -Evidence $gitStatus
    }
}

Add-Result -Category 'Automated' -Name 'Accepted baseline reference' -Status 'PASS' -Detail "Branch $AcceptedBranch, commit $AcceptedCommit, CI validation run $AcceptedCiRunId, finalization run $AcceptedFinalizationRunId"

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

$normalModeDetected = $false
$dfuModeDetected = $false
$qFlipperDetected = $false

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
        $qFlipperDetected = $true
        Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'PASS' -Detail "Detected: $qFlipperFound"
    }
    else {
        Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'BLOCKED' -Detail 'qFlipper not found via PATH, common install directories, or the Windows uninstall registry. This is best-effort detection - it may still be installed under a nonstandard path. Per this gate''s design, do not proceed toward flashing until qFlipper is confirmed installed.'
    }
}

# ---------------------------------------------------------------------------
# Category: Hardware-connected checks - normal-mode device detection
# (DeviceDetect and RecoveryReadiness modes)
# ---------------------------------------------------------------------------

if (-not $deviceCheckApplicable) {
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status 'NOT_RUN' -Detail "Mode is $Mode - device detection was not requested."
}
else {
    try {
        $pnp = Get-PnpDevice -PresentOnly -ErrorAction Stop |
            Where-Object { $_.FriendlyName -match $NormalModeFriendlyNameSubstring -or $_.InstanceId -match [regex]::Escape($NormalModeVidPid) }
        if ($pnp) {
            $normalModeDetected = $true
            $first = $pnp | Select-Object -First 1
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status 'PASS' -Detail "Detected: $($first.FriendlyName) ($($first.InstanceId))"
        }
        else {
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status 'NOT_RUN' -Detail 'No connected Flipper Zero detected in normal mode via Windows PnP enumeration (Get-PnpDevice). Connect the device in normal (not DFU) mode and re-run if you want to confirm normal-mode detection.'
        }
    }
    catch {
        Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (normal mode)' -Status 'BLOCKED' -Detail "Get-PnpDevice failed or is unavailable ($($_.Exception.Message)) - this cmdlet requires Windows. Use a Windows machine for this mode."
    }
}

# ---------------------------------------------------------------------------
# Category: Hardware-connected checks - DFU/recovery-mode device detection
# (RecoveryReadiness mode only - the whole point of this mode is to let a
# user confirm their device is reachable in recovery mode WITHOUT performing
# any recovery action, before they might ever need it for real)
# ---------------------------------------------------------------------------

if ($Mode -ne 'RecoveryReadiness') {
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'NOT_RUN' -Detail "Mode is $Mode - DFU/recovery-mode detection is only attempted in -Mode RecoveryReadiness."
}
else {
    try {
        $pnpDfu = Get-PnpDevice -PresentOnly -ErrorAction Stop |
            Where-Object { $_.FriendlyName -match $DfuModeFriendlyNameSubstring -or $_.InstanceId -match [regex]::Escape($DfuModeVidPid) }
        if ($pnpDfu) {
            $dfuModeDetected = $true
            $firstDfu = $pnpDfu | Select-Object -First 1
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'PASS' -Detail "Detected: $($firstDfu.FriendlyName) ($($firstDfu.InstanceId)). This confirms the device's recovery path is reachable - no recovery action was performed by this check."
        }
        else {
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'NOT_RUN' -Detail "No device in DFU/recovery mode detected. This is expected if you have not deliberately put the device into DFU mode (hold Back while connecting USB) - only do so if you specifically want to test recovery-mode reachability now, per docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md. This check performs no recovery action itself either way."
        }
    }
    catch {
        Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection (DFU/recovery mode)' -Status 'BLOCKED' -Detail "Get-PnpDevice failed or is unavailable ($($_.Exception.Message)) - this cmdlet requires Windows. Use a Windows machine for this mode."
    }
}

# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host '=== Classification ===' -ForegroundColor Cyan

$hasFail = @($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count -gt 0
$hasBlocked = @($script:Results | Where-Object { $_.Status -eq 'BLOCKED' }).Count -gt 0
$hasNeedsReview = @($script:Results | Where-Object { $_.Status -eq 'NEEDS_REVIEW' }).Count -gt 0

# Per this gate's own design requirement: if ANY required pre-flash safety
# check fails, final classification must be BLOCKED - never a looser result.
if ($hasFail) {
    $classification = 'PRE-FLASH SAFEGUARD FAILED'
}
elseif ($deviceCheckApplicable -and -not $normalModeDetected -and -not $dfuModeDetected) {
    $classification = 'PRE-FLASH SAFEGUARD BLOCKED - DEVICE NOT AVAILABLE'
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
    $classification = 'PRE-FLASH SAFEGUARD CHECKS PASSED (see docs/PRE_FLASH_PHYSICAL_CHECKLIST.md for the full human checklist still required)'
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
        branch                = $AcceptedBranch
        commit                = $AcceptedCommit
        ciValidationRunId     = $AcceptedCiRunId
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
elseif ($hasBlocked -or $hasNeedsReview -or ($deviceCheckApplicable -and -not $normalModeDetected -and -not $dfuModeDetected)) { exit 2 }
else { exit 0 }

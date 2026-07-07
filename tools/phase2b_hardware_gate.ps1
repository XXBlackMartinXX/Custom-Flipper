<#
.SYNOPSIS
    Phase 2B.4 hardware-assisted validation gate for the accepted Phase 2B
    CI baseline (Custom-Flipper, integration/phase2b-first-batch).

.DESCRIPTION
    This script is defensive and non-destructive by default. It never
    flashes a device automatically under any mode or flag combination - the
    actual flash step always remains a manual, deliberate action performed
    by the operator with qFlipper or `fbt flash_usb` outside this script,
    even in -Mode HardwareAssisted with -AllowFlashPrompt. It is the Phase
    2B counterpart to tools/phase2a_hardware_gate.ps1 (which remains
    untouched and still valid for the accepted Phase 2A-only baseline) -
    same mechanism, extended to cover all 8 apps now in the accepted Phase
    2B baseline.

    It validates the Phase 2B baseline recorded in
    tools/phase2b_hardware_gate_config.json (branch, commit, and the real,
    GitHub-Actions-generated artifact hashes from docs/PHASE2B_3_ARTIFACT_HASHES.md)
    and, only in HardwareAssisted mode, attempts safe, read-only detection of
    a connected Flipper Zero and installed official flashing tooling (qFlipper).

    Four categories of check are always kept explicitly distinct in the
    report, never blurred together:
      - Automated checks       (repo state, config sanity, artifact hashes)
      - Hardware-connected checks (device detection, tooling detection - still
                                 read-only, no data exchange with the device)
      - Human-observed GUI checks (menu visibility, app launch, navigation,
                                 input handling - explicitly REQUIRES_HUMAN_OBSERVATION,
                                 never simulated or assumed)
      - Not-automatable checks (anything this script has no way to verify,
                                 explicitly marked as such rather than skipped
                                 silently)

    This script contains NO code path for Sub-GHz/RF, NFC/RFID/iButton,
    BadUSB/HID injection, BLE, GPIO, or IR interaction, and no code path for
    cloning, brute force, jamming, deauth, bypass, credential extraction, or
    any other unauthorized-access/security-abuse behavior, for any app,
    under any mode or flag. This is not a configuration toggle to disable -
    it is simply not implemented anywhere in this file.

.PARAMETER Mode
    Preflight (default) - repo/config checks only, no hardware, no artifact
                           directory required.
    DetectDevice        - Preflight checks, plus safe PnP-based detection of
                           a connected Flipper Zero and installed qFlipper.
                           Read-only; no serial communication with the device.
    HashVerify          - Preflight checks, plus verifying a downloaded
                           artifact directory's firmware.dfu and updater .tgz
                           against the accepted baseline's real SHA-256
                           hashes. Requires -ArtifactDir.
    HardwareAssisted    - Combines DetectDevice + HashVerify (if -ArtifactDir
                           given), prints a preflight summary, and - only
                           with -AllowFlashPrompt and a typed confirmation
                           phrase - acknowledges that a manual flash may now
                           proceed. Never performs the flash itself. Also
                           enumerates every GUI-level app check as
                           REQUIRES_HUMAN_OBSERVATION, pointing to
                           docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md.
    ReportOnly          - Regenerates a report from repo/config state only,
                           without attempting device detection or artifact
                           hashing even if -ArtifactDir is supplied. Useful
                           for a "status frozen, nothing live attempted" record.

.PARAMETER ArtifactDir
    Path to an already-downloaded-and-extracted Phase 2B CI artifact
    directory (containing firmware.dfu and/or flipper-z-f7-update-local.tgz
    somewhere under it). Required for a real result in HashVerify mode;
    optional elsewhere.

.PARAMETER AllowFlashPrompt
    Switch. Only meaningful in -Mode HardwareAssisted. Without it, this mode
    is strictly read-only (detection + hash verification + preflight summary
    only). With it, and only if a device was detected and the artifact
    hashes verified PASS, the script displays the artifact hashes and a
    rollback warning, then requires an exact typed confirmation phrase before
    acknowledging that a manual flash may proceed - it does not flash
    anything itself.

.PARAMETER ReportDir
    Directory to write JSON/Markdown reports into. Defaults to
    reports\phase2b_hardware under the repo root. Created if missing.

.PARAMETER RepoRoot
    Path to the repository root. Defaults to the parent directory of this
    script's own location (tools\..).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\phase2b_hardware_gate.ps1 -Mode Preflight

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\phase2b_hardware_gate.ps1 -Mode HashVerify -ArtifactDir "<artifact-dir>"

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\phase2b_hardware_gate.ps1 -Mode DetectDevice

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\tools\phase2b_hardware_gate.ps1 -Mode HardwareAssisted -ArtifactDir "<artifact-dir>" -AllowFlashPrompt
#>

[CmdletBinding()]
param(
    [ValidateSet('Preflight', 'DetectDevice', 'HashVerify', 'HardwareAssisted', 'ReportOnly')]
    [string]$Mode = 'Preflight',

    [string]$ArtifactDir = '',

    [switch]$AllowFlashPrompt,

    [string]$ReportDir = '',

    [string]$RepoRoot = ''
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
    $ReportDir = Join-Path $RepoRoot 'reports\phase2b_hardware'
}
if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$ConfigPath = Join-Path $ScriptRoot 'phase2b_hardware_gate_config.json'
if (-not (Test-Path $ConfigPath)) {
    throw "Config file not found at '$ConfigPath'. This script requires tools\phase2b_hardware_gate_config.json to exist alongside it."
}
$Config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json

$RunTimestampUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$RunTimestampForFilename = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss')

$script:Results = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('PASS', 'FAIL', 'BLOCKED', 'NOT_RUN', 'NEEDS_REVIEW', 'REQUIRES_HUMAN_OBSERVATION')][string]$Status,
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
        'PASS'                       { 'Green' }
        'FAIL'                       { 'Red' }
        'BLOCKED'                    { 'Yellow' }
        'NEEDS_REVIEW'               { 'Yellow' }
        'REQUIRES_HUMAN_OBSERVATION' { 'Cyan' }
        default                      { 'Gray' }
    }
    Write-Host ("[{0,-28}] [{1,-12}] {2}" -f $Category, $Status, $Name) -ForegroundColor $color
    if ($Detail) {
        Write-Host ("{0}{1}" -f (' ' * 46), $Detail) -ForegroundColor DarkGray
    }
}

function Get-LineSha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

Write-Host ''
Write-Host '=== Phase 2B.4 Hardware-Assisted Validation Gate ===' -ForegroundColor Cyan
Write-Host "Mode: $Mode"
Write-Host "Repo: $RepoRoot"
Write-Host "Timestamp (UTC): $RunTimestampUtc"
if ($ArtifactDir) { Write-Host "ArtifactDir: $ArtifactDir" }
Write-Host ''

# ---------------------------------------------------------------------------
# Category: Automated checks - repo/branch/commit state
# ---------------------------------------------------------------------------

Write-Host '--- Automated checks ---' -ForegroundColor Cyan

Push-Location $RepoRoot
try {
    $currentBranch = (& git rev-parse --abbrev-ref HEAD 2>&1)
    $currentCommit = (& git rev-parse HEAD 2>&1)
    $gitStatus = (& git status --short 2>&1) -join "`n"
}
finally {
    Pop-Location
}

if ($currentBranch -eq $Config.acceptedBaseline.branch) {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'PASS' -Detail "On expected branch '$currentBranch'"
}
else {
    Add-Result -Category 'Automated' -Name 'Branch verification' -Status 'NEEDS_REVIEW' -Detail "Expected '$($Config.acceptedBaseline.branch)', found '$currentBranch'."
}

if ($currentCommit -eq $Config.acceptedBaseline.ciBaselineSha) {
    Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted CI baseline)' -Status 'PASS' -Detail "HEAD matches accepted baseline commit $currentCommit"
}
else {
    Add-Result -Category 'Automated' -Name 'Commit verification (matches accepted CI baseline)' -Status 'NEEDS_REVIEW' -Detail "HEAD is $currentCommit, accepted baseline is $($Config.acceptedBaseline.ciBaselineSha). Hardware-assisted validation against a different commit does not itself validate the accepted baseline - confirm this is intentional."
}

if ($gitStatus.Trim() -eq '') {
    Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'PASS' -Detail 'No uncommitted changes'
}
else {
    Add-Result -Category 'Automated' -Name 'Git status (clean working tree)' -Status 'NEEDS_REVIEW' -Detail 'Uncommitted changes present' -Evidence $gitStatus
}

Add-Result -Category 'Automated' -Name 'Accepted baseline reference' -Status 'PASS' -Detail "CI validation run $($Config.acceptedBaseline.ciValidationRunId), finalization run $($Config.acceptedBaseline.finalizationWorkflowRunId)"

# ---------------------------------------------------------------------------
# Category: Automated checks - artifact hash verification
# ---------------------------------------------------------------------------

$hashVerifyApplicable = ($Mode -eq 'HashVerify' -or $Mode -eq 'HardwareAssisted') -and $ArtifactDir

if ($Mode -eq 'ReportOnly') {
    Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail "Mode is ReportOnly - live artifact hashing is never attempted in this mode by design, even if -ArtifactDir was supplied."
}
elseif (-not $hashVerifyApplicable) {
    if ($Mode -eq 'HashVerify' -or $Mode -eq 'HardwareAssisted') {
        Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail "Mode is $Mode but -ArtifactDir was not supplied - nothing to hash."
    }
    else {
        Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'NOT_RUN' -Detail "Mode is $Mode - artifact hash verification was not requested."
    }
}
else {
    if (-not (Test-Path $ArtifactDir)) {
        Add-Result -Category 'Automated' -Name 'Artifact hash verification' -Status 'FAIL' -Detail "ArtifactDir '$ArtifactDir' does not exist."
    }
    else {
        $allFiles = Get-ChildItem -Path $ArtifactDir -Recurse -File
        $firmwareCfg = $Config.expectedArtifacts.firmwareDfu
        $updaterCfg = $Config.expectedArtifacts.updaterPackage

        $firmware = $allFiles | Where-Object { $_.Name -eq $firmwareCfg.fileName } | Select-Object -First 1
        $updater = $allFiles | Where-Object { $_.Name -eq $updaterCfg.fileName } | Select-Object -First 1

        if (-not $firmware) {
            Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'FAIL' -Detail "'$($firmwareCfg.fileName)' not found under $ArtifactDir"
        }
        else {
            $actualSize = $firmware.Length
            $actualHash = Get-LineSha256 -Path $firmware.FullName
            if ($actualSize -eq $firmwareCfg.expectedSizeBytes -and $actualHash -eq $firmwareCfg.expectedSha256) {
                Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'PASS' -Detail "Size $actualSize bytes, SHA-256 $actualHash matches the accepted baseline exactly."
            }
            else {
                Add-Result -Category 'Automated' -Name 'Firmware artifact present and hash-verified' -Status 'FAIL' -Detail "MISMATCH - expected size $($firmwareCfg.expectedSizeBytes) / sha256 $($firmwareCfg.expectedSha256), found size $actualSize / sha256 $actualHash. Do not proceed to a flash with this artifact."
            }
        }

        if (-not $updater) {
            Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'FAIL' -Detail "'$($updaterCfg.fileName)' not found under $ArtifactDir"
        }
        else {
            $actualSize = $updater.Length
            $actualHash = Get-LineSha256 -Path $updater.FullName
            if ($actualSize -eq $updaterCfg.expectedSizeBytes -and $actualHash -eq $updaterCfg.expectedSha256) {
                Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'PASS' -Detail "Size $actualSize bytes, SHA-256 $actualHash matches the accepted baseline exactly."
            }
            else {
                Add-Result -Category 'Automated' -Name 'Updater artifact present and hash-verified' -Status 'FAIL' -Detail "MISMATCH - expected size $($updaterCfg.expectedSizeBytes) / sha256 $($updaterCfg.expectedSha256), found size $actualSize / sha256 $actualHash. Do not proceed to a flash with this artifact."
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Category: Hardware-connected checks - device + tooling detection
# ---------------------------------------------------------------------------

$deviceDetectionApplicable = ($Mode -eq 'DetectDevice' -or $Mode -eq 'HardwareAssisted')

$deviceDetected = $false
$qFlipperDetected = $false

if (-not $deviceDetectionApplicable) {
    Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection' -Status 'NOT_RUN' -Detail "Mode is $Mode - device detection was not requested."
    Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'NOT_RUN' -Detail "Mode is $Mode - tooling detection was not requested."
}
else {
    try {
        $pnp = Get-PnpDevice -PresentOnly -ErrorAction Stop |
            Where-Object { $_.FriendlyName -match $Config.deviceDetection.expectedFriendlyNameSubstring -or $_.InstanceId -match [regex]::Escape($Config.deviceDetection.expectedVidPid) }
        if ($pnp) {
            $deviceDetected = $true
            $first = $pnp | Select-Object -First 1
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection' -Status 'PASS' -Detail "Detected: $($first.FriendlyName) ($($first.InstanceId))"
        }
        else {
            Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection' -Status 'NOT_RUN' -Detail 'No connected Flipper Zero detected via Windows PnP enumeration (Get-PnpDevice). Connect the device in normal (not DFU) mode and re-run if you want to proceed with hardware-assisted checks.'
        }
    }
    catch {
        Add-Result -Category 'HardwareConnected' -Name 'Flipper Zero detection' -Status 'BLOCKED' -Detail "Get-PnpDevice failed or is unavailable ($($_.Exception.Message)) - this cmdlet requires Windows. Use a Windows machine for this mode."
    }

    $qFlipperFound = $null
    try {
        $cmd = Get-Command -Name 'qFlipper.exe' -ErrorAction SilentlyContinue
        if ($cmd) { $qFlipperFound = $cmd.Source }
    }
    catch { }

    if (-not $qFlipperFound) {
        foreach ($dirTemplate in $Config.officialToolingDetection.qFlipperCommonInstallDirs) {
            $dir = $ExecutionContext.InvokeCommand.ExpandString($dirTemplate)
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
        Add-Result -Category 'HardwareConnected' -Name 'Official flashing tooling detection (qFlipper)' -Status 'BLOCKED' -Detail 'qFlipper not found via PATH, common install directories, or the Windows uninstall registry. This is best-effort detection - it may still be installed under a nonstandard path. Flashing is classified BLOCKED / TOOLING NOT AVAILABLE unless and until this is confirmed, per this script''s design (never improvise a flash path).'
    }
}

# ---------------------------------------------------------------------------
# Category: Flash confirmation gate (HardwareAssisted + -AllowFlashPrompt only)
# ---------------------------------------------------------------------------

if ($Mode -eq 'HardwareAssisted') {
    if (-not $AllowFlashPrompt) {
        Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'NOT_RUN' -Detail '-AllowFlashPrompt was not passed. This run is strictly read-only - no flash prompt was shown, nothing was written to any device.'
    }
    else {
        $firmwareOk = @($script:Results | Where-Object { $_.Name -eq 'Firmware artifact present and hash-verified' -and $_.Status -eq 'PASS' }).Count -gt 0
        $updaterOk = @($script:Results | Where-Object { $_.Name -eq 'Updater artifact present and hash-verified' -and $_.Status -eq 'PASS' }).Count -gt 0

        if (-not $deviceDetected) {
            Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'BLOCKED' -Detail '-AllowFlashPrompt was passed, but no device was detected. Refusing to show the flash confirmation prompt with nothing connected.'
        }
        elseif (-not ($firmwareOk -and $updaterOk)) {
            Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'BLOCKED' -Detail '-AllowFlashPrompt was passed, but artifact hash verification did not PASS for both files (or -ArtifactDir was not supplied). Refusing to show the flash confirmation prompt without hash-verified artifacts.'
        }
        elseif (-not $qFlipperDetected) {
            Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'BLOCKED' -Detail 'TOOLING NOT AVAILABLE - qFlipper (or other official flashing tooling) was not detected. This script does not improvise a flash path with unofficial tooling; install qFlipper and re-run.'
        }
        else {
            Write-Host ''
            Write-Host '=== FLASH CONFIRMATION GATE ===' -ForegroundColor Yellow
            Write-Host 'Device detected. Artifact hashes verified. qFlipper detected.' -ForegroundColor Yellow
            Write-Host "Firmware: $($Config.expectedArtifacts.firmwareDfu.fileName) - SHA-256 $($Config.expectedArtifacts.firmwareDfu.expectedSha256)" -ForegroundColor Yellow
            Write-Host "Updater:  $($Config.expectedArtifacts.updaterPackage.fileName) - SHA-256 $($Config.expectedArtifacts.updaterPackage.expectedSha256)" -ForegroundColor Yellow
            Write-Host 'Before proceeding, confirm you have completed docs/PHASE2A_FLASHING_PRECHECK.md' -ForegroundColor Yellow
            Write-Host '(backup, current firmware version recorded, rollback artifact identified) -' -ForegroundColor Yellow
            Write-Host 'the rollback discipline is batch-agnostic and applies unchanged to this baseline.' -ForegroundColor Yellow
            Write-Host 'This script will NOT flash anything itself - it only records your confirmation' -ForegroundColor Yellow
            Write-Host 'that you understand the risk and intend to flash manually, afterward, using' -ForegroundColor Yellow
            Write-Host 'qFlipper or `fbt flash_usb` yourself.' -ForegroundColor Yellow
            Write-Host ''
            $typed = Read-Host "Type exactly '$($Config.flashConfirmationPhrase)' to proceed, anything else cancels"
            if ($typed -eq $Config.flashConfirmationPhrase) {
                Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'PASS' -Detail 'Operator typed the exact confirmation phrase. Manual flash may now proceed OUTSIDE this script, using qFlipper or fbt flash_usb. This script performed no flash and will perform none - it only recorded this confirmation.'
            }
            else {
                Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'NOT_RUN' -Detail 'Operator did not type the exact confirmation phrase. No flash was confirmed; none was performed.'
            }
        }
    }
}
else {
    Add-Result -Category 'HardwareConnected' -Name 'Flash confirmation gate' -Status 'NOT_RUN' -Detail "Mode is $Mode - flash confirmation is only ever offered in HardwareAssisted mode with -AllowFlashPrompt."
}

# ---------------------------------------------------------------------------
# Category: Human-observed GUI checks (HardwareAssisted only - always listed,
# never simulated, never assumed)
# ---------------------------------------------------------------------------

if ($Mode -eq 'HardwareAssisted') {
    foreach ($app in $Config.allowedApps) {
        Add-Result -Category 'HumanObserved' -Name "App menu/launch/navigation check: $($app.displayName)" -Status 'REQUIRES_HUMAN_OBSERVATION' -Detail "Menu visibility, launch success, on-screen navigation, one normal input, one edge input, and exit behavior cannot be verified by this script - a human must watch the device screen. Use docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md, section for $($app.displayName)."
    }
    $chessStoragePath = $Config.expectedAppPrivateStoragePaths.chess
    Add-Result -Category 'HumanObserved' -Name 'Chess save/load private-path check' -Status 'REQUIRES_HUMAN_OBSERVATION' -Detail "Verifying a chess save file appears only under $chessStoragePath during actual gameplay requires driving the game (human observation) and then inspecting the SD card - not automatable with current tooling. See docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md, chess section."
    $sudokuStoragePath = $Config.expectedAppPrivateStoragePaths.sudoku
    Add-Result -Category 'HumanObserved' -Name 'Sudoku save/load private-path check' -Status 'REQUIRES_HUMAN_OBSERVATION' -Detail "Verifying a sudoku save file appears only under $sudokuStoragePath during actual gameplay requires driving the game (human observation) and then inspecting the SD card - not automatable with current tooling, and not yet confirmed against real hardware (source-derived only, see docs/PHASE2B_2_SAFETY_REVIEW.md). See docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md, sudoku section."
    Add-Result -Category 'NotAutomatable' -Name 'No crash/reboot/freeze during use' -Status 'REQUIRES_HUMAN_OBSERVATION' -Detail 'Requires a human operating the device through the smoke-test checklist and watching for the global fail conditions in docs/PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md (batch-agnostic; applies unchanged to the Phase 2B-inclusive baseline).'
    Add-Result -Category 'NotAutomatable' -Name 'No unexpected hardware activation (RF/NFC/BLE LEDs etc.)' -Status 'REQUIRES_HUMAN_OBSERVATION' -Detail 'Requires a human watching the device''s own indicators during use - this script has no telemetry channel to the device and does not claim one.'
}
else {
    Add-Result -Category 'HumanObserved' -Name 'GUI-level app checks' -Status 'NOT_RUN' -Detail "Mode is $Mode - GUI-level checks are only enumerated in HardwareAssisted mode (they are never automated in any mode; HardwareAssisted mode lists them explicitly instead of omitting them)."
}

# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host '=== Classification ===' -ForegroundColor Cyan

$hasFail = @($script:Results | Where-Object { $_.Status -eq 'FAIL' }).Count -gt 0
$hasBlocked = @($script:Results | Where-Object { $_.Status -eq 'BLOCKED' }).Count -gt 0
$hasNeedsReview = @($script:Results | Where-Object { $_.Status -eq 'NEEDS_REVIEW' }).Count -gt 0
$hasHumanObs = @($script:Results | Where-Object { $_.Status -eq 'REQUIRES_HUMAN_OBSERVATION' }).Count -gt 0
$deviceWasDetected = @($script:Results | Where-Object { $_.Name -eq 'Flipper Zero detection' -and $_.Status -eq 'PASS' }).Count -gt 0

if ($Mode -eq 'Preflight' -or $Mode -eq 'ReportOnly') {
    if ($hasFail) { $classification = 'NEEDS REVIEW' }
    elseif ($hasNeedsReview) { $classification = 'NEEDS REVIEW' }
    else { $classification = 'PREFLIGHT OK - HARDWARE NOT ATTEMPTED' }
}
elseif ($Mode -eq 'DetectDevice' -or $Mode -eq 'HashVerify') {
    if ($hasFail) { $classification = 'HARDWARE VALIDATION FAILED' }
    elseif (-not $deviceWasDetected -and $Mode -eq 'DetectDevice') { $classification = 'HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE' }
    elseif ($hasBlocked) { $classification = 'HARDWARE VALIDATION BLOCKED' }
    else { $classification = 'NEEDS REVIEW' }
}
else {
    # HardwareAssisted
    if ($hasFail) {
        $classification = 'HARDWARE VALIDATION FAILED'
    }
    elseif (-not $deviceWasDetected) {
        $classification = 'HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE'
    }
    elseif ($hasHumanObs) {
        $classification = 'HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING'
    }
    elseif ($hasBlocked) {
        $classification = 'HARDWARE VALIDATION BLOCKED'
    }
    else {
        $classification = 'NEEDS REVIEW'
    }
}

Write-Host "Classification: $classification" -ForegroundColor $(if ($classification -like 'HARDWARE VALIDATION FAILED*') { 'Red' } elseif ($classification -like '*BLOCKED*') { 'Yellow' } else { 'Cyan' })
Write-Host ''
Write-Host 'REMINDER: This script never flashes a device automatically under any' -ForegroundColor Yellow
Write-Host 'circumstance, and never claims hardware testing on your behalf. GUI-level' -ForegroundColor Yellow
Write-Host 'app behavior always requires a human running docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md.' -ForegroundColor Yellow
Write-Host "Hardware flashing/testing: NOT PERFORMED unless you performed it yourself." -ForegroundColor Yellow
Write-Host "Release status: $($Config.expectedReleaseStatusWording)." -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------

$reportObject = [ordered]@{
    timestampUtc   = $RunTimestampUtc
    mode           = $Mode
    repoPath       = $RepoRoot
    artifactDir    = $ArtifactDir
    branch         = $currentBranch
    commit         = $currentCommit
    checks         = $script:Results
    classification = $classification
    hardwareStatus = [ordered]@{
        hardwareAssistedValidation = if ($Mode -eq 'HardwareAssisted' -and $deviceWasDetected) { 'ATTEMPTED' } else { 'NOT_RUN' }
        hardwareFlashingTesting    = 'NOT_PERFORMED'
        releaseStatus              = $Config.expectedReleaseStatusWording
    }
    nextActions    = @(
        'Review every FAIL, BLOCKED, and NEEDS_REVIEW entry above before treating this run as clean.',
        'REQUIRES_HUMAN_OBSERVATION entries are not optional to skip - complete docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md on the real device and record results in a copy of docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md.',
        'This report alone never constitutes hardware-tested or release-ready status.'
    )
}

$jsonPath = Join-Path $ReportDir "phase2b_hardware_gate_$RunTimestampForFilename.json"
$reportObject | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

$md = New-Object System.Collections.Generic.List[string]
$md.Add('# Phase 2B.4 Hardware-Assisted Validation Gate Report') | Out-Null
$md.Add('') | Out-Null
$md.Add("Generated: $RunTimestampUtc") | Out-Null
$md.Add("Mode: $Mode") | Out-Null
$md.Add("Branch: $currentBranch") | Out-Null
$md.Add("Commit: $currentCommit") | Out-Null
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
$md.Add('- Hardware-assisted validation: ' + $(if ($Mode -eq 'HardwareAssisted' -and $deviceWasDetected) { 'ATTEMPTED (see checks above)' } else { 'NOT RUN' })) | Out-Null
$md.Add('- Hardware flashing/testing: NOT PERFORMED unless you performed it yourself outside this script') | Out-Null
$md.Add("- Release status: $($Config.expectedReleaseStatusWording)") | Out-Null
$md.Add('') | Out-Null
$md.Add('**This report never claims hardware testing or release-readiness on your behalf.**') | Out-Null

$mdPath = Join-Path $ReportDir "phase2b_hardware_gate_$RunTimestampForFilename.md"
($md -join "`n") | Set-Content -Path $mdPath -Encoding UTF8

Write-Host ''
Write-Host "JSON report: $jsonPath"
Write-Host "Markdown report: $mdPath"

if ($hasFail) { exit 1 }
elseif ($hasBlocked -or $hasNeedsReview) { exit 2 }
else { exit 0 }

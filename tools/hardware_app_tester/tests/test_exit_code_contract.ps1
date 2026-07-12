<#
.SYNOPSIS
    Dependency-free (no Pester) regression harness for the Gate A
    exit-code contract in Run-GateA-HardwareProof.ps1.

.DESCRIPTION
    Pester is not available in this project's Linux/pwsh development
    sandbox (no package registry access to install it), so this harness
    is a small, self-contained set of assertions runnable with plain
    `pwsh -File`. It covers two layers:

    1. Pure contract tests (Get-ExitCodeForOutcome / ConvertTo-GateOutcome)
       - loaded by literally extracting the real script's function and
         enum definitions (everything before its top-level `try { ... }`
         execution block) and evaluating that text in this process, so
         these tests can never silently drift from the shipped
         implementation the way a hand-copied re-implementation could.

    2. Real subprocess tests - actually invoking
       Run-GateA-HardwareProof.ps1 as a child process for the scenarios
       that are safe and deterministic to reproduce without real
       hardware (successful DryRun, a deliberately dirty working tree,
       and the -SelfTestForceInternalError fault-injection switch),
       and asserting on $LASTEXITCODE plus the written evidence.

    Device-dependent scenarios (no device, DFU detected, multiple
    devices, ambiguous COM port, port contention after retry, USB
    disappearance, uptime reset) cannot be reproduced for real without
    physical hardware or a fixture Flipper. Layer 1 exercises them
    instead, using the *exact* classification strings the real
    discovery.py/cli.py modules are already proven (by
    tools/hardware_app_tester/tests/test_discovery.py and
    test_cli_hardening.py, both real/passing pytest suites) to emit for
    those exact conditions - proving the status-string -> exit-code
    half of the contract, while the Python suite proves the
    condition -> status-string half.

    Exit code of this script itself: 0 if every assertion passed, 1 if
    any assertion failed.
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = ''
)

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}
$RepoRoot = (Resolve-Path $RepoRoot).Path
$ScriptUnderTest = Join-Path $RepoRoot 'tools\hardware_app_tester\Run-GateA-HardwareProof.ps1'

$script:PassCount = 0
$script:FailCount = 0

function Assert-Equal {
    param([string]$Name, $Expected, $Actual)
    if ("$Expected" -eq "$Actual") {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        $script:PassCount++
    }
    else {
        Write-Host "[FAIL] $Name - expected '$Expected', got '$Actual'" -ForegroundColor Red
        $script:FailCount++
    }
}

function Assert-True {
    param([string]$Name, [bool]$Condition, [string]$Detail = '')
    if ($Condition) {
        Write-Host "[PASS] $Name" -ForegroundColor Green
        $script:PassCount++
    }
    else {
        Write-Host "[FAIL] $Name $Detail" -ForegroundColor Red
        $script:FailCount++
    }
}

# ---------------------------------------------------------------------------
# Layer 1 - pure contract tests, loaded from the real script's own text.
# ---------------------------------------------------------------------------

$scriptText = Get-Content -Path $ScriptUnderTest -Raw
$startMarker = "`nenum GateAOutcome {`n"
$endMarker = "`nfunction Write-Phase {`n"
$startIndex = $scriptText.IndexOf($startMarker)
$endIndex = $scriptText.IndexOf($endMarker)
Assert-True -Name 'Located the enum/pure-function region in the real script' -Condition ($startIndex -gt 0 -and $endIndex -gt $startIndex)
# Deliberately excludes the script's own [CmdletBinding()]/param(...)
# block above this region - evaluating a bare param() block via
# Invoke-Expression would rebind $RepoRoot/$DryRun/etc. to their empty
# defaults in this test's own scope, silently clobbering variables this
# test file already set. Only the enum and the two pure, side-effect-
# free contract functions (Get-ExitCodeForOutcome, ConvertTo-GateOutcome)
# are needed for Layer 1, so only that slice is evaluated.
$definitionsText = $scriptText.Substring($startIndex, $endIndex - $startIndex)

Invoke-Expression $definitionsText

Assert-Equal -Name 'DryRunReady -> exit 0'   -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::DryRunReady))
Assert-Equal -Name 'HardwarePass -> exit 0'  -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::HardwarePass))
Assert-Equal -Name 'GateAPartial -> exit 0'  -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::GateAPartial))
Assert-Equal -Name 'GateBPass -> exit 0'     -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::GateBPass))
Assert-Equal -Name 'GateBPartial -> exit 0'  -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::GateBPartial))
Assert-Equal -Name 'Blocked -> exit 2'       -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::Blocked))
Assert-Equal -Name 'Failed -> exit 3'        -Expected 3 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::Failed))
Assert-Equal -Name 'InternalError -> exit 1' -Expected 1 -Actual (Get-ExitCodeForOutcome -Outcome ([GateAOutcome]::InternalError))

# --- C/D/E: expected operational blocking conditions -> BLOCKED -> 2 ---
# These are the exact status strings discovery.py's classify_ports()
# returns for these exact conditions (see test_discovery.py::
# test_no_devices_blocked, test_dfu_only_blocked_not_pass,
# test_ambiguous_multiple_devices_blocked, test_port_contention_blocked
# - all real, passing pytest assertions against the pure classification
# function).
Assert-Equal -Name 'C. No normal device -> Blocked' -Expected ([GateAOutcome]::Blocked) -Actual (ConvertTo-GateOutcome -Status 'BLOCKED - NO NORMAL-MODE DEVICE DETECTED' -Gate 'GateA')
Assert-Equal -Name 'C. No normal device -> exit 2' -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'BLOCKED - NO NORMAL-MODE DEVICE DETECTED' -Gate 'GateA'))
Assert-Equal -Name 'D. DFU device detected -> Blocked' -Expected ([GateAOutcome]::Blocked) -Actual (ConvertTo-GateOutcome -Status 'BLOCKED - DFU MODE DETECTED' -Gate 'GateA')
Assert-Equal -Name 'D. DFU device detected -> exit 2' -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'BLOCKED - DFU MODE DETECTED' -Gate 'GateA'))
Assert-Equal -Name 'Multiple devices -> exit 2' -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'BLOCKED - AMBIGUOUS MULTIPLE DEVICES' -Gate 'GateA'))
Assert-Equal -Name 'E. Port contention after retry -> Blocked' -Expected ([GateAOutcome]::Blocked) -Actual (ConvertTo-GateOutcome -Status 'BLOCKED - PORT CONTENTION' -Gate 'GateA')
Assert-Equal -Name 'E. Port contention after retry -> exit 2' -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'BLOCKED - PORT CONTENTION' -Gate 'GateA'))
Assert-Equal -Name 'Required profile missing -> exit 2' -Expected 2 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Gate 'GateA'))

# --- F: representative Gate A run, clean, capped at PARTIAL -> exit 0 ---
Assert-Equal -Name 'F. Gate A clean run (PARTIAL ceiling) -> exit 0' -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE A HARDWARE PROOF PARTIAL' -Gate 'GateA'))
# Also prove the contract's forward-looking PASS case (not claimed as
# achievable by this tool version - see the script's own docstring -
# but the exit-code table must still be correct if/when it is).
Assert-Equal -Name 'F. Gate A HARDWARE PROOF PASS -> exit 0' -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE A HARDWARE PROOF PASS' -Gate 'GateA'))

# --- G: operator declines optional Gate B expansion -> exit 0 ---
Assert-Equal -Name 'G. Gate B PARTIAL (declined expansion) -> exit 0' -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE B SAFE-AUTOMATION QUALIFICATION PARTIAL' -Gate 'GateB'))
Assert-Equal -Name 'G. Gate B PASS -> exit 0' -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE B SAFE-AUTOMATION QUALIFICATION PASS' -Gate 'GateB'))

# --- H: USB disappearance / uptime reset -> FAILED -> exit 3 ---
Assert-Equal -Name 'H. Device-state FAILED -> Failed' -Expected ([GateAOutcome]::Failed) -Actual (ConvertTo-GateOutcome -Status 'GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW' -Gate 'GateA')
Assert-Equal -Name 'H. Device-state FAILED -> exit 3' -Expected 3 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW' -Gate 'GateA'))

# --- Mock-prefixed statuses must map identically to their unprefixed
#     equivalents (mock is never allowed to change the exit-code side
#     of the contract, only the HardwareExecutionOccurred disclosure). ---
Assert-Equal -Name 'MOCK-prefixed PARTIAL still -> exit 0' -Expected 0 -Actual (Get-ExitCodeForOutcome -Outcome (ConvertTo-GateOutcome -Status 'MOCK - GATE A HARDWARE PROOF PARTIAL' -Gate 'GateA'))

# ---------------------------------------------------------------------------
# Layer 2 - real subprocess tests.
# ---------------------------------------------------------------------------

function Invoke-ScriptUnderTest {
    param([string[]]$ScriptArgs)
    $stdoutFile = [System.IO.Path]::GetTempFileName()
    try {
        $psArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $ScriptUnderTest) + $ScriptArgs
        & pwsh @psArgs *> $stdoutFile
        $exit = $LASTEXITCODE
        $output = Get-Content -Path $stdoutFile -Raw
        return [ordered]@{ ExitCode = $exit; Output = $output }
    }
    finally {
        Remove-Item -Path $stdoutFile -ErrorAction SilentlyContinue
    }
}

function Get-LatestReportDir {
    $base = Join-Path $RepoRoot 'reports\hardware_app_tester'
    if (-not (Test-Path $base)) { return $null }
    return (Get-ChildItem -Path $base -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
}

# --- A. Successful DryRun ---
$reportsBase = Join-Path $RepoRoot 'reports\hardware_app_tester'
if (Test-Path $reportsBase) { Remove-Item -Path $reportsBase -Recurse -Force -ErrorAction SilentlyContinue }

$dryRunResult = Invoke-ScriptUnderTest -ScriptArgs @('-DryRun')
Assert-Equal -Name 'A. Successful DryRun -> exit 0' -Expected 0 -Actual $dryRunResult.ExitCode
Assert-True -Name 'A. Successful DryRun output contains COMPLETED' -Condition ($dryRunResult.Output -match '(?m)^=== COMPLETED ===')
Assert-True -Name 'A. Successful DryRun output does NOT classify the run as STOPPED' -Condition ($dryRunResult.Output -notmatch '(?m)^=== STOPPED ===')
Assert-True -Name 'A. Successful DryRun output states hardware execution not performed' -Condition ($dryRunResult.Output -match 'HARDWARE EXECUTION: NOT PERFORMED')
Assert-True -Name 'A. Successful DryRun output states REAL HARDWARE RUN NOT YET PERFORMED' -Condition ($dryRunResult.Output -match 'REAL HARDWARE RUN NOT YET PERFORMED')

$dryRunReportDir = Get-LatestReportDir
Assert-True -Name 'A/J. Evidence (run_manifest.json) was written for the successful DryRun' -Condition ($null -ne $dryRunReportDir -and (Test-Path (Join-Path $dryRunReportDir 'run_manifest.json')))
if ($dryRunReportDir) {
    $dryRunManifest = Get-Content (Join-Path $dryRunReportDir 'run_manifest.json') -Raw | ConvertFrom-Json
    Assert-Equal -Name 'A. Manifest exit_code is 0' -Expected 0 -Actual $dryRunManifest.exit_code
    Assert-Equal -Name 'A. Manifest outcome is DryRunReady' -Expected 'DryRunReady' -Actual $dryRunManifest.outcome
    Assert-Equal -Name 'A. Manifest hardware_execution_occurred is false' -Expected 'False' -Actual $dryRunManifest.hardware_execution_occurred
}

# --- I. Internal unhandled exception -> exit code 1 ---
if (Test-Path $reportsBase) { Remove-Item -Path $reportsBase -Recurse -Force -ErrorAction SilentlyContinue }
$internalErrorResult = Invoke-ScriptUnderTest -ScriptArgs @('-SelfTestForceInternalError')
Assert-Equal -Name 'I. Internal unhandled exception -> exit 1' -Expected 1 -Actual $internalErrorResult.ExitCode
Assert-True -Name 'I. Internal error output identifies itself as an internal error' -Condition ($internalErrorResult.Output -match 'INTERNAL ERROR')
$internalErrorReportDir = Get-LatestReportDir
Assert-True -Name 'I/J. Evidence was written for the internal-error path' -Condition ($null -ne $internalErrorReportDir -and (Test-Path (Join-Path $internalErrorReportDir 'run_manifest.json')))

# --- B (proxy)/repository-verification BLOCKED: a real, deliberately
#     dirty working tree - a genuine pre-hardware BLOCKED condition,
#     reached before any device access is attempted, exactly like a
#     DryRun profile-validation failure would be. ---
Push-Location $RepoRoot
try {
    $sentinelFile = Join-Path $RepoRoot 'tools\hardware_app_tester\.exit_code_contract_test_sentinel'
    'sentinel - deleted by the test that created it' | Set-Content -Path $sentinelFile
    try {
        if (Test-Path $reportsBase) { Remove-Item -Path $reportsBase -Recurse -Force -ErrorAction SilentlyContinue }
        $dirtyTreeResult = Invoke-ScriptUnderTest -ScriptArgs @('-DryRun')
        Assert-Equal -Name 'B. Dirty working tree (pre-hardware BLOCKED) -> exit 2' -Expected 2 -Actual $dirtyTreeResult.ExitCode
        Assert-True -Name 'B. Dirty working tree output classifies as BLOCKED, not silently ignored' -Condition ($dirtyTreeResult.Output -match 'BLOCKED')
        Assert-True -Name 'B. Dirty working tree: no device access was attempted' -Condition ($dirtyTreeResult.Output -notmatch 'ACTION REQUIRED: connect one normally booted Flipper Zero')
    }
    finally {
        # -Force is required here: PowerShell treats dotfiles as
        # hidden on every platform (not just Windows), and refuses to
        # remove a hidden item without it - confirmed directly, this
        # sentinel file was otherwise silently left behind on disk
        # even though this `finally` block executed.
        Remove-Item -Path $sentinelFile -Force -ErrorAction SilentlyContinue
    }
}
finally {
    Pop-Location
}

if (Test-Path $reportsBase) { Remove-Item -Path $reportsBase -Recurse -Force -ErrorAction SilentlyContinue }

# ---------------------------------------------------------------------------
# K. No flashing/update/Repair/erase/format capability was added.
# ---------------------------------------------------------------------------

$forbiddenPattern = '(?i)(reflash|firmware\s*update|firmware\s*install|firmware\s*repair|enter\s*dfu|format\s*storage|format\s*device|erase\s*device)'
$forbiddenMatches = Select-String -Path $ScriptUnderTest -Pattern $forbiddenPattern -AllMatches
$genuineForbiddenMatches = $forbiddenMatches | Where-Object {
    $_.Line -notmatch '(?i)never|do not|does not|no flashing|will not|not flash|not install|not update|not repair|not erase|not format|refus'
}
Assert-True -Name 'K. No flashing/update/Repair/erase/format capability found in the runner' -Condition ($genuineForbiddenMatches.Count -eq 0) -Detail (($genuineForbiddenMatches | ForEach-Object { $_.Line }) -join ' | ')

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host "Passed: $script:PassCount  Failed: $script:FailCount" -ForegroundColor Cyan

if ($script:FailCount -gt 0) {
    exit 1
}
exit 0

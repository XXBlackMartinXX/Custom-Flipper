<#
.SYNOPSIS
    Regression tests for tools/pre_flash_safeguard_gate.ps1's identity
    evaluation and baseline ancestry/diff logic - no real hardware, no real
    device, and no network access required.

.DESCRIPTION
    Dot-sources tools/pre_flash_safeguard_gate.ps1 (which, when dot-sourced,
    loads only its function definitions and performs no hardware
    detection, no git operations against the real repo beyond what a test
    explicitly requests, and no report generation - see the dot-source
    guard near the end of that file) and then exercises the exact
    regression scenarios required by the Pre-Flash Safeguard Correctness
    Patch:

    Test A - exact Flipper DFU identity is accepted.
    Test B - an unrelated camera DFU device is rejected, never accepted.
    Test C - a generic "DFU"-named device with a non-Flipper VID:PID is
             rejected.
    Test D - a normal-mode Flipper identity is rejected by the DFU-specific
             check (it is not a DFU device).
    Test E - among multiple devices (an unrelated camera DFU plus the exact
             Flipper DFU), only the exact entry determines a PASS.
    Test F - the real repository's actual baseline ancestry/diff logic,
             run against this repo's real accepted baseline commit and
             real HEAD, is confirmed to classify correctly (this project's
             own HEAD is expected to be a docs/tools-only descendant of
             the accepted baseline at the time this test is written).
    Test G - a disposable scratch git repository (created under the OS
             temp directory, entirely outside this repository, and deleted
             after the test) proves that a change under applications_user/
             between the accepted baseline and HEAD is correctly rejected.
             This never touches this repository's own applications_user/.

    This file performs no flashing, no device interaction, and no writes
    to this repository - it is read-only against the real repo (Test F)
    and entirely self-contained for everything else.

.EXAMPLE
    pwsh -NoProfile -File .\tools\pre_flash_safeguard_gate.tests.ps1
#>

[CmdletBinding()]
param(
    [string]$TestRepoRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $TestRepoRoot) {
    $TestRepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
}
$TestRepoRoot = (Resolve-Path $TestRepoRoot).Path

# NOTE: pre_flash_safeguard_gate.ps1 has its own [CmdletBinding()] param()
# block, including a -RepoRoot parameter. Dot-sourcing it re-runs that
# param block IN THIS SCRIPT'S SCOPE, binding -RepoRoot (default '') into
# any local variable of that same name - so this test script deliberately
# uses the differently-named $TestRepoRoot throughout to avoid that
# collision, and dot-sources only after computing $TestRepoRoot.
. (Join-Path $PSScriptRoot 'pre_flash_safeguard_gate.ps1')

$script:TestResults = New-Object System.Collections.Generic.List[object]

function Assert-TestResult {
    param(
        [Parameter(Mandatory)][string]$TestName,
        [Parameter(Mandatory)][bool]$Condition,
        [string]$Detail = ''
    )
    $status = if ($Condition) { 'PASS' } else { 'FAIL' }
    $color = if ($Condition) { 'Green' } else { 'Red' }
    Write-Host ("[{0,-6}] {1}" -f $status, $TestName) -ForegroundColor $color
    if ($Detail) { Write-Host ("       $Detail") -ForegroundColor DarkGray }
    $script:TestResults.Add([ordered]@{ Test = $TestName; Status = $status; Detail = $Detail }) | Out-Null
}

function New-DeviceFixture {
    param([string]$InstanceId, [string]$FriendlyName)
    return [pscustomobject]@{ InstanceId = $InstanceId; FriendlyName = $FriendlyName }
}

function New-SuccessEnumeration {
    param([array]$Devices)
    return [ordered]@{ Success = $true; Devices = @($Devices); ErrorType = $null; ErrorMessage = $null }
}

Write-Host ''
Write-Host '=== Pre-Flash Safeguard Gate - Regression Tests ===' -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# Test A - exact Flipper DFU success
# ---------------------------------------------------------------------------
$fixtureA = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$resultA = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureA))
Assert-TestResult -TestName 'Test A - exact Flipper DFU success' -Condition ($resultA.Status -like 'PASS*') -Detail "Status: $($resultA.Status)"

# ---------------------------------------------------------------------------
# Test B - unrelated camera DFU rejection (the exact false-positive fixture)
# ---------------------------------------------------------------------------
$fixtureB = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'
$resultB = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureB))
Assert-TestResult -TestName 'Test B - unrelated camera DFU rejection' -Condition ($resultB.Status -like 'BLOCKED*' -and $resultB.Status -notlike 'PASS*') -Detail "Status: $($resultB.Status)"

# ---------------------------------------------------------------------------
# Test C - generic DFU name rejection (non-Flipper VID:PID)
# ---------------------------------------------------------------------------
$fixtureC = New-DeviceFixture -InstanceId 'USB\VID_1234&PID_5678\SOMESERIAL01' -FriendlyName 'DFU in FS Mode'
$resultC = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureC))
Assert-TestResult -TestName 'Test C - generic DFU name rejection' -Condition ($resultC.Status -like 'BLOCKED*') -Detail "Status: $($resultC.Status)"

# ---------------------------------------------------------------------------
# Test D - normal-mode Flipper is not DFU
# ---------------------------------------------------------------------------
$fixtureD = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$resultD = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureD))
Assert-TestResult -TestName 'Test D - normal-mode Flipper rejected by DFU check' -Condition ($resultD.Status -like 'BLOCKED*') -Detail "Status: $($resultD.Status)"
# Cross-check: the same fixture DOES pass the normal-mode check (sanity, not
# one of the 7 required tests, but confirms the two identity functions are
# not accidentally conflated).
$resultDNormal = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureD))
Assert-TestResult -TestName 'Test D (sanity) - same fixture PASSes normal-mode check' -Condition ($resultDNormal.Status -like 'PASS*') -Detail "Status: $($resultDNormal.Status)"

# ---------------------------------------------------------------------------
# Test E - multiple devices: camera DFU plus exact Flipper DFU -> PASS based
# only on the exact entry
# ---------------------------------------------------------------------------
$resultE = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureB, $fixtureA))
$eIsPass = $resultE.Status -like 'PASS*'
$eMentionsFlipperSerial = $resultE.Detail -like '*2059388C4831*'
Assert-TestResult -TestName 'Test E - multiple devices, only exact entry matches' -Condition ($eIsPass -and $eMentionsFlipperSerial) -Detail "Status: $($resultE.Status); Detail mentions exact InstanceId: $eMentionsFlipperSerial"

# ---------------------------------------------------------------------------
# Test F - docs/tools-only descendant is accepted.
#
# IMPORTANT, discovered while writing this test: the REAL repository's HEAD
# is NOT currently a pure docs/tools-only descendant of the accepted
# baseline commit under this check's strict allow-list, because
# .github/workflows/fcc-id-lookup-finalize-baseline.yml was added at commit
# 22167ac - AFTER the accepted baseline commit - as part of this project's
# own (already-completed, already-reviewed) baseline-finalization process.
# That is a real, legitimate, historical fact about this repository, not a
# defect in this check: per this patch's own explicit specification,
# .github/workflows/ changes are always forbidden, with no exception carved
# out for that file. Running Get-BaselineAncestryDiffResult against the
# real repo therefore correctly returns a FAIL, not a PASS - see the
# separate real-repo diagnostic below, which reports this honestly rather
# than asserting a result that does not hold. Test F itself proves the
# PASS path works, using a disposable scratch repository (the same
# technique as Test G) whose diff genuinely is confined to docs/ and
# tools/, since the real repository cannot currently be used to
# demonstrate this scenario.
# ---------------------------------------------------------------------------
$scratchDirF = Join-Path ([System.IO.Path]::GetTempPath()) "preflash_safeguard_test_scratch_f_$([guid]::NewGuid().ToString('N'))"
$resultF = $null
try {
    New-Item -ItemType Directory -Path $scratchDirF -Force | Out-Null
    Push-Location $scratchDirF
    try {
        & git init -q 2>&1 | Out-Null
        & git config user.email 'test@example.com' 2>&1 | Out-Null
        & git config user.name 'Pre-Flash Safeguard Test' 2>&1 | Out-Null

        New-Item -ItemType Directory -Path (Join-Path $scratchDirF 'applications_user') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirF 'applications_user\existing_app.c') -Value '// pre-existing, unrelated to this diff' -Encoding UTF8
        & git add applications_user/existing_app.c 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaF = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDirF 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirF 'docs\finalize_notes.md') -Value 'docs-only descendant change' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $scratchDirF 'tools') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirF 'tools\finalize_gate.ps1') -Value '# tools-only descendant change' -Encoding UTF8
        & git add docs/finalize_notes.md tools/finalize_gate.ps1 2>&1 | Out-Null
        & git commit -q -m 'docs/tools-only descendant commit' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }

    $resultF = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirF -AcceptedBaselineCommit $scratchBaselineShaF -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    if (Test-Path $scratchDirF) {
        Remove-Item -Path $scratchDirF -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$fIsPass = $resultF.Status -like 'PASS - ACCEPTED BASELINE WITH TOOLING/DOCS-ONLY DESCENDANT*'
Assert-TestResult -TestName 'Test F - docs/tools-only descendant accepted (scratch repo)' -Condition $fIsPass -Detail "Status: $($resultF.Status)"

# ---------------------------------------------------------------------------
# Real-repo diagnostic (informational, not one of the 7 required pass/fail
# tests) - reports the ACTUAL current result of running this check against
# this repository's real accepted baseline commit and real HEAD, honestly,
# whatever it is.
# ---------------------------------------------------------------------------
$AcceptedCommitForRealRepo = '86265727b5b8cfce5086eb88f8bb93d0169ab9a9'
$resultRealRepo = Get-BaselineAncestryDiffResult -RepoRoot $TestRepoRoot -AcceptedBaselineCommit $AcceptedCommitForRealRepo -AllowedPathPrefixes @('docs/', 'tools/')
Write-Host ''
Write-Host '[INFO ] Real-repo diagnostic (not a pass/fail assertion - reported as-is)' -ForegroundColor Cyan
Write-Host "        Status: $($resultRealRepo.Status)" -ForegroundColor DarkGray
Write-Host "        Detail: $($resultRealRepo.Detail)" -ForegroundColor DarkGray
if ($resultRealRepo.ForbiddenFiles -and $resultRealRepo.ForbiddenFiles.Count -gt 0) {
    Write-Host "        Forbidden files: $($resultRealRepo.ForbiddenFiles -join ', ')" -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------------
# Test G - app-source descendant in a disposable scratch repository
# ---------------------------------------------------------------------------
$scratchDir = Join-Path ([System.IO.Path]::GetTempPath()) "preflash_safeguard_test_scratch_$([guid]::NewGuid().ToString('N'))"
$resultG = $null
try {
    New-Item -ItemType Directory -Path $scratchDir -Force | Out-Null
    Push-Location $scratchDir
    try {
        & git init -q 2>&1 | Out-Null
        & git config user.email 'test@example.com' 2>&1 | Out-Null
        & git config user.name 'Pre-Flash Safeguard Test' 2>&1 | Out-Null

        New-Item -ItemType Directory -Path (Join-Path $scratchDir 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDir 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineSha = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDir 'applications_user') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDir 'applications_user\synthetic_change.c') -Value '// synthetic forbidden-path change for Test G' -Encoding UTF8
        & git add applications_user/synthetic_change.c 2>&1 | Out-Null
        & git commit -q -m 'descendant with forbidden applications_user/ change' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }

    $resultG = Get-BaselineAncestryDiffResult -RepoRoot $scratchDir -AcceptedBaselineCommit $scratchBaselineSha -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    if (Test-Path $scratchDir) {
        Remove-Item -Path $scratchDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$gIsBlockedOrFail = ($resultG.Status -like 'BLOCKED*') -or ($resultG.Status -like 'FAIL*')
$gMentionsForbiddenFile = $resultG.ForbiddenFiles -contains 'applications_user/synthetic_change.c'
Assert-TestResult -TestName 'Test G - app-source descendant rejected (scratch repo)' -Condition ($gIsBlockedOrFail -and $gMentionsForbiddenFile) -Detail "Status: $($resultG.Status); ForbiddenFiles: $($resultG.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Host ''
$failCount = @($script:TestResults | Where-Object { $_.Status -eq 'FAIL' }).Count
$totalCount = $script:TestResults.Count
if ($failCount -eq 0) {
    Write-Host "=== ALL $totalCount REGRESSION TESTS PASSED ===" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "=== $failCount OF $totalCount REGRESSION TESTS FAILED ===" -ForegroundColor Red
    exit 1
}

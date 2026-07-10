<#
.SYNOPSIS
    Regression tests for tools/final_hardware_gate.ps1's device-identity
    evaluation logic - no real hardware, no real device, and no network
    access required.

.DESCRIPTION
    Dot-sources tools/final_hardware_gate.ps1 (which, when dot-sourced,
    loads only its function definitions and performs no hardware
    detection, no git operations, and no report generation - see the
    dot-source guard near the end of that file) and exercises the exact
    device-identity regression scenarios required by the Pre-Flash
    Safeguard Hardening phase:

    Test G - exact normal-mode Flipper identity (USB\VID_0483&PID_5740\...)
             is accepted by the normal-mode check.
    Test H - exact Flipper DFU identity (USB\VID_0483&PID_DF11\...) is
             accepted by the DFU/recovery check.
    Test I - an unrelated camera DFU device (VID_04F2&PID_B83E,
             FriendlyName "Camera DFU Device") is rejected (BLOCKED), never
             accepted.
    Test J - a generic DFU-sounding FriendlyName with an unrelated
             InstanceId is rejected (BLOCKED).
    Test K - the exact normal-mode Flipper identity, evaluated by the
             DFU-specific check, is rejected (BLOCKED) - it is not a DFU
             device.
    Test L - among multiple devices (camera DFU plus the exact Flipper
             DFU), only the exact entry determines a PASS.
    Test M - FriendlyName says "Flipper" but the InstanceId's USB IDs are
             wrong - rejected (BLOCKED). FriendlyName must never determine
             identity.

    This file performs no flashing, no device interaction, and no writes
    to this repository - it is entirely self-contained, synthetic-fixture
    based.

.EXAMPLE
    pwsh -NoProfile -File .\tools\final_hardware_gate.tests.ps1
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

# NOTE: final_hardware_gate.ps1 has its own [CmdletBinding()] param() block,
# including a -RepoRoot parameter. Dot-sourcing it re-runs that param block
# IN THIS SCRIPT'S SCOPE, binding -RepoRoot (default '') into any local
# variable of that same name - so this test script deliberately uses the
# differently-named $TestRepoRoot throughout to avoid that collision, and
# dot-sources only after computing $TestRepoRoot (the same fix pattern
# already used by tools/pre_flash_safeguard_gate.tests.ps1).
. (Join-Path $PSScriptRoot 'final_hardware_gate.ps1')

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
Write-Host '=== Final Hardware Gate - Device Identity Regression Tests ===' -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# Test G - exact normal-mode Flipper identity -> normal-mode PASS
# ---------------------------------------------------------------------------
$fixtureG = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$resultG = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureG))
Assert-TestResult -TestName 'Test G - exact normal-mode Flipper identity accepted' -Condition ($resultG.Status -like 'PASS*') -Detail "Status: $($resultG.Status)"

# ---------------------------------------------------------------------------
# Test H - exact Flipper DFU identity -> recovery PASS
# ---------------------------------------------------------------------------
$fixtureH = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$resultH = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureH))
Assert-TestResult -TestName 'Test H - exact Flipper DFU identity accepted (recovery PASS)' -Condition ($resultH.Status -like 'PASS*') -Detail "Status: $($resultH.Status)"

# ---------------------------------------------------------------------------
# Test I - unrelated camera DFU device -> BLOCKED
# ---------------------------------------------------------------------------
$fixtureI = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'
$resultI = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureI))
Assert-TestResult -TestName 'Test I - unrelated camera DFU device rejected' -Condition ($resultI.Status -like 'BLOCKED*' -and $resultI.Status -notlike 'PASS*') -Detail "Status: $($resultI.Status)"

# ---------------------------------------------------------------------------
# Test J - generic DFU-sounding name, unrelated InstanceId -> BLOCKED
# ---------------------------------------------------------------------------
$fixtureJ = New-DeviceFixture -InstanceId 'USB\VID_1234&PID_5678\SOMESERIAL01' -FriendlyName 'DFU in FS Mode'
$resultJ = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureJ))
Assert-TestResult -TestName 'Test J - generic DFU name with unrelated InstanceId rejected' -Condition ($resultJ.Status -like 'BLOCKED*') -Detail "Status: $($resultJ.Status)"

# ---------------------------------------------------------------------------
# Test K - normal-mode Flipper identity tested as DFU -> BLOCKED
# ---------------------------------------------------------------------------
$resultK = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureG))
Assert-TestResult -TestName 'Test K - normal-mode Flipper identity rejected by DFU check' -Condition ($resultK.Status -like 'BLOCKED*') -Detail "Status: $($resultK.Status)"

# ---------------------------------------------------------------------------
# Test L - camera DFU plus exact Flipper DFU -> PASS based only on the exact
# entry
# ---------------------------------------------------------------------------
$resultL = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureI, $fixtureH))
$lIsPass = $resultL.Status -like 'PASS*'
$lMentionsFlipperSerial = $resultL.Detail -like '*2059388C4831*'
Assert-TestResult -TestName 'Test L - camera DFU plus exact Flipper DFU, PASS on exact entry only' -Condition ($lIsPass -and $lMentionsFlipperSerial) -Detail "Status: $($resultL.Status); Detail mentions exact InstanceId: $lMentionsFlipperSerial"

# ---------------------------------------------------------------------------
# Test M - FriendlyName says "Flipper" but the USB IDs are wrong -> BLOCKED
# (FriendlyName must never determine identity)
# ---------------------------------------------------------------------------
$fixtureM = New-DeviceFixture -InstanceId 'USB\VID_9999&PID_0001\UNRELATEDSERIAL' -FriendlyName 'Flipper'
$resultMNormal = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureM))
$resultMDfu = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureM))
Assert-TestResult -TestName 'Test M - FriendlyName "Flipper" with wrong USB IDs rejected (normal-mode)' -Condition ($resultMNormal.Status -like 'BLOCKED*') -Detail "Status: $($resultMNormal.Status)"
Assert-TestResult -TestName 'Test M - FriendlyName "Flipper" with wrong USB IDs rejected (DFU check)' -Condition ($resultMDfu.Status -like 'BLOCKED*') -Detail "Status: $($resultMDfu.Status)"

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

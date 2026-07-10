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
    Ancestry Test A - docs/tools-only descendant (scratch repo) -> PASS.
    Ancestry Test B - docs/tools + the exact pinned finalization workflow
             file, hash matching -> PASS via the pinned-exception path.
    Ancestry Test C - the exact pinned workflow path present, but its
             content (and therefore its hash) altered after the pin was
             recorded -> FAIL, never silently accepted.
    Ancestry Test D - a different, non-pinned .github/workflows/ file
             changed -> FAIL (the exception is for exactly one named file,
             never the directory).
    Ancestry Test E - a disposable scratch git repository (created under
             the OS temp directory, entirely outside this repository, and
             deleted after the test) proves that a change under
             applications_user/ between the accepted baseline and HEAD is
             correctly rejected. This never touches this repository's own
             applications_user/.
    Ancestry Test F - the accepted baseline commit is not an ancestor of
             HEAD (two unrelated histories) -> FAIL/BLOCKED, never PASS.
    Real-repo assertion - this repository's own real accepted baseline
             commit and real HEAD are confirmed to classify as
             'PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS
             DESCENDANT AND PINNED FINALIZATION WORKFLOW', i.e. the
             pinned exception for
             .github/workflows/fcc-id-lookup-finalize-baseline.yml is
             exercised for real, not just diagnosed.

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

function New-ScratchGitRepo {
    param([string]$Prefix)
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) "preflash_safeguard_test_$Prefix`_$([guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Push-Location $dir
    try {
        & git init -q 2>&1 | Out-Null
        & git config user.email 'test@example.com' 2>&1 | Out-Null
        & git config user.name 'Pre-Flash Safeguard Test' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    return $dir
}

function Get-ScratchFileSha256 {
    param([string]$Path)
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

# ---------------------------------------------------------------------------
# Ancestry Test A - docs/tools-only descendant -> PASS
# ---------------------------------------------------------------------------
$scratchDirA = New-ScratchGitRepo -Prefix 'ancestry_a'
$resultAncestryA = $null
try {
    Push-Location $scratchDirA
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirA 'applications_user') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirA 'applications_user\existing_app.c') -Value '// pre-existing, unrelated to this diff' -Encoding UTF8
        & git add applications_user/existing_app.c 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaA = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDirA 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirA 'docs\finalize_notes.md') -Value 'docs-only descendant change' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $scratchDirA 'tools') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirA 'tools\finalize_gate.ps1') -Value '# tools-only descendant change' -Encoding UTF8
        & git add docs/finalize_notes.md tools/finalize_gate.ps1 2>&1 | Out-Null
        & git commit -q -m 'docs/tools-only descendant commit' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultAncestryA = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirA -AcceptedBaselineCommit $scratchBaselineShaA -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    if (Test-Path $scratchDirA) { Remove-Item -Path $scratchDirA -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryAIsPass = $resultAncestryA.Status -like 'PASS - ACCEPTED BASELINE WITH TOOLING/DOCS-ONLY DESCENDANT*'
Assert-TestResult -TestName 'Ancestry Test A - docs/tools-only descendant accepted (scratch repo)' -Condition $ancestryAIsPass -Detail "Status: $($resultAncestryA.Status)"

# ---------------------------------------------------------------------------
# Ancestry Test B - docs/tools + the exact pinned finalization workflow file,
# hash matching -> PASS via the pinned-exception path
# ---------------------------------------------------------------------------
$scratchDirB = New-ScratchGitRepo -Prefix 'ancestry_b'
$resultAncestryB = $null
try {
    Push-Location $scratchDirB
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirB 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirB 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaB = "$(& git rev-parse HEAD 2>&1)".Trim()

        Set-Content -Path (Join-Path $scratchDirB 'docs\baseline.md') -Value 'baseline plus docs update' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $scratchDirB 'tools') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirB 'tools\finalize_gate.ps1') -Value '# tools-only descendant change' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $scratchDirB '.github\workflows') -Force | Out-Null
        $pinnedWorkflowContentB = "name: finalize-baseline`non: workflow_dispatch`n"
        Set-Content -Path (Join-Path $scratchDirB '.github\workflows\finalize-baseline.yml') -Value $pinnedWorkflowContentB -Encoding UTF8 -NoNewline
        & git add docs/baseline.md tools/finalize_gate.ps1 .github/workflows/finalize-baseline.yml 2>&1 | Out-Null
        & git commit -q -m 'docs/tools plus pinned finalization workflow' 2>&1 | Out-Null

        $pinnedHashB = Get-ScratchFileSha256 -Path (Join-Path $scratchDirB '.github\workflows\finalize-baseline.yml')
    }
    finally {
        Pop-Location
    }
    $pinnedExceptionsB = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedSha256 = $pinnedHashB })
    $resultAncestryB = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirB -AcceptedBaselineCommit $scratchBaselineShaB -AllowedPathPrefixes @('docs/', 'tools/') -PinnedFileExceptions $pinnedExceptionsB
}
finally {
    if (Test-Path $scratchDirB) { Remove-Item -Path $scratchDirB -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryBIsPass = $resultAncestryB.Status -like 'PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND PINNED FINALIZATION WORKFLOW*'
Assert-TestResult -TestName 'Ancestry Test B - docs/tools + exact pinned workflow (matching hash) accepted' -Condition $ancestryBIsPass -Detail "Status: $($resultAncestryB.Status)"

# ---------------------------------------------------------------------------
# Ancestry Test C - exact pinned workflow path present, but content (and
# therefore hash) altered after the pin was recorded -> FAIL
# ---------------------------------------------------------------------------
$scratchDirC = New-ScratchGitRepo -Prefix 'ancestry_c'
$resultAncestryC = $null
try {
    Push-Location $scratchDirC
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirC 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirC 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaC = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDirC '.github\workflows') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirC '.github\workflows\finalize-baseline.yml') -Value 'name: finalize-baseline (ALTERED)' -Encoding UTF8 -NoNewline
        & git add .github/workflows/finalize-baseline.yml 2>&1 | Out-Null
        & git commit -q -m 'workflow content differs from the pinned hash' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    # Deliberately WRONG expected hash - simulates the pinned file's content
    # having changed since the hash was recorded.
    $pinnedExceptionsC = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedSha256 = ('0' * 64) })
    $resultAncestryC = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirC -AcceptedBaselineCommit $scratchBaselineShaC -AllowedPathPrefixes @('docs/', 'tools/') -PinnedFileExceptions $pinnedExceptionsC
}
finally {
    if (Test-Path $scratchDirC) { Remove-Item -Path $scratchDirC -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryCIsFail = $resultAncestryC.Status -like 'FAIL*'
$ancestryCMentionsFile = @($resultAncestryC.ForbiddenFiles | Where-Object { $_ -like '.github/workflows/finalize-baseline.yml*' }).Count -gt 0
Assert-TestResult -TestName 'Ancestry Test C - pinned workflow with altered content/hash rejected' -Condition ($ancestryCIsFail -and $ancestryCMentionsFile) -Detail "Status: $($resultAncestryC.Status); ForbiddenFiles: $($resultAncestryC.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Ancestry Test D - a different, non-pinned .github/workflows/ file changed
# -> FAIL (the exception is for exactly one named file, never the directory)
# ---------------------------------------------------------------------------
$scratchDirD = New-ScratchGitRepo -Prefix 'ancestry_d'
$resultAncestryD = $null
try {
    Push-Location $scratchDirD
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirD 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirD 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaD = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDirD '.github\workflows') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirD '.github\workflows\some-other-workflow.yml') -Value 'name: some-other-workflow' -Encoding UTF8
        & git add .github/workflows/some-other-workflow.yml 2>&1 | Out-Null
        & git commit -q -m 'unrelated workflow file added' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    # Pinned exception is for a DIFFERENT file name - must not cover this one.
    $pinnedExceptionsD = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedSha256 = ('0' * 64) })
    $resultAncestryD = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirD -AcceptedBaselineCommit $scratchBaselineShaD -AllowedPathPrefixes @('docs/', 'tools/') -PinnedFileExceptions $pinnedExceptionsD
}
finally {
    if (Test-Path $scratchDirD) { Remove-Item -Path $scratchDirD -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryDIsFail = $resultAncestryD.Status -like 'FAIL*'
$ancestryDMentionsFile = $resultAncestryD.ForbiddenFiles -contains '.github/workflows/some-other-workflow.yml'
Assert-TestResult -TestName 'Ancestry Test D - different non-pinned workflow file rejected' -Condition ($ancestryDIsFail -and $ancestryDMentionsFile) -Detail "Status: $($resultAncestryD.Status); ForbiddenFiles: $($resultAncestryD.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Ancestry Test E - app-source descendant in a disposable scratch repository
# -> FAIL
# ---------------------------------------------------------------------------
$scratchDirE = New-ScratchGitRepo -Prefix 'ancestry_e'
$resultAncestryE = $null
try {
    Push-Location $scratchDirE
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirE 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirE 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaE = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $scratchDirE 'applications_user') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirE 'applications_user\synthetic_change.c') -Value '// synthetic forbidden-path change for Ancestry Test E' -Encoding UTF8
        & git add applications_user/synthetic_change.c 2>&1 | Out-Null
        & git commit -q -m 'descendant with forbidden applications_user/ change' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultAncestryE = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirE -AcceptedBaselineCommit $scratchBaselineShaE -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    if (Test-Path $scratchDirE) { Remove-Item -Path $scratchDirE -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryEIsBlockedOrFail = ($resultAncestryE.Status -like 'BLOCKED*') -or ($resultAncestryE.Status -like 'FAIL*')
$ancestryEMentionsForbiddenFile = $resultAncestryE.ForbiddenFiles -contains 'applications_user/synthetic_change.c'
Assert-TestResult -TestName 'Ancestry Test E - app-source descendant rejected (scratch repo)' -Condition ($ancestryEIsBlockedOrFail -and $ancestryEMentionsForbiddenFile) -Detail "Status: $($resultAncestryE.Status); ForbiddenFiles: $($resultAncestryE.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Ancestry Test F - accepted baseline commit is NOT an ancestor of HEAD
# (two unrelated histories) -> FAIL/BLOCKED, never PASS
# ---------------------------------------------------------------------------
$scratchDirF = New-ScratchGitRepo -Prefix 'ancestry_f'
$resultAncestryF = $null
try {
    Push-Location $scratchDirF
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchDirF 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirF 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'unrelated baseline commit' 2>&1 | Out-Null
        $scratchUnrelatedBaselineSha = "$(& git rev-parse HEAD 2>&1)".Trim()

        & git checkout -q --orphan other-history 2>&1 | Out-Null
        & git rm -rf -q . 2>&1 | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $scratchDirF 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchDirF 'docs\unrelated.md') -Value 'a completely separate history' -Encoding UTF8
        & git add docs/unrelated.md 2>&1 | Out-Null
        & git commit -q -m 'root commit of an unrelated history' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultAncestryF = Get-BaselineAncestryDiffResult -RepoRoot $scratchDirF -AcceptedBaselineCommit $scratchUnrelatedBaselineSha -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    if (Test-Path $scratchDirF) { Remove-Item -Path $scratchDirF -Recurse -Force -ErrorAction SilentlyContinue }
}
$ancestryFIsBlockedOrFail = ($resultAncestryF.Status -like 'BLOCKED*') -or ($resultAncestryF.Status -like 'FAIL*')
$ancestryFNeverPass = $resultAncestryF.Status -notlike 'PASS*'
Assert-TestResult -TestName 'Ancestry Test F - baseline not an ancestor of HEAD rejected' -Condition ($ancestryFIsBlockedOrFail -and $ancestryFNeverPass) -Detail "Status: $($resultAncestryF.Status)"

# ---------------------------------------------------------------------------
# Real-repo assertion - this repository's own real accepted baseline commit
# and real HEAD must classify as PASS via the pinned finalization-workflow
# exception (not a diagnostic - this is now a required, asserted result).
# ---------------------------------------------------------------------------
$resultRealRepo = Get-BaselineAncestryDiffResult -RepoRoot $TestRepoRoot -AcceptedBaselineCommit $AcceptedCommit -AllowedPathPrefixes $AllowedPostBaselinePathPrefixes -PinnedFileExceptions $PinnedWorkflowExceptions
$realRepoIsPass = $resultRealRepo.Status -like 'PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND PINNED FINALIZATION WORKFLOW*'
Assert-TestResult -TestName 'Real-repo - current HEAD passes only through the pinned finalization-workflow exception' -Condition $realRepoIsPass -Detail "Status: $($resultRealRepo.Status)"

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

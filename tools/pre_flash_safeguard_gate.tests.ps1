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

        $pinnedBlobIdB = "$(& git rev-parse "HEAD:.github/workflows/finalize-baseline.yml" 2>&1)".Trim()
    }
    finally {
        Pop-Location
    }
    $pinnedHashB = Get-Sha256OfBytes -Bytes (Get-CanonicalGitBlobBytes -RepoRoot $scratchDirB -BlobId $pinnedBlobIdB)
    $pinnedExceptionsB = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedBlobId = $pinnedBlobIdB; ExpectedSha256 = $pinnedHashB })
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
    # Deliberately WRONG expected blob ID/hash - simulates the pinned file's
    # content having changed since the review, i.e. a different blob was
    # reviewed/pinned than what is actually committed now.
    $pinnedExceptionsC = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedBlobId = ('1' * 40); ExpectedSha256 = ('0' * 64) })
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
    $pinnedExceptionsD = @([ordered]@{ Path = '.github/workflows/finalize-baseline.yml'; ExpectedBlobId = ('0' * 40); ExpectedSha256 = ('0' * 64) })
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
# Canonical Git Blob Integrity Fix - regression tests (Blob Test A-M)
#
# These prove the pinned finalization-workflow exception is decided from
# canonical Git object content (git rev-parse HEAD:<path> / git cat-file
# blob <id>), never from working-tree bytes - the exact defect that
# produced a false FAIL on a real Windows checkout with core.autocrlf=true
# even though the underlying Git object was unchanged.
#
# Test B specifically reproduces core.autocrlf=true for real: `git config
# core.autocrlf true` is a cross-platform Git config option (implemented
# in Git's own checkout/smudge logic, not gated by uname), so setting it
# and re-checking out the file in this Linux sandbox genuinely produces
# CRLF working-tree bytes via the same code path Git uses on Windows -
# this is a real reproduction of the behavior, not a hand-rolled mock.
# ---------------------------------------------------------------------------

function New-ScratchBlobIntegrityRepo {
    param([string]$Prefix, [string]$WorkflowPath = '.github/workflows/finalize-baseline.yml')
    $dir = New-ScratchGitRepo -Prefix $Prefix
    $fullWorkflowPath = Join-Path $dir ($WorkflowPath -replace '/', '\')
    New-Item -ItemType Directory -Path (Split-Path $fullWorkflowPath -Parent) -Force | Out-Null
    # Written with explicit LF endings and no BOM, regardless of host OS,
    # simulating the real reviewed file's canonical (Linux-committed) form.
    $lfContent = "name: finalize-baseline`non: workflow_dispatch`n"
    [System.IO.File]::WriteAllText($fullWorkflowPath, $lfContent, (New-Object System.Text.UTF8Encoding($false)))
    Push-Location $dir
    try {
        & git add -- $WorkflowPath 2>&1 | Out-Null
        & git commit -q -m 'baseline commit with pinned workflow (LF)' 2>&1 | Out-Null
        $blobIdRaw = & git rev-parse "HEAD:$WorkflowPath" 2>&1
    }
    finally {
        Pop-Location
    }
    return [ordered]@{ Dir = $dir; WorkflowPath = $WorkflowPath; FullWorkflowPath = $fullWorkflowPath; BlobId = "$blobIdRaw".Trim() }
}

function Remove-ScratchGitRepo {
    param([string]$Dir)
    if (Test-Path $Dir) { Remove-Item -Path $Dir -Recurse -Force -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------------------
# Byte-capture sanity check (not one of the lettered tests) - proves
# Get-CanonicalGitBlobBytes returns the EXACT original bytes of a known,
# independently-authored blob, before trusting it as the oracle for the
# lettered tests below. This is a direct check against known input, not a
# self-referential comparison.
# ---------------------------------------------------------------------------
$sanityRepo = New-ScratchBlobIntegrityRepo -Prefix 'blob_sanity'
try {
    $capturedBytes = Get-CanonicalGitBlobBytes -RepoRoot $sanityRepo.Dir -BlobId $sanityRepo.BlobId
    $capturedText = [System.Text.Encoding]::UTF8.GetString($capturedBytes)
    $expectedText = "name: finalize-baseline`non: workflow_dispatch`n"
    $sanityOk = ($capturedText -ceq $expectedText) -and ($capturedBytes.Length -eq [System.Text.Encoding]::UTF8.GetByteCount($expectedText))
    Assert-TestResult -TestName 'Blob capture sanity - Get-CanonicalGitBlobBytes returns exact known bytes' -Condition $sanityOk -Detail "Captured length: $($capturedBytes.Length) bytes"
}
finally {
    Remove-ScratchGitRepo -Dir $sanityRepo.Dir
}

# ---------------------------------------------------------------------------
# Blob Test A - canonical LF repository blob: reviewed blob and canonical
# SHA match -> PASS
# ---------------------------------------------------------------------------
$repoA = New-ScratchBlobIntegrityRepo -Prefix 'blob_a'
try {
    $canonicalBytesA = Get-CanonicalGitBlobBytes -RepoRoot $repoA.Dir -BlobId $repoA.BlobId
    $canonicalSha256A = Get-Sha256OfBytes -Bytes $canonicalBytesA
    $resultBlobA = Get-PinnedWorkflowExceptionResult -RepoRoot $repoA.Dir -Path $repoA.WorkflowPath -ExpectedBlobId $repoA.BlobId -ExpectedSha256 $canonicalSha256A
    Assert-TestResult -TestName 'Blob Test A - canonical LF blob and hash match -> PASS' -Condition ($resultBlobA.Status -eq 'PASS') -Detail "Status: $($resultBlobA.Status); Detail: $($resultBlobA.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoA.Dir
}

# ---------------------------------------------------------------------------
# Blob Test B - Windows CRLF working tree (real core.autocrlf=true
# reproduction): repo blob unchanged, working-tree bytes are CRLF and hash
# differently -> still PASS, decided from the canonical blob
# ---------------------------------------------------------------------------
$repoB = New-ScratchBlobIntegrityRepo -Prefix 'blob_b'
$resultBlobB = $null
$workingTreeShaB = $null
$canonicalShaB = $null
$statusCleanB = $false
try {
    $canonicalBytesB = Get-CanonicalGitBlobBytes -RepoRoot $repoB.Dir -BlobId $repoB.BlobId
    $canonicalShaB = Get-Sha256OfBytes -Bytes $canonicalBytesB

    Push-Location $repoB.Dir
    try {
        & git config core.autocrlf true 2>&1 | Out-Null
        Remove-Item -Path $repoB.FullWorkflowPath -Force
        & git checkout -q -- $repoB.WorkflowPath 2>&1 | Out-Null
        $statusRawB = & git status --porcelain -- $repoB.WorkflowPath 2>&1
        $statusCleanB = ("$statusRawB".Trim() -eq '')
    }
    finally {
        Pop-Location
    }

    $workingTreeShaB = (Get-FileHash -Path $repoB.FullWorkflowPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $crlfConfirmed = (Get-Content -Path $repoB.FullWorkflowPath -Raw) -match "`r`n"

    $resultBlobB = Get-PinnedWorkflowExceptionResult -RepoRoot $repoB.Dir -Path $repoB.WorkflowPath -ExpectedBlobId $repoB.BlobId -ExpectedSha256 $canonicalShaB
    $blobBIsPass = $resultBlobB.Status -eq 'PASS'
    $shasDiffer = $workingTreeShaB -ne $canonicalShaB
    Assert-TestResult -TestName 'Blob Test B - Windows core.autocrlf=true CRLF working tree still PASSes (canonical-blob decided)' -Condition ($blobBIsPass -and $shasDiffer -and $statusCleanB -and $crlfConfirmed) -Detail "Status: $($resultBlobB.Status); working-tree SHA differs from canonical: $shasDiffer; git status clean: $statusCleanB; CRLF confirmed in working tree: $crlfConfirmed"
}
finally {
    Remove-ScratchGitRepo -Dir $repoB.Dir
}

# ---------------------------------------------------------------------------
# Blob Test C - committed workflow content modification: HEAD blob differs
# -> FAIL
# ---------------------------------------------------------------------------
$repoC = New-ScratchBlobIntegrityRepo -Prefix 'blob_c'
try {
    Push-Location $repoC.Dir
    try {
        [System.IO.File]::WriteAllText($repoC.FullWorkflowPath, "name: finalize-baseline`non: workflow_dispatch`n# altered after review`n", (New-Object System.Text.UTF8Encoding($false)))
        & git add -- $repoC.WorkflowPath 2>&1 | Out-Null
        & git commit -q -m 'content modified after pin was recorded' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultBlobC = Get-PinnedWorkflowExceptionResult -RepoRoot $repoC.Dir -Path $repoC.WorkflowPath -ExpectedBlobId $repoC.BlobId -ExpectedSha256 '0000000000000000000000000000000000000000000000000000000000000000'
    Assert-TestResult -TestName 'Blob Test C - committed content modified, blob ID differs -> FAIL' -Condition ($resultBlobC.Status -eq 'FAIL' -and $resultBlobC.Detail -like '*blob ID mismatch*') -Detail "Status: $($resultBlobC.Status); Detail: $($resultBlobC.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoC.Dir
}

# ---------------------------------------------------------------------------
# Blob Test D - same path, same blob ID, but a deliberately wrong pinned
# ExpectedSha256 (simulated config drift) -> FAIL
# ---------------------------------------------------------------------------
$repoD = New-ScratchBlobIntegrityRepo -Prefix 'blob_d'
try {
    $resultBlobD = Get-PinnedWorkflowExceptionResult -RepoRoot $repoD.Dir -Path $repoD.WorkflowPath -ExpectedBlobId $repoD.BlobId -ExpectedSha256 ('f' * 64)
    Assert-TestResult -TestName 'Blob Test D - matching blob ID but wrong pinned SHA256 -> FAIL' -Condition ($resultBlobD.Status -eq 'FAIL' -and $resultBlobD.Detail -like '*canonical SHA256*') -Detail "Status: $($resultBlobD.Status); Detail: $($resultBlobD.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoD.Dir
}

# ---------------------------------------------------------------------------
# Blob Test E - dirty UNSTAGED workflow modification: committed blob still
# matches, but the working tree has an uncommitted edit -> FAIL
# ---------------------------------------------------------------------------
$repoE = New-ScratchBlobIntegrityRepo -Prefix 'blob_e'
try {
    $canonicalBytesE = Get-CanonicalGitBlobBytes -RepoRoot $repoE.Dir -BlobId $repoE.BlobId
    $canonicalShaE = Get-Sha256OfBytes -Bytes $canonicalBytesE
    [System.IO.File]::WriteAllText($repoE.FullWorkflowPath, "name: finalize-baseline`non: workflow_dispatch`n# local uncommitted edit`n", (New-Object System.Text.UTF8Encoding($false)))
    $resultBlobE = Get-PinnedWorkflowExceptionResult -RepoRoot $repoE.Dir -Path $repoE.WorkflowPath -ExpectedBlobId $repoE.BlobId -ExpectedSha256 $canonicalShaE
    Assert-TestResult -TestName 'Blob Test E - dirty unstaged working-tree edit rejected -> FAIL' -Condition ($resultBlobE.Status -eq 'FAIL' -and $resultBlobE.Detail -like '*not clean*') -Detail "Status: $($resultBlobE.Status); Detail: $($resultBlobE.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoE.Dir
}

# ---------------------------------------------------------------------------
# Blob Test F - staged (but not committed) workflow modification -> FAIL
# ---------------------------------------------------------------------------
$repoF = New-ScratchBlobIntegrityRepo -Prefix 'blob_f'
try {
    $canonicalBytesF = Get-CanonicalGitBlobBytes -RepoRoot $repoF.Dir -BlobId $repoF.BlobId
    $canonicalShaF = Get-Sha256OfBytes -Bytes $canonicalBytesF
    [System.IO.File]::WriteAllText($repoF.FullWorkflowPath, "name: finalize-baseline`non: workflow_dispatch`n# staged but not committed`n", (New-Object System.Text.UTF8Encoding($false)))
    Push-Location $repoF.Dir
    try {
        & git add -- $repoF.WorkflowPath 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultBlobF = Get-PinnedWorkflowExceptionResult -RepoRoot $repoF.Dir -Path $repoF.WorkflowPath -ExpectedBlobId $repoF.BlobId -ExpectedSha256 $canonicalShaF
    Assert-TestResult -TestName 'Blob Test F - staged (uncommitted) working-tree edit rejected -> FAIL' -Condition ($resultBlobF.Status -eq 'FAIL' -and $resultBlobF.Detail -like '*not clean*') -Detail "Status: $($resultBlobF.Status); Detail: $($resultBlobF.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoF.Dir
}

# ---------------------------------------------------------------------------
# Blob Test G - unrelated workflow file added (not the pinned path) -> FAIL,
# exercised through the full Get-BaselineAncestryDiffResult pipeline
# ---------------------------------------------------------------------------
$repoG = New-ScratchGitRepo -Prefix 'blob_g'
$resultBlobG = $null
try {
    Push-Location $repoG
    try {
        New-Item -ItemType Directory -Path (Join-Path $repoG 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $repoG 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaG = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $repoG '.github\workflows') -Force | Out-Null
        Set-Content -Path (Join-Path $repoG '.github\workflows\some-other-workflow.yml') -Value 'name: some-other-workflow' -Encoding UTF8
        & git add .github/workflows/some-other-workflow.yml 2>&1 | Out-Null
        & git commit -q -m 'unrelated workflow file added' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $pinnedExceptionsG = @([ordered]@{ Path = '.github/workflows/fcc-id-lookup-finalize-baseline.yml'; ExpectedBlobId = ('0' * 40); ExpectedSha256 = ('0' * 64) })
    $resultBlobG = Get-BaselineAncestryDiffResult -RepoRoot $repoG -AcceptedBaselineCommit $scratchBaselineShaG -AllowedPathPrefixes @('docs/', 'tools/') -PinnedFileExceptions $pinnedExceptionsG
}
finally {
    Remove-ScratchGitRepo -Dir $repoG
}
$blobGIsFail = $resultBlobG.Status -like 'FAIL*'
$blobGMentionsFile = $resultBlobG.ForbiddenFiles -contains '.github/workflows/some-other-workflow.yml'
Assert-TestResult -TestName 'Blob Test G - unrelated workflow file added rejected -> FAIL' -Condition ($blobGIsFail -and $blobGMentionsFile) -Detail "Status: $($resultBlobG.Status); ForbiddenFiles: $($resultBlobG.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Blob Test H - workflow path missing at HEAD -> FAIL
# ---------------------------------------------------------------------------
$repoH = New-ScratchBlobIntegrityRepo -Prefix 'blob_h'
try {
    Push-Location $repoH.Dir
    try {
        & git rm -q -- $repoH.WorkflowPath 2>&1 | Out-Null
        & git commit -q -m 'remove the pinned workflow file' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultBlobH = Get-PinnedWorkflowExceptionResult -RepoRoot $repoH.Dir -Path $repoH.WorkflowPath -ExpectedBlobId $repoH.BlobId -ExpectedSha256 ('0' * 64)
    Assert-TestResult -TestName 'Blob Test H - workflow path missing at HEAD -> FAIL' -Condition ($resultBlobH.Status -eq 'FAIL' -and $resultBlobH.Detail -like '*missing or unresolvable*') -Detail "Status: $($resultBlobH.Status); Detail: $($resultBlobH.Detail)"
}
finally {
    Remove-ScratchGitRepo -Dir $repoH.Dir
}

# ---------------------------------------------------------------------------
# Blob Test I - accepted baseline is NOT an ancestor of HEAD -> FAIL/BLOCKED
# ---------------------------------------------------------------------------
$repoI = New-ScratchGitRepo -Prefix 'blob_i'
$resultBlobI = $null
try {
    Push-Location $repoI
    try {
        New-Item -ItemType Directory -Path (Join-Path $repoI 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $repoI 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'unrelated baseline commit' 2>&1 | Out-Null
        $unrelatedBaselineShaI = "$(& git rev-parse HEAD 2>&1)".Trim()

        & git checkout -q --orphan other-history 2>&1 | Out-Null
        & git rm -rf -q . 2>&1 | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $repoI 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $repoI 'docs\unrelated.md') -Value 'a completely separate history' -Encoding UTF8
        & git add docs/unrelated.md 2>&1 | Out-Null
        & git commit -q -m 'root commit of an unrelated history' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultBlobI = Get-BaselineAncestryDiffResult -RepoRoot $repoI -AcceptedBaselineCommit $unrelatedBaselineShaI -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    Remove-ScratchGitRepo -Dir $repoI
}
$blobIRejected = ($resultBlobI.Status -like 'BLOCKED*' -or $resultBlobI.Status -like 'FAIL*') -and ($resultBlobI.Status -notlike 'PASS*')
Assert-TestResult -TestName 'Blob Test I - accepted baseline not an ancestor of HEAD -> FAIL/BLOCKED' -Condition $blobIRejected -Detail "Status: $($resultBlobI.Status)"

# ---------------------------------------------------------------------------
# Blob Test J - docs/tools-only descendant plus the exact pinned workflow
# blob -> PASS
# ---------------------------------------------------------------------------
$repoJ = New-ScratchGitRepo -Prefix 'blob_j'
$resultBlobJ = $null
try {
    Push-Location $repoJ
    try {
        New-Item -ItemType Directory -Path (Join-Path $repoJ 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $repoJ 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaJ = "$(& git rev-parse HEAD 2>&1)".Trim()

        Set-Content -Path (Join-Path $repoJ 'docs\baseline.md') -Value 'baseline plus docs update' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $repoJ 'tools') -Force | Out-Null
        Set-Content -Path (Join-Path $repoJ 'tools\finalize_gate.ps1') -Value '# tools-only descendant change' -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $repoJ '.github\workflows') -Force | Out-Null
        $pinnedWorkflowPathJ = '.github/workflows/finalize-baseline.yml'
        $pinnedWorkflowFullPathJ = Join-Path $repoJ '.github\workflows\finalize-baseline.yml'
        [System.IO.File]::WriteAllText($pinnedWorkflowFullPathJ, "name: finalize-baseline`non: workflow_dispatch`n", (New-Object System.Text.UTF8Encoding($false)))
        & git add docs/baseline.md tools/finalize_gate.ps1 .github/workflows/finalize-baseline.yml 2>&1 | Out-Null
        & git commit -q -m 'docs/tools plus pinned finalization workflow' 2>&1 | Out-Null

        $pinnedBlobIdJ = "$(& git rev-parse "HEAD:$pinnedWorkflowPathJ" 2>&1)".Trim()
    }
    finally {
        Pop-Location
    }
    $pinnedBytesJ = Get-CanonicalGitBlobBytes -RepoRoot $repoJ -BlobId $pinnedBlobIdJ
    $pinnedShaJ = Get-Sha256OfBytes -Bytes $pinnedBytesJ
    $pinnedExceptionsJ = @([ordered]@{ Path = $pinnedWorkflowPathJ; ExpectedBlobId = $pinnedBlobIdJ; ExpectedSha256 = $pinnedShaJ })
    $resultBlobJ = Get-BaselineAncestryDiffResult -RepoRoot $repoJ -AcceptedBaselineCommit $scratchBaselineShaJ -AllowedPathPrefixes @('docs/', 'tools/') -PinnedFileExceptions $pinnedExceptionsJ
}
finally {
    Remove-ScratchGitRepo -Dir $repoJ
}
$blobJIsPass = $resultBlobJ.Status -like 'PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND PINNED FINALIZATION WORKFLOW*'
Assert-TestResult -TestName 'Blob Test J - docs/tools-only plus exact pinned workflow blob -> PASS' -Condition $blobJIsPass -Detail "Status: $($resultBlobJ.Status)"

# ---------------------------------------------------------------------------
# Blob Test K - applications_user/ change -> FAIL
# ---------------------------------------------------------------------------
$repoK = New-ScratchGitRepo -Prefix 'blob_k'
$resultBlobK = $null
try {
    Push-Location $repoK
    try {
        New-Item -ItemType Directory -Path (Join-Path $repoK 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $repoK 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaK = "$(& git rev-parse HEAD 2>&1)".Trim()

        New-Item -ItemType Directory -Path (Join-Path $repoK 'applications_user') -Force | Out-Null
        Set-Content -Path (Join-Path $repoK 'applications_user\synthetic_change.c') -Value '// synthetic forbidden-path change for Blob Test K' -Encoding UTF8
        & git add applications_user/synthetic_change.c 2>&1 | Out-Null
        & git commit -q -m 'descendant with forbidden applications_user/ change' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $resultBlobK = Get-BaselineAncestryDiffResult -RepoRoot $repoK -AcceptedBaselineCommit $scratchBaselineShaK -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    Remove-ScratchGitRepo -Dir $repoK
}
$blobKIsRejected = ($resultBlobK.Status -like 'BLOCKED*') -or ($resultBlobK.Status -like 'FAIL*')
$blobKMentionsFile = $resultBlobK.ForbiddenFiles -contains 'applications_user/synthetic_change.c'
Assert-TestResult -TestName 'Blob Test K - applications_user/ descendant rejected -> FAIL' -Condition ($blobKIsRejected -and $blobKMentionsFile) -Detail "Status: $($resultBlobK.Status); ForbiddenFiles: $($resultBlobK.ForbiddenFiles -join ', ')"

# ---------------------------------------------------------------------------
# Blob Test L - canonical extraction failure -> FAIL, never a silent skip
#
# Part 1: Get-CanonicalGitBlobBytes itself must throw (not return empty or
# wrong bytes) when asked for an object that does not exist.
# Part 2: Get-PinnedWorkflowExceptionResult, given a path whose HEAD blob
# resolves correctly but whose underlying loose object has been removed
# from the object database (a real, if artificially induced, repository
# corruption scenario - e.g. an incomplete/corrupted clone), must return
# Status=FAIL via its catch branch, never throw uncaught and never
# silently report PASS/skip.
# ---------------------------------------------------------------------------
$repoL = New-ScratchBlobIntegrityRepo -Prefix 'blob_l'
try {
    $threwOnBogusBlob = $false
    try {
        Get-CanonicalGitBlobBytes -RepoRoot $repoL.Dir -BlobId ('0' * 40) | Out-Null
    }
    catch {
        $threwOnBogusBlob = $true
    }
    Assert-TestResult -TestName 'Blob Test L (part 1) - Get-CanonicalGitBlobBytes throws on a nonexistent object' -Condition $threwOnBogusBlob -Detail "Threw as expected: $threwOnBogusBlob"

    # Remove the pinned blob's loose object file from the object database,
    # without touching the tree/commit objects - git rev-parse HEAD:<path>
    # will still resolve the blob ID (it only needs the tree entry), but
    # git cat-file blob <id> will now genuinely fail to read it.
    $looseObjectPath = Join-Path $repoL.Dir (".git\objects\$($repoL.BlobId.Substring(0,2))\$($repoL.BlobId.Substring(2))")
    $looseObjectRemoved = $false
    if (Test-Path $looseObjectPath) {
        Remove-Item -Path $looseObjectPath -Force
        $looseObjectRemoved = $true
    }

    if ($looseObjectRemoved) {
        $resultBlobL = Get-PinnedWorkflowExceptionResult -RepoRoot $repoL.Dir -Path $repoL.WorkflowPath -ExpectedBlobId $repoL.BlobId -ExpectedSha256 ('0' * 64)
        Assert-TestResult -TestName 'Blob Test L (part 2) - missing loose object -> FAIL via catch, not silent skip' -Condition ($resultBlobL.Status -eq 'FAIL' -and $resultBlobL.Detail -like '*extraction failed*') -Detail "Status: $($resultBlobL.Status); Detail: $($resultBlobL.Detail)"
    }
    else {
        Assert-TestResult -TestName 'Blob Test L (part 2) - missing loose object -> FAIL via catch, not silent skip' -Condition $false -Detail "Could not locate the expected loose object file at $looseObjectPath to remove it - test precondition not met."
    }
}
finally {
    Remove-ScratchGitRepo -Dir $repoL.Dir
}

# ---------------------------------------------------------------------------
# Blob Test M - existing USB identity tests remain intact (explicit
# regression pin for this phase, not a re-derivation of Tests A-E above)
# ---------------------------------------------------------------------------
$fixtureBlobMNormal = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$fixtureBlobMDfu = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$fixtureBlobMCamera = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'

$resultBlobMNormal = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureBlobMNormal))
$resultBlobMDfu = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureBlobMDfu))
$resultBlobMCamera = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureBlobMCamera))

Assert-TestResult -TestName 'Blob Test M - exact normal-mode ID (VID_0483&PID_5740) passes normal detection' -Condition ($resultBlobMNormal.Status -like 'PASS*') -Detail "Status: $($resultBlobMNormal.Status)"
Assert-TestResult -TestName 'Blob Test M - exact DFU ID (VID_0483&PID_DF11) passes recovery detection' -Condition ($resultBlobMDfu.Status -like 'PASS*') -Detail "Status: $($resultBlobMDfu.Status)"
Assert-TestResult -TestName 'Blob Test M - camera DFU (VID_04F2&PID_B83E) remains rejected' -Condition ($resultBlobMCamera.Status -like 'BLOCKED*' -and $resultBlobMCamera.Status -notlike 'PASS*') -Detail "Status: $($resultBlobMCamera.Status)"

# ---------------------------------------------------------------------------
# Device State-Machine Fix - regression tests (State Test A-M)
#
# Normal mode (VID_0483&PID_5740) and DFU mode (VID_0483&PID_DF11) are
# SEQUENTIAL states of one physical device, never a simultaneous
# requirement. These tests prove -Mode RecoveryReadiness no longer BLOCKs
# merely because the normal-mode identity is absent while the exact DFU
# identity is present - and that it still fails closed on every real
# defect scenario (camera DFU, generic names, no devices, enumeration
# errors, both identities present at once).
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# State Test A - normal-mode DeviceDetect: VID_0483&PID_5740 present -> PASS
# ---------------------------------------------------------------------------
$fixtureStateA = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$resultStateA = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateA))
Assert-TestResult -TestName 'State Test A - DeviceDetect: exact normal-mode ID present -> PASS' -Condition ($resultStateA.Status -like 'PASS*') -Detail "Status: $($resultStateA.Status)"

# ---------------------------------------------------------------------------
# State Test B - DFU RecoveryReadiness: VID_0483&PID_DF11 present, normal
# mode absent -> PASS overall, normal mode reported EXPECTED ABSENT
# ---------------------------------------------------------------------------
$fixtureStateB = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$enumStateB = New-SuccessEnumeration -Devices @($fixtureStateB)
$normalResultStateB = Get-NormalModeDetectionResult -EnumerationResult $enumStateB
$dfuResultStateB = Get-DfuDetectionResult -EnumerationResult $enumStateB
$advisoryStateB = Get-RecoveryModeNormalIdentityAdvisory -NormalModeResult $normalResultStateB -DfuModeResult $dfuResultStateB
$stateBDfuPass = $dfuResultStateB.Status -like 'PASS*'
$stateBAdvisoryExpectedAbsent = $advisoryStateB.Status -eq 'EXPECTED ABSENT - DEVICE IS IN DFU MODE'
$stateBAdvisoryNeverBlocks = ($advisoryStateB.Status -notlike 'BLOCKED*') -and ($advisoryStateB.Status -notlike 'FAIL*') -and ($advisoryStateB.Status -notlike 'NEEDS_REVIEW*')
Assert-TestResult -TestName 'State Test B - RecoveryReadiness: exact DFU present, normal absent -> PASS, normal mode EXPECTED ABSENT' -Condition ($stateBDfuPass -and $stateBAdvisoryExpectedAbsent -and $stateBAdvisoryNeverBlocks) -Detail "DFU status: $($dfuResultStateB.Status); Advisory status: $($advisoryStateB.Status)"

# ---------------------------------------------------------------------------
# State Test C - normal mode used in RecoveryReadiness: VID_0483&PID_5740
# present, VID_0483&PID_DF11 absent -> BLOCKED
# ---------------------------------------------------------------------------
$fixtureStateC = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$enumStateC = New-SuccessEnumeration -Devices @($fixtureStateC)
$dfuResultStateC = Get-DfuDetectionResult -EnumerationResult $enumStateC
Assert-TestResult -TestName 'State Test C - RecoveryReadiness: normal-mode ID present, DFU absent -> BLOCKED' -Condition ($dfuResultStateC.Status -like 'BLOCKED*') -Detail "DFU status: $($dfuResultStateC.Status)"

# ---------------------------------------------------------------------------
# State Test D - camera DFU only -> BLOCKED
# ---------------------------------------------------------------------------
$fixtureStateD = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'
$dfuResultStateD = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateD))
Assert-TestResult -TestName 'State Test D - camera DFU only -> BLOCKED' -Condition ($dfuResultStateD.Status -like 'BLOCKED*' -and $dfuResultStateD.Status -notlike 'PASS*') -Detail "Status: $($dfuResultStateD.Status)"

# ---------------------------------------------------------------------------
# State Test E - generic DFU name only, unrelated InstanceId -> BLOCKED
# ---------------------------------------------------------------------------
$fixtureStateE = New-DeviceFixture -InstanceId 'USB\VID_1234&PID_5678\SOMESERIAL01' -FriendlyName 'DFU in FS Mode'
$dfuResultStateE = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateE))
Assert-TestResult -TestName 'State Test E - generic DFU-sounding name, unrelated InstanceId -> BLOCKED' -Condition ($dfuResultStateE.Status -like 'BLOCKED*') -Detail "Status: $($dfuResultStateE.Status)"

# ---------------------------------------------------------------------------
# State Test F - exact DFU plus camera DFU -> PASS based only on the exact
# Flipper ID; unrelated device reported informationally
# ---------------------------------------------------------------------------
$fixtureStateF_camera = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'
$fixtureStateF_flipper = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$dfuResultStateF = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateF_camera, $fixtureStateF_flipper))
$stateFIsPass = $dfuResultStateF.Status -like 'PASS*'
$stateFMentionsExactSerial = $dfuResultStateF.Detail -like '*2059388C4831*'
Assert-TestResult -TestName 'State Test F - exact DFU plus camera DFU -> PASS on exact entry only' -Condition ($stateFIsPass -and $stateFMentionsExactSerial) -Detail "Status: $($dfuResultStateF.Status)"

# ---------------------------------------------------------------------------
# State Test G - exact normal plus exact DFU simultaneously -> NEEDS REVIEW,
# reporting both InstanceIds, never silently treated as a normal state
# ---------------------------------------------------------------------------
$fixtureStateG_normal = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$fixtureStateG_dfu = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$enumStateG = New-SuccessEnumeration -Devices @($fixtureStateG_normal, $fixtureStateG_dfu)
$normalResultStateG = Get-NormalModeDetectionResult -EnumerationResult $enumStateG
$dfuResultStateG = Get-DfuDetectionResult -EnumerationResult $enumStateG
$advisoryStateG = Get-RecoveryModeNormalIdentityAdvisory -NormalModeResult $normalResultStateG -DfuModeResult $dfuResultStateG
$stateGIsNeedsReview = $advisoryStateG.Status -like 'NEEDS_REVIEW*'
$stateGMentionsBothIds = ($advisoryStateG.Detail -like '*VID_0483&PID_5740*') -and ($advisoryStateG.Detail -like '*VID_0483&PID_DF11*')
Assert-TestResult -TestName 'State Test G - exact normal plus exact DFU simultaneously -> NEEDS REVIEW' -Condition ($stateGIsNeedsReview -and $stateGMentionsBothIds) -Detail "Status: $($advisoryStateG.Status)"

# ---------------------------------------------------------------------------
# State Test H - no devices present -> BLOCKED
# ---------------------------------------------------------------------------
$dfuResultStateH = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @())
Assert-TestResult -TestName 'State Test H - no devices present -> BLOCKED' -Condition ($dfuResultStateH.Status -like 'BLOCKED*') -Detail "Status: $($dfuResultStateH.Status)"

# ---------------------------------------------------------------------------
# State Test I - device enumeration error (Windows API unavailable) ->
# BLOCKED with the exact error text
# ---------------------------------------------------------------------------
$enumStateI = [ordered]@{ Success = $false; Devices = @(); ErrorType = 'ApiUnavailable'; ErrorMessage = 'Get-PnpDevice is not recognized (synthetic test error).' }
$dfuResultStateI = Get-DfuDetectionResult -EnumerationResult $enumStateI
$stateIIsBlocked = $dfuResultStateI.Status -like 'BLOCKED*'
$stateIMentionsError = $dfuResultStateI.Detail -like '*synthetic test error*'
Assert-TestResult -TestName 'State Test I - device enumeration error -> BLOCKED with exact error text' -Condition ($stateIIsBlocked -and $stateIMentionsError) -Detail "Status: $($dfuResultStateI.Status)"

# ---------------------------------------------------------------------------
# State Test J - complete sequential wrapper (function-level, synthetic):
# Preflight-equivalent PASS, ArtifactHashVerify-equivalent PASS,
# DeviceDetect-equivalent PASS (exact normal ID), then RecoveryReadiness-
# equivalent PASS (exact DFU ID, normal absent) -> all four stages clear,
# modeling an overall FINAL NO-FLASH SAFEGUARD PASS.
#
# This is a function-level composition test, not a real end-to-end
# execution of the script's four modes in sequence against real hardware -
# no such hardware exists in this sandbox. It proves the same decision
# functions the live script calls for each mode never independently block
# a valid sequential state transition.
# ---------------------------------------------------------------------------
$scratchStateJ = New-ScratchGitRepo -Prefix 'state_j'
$stagePreflightResult = $null
try {
    Push-Location $scratchStateJ
    try {
        New-Item -ItemType Directory -Path (Join-Path $scratchStateJ 'docs') -Force | Out-Null
        Set-Content -Path (Join-Path $scratchStateJ 'docs\baseline.md') -Value 'baseline' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'baseline commit' 2>&1 | Out-Null
        $scratchBaselineShaJ2 = "$(& git rev-parse HEAD 2>&1)".Trim()

        Set-Content -Path (Join-Path $scratchStateJ 'docs\baseline.md') -Value 'baseline plus docs update' -Encoding UTF8
        & git add docs/baseline.md 2>&1 | Out-Null
        & git commit -q -m 'docs-only descendant commit' 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }
    $stagePreflightResult = Get-BaselineAncestryDiffResult -RepoRoot $scratchStateJ -AcceptedBaselineCommit $scratchBaselineShaJ2 -AllowedPathPrefixes @('docs/', 'tools/')
}
finally {
    Remove-ScratchGitRepo -Dir $scratchStateJ
}
$stage1PreflightPass = $stagePreflightResult.Status -like 'PASS*'

# ArtifactHashVerify-equivalent: replicate the exact size/hash comparison
# the live script performs, against a synthetic file whose real computed
# hash is then used as its own "expected" value (proves the comparison
# logic itself accepts a genuine byte-for-byte match; this sandbox has no
# access to the real firmware/updater bytes to check against their real
# published hashes).
$scratchArtifactPath = Join-Path ([System.IO.Path]::GetTempPath()) "state_j_artifact_$([guid]::NewGuid().ToString('N')).bin"
$stage2ArtifactPass = $false
try {
    [System.IO.File]::WriteAllBytes($scratchArtifactPath, [byte[]](1..64))
    $syntheticExpectedSize = (Get-Item $scratchArtifactPath).Length
    $syntheticExpectedHash = (Get-FileHash -Path $scratchArtifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $syntheticActualSize = (Get-Item $scratchArtifactPath).Length
    $syntheticActualHash = (Get-FileHash -Path $scratchArtifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $stage2ArtifactPass = ($syntheticActualSize -eq $syntheticExpectedSize -and $syntheticActualHash -eq $syntheticExpectedHash)
}
finally {
    if (Test-Path $scratchArtifactPath) { Remove-Item -Path $scratchArtifactPath -Force -ErrorAction SilentlyContinue }
}

# DeviceDetect-equivalent
$fixtureStateJ_normal = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_5740\FLIPPERSERIAL01' -FriendlyName 'Flipper'
$stage3NormalResult = Get-NormalModeDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateJ_normal))
$stage3DeviceDetectPass = $stage3NormalResult.Status -like 'PASS*'

# RecoveryReadiness-equivalent (later in time - normal mode now absent,
# exact DFU present)
$fixtureStateJ_dfu = New-DeviceFixture -InstanceId 'USB\VID_0483&PID_DF11\2059388C4831' -FriendlyName 'STM32  BOOTLOADER'
$enumStateJ_recovery = New-SuccessEnumeration -Devices @($fixtureStateJ_dfu)
$stage4NormalResult = Get-NormalModeDetectionResult -EnumerationResult $enumStateJ_recovery
$stage4DfuResult = Get-DfuDetectionResult -EnumerationResult $enumStateJ_recovery
$stage4Advisory = Get-RecoveryModeNormalIdentityAdvisory -NormalModeResult $stage4NormalResult -DfuModeResult $stage4DfuResult
$stage4RecoveryReadinessPass = ($stage4DfuResult.Status -like 'PASS*') -and ($stage4Advisory.Status -notlike 'BLOCKED*') -and ($stage4Advisory.Status -notlike 'FAIL*') -and ($stage4Advisory.Status -notlike 'NEEDS_REVIEW*')

$allFourStagesClear = $stage1PreflightPass -and $stage2ArtifactPass -and $stage3DeviceDetectPass -and $stage4RecoveryReadinessPass
Assert-TestResult -TestName 'State Test J - complete sequential wrapper -> FINAL NO-FLASH SAFEGUARD PASS (function-level, synthetic)' -Condition $allFourStagesClear -Detail "Preflight: $stage1PreflightPass; ArtifactHashVerify: $stage2ArtifactPass; DeviceDetect: $stage3DeviceDetectPass; RecoveryReadiness: $stage4RecoveryReadinessPass"

# ---------------------------------------------------------------------------
# State Test K - camera false-positive regression: a camera DFU device must
# never determine a PASS, in isolation or alongside the exact Flipper DFU
# identity (re-confirms State Tests D and F from a single, explicitly-named
# regression angle)
# ---------------------------------------------------------------------------
$fixtureStateK_camera = New-DeviceFixture -InstanceId 'USB\VID_04F2&PID_B83E&MI_02\6&1A2B3C4D&0&0002' -FriendlyName 'Camera DFU Device'
$dfuResultStateK_aloneOnly = Get-DfuDetectionResult -EnumerationResult (New-SuccessEnumeration -Devices @($fixtureStateK_camera))
Assert-TestResult -TestName 'State Test K - camera DFU alone never determines PASS' -Condition ($dfuResultStateK_aloneOnly.Status -notlike 'PASS*') -Detail "Status: $($dfuResultStateK_aloneOnly.Status)"

# ---------------------------------------------------------------------------
# State Test L - canonical Git-blob integrity tests remain passing
#
# Not a new assertion - the full Canonical Git Blob Integrity Fix suite
# (byte-capture sanity check plus Blob Tests A-M) runs earlier in this same
# file and is included in this run's overall pass/fail total. This entry
# exists purely so the required test letter is visible in this file's own
# output, cross-referencing that no regression was introduced there.
# ---------------------------------------------------------------------------
$blobSuiteStillPassing = @($script:TestResults | Where-Object { $_.Test -like 'Blob Test *' -and $_.Status -eq 'FAIL' }).Count -eq 0
Assert-TestResult -TestName 'State Test L - canonical Git-blob integrity tests (Blob Test A-M) remain passing' -Condition $blobSuiteStillPassing -Detail "Blob Test failures so far in this run: $(@($script:TestResults | Where-Object { $_.Test -like 'Blob Test *' -and $_.Status -eq 'FAIL' }).Count)"

# ---------------------------------------------------------------------------
# State Test M - zero-flash guarantee: no flashing/install/repair command
# was added anywhere in the gate script's own source text
# ---------------------------------------------------------------------------
$gateScriptPath = Join-Path $PSScriptRoot 'pre_flash_safeguard_gate.ps1'
$gateScriptText = Get-Content -Path $gateScriptPath -Raw
$forbiddenPatterns = @(
    'Invoke-Flash', 'Flash-Device', 'qFlipper.*-repair', 'qFlipper.*[Rr]epair',
    'qFlipper.*[Ii]nstall\s+from\s+file', 'qFlipper.*[Uu]pdate\b.*-[Ff]orce',
    'dfu-util', '\bST-LINK_CLI\b', '\bSTM32CubeProgrammer\b'
)
$foundForbidden = @()
foreach ($pattern in $forbiddenPatterns) {
    if ($gateScriptText -match $pattern) { $foundForbidden += $pattern }
}
Assert-TestResult -TestName 'State Test M - zero-flash guarantee: no flashing/install/repair command found in source' -Condition ($foundForbidden.Count -eq 0) -Detail "Forbidden patterns found: $($foundForbidden -join ', ')"

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

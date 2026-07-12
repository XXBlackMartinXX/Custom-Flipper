<#
.SYNOPSIS
    One-command Windows runner for Gate A of the Custom-Flipper Ultimate
    vNext automated hardware test platform.

.DESCRIPTION
    Fail-closed orchestrator. Automates every safe and deterministic
    step (repository verification, Python environment setup, the host
    pytest suite, test-profile validation, device discovery, a
    read-only CLI handshake, and the Gate A 5-app run) and asks only
    for these physical actions from the operator:

      1. Connect one normally booted Flipper Zero.
      2. Keep the device on its desktop.
      3. Close qFlipper (or anything else holding the serial port) when
         prompted.
      4. Observe the physical device only when explicitly asked.
      5. Never enter DFU mode.
      6. Never approve firmware installation, Repair, erase, or
         formatting - this script never asks for that, and never does
         it.

    HONEST CAPABILITY CEILING (see docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md
    for the full explanation): the underlying Python tester can perform
    real device discovery, a real read-only handshake, a real
    `loader open`/`loader close` round trip, and real uptime/USB/heap-
    continuity and panic-log crash detection - but it cannot yet send a
    profile-declared input sequence or capture/compare a screen
    fingerprint (that requires the Flipper RPC protobuf client, which is
    an intentional, documented skeleton in this phase - see
    hardware_app_tester/rpc_client.py). Because of this, **no per-app
    result is ever classified PASS** by the underlying tool today, so a
    real run will realistically reach `GATE A HARDWARE PROOF PARTIAL`,
    not `GATE A HARDWARE PROOF PASS`. This is deliberate: this gate's
    own rule is "no overall PASS may be emitted unless raw evidence
    supports every required condition," and evidence for the
    input/screen steps does not yet exist. The exit-code contract below
    still defines what `PASS` would mean if/when that capability exists,
    without weakening today's honest ceiling.

    This script NEVER flashes, installs, updates, repairs, erases, or
    formats a device. It never enters DFU mode. It never terminates
    another process automatically.

    EXIT-CODE CONTRACT (authoritative - see Get-ExitCodeForOutcome):
      0 - DryRun completed successfully (no device interaction), or a
          real/Gate-B run reached PASS or PARTIAL with no
          integrity-threatening failure and no blocking condition.
      1 - Internal tooling error (unhandled exception in this script).
      2 - An expected operational blocking condition was hit (no
          device, DFU detected, multiple devices, ambiguous COM port,
          persistent port contention, missing required profile, etc).
          No application was launched.
      3 - A device-integrity or test failure occurred (unexpected
          reboot, uptime reset, USB disappearance, panic/fault, an app
          that would not close, loader state that could not be
          restored, or evidence the wrong application launched).

    A classification is never allowed to disagree with this table: the
    exit code is derived solely from a typed `[GateAOutcome]` value via
    Get-ExitCodeForOutcome, never from an independently-supplied number,
    so a future call site cannot accidentally pair a BLOCKED/FAILED
    classification with exit code 0.

.PARAMETER RepoRoot
    Path to the Custom-Flipper repository root. Defaults to the parent
    of this script's own location (tools/hardware_app_tester/..\..).

.PARAMETER DryRun
    Performs repository verification, environment preparation, the host
    pytest suite, profile validation, planned test-set generation,
    command-plan rendering, and evidence-directory creation. Never
    opens a serial connection, never discovers a device, never launches
    an application. On success, exits 0 with classification
    `GATE A WINDOWS EXECUTION PACKAGE READY / REAL HARDWARE RUN NOT YET
    PERFORMED` and an explicit `HARDWARE EXECUTION: NOT PERFORMED`
    statement.

.PARAMETER Mock
    Developer regression mode only - exercises the full orchestration
    logic against a synthetic, in-process transport instead of a real
    device. Every result is labeled `HARDWARE EXECUTION: NOT PERFORMED`
    and prefixed `MOCK -`. Never usable as real hardware evidence, and
    never promoted to a real Gate A classification. Ignored if -DryRun
    is also specified (DryRun takes precedence).

.PARAMETER SkipSafeAutomationExpansion
    Skips the interactive "run all remaining SAFE_AUTOMATION profiles
    now?" prompt and answers it as declined - useful for a first,
    conservative Gate A-only run.

.PARAMETER SelfTestForceInternalError
    TEST-ONLY. Throws a synthetic exception immediately, before any
    repository, environment, or device action is taken, solely so
    regression tests can exercise the InternalError -> exit-code-1
    contract end-to-end. Never set this during a real run.

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1 -DryRun

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = '',

    [switch]$DryRun,

    [switch]$Mock,

    [switch]$SkipSafeAutomationExpansion,

    [switch]$SelfTestForceInternalError
)

# ---------------------------------------------------------------------------
# PowerShell 5.1 / 7 compatibility discipline: no ternary (?:), no
# null-coalescing (??/??=), no pipeline-chain (&&/||) operators anywhere
# in this file - only if/else, switch, and -and/-or, matching every
# other PowerShell gate script in this project. `enum` is supported in
# both PowerShell 5.1 (5.0+) and PowerShell 7.
# ---------------------------------------------------------------------------

if (-not $RepoRoot) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
$RepoRoot = (Resolve-Path $RepoRoot).Path
$ToolDir = Join-Path $RepoRoot 'tools\hardware_app_tester'
$ExpectedBranch = 'feature/ultimate-vnext-test-census-architecture'
$ExpectedRemoteFragment = 'XXBlackMartinXX/Custom-Flipper'

$RunTimestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss_fff')
$RunNonce = -join ((1..4) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
$ReportDir = Join-Path $RepoRoot "reports\hardware_app_tester\$RunTimestamp-$RunNonce"

$script:StopReason = $null
$script:OverallClassification = $null
$script:FinalOutcome = $null
$script:FinalExitCode = $null
$script:HardwareExecutionOccurred = $false

# ---------------------------------------------------------------------------
# Typed classification -> exit-code contract.
#
# This is the fix for the "successful DryRun returns a non-zero process
# exit code" defect: the previous implementation had exactly one
# terminal path (Stop-Run), which unconditionally called `exit 1`
# regardless of the classification passed to it - including the
# DryRun-success classification. There was no `exit 0` path anywhere in
# the script; the only way a run could appear to succeed at the process
# level was by accident, via whatever $LASTEXITCODE happened to be left
# over from the last native command executed before the script fell off
# its own end (the non-DryRun "final summary" path never called `exit`
# explicitly at all).
# ---------------------------------------------------------------------------

enum GateAOutcome {
    DryRunReady
    HardwarePass
    GateAPartial
    GateBPass
    GateBPartial
    Blocked
    Failed
    InternalError
}

function Get-ExitCodeForOutcome {
    <#
        The single authoritative classification -> exit-code mapping.
        Deliberately takes only the typed [GateAOutcome] enum, never an
        independently-supplied integer, so a call site can never pair a
        Blocked/Failed outcome with exit code 0 by mistake.
    #>
    param([Parameter(Mandatory = $true)][GateAOutcome]$Outcome)
    switch ($Outcome) {
        ([GateAOutcome]::DryRunReady) { return 0 }
        ([GateAOutcome]::HardwarePass) { return 0 }
        ([GateAOutcome]::GateAPartial) { return 0 }
        ([GateAOutcome]::GateBPass) { return 0 }
        ([GateAOutcome]::GateBPartial) { return 0 }
        ([GateAOutcome]::Blocked) { return 2 }
        ([GateAOutcome]::Failed) { return 3 }
        ([GateAOutcome]::InternalError) { return 1 }
        default { return 1 }
    }
}

function ConvertTo-GateOutcome {
    <#
        The only place in this script that inspects a Gate A/B
        classification string returned by the Python CLI - cli.py emits
        plain strings across the process boundary, so there is no
        shared enum type between the two languages. Every exit-code
        decision downstream of this function operates on the returned
        [GateAOutcome] value, never on the raw string again.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][ValidateSet('GateA', 'GateB')][string]$Gate
    )
    if ($Status -match 'FAILED') { return [GateAOutcome]::Failed }
    if ($Status -match 'BLOCKED') { return [GateAOutcome]::Blocked }
    if ($Status -match 'PASS') {
        if ($Gate -eq 'GateA') { return [GateAOutcome]::HardwarePass }
        return [GateAOutcome]::GateBPass
    }
    if ($Status -match 'PARTIAL') {
        if ($Gate -eq 'GateA') { return [GateAOutcome]::GateAPartial }
        return [GateAOutcome]::GateBPartial
    }
    return [GateAOutcome]::InternalError
}

function Write-Phase {
    param([string]$Name)
    Write-Host ''
    Write-Host "=== $Name ===" -ForegroundColor Cyan
}

function Write-Status {
    param([string]$Status, [string]$Detail = '')
    $color = 'Gray'
    if ($Status -like 'PASS*') { $color = 'Green' }
    elseif ($Status -like 'FAIL*') { $color = 'Red' }
    elseif ($Status -like 'BLOCKED*') { $color = 'Yellow' }
    elseif ($Status -like 'NEEDS_REVIEW*' -or $Status -like 'NEEDS REVIEW*') { $color = 'Yellow' }
    elseif ($Status -like 'PARTIAL*') { $color = 'Yellow' }
    elseif ($Status -like 'MOCK*') { $color = 'Magenta' }
    Write-Host "[$Status]" -ForegroundColor $color -NoNewline
    Write-Host " $Detail"
}

function Write-RunManifest {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    $manifest = [ordered]@{
        run_timestamp_utc           = $RunTimestamp
        run_nonce                   = $RunNonce
        report_dir                  = $ReportDir
        dry_run                     = [bool]$DryRun
        mock                        = [bool]$Mock
        overall_classification      = $script:OverallClassification
        outcome                     = $script:FinalOutcome
        exit_code                   = $script:FinalExitCode
        hardware_execution_occurred = $script:HardwareExecutionOccurred
        stop_reason                 = $script:StopReason
        repo_root                   = $RepoRoot
        expected_branch             = $ExpectedBranch
    }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $ReportDir 'run_manifest.json') -Encoding UTF8
}

function Write-ChecksumsFile {
    $files = Get-ChildItem -Path $ReportDir -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'checksums.sha256' }
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($f in $files) {
        $hash = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $relative = $f.FullName.Substring($ReportDir.Length + 1) -replace '\\', '/'
        $lines.Add("$hash  $relative")
    }
    $lines | Set-Content -Path (Join-Path $ReportDir 'checksums.sha256') -Encoding UTF8
}

function Complete-Run {
    <#
        The single centralized finalization path for every controlled
        exit from this script (replacing the old Stop-Run, which always
        called `exit 1` no matter what classification it was given).

        Receives: a human-readable Classification string, a typed
        Outcome (drives the exit code - see Get-ExitCodeForOutcome),
        and an explicit HardwareExecutionOccurred flag recorded in the
        evidence manifest so a reader never has to infer it from the
        classification text. Always writes evidence (checksums, then
        the run manifest) before exiting, and always uses `exit
        <derived code>` - never relies on $LASTEXITCODE left over from
        an earlier native command.

        `exit` inside PowerShell try/finally blocks still runs the
        enclosing `finally` blocks before the process terminates (e.g.
        Phase A's Pop-Location), and is not intercepted by an enclosing
        `catch` block - both verified directly against this project's
        pwsh before relying on it here. Nested `powershell.exe`/`pwsh
        -File` invocations propagate this exit code to the parent's
        $LASTEXITCODE unchanged (also verified directly).
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Classification,
        [Parameter(Mandatory = $true)][GateAOutcome]$Outcome,
        [Parameter(Mandatory = $true)][bool]$HardwareExecutionOccurred,
        [string]$Detail = ''
    )

    $exitCode = Get-ExitCodeForOutcome -Outcome $Outcome

    $completedOutcomes = @(
        [GateAOutcome]::DryRunReady,
        [GateAOutcome]::HardwarePass,
        [GateAOutcome]::GateAPartial,
        [GateAOutcome]::GateBPass,
        [GateAOutcome]::GateBPartial
    )
    $runLabel = 'STOPPED'
    if ($completedOutcomes -contains $Outcome) {
        $runLabel = 'COMPLETED'
    }

    $script:OverallClassification = $Classification
    $script:StopReason = $Detail
    $script:FinalOutcome = $Outcome.ToString()
    $script:FinalExitCode = $exitCode
    $script:HardwareExecutionOccurred = $HardwareExecutionOccurred

    Write-Phase $runLabel
    Write-Status -Status $Classification -Detail $Detail
    if (-not $HardwareExecutionOccurred) {
        Write-Host 'HARDWARE EXECUTION: NOT PERFORMED' -ForegroundColor DarkGray
    }

    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    Write-ChecksumsFile
    Write-RunManifest

    Write-Host ''
    Write-Host "Evidence written to: $ReportDir" -ForegroundColor Cyan

    exit $exitCode
}

try {

    if ($SelfTestForceInternalError) {
        throw 'Synthetic internal error requested via -SelfTestForceInternalError (test-only fault injection - no repository, environment, or device action was taken).'
    }

    # -----------------------------------------------------------------------
    # Phase A - Repository verification
    # -----------------------------------------------------------------------

    Write-Phase 'Phase A - Repository verification'

    if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "$RepoRoot does not look like a git repository root (.git not found)."
    }

    Push-Location $RepoRoot
    try {
        $remoteUrl = "$(& git remote get-url origin 2>&1)".Trim()
        if ($remoteUrl -notlike "*$ExpectedRemoteFragment*") {
            Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "origin remote ($remoteUrl) does not match the expected repository ($ExpectedRemoteFragment) - refusing to proceed against a different repository."
        }

        $currentBranch = "$(& git rev-parse --abbrev-ref HEAD 2>&1)".Trim()
        if ($currentBranch -eq 'HEAD') {
            Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'Repository is in a detached HEAD state - refusing to proceed. Check out feature/ultimate-vnext-test-census-architecture explicitly.'
        }
        if ($currentBranch -ne $ExpectedBranch) {
            Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "Current branch is '$currentBranch', expected '$ExpectedBranch'. Check out the correct branch before running this script."
        }

        & git fetch origin $ExpectedBranch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Status -Status 'NEEDS_REVIEW' -Detail 'git fetch failed or is offline - continuing with the local branch state as-is (not modifying source files).'
        }
        else {
            & git pull --ff-only origin $ExpectedBranch 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'git pull --ff-only failed - the local branch has diverged from origin. Resolve this manually before running this script; it will not attempt a merge or rebase.'
            }
        }

        $statusPorcelain = & git status --porcelain 2>&1
        if ("$statusPorcelain".Trim() -ne '') {
            Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "Working tree is not clean:`n$statusPorcelain`nCommit, stash, or discard these changes before running this script."
        }

        $headCommit = "$(& git rev-parse HEAD 2>&1)".Trim()
        Write-Status -Status 'PASS' -Detail "Branch $currentBranch at $headCommit, working tree clean."
    }
    finally {
        Pop-Location
    }

    # -----------------------------------------------------------------------
    # Phase B - Environment preparation
    # -----------------------------------------------------------------------

    Write-Phase 'Phase B - Environment preparation'

    function Get-SupportedPython {
        $candidates = @()
        if (Get-Command 'py' -ErrorAction SilentlyContinue) {
            $candidates += @{ Command = 'py'; Args = @('-3') }
        }
        if (Get-Command 'python3' -ErrorAction SilentlyContinue) {
            $candidates += @{ Command = 'python3'; Args = @() }
        }
        if (Get-Command 'python' -ErrorAction SilentlyContinue) {
            $candidates += @{ Command = 'python'; Args = @() }
        }

        foreach ($candidate in $candidates) {
            $versionArgs = $candidate.Args + @('--version')
            $versionOutput = "$(& $candidate.Command @versionArgs 2>&1)".Trim()
            if ($versionOutput -match 'Python (\d+)\.(\d+)') {
                $major = [int]$Matches[1]
                $minor = [int]$Matches[2]
                if ($major -eq 3 -and $minor -ge 10) {
                    return [ordered]@{ Command = $candidate.Command; Args = $candidate.Args; Version = $versionOutput }
                }
            }
        }
        return $null
    }

    $pythonInfo = Get-SupportedPython
    if ($null -eq $pythonInfo) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'No supported Python (>= 3.10) was found via py/python3/python. Install Python 3.10+ and ensure it is on PATH.'
    }
    Write-Status -Status 'PASS' -Detail "Using $($pythonInfo.Command) $($pythonInfo.Args) - $($pythonInfo.Version)"

    $VenvDir = Join-Path $ToolDir '.venv'
    # Cross-platform venv layout detection: Windows PowerShell 5.1 only ever
    # runs on Windows (Scripts\python.exe), but PowerShell 7 is genuinely
    # cross-platform and this script is tested in this project's own CI/dev
    # sandbox via pwsh on Linux (bin/python) before being run for real on
    # Windows - $IsWindows is undefined in Windows PowerShell 5.1, where the
    # Windows layout is always correct.
    $isWindowsPlatform = $true
    if (Test-Path variable:IsWindows) {
        $isWindowsPlatform = $IsWindows
    }
    if ($isWindowsPlatform) {
        $venvPython = Join-Path $VenvDir 'Scripts\python.exe'
    }
    else {
        $venvPython = Join-Path $VenvDir 'bin/python'
    }
    if (-not (Test-Path $venvPython)) {
        $createArgs = $pythonInfo.Args + @('-m', 'venv', $VenvDir)
        & $pythonInfo.Command @createArgs
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $venvPython)) {
            Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "Failed to create a virtual environment at $VenvDir."
        }
    }
    Write-Status -Status 'PASS' -Detail "Isolated virtual environment ready at $VenvDir (gitignored path)."

    & $venvPython -m pip install --disable-pip-version-check --quiet --upgrade pip 2>&1 | Out-Null
    & $venvPython -m pip install --disable-pip-version-check --quiet -r (Join-Path $ToolDir 'requirements.txt')
    if ($LASTEXITCODE -ne 0) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'pip install of tools/hardware_app_tester/requirements.txt failed.'
    }

    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    $freezeOutput = & $venvPython -m pip freeze 2>&1
    $freezeOutput | Set-Content -Path (Join-Path $ReportDir 'dependency_versions.json.tmp') -Encoding UTF8
    $depVersions = [ordered]@{}
    foreach ($line in $freezeOutput) {
        if ($line -match '^([^=]+)==(.+)$') {
            $depVersions[$Matches[1]] = $Matches[2]
        }
    }
    $depVersions | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $ReportDir 'dependency_versions.json') -Encoding UTF8
    Remove-Item -Path (Join-Path $ReportDir 'dependency_versions.json.tmp') -ErrorAction SilentlyContinue
    Write-Status -Status 'PASS' -Detail "Dependency versions recorded to dependency_versions.json (pinned in requirements.txt; installed into the isolated venv only - no system-wide install)."

    $environmentInfo = [ordered]@{
        os                 = "$(& $venvPython -c 'import platform; print(platform.platform())' 2>&1)".Trim()
        python_version     = "$(& $venvPython -c 'import sys; print(sys.version)' 2>&1)".Trim()
        powershell_version = $PSVersionTable.PSVersion.ToString()
        powershell_edition = $PSVersionTable.PSEdition
    }
    $environmentInfo | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $ReportDir 'environment.json') -Encoding UTF8

    $repositoryInfo = [ordered]@{
        repo_root   = $RepoRoot
        branch      = $currentBranch
        head_commit = $headCommit
        remote_url  = $remoteUrl
    }
    $repositoryInfo | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $ReportDir 'repository.json') -Encoding UTF8

    Write-Status -Status 'PASS' -Detail 'Parse-checking all Python files under hardware_app_tester/ before the hardware phase.'
    $pyFiles = Get-ChildItem -Path (Join-Path $ToolDir 'hardware_app_tester') -Filter '*.py' -Recurse
    $parseFailures = @()
    foreach ($pyFile in $pyFiles) {
        & $venvPython -c "import ast; ast.parse(open(r'$($pyFile.FullName)', encoding='utf-8').read())" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $parseFailures += $pyFile.FullName
        }
    }
    if ($parseFailures.Count -gt 0) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail "Python parse failure(s): $($parseFailures -join ', ')"
    }
    Write-Status -Status 'PASS' -Detail "$($pyFiles.Count) Python file(s) parse cleanly."

    Write-Status -Status 'PASS' -Detail 'Running the complete host pytest suite (hardware-independent unit tests).'
    Push-Location $ToolDir
    try {
        & $venvPython -m pytest tests -v 2>&1 | Tee-Object -FilePath (Join-Path $ReportDir 'pytest_output.log')
        $pytestExitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    if ($pytestExitCode -ne 0) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'The host pytest suite did not fully pass - see pytest_output.log. Refusing to proceed to device interaction with a failing test suite.'
    }
    Write-Status -Status 'PASS' -Detail 'Host pytest suite passed.'

    # -----------------------------------------------------------------------
    # Phase C - Profile validation
    # -----------------------------------------------------------------------

    Write-Phase 'Phase C - Profile validation'

    $env:PYTHONPATH = $ToolDir
    $profileValidationOutput = & $venvPython -m hardware_app_tester.cli validate-profiles --repo-root $RepoRoot --output (Join-Path $ReportDir 'profile_validation.json') 2>&1
    $profileValidationExit = $LASTEXITCODE
    Write-Host ($profileValidationOutput -join "`n")
    if ($profileValidationExit -ne 0) {
        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $false -Detail 'Profile validation failed - see profile_validation.json. This includes the required-count check (exactly 20 unless explained), schema validation, and the repository cross-check (source_path exists, launch_target matches the real application.fam appid).'
    }
    Write-Status -Status 'PASS' -Detail 'All 20 profiles schema-valid and cross-checked against real source.'

    # -----------------------------------------------------------------------
    # DryRun short-circuit: everything above is real; nothing below this
    # point touches a device.
    # -----------------------------------------------------------------------

    if ($DryRun) {
        Write-Phase 'DryRun - device discovery, handshake, and app runs skipped by design'
        & $venvPython -m hardware_app_tester.cli discover --dry-run --output (Join-Path $ReportDir 'device_discovery.json') 2>&1 | Out-Null
        & $venvPython -m hardware_app_tester.cli run-gate-a --repo-root $RepoRoot --report-dir $ReportDir --dry-run --output (Join-Path $ReportDir 'app_results.json') 2>&1 | Out-Null

        $summary = @"
# Gate A Hardware Proof - DryRun

DryRun performed repository verification, environment preparation, the
host pytest suite, profile validation, and planned test-set / command-
plan rendering. **No serial connection was opened. No device was
discovered. No application was launched. HARDWARE EXECUTION: NOT
PERFORMED.**

See profile_validation.json, device_discovery.json (NOT_RUN by design),
and app_results.json (planned_apps only) in this directory.
"@
        $summary | Set-Content -Path (Join-Path $ReportDir 'summary.md') -Encoding UTF8

        Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE READY / REAL HARDWARE RUN NOT YET PERFORMED' -Outcome ([GateAOutcome]::DryRunReady) -HardwareExecutionOccurred $false -Detail 'DryRun completed successfully. No device interaction occurred. HARDWARE EXECUTION: NOT PERFORMED.'
    }

    # -----------------------------------------------------------------------
    # Phase D/E - Device discovery + serial-port contention
    # -----------------------------------------------------------------------

    Write-Phase 'Phase D/E - Device discovery and serial-port contention'

    if (-not $Mock) {
        Write-Host ''
        Write-Host 'ACTION REQUIRED: connect one normally booted Flipper Zero now, on its desktop.' -ForegroundColor Yellow
        Write-Host 'Do not enter DFU mode. Do not approve any install/Repair/erase/format prompt.' -ForegroundColor Yellow
        Write-Host ''
    }

    function Invoke-Discover {
        $discoverArgs = @('-m', 'hardware_app_tester.cli', 'discover', '--output', (Join-Path $ReportDir 'device_discovery.json'))
        $output = & $venvPython @discoverArgs 2>&1
        Write-Host ($output -join "`n")
        return (Get-Content (Join-Path $ReportDir 'device_discovery.json') -Raw | ConvertFrom-Json)
    }

    if (-not $Mock) {
        # From this point on, a real, physical device interaction is
        # attempted, whatever the outcome - recorded honestly in every
        # subsequent evidence manifest via HardwareExecutionOccurred.
        $script:HardwareExecutionOccurred = $true

        $discoverResult = Invoke-Discover

        if ($discoverResult.status -eq 'BLOCKED - PORT CONTENTION') {
            Write-Host ''
            Write-Host 'The Flipper''s serial port appears to be held by another process' -ForegroundColor Yellow
            Write-Host '(commonly qFlipper). Close qFlipper (or any other program that might' -ForegroundColor Yellow
            Write-Host 'have a connection open to the device) now.' -ForegroundColor Yellow
            Write-Host ''
            $confirmation = Read-Host 'Type CLOSED once qFlipper (and any other serial client) is closed, or anything else to abort'
            if ($confirmation -ne 'CLOSED') {
                Complete-Run -Classification 'GATE A HARDWARE PROOF BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $true -Detail 'Operator did not confirm the serial port was freed. Aborting rather than guessing.'
            }
            Remove-Item -Path (Join-Path $ReportDir 'device_discovery.json') -ErrorAction SilentlyContinue
            # Maximum one controlled retry - never terminate qFlipper automatically.
            $discoverResult = Invoke-Discover
        }

        if ($discoverResult.status -ne 'PASS') {
            Complete-Run -Classification 'GATE A HARDWARE PROOF BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $true -Detail "Device discovery did not pass: $($discoverResult.detail)"
        }
        Write-Status -Status 'PASS' -Detail "Device discovered on $($discoverResult.port.device)."

        # ---------------------------------------------------------------
        # Phase F - Read-only device handshake
        # ---------------------------------------------------------------
        Write-Phase 'Phase F - Read-only device handshake'
        $handshakeArgs = @('-m', 'hardware_app_tester.cli', 'handshake', '--port', $discoverResult.port.device, '--output', (Join-Path $ReportDir 'serial_handshake.json'))
        $handshakeOutput = & $venvPython @handshakeArgs 2>&1
        $handshakeExit = $LASTEXITCODE
        Write-Host ($handshakeOutput -join "`n")
        if ($handshakeExit -ne 0) {
            Complete-Run -Classification 'GATE A HARDWARE PROOF BLOCKED' -Outcome ([GateAOutcome]::Blocked) -HardwareExecutionOccurred $true -Detail 'Read-only device handshake did not pass - see serial_handshake.json. No application will be launched until this passes.'
        }
        Write-Status -Status 'PASS' -Detail 'CLI prompt reachable; uptime/loader/heap queries responded.'
    }
    else {
        Write-Status -Status 'MOCK - SYNTHETIC DEVICE' -Detail 'Mock mode: device discovery and handshake are skipped in favor of a synthetic in-process transport used directly by the app-run phase below.'
        [ordered]@{ status = 'MOCK - SYNTHETIC DEVICE'; detail = 'No real discovery attempted.' } | ConvertTo-Json | Set-Content -Path (Join-Path $ReportDir 'device_discovery.json') -Encoding UTF8
        [ordered]@{ status = 'MOCK - NOT PERFORMED'; detail = 'No real handshake attempted.' } | ConvertTo-Json | Set-Content -Path (Join-Path $ReportDir 'serial_handshake.json') -Encoding UTF8
    }

    # -----------------------------------------------------------------------
    # Phase G - Inventory reconciliation (partial - see honest note below)
    # -----------------------------------------------------------------------

    Write-Phase 'Phase G - Inventory reconciliation'
    Write-Host 'NOTE: full device-visible app inventory reconciliation (loader list vs.' -ForegroundColor DarkGray
    Write-Host 'profiles vs. build output) is not yet implemented in this tool version -' -ForegroundColor DarkGray
    Write-Host 'only source-manifest vs. expected-profile reconciliation (Phase C) is real' -ForegroundColor DarkGray
    Write-Host 'today. This is disclosed, not silently assumed complete.' -ForegroundColor DarkGray
    $inventoryReconciliation = [ordered]@{
        source_manifest_vs_profiles = 'RECONCILED (Phase C - profile_validation.json)'
        device_visible_inventory    = 'NOT_IMPLEMENTED - loader list-based reconciliation requires a CLI subcommand not yet built in this phase'
        built_fap_inventory         = 'NOT_IMPLEMENTED - requires a real fbt build, out of scope for this phase'
    }
    $inventoryReconciliation | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path $ReportDir 'inventory_reconciliation.json') -Encoding UTF8

    # -----------------------------------------------------------------------
    # Phase H - Gate A representative app set
    # -----------------------------------------------------------------------

    Write-Phase 'Phase H - Gate A representative app set (5 apps)'
    if (-not $Mock) {
        Write-Host 'Observe the device screen during this phase - apps will open and close' -ForegroundColor Yellow
        Write-Host 'automatically. Do not press device buttons unless the summary later' -ForegroundColor Yellow
        Write-Host 'instructs you to.' -ForegroundColor Yellow
    }

    $gateAArgs = @('-m', 'hardware_app_tester.cli', 'run-gate-a', '--repo-root', $RepoRoot, '--report-dir', $ReportDir, '--output', (Join-Path $ReportDir 'app_results.json'))
    if ($Mock) { $gateAArgs += '--mock' }
    $gateAOutput = & $venvPython @gateAArgs 2>&1
    Write-Host ($gateAOutput -join "`n")
    $gateAResult = Get-Content (Join-Path $ReportDir 'app_results.json') -Raw | ConvertFrom-Json

    Write-Status -Status $gateAResult.status -Detail $gateAResult.detail

    $gateAOutcome = ConvertTo-GateOutcome -Status $gateAResult.status -Gate 'GateA'
    if ($gateAOutcome -eq [GateAOutcome]::Blocked -or $gateAOutcome -eq [GateAOutcome]::Failed) {
        Complete-Run -Classification $gateAResult.status -Outcome $gateAOutcome -HardwareExecutionOccurred $script:HardwareExecutionOccurred -Detail $gateAResult.detail
    }

    # -----------------------------------------------------------------------
    # Phase I - Expansion to all remaining SAFE_AUTOMATION apps
    # -----------------------------------------------------------------------

    Write-Phase 'Phase I - Optional expansion to remaining SAFE_AUTOMATION apps'

    $runSafeAutomation = $false
    if ($SkipSafeAutomationExpansion) {
        Write-Status -Status 'NOT_RUN' -Detail '-SkipSafeAutomationExpansion was specified; treating the expansion prompt as declined.'
    }
    else {
        $expansionAnswer = Read-Host 'Run all remaining SAFE_AUTOMATION profiles now? [y/N]'
        if ($expansionAnswer -eq 'y' -or $expansionAnswer -eq 'Y') {
            $runSafeAutomation = $true
        }
    }

    $gateBClassification = 'GATE B SAFE-AUTOMATION QUALIFICATION NOT RUN (declined)'
    $finalOutcome = $gateAOutcome
    $finalClassificationSource = $gateAResult.status

    if ($runSafeAutomation) {
        $safeAutoArgs = @('-m', 'hardware_app_tester.cli', 'run-safe-automation', '--repo-root', $RepoRoot, '--report-dir', $ReportDir, '--output', (Join-Path $ReportDir 'app_results_expansion.json'))
        if ($Mock) { $safeAutoArgs += '--mock' }
        $safeAutoOutput = & $venvPython @safeAutoArgs 2>&1
        Write-Host ($safeAutoOutput -join "`n")
        $safeAutoResult = Get-Content (Join-Path $ReportDir 'app_results_expansion.json') -Raw | ConvertFrom-Json
        Write-Status -Status $safeAutoResult.status -Detail $safeAutoResult.detail

        $gateBClassification = $safeAutoResult.status
        $safeAutoOutcome = ConvertTo-GateOutcome -Status $safeAutoResult.status -Gate 'GateB'
        if ($safeAutoOutcome -eq [GateAOutcome]::Blocked -or $safeAutoOutcome -eq [GateAOutcome]::Failed) {
            # A real integrity-threatening condition (or blocking
            # condition) surfaced during the optional Gate B expansion -
            # this must never be silently folded into a successful Gate
            # A result just because Gate A itself already passed.
            Complete-Run -Classification $safeAutoResult.status -Outcome $safeAutoOutcome -HardwareExecutionOccurred $script:HardwareExecutionOccurred -Detail $safeAutoResult.detail
        }
        $finalOutcome = $safeAutoOutcome
        $finalClassificationSource = $safeAutoResult.status
    }
    else {
        Write-Status -Status 'NOT_RUN' -Detail 'Remaining SAFE_AUTOMATION profiles were not run. Gate B is not classified complete.'
    }

    # -----------------------------------------------------------------------
    # Final summary and evidence
    # -----------------------------------------------------------------------

    Write-Phase 'Final summary'

    $mockPrefix = ''
    if ($Mock -and $finalClassificationSource -notlike 'MOCK -*') {
        # cli.py's own run-gate-a/run-safe-automation output already
        # prefixes "MOCK - " onto the status string in mock mode; only
        # add it here if that did not already happen, to avoid a
        # confusing doubled "MOCK - MOCK - ..." classification.
        $mockPrefix = 'MOCK - '
    }

    $summaryLines = New-Object System.Collections.Generic.List[string]
    $summaryLines.Add('# Gate A Hardware Proof - Run Summary')
    $summaryLines.Add('')
    $summaryLines.Add("Repository HEAD: $headCommit ($currentBranch)")
    $summaryLines.Add("Mock mode: $Mock")
    $summaryLines.Add('')
    $summaryLines.Add("Gate A result: $($gateAResult.status)")
    $summaryLines.Add("Gate B result: $gateBClassification")
    $summaryLines.Add('')
    $summaryLines.Add('No per-app result is ever classified PASS by this tool version - input-')
    $summaryLines.Add('sequence and screen-fingerprint verification are not yet implemented (the')
    $summaryLines.Add('RPC client is an intentional skeleton). See docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md.')
    $summaryLines.Add('')
    $summaryLines.Add('**No firmware was flashed. No firmware was installed or reinstalled.**')
    ($summaryLines -join "`n") | Set-Content -Path (Join-Path $ReportDir 'summary.md') -Encoding UTF8

    Complete-Run -Classification "$mockPrefix$finalClassificationSource" -Outcome $finalOutcome -HardwareExecutionOccurred $script:HardwareExecutionOccurred -Detail 'Run complete.'

}
catch {
    Complete-Run -Classification 'GATE A WINDOWS EXECUTION PACKAGE INTERNAL ERROR' -Outcome ([GateAOutcome]::InternalError) -HardwareExecutionOccurred $script:HardwareExecutionOccurred -Detail "Unhandled exception: $($_.Exception.Message)"
}

<#
.SYNOPSIS
    Dependency-free (no Pester) regression tests for the PowerShell-side
    process supervision added in the Gate A serial-transport-hardening
    phase: Invoke-BoundedPythonCommand and Repair-EvidenceAfterWatchdog
    in Run-GateA-HardwareProof.ps1.

.DESCRIPTION
    Loads these functions the same way tests/test_exit_code_contract.ps1
    already does - by extracting the real script's enum/function
    definitions region (everything between `enum GateAOutcome {` and
    `function Write-Phase {`) and evaluating it in this process - so
    these tests exercise the literal shipped implementation, not a
    hand-copied reimplementation.

    Covers Part 7, item 17: "Process watchdog timeout preserves
    stdout/stderr/evidence." A deliberately slow Python one-liner
    stands in for a hung handshake subprocess; a short timeout forces
    the watchdog to intervene, and the test asserts that (a) it
    actually terminated only that one process, (b) partial stdout was
    still captured, and (c) Repair-EvidenceAfterWatchdog preserves or
    honestly fabricates a fallback evidence file rather than leaving
    nothing behind.
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

$scriptText = Get-Content -Path $ScriptUnderTest -Raw
$startMarker = "`nenum GateAOutcome {`n"
$endMarker = "`nfunction Write-Phase {`n"
$startIndex = $scriptText.IndexOf($startMarker)
$endIndex = $scriptText.IndexOf($endMarker)
Assert-True -Name 'Located the enum/pure-function region in the real script' -Condition ($startIndex -gt 0 -and $endIndex -gt $startIndex)
$definitionsText = $scriptText.Substring($startIndex, $endIndex - $startIndex)
Invoke-Expression $definitionsText

function Get-PortablePython {
    foreach ($candidate in @('python3', 'python')) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            return $candidate
        }
    }
    return $null
}

$pythonExe = Get-PortablePython
Assert-True -Name 'A portable python3/python was found to drive these tests' -Condition ($null -ne $pythonExe)

$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ("gatea-transport-ps-test-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

try {
    # -------------------------------------------------------------------
    # 17. Process watchdog timeout preserves stdout/stderr/evidence.
    # -------------------------------------------------------------------
    $slowScript = Join-Path $workDir 'slow_hang.py'
    @'
import sys
import time
print("partial output before the hang", flush=True)
time.sleep(30)
print("should never be reached")
'@ | Set-Content -Path $slowScript -Encoding UTF8

    $stdOutPath = Join-Path $workDir 'slow_stdout.log'
    $stdErrPath = Join-Path $workDir 'slow_stderr.log'

    $result = Invoke-BoundedPythonCommand -PythonExe $pythonExe -PythonArgs @($slowScript) -WorkingDirectory $workDir `
        -TimeoutSeconds 2 -StdOutPath $stdOutPath -StdErrPath $stdErrPath

    Assert-Equal -Name 'Watchdog: Completed is false for a genuinely hung process' -Expected 'False' -Actual $result.Completed
    Assert-Equal -Name 'Watchdog: WatchdogIntervened is true' -Expected 'True' -Actual $result.WatchdogIntervened
    Assert-True -Name 'Watchdog: partial stdout was still captured despite the kill' -Condition ($result.StdOut -match 'partial output before the hang')

    # -------------------------------------------------------------------
    # Confirm ONLY the target process was affected - a second, unrelated
    # background process (standing in for qFlipper) must survive.
    # -------------------------------------------------------------------
    $bystanderScript = Join-Path $workDir 'bystander.py'
    'import time' + "`n" + 'time.sleep(15)' | Set-Content -Path $bystanderScript -Encoding UTF8
    $bystander = Start-Process -FilePath $pythonExe -ArgumentList @($bystanderScript) -PassThru -WorkingDirectory $workDir

    $hangScript2 = Join-Path $workDir 'slow_hang2.py'
    'import time' + "`n" + 'time.sleep(30)' | Set-Content -Path $hangScript2 -Encoding UTF8
    $stdOutPath2 = Join-Path $workDir 'slow_stdout2.log'
    $stdErrPath2 = Join-Path $workDir 'slow_stderr2.log'
    Invoke-BoundedPythonCommand -PythonExe $pythonExe -PythonArgs @($hangScript2) -WorkingDirectory $workDir `
        -TimeoutSeconds 2 -StdOutPath $stdOutPath2 -StdErrPath $stdErrPath2 | Out-Null

    Start-Sleep -Milliseconds 300
    $bystanderStillRunning = -not $bystander.HasExited
    Assert-True -Name 'Watchdog: an unrelated bystander process (standing in for qFlipper) was left untouched' -Condition $bystanderStillRunning
    if ($bystanderStillRunning) {
        Stop-Process -Id $bystander.Id -Force -ErrorAction SilentlyContinue
    }

    # -------------------------------------------------------------------
    # Repair-EvidenceAfterWatchdog: partial evidence is patched, not
    # replaced/invented.
    # -------------------------------------------------------------------
    $partialEvidencePath = Join-Path $workDir 'partial_evidence.json'
    [ordered]@{
        command = 'handshake'
        stages  = @(
            [ordered]@{ stage = 'PROCESS_STARTED' }
            [ordered]@{ stage = 'SERIAL_OPEN_START' }
            [ordered]@{ stage = 'SERIAL_OPEN_PASS' }
            [ordered]@{ stage = 'PROMPT_SYNC_START' }
        )
        last_stage = 'PROMPT_SYNC_START'
    } | ConvertTo-Json -Depth 6 | Set-Content -Path $partialEvidencePath -Encoding UTF8

    Repair-EvidenceAfterWatchdog -EvidencePath $partialEvidencePath -CommandName 'handshake' `
        -FallbackStatus 'BLOCKED - HANDSHAKE PROCESS TIMEOUT' -TimeoutSeconds 30 -ExitCode $null

    $patched = Get-Content -Path $partialEvidencePath -Raw | ConvertFrom-Json
    Assert-Equal -Name 'Repair: watchdog_intervened patched onto existing partial evidence' -Expected 'True' -Actual $patched.watchdog_intervened
    Assert-Equal -Name 'Repair: real prior stages (last_stage) preserved, not invented' -Expected 'PROMPT_SYNC_START' -Actual $patched.last_stage
    Assert-Equal -Name 'Repair: stage count unchanged (no fabricated stages added)' -Expected 4 -Actual $patched.stages.Count

    # -------------------------------------------------------------------
    # Repair-EvidenceAfterWatchdog: no evidence file at all (killed
    # before its own first atomic write) -> honest fallback is created.
    # -------------------------------------------------------------------
    $missingEvidencePath = Join-Path $workDir 'missing_evidence.json'
    Repair-EvidenceAfterWatchdog -EvidencePath $missingEvidencePath -CommandName 'handshake' `
        -FallbackStatus 'BLOCKED - HANDSHAKE PROCESS TIMEOUT' -TimeoutSeconds 30 -ExitCode $null

    Assert-True -Name 'Repair: a fallback evidence file is created when none existed at all' -Condition (Test-Path $missingEvidencePath)
    $fallback = Get-Content -Path $missingEvidencePath -Raw | ConvertFrom-Json
    Assert-Equal -Name 'Repair: fallback status matches the requested classification' -Expected 'BLOCKED - HANDSHAKE PROCESS TIMEOUT' -Actual $fallback.status
    Assert-Equal -Name 'Repair: fallback watchdog_intervened is true' -Expected 'True' -Actual $fallback.watchdog_intervened
    Assert-Equal -Name 'Repair: fallback discloses applications_launched=false' -Expected 'False' -Actual $fallback.applications_launched
    Assert-Equal -Name 'Repair: fallback discloses firmware_operations_performed=false' -Expected 'False' -Actual $fallback.firmware_operations_performed

    # -------------------------------------------------------------------
    # A process that completes well within the timeout is reported as
    # completed, not as a watchdog intervention.
    # -------------------------------------------------------------------
    $fastScript = Join-Path $workDir 'fast_ok.py'
    'print("fast ok")' | Set-Content -Path $fastScript -Encoding UTF8
    $fastStdOut = Join-Path $workDir 'fast_stdout.log'
    $fastStdErr = Join-Path $workDir 'fast_stderr.log'
    $fastResult = Invoke-BoundedPythonCommand -PythonExe $pythonExe -PythonArgs @($fastScript) -WorkingDirectory $workDir `
        -TimeoutSeconds 10 -StdOutPath $fastStdOut -StdErrPath $fastStdErr

    Assert-Equal -Name 'Fast process: Completed is true' -Expected 'True' -Actual $fastResult.Completed
    Assert-Equal -Name 'Fast process: WatchdogIntervened is false' -Expected 'False' -Actual $fastResult.WatchdogIntervened
    Assert-Equal -Name 'Fast process: exit code captured as 0' -Expected 0 -Actual $fastResult.ExitCode
    Assert-True -Name 'Fast process: stdout captured' -Condition ($fastResult.StdOut -match 'fast ok')
}
finally {
    Remove-Item -Path $workDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "Passed: $script:PassCount  Failed: $script:FailCount" -ForegroundColor Cyan

if ($script:FailCount -gt 0) {
    exit 1
}
exit 0

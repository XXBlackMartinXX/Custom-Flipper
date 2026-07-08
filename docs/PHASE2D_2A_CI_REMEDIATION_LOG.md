# Phase 2D.2A — CI Remediation Log

Docs + a narrow tooling fix. Records exactly what was changed, why, and
what the real validation results were, for the `updater_package` CI
blocker remediation. See `docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`
for the full investigation this remediation is based on.

## Workflow/script changes made

### 1. `tools/phase2a_validate.ps1` — diagnostics + launch-method change

**Scope**: exactly one call site — the `updater_package` `fbt.cmd`
invocation inside the existing `if ($buildExit -eq 0) { ... }` block. The
firmware build call site immediately above it (same file, ~15 lines
earlier) is untouched.

**Diagnostic commands added**, printed via `Write-Host` (so they appear
directly in the CI job log, not only in a redirected file) immediately
before the `updater_package` attempt:

```powershell
Write-Host "Current directory: $(Get-Location)"
Write-Host "Repo root: $RepoRoot"
$fbtExists = Test-Path $fbtPath
Write-Host "fbt.cmd exists: $fbtExists"
# ... Get-Item metadata, Get-Command resolution ...
cmd /c "dir `"$fbtPath`"" 2>&1 | ForEach-Object { Write-Host "  $_" }
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "OS version: $([System.Environment]::OSVersion.VersionString)"
# ... git status --short, build-output directory presence ...
# ... disk free/used space via Get-PSDrive ...
# ... Windows Defender real-time-protection status via Get-MpComputerStatus ...
Write-Host "PATH (first 500 chars): $($env:PATH.Substring(0, [Math]::Min(500, $env:PATH.Length)))"
```

No secret, token, or credential value is printed — this workflow has no
configured secrets (`permissions: contents: read, actions: read` only),
and the diagnostics deliberately print only the first 500 characters of
`PATH` (a long but non-secret system value) rather than a full
environment-variable dump.

**Command-launch method used**: replaced

```powershell
& .\fbt.cmd COMPACT=1 DEBUG=0 updater_package *> $updaterLogPath
```

with

```powershell
cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0 updater_package" *> $updaterLogPath
```

**Why this method, and why it is safe and narrow**:
- It is the least invasive of the three options the remediation task
  offered (`cmd /c` wrapper, `Start-Process -Wait -PassThru`, or an
  absolute-path `&` invocation) — it changes only *how* the process is
  launched (via `cmd.exe` itself, the same shell a user would get by
  typing the command directly at a Windows command prompt), not the
  build target, not the arguments, not the output redirection, and not
  the exit-code-based pass/fail logic downstream (`$LASTEXITCODE` is set
  identically by `cmd /c` as it was by the bare `&` operator).
- It does not skip `updater_package`, does not hide a failure (the
  existing `catch` block and `BLOCKED`/`FAIL` classification logic is
  completely unchanged — only the invocation inside the `try` changed),
  and does not weaken the artifact-verification checks that follow.
- It is scoped to exactly one call site. The firmware build's own `&`
  invocation is left exactly as it was, since it has never failed to
  launch in any of the 6 real CI attempts across this investigation —
  changing it would have been an unnecessary, unjustified expansion of
  scope.
- `tools/phase2a_validate.ps1` is a shared script also used by
  `phase2a-windows-validation.yml`, `phase2b-windows-validation.yml`, and
  `phase2c-windows-validation.yml`. This change does not alter any
  Phase 2A/2B/2C classification behavior, pass/fail threshold, or gate —
  it only makes the `updater_package` call site of `-Mode Build` more
  robust and more observable, for every phase's workflow equally. No
  Phase 2A/2B/2C validator config file (`tools/phase2a_validate_config.json`,
  `tools/phase2b_validate_config.json`, `tools/phase2c_validate_config.json`)
  was touched.

### 2. `.github/workflows/phase2d-windows-validation.yml` — documentation only

Added a header comment documenting the Phase 2D.2A remediation and
pointing to this log and the blocker analysis doc. No step, trigger,
permission, or job definition was changed — the workflow's actual
behavior is unchanged by this file; the real change is entirely in
`tools/phase2a_validate.ps1` above.

## Validation performed before pushing

- `[System.Management.Automation.Language.Parser]::ParseFile()` against
  `tools/phase2a_validate.ps1` — **0 syntax errors**.
- `python3 -c "import yaml; yaml.safe_load(...)"` against
  `.github/workflows/phase2d-windows-validation.yml` — **parses
  correctly**.
- Local `-Mode Static` run via `pwsh` against the modified script —
  **`PASS_WITH_REVIEWED_FALSE_POSITIVES`**, identical to every prior
  local Static run in this project; confirms the script's Static-mode
  code path (which the Build-mode edit sits alongside, not inside) is
  unaffected.
- `grep` confirmed zero `HardwareAssisted` invocations and zero flash
  commands anywhere in the modified workflow or script.

## Command-launch method chosen (summary)

`cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0 updater_package"` — narrowest
available option, same build target and arguments, only the
process-launch mechanism changed, scoped to one call site only.

## Validation results after pushing (real CI)

| Attempt | Run/attempt ID | Result |
|---|---|---|
| Post-fix, 1st | `28938933924` attempt 1 | **PASS** — firmware.dfu 862,825 bytes; updater `.tgz` 2,784,400 bytes; all 13 `.fap` present; `.fap` artifact upload succeeded; real diagnostics captured (145.14 GB free disk, Windows Defender real-time protection disabled, `fbt.cmd` present/822 bytes/valid) |
| Post-fix, 2nd (independent confirmation) | `28938933924` attempt 2 (triggered via `rerun_workflow_run`, executed on a different runner instance, `1000000202` vs. `1000000201`) | **PASS** — firmware.dfu 862,825 bytes (identical); updater `.tgz` 2,783,411 bytes; all 13 `.fap` present; `.fap` artifact upload succeeded; same diagnostics profile (145.14 GB free disk, Defender disabled) |

## Artifact upload status

`.fap` artifact upload (the separate tooling fix from Phase 2D.2,
`include-hidden-files: true`) continued to work correctly in both
post-fix attempts — `phase2d-fap-artifacts` produced in each. Firmware
and updater-package artifacts (`phase2d-firmware-artifacts`) and
validation reports (`phase2d-validation-reports`) also uploaded
successfully in both attempts.

## Final result

**2 of 2 real, independent post-fix CI attempts passed in full**,
including `updater_package`, on 2 different GitHub-hosted runner
instances. Combined with the pre-fix history (2 of 4 real attempts also
passed, establishing the failure was intermittent, not deterministic),
this phase's decision rule classifies the outcome as:

**UPDATER_PACKAGE CI BLOCKER RESOLVED WITH INTERMITTENT PRE-FIX FAILURE
NOTE.**

This is not a claim that the `cmd /c` change is statistically proven to
be causal (see the epistemic-honesty section of
`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`) — it is a
statement that: the fix is real, narrow, and safe; both post-fix runs
passed; no app or firmware source changed; and the project's own
decision framework for this investigation calls for this classification
given the evidence actually collected.

## What did not change

- **App source**: unchanged. `applications_user/resistors/`,
  `applications_user/crypto_dictionary/`, `applications_user/2048/` are
  byte-identical to their Phase 2D.2 import commits.
- **Firmware/core source**: unchanged. `applications/`, `lib/`, `assets/`
  (the base firmware) were not touched at any point in this
  investigation.
- **Hardware testing**: **NOT PERFORMED.** No `-Mode HardwareAssisted`
  invocation exists anywhere in the workflow or script changes. No
  device, no flash.
- **Release status**: remains **TEST-READY ONLY / NOT RELEASE-READY.**

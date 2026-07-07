# Phase 2A.12 — Hardware-Assisted Validation Results

Docs only. This records what actually happened when
`tools/phase2a_hardware_gate.ps1` was executed in this phase, in the
environment it was executed in — nothing is inferred, extrapolated, or
assumed beyond what each run actually reported.

## Execution environment

| Field | Value |
|---|---|
| Environment | Cloud AI session sandbox (Linux container), not a Windows machine |
| PowerShell | PowerShell 7.6.3 (`pwsh`), confirmed present and used for every run below |
| Physical Flipper Zero connected | **No** — this environment has no USB device access at all |
| qFlipper installed | **No** — not installed in this environment |
| Repo state at time of runs | Branch `integration/phase2a-first-batch`, HEAD `80f429bc7385975e9c1f30bf0e116dc5653b236a` (one commit ahead of the accepted CI baseline `718eec5fe115c9e0467a8d07d974947a85b27cf6`, because this phase's own new files were being authored on top of it — working tree was not yet committed at run time) |

This is the same structural limitation documented since Phase 0: this
project has no access to a Windows machine or a physical Flipper Zero in
any AI session's execution environment. That has not changed in Phase
2A.12. What has changed is that `tools/phase2a_hardware_gate.ps1` now exists
to run the automatable parts of hardware-assisted validation on a real
Windows machine with a real device, whenever one becomes available.

## Runs actually performed in this phase

All six runs below were executed for real, via `pwsh`, in this sandbox, on
**2026-07-07** (UTC timestamps as embedded in each run's own generated
report). These are genuine executions of the finished script — not a
description of intended behavior.

### 1. `-Mode Preflight`

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode Preflight`
Timestamp: `2026-07-07T11:56:04Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115604.{json,md}`

| Check | Status | Detail |
|---|---|---|
| Branch verification | PASS | On `integration/phase2a-first-batch` |
| Commit verification | NEEDS_REVIEW | HEAD `80f429b...` vs accepted baseline `718eec5...` — expected, since this phase's own new files were uncommitted work on top of the baseline |
| Git status (clean tree) | NEEDS_REVIEW | Uncommitted changes present — expected, same reason |
| Accepted baseline reference | PASS | CI run `28814008347`, finalization run `28859929957` |
| Artifact hash verification | NOT_RUN | Mode does not request it |
| Device detection / tooling / flash gate | NOT_RUN | Mode does not request them |
| GUI-level app checks | NOT_RUN | Only enumerated in `HardwareAssisted` mode |

**Classification: `NEEDS REVIEW`** (exit code 2) — expected and correct for
a Preflight run against an uncommitted working tree.

### 2. `-Mode HashVerify` (no `-ArtifactDir`)

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode HashVerify`
Timestamp: `2026-07-07T11:56:10Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115610.{json,md}`

Artifact hash verification correctly reported `NOT_RUN` ("no
`-ArtifactDir` supplied") rather than being skipped silently or assumed
passing. All hardware-connected and human-observed checks `NOT_RUN` (mode
does not request them). **Classification: `NEEDS REVIEW`** (same branch/
commit/status findings as run 1).

### 3. `-Mode HashVerify` against synthetic (non-real) artifact files

To confirm the hash-comparison logic itself actually works — rather than
trusting it by inspection — two synthetic files of the exact expected
sizes (862,825 and 2,733,074 bytes, filled with random data, generated
locally and never committed to the repository) were pointed at with
`-ArtifactDir`.

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode HashVerify -ArtifactDir <synthetic-dir>`
Timestamp: `2026-07-07T11:56:24Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115624.{json,md}`

| File | Result |
|---|---|
| `firmware.dfu` (synthetic) | **FAIL** — size matched (862,825 bytes) but SHA-256 did not match the accepted baseline's real hash; script explicitly reported "Do not proceed to a flash with this artifact." |
| `flipper-z-f7-update-local.tgz` (synthetic) | **FAIL** — same outcome, size matched but hash did not |

This confirms the script correctly rejects an artifact that merely has the
right size but is not byte-for-byte identical to the accepted baseline —
it does not pass on size alone. **Classification: `HARDWARE VALIDATION
FAILED`.** The synthetic files were deleted immediately after this test
and were never part of any commit; **no real firmware.dfu or updater
package was downloaded or hashed in this phase**, because this sandbox
cannot reach GitHub Actions artifact storage (same network-egress block
documented since Phase 2A.10). Real hash verification against the actual
accepted-baseline artifacts still requires a human running this gate on a
machine that can download them from run `28814008347`.

### 4. `-Mode DetectDevice`

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode DetectDevice`
Timestamp: `2026-07-07T11:56:14Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115614.{json,md}`

| Check | Status | Detail |
|---|---|---|
| Flipper Zero detection | BLOCKED | `Get-PnpDevice` is not available — this cmdlet requires Windows, and this sandbox is Linux |
| qFlipper detection | BLOCKED | Not found via PATH, common install directories, or Windows uninstall registry (also expected — this is Linux) |

**Classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.**
This is the accurate, honest result for this environment — not a
simulated pass, not a skipped check.

### 5. `-Mode HardwareAssisted` (no `-ArtifactDir`, no `-AllowFlashPrompt`)

This is the run that reflects this phase's actual real-world outcome most
completely — every check the finished tool is capable of running, in the
actual environment this phase was executed in.

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode HardwareAssisted`
Timestamp: `2026-07-07T11:56:15Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115615.{json,md}`

| Check | Status |
|---|---|
| Branch verification | PASS |
| Commit verification | NEEDS_REVIEW (uncommitted work at run time) |
| Git status | NEEDS_REVIEW (uncommitted work at run time) |
| Accepted baseline reference | PASS |
| Artifact hash verification (both files) | NOT_RUN (no `-ArtifactDir` supplied) |
| Flipper Zero detection | BLOCKED (non-Windows, no device) |
| qFlipper detection | BLOCKED (not installed) |
| Flash confirmation gate | NOT_RUN — `-AllowFlashPrompt` was not passed; explicitly logged as "This run is strictly read-only - no flash prompt was shown, nothing was written to any device." |
| App menu/launch/navigation check (all 5 apps) | REQUIRES_HUMAN_OBSERVATION, each pointing to the matching section of `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` |
| Chess save/load private-path check | REQUIRES_HUMAN_OBSERVATION |
| No crash/reboot/freeze during use | REQUIRES_HUMAN_OBSERVATION |
| No unexpected hardware activation | REQUIRES_HUMAN_OBSERVATION |

**Classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**
(exit code 2). No flash was attempted, offered, or confirmed. No GUI-level
check was performed or claimed — all are explicitly logged as requiring a
human.

### 6. `-Mode ReportOnly`

Command: `pwsh -File tools/phase2a_hardware_gate.ps1 -Mode ReportOnly`
Timestamp: `2026-07-07T11:56:16Z`
Report: `reports/phase2a_hardware/phase2a_hardware_gate_20260707_115616.{json,md}`

All hardware-connected and human-observed checks correctly `NOT_RUN` by
design (this mode never touches hardware or artifacts even if pointed at
them). **Classification: `NEEDS REVIEW`** (same branch/commit/status
findings as runs 1–2).

## Summary of what was and was not actually validated in this phase

| Item | Status |
|---|---|
| Hardware-assisted validation gate tool | **Built and exercised for real** (6 runs above), including one adversarial test proving its hash-mismatch detection actually works |
| Real accepted-baseline artifact hash verification (`firmware.dfu`, updater `.tgz`) | **NOT performed against the real files** — this sandbox cannot download them (same GitHub Actions artifact network block as Phase 2A.10); only a synthetic mismatch scenario was exercised, to prove the comparison logic itself is correct |
| Device detection | **NOT_RUN / BLOCKED** — no physical Flipper Zero, and `Get-PnpDevice` requires Windows, which this sandbox is not |
| qFlipper / official tooling detection | **BLOCKED** — not installed in this sandbox |
| Flashing | **NOT PERFORMED** — never attempted, never offered (`-AllowFlashPrompt` was never passed in any run against real hardware; the one existing flash-confirmation code path was never exercised) |
| GUI-level app smoke tests (visibility, launch, navigation, input, exit, storage path) | **NOT RUN / NOT OBSERVED** — every such check is logged as `REQUIRES_HUMAN_OBSERVATION`, pointing to `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md`; no human has executed that checklist on a real device |

## Final classification for this phase

**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**

This is the honest, actual output of the finished gate tool when run in
this phase's real execution environment — not a fabricated or optimistic
label. It means: the automatable checks this tool is capable of ran
correctly (and were proven correct, including under a deliberately
mismatching synthetic-artifact scenario), but no physical Flipper Zero and
no Windows machine were available in this environment, so the
hardware-connected checks could not proceed past that structural
limitation, and the human-observed GUI checks were never attempted.

## Status fields (verbatim, as required)

- Hardware-assisted validation: **RUN** in this sandbox (all non-hardware-
  dependent parts); hardware-connected parts **BLOCKED - DEVICE NOT
  AVAILABLE**.
- Device detection: **RUN, result BLOCKED** (non-Windows sandbox, no
  physical device).
- Artifact hash verification: **RUN** (synthetic-mismatch proof only); real
  accepted-baseline artifacts **NOT hash-verified in this phase** (network
  block, same as Phase 2A.10).
- Flashing: **NOT RUN. NOT PERFORMED.**
- GUI smoke test: **NOT RUN. NOT OBSERVED.**
- Hardware flashing/testing: **NOT PERFORMED.**
- Release status: **TEST-READY ONLY / NOT RELEASE-READY.**

## What would need to happen for a real result

A human with a Windows machine, a physical Flipper Zero, and qFlipper
installed would need to:

1. Download `firmware.dfu` and `flipper-z-f7-update-local.tgz` from CI run
   `28814008347` (or clone the repo at commit `718eec5fe115c9e0467a8d07d974947a85b27cf6`
   and build them locally).
2. Run `tools/phase2a_hardware_gate.ps1 -Mode HardwareAssisted -ArtifactDir <path>`
   and review the report.
3. If hashes verify `PASS` and a device and qFlipper are detected, decide
   whether to proceed to flashing (`-AllowFlashPrompt`, with the exact
   confirmation phrase from `tools/phase2a_hardware_gate_config.json`),
   after completing `docs/PHASE2A_FLASHING_PRECHECK.md` in full.
4. Complete `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real
   device and record results in
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.

Only after all of the above does hardware testing become complete, and
even then release-readiness still requires the project's full
release-gate checklist beyond Phase 2A alone.

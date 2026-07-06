# Phase 2A — Automated Validation Results

**v2 (Phase 2A.6).** v1 (Phase 2A.5) recorded a *manual reproduction* of the
validator's checks, since `tools/phase2a_validate.ps1` had not been executed
anywhere yet. This version records the script's **first real executions**,
the two genuine bugs those executions found and fixed, and a fresh Static +
Build snapshot from the fixed script.

## Critical caveat — where this was actually run

**This was executed in a cloud sandbox container, not on the project owner's
Windows machine.** This session has no access to
`C:\Github\Custom-Flipper-phase2a-build` or any other path on that machine —
it runs in an isolated, ephemeral Linux container. Phase 2A.6 asked for
execution "on the Windows local build environment"; that specific request
**was not fulfilled**, and this document does not claim otherwise.

What **was** done, and why it's still real progress: PowerShell 7.6.3 was
installed in this Linux sandbox (`packages.microsoft.com`'s official apt repo
was reachable, unlike the Flipper toolchain host) specifically so
`tools/phase2a_validate.ps1` could be **actually executed**, not just
manually reproduced, for the first time. This matters because the two bugs
found below are PowerShell-logic bugs, not OS-specific ones — they would have
crashed identically on the real Windows machine. Finding and fixing them here
means the script the project owner runs next on their own Windows machine is
already hardened against these two failure modes, rather than crashing there
for the first time.

**The project owner still needs to run this tooling on the real Windows
machine** for a Build-mode result that means anything (this sandbox cannot
build at all — see below) and, separately, for any Hardware-Assisted run.

## Validator bugs found and fixed (commit `ff4ba63`)

### Bug 1 — crash on the clean/successful path (`$null.Count`)

Several checks assigned the result of a `Where-Object`/`Group-Object`
pipeline directly to a variable, then read `.Count` on it. Under
`Set-StrictMode -Version Latest` (which this script sets), a pipeline that
matches **zero** items produces `$null`, not an empty array — and
`$null.Count` throws `"The property 'Count' cannot be found on this
object."` rather than returning `0`.

This crashed the script outright the first time it was actually run, and it
crashed on exactly the scenario that should be the common, successful case:
zero uninitialized submodules, zero duplicate app IDs, and — critically — the
final overall-classification step, which counts `FAIL`/`BLOCKED`/
`NEEDS_REVIEW` entries and would hit the same crash on a **fully clean run
with zero problems**. In other words: as originally written, the script
could never have produced a green `AUTOMATED VALIDATION PASS` at all — it
would have crashed one step before printing that result.

Reproduced with a minimal standalone repro before touching the real script,
to confirm the exact mechanism:
```powershell
Set-StrictMode -Version Latest
$a = @(1,2,3) | Where-Object { $_ -gt 10 }   # zero matches -> $a is $null
$a.Count                                     # throws
```

**Fix**: wrapped every such assignment in `@(...)`, which guarantees an array
(possibly empty) so `.Count` is always valid. Confirmed the fix with the same
repro (`@(@(1,2,3) | Where-Object {...}).Count` returns `0` cleanly).

### Bug 2 — build-launch failure misclassified as a generic FAIL

A genuine "the build process could not even be started" condition (surfaced
in this sandbox because it's Linux and `fbt.cmd` is a Windows batch file —
an environment mismatch unrelated to the bug itself, but a real trigger for
the code path) was being reported as a plain `FAIL`, indistinguishable from
"the process launched and genuinely exited non-zero for a real reason." These
need different classifications: a launch failure says nothing about the
firmware; a non-zero exit after a real launch might.

**Fix**: the script now tracks launch success separately from exit code, and
reports `BLOCKED` (not `FAIL`) when the process could not be launched at all.
A knock-on fix: the artifact and `.fap`-output checks now report `NOT_RUN`
(not `FAIL`, and not a false `PASS` on a stale leftover file) whenever this
run's own build didn't succeed and `-SkipBuild` wasn't explicitly passed —
previously they would either wrongly `FAIL` ("file does not exist," as if
today's build should have produced it) or silently validate a stale artifact
from an unrelated earlier run instead of reporting on *this* run, which is
exactly the "not stale values" requirement this tooling is supposed to meet.

Both fixes are in commit `ff4ba63` on `integration/phase2a-first-batch`.
**No firmware or app source was touched by either fix** — both are entirely
within `tools/phase2a_validate.ps1`.

## Static validation — run against commit `ff4ba635fda0bf3e0e54188ba6da51335cd924f6`

Exact command:
```powershell
pwsh -File ./tools/phase2a_validate.ps1 -Mode Static -ExpectedCommit ff4ba635fda0bf3e0e54188ba6da51335cd924f6 -ReportDir ./reports/phase2a
```
(`pwsh` used here since this is the Linux sandbox; on the real Windows
machine, use `powershell -ExecutionPolicy Bypass -File .\tools\phase2a_validate.ps1 ...`
as originally specified.)

| Check | Result |
|---|---|
| Branch verification | PASS — `integration/phase2a-first-batch` |
| Commit verification | PASS — HEAD matches `ff4ba635fda0bf3e0e54188ba6da51335cd924f6` |
| Git status before | PASS — clean |
| Submodule initialization | PASS — all 16 (12 top-level + 4 nested) initialized and pinned |
| Phase 2A app directories present | PASS — all 5 |
| Application manifests valid | PASS — all 5 `application.fam` parse, appids confirmed |
| App ID uniqueness (within batch) | PASS |
| App ID collision vs base `applications/` | PASS — zero collisions |
| SAM removal verification (chess) | PASS — zero matches for `sam`/`stm32_sam`/`flipchess_voice`/`speech`/`voice` |
| Risky keyword scan (Phase 2A app dirs only) | NEEDS_REVIEW — 104 substring matches, all manually reviewed and confirmed benign (see breakdown below, unchanged from Phase 2A.5's findings) |
| Git status after | PASS — unchanged by the run |

**Exit code: 2** (`NEEDS REVIEW`, per the script's own exit-code convention:
0=PASS, 1=FAILED, 2=NEEDS REVIEW). This is correct, not a bug: the run is
clean except for the one broad substring scan, which is reviewed below.

### Risky keyword scan — unchanged breakdown

Same 104 matches, same disposition as recorded in the Phase 2A.5 results
(re-confirmed against this commit): **zero** matches for any of the 8 real
Flipper HAL/capability APIs (`furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`); 102 matches for
`ble` (all confirmed substrings of benign words — `possible`, `variable`,
`double`, `available`, `enabled`, `disable`, `table`); 2 matches for `jam`
(both the VIN-decoder manufacturer code `"JAM"` = Isuzu, not the word "jam").

**Static classification: NEEDS_REVIEW → confirmed benign on review → treat as
PASS for gating purposes.**

## Build validation — run against the same commit

Exact command:
```powershell
pwsh -File ./tools/phase2a_validate.ps1 -Mode Build -ExpectedCommit ff4ba635fda0bf3e0e54188ba6da51335cd924f6 -ReportDir ./reports/phase2a
```

| Check | Result |
|---|---|
| Firmware build (`.\fbt.cmd COMPACT=1 DEBUG=0`) | **BLOCKED** — `fbt.cmd` could not be launched as a process in this sandbox (it's a Windows batch file; this sandbox is Linux). Full exception in `reports/phase2a/build_firmware_*.log`. |
| Updater package build | NOT_RUN — skipped because the firmware build didn't succeed |
| `build\f7-firmware-C\firmware.dfu` | NOT_RUN — not checked, since this run's own build didn't succeed (see the fix in Bug 2 above: this correctly avoids reporting on a stale/nonexistent artifact as if it were this run's result) |
| `dist\f7-C\flipper-z-f7-update-local.tgz` | NOT_RUN — same reason |
| Per-app `.fap` output verification | NOT_RUN — same reason |
| Git status after | PASS — recorded; no `build/`/`dist/` directories were created (confirmed: `ls build dist` → both "No such file or directory") |

**Exit code: 2** (`NEEDS REVIEW` — BLOCKED, not FAILED, correctly reflects
"this environment can't run the build," not "the build ran and broke").

**This BLOCKED result is an environment limitation of this cloud sandbox, not
a finding about the Phase 2A apps or the firmware.** It is architecturally the
same category of limitation already documented throughout this project (the
sandbox's network policy separately blocks the real toolchain host with a
403) — this run happened to hit a more basic limitation first (this sandbox
cannot execute a Windows batch file at all), but the conclusion is identical:
**a real Build-mode result requires the Windows machine.**

**A real, independent Build PASS already exists for this branch** from the
project owner's own local Windows build (see `PHASE2A_BUILD_REPORT.md`):
commit `5e5e0ecf225be947a754e537670a6421838b939b`,
`build\f7-firmware-C\firmware.dfu` (862,825 bytes) and
`dist\f7-C\flipper-z-f7-update-local.tgz` (2,732,909 bytes) both present, both
`fbt.cmd` invocations PASS. **This tooling has not yet reproduced that result
itself** — running the now-fixed `tools/phase2a_validate.ps1 -Mode Build` on
that same Windows machine, against the current tip, is the natural next step.

## Hardware-assisted validation: **NOT RUN**

Per explicit instruction for this phase, `-Mode HardwareAssisted` was **not
invoked** at all in this round — not even inertly. (It would have been
inert regardless: no physical Flipper Zero is connected to this sandbox, and
`Get-PnpDevice` is Windows-only, so the device-detection path could not have
done anything here.) A static code-review pass was performed over that
section of the script instead, checking specifically for the same
null-array-`.Count` bug class found and fixed above — no further instances
were found in the `HardwareAssisted` code path; the two other places that
read `.Count` there (inside `Get-TrackClassification`) are already guarded by
a `-not $Entries -or` short-circuit that avoids the crash. This review is not
a substitute for actually running the mode.

**Hardware-assisted classification: NOT RUN.**

## Final classification

| Track | Classification |
|---|---|
| Static | **NEEDS_REVIEW → reviewed, confirmed benign → PASS for gating purposes** |
| Build | **BLOCKED** (this sandbox cannot run a build at all; a real Windows-machine run is still needed to reproduce/confirm the existing manual Build PASS through this tooling) |
| Hardware-assisted | **NOT RUN** (not attempted, per explicit instruction for this phase) |
| **Overall** | **NEEDS REVIEW** |

This is the honest label, not `AUTOMATED VALIDATION PASS` — Static is clean
after review, but Build is BLOCKED in the only environment this session had
access to, and Hardware-assisted was deliberately not attempted. Nothing here
indicates a problem with the Phase 2A apps themselves; everything found and
fixed this round was in the validation tooling.

## Report artifacts (this run)

Generated under `reports/phase2a/` (gitignored — see `.gitignore`; not
committed, per this project's policy of not committing generated/regenerable
output alongside `build/`/`dist/`):
- `phase2a_validation_20260706_122332.json` / `.md` (Static)
- `phase2a_validation_20260706_122337.json` / `.md` (Build)
- `build_firmware_20260706_122337.log` (the launch-exception detail for the
  BLOCKED build check)

These are local to this sandbox session and will not persist; they are
described here for the record, not attached as committed artifacts.

## What this round establishes and does not

**Establishes:**
- `tools/phase2a_validate.ps1` now runs to completion without crashing, in
  both Static and Build modes, including on the "everything is clean" path
  that previously crashed.
- The repository's static state remains exactly as previously documented
  (re-confirmed independently, for the second time, via this tooling).
- Build-mode's failure classification now correctly distinguishes an
  environment problem from a real build problem.

**Does not establish:**
- That a real build succeeds anywhere except the project owner's own,
  separately-verified Windows machine (unchanged from before).
- Anything about hardware or GUI-level app behavior.
- That the script has been exercised on Windows itself, or under
  Windows PowerShell 5.1 specifically (only PowerShell 7.6.3 on Linux was
  used here) — the project owner's first Windows run remains the real
  confirmation this tooling was written for.

**Hardware flashing/testing status: NOT PERFORMED.** **Release status:
TEST-READY ONLY / NOT RELEASE-READY.** Unchanged by this round.

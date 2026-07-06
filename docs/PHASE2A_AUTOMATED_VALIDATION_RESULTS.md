# Phase 2A — Automated Validation Results

**v3 (Phase 2A.8) — CI hardening after the first real Windows GitHub Actions
run.** See the "Phase 2A.8" section immediately below for the current state.
v2 (Phase 2A.6, preserved further down this document) recorded the script's
first real executions in the cloud sandbox and the two bugs found/fixed
then. v1 (Phase 2A.5) recorded a manual reproduction of the validator's
checks before it had been executed anywhere.

## Phase 2A.8 — first real Windows CI run, and the fix for its false failure

### The CI run

| Field | Value |
|---|---|
| Workflow | Phase 2A Windows Validation |
| Run ID | `28808570107` |
| Head SHA | `6920b4087afbbb0d0cfc50430e4aa4d541605fa2` |
| Workflow conclusion (as reported by GitHub Actions) | **failure** |
| Actual Windows Build result | **PASS** |
| Firmware artifact | `build\f7-firmware-C\firmware.dfu` — **862,825 bytes** |
| Updater artifact | `dist\f7-C\flipper-z-f7-update-local.tgz` — **2,732,904 bytes** |
| Per-app FAP verification | PASS (all 5: `network_subnet`, `programmercalc`, `vin_decoder`, `flipper95`, `chess`) |
| SAM removal verification | PASS |
| Hardware-assisted validation | NOT RUN |
| Hardware testing | NOT PERFORMED |
| Release status | TEST-READY ONLY / NOT RELEASE-READY |

Note the updater artifact size, **2,732,904 bytes**, is 5 bytes smaller than
the previously-recorded manual-build size of 2,732,909 bytes from commit
`5e5e0ecf225be947a754e537670a6421838b939b`. This is expected, not a defect:
the two commits are different (this CI run built a later commit,
`6920b408...`, with additional docs/tooling commits on top — the updater
package embeds a changelog/version string derived from git metadata, and a
few-byte difference between two different commits' packages is normal. The
validator's own size check only flags a difference as `NEEDS_REVIEW` when
sizes differ **at the exact same commit** a known-good size was recorded
against — this is a different commit, so no discrepancy is flagged.

### Root cause of the "failure" (not a firmware/app defect)

The workflow's overall exit code was non-zero because **Static mode's
risky-keyword scan** found its now-familiar **104 substring matches** (102
`ble`, 2 `jam` — the same matches manually reviewed and confirmed benign back
in Phase 2A.5/2A.6) and, before this round, had **no mechanism to record that
prior review** — every run, forever, would re-report `NEEDS_REVIEW` (exit 2)
for these exact same 104 already-known-benign matches, regardless of how many
times they'd been looked at. This is a **CI policy/validator gap**, not a
build failure, not a hardware-test result, and not a release-readiness claim:

- **Not** a confirmed firmware/app build failure — the Windows build actually
  passed, artifacts exist, sizes are sane.
- **Not** a hardware-test pass — hardware-assisted validation was correctly
  NOT RUN, as designed.
- **Not** release-ready — that status is unchanged regardless of this fix.

### The fix

Implemented in commit `8d21138` on `integration/phase2a-first-batch`
(`tools/` only — no firmware/app source touched):

- **`tools/phase2a_validate_config.json`**: added a `reviewedFalsePositives`
  array with **104 entries** — one per exact previously-confirmed-benign
  match, each keyed on **file path + line number + keyword + SHA-256 hash of
  the exact trimmed line text**, plus the specific benign word/token that
  caused the match and a human-readable reason. This is deliberately not a
  blanket suppression: editing, moving, or renaming a matched line changes
  its hash and the match reverts to unreviewed automatically. Also added
  `highConfidenceUnsafeKeywords` — a 15-keyword subset of
  `forbiddenRiskyKeywords` (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
  `furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
  `furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
  `deauth`, `jam`, `brute`, `credential`, `token`, `exfil`) where an
  **unreviewed** match hard-**FAIL**s the whole run rather than merely
  needing review. Only 2 entries in the allowlist cover a high-confidence
  keyword (both `jam` — a VIN manufacturer code and a surname, individually
  justified); the other 14 high-confidence keywords have zero reviewed
  entries, so any future match against them fails hard until individually
  reviewed and justified with the same evidence bar. `ble` and `password`
  remain in the generic (lower-severity, `NEEDS_REVIEW`-on-unreviewed) tier.
- **`tools/phase2a_validate.ps1`**: the scan now checks every live match
  against the allowlist by exact (file, line, keyword, freshly-computed line
  hash) match. Three-way outcome, most severe first: any unreviewed
  high-confidence match → **FAIL**; any other unreviewed match →
  **NEEDS_REVIEW** (unchanged from before); every match accounted for by a
  reviewed entry → new **`PASS_WITH_REVIEWED_FALSE_POSITIVES`** status (rolls
  up as a pass for the overall exit code, 0); zero matches at all → plain
  **PASS** (unchanged).

### Verification performed before committing (this cloud sandbox, PowerShell 7.6.3)

- **Positive case**: re-ran `-Mode Static` against the current tree after
  adding the allowlist — all 104 live matches resolved to
  `PASS_WITH_REVIEWED_FALSE_POSITIVES`, zero unreviewed, zero
  high-confidence-unreviewed. Confirms the SHA-256 hashes computed in Python
  (at config-authoring time) and in PowerShell (at scan time, via
  `[System.Security.Cryptography.SHA256]`) agree exactly, byte-for-byte.
- **Negative case** (to prove the mechanism actually enforces something,
  not just that it passes when everything lines up): temporarily corrupted
  one high-confidence (`jam`) entry's stored hash in a scratch copy of the
  config, re-ran Static mode, confirmed it correctly reported `FAIL` (exit
  code 1) — "1 UNREVIEWED high-confidence unsafe API/capability match(es)
  found" — then restored the real config file via `git checkout` before
  committing anything. This confirms an edited/mismatched line genuinely
  reverts to unreviewed and fails, rather than the allowlist silently
  covering anything with a matching keyword.
- Re-ran `-Mode Build`: unchanged `BLOCKED` behavior (this sandbox still
  cannot execute `fbt.cmd` at all, being Linux — unrelated to this change,
  same limitation as every prior round).
- Confirmed via `git status --short` / `git diff --stat` that only
  `tools/phase2a_validate.ps1` and `tools/phase2a_validate_config.json`
  changed before committing the validator fix.

### What this does and does not change

- **Does not weaken detection of real risk.** All 8 original
  `furi_hal_*`/`badusb`/`deauth` capability keywords, plus `brute`,
  `credential`, `token`, `exfil`, remain hard-FAIL-on-unreviewed. Zero
  reviewed entries exist for any of them — a real future match against any
  of the 5 Phase 2A apps would still fail CI immediately, exactly as before.
- **Does not touch firmware or app source.** Confirmed: this round's entire
  diff is `tools/phase2a_validate.ps1` + `tools/phase2a_validate_config.json`
  (validator commit) plus documentation (this commit and others below).
- **Does not claim hardware testing or release-readiness.** Both remain
  exactly as before this round.

**Static classification (this fix, re-verified): PASS_WITH_REVIEWED_FALSE_POSITIVES.
Build classification (this sandbox): BLOCKED (environment limitation,
unrelated). Overall (this sandbox): AUTOMATED VALIDATION PASS** once
Static's one review item is accounted for and nothing else is outstanding —
confirmed by a clean local re-run at commit `8d21138` (exit code 0). **The
next real CI run on `integration/phase2a-first-batch` (via GitHub Actions,
automatically on push, or manually via the Actions tab) is expected to reach
a green Static step and a real Windows Build PASS in the same run** — this
has not been re-confirmed via an actual new GitHub Actions run as of this
document; that is the next concrete step.

---

## Phase 2A.6 (preserved from v2)

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

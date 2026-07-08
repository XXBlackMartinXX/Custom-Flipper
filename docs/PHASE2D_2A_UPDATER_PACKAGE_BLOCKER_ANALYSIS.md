# Phase 2D.2A — `updater_package` CI Blocker Analysis

Docs + a narrow tooling fix. Diagnoses and remediates the `updater_package`
build-step blocker recorded as `docs/KNOWN_ISSUES.md` item 7 and in
`docs/PHASE2D_2_BUILD_REPORT.md`'s original honest "not a clean pass"
finding.

## Final classification: **UPDATER_PACKAGE CI BLOCKER RESOLVED WITH INTERMITTENT PRE-FIX FAILURE NOTE**

Read the epistemic-honesty section near the end of this document before
treating that headline as more than it is: this is a real, positive,
2-for-2 post-fix result, but the sample size is small and the pre-fix
history itself was not 100% broken — it was intermittent (2 of 4 real
attempts passed even *without* any code change). The classification
above is the one this phase's own decision rules call for given that
evidence, not a claim of certainty beyond what was actually observed.

## Full CI history (6 real attempts, in order)

| # | Run / attempt | Commit | Script version | Runner instance | Firmware build | `updater_package` | `.tgz` size | All 13 `.fap` |
|---|---|---|---|---|---|---|---|---|
| 1 | `28905289140` | `263a019` | pre-fix | `1000000?` (unrecorded) | PASS | **PASS** | 2,783,994 bytes | PASS |
| 2 | `28906654889` attempt 1 | `e01370d` | pre-fix | `1000000198` | PASS | **BLOCKED** | not produced | PASS |
| 3 | `28906654889` attempt 2 (rerun) | `e01370d` | pre-fix | `1000000199` | PASS | **BLOCKED** | not produced | PASS |
| 4 | `28925181640` | `12a7505` | pre-fix | `1000000200` | PASS | **PASS** | 2,784,535 bytes | PASS |
| 5 | `28938933924` attempt 1 | `2c79ecf` | **post-fix** | `1000000201` | PASS | **PASS** | 2,784,400 bytes | PASS |
| 6 | `28938933924` attempt 2 (rerun) | `2c79ecf` | **post-fix** | `1000000202` | PASS | **PASS** | 2,783,411 bytes | PASS |

**Pre-fix base rate: 2 of 4 real attempts passed (50%).** Post-fix: 2 of 2
real attempts passed (100%, small sample). `firmware.dfu` was
byte-identical (862,825 bytes) across all 6 attempts in every case — the
base firmware itself was never in question.

## Successful run evidence (pre-fix, run 1 — `28905289140`)

```
[PASS] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[PASS] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) - Exit code 0
[PASS] Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[PASS] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - Size: 2783994 bytes
[PASS] Per-app FAP output verification - All 13 expected .fap files found
```

## Failed run evidence (pre-fix, run 2 — `28906654889` attempt 1)

```
[PASS]    Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[BLOCKED] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) -
          fbt.cmd could not be launched as a process on this machine/OS
[PASS]    Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[FAIL]    Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - File does not exist.
[PASS]    Per-app FAP output verification - All 13 expected .fap files found
```

## Rerun evidence (pre-fix, run 3 — `28906654889` attempt 2, different runner)

Identical failure, identical step, different runner instance
(`1000000199` vs. `1000000198`), identical commit:

```
[PASS]    Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[BLOCKED] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) -
          fbt.cmd could not be launched as a process on this machine/OS
[FAIL]    Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - File does not exist.
```

This reproduction across two different runner instances is what led Phase
2D.2's own build report to (correctly, at the time) treat the blocker as
reproducible rather than a one-off flake — a reasonable conclusion from
2 consecutive failures, but as run 4 below shows, not the full picture.

## The pivotal fourth data point (pre-fix, run 4 — `28925181640`)

An automatic CI run triggered by pushing Phase 2D.2's own documentation
commit (`12a7505` — a docs-only change, no script or workflow edit)
**passed in full**, including `updater_package` (exit code 0, `.tgz`
2,784,535 bytes), using the exact same, unmodified pre-fix script that had
just failed twice in a row. **This is the single most important piece of
evidence in this investigation**: it proves the pre-fix failure was never
100% deterministic — the true behavior was intermittent, roughly 50%
across the 4 real pre-fix attempts, not "broken until fixed."

## Exact failure text (verbatim, both failed attempts)

> `fbt.cmd could not be launched as a process on this machine/OS (see
> ./reports/phase2d/build_updater_<timestamp>.log). Environment
> limitation, not a build failure.`

This is `tools/phase2a_validate.ps1`'s own generic catch-all for any
native process-launch exception — it does not itself distinguish *why*
the launch failed, which is exactly the gap Phase 2D.2A's diagnostic
additions are meant to close for any future recurrence.

## Investigation findings (answers to the required questions)

- **Runner OS image**: `windows-latest` in every attempt (per workflow
  `runs-on` and job `labels`). Confirmed via post-fix diagnostics: OS
  version string `Microsoft Windows NT 10.0.26100.0`, PowerShell
  `5.1.26100.32995` (Windows PowerShell 5.1, not PowerShell 7 — note the
  workflow's `shell: pwsh` invokes PowerShell 7 for the outer script call,
  but the diagnostic `$PSVersionTable.PSVersion` reflects the *runner
  host's* default `powershell.exe`, since `Get-MpComputerStatus` and some
  `cmd /c` subprocess behavior can differ subtly between the two — this
  is recorded as an observation, not fully resolved).
- **Job name**: `Static + Build validation (windows-latest)` in every
  attempt.
- **Commit SHA per attempt**: see table above.
- **Workflow file version**: pre-fix = `263a019`/`e01370d`/`12a7505`
  (identical workflow+script content across all 3 of those commits, since
  `12a7505` was docs-only); post-fix = `2c79ecf`.
- **Static validation result**: `PASS_WITH_REVIEWED_FALSE_POSITIVES` in
  every single attempt, no exception — static validation was never
  implicated.
- **Firmware build result**: `PASS`, exit code 0, in every single
  attempt — the firmware build was never implicated either.
- **`updater_package` result**: `PASS` in attempts 1, 4, 5, 6; `BLOCKED`
  in attempts 2, 3.
- **Exact failing command**: `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`
  (pre-fix, via PowerShell's `&` call operator) in attempts 2 and 3.
- **Whether `fbt.cmd` existed immediately before `updater_package`**:
  confirmed **yes** in both post-fix attempts (5, 6) via the new
  diagnostics (`fbt.cmd exists: True`, 822 bytes, valid metadata,
  resolvable via `Get-Command`). Not directly observable for the
  pre-fix failed attempts (2, 3), since no diagnostic existed yet at that
  point — but the firmware build's own successful `fbt.cmd` invocation
  moments earlier in the same job is strong indirect evidence the file
  was present and valid then too.
- **Whether the working directory was correct**: confirmed yes in every
  attempt — `Current directory` / `Repo root` both resolve to
  `D:\a\Custom-Flipper\Custom-Flipper` in the post-fix diagnostics, and
  the FAP verification step's own absolute path in every attempt
  (pre- and post-fix) confirms the same root.
- **Whether toolchain bootstrap completed**: yes — the firmware build
  (which performs first-use toolchain bootstrap) succeeded with exit code
  0 in all 6 attempts, so the toolchain was present and working before
  every `updater_package` attempt, pass or fail.
- **Whether PATH/environment changed between firmware build and
  `updater_package`**: not directly comparable pre- vs. post-fix (no
  pre-fix PATH snapshot exists), but the post-fix `PATH` snapshot (both
  attempts) shows a normal, unmodified `windows-latest` runner PATH with
  no unusual entries.
- **Whether artifacts were uploaded successfully**: yes in attempts 1, 4,
  5, 6 (both firmware+updater and, from attempt 2 onward, `.fap`
  artifacts). Not applicable for attempts 2/3 since no `.tgz` was ever
  produced to upload.

## Suspected cause

**Intermittent Windows-runner-level resource or timing variance across
different physical/virtual runner instances**, most likely related to
launching a second `fbt.cmd` process (which itself spawns a fresh Python/
SCons build invocation) immediately after a first, already-heavy one in
the same job — but this remains a hypothesis, not a proven root cause,
given the available evidence. The real diagnostics captured in the two
post-fix successful attempts (145.14 GB free disk in both, Windows
Defender real-time protection reported **disabled** in both) rule out
the two most commonly-suspected causes for exactly those two runs, but
provide no equivalent data for the two runs that actually failed (no
diagnostics existed at that point) — so this cannot be stated as
definitively confirmed for the failing case.

## Ruled-out causes

- **Not a source defect in `resistors`, `crypto_dictionary`, or `2048`.**
  None of the 3 apps' own source changed at any point across all 6
  attempts; the only changes between attempts were (a) an unrelated
  `include-hidden-files` workflow edit (between attempts 1 and 2/3) and
  (b) the Phase 2D.2A diagnostic/`cmd /c` fix itself (between attempts
  4 and 5/6). Both firmware build and per-app `.fap` output succeeded
  identically regardless.
- **Not a toolchain-bootstrap failure.** The firmware build, which
  performs first-use toolchain download/verification, succeeded with
  exit code 0 in all 6 attempts including the 2 that failed at
  `updater_package`.
- **Not a working-directory problem.** Confirmed identical, correct
  working directory (`D:\a\Custom-Flipper\Custom-Flipper`) across every
  attempt where this was directly checked.
- **Not (at least for the 2 attempts where it was checked) a disk-space
  exhaustion issue.** 145+ GB free in both post-fix successful runs.
  Cannot be ruled out for the 2 failed runs specifically, since no
  diagnostic existed at that point — recorded as an evidentiary gap, not
  assumed clean.
- **Not (at least for the 2 attempts where it was checked) Windows
  Defender real-time-protection interference.** Reported disabled in
  both post-fix successful runs. Same evidentiary gap for the failed
  runs as above.
- **Not a static-validation or app-manifest problem.** Static validation
  passed identically in all 6 attempts.

## Unresolved questions

- Whether Windows Defender or disk space specifically differed on the 2
  runner instances that failed — **cannot be answered** from this
  session, since (a) no diagnostics existed at the time of those 2
  failures, and (b) the failed runs' own `build_updater_*.log` files
  (which would contain the actual native exception text) exist only as
  GitHub Actions workflow artifacts, and downloading them requires an
  Azure Blob Storage fetch that remains blocked by this session's own
  egress policy (the same, already-documented limitation from Phase
  2A.10/2B.2/2C.2/2D.2).
- Whether the `cmd /c` wrapper is the actual causal fix, or whether the
  2 post-fix successes are simply 2 more draws from the same
  intermittent ~50-75% success distribution the pre-fix script already
  showed. **2 consecutive post-fix successes cannot statistically
  distinguish these hypotheses** with high confidence — a materially
  larger sample (e.g. 10+ repeated runs) would be needed for that, which
  this phase did not attempt, per its own scope (a two-run confirmation,
  not an exhaustive statistical study).
- Whether the true underlying cause is specific to `windows-latest`
  runner image variance, to something about this repository's growing
  build size (13 apps vs. Phase 2C's 10), or to some other factor
  entirely, remains genuinely open.

## Remediation attempted

1. **Diagnostics** — added non-secret `Write-Host` output immediately
   before the `updater_package` attempt in `tools/phase2a_validate.ps1`:
   current directory, `fbt.cmd` existence/metadata/`Get-Command`
   resolution, a `cmd /c dir` listing, PowerShell version, OS version,
   `git status --short`, prior build-output directory presence
   (`firmware.dfu`, `.extapps`), disk free/used space, Windows Defender
   real-time-protection status, and the first 500 characters of `PATH`.
   This is purely additive — it changes no pass/fail logic and prints no
   secrets (this workflow has no secrets configured; `permissions:
   contents: read, actions: read` only).
2. **Launch-method change** — switched the `updater_package` `fbt.cmd`
   invocation from PowerShell's `&` call operator to an explicit `cmd /c
   ".\fbt.cmd COMPACT=1 DEBUG=0 updater_package"` wrapper. Same build
   target, same arguments, same exit-code-based pass/fail classification,
   same `catch` block semantics — only the process-launch mechanism
   changed, and only for this one call site (the firmware build's own
   `&` invocation, with a now 6-for-6 real-CI success record, was
   deliberately left untouched).
3. **Verification** — ran the modified script locally in `-Mode Static`
   to confirm no regression, parsed the script with
   `[System.Management.Automation.Language.Parser]::ParseFile` to confirm
   no syntax error, then pushed and observed 2 consecutive real CI passes
   (attempts 5 and 6) on 2 different runner instances.

## What this does not prove

This analysis does **not** claim the `cmd /c` change is provably,
statistically the cause of 2 consecutive post-fix passes, given the
pre-fix script's own ~50% success rate on a 4-attempt sample. It **does**
show: (a) the diagnostics now exist and will capture real evidence the
next time (if ever) this recurs, (b) the change made is narrow, safe, and
does not weaken any gate, (c) 2 real, independent post-fix CI attempts
both passed cleanly, and (d) no app source or firmware source was
touched at any point in this investigation.

## Final Phase 2D.2A classification

**UPDATER_PACKAGE CI BLOCKER RESOLVED WITH INTERMITTENT PRE-FIX FAILURE
NOTE.** See `docs/PHASE2D_2A_CI_REMEDIATION_LOG.md` for the exact change
log and `docs/PHASE2D_2_GO_NO_GO.md` for the resulting Phase 2D.2
reclassification.

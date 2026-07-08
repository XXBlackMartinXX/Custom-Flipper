# Phase 2D.2 — Build Report

Docs only. Records the real local and CI build results for the Phase 2D
tiny batch (`resistors`, `crypto_dictionary`, `2048`) alongside the 10
already-accepted Phase 2A/2B/2C apps — 13 apps total. `fcc_id_lookup` is
not part of this batch or this report.

**This report's bottom line is a genuine, reproducible partial result,
not a clean pass**: the firmware itself, and all 13 apps' `.fap` outputs,
build correctly and consistently across every attempt. The separate
`updater_package` packaging step, however, failed to even launch as a
process on 2 of 3 real CI attempts — reproduced on two different
GitHub-hosted runner instances for the same commit. This is documented in
full below, honestly, rather than reported as a clean pass.

## Local build status: BUILD BLOCKED / ENVIRONMENT

Same, already-established root cause as every prior phase's cloud-sandbox
build attempt: `fbt.cmd` is a Windows batch file; this session's sandbox
is Linux, so it cannot be launched as a process here at all — confirmed
directly via `pwsh -File ./tools/phase2a_validate.ps1 -Mode Build
-ConfigPath ./tools/phase2d_validate_config.json`:

```
[BLOCKED     ] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)
             fbt.cmd could not be launched as a process on this machine/OS
             (see ./reports/phase2d/build_firmware_20260707_231419.log for
             the exact exception). This is an environment limitation, not
             a build failure or firmware defect.
```

## Local static validation: PASS (real, run via `pwsh` in this session)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    NOT_RUN
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

All 13 app directories present, all 13 `application.fam` files parse and
appid-match, all 13 appids unique with no collision against base
`applications/`, `chess`'s SAM removal still confirmed clean, submodules
initialized (16/16, after a fresh `git submodule update --init
--recursive` in this session's own working tree), and the risky-keyword
scan found all 189 substring matches accounted for by an
individually-reviewed entry (139 carried over from Phase 2C plus 50 new
for this batch) — zero unreviewed, zero high-confidence-unsafe.

## CI build status: three real attempts, honestly reported

`.github/workflows/phase2d-windows-validation.yml` ran automatically on
every push to `integration/phase2d-first-batch`, on real GitHub-hosted
`windows-latest` runners.

### Attempt 1 — Run `28905289140` (commit `263a019`): **PASS**

| Field | Value |
|---|---|
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28905289140 |
| Job ID | `85750925873` |
| Commit validated | `263a019a5b5dbe2213257481fdb21f220d073503` |
| Conclusion (via GitHub API) | **success** |
| Total run duration | `23:15:14`–`23:23:40Z` (~8.4 minutes) |

```
--- Build checks ---
[PASS] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[PASS] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) - Exit code 0
[PASS] Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[PASS] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - Size: 2783994 bytes
[PASS] Per-app FAP output verification - All 13 expected .fap files found in build\f7-firmware-C\.extapps

=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    PASS
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

**One real, separate tooling bug found on this run**: the workflow's
"Upload per-app .fap artifacts" step (a convenience upload, not part of
the validator's own pass/fail logic) logged `##[warning]No files were
found with the provided path: build/f7-firmware-C/.extapps/*.fap. No
artifacts will be uploaded.` — even though the validator's own,
independent "Per-app FAP output verification" check (quoted above) had
already confirmed all 13 `.fap` files present at that exact path.
Root-caused: `fbt`'s own FAP output directory is dot-prefixed
(`.extapps`), and `actions/upload-artifact@v4` excludes dot-prefixed
directories from its glob by default unless `include-hidden-files: true`
is explicitly set. This did not affect the validation result itself —
only the human-inspection artifact upload. Fixed in commit `e01370d`
by adding `include-hidden-files: true` to that one step.

### Attempt 2 — Run `28906654889`, first execution (commit `e01370d`): **FAILURE**

| Field | Value |
|---|---|
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28906654889 (attempt 1) |
| Job ID | `85755077690` |
| Commit validated | `e01370df389d13fb413ae04b8c196686784d9b48` |
| Conclusion (via GitHub API) | **failure** |
| Runner | GitHub Actions runner `1000000198` |
| Total run duration | `23:46:24`–`23:53:24Z` (~7 minutes) |

```
--- Build checks ---
[PASS]    Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[BLOCKED] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) -
          fbt.cmd could not be launched as a process on this machine/OS
[PASS]    Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[FAIL]    Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - File does not exist.
[PASS]    Per-app FAP output verification - All 13 expected .fap files found

=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    FAIL
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION FAILED
```

The `.fap` artifact-upload fix worked correctly this time (the
`phase2d-fap-artifacts` artifact was produced, 227,794 bytes) — but the
firmware build was followed by the `updater_package` sub-invocation of
`fbt.cmd` failing to even launch as a process, a different, new failure
from anything seen in Attempt 1. Since the exact same command had
succeeded moments earlier in this very run (firmware build) and in the
entirety of Attempt 1 (both firmware and updater), this was treated as a
candidate transient Windows-runner issue rather than assumed to be a real
regression — a `rerun_failed_jobs` was triggered on this same run to get
a second, independent data point before drawing a conclusion.

### Attempt 2 — Run `28906654889`, re-run (same commit `e01370d`): **FAILURE — reproduced**

| Field | Value |
|---|---|
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28906654889 (attempt 2) |
| Job ID | `85807631742` |
| Commit validated | `e01370df389d13fb413ae04b8c196686784d9b48` (identical to the failed attempt) |
| Conclusion (via GitHub API) | **failure** |
| Runner | GitHub Actions runner `1000000199` — a **different** runner instance from Attempt 2's first execution |
| Total run duration | `07:03:01`–`07:08:16Z` (~5.25 minutes) |

```
--- Build checks ---
[PASS]    Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[BLOCKED] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) -
          fbt.cmd could not be launched as a process on this machine/OS
[PASS]    Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[FAIL]    Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - File does not exist.
[PASS]    Per-app FAP output verification - All 13 expected .fap files found

=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    FAIL
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION FAILED
```

**This is the identical failure, at the identical step, on a different
runner instance, for the identical commit.** This is no longer treated as
a one-off transient blip — it is a real, currently-reproducible CI
blocker specific to the `updater_package` build sub-step, distinct from
the app source itself.

## What is confirmed, and what is not

**Confirmed, 3 for 3 attempts, on real Windows CI**:
- The firmware itself builds successfully (`firmware.dfu`, byte-identical
  862,825 bytes across all 3 attempts — the base firmware is unaffected
  by this batch, exactly as expected for externally-built FAPs).
- All 13 apps — the 10 already-accepted apps plus `resistors`,
  `crypto_dictionary`, and `2048` — compile and produce their expected
  `.fap` output (`resistance_calculator.fap`, `crypto_dict.fap`,
  `2048_improved.fap`, plus the 10 existing `.fap` files), confirmed both
  by the validator's own per-app check and (from Attempt 2 onward) by a
  successful `.fap` artifact upload for direct inspection.
- Static validation is clean (`PASS_WITH_REVIEWED_FALSE_POSITIVES`, zero
  unreviewed matches) on every attempt.

**Not yet confirmed — real, open, reproducible CI blocker**:
- The `updater_package` build target (`.\fbt.cmd COMPACT=1 DEBUG=0
  updater_package`) — which packages the built firmware and FAPs into the
  distributable updater `.tgz` — succeeded once (Attempt 1) and then
  failed to launch as a process twice in a row (Attempt 2's original
  execution and its re-run), on two different runner instances, for the
  same commit.
- **This is not evaluable as an app-source defect.** None of the 3 newly
  imported apps' own source changed between Attempt 1 (which produced a
  working updater package) and Attempt 2 (which did not) — the only
  change was a workflow-YAML edit to a later, unrelated artifact-upload
  step (`include-hidden-files: true`), which cannot plausibly affect
  whether `fbt.cmd`'s `updater_package` target can be launched as a
  process. The most likely explanation, based on the available evidence,
  is a Windows-runner-level resource constraint (e.g. disk space or
  process/handle contention after a full firmware + 13-app build
  immediately followed by a second `fbt.cmd` invocation) that this
  project cannot fully diagnose without deeper log access — GitHub
  Actions artifact downloads (which would contain the actual captured
  `build_updater_*.log`) redirect to Azure Blob Storage, which remains
  blocked by this session's own egress policy (the same, already-documented
  limitation from Phase 2A.10/2B.2/2C.2). This is recorded as an honest
  evidentiary limit, not filled in with a guess.
- **No further re-run was attempted beyond this second, confirming
  attempt.** Per this phase's own instruction, a second failure at the
  same step is treated as reproducible, not transient, and this report
  stops here rather than continuing to retry.

## Artifacts

| Artifact | Attempt 1 | Attempt 2 (both executions) |
|---|---|---|
| `firmware.dfu` | 862,825 bytes — PASS | 862,825 bytes — PASS (identical) |
| `flipper-z-f7-update-local.tgz` | 2,783,994 bytes — PASS | **Not produced — FAIL** (file does not exist) |
| Per-app `.fap` outputs (13) | All present — PASS | All present — PASS (identical) |
| `.fap` artifact upload | Warned "no files found" (tooling bug, fixed) | Succeeded, 227,794 bytes uploaded |

All artifacts exist only as GitHub Actions workflow artifacts for their
respective runs — not committed to the repository.

## Failures/blocks

- **Local**: `BUILD BLOCKED / ENVIRONMENT` (Linux sandbox, `fbt.cmd` is a
  Windows batch file) — unchanged, established limitation.
- **CI**: `updater_package` build step is **reproducibly BLOCKED** as of
  this report (2 of 3 real attempts, 2 different runner instances, same
  commit). Firmware build and all 13 `.fap` outputs are **not** blocked
  and have passed on every attempt.

## Phase 2D.3 artifact hash finalization

Real SHA-256 hashes of the `firmware.dfu`/updater `.tgz` from run 28941093859 were finalized by the `Phase 2D Finalize Baseline` workflow (run [`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724)) - see `docs/PHASE2D_3_ARTIFACT_HASHES.md` for the values. Phase 2D.3 finalized this build's artifacts; nothing about the build result itself changed.

## Conclusion (as of this report's original writing)

**Firmware build and per-app `.fap` output: CONFIRMED PASS, 3 for 3.**
**Updater package build: BUILD BLOCKED / UPDATER_PACKAGE CI TOOLING,
reproducible 2 of 3 real CI attempts.** This is a CI/tooling-environment
finding, not evidence of a defect in `resistors`, `crypto_dictionary`, or
`2048`'s own source — but it is real, unresolved, and not glossed over.

---

## Phase 2D.2A update: diagnosis, remediation, and a pivotal 4th data point

**This section adds new evidence and a real remediation. The
above content is left unmodified as the historical record of what was
known at the time this report was first written; do not read this
section as retroactively editing it.**

A 4th real CI attempt, `28925181640` (an automatic run triggered by
pushing Phase 2D.2's own documentation commit `12a7505` — a docs-only
change, no script/workflow edit), **passed in full**, including
`updater_package` (exit code 0, `.tgz` 2,784,535 bytes), using the exact
same, unmodified script that had just failed twice in a row. **This
proves the original "reproducibly BLOCKED" framing above was an
understandable but incomplete conclusion from only 2 data points** — the
real, pre-fix behavior was intermittent (2 of 4 real attempts passed,
~50%), not a deterministic break.

Phase 2D.2A then applied a narrow remediation to
`tools/phase2a_validate.ps1`'s `updater_package` call site only (the
firmware build call site is untouched): added non-secret diagnostic
output (disk space, `fbt.cmd` metadata, PowerShell/OS version, Windows
Defender status, PATH) immediately before the attempt, and switched the
launch mechanism from PowerShell's `&` call operator to an explicit `cmd
/c` wrapper — same build target, same arguments, same pass/fail logic.
See `docs/PHASE2D_2A_CI_REMEDIATION_LOG.md` for the exact change and
`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md` for the full
investigation.

**Post-fix result: 2 of 2 real, independent CI attempts passed in full**,
on 2 different runner instances (`1000000201`, `1000000202`), both via
`rerun_workflow_run` for a genuine second confirmation rather than
accepting a single green run:

| Attempt | Firmware build | `updater_package` | `.tgz` size | All 13 `.fap` | `.fap` upload |
|---|---|---|---|---|---|
| Post-fix 1 (`28938933924` attempt 1) | PASS | **PASS** | 2,784,400 bytes | PASS | PASS |
| Post-fix 2 (`28938933924` attempt 2) | PASS | **PASS** | 2,783,411 bytes | PASS | PASS |

`firmware.dfu` remained byte-identical (862,825 bytes) in both. Real
diagnostics captured in both post-fix runs: 145.14 GB free disk, Windows
Defender real-time protection reported disabled, `fbt.cmd` present and
valid (822 bytes) — ruling out the two most commonly-suspected causes
for these two specific runs (though no equivalent diagnostic data exists
for the 2 runs that actually failed, since diagnostics did not exist at
that point — an honest evidentiary gap, not filled in with a guess).

### Updated conclusion (Phase 2D.2A supersedes the "reproducibly BLOCKED" framing above)

**Firmware build and per-app `.fap` output: CONFIRMED PASS, 6 for 6**
across the full CI history now on record. **Updater package build:
PASS in 4 of 6 real attempts overall (2 of 4 pre-fix, 2 of 2 post-fix)**,
BLOCKED in 2 (both pre-fix, same commit, 2 different runners).
Classification: **UPDATER_PACKAGE CI BLOCKER RESOLVED WITH INTERMITTENT
PRE-FIX FAILURE NOTE** — a real, narrow, verified fix, applied and
confirmed twice, but not a claim that the pre-fix intermittent failure
rate is statistically proven eliminated versus merely not re-observed in
2 more attempts. No app source changed. No firmware/core source changed
at any point in this investigation. Hardware testing remains **NOT
PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

See `docs/PHASE2D_2_GO_NO_GO.md` for the resulting Phase 2D.2
reclassification and next gate.

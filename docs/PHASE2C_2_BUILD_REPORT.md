# Phase 2C.2 — Build Report

Docs only. Records the real local and CI build results for the Phase 2C
tiny batch (`sd_info`, `docviewlite`) alongside the 8 already-accepted
Phase 2A/2B apps — 10 apps total. `fcc_id_lookup` is not part of this
batch or this report.

## Local build status: BUILD BLOCKED / ENVIRONMENT

A real local build was attempted in this session's cloud sandbox (Linux),
using `pwsh` and `tools/phase2a_validate.ps1 -Mode Build -ConfigPath
tools/phase2c_validate_config.json`. Result: **genuinely blocked, not
faked, not worked around** — the same root cause documented since Phase 0
and reconfirmed in every prior phase's own cloud-sandbox build attempt:

```
[BLOCKED] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)
          fbt.cmd could not be launched as a process on this machine/OS
          - this is an environment limitation, not a build failure or
          firmware defect.
```

`fbt.cmd` is a Windows batch file; this sandbox is Linux, so it cannot
even be launched as a process here — separate from whether the toolchain
download itself would be reachable. Static validation, by contrast, ran
cleanly in this same sandbox (see below), since it does not require
invoking `fbt.cmd` at all.

**Classification: BUILD BLOCKED / ENVIRONMENT.**

## Local static validation: PASS (real, run via `pwsh` in this session)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    NOT_RUN
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

All 10 app directories present, all 10 `application.fam` parse and
appid-match, all 10 appids unique with no collision against base
`applications/`, chess's SAM removal still confirmed clean, submodules
initialized (16/16), and the risky-keyword scan found all 139 substring
matches accounted for by an individually-reviewed entry — zero
unreviewed, zero high-confidence-unsafe.

## CI build status: PASS (real, verified via the GitHub API)

`.github/workflows/phase2c-windows-validation.yml` ran automatically on
push to `integration/phase2c-first-batch`, on a real GitHub-hosted
`windows-latest` runner. (An earlier run, `28897535133`, against the
prior infra commit `8cc20e2`, was auto-cancelled — not failed — by the
workflow's own `concurrency: cancel-in-progress: true` setting when a
second, closely-following docs commit was pushed to the same branch; this
is the workflow's own intended behavior, not an error.)

| Field | Value |
|---|---|
| Workflow | Phase 2C Windows Validation |
| Workflow run ID | `28897702247` |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28897702247 |
| Job ID | `85727429366` |
| Runner | GitHub-hosted `windows-latest` |
| Commit validated | `969054ee9f802f72be1064a62052c4be82a91783` |
| Job conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`) | **success** |
| Static validation duration | `20:55:55Z`–`20:56:00Z` (a few seconds) |
| Build validation duration | `20:56:00Z`–`21:02:49Z` (~6.8 minutes — consistent with a real `fbt.cmd` build including toolchain bootstrap on a fresh runner, comparable to Phase 2A's ~5-minute and Phase 2B's ~6.5-minute CI build durations) |

### Per-step confirmation (from the job's own real log, fetched via `get_job_logs`)

```
--- Static checks ---
[PASS] Branch verification - On expected branch 'integration/phase2c-first-batch'
[PASS] Commit verification - HEAD matches expected commit 969054ee9f802f72be1064a62052c4be82a91783
[PASS] Git status before (clean working tree)
[PASS] Submodule initialization - All 16 submodule(s) initialized and pinned as expected
[PASS] Phase 2A app directories present - All 10 app directories found
[PASS] Application manifests valid - All 10 application.fam files present and parse as expected
[PASS] App ID uniqueness (within Phase 2A batch) - All 10 appids are unique within this batch
[PASS] App ID collision check vs base applications/ - No Phase 2A appid collides with a base-firmware app
[PASS] SAM removal verification (chess) - Zero matches for sam/stm32_sam/flipchess_voice/speech/voice
[PASS_WITH_REVIEWED_FALSE_POSITIVES] Risky keyword scan - 139 substring match(es) found; all 139 matched an exact,
  individually-reviewed entry. Zero unreviewed matches, zero high-confidence-unsafe matches.

--- Build checks ---
[PASS] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[PASS] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) - Exit code 0
[PASS] Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[PASS] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - Size: 2757340 bytes
[PASS] Per-app FAP output verification - All 10 expected .fap files found in build\f7-firmware-C\.extapps
[NOT_RUN] Flipper Zero detection - Mode is 'Build' - HardwareAssisted was not requested.

=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    PASS
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

### Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** — identical to the Phase 2A/2B baseline's known-good size, confirming the base firmware itself is unchanged by this batch |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,757,340 bytes** — larger than the Phase 2B baseline's 2,742,659 bytes; expected, not a defect, for the same reason documented in every prior phase's build report: the updater package embeds the 2 additional compiled FAPs plus a commit-derived version string, so a size increase at a different, larger commit is normal |
| FAP outputs | `build\f7-firmware-C\.extapps\*.fap` | All 10 expected `.fap` files confirmed present (8 Phase 2A/2B + `sd_info.fap`, `docviewlite.fap`) |

Both artifacts exist only as GitHub Actions **workflow artifacts** for run
`28897702247` (`phase2c-firmware-artifacts`, `phase2c-validation-reports`)
— not committed to the repository. Attempting to download them directly
in this session would hit the same, already-documented network limitation
as Phase 2A.10/2B.2: GitHub Actions artifact downloads redirect to Azure
Blob Storage, blocked by this session's egress policy. This does not
affect the result above: the full per-step detail was retrieved instead
from the job's own real, unedited log via the GitHub API (`get_job_logs`),
the authoritative source these numbers are quoted from.

## `docviewlite`'s `fap_icon_assets="images"` question — resolved by this real build

The Phase 2C.1 finding that `docviewlite`'s manifest references a
non-existent `images/` directory was left unresolved pending an actual
build attempt (per this phase's "do not improve app features during
import, validate at build time" instruction). **This real CI build
succeeded**, including `docviewlite`'s own `.fap` output being confirmed
present among the 10 — meaning `fbt`'s build system tolerates a
`fap_icon_assets` reference to a directory that does not exist, at least
for this specific app and commit. No source or manifest change was made
to work around this; the build simply passed as-is.

## `sd_info`'s SD-benchmark storage behavior — build-level confirmation

The build succeeded with `sd_info`'s `main.c` compiling and linking
cleanly against the storage APIs its SD speed test uses
(`storage_file_open`/`storage_file_write`/`storage_file_read`/
`storage_simply_remove`) — confirming the app compiles correctly, not
that its runtime storage behavior has been hardware-verified (that
remains a hardware-smoke-test-time question, not a CI-build-time one).

## Failures/blocks

**None in CI.** The only block recorded in this phase is the
local-sandbox toolchain/OS limitation described above, which is an
established, unrelated environment limitation — not a Phase 2C code
defect.

## Phase 2C.3 artifact hash finalization

Real SHA-256 hashes of the `firmware.dfu`/updater `.tgz` shown above were finalized by the `Phase 2C Finalize Baseline` workflow (run [`28899393035`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28899393035)) - see `docs/PHASE2C_3_ARTIFACT_HASHES.md` for the values. Phase 2C.3 finalized this build's artifacts; nothing about the build result itself changed.

## Conclusion

**Local build: BUILD BLOCKED / ENVIRONMENT** (same root cause as every
prior phase's cloud-sandbox attempt). **CI build: PASS**, real and
verified via the GitHub API, not claimed on trust. This is the first
real, successful compiled-and-linked confirmation that all 10 apps — the
8 accepted Phase 2A/2B apps plus the 2 newly-imported Phase 2C apps —
build together cleanly on a real Windows machine.

This does **not** constitute hardware-tested or release-ready status —
see `docs/PHASE2C_2_GO_NO_GO.md` for the full classification and next
gate.

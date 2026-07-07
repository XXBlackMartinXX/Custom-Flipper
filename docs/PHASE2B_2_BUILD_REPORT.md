# Phase 2B.2 — Build Report

Docs only. Records the real local and CI build results for the Phase 2B
tiny batch (`flipfetch`, `quadratic_solver`, `sudoku`) alongside the 5
already-accepted Phase 2A apps — 8 apps total.

## Local build status: BUILD BLOCKED / ENVIRONMENT

A real local build was attempted in this session's cloud sandbox (Linux),
using the same `./fbt` entry point Unleashed/RogueMaster ship. Result:
**genuinely blocked**, not faked, not worked around.

- **Root cause**: `fbt` downloads a pinned, patched ARM GCC 12.3 toolchain
  from `https://update.flipperzero.one/builds/toolchain/
  gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz`. A direct request
  to that host in this session returned:
  ```
  curl: (56) CONNECT tunnel failed, response 403
  ```
  confirmed independently via this session's own proxy status endpoint,
  which recorded the identical rejection:
  ```json
  {"kind": "connect_rejected", "detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)", "host": "update.flipperzero.one:443"}
  ```
- This is the **same root cause** documented since Phase 0 and reconfirmed
  in Phase 2A.6 — the vendor toolchain host is genuinely unreachable from
  this sandbox's network policy. It is unrelated to any Phase 2B app; the
  base firmware itself cannot be built locally here for the same reason.
- **No substitute/unofficial toolchain was used.** Per this project's
  standing rule (established in the original Phase 0 build attempt), an
  ad hoc substitute toolchain is not a meaningful test of "does this
  firmware build" and was not attempted again here.
- One genuine improvement *was* made and is worth recording honestly: this
  session's own git submodules (`git submodule update --init --recursive`)
  initialized successfully for the first time in this project's history,
  confirming `raw.githubusercontent.com`/`github.com` git-clone access is
  not blocked, even though the specific `update.flipperzero.one` toolchain
  host still is. This let local **Static** validation run cleanly against
  all 8 apps (see `docs/PHASE2B_2_SAFETY_REVIEW.md` and
  `docs/PHASE2B_2_IMPORT_LOG.md`), even though local **Build** remains
  blocked.

**Classification: BUILD BLOCKED / ENVIRONMENT.**

## CI build status: PASS (real, verified via GitHub API)

`.github/workflows/phase2b-windows-validation.yml` ran automatically on
push to `integration/phase2b-first-batch`, on a real GitHub-hosted
`windows-latest` runner.

| Field | Value |
|---|---|
| Workflow | Phase 2B Windows Validation |
| Workflow run ID | `28877810474` |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474 |
| Job ID | `85657573542` |
| Runner | GitHub-hosted `windows-latest` |
| Commit validated | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` |
| Job conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`) | **success** |
| Static validation duration | `15:24:38Z`–`15:24:41Z` (a few seconds) |
| Build validation duration | `15:24:41Z`–`15:31:06Z` (~6.5 minutes — consistent with a real `fbt.cmd` build including toolchain bootstrap on a fresh runner, not a skipped/faked step; comparable to Phase 2A's own ~5-minute CI build duration) |

### Per-step confirmation (from the job's own real log, fetched via `get_job_logs`)

```
--- Static checks ---
[PASS] Branch verification - On expected branch 'integration/phase2b-first-batch'
[PASS] Commit verification - HEAD matches expected commit 50dfe2fadb2e587f4e8ed67edbf7f60e42b90159
[PASS] Git status before (clean working tree)
[PASS] Submodule initialization - All 16 submodule(s) initialized and pinned as expected
[PASS] Phase 2A app directories present - All 8 app directories found
[PASS] Application manifests valid - All 8 application.fam files present and parse as expected
[PASS] App ID uniqueness (within Phase 2A batch) - All 8 appids are unique within this batch
[PASS] App ID collision check vs base applications/ - No Phase 2A appid collides with a base-firmware app
[PASS] SAM removal verification (chess) - Zero matches for sam/stm32_sam/flipchess_voice/speech/voice
[PASS_WITH_REVIEWED_FALSE_POSITIVES] Risky keyword scan - 110 substring match(es) found; all 110 matched an exact,
  individually-reviewed entry. Zero unreviewed matches, zero high-confidence-unsafe matches.

--- Build checks ---
[PASS] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0) - Exit code 0
[PASS] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package) - Exit code 0
[PASS] Artifact present: build\f7-firmware-C\firmware.dfu - Size: 862825 bytes
[PASS] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz - Size: 2742659 bytes
[PASS] Per-app FAP output verification - All 8 expected .fap files found in build\f7-firmware-C\.extapps
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
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** — identical to the Phase 2A-only baseline's known-good size, confirming the base firmware itself is unchanged by this batch |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,742,659 bytes** — larger than the Phase 2A-only baseline's 2,732,909/2,733,074 bytes; expected, not a defect, for the same reason documented in Phase 2A's own build reports: the updater package embeds the 3 additional compiled FAPs plus a commit-derived version string, so a size increase at a different, larger commit is normal, not anomalous |
| FAP outputs | `build\f7-firmware-C\.extapps\*.fap` | All 8 expected `.fap` files confirmed present (5 Phase 2A + `flipfetch.fap`, `quadratic_solver.fap`, `sudoku.fap`) |

Both artifacts exist only as GitHub Actions **workflow artifacts** for run
`28877810474` (`phase2b-firmware-artifacts`, `phase2b-validation-reports`)
— not committed to the repository. Attempting to download them directly
in this session hit the same, already-documented network limitation as
Phase 2A.10: GitHub Actions artifact downloads redirect to Azure Blob
Storage (`productionresultssa19.blob.core.windows.net`), and this
session's egress policy returns `403` for that host — confirmed directly
(`curl: (56) CONNECT tunnel failed, response 403`). This does not affect
the result above: the full per-step detail was retrieved instead from the
job's own real, unedited log via the GitHub API (`get_job_logs`), which is
the authoritative source these numbers are quoted from, not a
re-derivation or estimate.

## FAP output verification for all three new apps

Confirmed present in `build\f7-firmware-C\.extapps\` alongside the 5
Phase 2A FAPs (per "All 8 expected .fap files found"): `flipfetch.fap`,
`quadratic_solver.fap`, `sudoku.fap`.

## Failures/blocks

**None in CI.** The only block recorded in this phase is the local-sandbox
toolchain-host block described above, which is an established, unrelated
environment limitation — not a Phase 2B code defect.

## Phase 2B.3 artifact hash finalization

Real SHA-256 hashes of the `firmware.dfu`/updater `.tgz` shown above were finalized by the `Phase 2B Finalize Baseline` workflow (run [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603)) - see `docs/PHASE2B_3_ARTIFACT_HASHES.md` for the values. Phase 2B.3 finalized this build's artifacts; nothing about the build result itself changed.

## Conclusion

**Local build: BUILD BLOCKED / ENVIRONMENT** (same root cause as every
prior phase's cloud-sandbox attempt). **CI build: PASS**, real and
verified via the GitHub API, not claimed on trust. This is the first real,
successful compiled-and-linked confirmation that all 8 apps — the 5
accepted Phase 2A apps plus the 3 newly-imported Phase 2B apps — build
together cleanly on a real Windows machine.

This does **not** constitute hardware-tested or release-ready status —
see `docs/PHASE2B_2_GO_NO_GO.md` for the full classification and next
gate.

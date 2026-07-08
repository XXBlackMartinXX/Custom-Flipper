# Phase 2D.2 — Go / No-Go

Docs only. This is the closing decision document for Phase 2D.2 —
implementation/import of the cleared Phase 2D tiny batch.

## Final classification: **PHASE 2D.2 BUILD BLOCKED / UPDATER_PACKAGE CI TOOLING**

This is **not** a clean pass, and is reported honestly as such rather than
rounded up. All 3 cleared apps (`resistors`, `crypto_dictionary`, `2048`)
were imported one at a time, each preserving full provenance and license
text, each statically clean, and the resulting 13-app batch's **firmware
and all 13 `.fap` outputs build successfully and consistently on real
Windows CI (3 for 3 real attempts)**. However, the separate
`updater_package` build sub-step — which packages the built firmware and
FAPs into the distributable updater `.tgz` — **failed to launch as a
process on 2 of 3 real CI attempts**, reproduced on two different
GitHub-hosted runner instances for the same commit, after having
succeeded on the first attempt. This is a real, currently-unresolved
CI/tooling-environment finding, not evidence of a source defect in any of
the 3 imported apps, but it is not swept aside either.

## Imported apps

| App | License | Import commit | Static scan | Storage behavior | Firmware+FAP build | Updater package build |
|---|---|---|---|---|---|---|
| `resistors` | MIT (confirmed, full text) | `621229a` | Clean — zero real matches; 6 benign `double`-substring false positives (correcting Phase 2D.1's overstated "zero raw substring matches" claim — see `docs/PHASE2D_2_SAFETY_REVIEW.md`) | Confirmed zero storage API usage | PASS, 3/3 | PASS 1/3, BLOCKED 2/3 |
| `crypto_dictionary` | GPLv3 (confirmed, full text) | `f9fcc57` | Clean — zero matches of any kind | Confirmed read-only bundled glossary access | PASS, 3/3 | PASS 1/3, BLOCKED 2/3 |
| `2048` | MIT (confirmed, full text) | `52b1361` | Clean — benign `table`-substring false positives only | Confirmed app-scoped save (`/ext/apps_data/game_2048/`), hardcoded path + legacy-migration nuance documented | PASS, 3/3 | PASS 1/3, BLOCKED 2/3 |

Plus infrastructure commits: `41597a9` (validator config,
`tools/phase2d_validate_config.json`), `263a019` (CI workflow,
`.github/workflows/phase2d-windows-validation.yml`), and `e01370d` (a
real, root-caused fix for a `.fap` artifact-upload tooling bug — see
`docs/PHASE2D_2_BUILD_REPORT.md`).

## Skipped/deferred apps

- **`fcc_id_lookup`** — **not imported, not re-reviewed.** Remains
  deferred per `docs/PHASE2C_1_GO_NO_GO.md` on its own, separate,
  unrelated license-evidence gap. Not touched by this phase.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`, `qrcode`, `barcode_gen`, `hex_viewer`, `image_viewer`,
  `minesweeper`, `boilerplate`** — none imported, none re-reviewed, per
  this phase's explicit hard exclusions.

## Code changed summary

- **Added**: `applications_user/resistors/` (20 files), `applications_user/crypto_dictionary/`
  (30 files), `applications_user/2048/` (9 files), 6 exception lines in
  `applications_user/.gitignore` (one pair per app), `tools/phase2d_validate_config.json`,
  `.github/workflows/phase2d-windows-validation.yml`.
- **Not touched**: `applications/` (base firmware source), `build/`,
  `dist/`, `toolchain/`, any Phase 2A/2B/2C app directory, any firmware
  binary, any updater package. No core firmware modification was made or
  needed — confirmed directly, since the firmware build itself succeeded
  unmodified on all 3 attempts.
- **Not imported**: `applications_user/fcc_id_lookup/` does not exist on
  this branch. `resistors`'s `.flipcorg/`/`design/`/`img/`/`screenshots/`
  and `2048`'s `images/`/`img/` were deliberately excluded per the
  Phase 2D.1 import-scope condition — confirmed absent by directory
  listing before every commit.

## Build/CI status

- **Local build**: `BUILD BLOCKED / ENVIRONMENT` (same structural
  limitation as every prior phase — `fbt.cmd` is a Windows batch file,
  this sandbox is Linux).
- **Local Static validation**: real, run via `pwsh` in this session —
  **PASS_WITH_REVIEWED_FALSE_POSITIVES**.
- **CI, Attempt 1** (run `28905289140`, commit `263a019`): **PASS** in
  full — firmware, updater package, and all 13 `.fap` outputs all
  succeeded. One separate, non-blocking tooling bug found and fixed
  (`.fap` artifact-upload dot-directory exclusion).
- **CI, Attempt 2** (run `28906654889`, commit `e01370d`, two executions
  on two different runners): firmware build and all 13 `.fap` outputs
  **PASS** both times; `updater_package` **BLOCKED** both times ("fbt.cmd
  could not be launched as a process"), reproducibly. See
  `docs/PHASE2D_2_BUILD_REPORT.md` for the full per-attempt detail and
  the evidentiary limits on further root-causing this (Azure Blob
  artifact-log downloads remain blocked in this session, the same
  established limitation from prior phases).

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's workflow or docs. No device, no flash. This phase's own
strict boundaries explicitly prohibited running `HardwareAssisted` mode
or flashing hardware, and neither was attempted.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.** This status is unaffected by
today's CI result either way — it was never closer to release-ready than
this, and the `updater_package` CI blocker only reinforces that no
release artifact should be treated as authoritative yet.

## Why this is not classified as a clean "IMPORT PASS"

The firmware and per-app `.fap` build result is genuinely strong evidence
that all 3 apps' source is structurally sound and compiles cleanly
alongside the existing 10-app baseline — this is a real, positive,
3-for-3 confirmed result, not a guess. But this project's own standing
rule (established by the `sd_info`/`fcc_id_lookup` corrections in Phase
2C.1 and reinforced by this very phase's own `resistors` substring-count
correction) is to report exactly what was tested and exactly what wasn't,
never to round a partial result up to a full pass. The updater `.tgz` —
the actual distributable release artifact — could not be produced on 2 of
the last 2 CI attempts. Calling that "IMPORT PASS" would overstate what
has actually been demonstrated.

## Next recommended gate

This phase does **not** authorize any of the following on its own — each
requires the project owner's own separate, explicit request:

1. **Resolve the `updater_package` CI blocker first**, before any
   further Phase 2D gate. Candidate next steps for a future session:
   retry the CI run once more (a third data point, since 2 consecutive
   failures on different runners is suspicious but not yet exhaustively
   proven non-transient); investigate whether the 13-app build now
   consumes materially more disk/build time than the 10-app Phase 2C
   baseline (Attempt 1's total run was ~8.4 minutes vs. Phase 2C's
   ~6.8-minute CI build, a real increase); or accept the firmware+FAP
   build result as sufficient for now and explicitly track the updater
   packaging gap as a known, separate CI-tooling issue (see
   `docs/KNOWN_ISSUES.md` update below).
2. **Only after that is resolved or explicitly accepted**: a Phase 2D.3
   CI-baseline acceptance / artifact-hash finalization pass, mirroring
   Phase 2A.9–2A.11/2B.3/2C.3 — but a finalized baseline should not be
   tagged against a batch whose updater package cannot yet be reliably
   produced.
3. **A Phase 2D hardware-assisted validation gate**, only if/when a
   device and Windows machine become available — out of scope until
   Phase 2D.3 exists.
4. **`fcc_id_lookup`'s license gap** remains its own, separate, narrow
   follow-up, entirely unaffected by this phase.

## Statement (as of this document's original writing)

**PHASE 2D.2 BUILD BLOCKED / UPDATER_PACKAGE CI TOOLING.** Exactly 3 apps
imported (`resistors`, `crypto_dictionary`, `2048`); `fcc_id_lookup`
correctly not imported; no other app touched; no core firmware
modification; no hardware touched; no hardware-connected validation mode
run; no release published. Firmware and all 13 `.fap` outputs confirmed
building successfully on real CI, 3 for 3 attempts. The updater `.tgz`
packaging step is reproducibly blocked in CI as of this report (2 of 3
attempts) and remains an open, unresolved item. Hardware flashing/testing
remains **NOT PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. Phase 2D.3 is **not started**.

---

## Phase 2D.2A update: `updater_package` blocker diagnosed and reclassified

**This section updates the final classification with new evidence and a
real remediation. The original content above is left unmodified as the
historical record of what was known at the time; do not read this section
as retroactively editing it.**

A 4th real CI attempt (`28925181640`, an automatic run at Phase 2D.2's own
documentation commit `12a7505` — docs-only, no script/workflow change)
**passed in full**, including `updater_package`, using the exact same
unmodified pre-fix script that had just failed twice in a row. This
proves the original "reproducibly BLOCKED" framing above, while an
honest read of the 2 data points then available, was incomplete — the
real pre-fix behavior was **intermittent** (2 of 4 real attempts passed,
~50%), not a deterministic break.

Phase 2D.2A then applied a narrow, verified remediation scoped to the
`updater_package` call site only in `tools/phase2a_validate.ps1`: added
non-secret diagnostics (disk space, `fbt.cmd` metadata, PowerShell/OS
version, Windows Defender status, PATH) immediately before the attempt,
and switched the launch mechanism from PowerShell's `&` call operator to
an explicit `cmd /c` wrapper — same build target, same arguments, same
pass/fail classification logic. The firmware build call site (6-for-6
real-CI success record across the full investigation) was left
untouched. Full detail in `docs/PHASE2D_2A_CI_REMEDIATION_LOG.md` and
`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`.

**Post-fix result: 2 of 2 real, independent CI attempts passed in full**
(run `28938933924`, attempts 1 and 2, on 2 different runner instances,
the second triggered via `rerun_workflow_run` specifically to obtain an
independent confirmation rather than accept a single green run):

| Run | Firmware build | `updater_package` | `firmware.dfu` | `.tgz` | All 13 `.fap` | `.fap` upload |
|---|---|---|---|---|---|---|
| `28938933924` attempt 1 | PASS | **PASS** | 862,825 bytes | 2,784,400 bytes | PASS | PASS |
| `28938933924` attempt 2 | PASS | **PASS** | 862,825 bytes | 2,783,411 bytes | PASS | PASS |

### Updated final classification: **PHASE 2D.2 IMPORT PASS WITH CI TOOLING REMEDIATION NOTE**

All 3 apps (`resistors`, `crypto_dictionary`, `2048`) are confirmed
imported, license-clear, statically clean, and — as of this update —
confirmed building in full (firmware + `updater_package` + all 13 `.fap`
outputs) on 2 consecutive, independent real CI runs following a narrow,
documented tooling remediation. This reclassification is made honestly,
not triumphantly: the pre-fix history (2 of 4 passed) means 2 post-fix
passes cannot statistically *prove* the `cmd /c` change is what caused
the improvement, only that it is a real, safe, narrow change, applied and
verified twice, with no app or firmware source touched at any point. The
"CI TOOLING REMEDIATION NOTE" in this classification exists specifically
to carry that nuance forward — this is not the same as an unconditional
clean pass with no history behind it.

### Whether Phase 2D.3 is now allowed

**Yes — Phase 2D.3 (CI baseline acceptance / artifact-hash finalization)
may now be considered**, on the project owner's own separate, explicit
request, exactly as every prior phase transition in this project has
required. This document does not itself start Phase 2D.3.

### Updated statement

**PHASE 2D.2 IMPORT PASS WITH CI TOOLING REMEDIATION NOTE.** Exactly 3
apps imported (`resistors`, `crypto_dictionary`, `2048`); `fcc_id_lookup`
correctly not imported; no other app touched; no core firmware
modification at any point in this investigation; no hardware touched; no
hardware-connected validation mode run; no release published. Firmware,
`updater_package`, and all 13 `.fap` outputs confirmed building
successfully on 2 consecutive, independent post-fix real CI runs, on top
of an intermittent (not deterministic) pre-fix history that is recorded
honestly rather than hidden. Hardware flashing/testing remains **NOT
PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. Phase 2D.3 is **not started by this document** — it is
now an allowed next step, pending the project owner's own explicit
request.

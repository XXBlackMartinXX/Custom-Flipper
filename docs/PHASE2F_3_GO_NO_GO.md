# Phase 2F.3 — Go / No-Go

Docs only. This is the closing decision document for Phase 2F.3 — CI
baseline acceptance and artifact hash finalization for the Phase 2F
imported batch, after Phase 2F.2A's remediation. This document will be
updated in place once `.github/workflows/phase2f-finalize-baseline.yml`
has actually been run; the pre-finalization state is recorded honestly
below.

## Final classification: **PHASE 2F.3 BASELINE ACCEPTANCE PASS**

The CI Windows validation run (`29017861599`) has already succeeded, with
conclusion verified via the GitHub API (`get_workflow_run`,
`list_workflow_jobs`, `get_job_logs`), not claimed on trust. The
acceptance record (`docs/PHASE2F_3_ACCEPTANCE_RECORD.md`) is locked in
against that real run, at the actual current branch HEAD (a later,
automatically-triggered run than either of the two independent
Phase 2F.2A confirmation runs — checked explicitly, per this phase's own
requirement, before finalizing). Artifact hash finalization and tag
creation are handled by the new `Phase 2F Finalize Baseline` workflow —
see "Finalization workflow result" below for whether that workflow has
actually run yet in this session, and its real result if so.

## Imported apps accepted

`qrcode`, `hex_viewer`, `barcode_gen` (real appid `barcode_app`) — all 3,
per `docs/PHASE2F_3_ACCEPTANCE_RECORD.md`.

## Phase 2F.2A remediation accepted

Both real defects behind the original Phase 2F.2 `updater_package`/`.fap`
blockage — a CI/tooling defect (Windows PowerShell escalating routine
compiler stderr output to a terminating exception) and a real app-source
defect in `barcode_gen` (5 dead calls to an unwired custom-keyboard-fork
function, fixed with explicit owner approval) — are confirmed fixed and
accepted as part of this baseline. See
`docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` for the full evidence. The original 2
failed Phase 2F.2 attempts remain preserved, unmodified, in
`docs/PHASE2F_2_BUILD_REPORT.md`.

## Deferred apps preserved

`fcc_id_lookup` remains deferred, unchanged, on its license-evidence gap.
Not imported, not accepted, not substituted. `upython`, `iconedit`,
`c_book`, `animation_switcher`, `theme_manager` remain hard-excluded,
unchanged.

## CI run accepted

Run `29017861599` ("Phase 2F Windows Validation"), commit
`37d11cada5a83afdeb752c6b2106216d7fc09b9f`, conclusion `success`,
independently verified via the GitHub API. Static
`PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS` (firmware,
`updater_package`, and all 19 `.fap` outputs — including `qrcode.fap`,
`hex_viewer.fap`, `barcode_app.fap`).

## Artifact hash status

See "Finalization workflow result" below for the real, current status —
this section is not duplicated here to avoid two sources of truth
drifting apart.

## Tag status

See "Finalization workflow result" below.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's new workflow or docs. No device, no flash.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.**

## Next allowed gate

See "Finalization workflow result" below for the real, completed result
and the resulting next-gate determination.

---

## Finalization workflow result

**PENDING.** `.github/workflows/phase2f-finalize-baseline.yml` has been
created and is being pushed/mirrored/dispatched as part of this same
Phase 2F.3 work — this section will be updated with the real,
GitHub-API-verified result (run ID, conclusion, computed hashes, tag
creation/verification, or the exact blocker if execution fails) once that
dispatch completes. No hash or tag status is fabricated here in advance.

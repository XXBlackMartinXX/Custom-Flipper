# Phase 2D.3 — Go / No-Go

Docs only. This is the closing decision document for Phase 2D.3 — CI
baseline acceptance and artifact hash finalization for the Phase 2D
imported batch. This document will be updated in place once
`.github/workflows/phase2d-finalize-baseline.yml` has actually been run;
the pre-finalization state is recorded honestly below.

## Final classification: **PHASE 2D.3 BASELINE ACCEPTANCE PASS**

The CI Windows validation run (`28941093859`) has already succeeded, with
conclusion verified via the GitHub API (`get_workflow_run`,
`list_workflow_jobs`, `get_job_logs`), not claimed on trust. The
acceptance record (`docs/PHASE2D_3_ACCEPTANCE_RECORD.md`) is locked in
against that real run, at the actual current branch HEAD. Artifact hash
finalization and tag creation are handled by the new
`Phase 2D Finalize Baseline` workflow — see below for whether that
workflow has actually run yet in this session, and its real result if so.

## Imported apps accepted

`resistors`, `crypto_dictionary`, `2048` — all 3, per
`docs/PHASE2D_3_ACCEPTANCE_RECORD.md`.

## Deferred apps preserved

`fcc_id_lookup` remains deferred, unchanged, on its license-evidence gap.
Not imported, not accepted, not substituted. `upython`, `iconedit`,
`c_book`, `animation_switcher`, `theme_manager`, `qrcode`, `barcode_gen`,
`hex_viewer`, `image_viewer`, `minesweeper`, `boilerplate` remain
hard-excluded or held in the clean candidate pool, unchanged.

## CI run accepted

Run `28941093859` ("Phase 2D Windows Validation"), commit
`d0812638a02c50389b9e713ad98f2c8215b75dd5`, conclusion `success`,
independently verified via the GitHub API. Static
`PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS` (firmware,
`updater_package`, and all 13 `.fap` outputs).

## `updater_package` remediation status

**RESOLVED**, per Phase 2D.2A (`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`,
`docs/PHASE2D_2A_CI_REMEDIATION_LOG.md`), with the caveat carried forward
honestly: the pre-fix failure was intermittent (2 of 4 pre-fix real
attempts passed, ~50%), not deterministic, so the narrow `cmd /c`
launch-mechanism fix is confirmed by **3 consecutive independent post-fix
CI passes** (runs `28938933924` attempts 1 and 2, and `28941093859`) but
is not claimed as statistically, unconditionally proven causal. The two
pre-fix failures (`28906654889`, both executions) remain preserved,
never erased, in every doc that references this history.

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

**Executed successfully.** `.github/workflows/phase2d-finalize-baseline.yml`
was created, pushed, mirrored to `claude/flipper-custom-firmware-cxrcer`
(required for GitHub Actions to index and dispatch it — the same
requirement discovered in Phase 2B.3 and reused in Phase 2C.3), dispatched
via the GitHub API (`workflow_dispatch`), and completed in ~37 seconds
with conclusion **success**. Every step succeeded, verified via
`get_workflow_run`/`list_workflow_jobs`/`get_job_logs` — the real,
unedited job log, not inferred from the workflow's success status alone.

| Field | Value |
|---|---|
| Finalization workflow run | [`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724) |
| Source CI run used | `28941093859`, commit `d0812638a02c50389b9e713ad98f2c8215b75dd5` |
| `firmware.dfu` | 862,825 bytes, SHA-256 `4f3703a8778543257759f367bc02f50d440ef85d21da05b630f705564084b6a8` |
| `flipper-z-f7-update-local.tgz` | 2,783,170 bytes, SHA-256 `3e015f6c0b303536fab14e4a8b85233b8c439c0f642087cb92f3781bf1b16c49` |
| Validation reports / build logs | 6 files hashed (2× `phase2a_validation_*.json`/`.md` pairs, `build_firmware_*.log` 91,044 bytes, `build_updater_*.log` 216,632 bytes) — see `docs/PHASE2D_3_ARTIFACT_HASHES.md` for the full table |
| `.fap` artifact bundle | 35 files hashed (13 expected imported/pre-existing Phase 2D apps plus 22 Unleashed-bundled example/plugin FAPs, confirmed benign — see `docs/PHASE2D_3_ARTIFACT_HASHES.md`) |
| Docs patched | `docs/PHASE2D_3_ARTIFACT_HASHES.md` (generated), `docs/PHASE2D_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2D_3_ARTIFACT_MANIFEST.md`, `docs/PHASE2D_2_BUILD_REPORT.md` |
| Docs commit | [`f8edb1c`](https://github.com/XXBlackMartinXX/Custom-Flipper/commit/f8edb1c9c0cac5cf947df7aa96de2450aaedc14b) — "docs: finalize Phase 2D artifact hashes from CI artifacts" |
| `phase2d-ci-baseline-20260708` tag | **Created** (did not previously exist) → `d0812638a02c50389b9e713ad98f2c8215b75dd5` |
| `phase2d-acceptance-record-20260708` tag | **Created** (did not previously exist) → `f8edb1c9c0cac5cf947df7aa96de2450aaedc14b` (the finalization workflow's own docs commit) |

Both tags were created fresh — neither existed before this run — so the
"do not overwrite silently" safeguard was not exercised against a real
conflict in this run, but remains in place for any future re-run. All 6
prior tags from Phase 2A/2B/2C
(`phase2a-ci-baseline-20260707` → `718eec5fe115c9e0467a8d07d974947a85b27cf6`,
`phase2a-acceptance-record-20260707` → `80f429bc7385975e9c1f30bf0e116dc5653b236a`,
`phase2b-ci-baseline-20260707` → `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159`,
`phase2b-acceptance-record-20260707` → `ff44e82d5139717315960273917db064c9deeff1`,
`phase2c-ci-baseline-20260707` → `969054ee9f802f72be1064a62052c4be82a91783`,
`phase2c-acceptance-record-20260707` → `dbd7c56a596dd63dd2b790fe3dd1bb52de384762`)
were verified unchanged after this run by directly dereferencing each to
its target commit.

Since Phase 2D.3 finalization actually PASSed, per
`docs/PHASE2D_NEXT_GATE.md`: the next allowed path is either a Phase 2D
hardware-assisted gate (if/when a device and Windows machine become
available) or Phase 2E planning only — both only on the project owner's
own further explicit request. `fcc_id_lookup`'s license gap remains a
separate, narrow follow-up, not resolved by this document. Neither Phase
2E nor a hardware gate is started by this document. No app or firmware
source changed during Phase 2D.3, and no hardware testing was performed.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY.**

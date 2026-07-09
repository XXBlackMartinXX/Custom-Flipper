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

**Executed successfully.** `.github/workflows/phase2f-finalize-baseline.yml`
was created, pushed, mirrored to `claude/flipper-custom-firmware-cxrcer`
(required for GitHub Actions to index and dispatch it), dispatched via
the GitHub API (`workflow_dispatch`), and completed in ~59 seconds with
conclusion **success**. Every one of its 13 steps succeeded, verified via
`get_workflow_run`/`list_workflow_jobs` — the real, unedited run and job
status, not inferred or claimed on trust.

| Field | Value |
|---|---|
| Finalization workflow run | [`29027115867`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29027115867) |
| Source CI run used | `29017861599`, commit `37d11cada5a83afdeb752c6b2106216d7fc09b9f` |
| `firmware.dfu` | 862,825 bytes, SHA-256 `27f60598d43657710207510520159ba6626722a2825ed8adf5768d002a3a005b` |
| `flipper-z-f7-update-local.tgz` | 2,878,428 bytes, SHA-256 `341fa331625c488ff8c6bf079ed0c82b553ef1a11441687a81139464f3f91772` |
| `.fap` artifact bundle | 41 files hashed (19 expected imported/pre-existing Phase 2A-2F apps plus 22 Unleashed-bundled example/plugin FAPs, the same class of benign extras Phase 2E's finalization observed — see `docs/PHASE2F_3_ARTIFACT_HASHES.md` for the full table) |
| Docs patched | `docs/PHASE2F_3_ARTIFACT_HASHES.md` (generated), `docs/PHASE2F_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2F_3_ARTIFACT_MANIFEST.md`, `docs/PHASE2F_2_BUILD_REPORT.md` |
| Docs commit | [`51df041`](https://github.com/XXBlackMartinXX/Custom-Flipper/commit/51df041ed0dc9f49df23305b5f1966cd3294239d) — "docs: finalize Phase 2F artifact hashes from CI artifacts" |
| `phase2f-ci-baseline-20260709` tag | **Created** (did not previously exist) → `37d11cada5a83afdeb752c6b2106216d7fc09b9f`, independently verified via `git ls-remote --tags origin` |
| `phase2f-acceptance-record-20260709` tag | **Created** (did not previously exist) → `51df041ed0dc9f49df23305b5f1966cd3294239d` (the finalization workflow's own docs commit), independently verified via `git ls-remote --tags origin` |

Both tags were created fresh — neither existed before this run — so the
"do not overwrite silently" safeguard was not exercised against a real
conflict in this run, but remains in place for any future re-run. All 10
prior tags from Phase 2A/2B/2C/2D/2E
(`phase2a-ci-baseline-20260707` → `718eec5fe115c9e0467a8d07d974947a85b27cf6`,
`phase2a-acceptance-record-20260707` → `80f429bc7385975e9c1f30bf0e116dc5653b236a`,
`phase2b-ci-baseline-20260707` → `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159`,
`phase2b-acceptance-record-20260707` → `ff44e82d5139717315960273917db064c9deeff1`,
`phase2c-ci-baseline-20260707` → `969054ee9f802f72be1064a62052c4be82a91783`,
`phase2c-acceptance-record-20260707` → `dbd7c56a596dd63dd2b790fe3dd1bb52de384762`,
`phase2d-ci-baseline-20260708` → `d0812638a02c50389b9e713ad98f2c8215b75dd5`,
`phase2d-acceptance-record-20260708` → `f8edb1c9c0cac5cf947df7aa96de2450aaedc14b`,
`phase2e-ci-baseline-20260708` → `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93`,
`phase2e-acceptance-record-20260708` → `2910536cc131d2d23feba635ab5d3e806cfdc47d`)
were verified unchanged after this run by directly dereferencing each to
its target commit via `git ls-remote --tags origin`.

Since Phase 2F.3 finalization actually PASSed, per
`docs/PHASE2F_NEXT_GATE.md`: the next allowed path is either a Phase 2F
hardware-assisted gate (if/when a device and Windows machine become
available) or Phase 2G planning only (not import, and only if there
remains a safe candidate pool) — both only on the project owner's own
further explicit request. `fcc_id_lookup`'s license gap remains a
separate, narrow follow-up, not resolved by this document. Neither Phase
2G nor a hardware gate is started by this document. No app or firmware
source changed during Phase 2F.3, and no hardware testing was performed.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY.**

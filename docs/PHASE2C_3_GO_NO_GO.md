# Phase 2C.3 — Go / No-Go

Docs only. This is the closing decision document for Phase 2C.3 — CI
baseline acceptance and artifact hash finalization for the Phase 2C
imported batch. This section will be updated in place once
`.github/workflows/phase2c-finalize-baseline.yml` has actually been run;
the pre-finalization state is recorded honestly below.

## Final classification: **PHASE 2C.3 BASELINE ACCEPTANCE PASS**

The CI Windows validation run (`28897702247`) has already succeeded, with
conclusion verified via the GitHub API (`get_workflow_run`,
`list_workflow_jobs`), not claimed on trust. The acceptance record
(`docs/PHASE2C_3_ACCEPTANCE_RECORD.md`) is locked in against that real
run. Artifact hash finalization and tag creation are handled by the new
`Phase 2C Finalize Baseline` workflow — see below for whether that
workflow has actually run yet in this session, and its real result if so.

## Imported apps accepted

`sd_info`, `docviewlite` — both, per
`docs/PHASE2C_3_ACCEPTANCE_RECORD.md`.

## Deferred apps preserved

`fcc_id_lookup` remains deferred, unchanged, on its license-evidence gap.
Not imported, not accepted, not substituted. `upython`, `iconedit`,
`c_book`, `animation_switcher`, `theme_manager` remain hard-excluded,
unchanged.

## CI run accepted

Run `28897702247` ("Phase 2C Windows Validation"), commit
`969054ee9f802f72be1064a62052c4be82a91783`, conclusion `success`,
independently verified via the GitHub API. Static
`PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS`.

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

**Executed successfully.** `.github/workflows/phase2c-finalize-baseline.yml`
was created, pushed, mirrored to `claude/flipper-custom-firmware-cxrcer`
(required for GitHub Actions to index and dispatch it — the same
requirement discovered in Phase 2B.3), dispatched via the GitHub API
(`workflow_dispatch`), and completed in ~46 seconds
(`21:18:06Z`–`21:18:52Z`) with conclusion **success**. Every step
succeeded, verified via `get_workflow_run`/`list_workflow_jobs`/
`get_job_logs` — the real, unedited job log, not inferred from the
workflow's success status alone.

| Field | Value |
|---|---|
| Finalization workflow run | [`28899393035`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28899393035) |
| `firmware.dfu` | 862,825 bytes, SHA-256 `236ea92dfa826fe2459df3413e18952e0807775ed1f5c65737581e5c5c1934e8` |
| `flipper-z-f7-update-local.tgz` | 2,757,340 bytes, SHA-256 `d2fd4847830c311b487457e29f3ca285b009b2ca6735257739a4198711157632` |
| Docs patched | `docs/PHASE2C_3_ARTIFACT_HASHES.md` (generated), `docs/PHASE2C_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2C_3_ARTIFACT_MANIFEST.md`, `docs/PHASE2C_2_BUILD_REPORT.md` |
| Docs commit | [`dbd7c56`](https://github.com/XXBlackMartinXX/Custom-Flipper/commit/dbd7c56a596dd63dd2b790fe3dd1bb52de384762) — "docs: finalize Phase 2C artifact hashes from CI artifacts" |
| `phase2c-ci-baseline-20260707` tag | **Created** (did not previously exist) → `969054ee9f802f72be1064a62052c4be82a91783` |
| `phase2c-acceptance-record-20260707` tag | **Created** (did not previously exist) → `dbd7c56a596dd63dd2b790fe3dd1bb52de384762` (the finalization workflow's own docs commit) |

Both tags were created fresh — neither existed before this run (confirmed
by the job log's own `[new tag]` push output for both), so the
"do not overwrite silently" safeguard was not exercised against a real
conflict in this run, but remains in place for any future re-run. Phase
2A's and Phase 2B's own tags (`phase2a-ci-baseline-20260707`,
`phase2a-acceptance-record-20260707`, `phase2b-ci-baseline-20260707`,
`phase2b-acceptance-record-20260707`) were not touched, verified by
directly dereferencing each to its unchanged target commit after this run.

Since Phase 2C.3 finalization actually PASSed, per
`docs/PHASE2C_NEXT_GATE.md`: the next allowed path is either a Phase 2C
hardware-assisted gate (if/when a device and Windows machine become
available) or Phase 2D planning only — both only on the project owner's
own further explicit request. `fcc_id_lookup`'s license gap remains a
separate, narrow follow-up, not resolved by this document. Neither Phase
2D nor a hardware gate is started by this document.

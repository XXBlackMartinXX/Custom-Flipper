# FCC ID Lookup — Baseline Go / No-Go

Docs only. This is the closing decision document for `fcc_id_lookup`
baseline finalization, mirroring the format of this project's
`PHASEX_3_GO_NO_GO.md` documents.
`.github/workflows/fcc-id-lookup-finalize-baseline.yml` has now
actually run — see "Finalization workflow result" below for the real,
completed result.

## Final classification: **FCC_ID_LOOKUP BASELINE ACCEPTANCE PASS**

The CI Windows validation run
([`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596))
succeeded, with conclusion verified via the GitHub API, not claimed on
trust. This run is at the true branch HEAD (commit
`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`) that was current when
finalization was prepared, confirmed by explicitly checking for a later
successful run before finalizing, per this phase's own requirement — it
supersedes the earlier-cited run `29067243595` as the accepted baseline
(that earlier run's own evidence remains valid and preserved in
`docs/FCC_ID_LOOKUP_BUILD_REPORT.md`, not erased). Artifact hash
finalization and tag creation were handled by the
`fcc_id_lookup Finalize Baseline` workflow — see "Finalization workflow
result" below for the real, completed result.

## Accepted CI run

Run `29068148596` ("fcc_id_lookup One-App Import Validation"), commit
`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`, conclusion `success`,
independently verified via the GitHub API. Static
`PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS` (firmware, updater
package, and all 20 `.fap` outputs — including `fcc_id_lookup.fap`).

## Artifact hash status

**Generated.** Real SHA-256 hashes for `firmware.dfu`, the updater
`.tgz`, and all 42 `.fap` files (including `fcc_id_lookup.fap`) — see
`docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md` and "Finalization workflow
result" below.

## Tag status

**Created and independently re-verified.** Both
`fcc-id-lookup-ci-baseline-20260710` and
`fcc-id-lookup-acceptance-record-20260710` exist on `origin` and
dereference to their expected commits — see "Finalization workflow
result" below.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists
anywhere in this phase's new workflow or docs. No device, no flash.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.**

## Next allowed gate

Hardware-assisted validation and/or a future broader import batch — each
a separate, explicitly-requested step, neither started by this
finalization. This baseline is CI-only.

---

## Finalization workflow result

**Run.** The `fcc_id_lookup Finalize Baseline` workflow
([`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711))
completed with **all 13 steps `conclusion: success`**, independently
confirmed via `list_workflow_jobs`/`get_job_logs`.

| Field | Value |
|---|---|
| `firmware.dfu` SHA-256 | `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` (862,833 bytes) |
| Updater `.tgz` SHA-256 | `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` (2,891,859 bytes) |
| `fcc_id_lookup.fap` SHA-256 | `168025ddcffb01f94e1af8eefcead2ac80d69f6b7ad9856a603e1a7d30317658` (20,196 bytes) |
| Docs commit (bot) | `1c0232b` ("docs: finalize fcc_id_lookup artifact hashes from CI artifacts") |
| `fcc-id-lookup-ci-baseline-20260710` | → `86265727b5b8cfce5086eb88f8bb93d0169ab9a9`, verified via `git ls-remote --tags origin` |
| `fcc-id-lookup-acceptance-record-20260710` | → `1c0232b4137c366c5b79f651136b3097abf69a69`, verified via `git ls-remote --tags origin` |

All 10 prior Phase 2A–2F tags confirmed unchanged. Full detail in
`docs/FCC_ID_LOOKUP_BASELINE_ACCEPTANCE_RECORD.md` and
`docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md`.

**Final classification: FCC_ID_LOOKUP BASELINE ACCEPTANCE PASS.** No
hardware testing performed. Not release-ready — TEST-READY ONLY.

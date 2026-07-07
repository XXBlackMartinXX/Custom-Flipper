# Phase 2B.3 — Go / No-Go

Docs only. This is the closing decision document for Phase 2B.3 — CI
baseline acceptance and artifact hash finalization for the Phase 2B
imported batch. `.github/workflows/phase2b-finalize-baseline.yml` has now
been run for real (run
[`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603),
conclusion `success`, verified via the GitHub API) — this document
reflects that real, final result.

## Final classification: **PHASE 2B.3 BASELINE ACCEPTANCE PASS**

Both artifact hashes were generated for real and both baseline tags were
created and pushed, verified via the GitHub API (`get_workflow_run`,
`list_workflow_jobs`, `get_job_logs`) — not claimed on trust.

## Imported apps accepted

`flipfetch`, `quadratic_solver`, `sudoku` — all 3, per
`docs/PHASE2B_3_ACCEPTANCE_RECORD.md`.

## CI run accepted

Run `28877810474` ("Phase 2B Windows Validation"), commit
`50dfe2fadb2e587f4e8ed67edbf7f60e42b90159`, conclusion `success`,
independently verified via the GitHub API. Static
`PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build `PASS`.

## Artifact hash status

**GENERATED.** Real SHA-256 hashes, computed with `Get-FileHash` on a
GitHub-hosted Windows runner against the actual downloaded artifacts from
run `28877810474`:

| File | Size (bytes) | SHA-256 |
|---|---|---|
| `firmware.dfu` | 862,825 | `f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75` |
| `flipper-z-f7-update-local.tgz` | 2,742,659 | `6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7` |

See `docs/PHASE2B_3_ARTIFACT_HASHES.md` for the full manifest, including
validation report/log hashes.

## Tag status

**Both created and pushed, verified by dereferencing each tag to its
target commit:**

| Tag | Target commit | Verified via |
|---|---|---|
| `phase2b-ci-baseline-20260707` | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` | `git rev-parse phase2b-ci-baseline-20260707^{commit}`, matches the job log's own reported output exactly |
| `phase2b-acceptance-record-20260707` | `ff44e82d5139717315960273917db064c9deeff1` (the finalization workflow's own docs commit) | `git rev-parse phase2b-acceptance-record-20260707^{commit}`, matches the job log's own reported output exactly |

Neither tag existed before this run — both were created fresh (not a
pre-existing-tag-verification path), confirmed by the job log's `[new
tag]` push output for both.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's new workflow or docs. No device, no flash.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.**

## Next allowed gate

Since Phase 2B.3 finalization PASSed, per `docs/PHASE2B_NEXT_GATE.md`: the
next allowed path is either the Phase 2B hardware-assisted gate (if/when a
device and Windows machine become available) or Phase 2C planning only —
both only on the project owner's own further explicit request. Neither is
started by this document.

---

## Finalization workflow result

Run [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603)
("Phase 2B Finalize Baseline"), triggered via the GitHub API
(`actions_run_trigger` → `run_workflow`) against
`integration/phase2b-first-batch`, completed in ~32 seconds
(`15:52:22Z`–`15:52:54Z`) with conclusion **success**. Every step
succeeded: artifact download, SHA-256 computation, the three dependent
docs patched in place (`docs/PHASE2B_3_ACCEPTANCE_RECORD.md`,
`docs/PHASE2B_3_ARTIFACT_MANIFEST.md`, plus a finalization note added to
`docs/PHASE2B_2_BUILD_REPORT.md`), a docs-only commit (`ff44e82`, 4 files
changed) pushed to `integration/phase2b-first-batch`, and both tags
created and pushed. Confirmed via `get_workflow_run`,
`list_workflow_jobs`, and `get_job_logs` — the real, unedited job log, not
inferred from the workflow's success status alone.

One real environment-specific discovery from this phase, worth recording
plainly: the workflow could not be dispatched via the GitHub API until its
YAML file was also mirrored to `claude/flipper-custom-firmware-cxrcer` —
GitHub's Actions catalog only indexed it, and the dispatch endpoint only
found it, once it existed on that branch (every other indexed workflow's
`html_url` also resolves to that branch, strongly suggesting it is this
repository's actual default branch, distinct from any of the
`integration/*` branches). This was resolved by mirroring the workflow
(and its accompanying docs) there first — not by merging into any
release/main branch, and not a workaround that weakened anything about
the workflow's own logic or gates.

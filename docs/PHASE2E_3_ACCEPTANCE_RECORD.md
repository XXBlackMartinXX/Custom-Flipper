# Phase 2E — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2E
app-integration batch, covering exactly what has been verified and
nothing more. It does not authorize Phase 2F, does not claim hardware
testing, and does not claim release-readiness — see "Exact limitations"
and "Final acceptance classification" below. This document is updated in
place by the `Phase 2E Finalize Baseline` GitHub Actions workflow once
artifact hashes are generated; the pre-finalization state is recorded
honestly below and will be patched, not silently rewritten, when that
happens.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2e-first-batch` |
| CI-validated commit (SHA) | `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` (the actual current branch HEAD at acceptance time — chosen over the earlier `28966234832`/`59b5132` run, per the explicit requirement to check for a later automatic CI run at the true current HEAD before finalizing) |
| Workflow | Phase 2E Windows Validation |
| Accepted workflow run ID | `28968511276` |
| Accepted attempt | attempt 1 (an automatic run triggered by the push of this branch's own Phase 2E.2 documentation commit — a docs-only change, no script/workflow edit) |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28968511276 |
| Runner | GitHub-hosted `windows-latest` |
| CI conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`/`get_job_logs`) | **success** |

**Why this run/commit instead of the `28966234832` run cited when Phase
2E.2 was originally reported**: that run remains real, valid evidence (it
is the run Phase 2E.2's own docs were written against) and is not erased
— but `28968511276` validates the repository's actual current HEAD at
acceptance time (the docs-mirroring commit `dcdfbb4` that followed it),
so the commit this record locks in and the commit whose artifacts get
hashed by the finalization workflow are identically the same state, with
no gap between them. `28966234832` was superseded, not invalidated — its
own conclusion (`success`, commit `59b5132`) remains true and is recorded
in `docs/PHASE2E_2_BUILD_REPORT.md` unchanged.

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation (firmware) | **PASS** |
| Build validation (`updater_package`) | **PASS** |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the accepted run's own job log,
`get_job_logs`, job `85957834096`): "Run Static validation" — conclusion
`success`, `19:07:07Z`–`19:07:13Z`; "Run Build validation" — conclusion
`success`, `19:07:13Z`–`19:13:52Z` (~6.6 minutes, consistent with a real
`fbt.cmd` build including toolchain bootstrap on a fresh runner). Real,
verbatim per-check output from this run:

```
[PASS        ] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)
             Exit code 0. Full log: .\reports\phase2e\build_updater_20260708_190714.log
[PASS        ] Artifact present: build\f7-firmware-C\firmware.dfu
             Size: 862825 bytes
[PASS        ] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz
             Size: 2831378 bytes
[PASS        ] Per-app FAP output verification
             All 16 expected .fap files found in D:\a\Custom-Flipper\Custom-Flipper\build\f7-firmware-C\.extapps
```

## Imported apps (3, Phase 2E tiny batch)

| App | appid | Category | License/evidence | Import commit |
|---|---|---|---|---|
| `image_viewer` | `image_viewer` | Media | MIT | `3b20db6` |
| `boilerplate` | `fap_boilerplate` | Tools/Educational | Informal permissive README statement (no formal LICENSE) | `74d0927` |
| `minesweeper` | `minesweeper_redux` | Games | MIT | `d82c0ff` |

Combined with the 13 already-accepted Phase 2A/2B/2C/2D apps
(`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`,
`chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`,
`docviewlite`, `resistors`, `crypto_dictionary`, `2048`), this CI run
validates **16 apps total** — see `tools/phase2e_validate_config.json`.

## Deferred apps (not part of this acceptance)

- **`fcc_id_lookup`** — deferred per `docs/PHASE2C_1_GO_NO_GO.md` on a
  license-evidence gap (no `LICENSE` file in the RogueMaster-vendored
  copy; strong but not commit-pinned corroborating MIT evidence at the
  true upstream repository). Not imported, not re-reviewed, not part of
  this batch's acceptance. See `docs/KNOWN_ISSUES.md` item 6.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`, `qrcode`, `barcode_gen`, `hex_viewer`** —
  hard-excluded or held in the clean candidate pool throughout Phase 2E
  per explicit instruction; none imported, none re-reviewed.

## License status

- **`image_viewer`**: **MIT, confirmed by direct read** of the app's own
  `LICENSE` file in Phase 2E.1 and re-verified byte-identical at actual
  import time in Phase 2E.2. Import scope excludes the upstream
  repository's `example_images/` directory entirely (3 bundled `.bm`
  demo images, including `spongebob.bm`, decoded and visually confirmed
  in Phase 2E.1 to depict a recognizable trademarked cartoon character
  with no attribution evidence) — see
  `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md`. **This exclusion is confirmed
  still in effect: `applications_user/image_viewer/example_images/` does
  not exist on this branch.**
- **`boilerplate`**: **No formal `LICENSE` file exists upstream.**
  `README.md`'s own "## Licensing" section ("This code is open-source and
  may be used for whatever you want to do with it.") is preserved
  verbatim and recorded as the license-evidence record — a real,
  explicit, but non-SPDX evidence tier, not labeled "MIT" or any other
  named license.
- **`minesweeper`**: **MIT, confirmed by direct read**. No bundled
  third-party content beyond original game sprites; its one third-party
  header dependency (M\*LIB's `m-deque.h`) is already provided by this
  project's existing `lib/mlib` base-firmware submodule.
- Full detail in `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md` and
  `docs/PHASE2E_THIRD_PARTY_NOTICES.md`.

## Safety scan status

**Zero** matches across all 17 keywords this phase's own task
specification named (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `password`, `token`, `exfil`,
`clone`, `bypass`, `seed`, `wallet`, `private key`, `secret`) across all
16 apps. Any unreviewed match against the `highConfidenceUnsafeKeywords`
tier is a hard CI **FAIL** by design — this run had none.

## Reviewed false-positive summary

The risky-keyword substring scan found **373 total matches** (the 189
already-reviewed Phase 2A/2B/2C/2D matches, unchanged, plus 184 new
matches introduced by this batch's own source — all keyword `ble`, all
benign substring hits inside words like `variable`, `enabled`,
`solvable`, and `double`), and **all 373 resolved via the
reviewed-false-positive allowlist** in `tools/phase2e_validate_config.json`
— each entry individually keyed on exact file path + line number +
keyword + SHA-256 hash of the exact trimmed line text, so any future edit
to a matched line reverts it to unreviewed automatically. This is not a
blanket suppression of any keyword or directory. See
`docs/PHASE2E_2_SAFETY_REVIEW.md` for the full per-app detail.

## Storage behavior summary

- **`image_viewer`**: **Confirmed read-only.** `FSAM_READ`/
  `FSOM_OPEN_EXISTING` only in its 120-line `main.cpp`; no write call
  exists anywhere in the file.
- **`boilerplate`**: **App-private**, confirmed at
  `/ext/apps_data/boilerplate/boilerplate.conf`. No shared/root-level
  write.
- **`minesweeper`**: **App-private**, confirmed at
  `/ext/apps_data/mine_sweeper_redux/`, written via an atomic
  write-then-rename through a `.tmp` file in the same directory. No
  shared/root-level write.

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** (identical to the Phase 2A/2B/2C/2D baseline's known-good size — base firmware unchanged by this batch) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,831,378 bytes** (accepted run's size — sizes vary slightly between builds due to a commit/timestamp-derived version string embedded in the package, not a functional difference; the exact accepted-run size is confirmed, not assumed, by the finalization workflow's own download) |

Both artifacts exist only as GitHub Actions **workflow artifacts** for
run `28968511276` (not committed to the repository) — see
`docs/PHASE2E_3_ARTIFACT_MANIFEST.md` for the exact download locations
and retention window.

### Artifact hash finalization (Phase 2E.3)

| Field | Value |
|---|---|
| Artifact hashes generated | **PENDING** — will be generated by the `Phase 2E Finalize Baseline` GitHub Actions workflow once dispatched. See `docs/PHASE2E_3_ARTIFACT_HASHES.md`. This section will be patched (not silently rewritten) once real hashes exist. |
| Hash manifest file | `docs/PHASE2E_3_ARTIFACT_HASHES.md` (currently states PENDING) |
| CI artifact source | Run `28968511276` |

**No hash is fabricated here or in `docs/PHASE2E_3_ARTIFACT_HASHES.md`.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI
  run, not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** `image_viewer`,
  `boilerplate`, and `minesweeper` have no per-app section in any
  hardware smoke-test checklist yet — that remains entirely unexecuted.
- **This is not release-ready.** Release-readiness requires real
  hardware testing and the project's full release-gate checklist,
  neither of which this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 16 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2E ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2e-first-batch` at commit
`dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly (firmware, `updater_package`, and all 16 `.fap` outputs) with no
unreviewed safety-keyword hits. It does **not** mean the firmware has
been flashed to real hardware, that any app has been observed running,
or that this batch is release-ready. `fcc_id_lookup` remains deferred,
unresolved, and untouched.

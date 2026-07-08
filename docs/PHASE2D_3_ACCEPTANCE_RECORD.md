# Phase 2D — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2D
app-integration batch, covering exactly what has been verified and
nothing more. It does not authorize Phase 2E, does not claim hardware
testing, and does not claim release-readiness — see "Exact limitations"
and "Final acceptance classification" below. This document is updated in
place by the `Phase 2D Finalize Baseline` GitHub Actions workflow once
artifact hashes are generated; the pre-finalization state is recorded
honestly below and will be patched, not silently rewritten, when that
happens.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2d-first-batch` |
| CI-validated commit (SHA) | `d0812638a02c50389b9e713ad98f2c8215b75dd5` (the actual current branch HEAD at the time of this acceptance — chosen over the earlier `28938933924` run/commit specifically so the tagged commit and its hashed artifacts are the exact same state, not an intermediate one) |
| Workflow | Phase 2D Windows Validation |
| Accepted workflow run ID | `28941093859` |
| Accepted attempt | attempt 1 (an automatic run triggered by the push of this branch's own Phase 2D.2A documentation-mirroring commit — a docs-only change, no script/workflow edit — making this the **3rd consecutive independent post-fix pass**, on a 3rd different runner instance) |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28941093859 |
| Runner | GitHub-hosted `windows-latest` |
| CI conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`) | **success** |

**Why this run/commit instead of the `28938933924` run referenced during
Phase 2D.2A**: that run remains real, valid, twice-confirmed evidence (see
the CI remediation note below) and is not erased — but `28941093859`
validates the repository's actual current HEAD at acceptance time,
so the commit this record locks in and the commit whose artifacts get
hashed by the finalization workflow are identically the same state, with
no gap between them.

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation (firmware) | **PASS** |
| Build validation (`updater_package`) | **PASS** (after the Phase 2D.2A narrow `cmd /c` launch-mechanism remediation — see CI remediation note below) |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the accepted run's own job log,
`get_job_logs`, job `85863170307`): "Run Static validation" — conclusion
`success`, `12:04:39Z`–`12:04:45Z`; "Run Build validation" — conclusion
`success`, `12:04:45Z`–`12:11:48Z` (~7.1 minutes, consistent with a real
`fbt.cmd` build including toolchain bootstrap on a fresh runner). Real,
verbatim per-check output from this run:

```
[PASS        ] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)
             Exit code 0. Full log: .\reports\phase2d\build_updater_20260708_120446.log
[PASS        ] Artifact present: build\f7-firmware-C\firmware.dfu
             Size: 862825 bytes
[PASS        ] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz
             Size: 2783170 bytes
[PASS        ] Per-app FAP output verification
             All 13 expected .fap files found in D:\a\Custom-Flipper\Custom-Flipper\build\f7-firmware-C\.extapps
```

## Imported apps (3, Phase 2D tiny batch)

| App | appid | Category | License | Import commit |
|---|---|---|---|---|
| `resistors` | `resistance_calculator` | Tools | MIT | `621229a` |
| `crypto_dictionary` | `crypto_dict` | Tools/Educational | GPLv3 | `f9fcc57` |
| `2048` | `2048_improved` | Games | MIT | `52b1361` |

Combined with the 10 already-accepted Phase 2A/2B/2C apps
(`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`,
`chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`,
`docviewlite`), this CI run validates **13 apps total** — see
`tools/phase2d_validate_config.json`.

## Deferred apps (not part of this acceptance)

- **`fcc_id_lookup`** — deferred per `docs/PHASE2C_1_GO_NO_GO.md` on a
  license-evidence gap (no `LICENSE` file in the RogueMaster-vendored
  copy; strong but not commit-pinned corroborating MIT evidence at the
  true upstream repository). Not imported, not re-reviewed, not part of
  this batch's acceptance. See `docs/KNOWN_ISSUES.md` item 6.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`, `qrcode`, `barcode_gen`, `hex_viewer`,
  `image_viewer`, `minesweeper`, `boilerplate`** — hard-excluded or held
  in the clean candidate pool throughout Phase 2D per explicit
  instruction; none imported, none re-reviewed.

## License status

- **`resistors`**: **MIT, confirmed by direct read** of the app's own
  `LICENSE` file in Phase 2D.1 and re-verified byte-identical at actual
  import time in Phase 2D.2. Import scope excludes the upstream
  repository's `.flipcorg/`/`design/`/`img/`/`screenshots/` directories
  (non-build-input catalog/reference material, two files of unclear
  photographic provenance) — see `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md`.
- **`crypto_dictionary`**: **GPLv3, confirmed by direct read**, the same
  license as this project's own firmware base — the most direct
  compatibility case available. Bundles 14 original, non-copyrightable
  glossary reference files, no third-party attribution required.
- **`2048`**: **MIT, confirmed by direct read**. No bundled third-party
  content; `digits.h`'s pixel data is original.
- Full detail in `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md` and
  `docs/PHASE2D_THIRD_PARTY_NOTICES.md`.

## Safety scan status

**Zero** matches across all 15 `highConfidenceUnsafeKeywords`
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`) across all 13 apps. Any unreviewed match
against these 15 keywords is a hard CI **FAIL** by design — this run had
none.

## Reviewed-false-positive summary

The risky-keyword substring scan found **189 total matches** (the 139
already-reviewed Phase 2A/2B/2C matches, unchanged, plus 50 new matches
introduced by this batch's own source: 6 in `resistors` — all benign
`double`-substring hits, correcting Phase 2D.1's overstated "zero raw
substring matches" claim, see `docs/PHASE2D_2_SAFETY_REVIEW.md` — and 44
in `2048`, all benign `table`/`is_table_updated`-substring hits;
`crypto_dictionary` contributed zero new matches, since its only keyword
hits are inside its `LICENSE` file's GPLv3 boilerplate text, outside the
`.c`/`.h`/`.cpp` scan scope), and **all 189 resolved via the
reviewed-false-positive allowlist** in `tools/phase2d_validate_config.json`
— each entry individually keyed on exact file path + line number +
keyword + SHA-256 hash of the exact trimmed line text, so any future edit
to a matched line reverts it to unreviewed automatically. This is not a
blanket suppression of any keyword or directory. See
`docs/PHASE2D_2_SAFETY_REVIEW.md` for the full per-app detail.

## Storage behavior summary

- **`resistors`**: **Confirmed zero storage.** No `storage_`,
  `file_stream`, `FSAM_`, or `FSOM_` reference anywhere in `src/`.
- **`crypto_dictionary`**: **Confirmed read-only.** Opens its own
  bundled glossary files via `FSAM_READ`/`FSOM_OPEN_EXISTING` only; no
  write call exists anywhere in its source; no cryptographic operations
  on user data; no credential/wallet/seed/token/secret handling.
- **`2048`**: **App-scoped save**, confirmed at
  `/ext/apps_data/game_2048/game_2048.save`, built from a hardcoded
  literal path (not the idiomatic appid-based `APP_DATA_PATH` macro) plus
  a one-time, silently-no-op-on-fresh-install legacy-path migration
  check. Neither nuance is a shared/root-level write.

## CI remediation note (Phase 2D.2A)

The `updater_package` build sub-step initially appeared reproducibly
BLOCKED (2 of 3 real attempts on run `28906654889`, both preserved below
as failed history — never erased). A pivotal 4th real CI attempt
(`28925181640`, at a docs-only commit with no script change) then passed
in full using the exact same unmodified script, proving the failure was
**intermittent** (2 of 4 pre-fix attempts passed, ~50%), not
deterministic. A narrow remediation — non-secret diagnostics plus a
`cmd /c` launch-mechanism wrapper, scoped to the `updater_package` call
site only in `tools/phase2a_validate.ps1` — was then applied and
confirmed via **3 of 3 independent post-fix CI passes**: run
`28938933924` attempts 1 and 2 (2 different runner instances), and run
`28941093859` (a 3rd runner instance, at the actual current branch HEAD
— the run this acceptance record is built on). Full detail, including
the two preserved pre-fix failures, in
`docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md` and
`docs/PHASE2D_2A_CI_REMEDIATION_LOG.md`.

**Preserved failed pre-fix history (never erased)**:

| Run | Attempt | Result |
|---|---|---|
| `28906654889` | 1 | `updater_package` **BLOCKED** ("fbt.cmd could not be launched as a process") |
| `28906654889` | 2 (rerun, different runner) | `updater_package` **BLOCKED** (identical failure) |

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** (identical to the Phase 2A/2B/2C baseline's known-good size — base firmware unchanged by this batch) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,783,170 bytes** (accepted run's size — sizes varied slightly across post-fix attempts, 2,784,400 / 2,783,411 / 2,783,170 bytes, due to a commit/timestamp-derived version string embedded in the package, not a functional difference; the exact accepted-run size is confirmed, not assumed, by the finalization workflow's own download) |

Both artifacts exist only as GitHub Actions **workflow artifacts** for
run `28941093859` (not committed to the repository) — see
`docs/PHASE2D_3_ARTIFACT_MANIFEST.md` for the exact download locations
and retention window.

### Artifact hash finalization (Phase 2D.3)

| Field | Value |
|---|---|
| Artifact hashes generated | **PENDING** — the `Phase 2D Finalize Baseline` GitHub Actions workflow has been created in this phase and will be run to generate real, independently-computed SHA-256 hashes of the actual `firmware.dfu` and updater `.tgz` files from run `28941093859`. This section will be patched (not silently rewritten) with the real result once that workflow completes. |
| Hash manifest file | `docs/PHASE2D_3_ARTIFACT_HASHES.md` (currently states PENDING; see that file for the authoritative up-to-date status) |
| CI artifact source | Run `28941093859` |

**No hash is fabricated here or in `docs/PHASE2D_3_ARTIFACT_HASHES.md`.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI
  run, not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** `resistors`,
  `crypto_dictionary`, and `2048` have no per-app section in any hardware
  smoke-test checklist yet — that remains entirely unexecuted.
- **This is not release-ready.** Release-readiness requires real
  hardware testing and the project's full release-gate checklist,
  neither of which this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 13 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2D ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2d-first-batch` at commit
`d0812638a02c50389b9e713ad98f2c8215b75dd5` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly (firmware, `updater_package`, and all 13 `.fap` outputs) with no
reviewed-but-unaddressed risky findings. It does **not** mean
hardware-tested, release-ready, or approved for any further scope
expansion — see `docs/PHASE2D_NEXT_GATE.md` for what is and is not
authorized from here.

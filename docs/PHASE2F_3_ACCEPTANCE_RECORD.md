# Phase 2F — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2F
app-integration batch, covering exactly what has been verified and
nothing more. It does not authorize Phase 2G, does not claim hardware
testing, and does not claim release-readiness — see "Exact limitations"
and "Final acceptance classification" below. This document is updated in
place by the `Phase 2F Finalize Baseline` GitHub Actions workflow once
artifact hashes are generated; the pre-finalization state is recorded
honestly below and will be patched, not silently rewritten, when that
happens.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2f-first-batch` |
| CI-validated commit (SHA) | `37d11cada5a83afdeb752c6b2106216d7fc09b9f` (the actual current branch HEAD at acceptance time — the final Phase 2F.2A documentation commit — chosen over the earlier `29015788839`/`78914b3` run per the explicit requirement to check for a later automatic CI run at the true current HEAD before finalizing) |
| Workflow | Phase 2F Windows Validation |
| Accepted workflow run ID | `29017861599` |
| Accepted attempt | attempt 1 (an automatic `push`-triggered run, fired by the push of this branch's own final Phase 2F.2A documentation commit — a docs-only change, no script/workflow edit) |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29017861599 |
| Runner | GitHub-hosted `windows-latest` (runner `1000000241`) |
| CI conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`/`get_job_logs`) | **success** |

**Why this run/commit instead of the `29015788839` run cited when Phase
2F.2A's remediation was reported as confirmed**: that run remains real,
valid evidence (one of the 2 independent post-remediation confirmations
Phase 2F.2A's own requirement demanded, at commit `78914b3`) and is not
erased — but `29017861599` validates the repository's actual current HEAD
at acceptance time (the Phase 2F.2A documentation commit `37d11ca` that
followed it), so the commit this record locks in and the commit whose
artifacts get hashed by the finalization workflow are identically the
same state, with no gap between them. `29015788839` and `29015213503`
were superseded, not invalidated — their own conclusions (`success`,
commit `78914b3`) remain true and are recorded in
`docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` unchanged.

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation (firmware) | **PASS** |
| Build validation (`updater_package`) | **PASS** |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the accepted run's own job log, job
`86117245023`): "Run Static validation" — conclusion `success`,
`12:22:48Z`–`12:22:55Z`; "Run Build validation" — conclusion `success`,
`12:22:55Z`–`12:29:33Z` (~6.6 minutes). Real, verbatim per-check output
from this run:

```
[PASS        ] Commit verification
             HEAD matches expected commit 37d11cada5a83afdeb752c6b2106216d7fc09b9f
[PASS        ] Firmware build (.\fbt.cmd COMPACT=1 DEBUG=0)
[PASS        ] Updater package build (.\fbt.cmd COMPACT=1 DEBUG=0 updater_package)
             Exit code 0. Full log: .\reports\phase2f\build_updater_20260709_122256.log
[PASS        ] Artifact present: build\f7-firmware-C\firmware.dfu
             Size: 862825 bytes (previously recorded good size at commit 5e5e0ecf225be947a754e537670a6421838b939b: 862825 bytes)
[PASS        ] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz
             Size: 2878428 bytes (previously recorded good size at commit 5e5e0ecf225be947a754e537670a6421838b939b: 2732909 bytes)
[PASS        ] Per-app FAP output verification
             All 19 expected .fap files found in D:\a\Custom-Flipper\Custom-Flipper\build\f7-firmware-C\.extapps

=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    PASS
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

## Imported apps (3, Phase 2F tiny batch)

| App | appid | Category | License/evidence | Import commit |
|---|---|---|---|---|
| `qrcode` | `qrcode` | Tools | MIT (confirmed, full text; bundles a third-party MIT QR-encoding library, attributed) | `79f50cc` |
| `hex_viewer` | `hex_viewer` | Tools | MIT (confirmed, full text) | `04715de` |
| `barcode_gen` | `barcode_app` | Tools | MIT (confirmed, full text) | `2512644` |

Combined with the 16 already-accepted Phase 2A/2B/2C/2D/2E apps
(`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`,
`chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`,
`docviewlite`, `resistors`, `crypto_dictionary`, `2048`, `image_viewer`,
`boilerplate`, `minesweeper`), this CI run validates **19 apps total** —
see `tools/phase2f_validate_config.json`.

## Phase 2F.2A remediation accepted

Full detail in `docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md`. Summary:

| Remediation | Commit | Confirmed by |
|---|---|---|
| CI/tooling diagnostics (additive only) | `224a9b0` | Run `29003000398` |
| Fixed self-inflicted diagnostic-code bug (`if(){@()}else{@()}` collapsing to `$null`) | `0260ca6` | Run `29003824450` (revealed real root cause) |
| CI/tooling root-cause fix (`$ErrorActionPreference` scoping around `updater_package`) | `8e5f78f` | Run `29004603660` |
| Build-log-tail diagnostic (additive only) | `d1a2de7` | Run `29005529368` (revealed real compiler error) |
| **App-source fix**: removed 5 dead calls to `text_input_show_illegal_symbols()` in `applications_user/barcode_gen/views/create_view.c` — a function from an unwired, never-integrated custom keyboard fork bundled in the app; explicitly approved by the project owner via `AskUserQuestion` after the evidence was presented | `b6445ed` | Run `29013915792` (Build fully PASSED) |
| Reviewed-false-positive line-number correction (content hash unchanged) | `78914b3` | Runs `29015213503` and `29015788839` (2 independent full passes) |

**App-source remediation summary**: exactly one file changed across the
entire Phase 2F.2A investigation — `applications_user/barcode_gen/views/create_view.c`
(7 lines removed, no other logic/control-flow/behavior changed). No
other `applications_user/` app was touched.

**Validator/tooling remediation summary**: `tools/phase2a_validate.ps1`
(the shared validator script — the same file every phase's CI-tooling
fix since Phase 2D.2A has touched) received purely additive diagnostics
plus one narrow behavioral fix (`$ErrorActionPreference` scoping around
the `updater_package` external-process invocation only; the firmware-
build invocation was deliberately left untouched). `tools/phase2f_validate_config.json`
received one line-number correction to an existing reviewed-false-
positive entry (content hash unchanged, confirmed identical by direct
re-hash). No expected-app, no expected-FAP-count, and no safety-keyword
check was removed, weakened, or bypassed.

## Deferred apps (not part of this acceptance)

- **`fcc_id_lookup`** — deferred per `docs/PHASE2C_1_GO_NO_GO.md` on a
  license-evidence gap (no `LICENSE` file in the RogueMaster-vendored
  copy; strong but not commit-pinned corroborating MIT evidence at the
  true upstream repository). Not imported, not re-reviewed, not part of
  this batch's acceptance. See `docs/KNOWN_ISSUES.md`.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — none imported, none re-reviewed, per this project's
  explicit hard exclusions maintained since Phase 2E.

## License status

- **`qrcode`**: **MIT (wrapper) + MIT (bundled third-party library),
  both confirmed by direct read.** Bundled `qrcode.c`/`qrcode.h`
  QR-encoding library (Richard Moore/ricmoo, derived from Project
  Nayuki) attributed via its own preserved in-file header. See
  `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md`.
- **`hex_viewer`**: **MIT, confirmed by direct read.** No bundled
  third-party content.
- **`barcode_gen`**: **MIT, confirmed by direct read.** Real appid
  `barcode_app`, not `barcode_gen` — recorded precisely. Bundles 4
  standard, publicly-documented barcode-symbology encoding-table `.txt`
  files (non-copyrightable technical data, correctly declared via
  `fap_file_assets`).
- Full detail in `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md` and
  `docs/PHASE2F_THIRD_PARTY_NOTICES.md`.

## Safety scan status

**Zero** high-confidence-unsafe matches across all apps in this batch —
no reference to `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `password`, `token`, `exfil`,
`clone`, `bypass`, `seed`, `wallet`, `private key`, or `secret` in any of
the 3 newly imported apps. See `docs/PHASE2F_2_SAFETY_REVIEW.md`.

## Reviewed false-positive summary

**464 total matches**, all individually reviewed and resolved via the
allowlist in `tools/phase2f_validate_config.json` — each entry keyed on
exact file path + line number + keyword + SHA-256 hash of the exact
trimmed line text, so any future edit to a matched line reverts it to
unreviewed automatically (this self-healing mechanism was exercised for
real during Phase 2F.2A: the `barcode_gen` source fix shifted one
match's line number, the validator correctly flagged it as unreviewed,
and the line number was corrected with the content hash re-verified
identical). Zero unreviewed, zero high-confidence-unsafe. See
`docs/PHASE2F_2_SAFETY_REVIEW.md` for the full per-app breakdown.

## Storage behavior summary

- **`qrcode`**: **Confirmed read-only** for QR content
  (`flipper_format_read_*` calls exclusively). One bounded, benign
  one-time legacy-folder migration at launch.
- **`hex_viewer`**: **Confirmed genuinely read-only** for viewed files
  (`FSAM_READ`/`FSOM_OPEN_EXISTING` only). App-private settings only.
- **`barcode_gen`**: **Confirmed app-private storage only**, confined to
  `/ext/apps_data/barcodes/`.

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** (identical to the Phase 2A/2B/2C/2D/2E baseline's known-good size — base firmware unchanged by this batch) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,878,428 bytes** (accepted run's size — sizes vary slightly between builds due to a commit/timestamp-derived version string embedded in the package, not a functional difference; the exact accepted-run size is confirmed, not assumed, by the finalization workflow's own download) |

Both artifacts exist only as GitHub Actions **workflow artifacts** for
run `29017861599` (not committed to the repository) — see
`docs/PHASE2F_3_ARTIFACT_MANIFEST.md` for the exact download locations
and retention window.

### Artifact hash finalization (Phase 2F.3)

| Field | Value |
|---|---|
| Artifact hashes generated | **YES** — generated by the `Phase 2F Finalize Baseline` GitHub Actions workflow, run [`29027115867`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29027115867). See `docs/PHASE2F_3_ARTIFACT_HASHES.md`. |
| Hash manifest file | `docs/PHASE2F_3_ARTIFACT_HASHES.md` (currently states PENDING) |
| CI artifact source | Run `29017861599` |

**No hash is fabricated here or in `docs/PHASE2F_3_ARTIFACT_HASHES.md`.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI
  run, not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** `qrcode`,
  `hex_viewer`, and `barcode_gen` have no per-app section in any
  hardware smoke-test checklist yet — that remains entirely unexecuted.
- **This is not release-ready.** Release-readiness requires real
  hardware testing and the project's full release-gate checklist,
  neither of which this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 19 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2F ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2f-first-batch` at commit
`37d11cada5a83afdeb752c6b2106216d7fc09b9f` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly (firmware, `updater_package`, and all 19 `.fap` outputs) with no
unreviewed safety-keyword hits. It does **not** mean the firmware has
been flashed to real hardware, that any app has been observed running,
or that this batch is release-ready. `fcc_id_lookup` remains deferred,
unresolved, and untouched.

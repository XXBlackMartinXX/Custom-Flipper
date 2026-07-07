# Phase 2C — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2C
app-integration batch, covering exactly what has been verified and
nothing more. It does not authorize Phase 2D, does not claim hardware
testing, and does not claim release-readiness — see "Exact limitations"
and "Final acceptance classification" below. This document is updated in
place by the `Phase 2C Finalize Baseline` GitHub Actions workflow once
artifact hashes are generated; the pre-finalization state is recorded
honestly below and will be patched, not silently rewritten, when that
happens.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2c-first-batch` |
| CI-validated commit (SHA) | `969054ee9f802f72be1064a62052c4be82a91783` |
| Workflow | Phase 2C Windows Validation |
| Workflow run ID | `28897702247` |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28897702247 |
| Runner | GitHub-hosted `windows-latest` |
| CI conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`) | **success** |

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation | **PASS** |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the run's own job log, `get_job_logs`): "Run
Static validation" — conclusion `success`, `20:55:55Z`–`20:56:00Z`; "Run
Build validation" — conclusion `success`, `20:56:00Z`–`21:02:49Z` (~6.8
minutes, consistent with a real `fbt.cmd` build including toolchain
bootstrap on a fresh runner, not a skipped/faked step, and comparable to
Phase 2A's ~5-minute and Phase 2B's ~6.5-minute CI build durations).

## Imported apps (2, Phase 2C reduced tiny batch)

| App | appid | Category | License | Import commit |
|---|---|---|---|---|
| `sd_info` | `sd_info` | Tools | GPLv3 | `4e17278` |
| `docviewlite` | `docviewlite` | Tools | MIT | `4fab909` |

Combined with the 8 already-accepted Phase 2A/2B apps (`network_subnet`,
`programmer_calc`, `vin_decoder`, `flipper95`, `chess`, `flipfetch`,
`quadratic_solver`, `sudoku`), this CI run validates **10 apps total** —
see `tools/phase2c_validate_config.json`.

## Deferred apps (not part of this acceptance)

- **`fcc_id_lookup`** — deferred per `docs/PHASE2C_1_GO_NO_GO.md` on a
  license-evidence gap (no `LICENSE` file in the RogueMaster-vendored
  copy; strong but not commit-pinned corroborating MIT evidence at the
  true upstream repository). Not imported, not part of this batch's
  acceptance. See `docs/KNOWN_ISSUES.md` item 6.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — hard-excluded throughout Phase 2C per explicit
  instruction, unchanged from their Phase 2B status.

## License status

- **`sd_info`**: **GPLv3, confirmed by direct read** of the app's own
  `LICENSE` file in Phase 2C.1 and re-verified byte-identical (same
  SHA-256) at actual import time in Phase 2C.2. Full, unmodified FSF
  license text. The same license as this project's own firmware base —
  the most direct compatibility case available.
- **`docviewlite`**: **MIT, confirmed by direct read**, same
  re-verification discipline. Full, unmodified MIT text, GPLv3-compatible.
- Neither app bundles third-party code. Full detail in
  `docs/PHASE2C_2_LICENSE_ATTRIBUTION.md` and
  `docs/PHASE2C_THIRD_PARTY_NOTICES.md`.

## Safety scan status

**Zero** matches across all 15 `highConfidenceUnsafeKeywords`
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`) across all 10 apps. Any unreviewed match
against these 15 keywords is a hard CI **FAIL** by design — this run had
none.

## Reviewed-false-positive summary

The risky-keyword substring scan found **139 total matches** (the 138
already-reviewed Phase 2A/2B matches, unchanged, plus 1 new match
introduced by this batch's own source: `sd_info` contributed 4
`ble`-substring hits — lines 121/163/164 inside `"double"`, line 489
inside `"enabled"` — and `docviewlite` contributed 25 `ble`-substring hits,
of which line 86 was the one genuinely new entry added to the config in
this phase; the remaining 24 in `docviewlite` and all 4 in `sd_info` were
scanned and reviewed together as part of this same phase's config
addition), and **all 139 resolved via the reviewed-false-positive
allowlist** in `tools/phase2c_validate_config.json` — each entry
individually keyed on exact file path + line number + keyword + SHA-256
hash of the exact trimmed line text, so any future edit to a matched line
reverts it to unreviewed automatically. This is not a blanket suppression
of any keyword or directory. See `docs/PHASE2C_2_SAFETY_REVIEW.md` for
the full per-app detail.

## Storage behavior summary

- **`sd_info`**: **Real, but controlled.** Performs a transient,
  self-cleaning, explicitly user-initiated SD-card read/write/delete
  benchmark at `/ext/sdtest.tmp*` (SD-card root, not app-private, not
  persistent, not automatic). This corrects the original Phase 2C
  planning-phase assumption of "zero storage" — recorded honestly, not
  smoothed over, in `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` and
  `docs/PHASE2C_2_SAFETY_REVIEW.md`.
- **`docviewlite`**: **Confirmed read-only.** Opens and reads a
  user-selected `.txt` file via the standard file-browser dialog; no
  write call exists anywhere in its source.

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** (identical to the Phase 2A/2B baseline's known-good size — base firmware unchanged by this batch) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,757,340 bytes** |

Both artifacts exist only as GitHub Actions **workflow artifacts** for run
`28897702247` (not committed to the repository) — see
`docs/PHASE2C_3_ARTIFACT_MANIFEST.md` for the exact download locations and
retention window. The updater package size differs from the Phase 2B
baseline (2,742,659 bytes) — expected, not a defect: it now embeds 2
additional compiled FAPs plus a commit-derived version string, so a larger
size at a different, larger commit is normal, per the same reasoning
already documented for every prior build-size difference.

### Artifact hash finalization (Phase 2C.3)

| Field | Value |
|---|---|
| Artifact hashes generated | **PENDING** — the `Phase 2C Finalize Baseline` GitHub Actions workflow has been created in this phase and will be run to generate real, independently-computed SHA-256 hashes of the actual `firmware.dfu` and updater `.tgz` files from run `28897702247`. This section will be patched (not silently rewritten) with the real result once that workflow completes. |
| Hash manifest file | `docs/PHASE2C_3_ARTIFACT_HASHES.md` (currently states PENDING; see that file for the authoritative up-to-date status) |
| CI artifact source | Run `28897702247` |

**No hash is fabricated here or in `docs/PHASE2C_3_ARTIFACT_HASHES.md`.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI
  run, not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** `sd_info` and
  `docviewlite` have no per-app section in any hardware smoke-test
  checklist yet — that remains entirely unexecuted.
- **This is not release-ready.** Release-readiness requires real
  hardware testing and the project's full release-gate checklist,
  neither of which this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 10 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2C ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2c-first-batch` at commit
`969054ee9f802f72be1064a62052c4be82a91783` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly with no reviewed-but-unaddressed risky findings. It does **not**
mean hardware-tested, release-ready, or approved for any further scope
expansion — see `docs/PHASE2C_NEXT_GATE.md` for what is and is not
authorized from here.

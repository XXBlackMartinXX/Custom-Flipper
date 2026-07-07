# Phase 2B — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2B
app-integration batch, covering exactly what has been verified and nothing
more. It does not authorize Phase 2C, does not claim hardware testing, and
does not claim release-readiness — see "Exact limitations" and "Final
acceptance classification" below. This document is updated in place by the
`Phase 2B Finalize Baseline` GitHub Actions workflow once artifact hashes
are generated; the pre-finalization state is recorded honestly below and
will be patched, not silently rewritten, when that happens.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2b-first-batch` |
| CI-validated commit (SHA) | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` |
| Workflow | Phase 2B Windows Validation |
| Workflow run ID | `28877810474` |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474 |
| Runner | GitHub-hosted `windows-latest` |
| CI conclusion (verified via GitHub API, `get_workflow_run`/`list_workflow_jobs`) | **success** |

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation | **PASS** |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the run's own job log, `get_job_logs`): "Run
Static validation" — conclusion `success`, `15:24:38Z`–`15:24:41Z`; "Run
Build validation" — conclusion `success`, `15:24:41Z`–`15:31:06Z` (~6.5
minutes, consistent with a real `fbt.cmd` build including toolchain
bootstrap on a fresh runner, not a skipped/faked step, and comparable to
Phase 2A's own ~5-minute CI build duration).

## Imported apps (3, Phase 2B tiny batch)

| App | appid | Category | Import commit |
|---|---|---|---|
| `flipfetch` | `flipfetch` | Tools | `e6d4286` |
| `quadratic_solver` | `quadratic_solver` | Tools | `367bdb9` |
| `sudoku` | `sudoku` | Games | `2c6ff1c` |

Combined with the 5 already-accepted Phase 2A apps (`network_subnet`,
`programmer_calc`, `vin_decoder`, `flipper95`, `chess`), this CI run
validates **8 apps total** — see `tools/phase2b_validate_config.json`.

## License status

All 3 Phase 2B apps: **MIT, confirmed by direct read** of each app's own
`LICENSE` file in Phase 2B.1/2B.2 (not inferred). No bundled third-party
code in any of the 3. Full detail in
`docs/PHASE2B_2_LICENSE_ATTRIBUTION.md` and
`docs/PHASE2B_THIRD_PARTY_NOTICES.md`.

## Safety scan status

**Zero** matches across all 15 `highConfidenceUnsafeKeywords`
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`) across all 8 apps. Any unreviewed match
against these 15 keywords is a hard CI **FAIL** by design — this run had
none.

## Reviewed-false-positive summary

The risky-keyword substring scan found **110 total matches** (the 104
already-reviewed Phase 2A matches, unchanged, plus 6 new ones introduced
by the 3 Phase 2B apps: 5 `ble`-substring hits in `quadratic_solver`
— lines 36/77/81/85 inside `"double"`, line 218 inside `"enabled"` — and
1 in `sudoku` — line 674 inside `"enabled"`), and **all 110 resolved via
the reviewed-false-positive allowlist** in
`tools/phase2b_validate_config.json` — each entry individually keyed on
exact file path + line number + keyword + SHA-256 hash of the exact
trimmed line text (computed with the validator's own `Get-LineSha256`
against the actual imported files), so any future edit to a matched line
reverts it to unreviewed automatically. This is not a blanket suppression
of any keyword or directory. See `docs/PHASE2B_2_SAFETY_REVIEW.md` for
the full per-app detail.

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** (identical to the Phase 2A-only baseline's known-good size — base firmware unchanged by this batch) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,742,659 bytes** |

Both artifacts exist only as GitHub Actions **workflow artifacts** for run
`28877810474` (not committed to the repository) — see
`docs/PHASE2B_3_ARTIFACT_MANIFEST.md` for the exact download locations and
retention window. The updater package size differs from the Phase 2A-only
baseline (2,732,909/2,733,074 bytes) — expected, not a defect: it now
embeds 3 additional compiled FAPs plus a commit-derived version string, so
a larger size at a different, larger commit is normal, per the same
reasoning already documented for every prior Phase 2A build-size
difference.

### Artifact hash finalization (Phase 2B.3)

| Field | Value |
|---|---|
| Artifact hashes generated | **PENDING** — the `Phase 2B Finalize Baseline` GitHub Actions workflow has been created in this phase and will be run to generate real, independently-computed SHA-256 hashes of the actual `firmware.dfu` and updater `.tgz` files from run `28877810474`. This section will be patched (not silently rewritten) with the real result once that workflow completes. |
| Hash manifest file | `docs/PHASE2B_3_ARTIFACT_HASHES.md` (currently states PENDING; see that file for the authoritative up-to-date status) |
| CI artifact source | Run `28877810474` |

**No hash is fabricated here or in `docs/PHASE2B_3_ARTIFACT_HASHES.md`.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI run,
  not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** The steps in
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` (which now needs 3 more
  per-app sections for the new apps, not yet added) remain entirely
  unexecuted for `flipfetch`, `quadratic_solver`, and `sudoku`.
- **This is not release-ready.** Release-readiness requires real hardware
  testing and the project's full release-gate checklist, neither of which
  this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 8 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2B ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2b-first-batch` at commit
`50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly with no reviewed-but-unaddressed risky findings. It does **not**
mean hardware-tested, release-ready, or approved for any further scope
expansion — see `docs/PHASE2B_NEXT_GATE.md` for what is and is not
authorized from here.

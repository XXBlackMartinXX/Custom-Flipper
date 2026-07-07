# Phase 2A — Acceptance Record

Docs only. This is the formal, locked acceptance record for the Phase 2A
app-integration batch, covering exactly what has been verified and nothing
more. It does not authorize Phase 2B, does not claim hardware testing, and
does not claim release-readiness — see "Exact limitations" and "Final
acceptance classification" below.

## What is being accepted

| Field | Value |
|---|---|
| Branch | `integration/phase2a-first-batch` |
| CI-validated commit (SHA) | `718eec5fe115c9e0467a8d07d974947a85b27cf6` |
| Workflow | Phase 2A Windows Validation |
| Workflow run ID | `28814008347` |
| Workflow run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347 |
| Runner | GitHub-hosted `windows-latest` |
| CI conclusion (verified via GitHub API, `get_workflow_run`) | **success** |

## Validation results

| Track | Result |
|---|---|
| Static validation | **PASS_WITH_REVIEWED_FALSE_POSITIVES** |
| Build validation | **PASS** |
| Hardware-assisted validation | **NOT_RUN** |

Per-step confirmation (from the run's own job log, `get_workflow_jobs`):
"Run Static validation" — conclusion `success`; "Run Build validation" —
conclusion `success`, ran 18:28:41–18:33:32 UTC (~5 minutes, consistent with
a real `fbt.cmd` build including toolchain bootstrap on a fresh runner, not a
skipped/faked step).

## Artifacts

| Artifact | Path | Size |
|---|---|---|
| Firmware | `build\f7-firmware-C\firmware.dfu` | **862,825 bytes** |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` | **2,733,074 bytes** |

Both artifacts exist only as GitHub Actions **workflow artifacts** for run
`28814008347` (not committed to the repository) — see
`docs/PHASE2A_ARTIFACT_MANIFEST.md` for the exact download locations and
retention window. The updater package size differs slightly from the
previously-recorded manual-Windows-build size (2,732,909 bytes at commit
`5e5e0ecf...`) and the prior CI run's size (2,732,904 bytes at commit
`6920b408...`) — expected, not a defect: each is a different commit, and the
updater package embeds a commit-derived version string, so a few-byte
difference between different commits' packages is normal (see
`PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`'s Phase 2A.8 section for the same
reasoning applied to the prior run).

### Artifact hash finalization (Phase 2A.10)

| Field | Value |
|---|---|
| Artifact hashes generated | **NO** — attempted, blocked by environment network policy (see below) |
| Hash manifest file | `docs/PHASE2A_ARTIFACT_HASHES.md` |
| CI artifact source | Run `28814008347` |

Phase 2A.10 attempted to download both artifacts from run `28814008347` in
order to compute real, independently-verified SHA-256 hashes of the actual
`firmware.dfu` and updater `.tgz` files. This session's network egress
policy blocks the Azure Blob Storage host GitHub Actions artifact downloads
always redirect to (`productionresultssa12.blob.core.windows.net`) —
confirmed by a direct `403` on the redirected download URL and by this
session's own proxy status endpoint recording the same rejected host. This
is the same class of environment limitation as the Flipper-toolchain-host
block documented elsewhere in this project, not a defect in the artifacts,
the firmware, or the apps. **`docs/PHASE2A_ARTIFACT_HASHES.md` records this
plainly and gives the exact steps to generate real hashes on a machine with
network access to GitHub — no hash value is fabricated here or there.**
Hardware testing remains **NOT PERFORMED**; release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unaffected by whether hash
finalization has happened yet.

## Phase 2A apps included (5, unchanged since import)

| App | appid | Category |
|---|---|---|
| `network_subnet` | `network_subnet` | Tools |
| `programmer_calc` | `programmercalc` | Tools |
| `vin_decoder` | `vin_decoder` | Tools |
| `flipper95` | `flipper95` | Tools |
| `chess` | `chess` | Games |

Per-app FAP verification: **PASS** (all 5 `.fap` outputs confirmed present
under `build\f7-firmware-C\.extapps\` by this CI run).

## SAM removal status

**PASS.** `applications_user/chess`'s SAM text-to-speech component
(unclear/no valid open-source license — see
`PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`) was removed entirely in commit
`6359f87`, prior to this branch's current tip. This CI run re-confirmed zero
remaining `sam`/`stm32_sam`/`flipchess_voice`/`speech`/`voice` references
anywhere in `chess`.

## Reviewed-false-positive policy summary

The risky-keyword substring scan found its now-standard **104 matches**
(102 `ble`, 2 `jam`), and **all 104 resolved via the reviewed-false-positive
allowlist** in `tools/phase2a_validate_config.json` — each entry individually
keyed on exact file path + line number + keyword + SHA-256 hash of the exact
trimmed line text, so any future edit to a matched line reverts it to
unreviewed automatically. This is not a blanket suppression of any keyword or
directory; see `PHASE2A_AUTOMATED_VALIDATION.md`'s "Reviewed-false-positive
allowlist" section for the full mechanism, and
`PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`'s "Phase 2A.8" section for how and
why it was added.

## High-confidence unsafe API/capability result

**Zero matches**, across all 15 keywords in `highConfidenceUnsafeKeywords`
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`), except the 2 already-reviewed `jam` hits (a
VIN manufacturer code and a surname, neither jamming behavior). Any
unreviewed match against these 15 keywords is a hard CI **FAIL** by design —
this run had none.

## Exact limitations

- **No hardware flashing/testing has been performed.** Not by this CI run,
  not by any AI session, not by this acceptance record.
- **No GUI/manual smoke test has been performed.** The steps in
  `PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` remain entirely unexecuted.
- **This is not release-ready.** Release-readiness requires real hardware
  testing and the project's full release-gate checklist, neither of which
  this record covers.
- **This is test-ready only.** The firmware compiles cleanly, its static
  source properties are verified, and its 5 apps produce valid `.fap`
  outputs — nothing more is claimed.

## Final acceptance classification

**PHASE 2A ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY**

This means: the source, build, and static-analysis state of
`integration/phase2a-first-batch` at commit `718eec5` is locked in as a known,
CI-verified baseline that a real GitHub-hosted Windows runner can compile
cleanly with no reviewed-but-unaddressed risky findings. It does **not** mean
hardware-tested, release-ready, or approved for any further scope expansion —
see `docs/PHASE2A_NEXT_GATE.md` for what is and is not authorized from here.

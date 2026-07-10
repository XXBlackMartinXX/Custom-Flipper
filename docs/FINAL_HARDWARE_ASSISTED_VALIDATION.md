# Final Hardware-Assisted Validation — What This Checks and Does Not Check

Docs-only. Explains `tools/final_hardware_gate.ps1` and
`tools/final_hardware_gate_config.json`, the final 20-app
hardware-assisted validation gate for the accepted baseline (commit
`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`, CI run `29068148596`,
finalization run `29096377711`). It is modeled directly on
`tools/phase2f_hardware_gate.ps1` (and, before it,
`tools/phase2a_hardware_gate.ps1` through `tools/phase2e_hardware_gate.ps1`,
all six of which remain untouched and still valid for their own accepted
baselines).

## What this checks

**Automated, repo-level checks (no hardware required):**

- Current branch matches `integration/fcc-id-lookup-one-app-import`.
- Current commit matches the accepted baseline commit
  `86265727b5b8cfce5086eb88f8bb93d0169ab9a9`.
- Working tree is clean (`git status --short` empty).
- `applications_user/image_viewer/example_images/` remains absent (the
  excluded `cat.bm`/`dolphin.bm`/`spongebob.bm` demo images must not be
  reintroduced).
- `applications_user/barcode_gen/views/create_view.c` does not contain a
  call to `text_input_show_illegal_symbols` (the Phase 2F.2A source fix,
  commit `b6445ed`, remains preserved).
- `applications_user/fcc_id_lookup/LICENSE` is present and contains the
  expected copyright line (the upstream MIT license added at import
  time remains preserved).
- No `*.bin` file exists anywhere under
  `applications_user/fcc_id_lookup/` (the optional FCC frequency
  database was never bundled and remains absent).

**Artifact hash verification (`-Mode HashVerify` or `HardwareAssisted`
with `-ArtifactDir`):**

- Compares a locally-downloaded artifact directory's actual
  `firmware.dfu` and `flipper-z-f7-update-local.tgz` files, by size and
  SHA-256, against the real values recorded in
  `docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md` (862,833 bytes /
  `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` for
  firmware; 2,891,859 bytes /
  `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` for
  the updater).

**Hardware-connected checks (`-Mode DetectDevice` or
`HardwareAssisted`, still read-only):**

- Safe, PnP-based detection of a connected Flipper Zero
  (`Get-PnpDevice`, matching on friendly name and VID/PID) — no serial
  communication, no RPC, no data exchange with the device.
- Best-effort detection of installed qFlipper (PATH, common install
  directories, Windows uninstall registry).

**Flash confirmation gate (`-Mode HardwareAssisted -AllowFlashPrompt`
only):** displays the accepted artifact hashes and a rollback warning,
then requires an operator to type an exact confirmation phrase before
the report records that a *manual* flash may proceed — the script never
performs the flash itself, under any flag combination.

## What this does not check

- **Anything requiring the device screen.** App menu visibility,
  launch, navigation, input handling, and exit behavior are always
  marked `REQUIRES_HUMAN_OBSERVATION` and never simulated or assumed.
  See `docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`.
- **Whether a storage write actually lands where expected on a real SD
  card.** The script can only assert what the *source* does (already
  audited in `docs/STORAGE_AND_DATA_BEHAVIOR_AUDIT.md`); confirming it
  on-device requires a human running the smoke test and inspecting the
  card.
- **Crashes, reboots, freezes, or unexpected hardware activation** (RF
  LEDs, etc.) during use — these require a human watching the device.
- **Any RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR behavior of any
  app.** This script contains no code path for any of these, for any
  app, under any mode or flag — not a disabled feature, simply not
  implemented.
- **Cloning, brute force, jamming, deauth, bypass, HID injection,
  credential extraction, or any other unauthorized-access/security-abuse
  behavior.** Same as above — no code path exists.
- **The flash itself.** Even with `-AllowFlashPrompt` and a correctly
  typed confirmation phrase, the script only records that the operator
  intends to flash manually afterward, using qFlipper or `fbt
  flash_usb` — it never writes to the device.

## Accepted baseline and artifact hashes

| Field | Value |
|---|---|
| Accepted branch | `integration/fcc-id-lookup-one-app-import` |
| Accepted commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` |
| Accepted CI run | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) |
| Finalization run | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) |
| `firmware.dfu` | 862,833 bytes, SHA-256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` |
| `flipper-z-f7-update-local.tgz` | 2,891,859 bytes, SHA-256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` |
| Custom app count | 20 |

## Safety exclusions

This gate's script contains no code path for: Sub-GHz/RF transmit or
receive, NFC read/write/emulate/clone, RFID/LFRFID read/write/emulate/
clone, iButton read/write/emulate/clone, BadUSB/HID keystroke injection,
BLE spam/beacon/profile interaction, direct GPIO control, infrared
transmit, credential/token/password handling or extraction, or any
cloning/brute-force/jamming/deauth/bypass/unauthorized-access behavior.
This is enforced by omission, not by a disable-able flag — grep the
script yourself to confirm.

## Artifact hash verification

`-Mode HashVerify -ArtifactDir "<path>"` compares real, downloaded
artifact files against the accepted baseline's real hashes above. A
mismatch of either size or hash produces a `FAIL` result and an
explicit "Do not proceed to a flash with this artifact" warning. This
project's cloud sandbox environment cannot download GitHub Actions
artifacts (confirmed blocked, Azure Blob Storage redirect returns 403) —
so real hash verification can only be run on a machine with real network
access to GitHub Actions artifact downloads.

## Device detection

`-Mode DetectDevice` uses `Get-PnpDevice` (Windows-only) to look for a
USB device matching Flipper Zero's known friendly name / VID:PID
(`VID_0483&PID_5740`). On a non-Windows environment, this fails cleanly
with a `BLOCKED` result explaining that Windows is required — it never
fabricates a "device found" result.

## Flashing limitations

This script **never flashes a device**, under any mode or flag
combination, including `-Mode HardwareAssisted -AllowFlashPrompt`. The
flash confirmation gate exists only to make sure the operator has seen
the artifact hashes and rollback warning before proceeding manually,
outside this script, with qFlipper or `fbt flash_usb`. If qFlipper is
not detected, flashing is classified `BLOCKED / TOOLING NOT AVAILABLE`
— the script never improvises an alternate flash path.

## Rollback requirement

Before any real flash, `docs/PHASE2A_FLASHING_PRECHECK.md` (the
project's batch-agnostic rollback discipline: backup, current firmware
version recorded, rollback artifact identified) must be completed. The
flash confirmation gate's on-screen text reminds the operator of this
requirement every time it is shown.

## GUI observation limitations

Every app-level GUI check (menu visibility, launch, navigation, one
normal input, one edge input, exit behavior) is enumerated in
`-Mode HardwareAssisted` as `REQUIRES_HUMAN_OBSERVATION` and points to
the matching section in `docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`.
This script has no way to automate Flipper Zero's on-device GUI and does
not claim to.

## How to interpret classifications

| Classification | Meaning |
|---|---|
| `PREFLIGHT OK - HARDWARE NOT ATTEMPTED` | Repo/config checks all passed; no hardware step was requested (`Preflight`/`ReportOnly` mode). |
| `HARDWARE VALIDATION PASS` | (Reserved — this gate's current logic yields `PASS WITH HUMAN OBSERVATION PENDING` whenever any GUI check remains, which is always true in `HardwareAssisted` mode until the smoke-test checklist itself is separately completed and recorded.) |
| `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING` | Device detected, hashes verified (if requested), no FAIL/BLOCKED — but GUI-level checks still require a human to complete the smoke-test checklist separately. |
| `HARDWARE VALIDATION FAILED` | At least one check produced `FAIL` (e.g. a hash mismatch, a regressed source fix, a reintroduced excluded asset). Investigate before proceeding. |
| `HARDWARE VALIDATION BLOCKED` | A required step could not complete (e.g. qFlipper not detected) but nothing outright failed. |
| `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` | No Flipper Zero was detected (or `Get-PnpDevice` itself is unavailable, e.g. non-Windows). This is the expected result in this project's cloud sandbox environment. |
| `NEEDS REVIEW` | A repo-state check (branch, commit, git status) didn't match the expected value, or an ambiguous combination of results occurred — read the individual check details. |

## Why release-ready is still not claimed

This gate — even a fully successful `HardwareAssisted` run with a real
device — validates hardware compatibility and static/CI correctness. It
does not by itself constitute release-readiness: GUI smoke testing must
still be completed and recorded (`docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`
→ `docs/FINAL_HARDWARE_ASSISTED_RESULTS.md`), rollback must be verified
on a real device, and a separate release-readiness gap audit must run
before any release claim. See `docs/FINAL_NEXT_GATE.md`. This document,
this script, and every report it generates explicitly state **TEST-READY
ONLY / NOT RELEASE-READY** and never claim otherwise.

# Phase 2D — Hardware-Assisted Validation

Docs only. This is the Phase 2D counterpart to
`docs/PHASE2A_HARDWARE_ASSISTED_VALIDATION.md`,
`docs/PHASE2B_HARDWARE_ASSISTED_VALIDATION.md`, and
`docs/PHASE2C_HARDWARE_ASSISTED_VALIDATION.md` — same discipline, extended
to cover all 13 apps in the accepted Phase 2D baseline.
`tools/phase2d_hardware_gate.ps1` and
`tools/phase2d_hardware_gate_config.json` implement this gate;
`docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md` records what actually
happened when it was run.

## What this phase validates

- **Repository/branch/commit state** against the accepted Phase 2D
  baseline (`integration/phase2d-first-batch` at
  `d0812638a02c50389b9e713ad98f2c8215b75dd5`).
- **Artifact integrity** — if a downloaded copy of `firmware.dfu` and the
  updater `.tgz` is supplied via `-ArtifactDir`, their real SHA-256 hashes
  are compared against the finalized values in
  `docs/PHASE2D_3_ARTIFACT_HASHES.md`.
- **Safe, read-only device presence** — whether a Flipper Zero appears
  connected via Windows PnP enumeration (`Get-PnpDevice`), with no serial
  communication or data exchange with the device.
- **Safe, read-only official-tooling presence** — whether qFlipper appears
  installed (PATH, common install directories, Windows uninstall
  registry), best-effort only.
- **A structured, explicit enumeration** of every GUI-level check this
  script cannot itself perform, each individually marked
  `REQUIRES_HUMAN_OBSERVATION` rather than skipped or assumed.

## What this phase does not validate

- **It does not test app behavior.** No app is launched, no menu is
  navigated, no input is sent to a real device by this script, for any of
  the 13 apps.
- **It does not confirm the firmware boots correctly**, that any app
  displays correctly, or that any app's storage/UI behavior matches its
  documented expectations — that is the human-performed smoke-test
  checklist's job (`docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md`), not
  this script's.
- **It never flashes a device**, under any mode, flag, or confirmation
  phrase. The actual flash step is always a manual, deliberate action
  performed by the operator outside this script.
- **It does not run, and has no code path for, anything on the
  safety-exclusion list below.**

## Accepted baseline and hashes

| Field | Value |
|---|---|
| Branch | `integration/phase2d-first-batch` |
| Accepted CI baseline commit | `d0812638a02c50389b9e713ad98f2c8215b75dd5` |
| CI validation run | [`28941093859`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28941093859) |
| Finalization run | [`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724) |
| `firmware.dfu` | 862,825 bytes, SHA-256 `4f3703a8778543257759f367bc02f50d440ef85d21da05b630f705564084b6a8` |
| `flipper-z-f7-update-local.tgz` | 2,783,170 bytes, SHA-256 `3e015f6c0b303536fab14e4a8b85233b8c439c0f642087cb92f3781bf1b16c49` |
| Apps covered (13) | `network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`, `docviewlite`, `resistors`, `crypto_dictionary`, `2048` |
| `fcc_id_lookup` | **Not part of this baseline** — deferred pending a license-evidence resolution; not referenced anywhere in this gate |

## Exact safety exclusions

This script contains **no code path**, under any mode or flag, for:

- Sub-GHz / RF transmit or receive
- NFC read/write/emulate/clone
- RFID/LFRFID read/write/emulate/clone
- iButton read/write/emulate/clone
- BadUSB / HID keystroke injection
- BLE spam/beacon/profile interaction
- Direct GPIO control
- Infrared transmit
- Credential, token, or password handling/extraction
- Any cloning, brute force, jamming, deauth, or bypass behavior
- Any unauthorized-access or security-abuse demonstration

This is not a configuration toggle to disable — it is simply not
implemented anywhere in `tools/phase2d_hardware_gate.ps1`.

## Artifact hash verification

`-Mode HashVerify` (or `HardwareAssisted` with `-ArtifactDir`) computes
real SHA-256 hashes of a locally-downloaded `firmware.dfu` and updater
`.tgz` and compares them against the finalized values above. A mismatch
in either file — even a size match with a different hash — is a hard
`FAIL`, not a warning, and the script explicitly refuses to proceed to
the flash-confirmation gate. This logic can be verified with a deliberate
synthetic-mismatch test (two random-data files of the exact expected
sizes but the wrong content) — see
`docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md` for whether that test was
actually run in this session, clearly labeled as synthetic and not real
artifact verification.

## Device detection

`-Mode DetectDevice` (or `HardwareAssisted`) uses `Get-PnpDevice
-PresentOnly` to look for a USB device matching Flipper Zero's known
identity (friendly name containing "Flipper", or VID/PID `VID_0483&PID_5740`
— the STM32 CDC-ACM identity Flipper Zero enumerates as when running
normal firmware). This is Windows-only, read-only, and involves no serial
communication with the device.

## Flashing limitations

This script **never flashes a device itself**, under any circumstance. In
`-Mode HardwareAssisted` with `-AllowFlashPrompt`, it will only show a
flash-confirmation prompt if **all** of the following hold:

1. A device was detected (`DetectDevice` check `PASS`).
2. Both artifact hashes verified `PASS` (`HashVerify` check `PASS` for
   both files).
3. qFlipper (or other official tooling) was detected.

If any of these fail, the confirmation gate itself reports `BLOCKED` with
the specific reason — it does not fall through to showing the prompt
anyway. Even after a correctly-typed confirmation phrase, the script
performs **no flash** — it only records that the operator has seen the
hashes and rollback warning and intends to flash manually, afterward,
using qFlipper or `fbt flash_usb` themselves.

## Rollback requirement

`docs/PHASE2A_FLASHING_PRECHECK.md` (backup, current firmware version
recorded, rollback artifact identified) is reused unchanged — it is
batch-agnostic and applies to the Phase 2D-inclusive baseline exactly as
it did for Phase 2A, Phase 2B, and Phase 2C.

## GUI observation limitation

Menu visibility, app launch, on-screen navigation, input handling, and
exit behavior cannot be verified by any script — they require a human
watching the device's own screen. `-Mode HardwareAssisted` always
enumerates one `REQUIRES_HUMAN_OBSERVATION` entry per app (all 13), plus
dedicated entries for `chess`'s and `sudoku`'s save/load private-path
checks, `sd_info`'s SD-benchmark temp-file cleanup check,
`docviewlite`'s read-only confirmation check, `resistors`'s zero-storage
confirmation check, `crypto_dictionary`'s read-only confirmation check,
and `2048`'s app-scoped save-path check — never silently omitted, never
simulated. See `docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md` for the
actual human-performed steps.

## How to interpret PASS / PASS WITH HUMAN OBSERVATION / FAIL / BLOCKED / NEEDS REVIEW

| Classification | Meaning |
|---|---|
| `PREFLIGHT OK - HARDWARE NOT ATTEMPTED` | Repo/config checks are clean; no hardware-connected or GUI check was attempted (Preflight/ReportOnly mode). |
| `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` | Device detection was attempted but found nothing connected. Not a failure — just nothing to validate against in this environment/run. |
| `HARDWARE VALIDATION BLOCKED` | Some other precondition (e.g. tooling not found) blocked further progress; the specific reason is in the failing check's detail. |
| `HARDWARE VALIDATION FAILED` | A real check failed — e.g. an artifact hash mismatch. Do not proceed to a flash. |
| `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING` | Device detected, automated checks clean, but GUI-level checks remain outstanding — completing `docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real device is still required before any release-readiness claim. |
| `NEEDS REVIEW` | Something needs a human look before treating the run as clean (e.g. HEAD is not exactly the accepted baseline commit). |

**`HARDWARE VALIDATION PASS` (unqualified) is never produced by this
script** — every real hardware-connected run either blocks on a missing
precondition or lands in the "PASS WITH HUMAN OBSERVATION PENDING" state,
because GUI-level behavior is never automatable. A final
"PASS WITH HUMAN OBSERVATION" classification (as opposed to "...PENDING")
is only reached once a human has actually completed
`docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md` on a real device and
recorded the results — the script itself cannot produce that state on its
own, since it has no way to observe a screen.

## Why release-ready is still not claimed

Even a clean `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING`
result only means the non-GUI preconditions (artifact integrity, device
presence, tooling presence) are satisfied — it does not mean any app has
actually been launched and observed on a real screen, that no crash/
reboot/freeze occurred, or that storage behavior matches expectations.
Release-readiness requires the human-performed smoke-test checklist to
actually be completed and its results recorded, plus this project's full
release-gate checklist beyond Phase 2D alone. Nothing in this document or
in `tools/phase2d_hardware_gate.ps1` itself ever constitutes that
acceptance.

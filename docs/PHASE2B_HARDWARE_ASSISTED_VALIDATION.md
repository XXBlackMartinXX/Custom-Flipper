# Phase 2B.4 — Hardware-Assisted Validation Guide

Docs + tooling only. This explains `tools/phase2b_hardware_gate.ps1`: the
Phase 2B counterpart to `tools/phase2a_hardware_gate.ps1` (which remains
untouched and still valid for the accepted Phase 2A-only baseline) —
same mechanism, extended to the full 8-app Phase 2B-inclusive baseline
(`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`,
`flipfetch`, `quadratic_solver`, `sudoku`). This document covers what it
validates against the already-accepted Phase 2B CI baseline, what it does
not and cannot validate, why hardware validation is a fundamentally
different kind of check than CI validation, and how to interpret its
output.

## What this phase validates

Phase 2B.3 accepted a **non-hardware CI baseline**
(`docs/PHASE2B_3_ACCEPTANCE_RECORD.md`): the firmware compiles cleanly on
a real Windows runner, its static source properties are verified, its
artifact hashes are finalized, and its 8 apps produce valid `.fap`
outputs. Phase 2B.4 adds the next, distinct layer — confirming that the
**exact same accepted artifacts** are the ones a real device would
receive, and giving a structured, honest path toward the GUI-level checks
that only a human watching a physical Flipper Zero can perform.
Concretely, `tools/phase2b_hardware_gate.ps1` can verify:

- The repository is on the expected branch, and records whether the
  current commit matches the accepted CI baseline commit exactly.
- A locally-downloaded artifact directory's actual `firmware.dfu` and
  updater `.tgz` files hash to the **exact real SHA-256 values** recorded
  in `docs/PHASE2B_3_ARTIFACT_HASHES.md` (Phase 2B.3) — not a fabricated
  or archive-level digest, a real, independently-recomputed hash of the
  specific files you point it at.
- Whether a Flipper Zero appears connected (Windows PnP enumeration only —
  no serial communication, no data exchange with the device).
- Whether qFlipper (official flashing tooling) appears installed, via
  best-effort detection (PATH, common install directories, Windows
  uninstall registry).

## What this phase does not validate

- **Nothing about GUI-level app behavior**, for any of the 8 apps.
  Whether an app's menu entry renders correctly, whether it launches,
  whether navigation and input work as expected — none of this is
  automated. Every such check is explicitly logged as
  `REQUIRES_HUMAN_OBSERVATION`, pointing to
  `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md`, never simulated or
  assumed.
- **Nothing about the flash itself succeeding.** Even in `-Mode
  HardwareAssisted -AllowFlashPrompt`, this script never performs a flash.
  It verifies the preconditions (device detected, artifacts hash-verified,
  tooling present) and, only after an exact typed confirmation phrase,
  acknowledges that a manual flash may proceed — using qFlipper or
  `fbt flash_usb`, outside this script, by the operator.
- **Nothing about release-readiness.** That still requires the project's
  full release-gate checklist, independent of anything this gate reports.

## Accepted baseline and hashes

| Field | Value |
|---|---|
| Branch | `integration/phase2b-first-batch` |
| CI baseline commit | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` |
| CI validation run | `28877810474` |
| Finalization run | `28879790603` |
| `firmware.dfu` | 862,825 bytes, SHA-256 `f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75` |
| `flipper-z-f7-update-local.tgz` | 2,742,659 bytes, SHA-256 `6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7` |
| Apps covered (8) | `network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`, `flipfetch`, `quadratic_solver`, `sudoku` |

These are the same real, GitHub-Actions-generated values recorded in
`docs/PHASE2B_3_ARTIFACT_HASHES.md` — see `tools/phase2b_hardware_gate_config.json`
for the exact machine-readable copy this script consumes.

## Why hardware validation is different from CI validation

CI validation (`tools/phase2a_validate.ps1 -ConfigPath
tools/phase2b_validate_config.json` via GitHub Actions) proves the
firmware **compiles** cleanly and **passes static analysis** on a real
Windows machine — a fully automatable, repeatable, machine-checkable
process. Hardware validation is different in kind, not just degree: it
asks whether the compiled result **actually works when running on the
specific physical hardware it was built for** — booting, rendering a UI
on a real 128×64 display, responding to real button presses. No amount of
CI automation substitutes for this, because CI never runs the firmware on
target hardware at all; it only compiles it. This gate exists to make the
*automatable part* of hardware validation (artifact identity, device
presence, tooling availability) as rigorous as the CI side, while being
completely honest that the GUI-observation part has no automated
substitute with currently available tooling.

## Exact safety exclusions

This script contains **no code path** for any of the following, for any
app, under any mode or flag — this is not a setting to disable, it is
simply not implemented anywhere in `tools/phase2b_hardware_gate.ps1`:

- Sub-GHz / RF transmit or receive
- NFC, RFID, or iButton read/write/emulate/clone
- BadUSB / HID keystroke injection
- BLE spam/beacon/profile interaction
- Direct GPIO control
- Infrared transmit
- Credential, token, or password handling/extraction
- Cloning, brute force, jamming, deauth, or bypass behavior
- Any unauthorized-access or security-abuse demonstration

The only device interaction this script ever performs is **read-only PnP
enumeration** (does a USB device matching Flipper Zero's known VID/PID
appear present) — never a serial connection, never an RPC call, never data
exchange with the device.

## Artifact hash verification

`-Mode HashVerify -ArtifactDir <path>` (or `-Mode HardwareAssisted
-ArtifactDir <path>`) recursively scans the given directory for
`firmware.dfu` and `flipper-z-f7-update-local.tgz`, computes their real
SHA-256 with `Get-FileHash`, and compares against the values recorded in
`tools/phase2b_hardware_gate_config.json` (sourced from
`docs/PHASE2B_3_ARTIFACT_HASHES.md`, Phase 2B.3's real, GitHub-Actions
-generated hashes):

| File | Expected size | Expected SHA-256 |
|---|---|---|
| `firmware.dfu` | 862,825 bytes | `f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75` |
| `flipper-z-f7-update-local.tgz` | 2,742,659 bytes | `6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7` |

A `PASS` here means: the file you are about to flash is byte-for-byte
identical to the one the accepted CI baseline produced. A `FAIL` means it
is not, and the script explicitly warns not to proceed to a flash with
that artifact — this was directly exercised with a deliberately
mismatching synthetic file during this tool's own testing, confirming the
comparison logic rejects a wrong file (matching size, wrong hash) rather
than passing on size alone.

## Device detection

`-Mode DetectDevice` (or `-Mode HardwareAssisted`) uses `Get-PnpDevice
-PresentOnly` (Windows only) to look for a USB device whose friendly name
contains "Flipper" or whose instance ID matches Flipper Zero's known
USB VID/PID (`VID_0483&PID_5740` — an STM32 CDC-ACM device, the standard
enumeration for Flipper Zero running normal firmware). If none is found,
every hardware-connected check reports `NOT_RUN`/`BLOCKED` as appropriate —
nothing is inferred or assumed about a device that isn't actually detected.

## Flashing limitations

This script **never flashes a device**, under any mode, any flag
combination, or any confirmation. What `-Mode HardwareAssisted
-AllowFlashPrompt` actually does:

1. Requires a device to have been detected.
2. Requires both artifact hashes to have verified `PASS`.
3. Requires qFlipper (or other detected official tooling) to be present —
   if not detected, flashing is classified **BLOCKED / TOOLING NOT
   AVAILABLE**, and the script does not improvise a substitute flashing
   method.
4. Displays the artifact hashes and a rollback warning, and requires the
   operator to type an exact confirmation phrase.
5. If typed correctly, records that confirmation and reminds the operator
   that the actual flash is still their own manual action, performed
   afterward with qFlipper or `fbt flash_usb`, outside this script.

## Rollback requirement

Before any flash attempt, complete `docs/PHASE2A_FLASHING_PRECHECK.md` in
full — back up SD card contents, record the current firmware version, and
identify the exact rollback artifact/path (DFU recovery mode, or the
previously-installed firmware package). This rollback discipline is
batch-agnostic and applies unchanged to the Phase 2B-inclusive baseline;
no separate Phase 2B version of this document was needed. This gate's
flash-confirmation prompt explicitly reminds the operator of this before
accepting the confirmation phrase, but does not verify it was actually
done — that remains the operator's own responsibility, same as it always
has been in this project.

## GUI observation limitation

Flipper Zero is driven by a 128×64 monochrome display and a 5-button D-pad;
there is no confirmed, general-purpose remote-control or screen-capture API
this project relies on for scripted UI testing. Every GUI-level check —
menu visibility, launch success, navigation, input handling, exit behavior
— for all 8 apps, is logged by this gate as `REQUIRES_HUMAN_OBSERVATION`,
pointing to `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md`. This is stated
plainly rather than worked around; see
`docs/PHASE2A_AUTOMATION_LIMITATIONS.md` for the fuller background on why
(that document's reasoning is also batch-agnostic).

## How to interpret PASS / FAIL / BLOCKED / REQUIRES HUMAN OBSERVATION

| Status | Meaning |
|---|---|
| `PASS` | The check ran and found no problem. |
| `FAIL` | The check ran and found a real problem — e.g. an artifact hash mismatch. Do not proceed to a flash. |
| `BLOCKED` | The check could not run due to an environment limitation (no device, no qFlipper detected, non-Windows OS) — not evidence of a firmware/app defect. |
| `NOT_RUN` | Not attempted, either because the mode didn't call for it or a precondition wasn't met (e.g. no `-ArtifactDir` supplied). |
| `NEEDS_REVIEW` | Requires a human judgment call (e.g. HEAD doesn't exactly match the accepted baseline commit — not necessarily wrong, but worth confirming). |
| `REQUIRES_HUMAN_OBSERVATION` | Explicitly not automatable with current tooling — a human must complete this via `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md`. |

Overall run classifications:

- **`PREFLIGHT OK - HARDWARE NOT ATTEMPTED`** — Preflight/ReportOnly modes
  only; repo/config state looks fine, nothing hardware-related was
  attempted.
- **`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`** — no Flipper Zero
  was detected; hardware-connected checks could not proceed.
- **`HARDWARE VALIDATION BLOCKED`** — a device was detected but some other
  precondition (e.g. tooling) is missing.
- **`HARDWARE VALIDATION FAILED`** — a real FAIL exists (e.g. artifact hash
  mismatch). Investigate before proceeding.
- **`HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING`** — every
  automated/hardware-connected check passed, but the GUI-level checklist
  still needs to be completed by a human before hardware testing can be
  considered done.
- **`NEEDS REVIEW`** — read the individual checks; nothing clean enough to
  auto-classify further.

## Why release-ready is still not claimed

Even a fully clean `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION
PENDING` run — the best this script alone can ever report — explicitly
means the GUI-level checklist has **not yet** been completed. Only after a
human has actually run `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md` on
the real device (all 8 apps) and recorded results does hardware testing
itself become complete — and even then, release-readiness requires the
project's full release-gate checklist, which spans more than Phase 2B
alone. **Hardware flashing/testing remains NOT PERFORMED and release status
remains TEST-READY ONLY / NOT RELEASE-READY** until a human actually
completes and records each of these steps.

# Pre-Flash Anti-Brick Safeguard Gate

Docs only. No firmware has been flashed by this document or this phase.
This is a safety gate that must pass — honestly, not performatively —
**before** anyone attempts to flash the accepted final 20-app firmware
baseline to a real Flipper Zero. It exists to reduce flashing risk, not
to eliminate it, and it does not itself perform or claim to perform any
flash, hardware test, or GUI smoke test.

## What a soft brick is

A **soft brick** is a device that fails to boot its normal application
firmware but can still be recovered without special hardware — typically
because the bootloader (DFU mode) remains intact and reachable. Symptoms
include: a blank or frozen screen after flashing, a boot loop, a device
that only shows its bootloader/recovery screen, or a device that
qFlipper reports as "in DFU mode" or "firmware corrupted." A soft brick
is recoverable by re-flashing a known-good firmware package via
qFlipper's normal or recovery flow — see
`docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md`.

## What a hard brick is

A **hard brick** is a device that cannot be recovered through software
means at all — typically because the bootloader itself was corrupted or
overwritten, or because of an unrelated hardware fault (e.g. a failed
flash write that also damaged the flash chip, or a power loss at a
uniquely bad moment during a low-level write). Flipper Zero's design
makes a hard brick from a normal application-firmware flash unlikely
(the bootloader/DFU region is not touched by a standard `.dfu`/updater
flash), but "unlikely" is not "impossible," and this document does not
claim otherwise.

## Why risk cannot be zero

No pre-flash checklist, script, or gate — including this one — can
reduce flashing risk to zero. Real risks that remain even after every
check in this gate passes:

- A USB cable or port fault occurring mid-write, independent of
  anything checked beforehand.
- A power loss or unexpected device disconnect during the flash.
- An undiscovered defect in the firmware itself, despite the CI
  baseline's clean non-hardware validation (`docs/CI_BASELINE_SUMMARY.md`)
  — CI validates build correctness, not every possible runtime
  interaction with real hardware.
- A pre-existing hardware fault on the device that this gate has no way
  to detect.

This document's purpose is to minimize the *known, checkable* risk
factors — it cannot and does not claim to eliminate the *unknown* ones.

## Why qFlipper/DFU recovery matters

Flipper Zero's STM32-based bootloader supports DFU (Device Firmware
Upgrade) mode, a standard, low-level recovery mode independent of the
application firmware currently installed. If a flash goes wrong and the
device won't boot normally, DFU mode is very often still reachable
(hold the Back button while connecting USB, per Flipper's own
documented procedure), and qFlipper's "Install firmware" / recovery
flow can re-flash a known-good firmware through it. Understanding this
path **before** flashing — not discovering it for the first time during
a recovery emergency — is the single highest-value risk reduction this
gate can offer.

## Accepted artifact hashes

| Field | Value |
|---|---|
| Accepted branch | `integration/fcc-id-lookup-one-app-import` |
| Accepted commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` |
| Accepted CI run | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) |
| Finalization run | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) |
| `firmware.dfu` | 862,833 bytes, SHA-256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` |
| `flipper-z-f7-update-local.tgz` | 2,891,859 bytes, SHA-256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` |

Before flashing anything, re-verify a downloaded artifact against these
exact values using `tools/pre_flash_safeguard_gate.ps1 -Mode
ArtifactHashVerify -ArtifactDir "<path>"` (or `tools/final_hardware_gate.ps1`,
which performs the same check). A hash that does not match exactly means
you do not have the accepted artifact — do not flash it.

## No-flash rule for this phase

**This phase does not flash any firmware.** No script created or run in
this phase contains a flashing code path. `tools/pre_flash_safeguard_gate.ps1`
never writes to a device under any mode, flag, or combination — it is a
pre-condition checker only. Flashing, if it happens at all, is a
separate, explicit, human action performed afterward using qFlipper or
`fbt flash_usb`, entirely outside this gate's tooling, and only after a
separate future hardware-validation phase.

## Required physical checklist

Before even considering a flash attempt, confirm all of the following
are physically true (full detail and PASS/BLOCKED tracking in
`docs/PRE_FLASH_PHYSICAL_CHECKLIST.md`):

- [ ] A real Flipper Zero device is available.
- [ ] A Windows PC is available (qFlipper's officially supported
      desktop flow; this project's tooling targets Windows PowerShell).
- [ ] A known-good USB **data** cable is available (not a charge-only
      cable) and a direct USB port (avoid unpowered hubs).
- [ ] The device's battery is adequately charged (do not start a flash
      on a low-battery warning).
- [ ] qFlipper is installed and up to date.
- [ ] Windows recognizes the device's drivers correctly (normal serial
      mode, and DFU mode if tested).
- [ ] A known-good, name-brand microSD card is in use (or the device's
      internal state is otherwise understood) — see the microSD risk
      note below.
- [ ] Any SD-card contents the user cares about are backed up (app
      data, saved captures, personal files) before touching the device.
- [ ] The official firmware recovery path (qFlipper's DFU/recovery
      flow) is understood **before** it might be needed, not looked up
      for the first time during an emergency.
- [ ] A rollback plan is prepared: the device's current firmware
      version is recorded, and a known-good firmware package (official,
      or whatever was previously installed) is on hand to return to.

## microSD card risk note

Cheap, counterfeit, or failing microSD cards are a disproportionately
common cause of Flipper Zero misbehavior that gets mistaken for a
firmware defect — corrupted app data, failed saves, or device instability
that has nothing to do with the firmware flashed. Using a known-good,
name-brand card, and backing up anything of value on it before testing,
reduces both real risk and false-attribution risk (blaming this
project's firmware for a card-level problem).

## Final rule

**DO NOT FLASH CUSTOM FIRMWARE UNTIL THIS SAFEGUARD GATE PASSES.**

"Passes" means: every item in `docs/PRE_FLASH_PHYSICAL_CHECKLIST.md` is
checked PASS (not BLOCKED), `tools/pre_flash_safeguard_gate.ps1 -Mode
ArtifactHashVerify` confirms the real downloaded artifacts match the
accepted hashes above exactly, the recovery path in
`docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` has been read and understood,
and the decision tree in `docs/SAFE_FLASH_DECISION_TREE.md` has been
walked through honestly with no "stop" condition triggered. Passing
this gate does not mean release-ready, and does not force flashing —
flashing remains a separate, optional, explicit human decision, made in
a separate future hardware-validation phase, not this one.

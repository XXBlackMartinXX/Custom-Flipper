# Flash Rollback and Recovery Plan

Docs only. Device-level recovery procedures to use **if** a real flash
attempt goes wrong, written to be read and understood **before**
flashing, not looked up for the first time during an emergency. This is
the device-level counterpart to `docs/PHASE2A_ROLLBACK_PLAN.md`, which
covers source/repository-level rollback (dropping a commit or branch) —
a separate, unrelated kind of rollback from the physical-device recovery
steps below. No flash has been performed as of this document.

## How to recover if the device does not boot normally

1. **Do not panic-flash repeatedly.** Multiple hasty re-flash attempts
   without diagnosing what happened first increase risk rather than
   reduce it.
2. **Check the device screen first.** A blank screen, a frozen
   splash/logo, or a boot loop are all different symptoms with
   different likely causes (interrupted write vs. a genuine firmware
   issue vs. a hardware fault) — note exactly what you see before
   proceeding.
3. **Reconnect via USB and open qFlipper.** qFlipper will typically
   report the device's state (normal, DFU/recovery mode, or
   unresponsive) even if the on-device screen is not showing anything
   useful.
4. **If qFlipper reports normal mode but the device won't boot to its
   home screen**, use qFlipper's "Install firmware" option to re-flash
   the accepted firmware (or the previously-installed known-good
   firmware, if you want to abandon the test) while the device is still
   reachable in normal mode.
5. **If the device is unresponsive or won't reach normal mode**,
   proceed to the DFU/recovery path below.

## How to use the qFlipper recovery/repair path

1. Disconnect the device from USB.
2. Put the device into DFU mode: hold the **Back** button while
   reconnecting the USB cable (Flipper Zero's standard, documented
   recovery-entry procedure — confirm the exact button sequence against
   qFlipper's own current documentation before relying on this
   description, since it is restated here for planning purposes, not as
   the authoritative source).
3. qFlipper should detect the device in DFU/recovery mode (a different
   device identity than normal mode) even if the device's own screen
   shows nothing.
4. Use qFlipper's "Install firmware" / recovery flow to flash a
   known-good firmware package. This does not depend on the
   currently-installed (possibly broken) application firmware — DFU
   mode operates at the bootloader level.
5. Once the recovery flash completes, disconnect, power-cycle the
   device normally (without holding Back), and confirm it boots to its
   normal home screen.

## How to return to official/stable firmware

1. If you want to abandon this project's firmware entirely and return
   to a known-good baseline, use qFlipper's official firmware catalog
   (accessible from qFlipper's own UI) to install the latest official
   Flipper Devices firmware, or reinstall whatever alternative firmware
   (RogueMaster, Unleashed, etc.) you were running before this test —
   whichever you recorded as your "current firmware version" per
   `docs/PRE_FLASH_PHYSICAL_CHECKLIST.md`.
2. If you have the exact previous firmware's own update package saved
   locally (recommended — see the physical checklist), install that
   directly via qFlipper rather than relying on the catalog, to
   guarantee an exact return to your prior state.
3. This project's own accepted artifacts
   (`docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md`) remain available for a
   future re-attempt once any issue is understood — returning to
   official/stable firmware is not a rejection of this project's
   firmware, just a safe default if you are unsure how to proceed.

## What to do if Windows does not detect the device

1. Try a different USB cable — confirm it is a **data** cable, not a
   charge-only cable (a common false alarm).
2. Try a different USB port, preferably a direct motherboard port
   rather than an unpowered hub.
3. Check Windows Device Manager for an unknown device, a device with a
   driver error (yellow warning icon), or a device listed but not
   recognized by qFlipper specifically.
4. Reinstall or update qFlipper, which bundles the necessary USB
   drivers for both normal and DFU modes.
5. If the device is completely unresponsive (no response in any mode,
   no charge indicator), this is outside the scope of a software
   recovery procedure — stop and treat it as a potential hardware
   fault, not something to keep retrying blindly.

## What to do if the device appears only in DFU/recovery mode

This is the **expected and recoverable** state after most failed
flashes — see "How to use the qFlipper recovery/repair path" above.
Confirm qFlipper genuinely shows a DFU/recovery-mode device (not just
"no device found"), then proceed with the recovery flash. Do not
attempt to force the device into normal mode by power-cycling
repeatedly without flashing — DFU mode after a bad flash typically
requires a successful recovery flash to clear, not a power cycle alone.

## What to do if microSD errors appear

1. Stop using the current card immediately — do not continue testing
   with a card showing errors, since this can produce misleading
   symptoms that look like firmware defects.
2. If you have a backup of the card's contents (per the physical
   checklist), the safest recovery is to reformat the card (using the
   device's own SD format function, or a PC tool) or replace it
   entirely with a known-good, name-brand card, then restore any
   backed-up data you want to keep.
3. If errors appeared only after this project's firmware was flashed,
   note this explicitly and stop further testing until it can be
   determined whether the card itself is at fault (common) or the
   firmware is (report it if so, with full evidence per below) — do not
   assume either without evidence.

## What evidence to save

If anything goes wrong, save evidence immediately, before it's lost to
a subsequent action:

- **Screenshots** of qFlipper's device-state panel (normal/DFU/
  unresponsive), any error dialogs, and the artifact hash-verification
  output.
- **qFlipper logs** (qFlipper has a log/diagnostics export option —
  use it) covering the flash attempt and any recovery attempt.
- **PowerShell script reports** — the JSON/Markdown reports generated
  by `tools/pre_flash_safeguard_gate.ps1` and `tools/final_hardware_gate.ps1`
  under `reports/pre_flash_safeguard/` and `reports/final_hardware/`
  document the pre-flash state; keep them alongside whatever happened
  next.
- **Device screen photos**, if the on-device display shows anything
  (error text, a boot-loop pattern, a blank screen with backlight on
  vs. off) — a photo captures detail a written description might miss.

## Clear stop conditions

Stop immediately — do not proceed to (or continue) flashing — if any of
the following is true:

- **Device not detected** by Windows or qFlipper in normal mode, and
  you have not yet confirmed DFU/recovery-mode detection either.
- **qFlipper cannot see the device in normal mode or in recovery/DFU
  mode.** If qFlipper truly cannot see the device in either state, do
  not attempt a flash — troubleshoot USB/driver issues first (see
  above).
- **Artifact hash mismatch.** If `tools/pre_flash_safeguard_gate.ps1
  -Mode ArtifactHashVerify` (or `tools/final_hardware_gate.ps1 -Mode
  HashVerify`) reports a mismatch against the accepted hashes in
  `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`, do not flash that artifact
  — re-download it.
- **Battery low.** Do not start a flash on a low-battery warning.
- **Bad or unknown USB cable.** If you are not certain the cable
  supports data (not just charging), replace it before proceeding.
- **Suspicious microSD card behavior.** Any read/write error, corruption,
  or unexpected card-related message before flashing is a reason to
  address the card first, not proceed and hope it doesn't matter.
- **You are not comfortable proceeding, for any reason.** This is a
  sufficient stop condition on its own — no other justification is
  required. This gate exists to support a deliberate, informed decision,
  not to pressure one.

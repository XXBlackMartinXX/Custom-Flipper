# Safe Flash Decision Tree

Docs only. A conservative, sequential decision tree to walk through
**before** any real flash attempt of the accepted final 20-app firmware
baseline. Each question is a hard stop if answered "no" — this tree is
deliberately structured so that any single unresolved concern halts the
process, rather than accumulating risk across multiple "mostly fine"
answers. Read `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`,
`docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md`, and
`docs/PRE_FLASH_PHYSICAL_CHECKLIST.md` before walking this tree — it
assumes their content is already understood, not being read for the
first time here.

## Start

**Are you comfortable testing?**
If no → **STOP.** No further justification is required. This is a
sufficient reason to stop on its own.

↓ yes

**Is the device working normally on its current official/stable
firmware?**
If no → **STOP.** Do not attempt to flash a device that is already
exhibiting problems on known-good firmware — resolve that first, or you
will not be able to tell whether any subsequent issue was caused by
this project's firmware or was pre-existing.

↓ yes

**Is qFlipper installed and detecting the device (in normal mode)?**
If no → **STOP.** Install/update qFlipper and confirm detection
(`tools/pre_flash_safeguard_gate.ps1 -Mode DeviceDetect` can help
confirm this) before proceeding. See "What to do if Windows does not
detect the device" in `docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md`.

↓ yes

**Is the recovery/DFU path understood?**
If no → **STOP.** Read `docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` in
full first. Understanding the DFU-mode recovery procedure only after
something has gone wrong is exactly the failure mode this gate exists
to prevent. Optionally, use `tools/pre_flash_safeguard_gate.ps1 -Mode
RecoveryReadiness` to confirm your device is reachable in DFU mode
*before* you might ever need it for real — this is safe and performs no
recovery action itself.

↓ yes

**Is the microSD card known-good and backed up?**
If no → **STOP.** Replace an unknown/suspect card with a known-good,
name-brand one, and back up anything of value before proceeding. See
the microSD risk note in `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`.

↓ yes

**Do the accepted custom artifact hashes match exactly?**
Run `tools/pre_flash_safeguard_gate.ps1 -Mode ArtifactHashVerify
-ArtifactDir "<path>"` against your downloaded `firmware.dfu` and
`flipper-z-f7-update-local.tgz`.
If no (mismatch, or verification could not be run) → **STOP.**
Re-download the artifacts from CI run `29068148596` / finalization run
`29096377711` and re-verify. Do not flash an artifact whose hash you
have not confirmed matches
`e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`
(firmware) and
`eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55`
(updater) exactly.

↓ yes

**Is the rollback plan ready?**
(Current firmware version recorded; a known-good firmware package on
hand or the official catalog confirmed reachable; evidence-saving
steps from `docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` understood.)
If no → **STOP.** Complete `docs/PRE_FLASH_PHYSICAL_CHECKLIST.md` items
8–9 first.

↓ yes

**Then, and only then, hardware flashing may be considered — in a
separate, future final hardware-validation phase, not this one.**

## What this decision tree does not do

- **It does not flash anything itself.** No step above performs a
  flash. Reaching the end of this tree is a statement that no known
  blocker remains, not an instruction to flash immediately or
  automatically.
- **It does not replace `docs/PRE_FLASH_PHYSICAL_CHECKLIST.md`.** Every
  question above maps to one or more checklist items; complete the full
  checklist, not just this summary tree.
- **It does not authorize a specific flashing session.** Each real
  flash attempt should be preceded by its own honest walk through this
  tree — do not treat a pass on a prior occasion as still valid if
  circumstances have changed (different device, different cable,
  different day).

## Explicit statements

**Passing this safeguard gate does not mean release-ready.** Release
status remains **TEST-READY ONLY / NOT RELEASE-READY** regardless of
the outcome of this tree — see `docs/FINAL_NEXT_GATE.md` for the full
list of what remains before release-readiness could even be considered.

**Passing this safeguard gate does not force flashing.** Nothing in
this project requires a flash to proceed. This tree exists to support
an informed, deliberate decision — not to create pressure toward one
outcome.

**Flashing remains a separate, explicit human decision**, made outside
this document, outside `tools/pre_flash_safeguard_gate.ps1` (which has
no flashing code path at all), and outside this phase — in a future,
separate hardware-validation phase, using qFlipper or `fbt flash_usb`
directly, by a human who has completed every step above.

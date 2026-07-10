# Pre-Flash Physical Checklist

Docs only. A human-completed checklist to work through, in order,
**before** attempting any real flash of the accepted final 20-app
firmware baseline. Read `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md` and
`docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` first. Mark each item PASS or
BLOCKED as you go — do not skip an item by leaving it blank. **This
checklist has not been executed as of this document; no flash has been
performed.**

Per `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`'s final rule: **do not flash
custom firmware until every item below is PASS.** A single BLOCKED item
is sufficient reason to stop and resolve it before continuing.

| # | Item | PASS | BLOCKED |
|---|---|---|---|
| 1 | Device powers on normally (screen shows the normal home screen or a recognizable menu, not a blank/frozen/looping state) | [ ] | [ ] |
| 2 | Device charges normally (battery indicator increases while connected to USB power, or is already adequately charged) | [ ] | [ ] |
| 3 | Device is detected by Windows (appears in Device Manager as a recognized serial device, no driver-error warning icon) | [ ] | [ ] |
| 4 | qFlipper detects the device in normal mode (qFlipper's device panel shows the device connected and identified, not "no device found") | [ ] | [ ] |
| 5 | qFlipper version and current firmware install are verified (qFlipper is up to date; the device's current firmware name/version is noted, per §2.2/2.3 of `docs/PHASE2A_FLASHING_PRECHECK.md`'s pattern) | [ ] | [ ] |
| 6 | Windows Serial/DFU drivers are healthy (no yellow-warning-icon device anywhere in Device Manager related to Flipper Zero, in either normal or DFU mode if tested) | [ ] | [ ] |
| 7 | microSD card is known-good, name-brand, and backed up (per the microSD risk note in `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`; anything of value on the card is copied off first) | [ ] | [ ] |
| 8 | Official recovery/repair instructions are open and understood (`docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` has been read; the DFU-mode entry procedure and qFlipper's recovery flow are understood, not merely bookmarked) | [ ] | [ ] |
| 9 | Official/stable rollback firmware path is ready (the device's current firmware version is recorded; either its own update package is on hand, or qFlipper's official firmware catalog is confirmed reachable as a fallback) | [ ] | [ ] |
| 10 | Accepted custom firmware artifacts are downloaded (`firmware.dfu` and `flipper-z-f7-update-local.tgz` from CI run `29068148596` / finalization run `29096377711`, saved locally) | [ ] | [ ] |
| 11 | Artifact hashes match exactly (`tools/pre_flash_safeguard_gate.ps1 -Mode ArtifactHashVerify -ArtifactDir "<path>"` reports PASS for both files against the accepted hashes in `docs/PRE_FLASH_ANTI_BRICK_SAFEGUARD.md`) | [ ] | [ ] |
| 12 | User understands no release-ready claim is being made (this gate, and every document referenced by it, states TEST-READY ONLY / NOT RELEASE-READY — passing this checklist does not change that) | [ ] | [ ] |
| 13 | User understands flashing remains optional (nothing in this project requires a flash to proceed; this checklist exists to support an informed decision, not to compel one) | [ ] | [ ] |
| 14 | User explicitly chooses whether to continue (a deliberate, recorded yes/no decision — not an assumption) | [ ] | [ ] |

## Notes field

Use this space to record anything relevant while working through the
checklist above — device firmware version before testing, qFlipper
version, cable/port used, microSD card model, any anomaly noticed:

```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

## Result

- [ ] **All 14 items PASS.** Proceed to `docs/SAFE_FLASH_DECISION_TREE.md`
      for the final go/no-go walkthrough before any flash attempt, in a
      separate future hardware-validation phase.
- [ ] **One or more items BLOCKED.** Stop. Resolve the blocked item(s)
      using `docs/FLASH_ROLLBACK_AND_RECOVERY_PLAN.md` (if
      device/recovery-related) or by re-downloading/re-verifying
      artifacts (if hash-related) before re-attempting this checklist.

**Passing this checklist does not mean release-ready, and does not by
itself authorize a flash.** See `docs/SAFE_FLASH_DECISION_TREE.md` for
the explicit decision that must still follow.

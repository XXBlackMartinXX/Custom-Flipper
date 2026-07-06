# Phase 2A — Flashing Pre-Check

Docs only. No code changed by this document. This is a pre-flight checklist to run
**before** flashing the Phase 2A firmware to real hardware. It exists so that a
flash attempt starts from a known-good, recoverable state — it does not perform, or
claim to have performed, any flashing or hardware testing itself.

Read `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` first for the full scope, safety rules,
and rollback path referenced below.

## 1. Confirm exactly what you are about to flash

| Field | Value |
|---|---|
| Branch | `integration/phase2a-first-batch` |
| Commit | `5e5e0ecf225be947a754e537670a6421838b939b` |
| Firmware artifact | `build\f7-firmware-C\firmware.dfu` (862,825 bytes) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` (2,732,909 bytes) |
| Apps in scope | `network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess` |

Before flashing, re-verify locally that the artifact you're about to flash actually
matches this commit — do not flash a stale build from an earlier attempt:

```powershell
cd C:\Github\Custom-Flipper-phase2a-build
git status
git rev-parse HEAD
```

`git rev-parse HEAD` must print `5e5e0ecf225be947a754e537670a6421838b939b` (or a
later commit you have separately decided to test — if so, stop and confirm the
newer commit's own build/doc status first, since this plan is written against
`5e5e0ec` specifically). `git status` must be clean. If either check fails, rebuild
before flashing rather than flashing a mismatched or dirty tree.

## 2. Back up before touching the device

1. **Back up the device's current SD card contents** (copy `/ext` off the device via
   qFlipper or mass-storage mode) if it holds anything you care about — app data,
   saved files, personal Sub-GHz/NFC/IR captures, etc. This smoke test is not
   expected to touch unrelated data, but back up first anyway; it's the cheap step.
2. **Record the device's current firmware version** before flashing (Settings →
   About, or qFlipper's device info panel) so you have a known-good version to
   return to if you need to roll back.
3. **Note whether the current firmware is official, RogueMaster, Unleashed, or
   something else**, and, if you have it, where that exact build/update package
   lives on disk. That file is your rollback artifact — see §5.

## 3. Device state checks

- **Battery**: confirm the device shows adequate charge (this project's own
  standard: don't start a flash on a low-battery warning). A flash interrupted by
  power loss is a real bricking risk unrelated to anything in this firmware.
- **Cable/connection**: use a data-capable USB cable and a direct port (avoid
  unpowered hubs) for the same reason — a dropped connection mid-flash is a known
  general risk for any DFU-style update, not specific to this build.
- **Close qFlipper/any other tool** that might be holding the device open before
  starting the actual flash tool, to avoid a device-busy failure mid-write.

## 4. What this pre-check does *not* cover

- It does not validate the *content* of the 5 apps — that's
  `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` and its checklist, run only after a
  successful flash.
- It does not perform the flash itself. Use your normal qFlipper/`fbt` flashing
  procedure; this document assumes you already know how to flash a `.dfu`/update
  package and is not a substitute for that tooling's own instructions.
- It does not claim hardware testing has occurred. Completing this pre-check is a
  precondition for testing, not the test itself.

## 5. Rollback path (know this *before* you flash, not after)

If anything goes wrong post-flash (device doesn't boot, recovery/DFU mode only,
apps missing, unexpected behavior outside this plan's scope):

1. **Recovery/DFU mode re-flash**: Flipper Zero's boot ROM DFU mode is independent
   of the firmware installed — a bad application-layer flash does not brick the
   bootloader. Hold the device into DFU mode (Back button while connecting USB, per
   Flipper's standard recovery procedure) and re-flash a known-good package via
   qFlipper.
2. **Return to your previously recorded firmware version** (from §2.2) using its
   own update package, official or otherwise, that you already had before this
   test.
3. **If you don't have the previous firmware's package on hand**, official
   recovery firmware can be fetched via qFlipper's own "Install firmware" /
   recovery flow, which does not depend on anything in this branch.
4. This project's own `PHASE2A_ROLLBACK_PLAN.md` covers rolling back the
   **source/repository** side (dropping an app or the whole Phase 2A batch from
   the branch) — that is a separate, source-level rollback from the
   **device-level** recovery steps above, which concern the physical Flipper only.

## 6. Go/no-go

Do not proceed to flashing unless all of the following are true:

- [ ] `git rev-parse HEAD` confirms `5e5e0ecf225be947a754e537670a6421838b939b` (or a
      newer commit you've separately validated) and `git status` is clean
- [ ] Both build artifacts exist locally and match the sizes in §1
- [ ] Device SD card / app data backed up (or confirmed nothing of value is on it)
- [ ] Current firmware version recorded
- [ ] Rollback artifact (previous firmware package) identified and accessible
- [ ] Battery adequately charged
- [ ] Data-capable cable, direct USB port, no other tool holding the device open

Only once every box above is checked should you proceed to flashing, and then to
`PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md`.

**Hardware flashing/testing has still NOT been performed as of this document.**
This is a pre-check for a future flash attempt, not a record of one.

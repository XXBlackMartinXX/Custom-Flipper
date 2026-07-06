# Phase 2A — Hardware Smoke Test Plan

Docs only. No code changed by this document, and **no hardware testing has been
performed as part of writing it.** This defines a safe, minimal, manual smoke test
for the already-built Phase 2A firmware, to be carried out by the project owner on
real hardware. It does not itself constitute test execution or results.

## What this plan covers

Verified starting point (see `PHASE2A_BUILD_REPORT.md` for full detail):

| Field | Value |
|---|---|
| Branch | `integration/phase2a-first-batch` |
| Verified commit | `5e5e0ecf225be947a754e537670a6421838b939b` |
| Docs commit (integration branch) | `f391963` |
| Docs mirror commit (documentation branch) | `633c48c` |
| Firmware build | **PASS** (`firmware.dfu`, 862,825 bytes) |
| Updater package build | **PASS** (`flipper-z-f7-update-local.tgz`, 2,732,909 bytes) |
| SAM voice feature (`chess`) | Removed entirely (commit `6359f87`) |
| Hardware flashing/testing | **NOT PERFORMED** |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** |

Apps in scope for this smoke test — **only** these 5, all imported in Phase 2A:

1. `network_subnet` (Tools) — appid `network_subnet`
2. `programmer_calc` (Tools) — appid `programmercalc`
3. `vin_decoder` (Tools) — appid `vin_decoder`
4. `flipper95` (Tools) — appid `flipper95`
5. `chess` (Games) — appid `chess`

No other app, base-firmware feature, or Unleashed subsystem is in scope for this
plan. This is a smoke test of the 5 newly-integrated apps, not a general firmware
QA pass.

## Objective

Confirm, on real hardware, that each of the 5 apps:
- appears correctly in its expected menu location,
- launches without crashing,
- responds to basic navigation and input,
- exits cleanly back to the menu,
- causes no crash, freeze, reboot, or unexpected hardware activation anywhere in
  the process.

This is a **smoke test**, not a functional or correctness audit. It is meant to
catch "does it even run" problems, not to validate every feature, edge case, or
calculation the apps expose. Confidence that the underlying app logic is correct
comes from these being individually source-audited, upstream open-source apps
(Phase 1.6), not from this smoke test.

## Explicit safety scope — what is and is not tested

**In scope (the only things this smoke test exercises):**
- App visibility in the correct menu category
- App launch and exit
- Basic on-screen navigation (D-pad / OK / Back)
- One normal-input case and one invalid/edge-input case per app, limited to each
  app's own UI (text/number entry, menu selection)
- `chess`'s private save/load file behavior (its own on-device save file only)
- Absence of crash, freeze, reboot, or unexpected hardware activation
- Absence of storage writes outside each app's own private data path

**Explicitly OUT of scope — do not test, demonstrate, or attempt any of the
following, on any app, at any point in this smoke test:**
- Sub-GHz / RF transmit or receive of any kind
- NFC, RFID, or iButton read, write, emulate, or clone operations
- BadUSB / HID keystroke injection
- BLE spam, beacon, or profile behavior
- Direct GPIO control
- Infrared transmit
- Any credential, token, or password handling
- Any form of unauthorized access, cloning, brute force, jamming, or bypass
  behavior
- Any behavior not already confirmed absent by `PHASE2A_SAFETY_REVIEW.md`'s
  capability grep (all 5 apps already confirmed to contain none of the above APIs
  in source — this smoke test is a runtime sanity check on top of that, not a
  search for hidden radio/HID/GPIO behavior)

If, during testing, any of the above activity is observed unexpectedly (e.g. the
device's Sub-GHz/NFC/BLE indicator activates when none of these apps should touch
it), **stop immediately** and record it as a global fail condition (see below) —
do not continue investigating live on hardware; report it instead.

## Test methodology

1. Complete `PHASE2A_FLASHING_PRECHECK.md` in full before flashing.
2. Flash the verified commit's firmware using your normal qFlipper/`fbt` procedure.
3. Once booted, work through `PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` app by app,
   in the order listed above.
4. Record every result — pass, fail, or anomaly — in a copy of
   `PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`. Do not skip recording a step
   because it "obviously passed" — the whole point of a written record is that it
   doesn't rely on memory.
5. If a **global fail condition** (below) occurs at any point, stop testing
   immediately, follow the rollback path in `PHASE2A_FLASHING_PRECHECK.md` §5, and
   report the failure — do not continue on to the next app.
6. If an app-specific fail condition occurs, record it, stop testing *that app*,
   and continue to the next app only if the device itself is still in a known-good
   state (no global fail condition present).

## Global fail conditions (stop testing immediately if any occur)

- Device boot loop
- Any app crash (returns to menu unexpectedly, or device resets)
- Hard freeze (device stops responding to any button)
- Unexpected reboot
- Any unexpected RF / NFC / BLE / HID / GPIO / IR activity (LED indicators,
  emitted signals, or logged activity for any of these subsystems, when the app
  being tested has no reason to touch them)
- Storage corruption (SD card becomes unreadable, existing files disappear or are
  altered outside the app under test's own data path)
- Any app writing outside its own expected app-private path (see each app's
  section in the checklist for its expected path)
- Battery/power abnormality (unexpected shutdown, abnormal drain, charge failure)
- Menu registration problem (an app is missing from its expected category, appears
  under the wrong category, or the menu itself fails to render)
- Any unexpected warning, error dialog, or log entry not described as expected
  behavior in the checklist

A global fail condition is a reason to stop, roll back, and report — not to debug
live on hardware. Root-causing a real hardware-observed failure is follow-up work
for a future session with the failure details in hand, not something to improvise
on-device.

## Pass criteria for the batch overall

The Phase 2A smoke test as a whole is only a PASS if **all 5 apps individually
pass** their per-app criteria in the checklist **and** no global fail condition
occurred at any point. A partial pass (e.g. 4 of 5 apps clean, one app failing)
is not a batch pass — record it exactly as it happened; per-app rollback
(`PHASE2A_ROLLBACK_PLAN.md`) exists precisely to let one failing app be pulled
without discarding the other 4.

## What this plan does not claim

- This document does not claim hardware testing has occurred. It is a plan for a
  test the user will run, not a report of one that already happened.
- Completing this smoke test, even fully passing, does **not** make the firmware
  release-ready. Release-readiness also requires the project's full release-gate
  checklist, which is out of scope here.
- This smoke test does not validate correctness of app logic (e.g. that
  `programmer_calc`'s arithmetic is right in every base, or that `vin_decoder`
  decodes every VIN field correctly) — only that the apps run without crashing and
  respond to basic input. Deeper functional testing, if wanted, is a separate,
  future task.

**Hardware flashing/testing status as of this document: NOT PERFORMED.** This
plan, the checklist, the results template, and the pre-flash check are all
preparation for a test the user has not yet run.

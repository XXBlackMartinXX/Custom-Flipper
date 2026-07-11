# Rollback Readiness After Install

## POST-INSTALL ROLLBACK READINESS EXECUTION: NOT PERFORMED

This is a planning/template document, not a results document. No
installation has occurred under `docs/CONTROLLED_INSTALLATION_PLAN.md`,
so no rollback has been attempted or is currently needed. This document
describes what rollback readiness and execution should look like if it
is ever required after a real installation attempt.

## Official/stable recovery path

If the device fails to boot normally after a real installation attempt,
the preferred recovery path is restoring the **official/stable Flipper
Zero firmware** via qFlipper's own official-firmware recovery flow —
not repeated attempts to reinstall the custom build. See
`docs/CONTROLLED_INSTALLATION_PLAN.md` Section L for the full recovery
decision tree.

## Exact DFU identity required for recovery

Recovery relies on the device being reachable in DFU/recovery mode under
its exact identity:

```
VID_0483&PID_DF11
```

A generic "DFU"-named device, or any other `InstanceId`, must never be
treated as confirming recovery-mode reachability — only this exact
identity does.

## Recovery authorization phrase

Before any recovery action is taken, the operator must type, exactly:

```
I AUTHORIZE OFFICIAL FIRMWARE RECOVERY
```

No recovery action - repair, erase, or official-firmware reinstall - may
proceed without this exact phrase having been typed by the operator.
This is a separate authorization from the installation authorization
phrase in `docs/CONTROLLED_INSTALLATION_PLAN.md` Section E, and is never
implied by it.

## Expected evidence if rollback is ever executed

If rollback is executed, the following should be recorded (in an update
to this document, replacing this stub, not appended to it):

- Whether normal boot failed, and how (boot loop, freeze, crash screen,
  no power, etc.).
- Whether exact DFU mode (`VID_0483&PID_DF11`) was reached.
- qFlipper logs from the recovery attempt.
- Photos of the device screen during the failure, if useful.
- The exact recovery action taken (e.g. official-firmware reinstall via
  qFlipper).
- Whether the recovery authorization phrase was typed exactly before any
  action was taken.
- The outcome of the recovery action.
- Whether normal boot was confirmed after recovery.
- Whether any internal device data was lost as a result of recovery.

## Internal-data-loss warning

**qFlipper's repair/recovery flow may erase internal device data.** This
is a known, accepted risk of any recovery action, not a defect. The
backup procedure in `docs/CONTROLLED_INSTALLATION_PLAN.md` Section C
exists specifically to reduce (not eliminate) the impact of this risk,
by capturing supported settings and microSD contents before the
installation attempt that might necessitate recovery.

## Rollback success criteria

A rollback attempt should be considered successful only when **all** of
the following are true and actually observed, not assumed:

- The device powers on.
- The desktop appears.
- Buttons respond normally.
- No boot loop, crash screen, or freeze is observed.
- The device is confirmed running official/stable firmware (not the
  custom build) after recovery.
- microSD is recognized.
- USB reconnects normally and qFlipper detects the device in normal
  mode.
- Windows detects the exact normal-mode identity `VID_0483&PID_5740`.
- One additional normal reboot passes cleanly.

If any of the above is not true, the rollback should be classified
`INSTALLATION FAILED — RECOVERY STILL REQUIRED`, not treated as
resolved.

## Current status

- Rollback has not been executed.
- No internal data loss has occurred (none has been necessary).
- This document will be updated with real evidence only after a real
  recovery attempt, if one is ever required.

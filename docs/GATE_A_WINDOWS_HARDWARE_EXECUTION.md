# Gate A Windows Hardware Execution

This document describes how to run **Gate A** of the Custom-Flipper
Ultimate vNext automated hardware test platform on a real Windows PC
against a real, already-installed Flipper Zero. It is the authoritative
reference for the one-command runner,
`tools/hardware_app_tester/Run-GateA-HardwareProof.ps1`.

**Read this before connecting a device.** It exists so that the human
operator only ever needs to do a small, fixed list of physical actions,
and so that the automated tool never does anything that risks the
device's already-accepted installed firmware baseline.

## What this is NOT

- This is **not** a firmware flashing tool. It contains no flashing,
  update, install, Repair, erase, or format capability of any kind.
  This is a checked design invariant
  (`tests/test_no_destructive_capability.py`), not a promise.
- This does **not** reinstall, upgrade, or modify the Flipper's firmware
  in any way. The device's currently accepted, operator-confirmed
  installed firmware baseline (`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`)
  is left exactly as it is.
- This does **not** put the device into DFU mode, and it will refuse to
  proceed if it ever detects `VID_0483&PID_DF11` (DFU identity) instead
  of, or alongside, `VID_0483&PID_5740` (normal identity).
- This does **not** automate RF, Sub-GHz, NFC, RFID, iButton, BadUSB,
  BLE, GPIO, or infrared operations, and does not test credentials,
  authentication, access control, replay, bypass, brute force, jamming,
  HID injection, seeds, wallets, or private keys.
- This can **never** emit `GATE A HARDWARE PROOF PASS`. See "Honest
  capability ceiling" below.

## Prerequisites

- Windows 10 or 11.
- A supported Python (3.10+) reachable via `py -3`, `python3`, or
  `python` on `PATH`. The runner detects and validates this itself and
  refuses to proceed on an unsupported version.
- PowerShell 5.1 (built into Windows) or PowerShell 7 (`pwsh`). The
  script is written to run correctly under either.
- Git, with this repository cloned and checked out on branch
  `feature/ultimate-vnext-test-census-architecture`.
- One Flipper Zero, normally booted (not in DFU mode), connected via a
  known-good USB data cable, showing normal USB identity
  `VID_0483&PID_5740`.
- qFlipper (or any other application that might hold the Flipper's
  serial port) installed but not required to be closed until the
  script prompts you.

## Exact one-command invocation

From the repository root, in PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1
```

Or, for a first conservative dry run that touches no device at all:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1 -DryRun
```

Other supported parameters:

- `-RepoRoot <path>` - override the detected repository root.
- `-Mock` - developer regression mode only, exercises the full
  orchestration logic against a synthetic in-process transport, never
  a real device. Every result is labeled `HARDWARE EXECUTION: NOT
  PERFORMED`. Never usable as real hardware evidence. Ignored if
  `-DryRun` is also given.
- `-SkipSafeAutomationExpansion` - answers the Part I "run all
  remaining SAFE_AUTOMATION profiles?" prompt as declined
  automatically, for a conservative Gate-A-only run.

## What is automated

- Repository verification: confirms the repo path, branch, remote,
  a clean working tree, and pulls the latest commit (fast-forward
  only) before recording the exact HEAD commit used for the run.
- Environment preparation: detects a supported Python, creates an
  isolated virtual environment under `tools/hardware_app_tester/.venv`
  (gitignored, never installed system-wide), installs only the pinned
  dependencies in `requirements.txt`, records their exact installed
  versions, parse-checks every Python file, and runs the complete host
  `pytest` suite before any device interaction is attempted.
- Test-profile validation: confirms exactly 20 current app profiles,
  unique app IDs and paths, and cross-checks every profile's declared
  `source_path`/`launch_target` against the real `application.fam` in
  this repository.
- Device discovery: requires exactly one device matching
  `VID_0483&PID_5740`, no device matching `VID_0483&PID_DF11`, and one
  unambiguous COM port - and refuses to guess in every other case
  (zero devices, DFU-only, both present, multiple normal devices,
  ambiguous ports).
- Serial-port contention handling: detects if something else (most
  likely qFlipper) is holding the port, and if so, stops and asks you
  to close it (see below) before making exactly one retry attempt. It
  never terminates another process itself.
- A read-only CLI handshake (uptime, loader state, free heap) before
  any application is launched.
- The Gate A 5-app run, using 5 representative `SAFE_AUTOMATION`
  profiles (see below), and optionally the remaining `SAFE_AUTOMATION`
  profiles if you confirm the Part I prompt.
- Full evidence collection into a fresh, collision-resistant directory
  under `reports/hardware_app_tester/`.

## Unavoidable human actions

Exactly these, and nothing else:

1. Connect one normally booted Flipper Zero to the PC.
2. Keep the device on its desktop/home screen; do not navigate menus
   unless a step explicitly asks you to observe something.
3. When prompted, close qFlipper (or any other application that might
   be holding the Flipper's serial port) - see "How to close qFlipper
   safely" below.
4. Observe the physical device only when a step explicitly asks you to.
5. Never enter DFU mode (do not hold the Back button through boot, and
   do not trigger DFU from qFlipper).
6. Never approve a firmware installation, Repair, erase, or format
   prompt - the script never asks for this, and if any other
   application (e.g. qFlipper) prompts you for one while this script is
   running, decline it and stop the run.

## How to close qFlipper safely

1. Open qFlipper's window (or its system-tray icon).
2. Disconnect the device from within qFlipper first if it shows an
   active connection, then close the qFlipper application entirely
   (not just minimize it) - right-click the tray icon and choose
   "Quit"/"Exit" if it runs in the tray.
3. Do not disconnect the USB cable to do this - only close the
   software.
4. Return to the PowerShell window and confirm as instructed. The
   script allows exactly one retry after this confirmation; if the
   port is still unavailable, it stops with `BLOCKED` rather than
   retrying indefinitely.

## Expected duration

Not yet measured against real hardware in this repository (no real
device has been used to execute this script). For reference, in the
Linux development sandbox used to build and validate this script,
`-DryRun` (repository verification, environment setup, the full pytest
suite, and profile validation - no device interaction) completed in
well under a minute on a warm virtual environment. The real hardware
phases (device discovery, handshake, and 5 app launch/close cycles)
add real device round-trip time on top of that; expect this to be on
the order of a few minutes for Gate A alone, longer if you accept the
Part I expansion to all remaining `SAFE_AUTOMATION` profiles.

## Evidence location

Every run creates a fresh directory:

```
reports/hardware_app_tester/<UTC timestamp>-<random nonce>/
```

containing (subject to what a given run phase actually reaches):
`run_manifest.json`, `environment.json`, `repository.json`,
`dependency_versions.json`, `device_discovery.json`,
`serial_handshake.json`, `inventory_reconciliation.json`,
`profile_validation.json`, `app_results.json`, raw and per-app serial
logs, `pytest_output.log`, `summary.md`, and `checksums.sha256`. This
directory is never committed to git (evidence is a run artifact, not
source).

## Stop conditions

The script (and the underlying per-app run loop) stops the entire run,
rather than continuing or silently skipping, if any of the following
occurs:

- The device's USB identity disappears.
- The device's reported uptime resets (indicates an unexpected reboot).
- The CLI stops responding within its timeout.
- The device reboots unexpectedly.
- Panic/fault text appears in device output.
- An application refuses to close via its declared exit method.
- The loader state cannot be restored to idle after closing an app.
- Discovery indicates the wrong app, an ambiguous device set, or DFU
  mode at any point.
- An operation not declared in the active profile becomes reachable.
- Device state otherwise becomes uncertain.

The script never automatically reboots the device after an unexplained
failure, and never silently marks a failed or skipped test as passing.

## Classification interpretation

Exactly these strings may appear as the final classification, and no
others:

- `GATE A HARDWARE PROOF PARTIAL` - the 5-app Gate A run completed
  without an integrity-threatening failure, but (see "Honest capability
  ceiling") input/screen verification was not performed, so this is a
  clean-launch/close/continuity result, not a full pass.
- `GATE A HARDWARE PROOF BLOCKED` - the run could not proceed past a
  precondition (repository state, environment, profiles, device
  discovery, port contention, or handshake) and no application was
  launched.
- `GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW` - a stop
  condition fired during an app run; treat the physical device as
  needing manual inspection before any further automated use.
- `GATE B SAFE-AUTOMATION QUALIFICATION PARTIAL` - the Part I
  expansion to the remaining `SAFE_AUTOMATION` profiles was accepted
  and completed under the same rules as Gate A (same capability
  ceiling, same "no PASS" rule).
- `GATE A WINDOWS EXECUTION PACKAGE READY / REAL HARDWARE RUN NOT YET
  PERFORMED` - only ever emitted by `-DryRun`, meaning the non-hardware
  phases succeeded and the package is ready to run against a real
  device, but no device interaction has occurred yet.
- `GATE A WINDOWS EXECUTION PACKAGE BLOCKED` - a non-hardware
  precondition failed before device interaction was even attempted
  (bad repo state, unsupported Python, failing pytest suite, invalid
  profiles, etc).

**`GATE A HARDWARE PROOF PASS` will never be emitted by this version of
the tool**, on any device, under any conditions - see the next section.

## Honest capability ceiling

The underlying Python tester (`hardware_app_tester/cli.py` and its
collaborators) can perform, for real: device discovery, a read-only CLI
handshake, a real `loader open`/`loader close` round trip, and real
uptime/USB-identity/free-heap-continuity and panic-log crash detection.

It **cannot yet** send a profile-declared input sequence to the device
or capture/compare a screen fingerprint, because `rpc_client.py` (the
Flipper protobuf RPC client) is an intentional, documented skeleton in
this phase - it has no compiled protobuf stubs and sends no RPC frames.

Because of this gap, no per-app result, and no overall run, can ever be
classified `PASS` - only `NEEDS_REVIEW` (clean launch/close/continuity,
input/screen not verified) or lower (`FAIL`/`BLOCKED`). This is a
deliberate, fail-closed design choice, not an oversight: it satisfies
this gate's own rule that "no overall PASS may be emitted unless raw
evidence supports every required condition."

## Gate A representative apps

Five low-risk `SAFE_AUTOMATION` profiles, chosen to cover distinct
behavior classes: `programmer_calc` (calculator/parser), `vin_decoder`
(data lookup), `quadratic_solver` (deterministic utility),
`sudoku` (puzzle/game), `resistors` (simple UI/state machine). The
remaining 5 `SAFE_AUTOMATION` profiles (`2048`, `chess`,
`crypto_dictionary`, `fap_boilerplate`, `minesweeper_redux`) are only
run if you accept the Part I expansion prompt.

## Explicit statements

- **This tool will never flash firmware onto your Flipper Zero.**
- **This tool will never install, update, or Repair your Flipper's
  firmware. Do not run qFlipper's Update or Repair function as part of
  this procedure, and do not do so in response to anything this script
  prints.**
- If you see any prompt (from qFlipper or Windows) asking to install,
  update, Repair, erase, or format the device while this script is
  running, decline it, stop the script, and treat the device as
  needing manual review before continuing.

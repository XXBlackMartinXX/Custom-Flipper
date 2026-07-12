# Gate A Operator Quickstart

Short version of `docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md`. Read that
document first if this is your first run. This tool never flashes,
installs, updates, Repairs, erases, or formats your Flipper Zero.

## Before you start

- [ ] Windows PC, Python 3.10+ on `PATH`, PowerShell 5.1 or 7.
- [ ] Repository cloned, on branch
      `feature/ultimate-vnext-test-census-architecture`.
- [ ] One Flipper Zero, normally booted (not DFU), plugged in with a
      known-good data cable.
- [ ] qFlipper may be open for now - you will be told when to close it.

## Run it

From the repository root, in PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1
```

Want to check everything except the device first? Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1 -DryRun
```

**Recommended for your very first real-hardware run**: check just the
serial connection before running the full app set -

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\hardware_app_tester\Run-GateA-HardwareProof.ps1 -ProbeOnly
```

A successful probe prints `SERIAL PROBE PASS` / `READ-ONLY HANDSHAKE
PASS` / `APPLICATIONS LAUNCHED: NO` / `FIRMWARE OPERATIONS: NO` and
exits without touching any app. Only run the full command (no
switches) after that succeeds.

## What you will be asked to do

1. Keep the Flipper connected and on its desktop/home screen.
2. If asked, close qFlipper entirely (Quit/Exit, not just minimize),
   then confirm in the PowerShell window. Do not unplug the cable.
3. Watch the device screen only if a step tells you to.
4. If you ever see a firmware install/update/Repair/erase/format
   prompt from any application while this is running - decline it and
   stop the script.
5. When asked "Run all remaining SAFE_AUTOMATION profiles now? [y/N]",
   answer `N` for a first, conservative run, or `y` to also run the
   remaining 5 low-risk apps.

## Reading the result

Look at the final classification line. Full meanings are in
`docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md`, but in short:

| Classification | Exit code | Meaning |
|---|---|---|
| `GATE A WINDOWS EXECUTION PACKAGE READY / REAL HARDWARE RUN NOT YET PERFORMED` | 0 | `-DryRun` only - everything except the device checked out fine. |
| `GATE A WINDOWS EXECUTION PACKAGE BLOCKED` | 2 | Stopped before touching the device (bad repo/env/profiles). |
| `GATE A HARDWARE PROOF BLOCKED` | 2 | Stopped at device discovery/port/handshake - no app was launched. |
| `GATE A HARDWARE PROOF PARTIAL` | 0 | Gate A's 5 apps launched/closed cleanly; input/screen verification is not implemented yet, so this is not a full PASS. |
| `GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW` | 3 | Something integrity-threatening happened - stop and inspect the device by hand. |
| `GATE B SAFE-AUTOMATION QUALIFICATION PARTIAL` | 0 | You accepted the expansion prompt (or declined it) and nothing integrity-threatening happened. |
| `GATE A WINDOWS EXECUTION PACKAGE INTERNAL ERROR` | 1 | Something went wrong inside the tooling itself, not an expected device/repo condition. |

This tool never emits `GATE A HARDWARE PROOF PASS` - see the full
document's "Honest capability ceiling" section for why. If you're
scripting around this tool, check the process exit code rather than
parsing the printed text - see the full document's "Exit-code contract"
table.

## Where to look afterward

Evidence is written to a new folder under
`reports/hardware_app_tester/<timestamp>-<nonce>/`. Start with
`summary.md` in that folder.

## If something goes wrong

See `docs/GATE_A_TROUBLESHOOTING.md`.

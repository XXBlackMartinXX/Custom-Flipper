# Gate A Troubleshooting

Companion to `docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md` and
`docs/GATE_A_OPERATOR_QUICKSTART.md`. **Firmware Repair/reinstall is
never a recommended troubleshooting step here** - if a symptom below
looks like it might need that, stop and treat it as a device-integrity
question to investigate manually, not something to fix by reflashing.

## No COM port / device discovery blocked

`device_discovery.json` will say why. Common, non-destructive causes:

- Device not connected, or connected but still booting - reconnect the
  cable and wait for it to reach its normal desktop screen, then rerun.
- Wrong cable (charge-only, no data lines) - swap to a known-good data
  cable.
- Windows enumerated the port but no exact `VID_0483&PID_5740` match
  was found - check Device Manager for how Windows is actually
  identifying the device; do not assume a FriendlyName match is enough
  (this tool deliberately doesn't accept those).

## qFlipper (or another process) holding the port

The script detects this and prints a `BLOCKED - PORT CONTENTION`
status with instructions. It will:

1. Ask you to close qFlipper (Quit/Exit from the tray icon, not just
   minimize the window).
2. Wait for your explicit confirmation.
3. Retry exactly once.

If it is still blocked after that one retry, close the script, confirm
in Windows Task Manager that no leftover qFlipper process remains, and
start over from the beginning rather than retrying indefinitely.

## DFU mode detected

If `device_discovery.json` reports a device matching
`VID_0483&PID_DF11`, the script stops immediately - it will not attempt
to work around this. Physically reboot the device to its normal
desktop (not by holding the button combination that enters DFU) and
reconnect, then rerun. Do not open qFlipper's Update/Repair flow to
"fix" this - that flow is what puts the device into DFU mode in the
first place.

## Multiple devices detected

The script requires exactly one Flipper Zero and refuses to guess
which one you mean. Disconnect every Flipper except the one you intend
to test, then rerun.

## CLI unavailable / handshake fails

`serial_handshake.json` records what failed (no prompt reached, no
response within timeout, etc). Causes to check, in order:

1. Something else opened the port between discovery and handshake -
   re-check for qFlipper or another serial monitor.
2. The device is showing a menu/dialog on-screen that is blocking CLI
   responses - return it to the normal desktop screen and rerun.
3. A USB hub or cable issue causing intermittent connectivity - connect
   directly to a PC USB port instead of through a hub.

Do not respond to a CLI failure by running qFlipper's Repair function.

## App missing / launch target not found

`profile_validation.json`'s repository cross-check will name the exact
profile and mismatch (missing `source_path`, missing/unreadable
`application.fam`, or an `appid` that doesn't match the profile's
`launch_target`). This indicates the checked-out source tree doesn't
match what the profile expects - confirm you're on the correct branch
and commit, not a device problem.

## App timeout (launch or close doesn't return in time)

`app_results.json`'s entry for that app will show
`exit_result`/`logs` including `timed_out=True`. The run stops rather
than continuing to the next app. Do not force-close the app on-device
and continue the same run - the run's evidence is only valid up to the
point of the timeout. Restart the whole script for a fresh run once you
have confirmed the device is back at its normal desktop.

## USB disconnects mid-run

The run stops immediately and is classified
`GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW`. Reconnect
the device, confirm it returns to its normal `VID_0483&PID_5740`
identity and boots normally on its own, and treat this as worth
investigating (cable, port, or device issue) before running Gate A
again - do not immediately re-run without understanding why it
disconnected.

## Unexpected reboot (uptime resets) mid-run

Same handling as a USB disconnect: the run stops and is classified
`GATE A HARDWARE PROOF FAILED / DEVICE STATE NEEDS REVIEW`. This is
exactly the kind of result this tool is designed to catch rather than
paper over - do not dismiss it, and do not respond to it by reflashing
or repairing the device.

## Evidence directory recovery

Every run's evidence goes to a fresh
`reports/hardware_app_tester/<timestamp>-<nonce>/` directory, so a
failed or interrupted run never overwrites a previous run's evidence.
If a run is interrupted (e.g. you closed the PowerShell window), the
partial directory for that run remains on disk with whatever files
were written up to that point - `run_manifest.json` (if present) will
show `dry_run`/`mock` and whatever classification was reached; a
missing `checksums.sha256` indicates the run did not reach its normal
end. This is informational only; simply rerun the script to produce a
new, complete evidence directory.

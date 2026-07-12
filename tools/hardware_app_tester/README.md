# Hardware App Tester

A Windows-first host test runner that communicates with **one** normally
booted Flipper Zero over its exact USB serial (CDC-ACM) interface, using
the device's line-based CLI and (where implemented) the official
protobuf RPC interface. It does not automate qFlipper's graphical
interface, and it contains **no flashing, update, repair, erase, or
format capability of any kind** — this is a design invariant, checked by
`tests/test_no_destructive_capability.py` (a source-text grep test, the
same pattern used by `tools/pre_flash_safeguard_gate.ps1`'s own
regression suite).

## Honest status of this tool, as of this commit

**This code has been written and, where possible, unit-tested against
synthetic/mocked serial data in a Linux cloud sandbox with no Windows
machine, no physical Flipper Zero, and no serial port available to it.**
It has **not** been executed against real hardware. Nothing in this
directory, or in any report referencing it, should be read as a claim
that an automated hardware test has actually run on a physical device.

What *has* been validated in this sandbox, for real, via `pytest`:

- Device-discovery classification logic (`discovery.py`), against
  synthetic COM-port listings — exact VID:PID matching, DFU rejection,
  ambiguous-multiple-device rejection, and port-contention detection
  are all pure functions that accept a list of port descriptors rather
  than calling `serial.tools.list_ports` directly, mirroring the
  enumeration/evaluation separation already used in
  `tools/pre_flash_safeguard_gate.ps1`.
- Evidence-file writing (`evidence.py`) — collision-resistant filenames
  (millisecond timestamp + random suffix), verified with a real
  concurrent-write test.
- Test-profile schema validation (`profile_schema.py`) against the 20
  YAML descriptors in `tests/hardware/apps/`.

What has **not** been validated, because it requires real hardware:

- `serial_cli.py` and `rpc_client.py` — the actual CLI/RPC transport
  code. This is real, intended-to-work code written against the
  documented Flipper Zero CLI and RPC protocol, but it has never been
  run against a real device's serial port in this session.
- Any app launch, screen capture, input injection, or crash-detection
  behavior described in `docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md`.

## Requirements (for real, future execution on Windows)

- Windows 10/11
- Python 3.10+
- `pyserial`
- `protobuf` (matching the Flipper firmware's own RPC `.proto`
  definitions, compiled separately — this tool does not vendor them)
- A Flipper Zero connected in **normal mode** (`VID_0483&PID_5740`) with
  a known-good USB data cable

## What this tool will never do

- Flash, update, repair, erase, or format the device.
- Automate qFlipper's GUI.
- Transmit Sub-GHz, infrared, NFC/RFID/iButton signals, or BLE control
  of another device.
- Execute BadUSB/HID payloads.
- Perform GPIO output to unknown hardware.
- Perform destructive storage operations, factory reset, or enter DFU
  mode on its own initiative.

## Package layout

```
hardware_app_tester/
  __init__.py
  cli.py                - the CLI entrypoint (validate-profiles, discover,
                          handshake, probe-serial, run-gate-a,
                          run-safe-automation)
  discovery.py         - device discovery (enumeration/evaluation separated)
  serial_cli.py        - line-based Flipper CLI client (loader open/list/etc.);
                          bounded read+write timeouts, raw-byte prompt
                          synchronization, per-stage transport diagnostics
  rpc_client.py         - protobuf RPC client skeleton (screen frames, input)
  mock_transport.py     - synthetic in-process transports: FakeSerialConnection
                          (--mock mode, line-scripted) and FakeRawSerialConnection
                          (raw-byte fault injection for transport-hardening tests)
  device_state.py       - best-effort uptime/heap/loader-state parsing
  profile_schema.py    - tests/hardware/apps/*.yaml schema + loader
                          + repository cross-check
  evidence.py          - collision-resistant JSON/Markdown evidence writer,
                          plus atomic_write_json for incremental stage evidence
  test_runner.py       - library helpers used by cli.py
  crash_detection.py    - uptime/heap/loader-state regression checks
tests/
  test_discovery.py
  test_evidence.py
  test_profile_schema.py
  test_no_destructive_capability.py
  test_serial_cli_hardening.py
  test_crash_detection.py
  test_cli_hardening.py
  test_serial_transport_hardening.py
  test_exit_code_contract.ps1
  test_serial_transport_hardening.ps1
Run-GateA-HardwareProof.ps1 (one directory up) - the Windows one-command
  runner; see docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md.
```

## Running the unit tests (no hardware required)

```bash
cd tools/hardware_app_tester
pip install -r requirements.txt
pytest tests/
```

These tests exercise only the pure, hardware-independent logic listed
above. They do not, and cannot, prove that this tool works against a
real device.

## Running the CLI directly (no hardware required for --dry-run/--mock)

```bash
cd tools/hardware_app_tester
python -m hardware_app_tester.cli validate-profiles --repo-root ../..
python -m hardware_app_tester.cli run-gate-a --repo-root ../.. --report-dir /tmp/report --dry-run
python -m hardware_app_tester.cli probe-serial --port COM6 --output serial_probe.json
```

`probe-serial` is the narrowest real-hardware check this tool offers:
open the port (bounded read/write timeouts), synchronize to the CLI
prompt (raw-byte, framing-independent), optionally one read-only
command (default `uptime`), close. Never launches an application, never
performs a firmware operation. Recommended as the very first real
command run against new hardware - see `Run-GateA-HardwareProof.ps1
-ProbeOnly` for the one-command equivalent that also does repository
verification and device discovery first.

For the full, one-command Windows execution package (repository
verification, environment setup, profile validation, device discovery,
handshake, and the Gate A app run), see
`Run-GateA-HardwareProof.ps1` and
`docs/GATE_A_WINDOWS_HARDWARE_EXECUTION.md`.

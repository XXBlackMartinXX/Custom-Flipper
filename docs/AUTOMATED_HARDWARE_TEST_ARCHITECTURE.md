# Automated Hardware Test Architecture

## Honest status

**This document describes an architecture and a real, unit-tested-
where-possible codebase (`tools/hardware_app_tester/`). It does not
describe a system that has been run against real Flipper Zero hardware
in this development session** — this session is a Linux cloud sandbox
with no Windows machine, no physical Flipper Zero, and no serial port.
Every claim in this document is scoped precisely to what has and has
not been verified; see `docs/AUTOMATED_HARDWARE_TEST_RESULTS.md` for the
run-by-run honest accounting.

## Goals

A Windows-first host test runner that communicates with **one**
normally booted Flipper Zero over its exact USB serial (CDC-ACM)
interface, using the device's line-based CLI and (where implemented)
the official protobuf RPC interface, with minimal human interaction and
**zero** flashing/update/repair/erase/format capability.

## Why not automate qFlipper's GUI

qFlipper is a Qt desktop application; automating its GUI would mean
either OS-level UI automation (fragile, version-dependent, and outside
this project's established discipline of preferring direct, inspectable
protocols over GUI scripting) or reverse-engineering qFlipper's own
internal RPC usage. The Flipper Zero's CLI and RPC protocols are
documented, versioned, and directly accessible over the same serial
port — this is the same reasoning that led every prior phase of this
project to prefer `git`/`Get-PnpDevice`/direct hash computation over
GUI automation of qFlipper for the pre-flash safeguard gates.

## A. Device discovery

`hardware_app_tester/discovery.py` implements exact VID:PID identity
matching (`0483:5740` normal mode, `0483:df11` DFU/recovery — the same
identities `tools/pre_flash_safeguard_gate.ps1` already enforces),
never a FriendlyName/description match. It rejects:

- DFU mode (`BLOCKED - DEVICE IN DFU MODE`) — this tester only operates
  against a normally booted device.
- No device present (`BLOCKED - NO NORMAL-MODE DEVICE DETECTED`).
- Ambiguous multiple normal-mode devices (`BLOCKED - AMBIGUOUS MULTIPLE
  DEVICES`) — refuses to guess which one to test.
- Port contention (`BLOCKED - PORT CONTENTION`) — detects when another
  process (commonly qFlipper itself) already holds the serial port.

Enumeration (`list_present_ports()`, the only function touching a real
OS API) is separated from classification (`classify_ports()`, a pure
function), mirroring the enumeration/evaluation separation already
proven in `tools/pre_flash_safeguard_gate.ps1`. This separation is what
makes 8 of the module's unit tests runnable in this Linux sandbox with
zero real hardware — see `tools/hardware_app_tester/tests/test_discovery.py`,
all passing for real via `pytest` in this session.

This module contains **no** flash/update/repair/erase/format
capability — enforced as a design invariant and checked by
`tests/test_no_destructive_capability.py`.

## B. Application inventory reconciliation

Sources to reconcile (architecture defined; automated reconciliation
against a real device's actual loader/storage output has not been
implemented or run in this phase, since it requires a live serial
connection):

1. **Source manifests**: `applications/**/application.fam` (none in
   this project's own tree — all 20 apps are `applications_user/**`)
   and `applications_user/**/application.fam` (real, already present in
   this repository).
2. **Build output**: generated FAP inventory (from a real `fbt` build,
   itself blocked in this sandbox by network policy per
   `docs/PHASE0_SOURCE_VERIFICATION.md`) and built-in application
   inventory (none currently, since all 20 apps are external FAPs).
3. **Device inventory**: `loader list` (via `serial_cli.py`) and a
   storage tree/list for external app folders (`/ext/apps/`) — real,
   intended code exists in `serial_cli.py`; has not been run against
   real hardware.
4. **Expected inventory manifest**: `tests/hardware/apps/*.yaml`, one
   file per app, validated by `hardware_app_tester/profile_schema.py`
   and enforced against exactly the current 20-app set by
   `tests/test_profile_schema.py::test_all_twenty_real_profiles_load_and_validate`
   (passing for real in this session).

Fail conditions (missing expected app, unexpected unapproved app,
duplicate app IDs, duplicate destination paths, incompatible FAP,
absent provenance) are architecturally defined here; the actual
reconciliation logic comparing manifest vs. build vs. device inventory
has not been implemented in this foundation phase — schema validation
and duplicate-app-ID detection *within* the test-profile set itself has
been implemented and is unit-tested
(`tests/test_profile_schema.py::test_no_duplicate_app_ids_across_real_profiles`).

## C. Automated safe launch test

For every app classified `SAFE_AUTOMATION`
(`hardware_app_tester/test_runner.py::run_single_app_test`):

1. Record uptime/loader-state/free-heap (via `serial_cli.py`'s
   `uptime()`/`loader_info()`/`free_heap()` — real code, not yet run
   against hardware).
2. Launch via `loader open <target>` (built-in or external-FAP appid —
   this project's own census confirms all 20 apps use a single-string
   `appid`-based launch, not a full file path).
3-4. Confirm the loader reports the expected running app; wait for a
   configurable timeout (`profile.timeout_seconds`).
5-6. Capture logs and one or more RPC screen frames — **not
   implemented**; `rpc_client.py` is a documented skeleton only (see its
   module docstring for exactly why: the Flipper RPC protobuf schema
   needs to be compiled from the exact firmware version's `.proto`
   files, which was out of scope for this foundation phase).
7. Compare the screen against app-specific fingerprints — depends on
   step 5-6, not implemented.
8-9. Send only declared-safe input sequences (`profile.input_sequence`,
   restricted to `UP/DOWN/LEFT/RIGHT/OK/BACK` by
   `rpc_client.ALLOWED_INPUT_KEYS`) and confirm expected transitions —
   depends on the RPC client, not implemented.
10-11. Exit via `profile.exit_method` and confirm desktop/loader idle
   return — `loader_close()` exists; idle-state confirmation depends on
   parsing real CLI output not yet captured/verified.
12. Recheck uptime/USB/heap/loader-state/crash indicators —
   `crash_detection.py` implements this as pure, unit-tested comparison
   functions (`tests/test_discovery.py`-style separation); real
   before/after snapshots require a live device.
13. Record `PASS`/`FAIL`/`BLOCKED`/`NOT_SUPPORTED`/`NEEDS_REVIEW` —
   `test_runner.py::run_single_app_test` currently returns `NOT_RUN`
   for every app, explicitly, because steps 5-11 above are not yet
   implemented against real hardware. **It never fabricates a `PASS`.**

## D. Test profiles

20 real YAML files exist at `tests/hardware/apps/*.yaml`, one per
current app, schema-validated by
`hardware_app_tester/profile_schema.py` (required fields, valid
automation classes, `FIXTURE_REQUIRED` profiles must declare a fixture,
`SAFE_AUTOMATION` profiles may not reference a forbidden operation in
their own input sequence — all enforced and unit-tested for real). See
`docs/CURRENT_20_APP_QUALIFICATION.md` for the automation-class
assignment rationale per app.

## E. Input safety

`rpc_client.ALLOWED_INPUT_KEYS` is a hard allow-list
(`UP/DOWN/LEFT/RIGHT/OK/BACK`); `send_input()` rejects any other key and
any hold duration over 3000ms (associated with device mode-change
button combinations, not app navigation). `profile_schema.py` separately
rejects any `SAFE_AUTOMATION` profile whose own declared
`input_sequence` references any of a fixed list of forbidden operation
substrings (Sub-GHz, infrared, NFC/RFID/iButton write/emulate,
BadUSB/HID, BLE control, GPIO output, factory reset, format, firmware
update, recovery, repair) — enforced and unit-tested
(`tests/test_profile_schema.py::test_safe_automation_cannot_reference_forbidden_operation`).

## F. Crash and hang detection

`crash_detection.py` implements pure comparison functions
(`check_uptime_continuity`, `check_usb_continuity`,
`check_heap_regression`, `check_loader_returned_to_idle`,
`scan_log_lines_for_panic`) over before/after `DeviceStateSnapshot`
pairs — real logic, unit-testable without hardware (not yet unit-tested
in this phase's test suite, though the pattern mirrors
`discovery.py`'s already-tested classification style; adding explicit
tests for this module is a natural next step). On any detected failure,
the architecture calls for stopping that app's test, preserving
evidence, and never automatically initiating DFU or Repair — consistent
with every prior phase's zero-flash discipline. No code path in this
tool performs a flash/update/repair/erase/format action; enforced by
`tests/test_no_destructive_capability.py`.

## G. On-device unit tests

See `tests/on_device/README.md` and `tests/on_device/logic/CANDIDATES.md`
— a real, source-grounded (not name-guessed) audit of which of the 20
apps contain pure, headlessly-testable logic. Two candidates were
directly confirmed by reading real source:
`resistors`' `resistor_logic.c` (10 pure boolean classifier functions)
and `network_subnet`'s `subnet_math.c` (bit-counting/CIDR arithmetic).
A third, `vin_decoder`, was checked and found to contain one pure lookup
function (`get_vehicle_manufacturer`) but **not** a checksum validator
(an earlier internal assumption to that effect was checked against the
real source and found wrong — corrected in `CANDIDATES.md`). No on-
device test has been compiled or run in this phase — that requires the
`fbt` build toolchain, blocked in this sandbox.

## H. Current 20-app qualification

See `docs/CURRENT_20_APP_QUALIFICATION.md` for the full per-app
automation-class assignment and honest test status. **No app is marked
`PASS` merely because it exists or because a profile was written for
it** — every one of the 20 profiles currently reports `NOT_RUN` for its
actual hardware test, because no hardware exists in this session to run
it against.

## Report format

`hardware_app_tester/evidence.py` writes collision-resistant
`<prefix>_<UTC timestamp with ms>_<4 hex chars>.json`/`.md` pairs,
verified for real in this session (concurrent-write test,
`tests/test_evidence.py::test_concurrent_writes_produce_no_collisions`,
10 simultaneous writes, 0 collisions) — the same naming discipline used
by every PowerShell gate script in this project since Phase 2C.4.

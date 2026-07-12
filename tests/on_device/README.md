# On-Device Unit Tests

**STATUS: architecture and skeleton only. Nothing in this directory has
been compiled or executed on real Flipper Zero hardware in this
development session** — that requires the full `fbt` build toolchain
(itself blocked in this sandbox by network policy, as documented since
`docs/PHASE0_SOURCE_VERIFICATION.md`) and a real device to run the
resulting `unit_tests` firmware image on.

## Intent

Extend the official Flipper Zero `unit_tests` framework
(`applications/debug/unit_tests/`) with plugin test suites for eligible
imported app logic, separating:

- **Pure logic tests** — parsers, calculators, data validation, file
  loaders, formatters, algorithms, state machines, persistence, error
  handling, boundary conditions. These require no UI, no screen, and no
  human interaction; they can run headlessly as part of the device's own
  `unit_tests` firmware image and report PASS/FAIL over serial.
- **UI tests** — anything that renders to the screen or waits on input.
  These belong to Part I's hardware app tester
  (`tools/hardware_app_tester/`), not here.

## Layout (skeleton)

```
tests/on_device/
  README.md                         - this file
  logic/
    test_vin_decoder_checksum.c.skeleton   - example pattern (not compiled)
    CANDIDATES.md                          - which of the 20 apps have
                                              logic worth unit-testing
                                              this way, and why
```

## Candidate logic worth on-device unit testing

See `logic/CANDIDATES.md` for the full breakdown. In summary, of the
current 20 apps, the following contain non-trivial, headlessly-testable
logic (parsers/calculators/validators) rather than being pure UI
shells:

- `vin_decoder` — VIN checksum/format validation logic
- `resistors` (`resistance_calculator`) — color-code <-> value
  conversion
- `quadratic_solver` — root-finding arithmetic
- `programmer_calc` (`programmercalc`) — base-conversion arithmetic
- `network_subnet` — CIDR/subnet-mask arithmetic
- `crypto_dictionary` (`crypto_dict`) — lookup/reference data validation
- `hex_viewer`, `docviewlite`, `image_viewer` — file-format parsing
  boundary conditions (once given real, license-clear fixture files)

Game apps (`chess`, `sudoku`, `2048`, `minesweeper_redux`) may contain
testable state-machine logic (win/loss detection, board validity) but
this has not been assessed against their actual source in this
foundation phase — see `logic/CANDIDATES.md` for the honest per-app
status.

## Why this is a skeleton, not a working test suite

Writing a real on-device unit test requires:

1. Reading each app's actual C source closely enough to identify a pure,
   side-effect-free function boundary suitable for a headless test
   (not yet done for any of the 20 apps in this phase).
2. Registering the test with the firmware's own `unit_tests` app
   (`applications/debug/unit_tests/unit_tests.c` and its test-list
   mechanism), which requires modifying firmware-adjacent build files -
   explicitly out of scope for this foundation phase's stated
   boundaries.
3. A real `fbt` build and a real device to run the resulting image on -
   neither available in this development session.

This directory exists so the *intent and candidate list* are concrete
and reviewable now, ahead of the actual implementation work, which
belongs to a later, explicitly scoped import/test-authoring phase.

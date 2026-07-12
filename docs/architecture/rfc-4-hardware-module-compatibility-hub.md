# RFC 4: Hardware and Module Compatibility Hub

Status: **PROPOSED** (design only — nothing in this RFC has been
implemented or hardware-tested in this phase).

## Problem

Flipper Zero supports a GPIO expansion-module ecosystem (confirmed real
via this phase's official-firmware census: `expansion`/
`expansion_settings`/`expansion_test` exist in official firmware as a
formal protocol/service, not just raw GPIO pins). Users and third-party
module makers need a single, honest place to check: is this module
supported, by which driver version, and has it actually been tested on
real hardware — not merely "should work in theory."

**Hard rule, restated from this phase's mission and non-negotiable in
this RFC: do not claim support for a module until it has been
hardware-tested.** This RFC's entire data model exists to make that
rule easy to follow and hard to accidentally violate.

## Data model

```json
{
  "module_id": "example-module",
  "display_name": "Example GPIO Module",
  "descriptor": {
    "interface": "GPIO | UART | I2C | SPI | 1-Wire",
    "required_pins": ["PA7", "PA6"],
    "voltage": "3.3V",
    "vendor": "<if known>",
    "vendor_url": "<if known>"
  },
  "driver": {
    "capability_version": "0.0.0",
    "declared_capabilities": ["read", "write"],
    "firmware_api_required": "<version>"
  },
  "compatibility_status": "UNSUPPORTED | DRIVER_ONLY_UNTESTED | HARDWARE_TESTED | HARDWARE_TESTED_WITH_LIMITATIONS | DEPRECATED",
  "self_test": {
    "available": false,
    "safe_diagnostic_description": "<what the self-test actually checks, in plain language>"
  },
  "known_limitations": [],
  "update_mechanism": "bundled-with-firmware | separate-fap-update",
  "explicit_unsupported_note": null
}
```

## Compatibility status states

- **`UNSUPPORTED`**: no driver exists. Default state for anything not
  explicitly entered into this hub.
- **`DRIVER_ONLY_UNTESTED`**: driver code exists (possibly imported or
  written), but no real hardware test has been performed. **This state
  must never be presented to a user as "supported."**
- **`HARDWARE_TESTED`**: a real module was connected to a real device
  and the self-test (or an equivalent manual test procedure) passed,
  with evidence recorded (date, tester, firmware version, module
  hardware revision if known).
- **`HARDWARE_TESTED_WITH_LIMITATIONS`**: hardware-tested, but with
  specific, named limitations (e.g. "read works, write untested").
- **`DEPRECATED`**: previously supported, now withdrawn (e.g. a
  firmware API change broke it and it has not been re-verified).

Only `HARDWARE_TESTED` and `HARDWARE_TESTED_WITH_LIMITATIONS` may ever
be described to an end user as "this module works." Every other state
must be presented as exactly what it is — untested or unsupported.

## Self-test capability

Where feasible, a module driver should expose a **safe diagnostic**
self-test: a bounded, read-only or clearly-labeled-write-once
capability check (e.g. "can this device be detected on the declared
interface at all") that a user can run to get a `PASS`/`FAIL` without
needing to understand the module's full protocol. Self-tests must:

- Never perform an irreversible action on the module or the host device
  as part of the check itself.
- Report their own limitations honestly (e.g. "this only confirms
  presence on the bus, not full read/write correctness").

## Update mechanism

Drivers ship either bundled with firmware (for well-established,
stable interfaces) or as a separate, versioned FAP update (preferred
for newer/experimental modules, consistent with this project's
external-FAP-by-default profile design). Either path is tracked via the
same version-pinning discipline as RFC 2's Smart App Packs.

## Explicit unsupported state

Any module a user might reasonably expect to work but that this project
has deliberately not implemented (e.g. because of safety, licensing, or
scope concerns) should have an explicit hub entry with
`compatibility_status: "UNSUPPORTED"` and a filled-in
`explicit_unsupported_note` explaining why — silence is not an
acceptable way to communicate "not supported."

## Relationship to other RFCs

- RFC 1 (Health Center) tracks the *software* (app) side; this hub
  tracks the *hardware* (module) side — an app that talks to a module
  should reference that module's `module_id` in its own Health Center
  entry.
- RFC 5 (Safe Mode and Crash Isolation) should be able to quarantine a
  module driver the same way it quarantines an app, if a module driver
  is implicated in a crash.

## Proof-of-concept plan (not built in this phase)

1. Populate the hub's schema with entries for modules this project's
   census (Part II) identifies as already supported by the official
   firmware's `expansion` protocol (real, confirmed capability — see
   `docs/ecosystem/SOURCE_PROVENANCE.md`), marked accurately based on
   what has actually been verified, not assumed.
2. Do not mark any third-party module `HARDWARE_TESTED` until a real
   module and a real device are both available and a real test is
   performed — this phase has neither.

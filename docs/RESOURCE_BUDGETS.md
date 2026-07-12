# Resource Budgets

## Honest status

**Most numeric thresholds below are proposed starting points, not
measured facts.** The only real, confirmed numbers in this document are
the accepted baseline's own artifact sizes (already verified multiple
times across this project's pre-flash safeguard phases). Everything
else — boot time, menu load time, per-app heap delta, idle heap — has
not been measured on real hardware in this session, because no hardware
exists here. This document defines the budget *categories* and a
starting *threshold*, to be replaced with real measurements the first
time this project's hardware app tester (or a human operator) actually
runs against real hardware.

## Known-real numbers (from the accepted baseline)

| Item | Value | Source |
|---|---|---|
| Firmware recovery artifact (`firmware.dfu`) size | 862,833 bytes | Accepted CI run `29068148596`, verified repeatedly by `tools/pre_flash_safeguard_gate.ps1 -Mode ArtifactHashVerify` across multiple phases |
| Updater artifact (`flipper-z-f7-update-local.tgz`) size | 2,891,859 bytes | Same source |
| Current app count | 20, all external FAPs | Confirmed via `application.fam` inspection, this phase |

## Budget categories (thresholds proposed, not yet measured against)

| Category | Proposed threshold | Measurement method (not yet executed) | Rationale |
|---|---|---|---|
| Internal flash (firmware image) | No more than the accepted baseline's `firmware.dfu` size plus 5% before requiring an explicit resource-budget review | `firmware.dfu` size comparison, pre/post a proposed change | External-FAP-by-default (see `docs/architecture/MODULAR_FIRMWARE_PROFILES.md`) means most app growth should not touch this number at all |
| RAM (heap at idle) | Not yet measured — placeholder threshold: flag any change if idle free heap drops below 50% of total available heap (exact total heap size for this firmware/hardware combination not yet confirmed in this document) | `free` via CLI (real code exists in `serial_cli.py`, unexecuted) | Needs a real baseline measurement before the percentage threshold means anything concrete |
| Heap during FAP loading | Per-app `maximum_heap_delta` field in each app's own `tests/hardware/apps/<app_id>.yaml` (currently a placeholder value of 4096 bytes for all 20 apps — not yet individually tuned per app) | `crash_detection.check_heap_regression()` (real, unit-tested logic; not yet run against real before/after snapshots) | A uniform placeholder is honest about "not yet measured" without pretending false precision per app |
| Updater package size | No more than the accepted baseline's `flipper-z-f7-update-local.tgz` size plus 5% before requiring explicit review | Direct file-size comparison | Same external-FAP-by-default reasoning as internal flash |
| microSD footprint | Not yet measured | Storage listing via `serial_cli.py` (unexecuted) | No baseline exists yet for external FAPs' installed size |
| Boot time | Not yet measured | Requires a real device and a real stopwatch/uptime capture at first responsive desktop | No prior phase of this project has recorded this number |
| Menu load time | Not yet measured | Requires real hardware and RPC screen-frame timing (RPC client not yet implemented — see `docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md`) | Same reason as boot time |
| Test duration (per app, automated) | Proposed default: `timeout_seconds: 10` per app (already set in all 20 YAML profiles) | Wall-clock time of `tools/hardware_app_tester` run | A reasonable, conservative starting default given no real timing data yet exists |

## Hard thresholds required before importing new batches (per this phase's mission)

Per Part III of this phase's mission, hard thresholds must be set
**before** importing any new batch of apps in a future wave. Given the
"not yet measured" status of most categories above, the honest,
enforceable rule for right now is:

> **No import wave may proceed (Gate E) until at least the internal
> flash and updater-package-size thresholds have been checked against a
> real, freshly built artifact for that wave** — this is already
> possible today using the existing, real, hash-and-size-verification
> discipline in `tools/pre_flash_safeguard_gate.ps1`. RAM/heap/boot-time
> thresholds should be measured for real (via the hardware app tester,
> once it can run against real hardware) as part of Gate E's own
> "resource comparison" requirement — a real number from that point
> forward, not a placeholder.

## What this document does NOT claim

This document does not claim any of the "not yet measured" numbers
above are safe, unsafe, tight, or generous — they are explicitly
unmeasured. Treat every placeholder value here as provisional until
replaced by a real measurement, and do not cite this document as
evidence that a specific resource ceiling has been validated.

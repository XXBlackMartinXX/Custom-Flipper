# Current 20-App Qualification

## Honest summary

Every one of the 20 apps below now has a real test profile
(`tests/hardware/apps/<app_id>.yaml`) and a real automation-class
assignment. **No app is marked hardware-`PASS` in this document** — no
real hardware exists in this development session (see
`docs/AUTOMATED_HARDWARE_TEST_RESULTS.md`). This document records
build-tested/unit-tested/schema-validated status honestly, distinct
from any hardware claim.

## Legend

- **Schema-validated**: the app's YAML profile passes
  `hardware_app_tester.profile_schema` validation (real, run via
  `pytest` in this session).
- **Hardware-tested**: an automated or manual run has actually occurred
  on real hardware and produced evidence. **None of the 20 apps have
  this status yet.**
- **Automation class**: per `tests/hardware/apps/<app_id>.yaml`.

## Per-app status

| app_id | Real device appid | Category | Automation class | Schema-validated | Hardware-tested | Rationale |
|---|---|---|---|---|---|---|
| `network_subnet` | `network_subnet` | Tools | `FIXTURE_REQUIRED` | Yes | No | Optional ESP32/WiFi devboard accessory not present/verified in this phase |
| `programmer_calc` | `programmercalc` | Tools | `SAFE_AUTOMATION` | Yes | No | Local numeric calculator UI only |
| `vin_decoder` | `vin_decoder` | Tools | `SAFE_AUTOMATION` | Yes | No | Local text-entry/lookup UI only (see `tests/on_device/logic/CANDIDATES.md` for its one confirmed pure logic function) |
| `flipper95` | `flipper95` | Tools | `MANUAL_VISUAL_REQUIRED` | Yes | No | Novelty UI not yet characterized on real hardware |
| `chess` | `chess` | Games | `SAFE_AUTOMATION` | Yes | No | Local board-game UI only |
| `flipfetch` | `flipfetch` | Tools | `MANUAL_VISUAL_REQUIRED` | Yes | No | System-info screen layout not yet characterized |
| `quadratic_solver` | `quadratic_solver` | Tools | `SAFE_AUTOMATION` | Yes | No | Local numeric calculator UI only |
| `sudoku` | `sudoku` | Games | `SAFE_AUTOMATION` | Yes | No | Local puzzle-game UI only |
| `sd_info` | `sd_info` | Tools | `MANUAL_VISUAL_REQUIRED` | Yes | No | Read-only info screen not yet characterized |
| `docviewlite` | `docviewlite` | Tools | `FIXTURE_REQUIRED` | Yes | No | Needs a real, license-clear test document file on microSD |
| `resistors` | `resistance_calculator` | Tools | `SAFE_AUTOMATION` | Yes | No | Local numeric calculator UI only (2 confirmed pure logic functions found in `resistor_logic.c` — see `tests/on_device/logic/CANDIDATES.md`) |
| `crypto_dictionary` | `crypto_dict` | Tools/Educational | `SAFE_AUTOMATION` | Yes | No | Local reference/lookup UI only |
| `2048` | `2048_improved` | Games | `SAFE_AUTOMATION` | Yes | No | Local puzzle-game UI only |
| `image_viewer` | `image_viewer` | Media | `FIXTURE_REQUIRED` | Yes | No | Needs a real, license-clear test image file (`example_images/` was excluded from import for licensing reasons in an earlier phase) |
| `fap_boilerplate` | `fap_boilerplate` | Tools/Educational | `SAFE_AUTOMATION` | Yes | No | Minimal example/reference app |
| `minesweeper_redux` | `minesweeper_redux` | Games | `SAFE_AUTOMATION` | Yes | No | Local puzzle-game UI only |
| `qrcode` | `qrcode` | Tools | `MANUAL_VISUAL_REQUIRED` | Yes | No | Generation/display UI not yet characterized |
| `hex_viewer` | `hex_viewer` | Tools | `FIXTURE_REQUIRED` | Yes | No | Needs a real test file to view |
| `barcode_app` | `barcode_app` | Tools | `MANUAL_VISUAL_REQUIRED` | Yes | No | Generation/display UI not yet characterized |
| `fcc_id_lookup` | `fcc_id_lookup` | Tools | `FIXTURE_REQUIRED` | Yes | No | Optional FCC database not bundled; meaningful test needs it |

## Totals

| Automation class | Count | Apps |
|---|---|---|
| `SAFE_AUTOMATION` | 10 | `programmer_calc`, `vin_decoder`, `chess`, `quadratic_solver`, `sudoku`, `resistors`, `crypto_dictionary`, `2048`, `fap_boilerplate`, `minesweeper_redux` |
| `FIXTURE_REQUIRED` | 5 | `network_subnet`, `docviewlite`, `image_viewer`, `hex_viewer`, `fcc_id_lookup` |
| `MANUAL_VISUAL_REQUIRED` | 5 | `flipper95`, `flipfetch`, `sd_info`, `qrcode`, `barcode_app` |
| `PROHIBITED_AUTOMATION` | 0 | none |
| `NOT_SUPPORTED` | 0 | none |

**All 20 = 20.** The 10 `SAFE_AUTOMATION` apps exactly match this
phase's mission-specified low-risk launch-only list (Part IX). The
remaining 10 are honestly split between apps needing a real fixture
file/hardware (5) and apps whose screen behavior has not yet been
characterized well enough to commit to a deterministic automation
profile (5) — see `docs/AUTOMATED_HARDWARE_TEST_ARCHITECTURE.md` Part D
for the schema these are validated against.

## Gate B status (from this phase's mission)

Gate B requires: all 20 apps classified (satisfied — see table above);
every `SAFE_AUTOMATION` app tested (**not satisfied** — no hardware
exists in this session; `test_runner.py` currently returns `NOT_RUN` for
every app by design, never a fabricated `PASS`); fixture/manual apps
clearly separated (satisfied — see totals table); no unsupported
blanket PASS (satisfied — zero apps are marked `PASS` anywhere in this
phase's documentation).

**Gate B is therefore only partially satisfied**, for the same
hardware-access reason as Gate A. See this phase's final report.

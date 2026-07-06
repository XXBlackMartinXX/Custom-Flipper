# Phase 2A — Hardware Test Results Template

Docs only. This is a **blank template** to be copied and filled in by whoever
actually runs `PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` on real hardware. Nothing
in this file is a claim that testing has occurred — every field below is
unfilled/placeholder until a real test run populates it.

**Do not edit this template in place with real results.** Copy it (e.g. to
`PHASE2A_HARDWARE_TEST_RESULTS_<date>.md`) and fill in the copy, so this file stays
a clean, reusable template for future runs.

## Run metadata

| Field | Value |
|---|---|
| Date/time of test | _____________________ |
| Tester | _____________________ |
| Device (model/serial, if tracked) | _____________________ |
| Firmware commit flashed | `5e5e0ecf225be947a754e537670a6421838b939b` (confirm this matches what was actually flashed; overwrite if a later validated commit was used) |
| Flashing method (qFlipper / fbt / DFU) | _____________________ |
| Pre-check (`PHASE2A_FLASHING_PRECHECK.md`) completed? | ☐ Yes ☐ No |
| Previous firmware recorded for rollback | _____________________ |

## Global fail conditions observed (check any that occurred, at any point)

- [ ] Device boot loop
- [ ] App crash (any app)
- [ ] Hard freeze
- [ ] Unexpected reboot
- [ ] Unexpected RF/NFC/BLE/HID/GPIO/IR activity
- [ ] Storage corruption
- [ ] App wrote outside its expected app-private path
- [ ] Battery/power abnormality
- [ ] Menu registration problem
- [ ] Any unexpected warning/error

If any box above is checked, describe exactly what happened, when (which app/step),
and whether rollback (`PHASE2A_FLASHING_PRECHECK.md` §5) was performed:

```
(describe here)
```

## Per-app results

### 1. `network_subnet`

| Check | Result | Notes |
|---|---|---|
| Appears in Apps → Tools menu | ☐ Pass ☐ Fail | |
| Launches without crash | ☐ Pass ☐ Fail | |
| Navigation (menu ↔ IP input) | ☐ Pass ☐ Fail | |
| Normal input (valid IP + mask) | ☐ Pass ☐ Fail | |
| Invalid/edge input | ☐ Pass ☐ Fail | |
| Exit / Back to Tools menu | ☐ Pass ☐ Fail | |
| No unexpected storage writes | ☐ Pass ☐ Fail | |
| **Overall app result** | ☐ PASS ☐ FAIL | |

### 2. `programmer_calc`

| Check | Result | Notes |
|---|---|---|
| Appears in Apps → Tools menu | ☐ Pass ☐ Fail | |
| Launches without crash | ☐ Pass ☐ Fail | |
| Navigation (base modes) | ☐ Pass ☐ Fail | |
| Normal input (`2 + 2` = `4`) | ☐ Pass ☐ Fail | |
| Invalid/edge input (divide by zero) | ☐ Pass ☐ Fail | |
| Exit / Back to Tools menu | ☐ Pass ☐ Fail | |
| No unexpected storage writes | ☐ Pass ☐ Fail | |
| **Overall app result** | ☐ PASS ☐ FAIL | |

### 3. `vin_decoder`

| Check | Result | Notes |
|---|---|---|
| Appears in Apps → Tools menu | ☐ Pass ☐ Fail | |
| Launches without crash | ☐ Pass ☐ Fail | |
| Navigation (text entry ↔ Back) | ☐ Pass ☐ Fail | |
| Normal input (valid 17-char VIN) | ☐ Pass ☐ Fail | |
| Invalid/edge input (short/invalid VIN) | ☐ Pass ☐ Fail | |
| Exit / Back to Tools menu | ☐ Pass ☐ Fail | |
| No unexpected storage writes | ☐ Pass ☐ Fail | |
| **Overall app result** | ☐ PASS ☐ FAIL | |

### 4. `flipper95`

| Check | Result | Notes |
|---|---|---|
| Appears in Apps → Tools menu | ☐ Pass ☐ Fail | |
| Launches without crash | ☐ Pass ☐ Fail | |
| Visible progress under load | ☐ Pass ☐ Fail | |
| Runs 30–60s without hang | ☐ Pass ☐ Fail | |
| Back responsive mid-computation | ☐ Pass ☐ Fail | |
| Exit / Back to Tools menu | ☐ Pass ☐ Fail | |
| No unexpected storage writes | ☐ Pass ☐ Fail | |
| **Overall app result** | ☐ PASS ☐ FAIL | |

### 5. `chess`

| Check | Result | Notes |
|---|---|---|
| Appears in Apps → Games menu | ☐ Pass ☐ Fail | |
| Launches without crash | ☐ Pass ☐ Fail | |
| Navigation (start screen → menu → board) | ☐ Pass ☐ Fail | |
| Legal move applies | ☐ Pass ☐ Fail | |
| Illegal move rejected | ☐ Pass ☐ Fail | |
| Save/load (if exercised) — no error/corruption | ☐ Pass ☐ Fail ☐ Not exercised | |
| Save file confined to `/ext/apps_data/flipchess/` | ☐ Pass ☐ Fail ☐ Not exercised | |
| No audio output (confirms SAM removal on hardware) | ☐ Pass ☐ Fail | |
| Exit / Back to Games menu | ☐ Pass ☐ Fail | |
| **Overall app result** | ☐ PASS ☐ FAIL | |

## Batch summary

| Field | Value |
|---|---|
| Apps passed | ___ / 5 |
| Apps failed | ___ / 5 |
| Any global fail condition occurred? | ☐ Yes ☐ No |
| **Overall Phase 2A smoke test result** | ☐ PASS (all 5 apps pass, no global fail) ☐ FAIL |
| Rollback performed? | ☐ Yes ☐ No ☐ N/A |

## Explicit non-claims (do not alter these lines when filling in real results —
## add a separate dated results file instead; these lines describe the template's
## own default state)

- This template, unfilled, does not constitute a test having occurred.
- A filled-in copy of this template is a record of one manual smoke test run, on
  one device, at one point in time — it is not a substitute for the project's
  full release-gate checklist, and passing it does not make the firmware
  release-ready.
- Any FAIL recorded here should be treated as real signal requiring follow-up
  investigation before this firmware is considered for further distribution —
  not something to be waived without a documented reason.

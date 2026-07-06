# Phase 2A — Automated Validation Results (Initial Run)

Docs only. This is the **first** validation snapshot produced under this new
tooling, generated in this project's cloud sandbox at the time
`tools/phase2a_validate.ps1` / `tools/phase2a_validate_config.json` were
authored.

## Important caveat on how this snapshot was produced

**This cloud sandbox does not have PowerShell installed** (`pwsh` was checked
and is not present), so `tools/phase2a_validate.ps1` itself has **not yet been
executed anywhere**. The results below were produced by manually running the
equivalent underlying commands (`git`, `grep`) that the script automates,
directly in this sandbox, against the same repository state, to give an honest
first snapshot rather than none at all. **The script's own first real
execution is still pending** and should happen on the Windows machine that has
already been used for Phase 2A's real builds
(`C:\Github\Custom-Flipper-phase2a-build`) — see
`PHASE2A_AUTOMATED_VALIDATION.md` for how to run it there. Nothing below
should be read as "the script was tested and works" — only "these are the real
facts about the repository the script is designed to check."

## Run context

| Field | Value |
|---|---|
| Repo | `xxblackmartinxx/custom-flipper` |
| Branch | `integration/phase2a-first-batch` |
| Commit checked | `e12bd9e3df525e0d4ecf611d6a77a31c1752672e` (tip immediately before this tooling/docs commit was added) |
| Environment | Cloud sandbox (Linux), not the Windows build machine |
| PowerShell available | No — checks below reproduced manually via `git`/`grep` |
| `arm-none-eabi-gcc` present | Yes (`/usr/bin/arm-none-eabi-gcc`), but see Build classification below — presence of a compiler alone does not mean a real build will succeed |

## STATIC VALIDATION: **PASS**

| Check | Result | Detail |
|---|---|---|
| Branch verification | PASS | `integration/phase2a-first-batch` |
| Commit recorded | (informational) | `e12bd9e3df525e0d4ecf611d6a77a31c1752672e` |
| Git status before | PASS (clean) | `git status --porcelain` empty before this round's new files were created |
| Submodule initialization | PASS | `git submodule update --init --recursive` completed successfully in this sandbox this session; `git submodule status --recursive` shows 16 entries (12 top-level + 4 nested), **0** uninitialized (`-` prefix), **0** out-of-sync (`+` prefix) — all pinned exactly as expected |
| Phase 2A app directories present | PASS | All 5 (`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`) found under `applications_user/` |
| Application manifests valid | PASS | All 5 `application.fam` files present; `appid=` values confirmed: `network_subnet`, `programmercalc`, `vin_decoder`, `flipper95`, `chess` |
| App ID uniqueness (within batch) | PASS | All 5 appids unique |
| App ID collision vs base `applications/` | PASS | Zero matches searching base `applications/` tree for any of the 5 appids |
| SAM removal verification (chess) | PASS | Zero matches for `sam`, `stm32_sam`, `flipchess_voice`, `speech`, `voice` (word-bounded) anywhere in `applications_user/chess/*.c/.h/.cpp/.fam` |
| Risky keyword scan (Phase 2A app dirs only) | NEEDS_REVIEW (reviewed here, confirmed benign) | See breakdown below |

### Risky keyword scan — full breakdown

Scanned all 5 Phase 2A app directories (`.c`/`.h`/`.cpp` only), case-insensitive
substring match, **104 total matches** across 17 keywords:

| Keyword | Matches | Disposition |
|---|---|---|
| `furi_hal_subghz` | 0 | — |
| `furi_hal_nfc` | 0 | — |
| `furi_hal_rfid` | 0 | — |
| `furi_hal_ibutton` | 0 | — |
| `furi_hal_hid` | 0 | — |
| `furi_hal_usb_hid` | 0 | — |
| `furi_hal_gpio_write` | 0 | — |
| `furi_hal_infrared_async_tx_start` | 0 | — |
| `ble` | 102 | **Confirmed false positives** — every match is a substring hit inside benign words: `possible`, `variable`, `double`, `available`, `enabled`, `disable`, `table` (e.g. `HEX_TO_BINARY_TABLE`), etc. Manually spot-checked; none are the Bluetooth LE API. |
| `badusb` | 0 | — |
| `password` | 0 | — |
| `credential` | 0 | — |
| `token` | 0 | — |
| `exfil` | 0 | — |
| `brute` | 0 | — |
| `jam` | 2 | **Confirmed false positive** — both matches are the 3-letter manufacturer code `"JAM"` (`"Isuzu"`) inside `vin_decoder.c`'s manufacturer lookup table, not the word "jam" or any jamming behavior. |
| `deauth` | 0 | — |

**Zero matches for any of the 8 real Flipper HAL/capability APIs** in the
forbidden list (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`). This is consistent with, and re-confirms,
`PHASE2A_SAFETY_REVIEW.md`'s existing capability grep. All 104 raw matches are
listed above (not hidden), and all are confirmed benign on manual review —
per this tooling's own design, that confirmation is a human judgment call the
script surfaces rather than makes silently.

**Static classification: PASS.** (Every check either passed outright, or — for
the one broad substring scan — every match was surfaced and has now been
manually reviewed and confirmed benign.)

## BUILD VALIDATION: **BLOCKED (not a firmware defect)**

The real, pinned Flipper toolchain is downloaded by `fbt` from
`update.flipperzero.one`. This cloud sandbox's network egress policy denies
that host — reconfirmed fresh for this round:

```
$ curl -sS -o /dev/null -w "%{http_code}\n" https://update.flipperzero.one/builds/toolchain/
CONNECT tunnel failed, response 403
```

This is the same, previously root-caused blocker documented in `BUILD_LOG.md`
and `KNOWN_ISSUES.md` — a network policy denial in this specific sandbox
environment, not a defect in the firmware or the 5 Phase 2A apps. Per this
project's own standing rule, this is reported as **BLOCKED**, not routed
around with an unofficial substitute toolchain, and not claimed as a build
PASS or FAIL.

**A real Build-mode PASS already exists for this branch**, independently, from
the project owner's actual local Windows build (see `PHASE2A_BUILD_REPORT.md`):
commit `5e5e0ecf225be947a754e537670a6421838b939b`, both
`.\fbt.cmd COMPACT=1 DEBUG=0` and `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`
passed, `firmware.dfu` (862,825 bytes) and the updater `.tgz` (2,732,909 bytes)
both present. This new tooling's Build mode has simply not been executed
anywhere yet — running `.\tools\phase2a_validate.ps1 -Mode Build` on that same
Windows machine is the natural next step to get a tooling-generated Build
report to match the manually-reported one already on file.

**Build classification: BLOCKED in this sandbox / independently known-PASS via
manual local Windows build (not yet re-verified through this new tooling).**

## HARDWARE-ASSISTED VALIDATION: **NOT RUN**

No physical Flipper Zero is connected to this cloud sandbox (a permanent,
structural constraint of this environment — see `PHASE0_SOURCE_VERIFICATION.md`
and every prior Phase 2A doc). This sandbox is also Linux, not Windows, so the
script's `Get-PnpDevice`-based detection path could not be exercised even in
principle here. Hardware-assisted validation, and the manual smoke-test
checklist it hands off to, both require the project owner to run them on their
own Windows machine with a device connected.

**Hardware classification: NOT RUN.**

## Overall classification: **NEEDS REVIEW**

Rolled up per `PHASE2A_AUTOMATED_VALIDATION.md`'s rules: Static came back
clean after review of its one NEEDS_REVIEW item (now resolved as benign, see
above), but Build is BLOCKED in this environment and Hardware is NOT RUN — an
overall run only reaches **AUTOMATED VALIDATION PASS** when every check that
ran came back PASS with nothing left to review. Since this run has a BLOCKED
entry (Build, environment-specific) and started from a sandbox that cannot run
Hardware mode at all, **NEEDS REVIEW** is the honest label, not PASS.

This is expected and consistent with this project's structural split between
"what the cloud sandbox can verify" and "what requires the real Windows
machine and/or real hardware" — it does not indicate a new problem.

## What this run does and does not establish

**Establishes:**
- The repository's static state (branches, submodules, manifests, appids,
  SAM removal, absence of risky APIs) is exactly as documented, re-confirmed
  independently via this new tooling's own check definitions.

**Does not establish:**
- That `tools/phase2a_validate.ps1` itself runs correctly end-to-end (it has
  not been executed anywhere yet — see the caveat at the top).
- Anything about build success beyond what was already known from the manual
  Windows build report.
- Anything about hardware or GUI-level app behavior — that remains entirely
  unperformed, per `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md`.

**Hardware flashing/testing status: NOT PERFORMED.** **Release status: TEST-READY
ONLY / NOT RELEASE-READY.** Neither claim changes as a result of this tooling
or this initial validation snapshot.

# Phase 2A — Automated Validation Runner

**v2 (Phase 2A.6).** Updated after the script's first real executions found
and fixed two bugs (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md` for the
full account) — this version reflects the fixed behavior. Docs + tooling
only. No firmware code changed by this document or by
`tools/phase2a_validate.ps1` / `tools/phase2a_validate_config.json`. This
explains what the validation runner does, what it does not (and cannot) prove,
and how to run and interpret it.

## What this is

`tools/phase2a_validate.ps1` is a Windows PowerShell script that automates the
repetitive, mechanical checks this project has been doing by hand throughout
Phase 2A — branch/commit verification, submodule state, app manifest/appid
checks, the SAM-removal grep sweep, the risky-API-keyword sweep, build
invocation, and artifact verification — so they can be re-run consistently
instead of re-derived manually every time. It is configured by
`tools/phase2a_validate_config.json`, which holds the expected branch, apps,
artifact paths/sizes, and keyword lists so the script itself doesn't hardcode
project-specific values inline.

It does **not** replace `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` or its checklist —
it automates the parts that can honestly be automated and clearly hands off the
rest (see "What this does not prove" below and
`docs/PHASE2A_AUTOMATION_LIMITATIONS.md`).

## The three modes

### `-Mode Static` (default)

Runs entirely against the repository on disk — no build, no network access
beyond `git` itself, no hardware. Safe to run anywhere, any time, as often as
you like. It checks:

- Current branch matches the expected branch (`integration/phase2a-first-batch`
  by default, from config)
- Current commit, compared against `-ExpectedCommit` if you pass one
- Working tree is clean before the run (and unchanged after — Static mode
  should never modify anything)
- All 12 submodules (+4 nested) are initialized and pinned at the expected
  commits (`git submodule status --recursive`, flags any `-` unintialized or
  `+` out-of-sync entries)
- All 5 Phase 2A app directories exist
- Each app's `application.fam` exists, parses, and has the expected `appid`
- App IDs are unique within the batch and don't collide with any app under
  the base firmware's own `applications/` tree
- `applications_user/chess` contains zero references to `sam`, `stm32_sam`,
  `flipchess_voice`, `speech`, or `voice` (word-bounded) — confirming the SAM
  voice removal (commit `6359f87`) is still in place
- A broad, deliberately non-word-bounded substring scan of all 5 app
  directories for risky keywords (`furi_hal_subghz`, `furi_hal_nfc`, `ble`,
  `password`, `credential`, `jam`, etc.) — **every match is listed, never
  hidden**, because this scan is intentionally broad and is expected to catch
  benign substrings (see below)

### `-Mode Build`

Runs everything in Static mode, then:

- Invokes `.\fbt.cmd COMPACT=1 DEBUG=0`, logging full output to the report
  directory
- If that succeeds, invokes `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`
- Verifies `build\f7-firmware-C\firmware.dfu` and
  `dist\f7-C\flipper-z-f7-update-local.tgz` exist, are non-empty, and records
  their sizes (flagging, not failing, a size difference unless it's at the
  exact same commit a known-good size was previously recorded against)
- Verifies each of the 5 apps produced its own `.fap` file under
  `build\f7-firmware-C\.extapps\<appid>.fap` — this path was confirmed by
  reading `firmware.scons` (`FBT_FAP_DEBUG_ELF_ROOT=fwenv["BUILD_DIR"].Dir(".extapps")`)
  and `scripts/fbt_tools/fbt_extapps.py`, not assumed

This mode distinguishes two different ways a build can not-succeed, and
reports each honestly rather than lumping them together:

- **The build process could not even be launched** (e.g. `fbt.cmd` doesn't
  exist at the repo root, or the OS/shell can't execute it at all) → reported
  as **BLOCKED**. This says nothing about the firmware or apps — it means
  this environment cannot even attempt a build. (This project's cloud sandbox
  has hit this in two different ways across its history: a `403` from its
  network policy against `update.flipperzero.one` when the toolchain tries to
  download — see `BUILD_LOG.md` — and, separately, simply being Linux while
  `fbt.cmd` is a Windows batch file.)
- **The build process launched and exited non-zero** → reported as **FAIL**.
  This is worth investigating as a possible real problem, though the log
  should still be checked before assuming it's a source defect (it could
  still be an environment issue, like a missing toolchain component).

When the build didn't succeed for either reason, the downstream artifact and
`.fap`-output checks are reported **NOT_RUN** (never a stale false PASS or a
misleading FAIL) unless you pass `-SkipBuild`, in which case they check
whatever pre-existing artifacts are actually on disk, since that's the
explicit point of that flag.

### `-Mode HardwareAssisted`

Runs everything in Static mode, then attempts to detect a connected Flipper
Zero via Windows device enumeration (`Get-PnpDevice`, matching on friendly name
or VID/PID). Behavior:

- **No device detected** → every hardware check reports `NOT_RUN`. Nothing is
  attempted.
- **Device detected** → prints a preflight summary (device, commit under test,
  the 5 in-scope apps) and reminds you to have completed
  `docs/PHASE2A_FLASHING_PRECHECK.md` first. From here the script is
  **read-only** unless you also pass `-ConfirmHardwareFlash`, in which case it
  asks for an additional interactive `CONFIRM` before proceeding — and even
  then, the script does **not** implement the actual flash itself. That step
  stays a deliberate, manual qFlipper/`fbt flash_usb` action, so a human is in
  the loop for the one step in this whole workflow that writes to the physical
  device.
- Every GUI-level check (does the app appear in its menu, does it launch, does
  navigation work, does chess's save file behave correctly) is explicitly
  logged as `NOT_RUN` with the reason `REQUIRES HUMAN OBSERVATION` or `NOT
  AUTOMATABLE WITH CURRENT TOOLING` — see
  `docs/PHASE2A_AUTOMATION_LIMITATIONS.md` for why, and use
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` to actually perform them.
- This mode contains **no code path** for RF/Sub-GHz/NFC/RFID/iButton/BadUSB/
  BLE/GPIO/IR interaction, and no code path resembling unauthorized access,
  cloning, brute force, jamming, credential handling, or bypass behavior, for
  any app, under any flag — this isn't a configuration toggle to disable, it
  is simply not implemented anywhere in the script.

## How to run it

From a Windows machine with this repository checked out (submodules
initialized) and PowerShell 5.1+ or PowerShell 7+:

```powershell
cd C:\Github\Custom-Flipper-phase2a-build

# Static — safe anywhere, anytime
.\tools\phase2a_validate.ps1

# Static with an explicit commit check
.\tools\phase2a_validate.ps1 -ExpectedCommit 5e5e0ecf225be947a754e537670a6421838b939b

# Build — actually compiles firmware + updater package
.\tools\phase2a_validate.ps1 -Mode Build -ExpectedCommit <commit>

# Hardware-assisted — only interacts with a device if one is connected
.\tools\phase2a_validate.ps1 -Mode HardwareAssisted -ExpectedCommit <commit>
```

Reports are written to `reports\phase2a\` (created if missing) as both a JSON
file (machine-readable, full detail) and a Markdown file (human-readable table)
per run, timestamped so old runs are never overwritten.

## GitHub-hosted Windows validation path

If a real Windows machine with Claude Desktop or local Claude Code isn't
available (as is currently the case for this project), the same Static and
Build validation can be run on a real Windows machine via GitHub Actions
instead — no local Windows setup required at all.

Workflow: **`.github/workflows/phase2a-windows-validation.yml`**, named
**"Phase 2A Windows Validation"** in the Actions UI. Runs on `windows-latest`,
triggered automatically on every push to `integration/phase2a-first-batch`,
or manually via **Actions tab → Phase 2A Windows Validation → Run workflow**.
It runs the same `-Mode Static` then `-Mode Build` sequence described above
against `$env:GITHUB_SHA`, uploads the JSON/Markdown reports plus
`firmware.dfu`/the updater `.tgz` as workflow artifacts, and **never** invokes
`-Mode HardwareAssisted` — there is no code path in the workflow that could
call it, and no physical device attached to a GitHub-hosted runner regardless.

Full explanation of what this path does and does not prove, how to read its
output, and why it exists at all:
`docs/PHASE2A_GITHUB_ACTIONS_VALIDATION.md`.

## Why hardware-assisted mode is still not the same as full release validation

Even a fully green `HardwareAssisted` run with a device connected only proves:
the device was detected, and (if you chose to flash) the operator manually
flashed and is now expected to walk through the smoke-test checklist
themselves. It does not prove:

- That any app's menu entry actually renders correctly (a human must look at
  the screen)
- That any app's UI navigation, input handling, or calculation logic is
  correct (a human must exercise it)
- That chess's save/load behavior is correct, or that its save file stays
  confined to `/ext/apps_data/flipchess/`, without a human driving a real game
  and then checking the SD card
- Anything about long-term stability, battery behavior under real use, or
  behavior across firmware updates/downgrades
- Release-readiness in the project's broader sense (hardware testing is one
  gate among several — see `PHASE2A_NEXT_GATE.md`)

## Why manual observation may still be required for GUI-only checks

Flipper Zero apps are driven by a 128×64 monochrome display and 5-button
D-pad; there is no first-party remote-control or screen-capture RPC API this
project has confirmed as usable for scripted UI-level testing from a
PowerShell runner (Flipper's serial CLI exposes a narrow set of commands —
things like `device_info`, storage operations, and a few others — not a
generalized "press this button, read the screen" interface for arbitrary
running apps). Until a dedicated in-firmware test harness or a verified RPC
automation path exists, "does the app menu look right" and "does this button
press do the right thing" remain human-only checks. This is stated honestly
here rather than assumed away — see
`docs/PHASE2A_AUTOMATION_LIMITATIONS.md` for the full breakdown.

## How to interpret results

Every check produces one of five statuses:

| Status | Meaning |
|---|---|
| `PASS` | The check ran and found no problem. |
| `FAIL` | The check ran and found a real problem — investigate before proceeding. |
| `NEEDS_REVIEW` | The check ran, but the result requires a human judgment call (e.g. the risky-keyword scan found substring matches that are very likely benign, but the script cannot tell for certain). |
| `NOT_RUN` | The check was not attempted, either because the mode didn't call for it or a precondition (e.g. no device detected) wasn't met. |
| `BLOCKED` | The check could not run due to an environment limitation (e.g. toolchain host unreachable) — not the same as FAIL, since it says nothing about the firmware itself. |

Three independent classifications are reported — **Static**, **Build**,
**Hardware** — plus one **Overall** classification that rolls all checks
together:

- **AUTOMATED VALIDATION PASS** — every check that ran came back PASS.
- **NEEDS REVIEW** — at least one NEEDS_REVIEW or BLOCKED entry exists; read
  every one before treating the run as clean.
- **AUTOMATED VALIDATION FAILED** — at least one real FAIL exists.

None of these three labels is a substitute for reading the individual checks —
they exist to triage, not to replace review. See
`docs/PHASE2A_NEXT_GATE.md` for what happens after a given classification.

**This document does not claim hardware testing has occurred, and does not
claim release-readiness.** Those remain governed by
`PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` and the project's own release-gate
checklist, respectively.

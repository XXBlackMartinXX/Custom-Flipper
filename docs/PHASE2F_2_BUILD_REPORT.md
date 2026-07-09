# Phase 2F.2 — Build Report

Docs only. Records the real local and CI build results for the Phase 2F
tiny batch (`qrcode`, `hex_viewer`, `barcode_gen`) alongside the 16
already-accepted Phase 2A/2B/2C/2D/2E apps — 19 apps total. `fcc_id_lookup`
is not part of this batch or this report.

**This report's bottom line is honest, not rounded up.** The section
below ("CI attempt 1" / "CI attempt 2") records the original 2 failed
real CI attempts exactly as they happened, unmodified. **Phase 2F.2A
(see `docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` for the full investigation) has since
root-caused and fixed both real defects behind that blockage — one
CI/tooling defect and one real app-source defect in `barcode_gen` — and
confirmed the fix with 2 independent full-pass real CI runs.** The
"Phase 2F.2A resolution" section at the end of this report records that
outcome. Static validation and the firmware build itself passed cleanly
and consistently across all real CI attempts, from the very first
attempt onward; the separate `updater_package` build sub-step and the
per-app `.fap` output directory are what changed from FAIL to PASS as a
result of Phase 2F.2A.

## Local build status: BUILD BLOCKED / ENVIRONMENT

Attempted `./fbt COMPACT=1 DEBUG=0` directly in this session's Linux
sandbox — failed at the toolchain-download step, the same root cause
every prior phase's cloud-sandbox build attempt has hit:

```
Checking for tar..yes
Checking if downloaded toolchain tgz exists..no
Checking curl..yes
Downloading toolchain:
curl: (56) CONNECT tunnel failed, response 403
Failed to download https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz
```

Environment/egress-policy limitation, not a build failure or firmware
defect. Not faked as a pass.

## Local static validation: PASS (real, run via `pwsh` in this session)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    NOT_RUN
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

All 19 app directories present, all 19 `application.fam` files parse and
appid-match, all 19 appids unique with no collision against base
`applications/`, submodules initialized (16/16), 464 risky-keyword
substring matches found, all 464 individually reviewed, zero unreviewed,
zero high-confidence-unsafe.

## CI attempt 1: run `28979764650` (attempt 1), commit `e5d2905`

- **Workflow**: `.github/workflows/phase2f-windows-validation.yml`
- **Trigger**: `workflow_dispatch`
- **Duration**: `22:20:27Z`–`22:30:39Z` (~10 minutes)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    FAIL
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION FAILED
```

Exact evidence from the real, unedited job log:

- **Static validation**: PASS, `22:25:28Z`–`22:25:35Z`. 464 substring
  matches, all reviewed, zero unreviewed, zero high-confidence-unsafe.
- **Firmware build** (`.\fbt.cmd COMPACT=1 DEBUG=0`): **PASS**, exit code
  0, `22:25:41Z`–`22:28:42Z` (~3 minutes).
- **Pre-updater_package diagnostics** (Phase 2D.2A remediation, inherited
  unchanged): `firmware.dfu` confirmed present
  (`build\f7-firmware-C\firmware.dfu exists: True`); **`.extapps` confirmed
  absent** (`build\f7-firmware-C\.extapps exists: False`) at this
  diagnostic checkpoint, immediately after the firmware build reported
  success; 145.14GB free disk; Windows Defender real-time protection
  disabled.
- **Updater package build** (`cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0
  updater_package"`): **BLOCKED** — "fbt.cmd could not be launched as a
  process on this machine/OS."
- **Artifact verification**:
  - `build\f7-firmware-C\firmware.dfu`: **PASS**, 862,825 bytes (matches
    the Phase 2A-baseline reference size recorded in the config).
  - `dist\f7-C\flipper-z-f7-update-local.tgz`: **FAIL** — file does not
    exist (expected, since `updater_package` never launched).
  - **Per-app FAP output verification: FAIL** — "Missing .fap for:
    `network_subnet, programmercalc, vin_decoder, flipper95, chess,
    flipfetch, quadratic_solver, sudoku, sd_info, docviewlite,
    resistance_calculator, crypto_dict, image_viewer, fap_boilerplate,
    minesweeper_redux, qrcode, hex_viewer, barcode_app`" — **all 19
    expected apps**, not merely the 3 new ones, meaning `.extapps`
    contained none of the specifically-named appid `.fap` files by the
    time this check ran (after the updater_package attempt).
- **Anomaly, recorded honestly, not explained away**: despite the FAP
  verification check reporting zero of the 19 named files present, the
  "Upload per-app .fap artifacts" step (glob
  `build/f7-firmware-C/.extapps/*.fap`) still produced a non-empty
  artifact — `phase2f-fap-artifacts`, 115,177 bytes, sha256
  `b299fe1d8db299975b777f0f157a03ab13992339a8e2a424c41ac45ad8eac2d7`.
  **The actual contents of this artifact were not independently verified
  in this session** — downloading it hit the same, already-documented
  Azure Blob Storage egress block (`CONNECT tunnel failed, response 403`)
  every prior phase's artifact-download attempt has hit. This
  discrepancy (glob matched *something* non-trivial in size, but none of
  it matched any of the 19 specifically-named appid `.fap` filenames) is
  an open question, not resolved in this session.
- **Hardware-assisted validation**: `NOT_RUN` — Build mode never invokes
  `-Mode HardwareAssisted`; no device, no flash, at any point in this CI
  run.

## CI attempt 2: rerun of run `28979764650` (attempt 2, job `85998128531`), same commit `e5d2905`

Dispatched via `rerun_failed_jobs` to distinguish a reproducible defect
from a one-off intermittent runner flake, per the exact diagnostic
methodology Phase 2D.2/2D.2A established for this project (re-running on
a fresh GitHub-hosted runner instance).

- **Duration**: `22:36Z`–`22:43:29Z` (~7 minutes, on a distinct runner
  instance from attempt 1 — new `fbt.cmd` file timestamp
  `07/08/2026 22:37:14` vs. attempt 1's `07/08/2026 22:24:20`, new volume
  serial number `98F3-A5DA` vs. attempt 1's `942B-CD8D`).

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    FAIL
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION FAILED
```

**Every material finding from attempt 1 reproduced identically on this
second, independent runner instance**:

- Static validation: PASS, 464 matches, all reviewed.
- Firmware build: **PASS**, exit code 0.
- Pre-updater_package diagnostic: `firmware.dfu exists: True`;
  **`.extapps exists: False`** — identical to attempt 1.
- Updater package build: **BLOCKED** — "fbt.cmd could not be launched as
  a process on this machine/OS" — **byte-identical error text** to
  attempt 1.
- `firmware.dfu`: **PASS**, **862,825 bytes** — identical size to
  attempt 1.
- `flipper-z-f7-update-local.tgz`: **FAIL** — does not exist.
- Per-app FAP output verification: **FAIL** — identical list of all 19
  missing apps.
- `phase2f-fap-artifacts` artifact: 115,177 bytes (**identical size** to
  attempt 1) but a **different** sha256
  (`43bc6a75bd53862cd50929315faa3c5880a7b1ab46c11ec99bc7ac1ac6f2a63f`)
  — same size, different content. Not independently inspected (same
  Azure Blob Storage download block).

## Reproducibility assessment

**This is a reproducible finding across 2 consecutive, independent
GitHub-hosted Windows runner instances for the same commit — not (yet)
established as a ~50%-intermittent flake the way Phase 2D.2A's own
`updater_package` launch issue was (that finding was based on 4 total
attempts: 2 pass, 2 fail).** With only 2 attempts made in this phase, both
failing identically, this could still turn out to be intermittent with
further attempts, or it could be a new, distinct, more consistently
reproducible regression — this session does not have enough data to
distinguish between those, and does not guess. See
`docs/PHASE2F_2_GO_NO_GO.md` for the resulting classification and the
proposed (not yet implemented) Phase 2F.2A remediation plan.

## Artifact paths and sizes (workflow artifacts, not committed to the repository)

| Artifact | Attempt 1 | Attempt 2 |
|---|---|---|
| `phase2f-firmware-artifacts` (`firmware.dfu` only — no updater `.tgz` was produced) | 594,853 bytes | 594,853 bytes |
| `phase2f-validation-reports` (JSON + Markdown reports) | 41,765 bytes | 41,730 bytes |
| `phase2f-fap-artifacts` (contents not independently verified) | 115,177 bytes, sha256 `b299fe1d...` | 115,177 bytes, sha256 `43bc6a75...` |

## Failures/blocks

- **Real, reproducible (2/2)**: `updater_package` build sub-step failed
  to launch as a process on both real CI attempts, with
  `build\f7-firmware-C\.extapps` confirmed absent immediately after the
  (successful) firmware build on both attempts.
- **Real, unresolved anomaly**: the `.fap`-artifact upload step produced
  a non-trivial, non-empty (though not independently inspected) artifact
  on both attempts despite the validator's own per-appid FAP check
  finding zero of the 19 expected files present.
- **Not a defect in any of the 3 newly imported apps' own source**: no
  compile error, no source-level failure message, and no app-specific
  error text appears anywhere in either attempt's log. The firmware
  itself built successfully both times, at the exact expected size, with
  no app-specific error attributed to `qrcode`, `hex_viewer`, or
  `barcode_gen`.

## Conclusion of the original 2 attempts (historical — see resolution below)

**Static validation PASS. Firmware build PASS (2/2 real CI attempts,
consistent size). `updater_package` build and full per-app `.fap` output
verification: FAIL/BLOCKED, reproducible (2/2).** Local build remains
`BUILD BLOCKED / ENVIRONMENT` for the same reason as every prior phase.
This was the state of Phase 2F.2 before Phase 2F.2A's investigation and
remediation, described below.

## Phase 2F.2A resolution

Full root-cause investigation and remediation: see
`docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` (narrative analysis) and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` (exact commit/run sequence). Summary:

**Two distinct real defects were found and fixed, both with direct CI
evidence:**

1. **CI/tooling defect** (`tools/phase2a_validate.ps1`, commits `0260ca6`
   then `8e5f78f`): Windows PowerShell was escalating a native command's
   routine stderr output (an ordinary GCC compiler diagnostic line) into
   a terminating exception under `$ErrorActionPreference = 'Stop'`,
   aborting `updater_package` before it could ever complete — this is
   why the generic "fbt.cmd could not be launched as a process on this
   machine/OS" text had appeared on every attempt across this failure
   class's history; the real exception (first captured in run
   `29003824450`) was `System.Management.Automation.RemoteException`
   wrapping native stderr text, never a genuine process-launch-failure
   type. Fixed by scoping `$ErrorActionPreference = 'Continue'` around
   just the `updater_package` `cmd /c` call, relying on `$LASTEXITCODE`
   (already captured) as the authoritative signal.
2. **Real app-source defect** (`applications_user/barcode_gen/views/create_view.c`,
   commit `b6445ed`, user-approved after evidence was presented):
   `create_view.c` called `text_input_show_illegal_symbols()`, a function
   belonging only to this app's own bundled, never-wired-in custom
   keyboard fork (`keyboard/text_input.c`/`.h`) — the app's real
   `text_input` widget is a **system** `TextInput` instance
   (`text_input_alloc()`, `barcode_app.c:349`), whose module has no such
   function and a different internal model layout. Fixed by removing the
   5 dead call sites (2 were accidental upstream duplicate calls).

**Real CI evidence, both fixes confirmed in place, 2 independent full
passes:**

- **Run `29015213503`** (commit `78914b3`):
  ```
  === Classification ===
  Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
  Build:    PASS
  Hardware: NOT_RUN
  Overall:  AUTOMATED VALIDATION PASS
  ```
  `[PASS] Firmware build` exit 0. `[PASS] Updater package build` exit 0.
  `[PASS] Artifact present: build\f7-firmware-C\firmware.dfu` — 862,825
  bytes. `[PASS] Artifact present: dist\f7-C\flipper-z-f7-update-local.tgz`
  — 2,877,979 bytes. `[PASS] Per-app FAP output verification` — "All 19
  expected .fap files found in `...\.extapps`" (includes `qrcode.fap`,
  `hex_viewer.fap`, `barcode_app.fap` by name).
- **Run `29015788839`** (same commit, second independent dispatch,
  distinct runner instance): identical classification. `firmware.dfu`
  862,825 bytes (identical). Updater `.tgz` 2,878,003 bytes (24-byte
  difference from run 1 — expected, embedded build metadata varies run
  to run). All 19 FAPs found, same as run 1.

**Local build** remains `BUILD BLOCKED / ENVIRONMENT` in this AI session's
own sandbox — unrelated to the real CI result above, same toolchain-
download egress restriction every prior phase has hit.

## Conclusion

**Static PASS_WITH_REVIEWED_FALSE_POSITIVES. Build PASS — firmware,
`updater_package`, and all 19 `.fap` outputs (including `qrcode.fap`,
`hex_viewer.fap`, `barcode_app.fap`) confirmed present on 2 independent
real Windows CI runs.** Hardware flashing/testing: **NOT PERFORMED**.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY** (build
verified in CI only; no hardware validation has been performed for this
batch). See `docs/PHASE2F_2_GO_NO_GO.md` for the final Phase 2F.2
classification and next steps.

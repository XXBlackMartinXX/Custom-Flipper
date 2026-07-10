# Final Hardware-Assisted Validation Results

Docs only. Records the real, actual execution of
`tools/final_hardware_gate.ps1` in this AI session's own environment.
Nothing below is inferred or assumed — every result is from an actual
invocation, with the generated report filename recorded alongside it.

## Environment

This AI session ran in a Linux cloud sandbox — no Windows machine, no
physical Flipper Zero, no qFlipper installation. `pwsh` (PowerShell 7)
is available in this sandbox, so the script itself could be executed for
real, but `Get-PnpDevice` (a Windows-only cmdlet) is not available here —
confirmed directly (see DetectDevice run below), the same limitation
documented in every prior phase's own hardware-gate results
(`docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md` through
`docs/PHASE2F_HARDWARE_ASSISTED_RESULTS.md`).

## Hardware-assisted validation: NOT RUN

No real device was available to attempt a genuine `-Mode
HardwareAssisted` run against. Run 5 below invoked `-Mode
HardwareAssisted` for real, but with no device connected (none could
be) and no `-AllowFlashPrompt`, so it is a read-only, no-device
exercise of the mode's code path — not a completed hardware-assisted
validation.

## Real artifact hash verification: NOT RUN

The real, finalized artifacts (`firmware.dfu`,
`flipper-z-f7-update-local.tgz`) exist only as GitHub Actions workflow
artifacts on CI run `29068148596` and finalization run `29096377711`.
Fetching such artifacts from this sandbox hits the same, already-
documented network limitation as every prior phase: this session's
egress proxy returns a blocked/403 response for the Azure Blob Storage
host that GitHub Actions artifact downloads redirect to. **No real
artifact was hash-verified in this phase.**

## Synthetic mismatch test performed (clearly labeled, not real verification)

To prove the hash-comparison logic itself works correctly (not to claim
real-artifact verification), two random-data files were generated at
the exact expected sizes (862,833 and 2,891,859 bytes, via Python's
`os.urandom`) in a temporary directory entirely outside this repository,
and deleted immediately after the test. Running `-Mode HashVerify
-ArtifactDir <synthetic dir>` against them correctly produced `FAIL` for
both files:

- Firmware: "MISMATCH - expected size 862833 / sha256
  `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`,
  found size 862833 / sha256
  `4ac15b2a37bac1f404d9ccc296dc4c30c2282849ce07638055b64c6016ac31ba`"
- Updater: "MISMATCH - expected size 2891859 / sha256
  `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55`,
  found size 2891859 / sha256
  `a6a2cd1aac8f6f8659488c33c5895f0c29b757dc2cab903c4c5405ebf38af019`"

proving the comparison rejects wrong files even when the size matches
exactly, rather than passing on size alone. **This is a synthetic logic
test, not a real artifact verification result.**

## Runs performed (all real, via `pwsh` in this session)

| # | Command | Timestamp (UTC) | Report file | Classification |
|---|---|---|---|---|
| 1 | `-Mode Preflight` | `17:20:48Z` | `final_hardware_gate_20260710_172048_002_e6d4.{json,md}` | `NEEDS REVIEW` |
| 2 | `-Mode ReportOnly` | `17:20:48Z` | `final_hardware_gate_20260710_172048_838_57a6.{json,md}` | `NEEDS REVIEW` |
| 3 | `-Mode DetectDevice` | `17:20:49Z` | `final_hardware_gate_20260710_172049_638_10a5.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |
| 4 | `-Mode HashVerify -ArtifactDir <synthetic mismatched files>` | `17:20:50Z` | `final_hardware_gate_20260710_172050_664_c1cf.{json,md}` | `HARDWARE VALIDATION FAILED` (synthetic mismatch, proves comparison logic — see above) |
| 5 | `-Mode HardwareAssisted` (no `-ArtifactDir`, no device, no `-AllowFlashPrompt`) | `17:20:51Z` | `final_hardware_gate_20260710_172051_545_f0ed.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |

**Collision-resistance re-confirmed**: a separate, throwaway batch of 5
simultaneous `-Mode ReportOnly` invocations (launched with zero
deliberate delay via background shell jobs) produced 10 distinct report
files (`final_hardware_gate_20260710_171915_096_1cdb`,
`_171915_112_c178`, `_171915_206_c5cf`, `_171915_329_958f`,
`_171915_472_664d`, plus their `.md` counterparts) with zero overwrites,
re-confirming the millisecond-precision timestamp + random hex suffix
scheme carried forward unchanged from Phase 2C.4 onward works correctly
for this script too. All report files in this section were generated
under `reports/final_hardware/`, which is `.gitignore`d (`/reports`) and
therefore not committed — consistent with every prior phase.

## Why runs 1 and 2 classified `NEEDS REVIEW` (honest explanation, not a defect)

Two real, benign, expected conditions triggered `NEEDS_REVIEW`-level
checks in these runs: **commit drift** and **uncommitted working-tree
changes**. At the time these runs were made, `HEAD` was at the full-
project-consolidation-audit commit `a713861` — one docs-only commit past
the accepted CI-validated commit
`86265727b5b8cfce5086eb88f8bb93d0169ab9a9` — and the new
`tools/final_hardware_gate.ps1`,
`tools/final_hardware_gate_config.json`, and this final hardware-gate
pack's docs themselves were not yet committed. The script correctly
flags both as "confirm this is intentional" rather than silently
treating a different commit or a dirty tree as validating the same
accepted baseline — this is by design, the same behavior every prior
phase's own hardware gate exhibits whenever run mid-development or after
any docs-only commit following its own CI-validated commit. This does
not reflect a real problem with the accepted baseline itself, and both
conditions are expected to clear once this phase's own docs/tooling
commit lands.

## Excluded-asset absence check result: PASS

Every run above confirmed
`applications_user/image_viewer/example_images/` remains absent from
the repository. No SpongeBob or SpongeBob-like image, and no other
example image from that directory, was reintroduced at any point in
this phase.

## `barcode_gen` source-fix preservation check result: PASS

Every run above confirmed
`applications_user/barcode_gen/views/create_view.c` does not contain a
call to `text_input_show_illegal_symbols` — the Phase 2F.2A remediation
(commit `b6445ed`) remains preserved and has not regressed.

## `fcc_id_lookup` LICENSE preservation check result: PASS

Every run above confirmed `applications_user/fcc_id_lookup/LICENSE` is
present and contains the expected copyright line "Copyright (c) 2026
lsr" — the new Preflight-level check added specifically for this final
gate, verifying the upstream MIT license added at import time remains
preserved.

## FCC database accidental-presence check result: PASS

Every run above confirmed no `*.bin` file exists anywhere under
`applications_user/fcc_id_lookup/` — the new Preflight-level check added
specifically for this final gate, confirming the optional FCC frequency
database remains not bundled.

## Device detection result: attempted, `Get-PnpDevice` unavailable

Run 3 (`-Mode DetectDevice`) attempted real detection: `Get-PnpDevice`
is not a recognized cmdlet in this Linux sandbox — confirmed directly
via the actual PowerShell error ("The term 'Get-PnpDevice' is not
recognized as a name of a cmdlet..."), not assumed. Classified `BLOCKED`
for device detection specifically, and `qFlipper` was correctly also
not found (no Windows install paths, no registry, this is Linux).
Overall run classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT
AVAILABLE`.

## Tooling detection result

`qFlipper` was checked in runs 3 and 5 — not found via PATH, common
install directories, or the Windows uninstall registry (expected: this
is a Linux sandbox with no qFlipper installed at all). Classified
`BLOCKED`.

## Flash status: NOT RUN

`-AllowFlashPrompt` was never passed in any run this phase. No flash
confirmation prompt was ever shown. No flash was performed, confirmed,
or even offered.

## GUI smoke test status: NOT RUN

No human observed a real device screen in this phase. Run 5 (`-Mode
HardwareAssisted`, no device) still enumerated all 20 per-app
`REQUIRES_HUMAN_OBSERVATION` checks, plus the chess/sudoku save-path
checks, the `sd_info` SD-benchmark temp-file cleanup check, the
`docviewlite` read-only confirmation check, the `resistors` zero-storage
confirmation check, the `crypto_dictionary` read-only confirmation
check, the `2048` app-scoped save-path check, the `image_viewer`
read-only confirmation check, the `boilerplate`/`minesweeper`
app-private storage-path checks, the `qrcode` read-only/legacy-migration
confirmation check, the `hex_viewer` read-only confirmation check, the
`barcode_gen` app-private storage-path check, and the new
`fcc_id_lookup` read-only/optional-database setup-hint check — listed
explicitly, never executed, never assumed.

## Failures/blocks

- **Real, structural**: no Windows machine, no physical Flipper Zero, no
  qFlipper install in this sandbox — the same limitation as every prior
  phase's hardware-gate attempt.
- **Real, structural**: real CI artifacts cannot be downloaded in this
  sandbox — the same confirmed Azure Blob Storage 403 egress block as
  every prior phase.
- **Not a defect**: the `NEEDS_REVIEW` results from commit drift and an
  uncommitted working tree, explained above.

## Final classification

**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**

This matches exactly what the script itself produced when actually run
in this environment (runs 3 and 5 above) — not a looser or more
optimistic classification chosen after the fact.

## What would need to happen for a real result

1. A human with a Windows machine and a physical Flipper Zero clones
   this repository at the accepted commit
   (`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`, or later if intentional).
2. Download the real CI artifacts from run `29068148596` (or the
   finalization run `29096377711`'s hashed values) and run
   `.\tools\final_hardware_gate.ps1 -Mode HashVerify -ArtifactDir
   <downloaded-artifact-path>` to confirm the real firmware/updater
   hashes match `docs/FCC_ID_LOOKUP_ARTIFACT_HASHES.md`.
3. With the device connected, run `-Mode DetectDevice` (or `-Mode
   HardwareAssisted`) to confirm real, positive device and qFlipper
   detection.
4. Walk through `docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md` for all
   20 apps on the real device, recording results in a filled-in copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
5. Only after all of the above genuinely pass would `HARDWARE
   VALIDATION PASS WITH HUMAN OBSERVATION PENDING` (and, once the
   smoke-test checklist is actually completed and recorded, eventual
   release-readiness consideration) become appropriate — not before.

**Hardware flashing/testing: NOT PERFORMED. Release status: TEST-READY
ONLY / NOT RELEASE-READY.**

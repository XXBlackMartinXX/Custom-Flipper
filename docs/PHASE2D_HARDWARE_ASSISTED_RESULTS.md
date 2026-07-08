# Phase 2D — Hardware-Assisted Validation Results

Docs only. Records the real, actual execution of
`tools/phase2d_hardware_gate.ps1` in this AI session's own environment.
Nothing below is inferred or assumed — every result is from an actual
invocation, with the generated report filename recorded alongside it.

## Environment

This AI session ran in a Linux cloud sandbox — no Windows machine, no
physical Flipper Zero, no qFlipper installation. `pwsh` (PowerShell 7) is
available in this sandbox, so the script itself could be executed for
real, but `Get-PnpDevice` (a Windows-only cmdlet) is not available here —
confirmed directly (see DetectDevice run below), the same limitation
documented in every prior phase's own hardware-gate results
(`docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md`,
`docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md`,
`docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md`).

## Real artifact hash verification: NOT RUN

The real, finalized Phase 2D artifacts (`firmware.dfu`,
`flipper-z-f7-update-local.tgz`) exist only as GitHub Actions workflow
artifacts on CI run `28941093859` (artifact ID `8167725019`,
`phase2d-firmware-artifacts`). A real download URL was actually requested
via the GitHub API in this session (`download_workflow_run_artifact`),
and it correctly resolved to a signed Azure Blob Storage URL — but
fetching that URL hit the same, already-documented network limitation as
every prior phase: this session's egress proxy returned `CONNECT tunnel
failed, response 403` for `productionresultssa18.blob.core.windows.net`.
**No real artifact was hash-verified in this phase.**

## Synthetic mismatch test performed (clearly labeled, not real verification)

To prove the hash-comparison logic itself works correctly (not to claim
real-artifact verification), two random-data files were generated at the
exact expected sizes (862,825 and 2,783,170 bytes, via `/dev/urandom`) in
the scratchpad directory, entirely outside this repository, and deleted
after the test. Running `-Mode HashVerify -ArtifactDir <synthetic dir>`
against them correctly produced `FAIL` for both files — "MISMATCH —
expected size ... / sha256 ..., found size ... / sha256 ..." — proving
the comparison rejects wrong files even when the size matches exactly,
rather than passing on size alone. **This is a synthetic logic test, not
a real artifact verification result.**

## Runs performed (all real, via `pwsh` in this session)

| # | Command | Timestamp (UTC) | Report file | Classification |
|---|---|---|---|---|
| 1 | `-Mode Preflight` | `16:10:33Z` | `phase2d_hardware_gate_20260708_161033_429_7dc9.{json,md}` | `NEEDS REVIEW` |
| 2 | `-Mode DetectDevice` | `16:10:34Z` | `phase2d_hardware_gate_20260708_161033_996_3ae1.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |
| 3 | `-Mode HashVerify -ArtifactDir <synthetic mismatched files>` | `16:10:34Z` | `phase2d_hardware_gate_20260708_161034_684_12c6.{json,md}` | `HARDWARE VALIDATION FAILED` (synthetic mismatch, proves comparison logic — see above) |
| 4 | `-Mode ReportOnly` | `16:10:35Z` | `phase2d_hardware_gate_20260708_161035_256_4d94.{json,md}` | `NEEDS REVIEW` |
| 5 | `-Mode HardwareAssisted` (no `-ArtifactDir`, no device, no `-AllowFlashPrompt`) | `16:10:53Z` | `phase2d_hardware_gate_20260708_161053_676_c552.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |

**Collision-resistance re-confirmed**: a separate, throwaway batch of 5
simultaneous `-Mode Preflight` invocations (launched with zero deliberate
delay, discarded before the runs above) produced 10 distinct report files
with zero overwrites, re-confirming the millisecond-precision timestamp +
random hex suffix scheme carried forward unchanged from Phase 2C.4 works
correctly for this script too.

## Why runs 1 and 4 classified `NEEDS REVIEW` (honest explanation, not a defect)

One real, benign, expected condition triggered `NEEDS_REVIEW`-level checks
in these runs: **commit drift**. By the time this hardware gate was built
and tested, `HEAD` had moved forward from the accepted CI-validated
commit (`d0812638a02c50389b9e713ad98f2c8215b75dd5`) via one subsequent
docs-only commit (`0bb5131`, recording the Phase 2D.3 finalization
workflow's real result in `docs/PHASE2D_3_GO_NO_GO.md`). The script
correctly flags this as "confirm this is intentional" rather than
silently treating a different commit as validating the same accepted
baseline — this is by design, the same behavior every prior phase's own
hardware gate exhibits whenever run after any docs-only commit following
its own CI-validated commit. This does not reflect a real problem with
the Phase 2D baseline itself.

## Device detection result: attempted, `Get-PnpDevice` unavailable

Run 2 (`-Mode DetectDevice`) attempted real detection: `Get-PnpDevice` is
not a recognized cmdlet in this Linux sandbox — confirmed directly via the
actual PowerShell error ("The term 'Get-PnpDevice' is not recognized as a
name of a cmdlet..."), not assumed. Classified `BLOCKED` for device
detection specifically, and `qFlipper` was correctly also not found (no
Windows install paths, no registry, this is Linux). Overall run
classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.

## Tooling detection result

`qFlipper` was checked in runs 2 and 5 — not found via PATH, common
install directories, or the Windows uninstall registry (expected: this is
a Linux sandbox with no qFlipper installed at all). Classified `BLOCKED`.

## Flash status: NOT RUN

`-AllowFlashPrompt` was never passed in any run this phase. No flash
confirmation prompt was ever shown. No flash was performed, confirmed, or
even offered.

## GUI smoke test status: NOT RUN

No human observed a real device screen in this phase. Run 5
(`-Mode HardwareAssisted`, no device) still enumerated all 13 per-app
`REQUIRES_HUMAN_OBSERVATION` checks, plus the chess/sudoku save-path
checks, the `sd_info` SD-benchmark temp-file cleanup check, the
`docviewlite` read-only confirmation check, the `resistors` zero-storage
confirmation check, the `crypto_dictionary` read-only confirmation check,
and the `2048` app-scoped save-path check — listed explicitly, never
executed, never assumed.

## Failures/blocks

- **Real, structural**: no Windows machine, no physical Flipper Zero, no
  qFlipper install in this sandbox — the same limitation as every prior
  phase's hardware-gate attempt.
- **Real, structural**: real Phase 2D CI artifacts cannot be downloaded in
  this sandbox — a real signed download URL was obtained via the GitHub
  API, but fetching it hit the confirmed Azure Blob Storage `403` egress
  block.
- **Not a defect**: the `NEEDS_REVIEW` results from commit drift,
  explained above.

## Final classification

**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**

This matches exactly what the script itself produced when actually run in
this environment (runs 2 and 5 above) — not a looser or more optimistic
classification chosen after the fact.

## What would need to happen for a real result

1. A human with a Windows machine and a physical Flipper Zero clones this
   repository at the accepted commit
   (`d0812638a02c50389b9e713ad98f2c8215b75dd5`, or later if intentional).
2. Download the real CI artifacts from run `28941093859` (or a later
   finalized run) and run
   `.\tools\phase2d_hardware_gate.ps1 -Mode HashVerify -ArtifactDir
   <downloaded-artifact-path>` to confirm the real firmware/updater hashes
   match `docs/PHASE2D_3_ARTIFACT_HASHES.md`.
3. With the device connected, run `-Mode DetectDevice` (or
   `-Mode HardwareAssisted`) to confirm real, positive device and
   qFlipper detection.
4. Walk through `docs/PHASE2D_HARDWARE_SMOKE_TEST_CHECKLIST.md` for all 13
   apps on the real device, recording results in a filled-in copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
5. Only after all of the above genuinely pass would
   `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING` (and, once
   the smoke-test checklist is actually completed and recorded, eventual
   release-readiness consideration) become appropriate — not before.

**Hardware flashing/testing: NOT PERFORMED. Release status: TEST-READY
ONLY / NOT RELEASE-READY.**

# Phase 2E — Hardware-Assisted Validation Results

Docs only. Records the real, actual execution of
`tools/phase2e_hardware_gate.ps1` in this AI session's own environment.
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
`docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md`,
`docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md`).

## Real artifact hash verification: NOT RUN

The real, finalized Phase 2E artifacts (`firmware.dfu`,
`flipper-z-f7-update-local.tgz`) exist only as GitHub Actions workflow
artifacts on CI run `28968511276` (artifact ID `8179247001`,
`phase2e-firmware-artifacts`). A real, signed download URL was
independently confirmed reachable via the GitHub API earlier in this
session's Phase 2E.3 work — but fetching that URL from this sandbox hits
the same, already-documented network limitation as every prior phase:
this session's egress proxy returns `CONNECT tunnel failed, response
403` for the Azure Blob Storage host. **No real artifact was
hash-verified in this phase.**

## Synthetic mismatch test performed (clearly labeled, not real verification)

To prove the hash-comparison logic itself works correctly (not to claim
real-artifact verification), two random-data files were generated at the
exact expected sizes (862,825 and 2,831,378 bytes, via `/dev/urandom`) in
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
| 1 | `-Mode Preflight` | `20:21:57Z` | `phase2e_hardware_gate_20260708_202157_508_a50a.{json,md}` | `NEEDS REVIEW` |
| 2 | `-Mode DetectDevice` | `20:22:03Z` | `phase2e_hardware_gate_20260708_202203_736_580b.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |
| 3 | `-Mode ReportOnly` | `20:22:04Z` | `phase2e_hardware_gate_20260708_202204_828_9d31.{json,md}` | `NEEDS REVIEW` |
| 4 | `-Mode HashVerify -ArtifactDir <synthetic mismatched files>` | `20:22:15Z` | `phase2e_hardware_gate_20260708_202215_539_31c6.{json,md}` | `HARDWARE VALIDATION FAILED` (synthetic mismatch, proves comparison logic — see above) |
| 5 | `-Mode HardwareAssisted` (no `-ArtifactDir`, no device, no `-AllowFlashPrompt`) | `20:22:24Z` | `phase2e_hardware_gate_20260708_202224_689_fa16.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |

**Collision-resistance re-confirmed**: a separate, throwaway batch of 5
simultaneous `-Mode Preflight` invocations (launched with zero deliberate
delay) produced 10 distinct report files
(`phase2e_hardware_gate_20260708_202232_914_ed1a`,
`_202232_932_e116`, `_202233_083_c989`, `_202233_120_ddea`,
`_202233_249_dd7d`, plus their `.md` counterparts) with zero overwrites,
re-confirming the millisecond-precision timestamp + random hex suffix
scheme carried forward unchanged from Phase 2C.4/2D.4 works correctly for
this script too.

## Why runs 1 and 3 classified `NEEDS REVIEW` (honest explanation, not a defect)

Two real, benign, expected conditions triggered `NEEDS_REVIEW`-level
checks in these runs: **commit drift** and **uncommitted working-tree
changes**. At the time this hardware gate was built and tested, `HEAD`
was still at the final Phase 2E.3 integration commit (`f2340ae`, one
docs-only commit past the accepted CI-validated commit
`dcdfbb4c262c585d7d4126dc21b40dc3b948fc93`), and the new
`tools/phase2e_hardware_gate.ps1`/`tools/phase2e_hardware_gate_config.json`
files themselves were not yet committed. The script correctly flags both
as "confirm this is intentional" rather than silently treating a
different commit or a dirty tree as validating the same accepted
baseline — this is by design, the same behavior every prior phase's own
hardware gate exhibits whenever run mid-development or after any
docs-only commit following its own CI-validated commit. This does not
reflect a real problem with the Phase 2E baseline itself, and both
conditions are expected to clear once this phase's own docs/tooling
commit lands.

## Excluded-asset absence check result: PASS

Every run above confirmed
`applications_user/image_viewer/example_images/` remains absent from the
repository — the new Preflight-level check added specifically for Phase
2E.4 (`image_viewer/example_images/ absence check`). No SpongeBob or
SpongeBob-like image, and no other example image from that directory, was
reintroduced at any point in this phase.

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
(`-Mode HardwareAssisted`, no device) still enumerated all 16 per-app
`REQUIRES_HUMAN_OBSERVATION` checks, plus the chess/sudoku save-path
checks, the `sd_info` SD-benchmark temp-file cleanup check, the
`docviewlite` read-only confirmation check, the `resistors` zero-storage
confirmation check, the `crypto_dictionary` read-only confirmation check,
the `2048` app-scoped save-path check, the `image_viewer` read-only
confirmation check, and the `boilerplate`/`minesweeper` app-private
storage-path checks — listed explicitly, never executed, never assumed.

## Failures/blocks

- **Real, structural**: no Windows machine, no physical Flipper Zero, no
  qFlipper install in this sandbox — the same limitation as every prior
  phase's hardware-gate attempt.
- **Real, structural**: real Phase 2E CI artifacts cannot be downloaded in
  this sandbox — the same confirmed Azure Blob Storage `403` egress
  block as every prior phase.
- **Not a defect**: the `NEEDS_REVIEW` results from commit drift and an
  uncommitted working tree, explained above.

## Final classification

**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**

This matches exactly what the script itself produced when actually run in
this environment (runs 2 and 5 above) — not a looser or more optimistic
classification chosen after the fact.

## What would need to happen for a real result

1. A human with a Windows machine and a physical Flipper Zero clones this
   repository at the accepted commit
   (`dcdfbb4c262c585d7d4126dc21b40dc3b948fc93`, or later if intentional).
2. Download the real CI artifacts from run `28968511276` (or a later
   finalized run) and run
   `.\tools\phase2e_hardware_gate.ps1 -Mode HashVerify -ArtifactDir
   <downloaded-artifact-path>` to confirm the real firmware/updater hashes
   match `docs/PHASE2E_3_ARTIFACT_HASHES.md`.
3. With the device connected, run `-Mode DetectDevice` (or
   `-Mode HardwareAssisted`) to confirm real, positive device and
   qFlipper detection.
4. Walk through `docs/PHASE2E_HARDWARE_SMOKE_TEST_CHECKLIST.md` for all 16
   apps on the real device, recording results in a filled-in copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
5. Only after all of the above genuinely pass would
   `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING` (and, once
   the smoke-test checklist is actually completed and recorded, eventual
   release-readiness consideration) become appropriate — not before.

**Hardware flashing/testing: NOT PERFORMED. Release status: TEST-READY
ONLY / NOT RELEASE-READY.**

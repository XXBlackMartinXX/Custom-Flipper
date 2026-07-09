# Phase 2F — Hardware-Assisted Validation Results

Docs only. Records the real, actual execution of
`tools/phase2f_hardware_gate.ps1` in this AI session's own environment.
Nothing below is inferred or assumed — every result is from an actual
invocation, with the generated report filename recorded alongside it.

## Environment

This AI session ran in a Linux cloud sandbox — no Windows machine, no
physical Flipper Zero, no qFlipper installation. `pwsh` (PowerShell 7) is
available in this sandbox, so the script itself could be executed for
real, but `Get-PnpDevice` (a Windows-only cmdlet) is not available here —
confirmed directly (see DetectDevice run below), the same limitation
documented in every prior phase's own hardware-gate results
(`docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md` through
`docs/PHASE2E_HARDWARE_ASSISTED_RESULTS.md`).

## Real artifact hash verification: NOT RUN

The real, finalized Phase 2F artifacts (`firmware.dfu`,
`flipper-z-f7-update-local.tgz`) exist only as GitHub Actions workflow
artifacts on CI run `29017861599`. Fetching such artifacts from this
sandbox hits the same, already-documented network limitation as every
prior phase: this session's egress proxy returns `CONNECT tunnel failed,
response 403` for the Azure Blob Storage host that GitHub Actions
artifact downloads redirect to. **No real artifact was hash-verified in
this phase.**

## Synthetic mismatch test performed (clearly labeled, not real verification)

To prove the hash-comparison logic itself works correctly (not to claim
real-artifact verification), two random-data files were generated at the
exact expected sizes (862,825 and 2,878,428 bytes, via `/dev/urandom`) in
a temporary directory, entirely outside this repository, and deleted
immediately after the test. Running `-Mode HashVerify -ArtifactDir
<synthetic dir>` against them correctly produced `FAIL` for both files —
"MISMATCH — expected size 862825 / sha256
27f60598d43657710207510520159ba6626722a2825ed8adf5768d002a3a005b, found
size 862825 / sha256
1d00a9b2e6d831c4a337c9607d27131af669f166c64c8e826d97e4eaa4379c63" (and
the equivalent for the updater file) — proving the comparison rejects
wrong files even when the size matches exactly, rather than passing on
size alone. **This is a synthetic logic test, not a real artifact
verification result.**

## Runs performed (all real, via `pwsh` in this session)

| # | Command | Timestamp (UTC) | Report file | Classification |
|---|---|---|---|---|
| 1 | `-Mode Preflight` | `18:25:56Z` | `phase2f_hardware_gate_20260709_182556_356_70ba.{json,md}` | `NEEDS REVIEW` |
| 2 | `-Mode ReportOnly` | `18:26:03Z` | `phase2f_hardware_gate_20260709_182603_707_d760.{json,md}` | `NEEDS REVIEW` |
| 3 | `-Mode DetectDevice` | `18:26:04Z` | `phase2f_hardware_gate_20260709_182604_426_d7b5.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |
| 4 | `-Mode HashVerify -ArtifactDir <synthetic mismatched files>` | `18:26:10Z` | `phase2f_hardware_gate_20260709_182610_828_6d86.{json,md}` | `HARDWARE VALIDATION FAILED` (synthetic mismatch, proves comparison logic — see above) |
| 5 | `-Mode HardwareAssisted` (no `-ArtifactDir`, no device, no `-AllowFlashPrompt`) | `18:26:15Z` | `phase2f_hardware_gate_20260709_182615_075_3937.{json,md}` | `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` |

**Collision-resistance re-confirmed**: a separate, throwaway batch of 5
simultaneous `-Mode Preflight` invocations (launched with zero deliberate
delay via background shell jobs) produced 10 distinct report files
(`phase2f_hardware_gate_20260709_182621_575_2b65`,
`_182621_585_83e6`, `_182621_641_5f70`, `_182621_655_147b`,
`_182621_781_a7f0`, plus their `.md` counterparts) with zero overwrites,
re-confirming the millisecond-precision timestamp + random hex suffix
scheme carried forward unchanged from Phase 2C.4/2D.4/2E.4 works
correctly for this script too. All report files in this section were
generated under `reports/phase2f_hardware/`, which is `.gitignore`d
(`/reports`) and therefore not committed — consistent with every prior
phase.

## Why runs 1 and 2 classified `NEEDS REVIEW` (honest explanation, not a defect)

Two real, benign, expected conditions triggered `NEEDS_REVIEW`-level
checks in these runs: **commit drift** and **uncommitted working-tree
changes**. At the time these runs were made, `HEAD` was at
`e7c18fb367d83ce1592fb810a4c479716fee6bd5` — 3 docs-only commits past the
accepted CI-validated commit
`37d11cada5a83afdeb752c6b2106216d7fc09b9f` (the Phase 2F.3 baseline
acceptance and finalization-workflow-result commits), and the new
`tools/phase2f_hardware_gate.ps1`,
`tools/phase2f_hardware_gate_config.json`,
`docs/PHASE2F_HARDWARE_ASSISTED_VALIDATION.md`, and
`docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` files themselves were not
yet committed. The script correctly flags both as "confirm this is
intentional" rather than silently treating a different commit or a dirty
tree as validating the same accepted baseline — this is by design, the
same behavior every prior phase's own hardware gate exhibits whenever run
mid-development or after any docs-only commit following its own
CI-validated commit. This does not reflect a real problem with the Phase
2F baseline itself, and both conditions are expected to clear once this
phase's own docs/tooling commit lands.

## Excluded-asset absence check result: PASS

Every run above confirmed
`applications_user/image_viewer/example_images/` remains absent from the
repository — the Preflight-level check carried forward unchanged from
Phase 2E.4 (`image_viewer/example_images/ absence check`). No SpongeBob
or SpongeBob-like image, and no other example image from that directory,
was reintroduced at any point in this phase.

## `barcode_gen` source-fix preservation check result: PASS

Every run above confirmed
`applications_user/barcode_gen/views/create_view.c` does not contain a
call to `text_input_show_illegal_symbols` — the new Preflight-level check
added specifically for Phase 2F.4, verifying the Phase 2F.2A remediation
(commit `b6445ed`) remains preserved and has not regressed.

## Device detection result: attempted, `Get-PnpDevice` unavailable

Run 3 (`-Mode DetectDevice`) attempted real detection: `Get-PnpDevice` is
not a recognized cmdlet in this Linux sandbox — confirmed directly via the
actual PowerShell error ("The term 'Get-PnpDevice' is not recognized as a
name of a cmdlet..."), not assumed. Classified `BLOCKED` for device
detection specifically, and `qFlipper` was correctly also not found (no
Windows install paths, no registry, this is Linux). Overall run
classification: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.

## Tooling detection result

`qFlipper` was checked in runs 3 and 5 — not found via PATH, common
install directories, or the Windows uninstall registry (expected: this is
a Linux sandbox with no qFlipper installed at all). Classified `BLOCKED`.

## Flash status: NOT RUN

`-AllowFlashPrompt` was never passed in any run this phase. No flash
confirmation prompt was ever shown. No flash was performed, confirmed, or
even offered.

## GUI smoke test status: NOT RUN

No human observed a real device screen in this phase. Run 5
(`-Mode HardwareAssisted`, no device) still enumerated all 19 per-app
`REQUIRES_HUMAN_OBSERVATION` checks, plus the chess/sudoku save-path
checks, the `sd_info` SD-benchmark temp-file cleanup check, the
`docviewlite` read-only confirmation check, the `resistors` zero-storage
confirmation check, the `crypto_dictionary` read-only confirmation check,
the `2048` app-scoped save-path check, the `image_viewer` read-only
confirmation check, the `boilerplate`/`minesweeper` app-private
storage-path checks, the `qrcode` read-only/legacy-migration confirmation
check, the `hex_viewer` read-only confirmation check, and the
`barcode_gen` app-private storage-path check — listed explicitly, never
executed, never assumed.

## Failures/blocks

- **Real, structural**: no Windows machine, no physical Flipper Zero, no
  qFlipper install in this sandbox — the same limitation as every prior
  phase's hardware-gate attempt.
- **Real, structural**: real Phase 2F CI artifacts cannot be downloaded in
  this sandbox — the same confirmed Azure Blob Storage `403` egress
  block as every prior phase.
- **Not a defect**: the `NEEDS_REVIEW` results from commit drift and an
  uncommitted working tree, explained above.

## Final classification

**`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`**

This matches exactly what the script itself produced when actually run in
this environment (runs 3 and 5 above) — not a looser or more optimistic
classification chosen after the fact.

## What would need to happen for a real result

1. A human with a Windows machine and a physical Flipper Zero clones this
   repository at the accepted commit
   (`37d11cada5a83afdeb752c6b2106216d7fc09b9f`, or later if intentional).
2. Download the real CI artifacts from run `29017861599` (or a later
   finalized run) and run
   `.\tools\phase2f_hardware_gate.ps1 -Mode HashVerify -ArtifactDir
   <downloaded-artifact-path>` to confirm the real firmware/updater hashes
   match `docs/PHASE2F_3_ARTIFACT_HASHES.md`.
3. With the device connected, run `-Mode DetectDevice` (or
   `-Mode HardwareAssisted`) to confirm real, positive device and
   qFlipper detection.
4. Walk through `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` for all 19
   apps on the real device, recording results in a filled-in copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
5. Only after all of the above genuinely pass would
   `HARDWARE VALIDATION PASS WITH HUMAN OBSERVATION PENDING` (and, once
   the smoke-test checklist is actually completed and recorded, eventual
   release-readiness consideration) become appropriate — not before.

**Hardware flashing/testing: NOT PERFORMED. Release status: TEST-READY
ONLY / NOT RELEASE-READY.**

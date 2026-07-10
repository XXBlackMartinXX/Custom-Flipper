# Pre-Flash Safeguard Results

Docs only. Records the real, actual execution of
`tools/pre_flash_safeguard_gate.ps1` in this AI session's own
environment. Nothing below is inferred or assumed — every result is
from an actual invocation, with the generated report filename recorded
alongside it. **No flash has been performed. No hardware validation has
been performed. This script contains no flashing code path at all.**

## Environment

This AI session ran in a Linux cloud sandbox — no Windows machine, no
physical Flipper Zero, no qFlipper installation. `pwsh` (PowerShell 7)
is available, so the script itself executed for real, but
`Get-PnpDevice` (a Windows-only cmdlet, used for both normal-mode and
DFU/recovery-mode detection) is not available here — confirmed directly
via the real PowerShell error, not assumed, the same limitation
documented in every prior hardware-gate results document in this
project (`docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md` through
`docs/FINAL_HARDWARE_ASSISTED_RESULTS.md`).

## Pre-flash safeguard classification: PRE-FLASH SAFEGUARD BLOCKED - DEVICE NOT AVAILABLE

No physical Flipper Zero exists in this environment to detect, in
either normal or DFU/recovery mode. This is a real, structural
limitation, not a defect in the gate or a looser classification chosen
after the fact — it matches exactly what the script itself produced
when run for real (runs 3 and 4 below).

## qFlipper detection: NOT DETECTED (expected)

qFlipper is a Windows desktop application; this is a Linux sandbox with
no qFlipper installed. Detection was attempted for real (PATH lookup,
common install directories, Windows uninstall registry) in runs 3 and
4 below and correctly found nothing — classified `BLOCKED`, not assumed
present.

## Device detection: attempted, `Get-PnpDevice` unavailable

Runs 3 and 4 (`-Mode DeviceDetect` and `-Mode RecoveryReadiness`)
attempted real detection in both normal mode and DFU/recovery mode:
`Get-PnpDevice` is not a recognized cmdlet in this Linux sandbox —
confirmed directly via the actual PowerShell error ("The term
'Get-PnpDevice' is not recognized as a name of a cmdlet..."). Both the
normal-mode and DFU/recovery-mode checks classified `BLOCKED` for the
same underlying reason (Windows required). No device state was
fabricated or assumed.

## Recovery/DFU readiness: NOT VERIFIED

Because no real Flipper Zero and no Windows machine are available in
this environment, DFU/recovery-mode detection could not be genuinely
exercised. `-Mode RecoveryReadiness` ran for real (run 4 below) and
correctly reported `BLOCKED` for the same `Get-PnpDevice`-unavailable
reason as normal-mode detection — it did not, and could not, confirm
recovery-mode reachability on a real device.

## Real artifact hash verification: NOT RUN

The real, finalized artifacts (`firmware.dfu`,
`flipper-z-f7-update-local.tgz`) exist only as GitHub Actions workflow
artifacts on CI run `29068148596` and finalization run `29096377711`.
Fetching such artifacts from this sandbox hits the same, already-
documented network limitation as every prior phase in this project:
this session's egress proxy blocks the Azure Blob Storage host that
GitHub Actions artifact downloads redirect to. **No real artifact was
hash-verified in this phase.**

## Synthetic mismatch test performed (clearly labeled, not real verification)

To prove the hash-comparison logic itself works correctly, two
random-data files were generated at the exact expected sizes (862,833
and 2,891,859 bytes, via Python's `os.urandom`) in a temporary
directory entirely outside this repository, and deleted immediately
after the test. Running `-Mode ArtifactHashVerify -ArtifactDir
<synthetic dir>` against them correctly produced `FAIL` for both files,
each with an explicit "DO NOT FLASH THIS ARTIFACT" warning:

- Firmware: "MISMATCH - expected size 862833 / sha256
  `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`,
  found size 862833 / sha256
  `e6929bbc7096541aac2ff107e578505d693b0b73df596a40d1e869dfaef3d5a8`"
- Updater: "MISMATCH - expected size 2891859 / sha256
  `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55`,
  found size 2891859 / sha256
  `b1e3eed26be3de4e5ceaec914450d34ef3c0cd3502b8d11d81922ea38b622b50`"

proving the comparison rejects wrong files even when the size matches
exactly. Overall classification for this run: `PRE-FLASH SAFEGUARD
FAILED`, matching this gate's own design requirement that any failed
required check produces a failing/blocked classification, never a
looser one. **This is a synthetic logic test, not a real artifact
verification result.**

## Runs performed (all real, via `pwsh` in this session)

| # | Command | Timestamp (UTC) | Report file | Classification |
|---|---|---|---|---|
| 1 | `-Mode Preflight` | `18:14:29Z` | `pre_flash_safeguard_20260710_181429_730_d6fa.{json,md}` | `PRE-FLASH SAFEGUARD NEEDS REVIEW` |
| 2 | `-Mode ReportOnly` | `18:14:30Z` | `pre_flash_safeguard_20260710_181430_585_a2fa.{json,md}` | `PRE-FLASH SAFEGUARD NEEDS REVIEW` |
| 3 | `-Mode DeviceDetect` | `18:14:31Z` | `pre_flash_safeguard_20260710_181431_291_05f3.{json,md}` | `PRE-FLASH SAFEGUARD BLOCKED - DEVICE NOT AVAILABLE` |
| 4 | `-Mode RecoveryReadiness` | `18:14:32Z` | `pre_flash_safeguard_20260710_181432_214_0270.{json,md}` | `PRE-FLASH SAFEGUARD BLOCKED - DEVICE NOT AVAILABLE` |
| 5 | `-Mode ArtifactHashVerify -ArtifactDir <synthetic mismatched files>` | `18:14:33Z` | `pre_flash_safeguard_20260710_181433_157_5647.{json,md}` | `PRE-FLASH SAFEGUARD FAILED` (synthetic mismatch, proves comparison logic — see above) |

**Collision-resistance confirmed**: a separate, throwaway batch of 5
simultaneous `-Mode ReportOnly` invocations (launched with zero
deliberate delay via background shell jobs) produced 10 distinct report
files with zero overwrites, confirming the millisecond-precision
timestamp + random hex suffix scheme (the same one used by
`tools/final_hardware_gate.ps1` and every `tools/phaseX_hardware_gate.ps1`
script since Phase 2C.4) works correctly for this script too. All
report files were generated under `reports/pre_flash_safeguard/`, which
is `.gitignore`d (`/reports`) and therefore not committed — consistent
with every prior phase.

## Why runs 1 and 2 classified `NEEDS REVIEW` (honest explanation, not a defect)

Two real, benign, expected conditions triggered `NEEDS_REVIEW`-level
checks: **commit drift** and **uncommitted working-tree changes**. At
the time these runs were made, `HEAD` was at the final-hardware-gate-
pack commit `d9e4381` — one docs-only commit past the accepted CI-
validated commit `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` — and this
phase's own new files (`tools/pre_flash_safeguard_gate.ps1` and this
phase's docs) were not yet committed. The script correctly flags both
as worth confirming rather than silently treating a different commit or
a dirty tree as validating the accepted baseline. This does not reflect
a real problem with the accepted baseline, and both conditions are
expected to clear once this phase's own docs/tooling commit lands.

## Flashing status: NOT PERFORMED

No flash of any kind occurred in this phase. `tools/pre_flash_safeguard_gate.ps1`
contains no flashing code path under any mode or flag — there is no
`-AllowFlashPrompt`-equivalent switch, no confirmation gate, and no way
to reach a flash action through this script at all, unlike
`tools/final_hardware_gate.ps1`'s read-only flash-confirmation gate.

## GUI smoke test status: NOT RUN

No human observed a real device screen in this phase. This gate does
not enumerate app-level GUI checks at all — that remains the scope of
`docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`, unaffected by this
phase.

## Final classification

**`PRE-FLASH SAFEGUARD BLOCKED - DEVICE NOT AVAILABLE`**

This matches exactly what the script itself produced when actually run
in this environment (runs 3 and 4 above) — not a looser or more
optimistic classification chosen after the fact.

**Hardware flashing/testing: NOT PERFORMED. Release status: TEST-READY
ONLY / NOT RELEASE-READY.**

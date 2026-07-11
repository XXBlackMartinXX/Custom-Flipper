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

---

## Correctness patch re-run (real results, corrected script)

The runs above used the pre-patch script. After the Pre-Flash Safeguard
Correctness Patch (see `docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md`
for the full defect/fix writeup), the corrected
`tools/pre_flash_safeguard_gate.ps1` was re-run for real in this same
Linux sandbox — the environment limitations above (no Windows, no
device, no qFlipper, no real artifact download) are unchanged and still
apply.

| # | Command | Classification |
|---|---|---|
| 1 | `-Mode Preflight` | `PRE-FLASH SAFEGUARD FAILED` |
| 2 | `-Mode DeviceDetect` | `PRE-FLASH SAFEGUARD FAILED` |
| 3 | `-Mode RecoveryReadiness` | `PRE-FLASH SAFEGUARD FAILED` |
| 4 | `-Mode ArtifactHashVerify -ArtifactDir <synthetic mismatched files>` | `PRE-FLASH SAFEGUARD FAILED` (synthetic mismatch, proves comparison logic) |

**Important change from the pre-patch runs**: every mode now shows
`FAILED` rather than the pre-patch `NEEDS REVIEW`/`BLOCKED`. This is
not a regression — it is the corrected "Baseline ancestry and
diff-scope verification" check working exactly as specified,
correctly detecting a real forbidden-path difference between the
accepted baseline commit and HEAD:
`.github/workflows/fcc-id-lookup-finalize-baseline.yml`, added after
the accepted baseline as part of this project's own already-completed
baseline-finalization tooling. Full detail, including why this is a
real historical fact and not a defect in the check, is in
`docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md`'s "Important real
finding from this patch" section. **This finding does not affect
artifact hash verification**, which remains an independent, direct
byte-level comparison unaffected by source-tree diff scope.

The device-detection checks (`DeviceDetect`, `RecoveryReadiness`) now
report the more specific `BLOCKED - WINDOWS DEVICE API UNAVAILABLE` for
both normal-mode and DFU-mode detection (previously a generic
`BLOCKED`), confirmed via the real `Get-PnpDevice`-not-recognized error
in this sandbox, same underlying cause as before.

**Regression tests**: `tools/pre_flash_safeguard_gate.tests.ps1` was
run for real in this session and all 8 assertions (Tests A–G plus one
sanity check) passed, including Test B (the exact "Camera DFU Device"
false-positive fixture from the defect report) correctly rejected, and
Test A (exact Flipper DFU identity) correctly accepted. Full detail in
`docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md`.

**No flash was performed. No hardware validation pass is claimed.**
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**. The
`FAILED` classification above reflects the real, current state of this
repository's diff from its accepted baseline under the corrected,
stricter check — it is surfaced honestly for the project owner's
decision, not silently resolved by this patch.

---

## Pre-Flash Safeguard Hardening phase re-run (real results, this phase)

This section records **tooling-test results only** for the current
Pre-Flash Safeguard Hardening phase. **The final real Windows/hardware
rerun has not occurred as of this writing** — nothing below should be read
as claiming it has. This environment remains the same Linux cloud sandbox
as every prior phase: no Windows, no physical Flipper Zero, no qFlipper.

This phase resolved the one open item from the correctness-patch re-run
above: `.github/workflows/fcc-id-lookup-finalize-baseline.yml` is now
covered by a narrow, individually-reviewed, pinned-SHA256 exception (see
`docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md`), instead of forcing a
`FAIL` on every run against this repository's real HEAD.

`tools/pre_flash_safeguard_gate.ps1 -Mode Preflight` was re-run for real
in this sandbox after the pinned-exception fix:

- "Baseline ancestry and diff-scope verification" now reports
  `PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND
  PINNED FINALIZATION WORKFLOW`, with Detail confirming the real changed-
  file count, that the rest are confined to `docs/`/`tools/`, and that
  exactly one pinned, hash-verified exception file
  (`.github/workflows/fcc-id-lookup-finalize-baseline.yml`) was matched.
- The overall run classification was `NEEDS_REVIEW`, not `PASS` or
  `FAILED` — driven entirely by the same benign, expected
  uncommitted-working-tree condition described earlier in this document
  (this phase's own new files were not yet committed at the moment of the
  test run), not by any hardware or artifact check. This is expected and
  clears once this phase's commit lands.
- Device-detection checks are unchanged from the correctness-patch re-run
  above: `BLOCKED - WINDOWS DEVICE API UNAVAILABLE` for both normal-mode
  and DFU-mode, confirmed via the real `Get-PnpDevice`-not-recognized
  error in this sandbox.

**Regression tests**: `tools/pre_flash_safeguard_gate.tests.ps1` was
extended with the required Ancestry Tests A–F (docs/tools-only PASS;
docs/tools plus the exact pinned workflow with a matching hash PASS; the
exact pinned path with altered content/hash FAIL; a different, non-pinned
workflow file FAIL; an `applications_user/` change FAIL; baseline not an
ancestor of HEAD FAIL/BLOCKED) plus a real-repo assertion that this
repository's actual accepted baseline and actual HEAD classify as `PASS`
via the pinned exception. All 13 assertions in that file passed when run
for real via `pwsh` in this session. Full detail in
`docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md`.

**`tools/final_hardware_gate.ps1`** was hardened in this same phase to use
exact-`InstanceId`-only device identity (see
`docs/DEVICE_IDENTITY_HARDENING.md`) and re-run for real in this sandbox:

- `-Mode Preflight`: all prior checks unchanged and still `PASS`
  (branch, excluded-asset, barcode_gen fix, fcc_id_lookup LICENSE, FCC
  database); "Commit verification" and "Git status" remain `NEEDS_REVIEW`
  for the same benign, expected reasons as always (later commit than
  baseline; uncommitted phase files at test time). Overall:
  `NEEDS REVIEW`.
- `-Mode DetectDevice`: "Flipper Zero detection" now reports
  `BLOCKED - WINDOWS DEVICE API UNAVAILABLE` (previously a generic
  `BLOCKED`), confirmed via the real `Get-PnpDevice`-not-recognized error.
  Overall: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.
- **Regression tests**: `tools/final_hardware_gate.tests.ps1` (new in this
  phase) exercises Tests G–M (exact normal-mode PASS; exact DFU/recovery
  PASS; camera DFU BLOCKED; generic DFU name with unrelated InstanceId
  BLOCKED; normal-mode identity rejected by the DFU-specific check;
  camera DFU plus exact Flipper DFU PASS on the exact entry only;
  FriendlyName "Flipper" with wrong USB IDs BLOCKED for both checks). All
  8 assertions passed when run for real via `pwsh` in this session.

**No flash was performed in this phase. No hardware validation pass is
claimed. The final real Windows/hardware no-flash rerun described in
`docs/DEVICE_IDENTITY_HARDENING.md` and
`docs/PRE_FLASH_WORKFLOW_EXCEPTION_REVIEW.md` has not yet happened** —
only the corrected tooling has been exercised, here, in this sandbox, with
real command execution and real (not fabricated) output. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**.

---

## Pre-Flash Canonical Blob Integrity Fix (real results, this phase)

This section records **tooling-test results only** for the Canonical
Blob Integrity Fix phase. **The final real Windows/hardware rerun has
not occurred as of this writing** — nothing below should be read as
claiming it has. This environment remains the same Linux cloud sandbox
as every prior phase: no Windows, no physical Flipper Zero, no qFlipper.

This phase fixed a real defect reported from a real Windows session with
`core.autocrlf=true`: the pinned finalization-workflow exception in
`tools/pre_flash_safeguard_gate.ps1` hashed **working-tree** bytes for
its integrity decision, which differ from the committed Git blob on any
checkout where Git rewrites line endings — producing a false `FAIL`
even though the repository's real, committed content was unchanged. Full
root-cause and fix detail is in
`docs/PRE_FLASH_CANONICAL_BLOB_INTEGRITY_FIX.md`.

`tools/pre_flash_safeguard_gate.ps1 -Mode Preflight` was re-run for real
in this sandbox after the fix:

- "Baseline ancestry and diff-scope verification" continues to report
  `PASS - ACCEPTED BASELINE WITH REVIEWED TOOLING/DOCS DESCENDANT AND
  PINNED FINALIZATION WORKFLOW`, now decided entirely from the Git blob
  ID (`094ed7bf30eecae5efe384568c5c0aa543260b2f`) and the canonical
  SHA256 computed directly from that blob's bytes
  (`3350d94037d2eaef38fc354d931ae25c9ce83fb837a71bfc5372e64515e7ecc5`),
  never from a working-tree file hash.
- The overall run classification remains `NEEDS_REVIEW`, driven by the
  same benign, expected uncommitted-working-tree condition described
  earlier in this document (this phase's own new files were not yet
  committed at the moment of the test run) — not by any hardware,
  artifact, or workflow-integrity check.

**Regression tests**: `tools/pre_flash_safeguard_gate.tests.ps1` was
extended with the Canonical Git Blob Integrity Fix test block — a
byte-capture sanity check plus Blob Tests A–M, covering: a canonical LF
blob match (PASS); a **real** `core.autocrlf=true` reproduction (Git
config set for real, file re-checked out, genuine CRLF working-tree
bytes with a different SHA256, still `PASS` because the decision is
blob-based); committed content modification (FAIL); a deliberately wrong
pinned SHA256 with a matching blob ID, i.e. simulated config drift
(FAIL); a dirty unstaged edit (FAIL); a dirty staged-but-uncommitted
edit (FAIL); an unrelated workflow file (FAIL); a missing workflow path
(FAIL); baseline not an ancestor of HEAD (BLOCKED); a docs/tools-only
descendant with the exact pinned blob (PASS); an `applications_user/`
change (FAIL); a canonical-extraction failure via a removed loose Git
object, confirmed to `FAIL` through a `catch` branch rather than an
uncaught exception or a silent skip; and a re-confirmation that the
existing USB-identity regressions (exact normal-mode ID, exact DFU ID,
camera DFU rejection) remain intact. **All 30 assertions in the file
passed** when run for real via `pwsh` in this session, including the
pre-existing Ancestry Tests A–F (updated to carry the new
`ExpectedBlobId` field) and the real-repo assertion. Full detail in
`docs/PRE_FLASH_CANONICAL_BLOB_INTEGRITY_FIX.md`.

**No flash was performed in this phase. No hardware validation pass is
claimed.** The `core.autocrlf=true` reproduction in Blob Test B is a real
exercise of Git's own checkout/smudge logic (not gated by host OS), but
this remains a Linux sandbox — no actual Windows machine ran this fix in
this session. The evidence quoted in this phase's mission (the observed
Windows working-tree SHA256 and the manual diagnostic) was supplied by
the project owner from their own real Windows session. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**.

---

## Pre-Flash Device State-Machine Fix (real results, this phase)

This section records **tooling-test results only** for the Device
State-Machine Fix phase. **The final real Windows/hardware rerun has
not occurred as of this writing** — nothing below should be read as
claiming it has. This environment remains the same Linux cloud sandbox
as every prior phase: no Windows, no physical Flipper Zero, no
qFlipper.

**Previous false BLOCK, reported from a real Windows session**: with
Preflight PASS, ArtifactHashVerify PASS (firmware 862,833 bytes /
`e8c11b62...328f1d`; updater 2,891,859 bytes / `eec5b148...347cc55`),
qFlipper PASS, and `-Mode DeviceDetect` correctly reporting the exact
normal-mode identity `VID_0483&PID_5740` as PASS, a subsequent
`-Mode RecoveryReadiness` run correctly detected the exact DFU identity
`USB\VID_0483&PID_DF11\2059388C4831`, but the overall run was
classified `BLOCKED` anyway — because the normal-mode identity was (as
expected, since the device had transitioned into DFU mode) no longer
present, and the prior implementation treated that absence as an
independent failure. This was a real, invalid simultaneous-state
requirement — full root-cause detail is in
`docs/PRE_FLASH_DEVICE_STATE_MACHINE_FIX.md`.

`tools/pre_flash_safeguard_gate.ps1` was re-run for real in this
sandbox after the fix:

- `-Mode RecoveryReadiness`: "Flipper Zero detection (DFU/recovery
  mode)" still correctly reports `BLOCKED - WINDOWS DEVICE API
  UNAVAILABLE` (no real device or Windows exists here). "Flipper Zero
  detection (normal mode)" now reports
  `INFORMATIONAL - BLOCKED - WINDOWS DEVICE API UNAVAILABLE` — routed
  through the new advisory rather than independently contributing a
  second, redundant block to the classification.
- `-Mode DeviceDetect`: unchanged behavior — the exact normal-mode
  identity remains a direct, required check in this mode.

**Regression tests**: `tools/pre_flash_safeguard_gate.tests.ps1` was
extended with State Tests A–M, covering: exact normal-mode ID passes
DeviceDetect (A); exact DFU present with normal mode absent passes
RecoveryReadiness, with normal mode reported `EXPECTED ABSENT - DEVICE
IS IN DFU MODE` rather than `BLOCKED` (B); normal-mode ID present with
DFU absent still `BLOCKED` (C); camera DFU alone `BLOCKED` (D); generic
DFU-sounding name with an unrelated InstanceId `BLOCKED` (E); exact DFU
plus a camera DFU device still `PASS`es on the exact entry only (F);
exact normal plus exact DFU present simultaneously classifies
`NEEDS_REVIEW`, reporting both InstanceIds, never silently accepted (G);
no devices present `BLOCKED` (H); a device-enumeration error `BLOCKED`
with the exact error text (I); a function-level synthetic wrapper
proving all four modes' PASS-path decision functions clear in sequence
without any hardware in this sandbox (J); a dedicated re-confirmation
that camera DFU devices never determine a PASS (K); confirmation that
the full canonical Git-blob integrity suite (Blob Tests A–M) still
passes with no regression (L); and a source-text grep confirming no
flashing/install/repair command was added anywhere in the script (M).
**All 43 assertions in the file passed** when run for real via `pwsh`
in this session (6 pre-existing device-identity tests, 6 pre-existing
Ancestry tests, 1 real-repo assertion, 14 Canonical Git Blob Integrity
Fix tests, and 13 new State Tests). Full detail in
`docs/PRE_FLASH_DEVICE_STATE_MACHINE_FIX.md`.

**No flash was performed in this phase. No hardware validation pass is
claimed, and the corrected script has not yet been rerun on a real
Windows machine with a real device in this session** — only the
corrected tooling has been exercised here, in this sandbox, with real
command execution against both synthetic fixtures and this repository's
real HEAD. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

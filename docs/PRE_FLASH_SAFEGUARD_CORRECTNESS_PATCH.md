# Pre-Flash Safeguard Correctness Patch

Docs only. Records a narrow correctness patch to
`tools/pre_flash_safeguard_gate.ps1`, applied after real hardware
evidence review surfaced two defects. This document explains what was
wrong, what changed, how it was verified, and one important real
finding the fix surfaced about this repository's own history.

## Defect 1 — false DFU positive

**Before this patch**, `-Mode RecoveryReadiness` matched a connected
device against the Flipper DFU identity using:

```
Where-Object { $_.FriendlyName -match 'STM32 BOOTLOADER|DFU' -or $_.InstanceId -match [regex]::Escape('VID_0483&PID_DF11') }
```

The `-or $_.FriendlyName -match 'STM32 BOOTLOADER|DFU'` clause meant
**any** device whose Windows-assigned friendly name merely contained
the word "DFU" — including something completely unrelated, such as a
webcam's own DFU-capable firmware-update mode (`Camera DFU Device`,
`USB\VID_04F2&PID_B83E...`) — would satisfy the match and be reported
as a detected Flipper Zero recovery-mode device. This is a real false
positive: a user could see "Flipper Zero detection (DFU/recovery mode):
PASS" with no Flipper device connected at all, purely because an
unrelated USB device with "DFU" in its name happened to be present.

**The fix**: identity is now determined **solely** by an exact
substring match of `VID_0483&PID_DF11` (Flipper's actual DFU
bootloader identity) against the device's `InstanceId` — never against
`FriendlyName`. `FriendlyName` is still displayed in the report's
Detail text once a real match is found, for human readability, but it
never contributes to the PASS/BLOCKED decision. The same discipline was
applied to normal-mode detection (`VID_0483&PID_5740`), for consistency
and because the identical false-positive risk class applies there too.

Device enumeration (`Get-PresentPnpDevices`, the only function that
calls the real `Get-PnpDevice` cmdlet) is now separated from identity
evaluation (`Test-FlipperDfuIdentity`, `Test-FlipperNormalModeIdentity`,
`Get-DfuDetectionResult`, `Get-NormalModeDetectionResult` — pure
functions operating only on the strings/objects they are given), so the
identity logic can be exercised with synthetic device fixtures and no
real hardware — see `tools/pre_flash_safeguard_gate.tests.ps1`.

**New classifications**:

| Condition | Status |
|---|---|
| Exact `VID_0483&PID_DF11` present | `PASS` |
| Only generic/unrelated DFU-like devices present | `BLOCKED - EXACT FLIPPER DFU ID NOT DETECTED` |
| `Get-PnpDevice` cmdlet itself unavailable (non-Windows) | `BLOCKED - WINDOWS DEVICE API UNAVAILABLE` |
| `Get-PnpDevice` present but the query itself errors | `NEEDS_REVIEW` with the exact error text |

## Defect 2 — baseline commit relationship

**Before this patch**, the "Commit verification" check required
`git rev-parse HEAD` to equal the accepted baseline commit
(`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`) exactly, or else it
reported `NEEDS_REVIEW`. This is fragile: it also flags every
legitimate docs/tools-only commit added after baseline acceptance —
including this gate's own prior tooling commits — with the same
generic "confirm this is intentional" language as a genuinely
suspicious divergence, giving no way to distinguish "harmless docs
commit" from "someone changed the firmware source after CI validated
it" without manual inspection every time.

**The fix**: `Get-BaselineAncestryDiffResult` replaces the equality
check with:

1. Verify the accepted baseline commit exists locally
   (`git cat-file -e <sha>^{commit}`).
2. Verify the accepted baseline is an ancestor of HEAD
   (`git merge-base --is-ancestor <accepted-baseline> HEAD`).
3. Diff the accepted baseline against HEAD
   (`git diff --name-only <accepted-baseline>..HEAD`).
4. **Allow-list, fail-closed**: every changed file must fall under
   `docs/` or `tools/`. Any file outside those two prefixes —
   `applications/`, `applications_user/`, core firmware source,
   `.github/workflows/`, `build/`, `dist/`, `toolchain/`, or anything
   else — is a forbidden difference.
5. Classify:

| Condition | Status |
|---|---|
| HEAD equals the accepted baseline exactly | `PASS - HEAD IS THE ACCEPTED BASELINE COMMIT EXACTLY` |
| Baseline not found locally | `BLOCKED - ACCEPTED BASELINE NOT FOUND LOCALLY` |
| Baseline not an ancestor of HEAD | `BLOCKED - ACCEPTED BASELINE NOT AN ANCESTOR OF HEAD` |
| Ancestor, diff confined to docs/tools | `PASS - ACCEPTED BASELINE WITH TOOLING/DOCS-ONLY DESCENDANT` |
| Ancestor, diff touches a forbidden path | `FAIL - FORBIDDEN PATH CHANGES BETWEEN ACCEPTED BASELINE AND HEAD`, naming every offending file |
| A git command itself errors | `NEEDS_REVIEW` with the exact error text |

This never implies that HEAD itself produced the accepted firmware
artifacts — the Detail text for the descendant-PASS case says so
explicitly, and artifact verification (`ArtifactHashVerify`) remains
bound to the accepted baseline commit's own recorded sizes and hashes,
completely independent of whatever commit HEAD happens to be.

## Important real finding from this patch

Running the corrected `Get-BaselineAncestryDiffResult` against this
repository's **real** accepted baseline commit and real HEAD reveals
that HEAD is **not currently a pure docs/tools-only descendant** under
this stricter, fail-closed rule:

```
git diff --name-only 86265727b5b8cfce5086eb88f8bb93d0169ab9a9..HEAD | grep -v '^docs/' | grep -v '^tools/'
.github/workflows/fcc-id-lookup-finalize-baseline.yml
```

This file was added in commit `22167ac` ("fcc: baseline acceptance
record and finalization workflow") — **after** the accepted baseline
commit — as part of this project's own already-completed,
already-reviewed baseline-finalization process. It is the very GitHub
Actions workflow that computed the accepted baseline's own artifact
hashes (finalization run `29096377711`). It never affected the CI run
(`29068148596`) that produced the accepted `firmware.dfu`/updater
`.tgz` in the first place — that run predates this file entirely.

**This is not a defect in the corrected check.** The check is working
exactly as specified: `.github/workflows/` is explicitly listed as a
forbidden path with no carve-out, and a real `.github/workflows/` file
genuinely differs between the accepted baseline and HEAD. Running
`tools/pre_flash_safeguard_gate.ps1 -Mode Preflight` (or `DeviceDetect`,
`RecoveryReadiness`, or `ArtifactHashVerify`) against this repository's
current HEAD will therefore show `FAIL - FORBIDDEN PATH CHANGES BETWEEN
ACCEPTED BASELINE AND HEAD` on the "Baseline ancestry and diff-scope
verification" check, and an overall run classification of
`PRE-FLASH SAFEGUARD FAILED`, until this is explicitly addressed.

**This finding does not affect artifact hash verification.** The
`firmware.dfu`/updater `.tgz` hash comparison is independent of source-
tree diff scope — it compares real downloaded file bytes against the
accepted baseline's recorded hashes directly, regardless of what else
has changed in the repository.

**This was not weakened or worked around.** No exception was added for
this specific file. This document records the finding for the project
owner's explicit decision on how to proceed — for example, extending
the allow-list to include this one already-reviewed workflow file (a
scoped, explicit, reviewable change), or accepting the current `FAIL`
result on this one check as a known, documented condition distinct
from a real safety concern. Neither decision is made by this patch.

## Regression tests

`tools/pre_flash_safeguard_gate.tests.ps1` dot-sources the corrected
gate script (loading only its function definitions, performing no
hardware detection and no unintended git operations — see the
dot-source guard near the end of `tools/pre_flash_safeguard_gate.ps1`)
and exercises all 7 required scenarios plus one sanity check and one
informational real-repo diagnostic:

| Test | Scenario | Result |
|---|---|---|
| A | Exact Flipper DFU identity | `PASS` |
| B | Unrelated camera DFU device (`VID_04F2&PID_B83E`, "Camera DFU Device") | `BLOCKED` — never `PASS` |
| C | Generic "DFU in FS Mode" name, non-Flipper VID:PID | `BLOCKED` |
| D | Normal-mode Flipper identity fed to the DFU-specific check | `BLOCKED` (confirmed via a sanity check that the same fixture correctly `PASS`es the *normal-mode* check) |
| E | Camera DFU + exact Flipper DFU together | `PASS`, matched only by the exact entry |
| F | Docs/tools-only descendant (disposable scratch repository, since the real repository does not currently satisfy this scenario — see the finding above) | `PASS - ACCEPTED BASELINE WITH TOOLING/DOCS-ONLY DESCENDANT` |
| G | `applications_user/` descendant (disposable scratch repository) | `BLOCKED`/`FAIL`, naming the exact forbidden file |

All 8 assertions (7 required + 1 sanity check) pass. The scratch
repositories used for Tests F and G are created under the OS temp
directory, entirely outside this repository, and deleted immediately
after each test — neither test modifies this repository's own
`applications_user/` or any other real path.

## Files changed by this patch

- `tools/pre_flash_safeguard_gate.ps1` — both defects fixed; testable
  function separation added; PowerShell 5.1 compatibility preserved
  (no ternary/null-coalescing/pipeline-chain operators); collision-
  resistant report filenames preserved; JSON/Markdown report generation
  preserved; zero-flash design preserved (still no flashing parameter
  or code path of any kind).
- `tools/pre_flash_safeguard_gate.tests.ps1` — new regression test
  harness (added, not requested as a named deliverable, but required by
  this patch's own "IMPLEMENTATION QUALITY" and "VALIDATION"
  requirements for unit-testable identity logic and passing regression
  tests).
- `docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md` — this document.
- `docs/PRE_FLASH_SAFEGUARD_RESULTS.md` — updated with the corrected
  real run.

# Pre-Flash Device State-Machine Fix

Docs only. Records a defect in `tools/pre_flash_safeguard_gate.ps1`
where `-Mode RecoveryReadiness` incorrectly demanded the normal-mode USB
identity remain present at the same time as the DFU identity, the root
cause, the fix, and the regression evidence.

## Defect root cause

`-Mode RecoveryReadiness` unconditionally ran and reported **both**
`Get-NormalModeDetectionResult` and `Get-DfuDetectionResult` as
independent, equally-weighted checks, both feeding directly into the
overall classification (`$hasBlocked` / `$hasFail` / `$hasNeedsReview`).
When a real device was correctly detected in DFU/recovery mode -
`USB\VID_0483&PID_DF11\2059388C4831` - it was, correctly, no longer
enumerated under its normal-mode identity
(`USB\VID_0483&PID_5740\...`). `Get-NormalModeDetectionResult` therefore
returned `BLOCKED - FLIPPER NORMAL MODE NOT DETECTED`, which alone was
enough to push the overall run to `PRE-FLASH SAFEGUARD BLOCKED`, even
though the actual purpose of `-Mode RecoveryReadiness` - confirming DFU
reachability - had already succeeded.

This is an invalid simultaneous-state requirement: it demanded a single
physical USB device be enumerated under two mutually exclusive
identities at the same instant.

## Real Windows evidence

| Check | Result |
|---|---|
| Preflight | PASS |
| ArtifactHashVerify | PASS |
| Firmware artifact | 862,833 bytes, SHA256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`, PASS |
| Updater artifact | 2,891,859 bytes, SHA256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55`, PASS |
| DeviceDetect (normal mode) | exact `VID_0483&PID_5740`, PASS |
| RecoveryReadiness (DFU mode) | exact `VID_0483&PID_DF11` detected, but run classified `BLOCKED` because normal mode was (correctly, expectedly) no longer present |
| qFlipper | PASS |
| Flashing performed | NO |

The RecoveryReadiness `BLOCKED` result above is the defect this phase
fixes - it is not a hardware problem, and it is not evidence the device
was unreachable in DFU mode. The DFU identity itself was detected
correctly.

## Why normal and DFU identities are sequential, not simultaneous

A Flipper Zero is a single physical USB device that presents **one**
identity at a time, depending on its current firmware state:

```
NORMAL MODE
VID_0483&PID_5740
        |
        | user explicitly enters firmware-upgrade/DFU mode
        v
DFU MODE
VID_0483&PID_DF11
```

Entering DFU mode (holding Back while connecting USB, or via qFlipper's
own "reboot to DFU" action) causes the device to re-enumerate under the
STM32 bootloader's DFU identity, replacing the normal-mode USB
descriptor entirely for as long as it remains in that mode. There is no
supported device state in which both identities are simultaneously
valid for the same physical device - requiring both to be present at
once is not a stricter safety check, it is a check that can never be
satisfied by any real, correctly-operating device in DFU mode.

## Corrected mode requirements

| Mode | Required | Not required | Device-state notes |
|---|---|---|---|
| `Preflight` | Repository integrity, canonical workflow blob integrity, clean working tree, expected branch, environment checks | Device state | Unchanged by this phase |
| `ArtifactHashVerify` | Exact accepted firmware size/SHA256; exact accepted updater size/SHA256 | Device state | Unchanged by this phase |
| `DeviceDetect` | qFlipper detected; exact normal-mode ID `VID_0483&PID_5740` present | Exact DFU ID (not attempted in this mode; unchanged) | Absence of the normal-mode ID is still `BLOCKED` here - it is genuinely required in this mode |
| `RecoveryReadiness` | qFlipper detected; exact DFU ID `VID_0483&PID_DF11` present | Normal-mode ID present at the same time | Absence of the normal-mode ID while the exact DFU ID is present is now `EXPECTED ABSENT - DEVICE IS IN DFU MODE`, not `BLOCKED` |

## Exact USB IDs

- Normal mode: `VID_0483&PID_5740`
- DFU/recovery mode: `VID_0483&PID_DF11`

Both remain matched by exact `InstanceId` substring only
(`Test-FlipperNormalModeIdentity` / `Test-FlipperDfuIdentity`), never by
`FriendlyName` - this fix does not touch, weaken, or bypass that
matching in any way.

## The fix

A new function, `Get-RecoveryModeNormalIdentityAdvisory`, converts the
already-computed normal-mode result into a `-Mode RecoveryReadiness`-
appropriate advisory instead of reporting it as a raw, independent
requirement:

| Condition | Advisory status | Contributes to overall classification? |
|---|---|---|
| Exact DFU present, normal-mode absent | `EXPECTED ABSENT - DEVICE IS IN DFU MODE` | No - this is the expected, healthy DFU-mode state |
| Exact DFU present, exact normal-mode also present | `NEEDS_REVIEW - BOTH NORMAL AND DFU IDENTITIES PRESENT SIMULTANEOUSLY` | Yes - forces `NEEDS_REVIEW`, reports both `InstanceId`s, and is never silently treated as a normal single-device state (may indicate multiple devices, stale enumeration, or an unusual host state) |
| Exact DFU not present (any reason) | `INFORMATIONAL - <underlying normal-mode status>` | No - normal-mode presence/absence is purely informational here; any failure in this run comes from the DFU-mode check itself, which remains fully fail-closed |

`-Mode DeviceDetect` is unchanged: it still requires the exact
normal-mode identity directly and unconditionally, and does not attempt
DFU detection at all (already `NOT_RUN` in that mode, unaffected by this
fix).

`-Mode RecoveryReadiness`'s own DFU-mode check (`Get-DfuDetectionResult`)
is completely unmodified: it still requires the exact DFU identity,
still rejects camera DFU devices, generic "DFU"-named devices, absent
devices, and device-enumeration errors, all exactly as before. This fix
only changes what the (already-fail-closed) normal-mode check is allowed
to do to the overall classification in this one mode.

## Regression results

`tools/pre_flash_safeguard_gate.tests.ps1` was extended with State Tests
A-M, run for real via `pwsh` in this session against synthetic device
fixtures (no real hardware needed for these):

| Test | Scenario | Result |
|---|---|---|
| A | DeviceDetect: exact normal-mode ID present | `PASS` |
| B | RecoveryReadiness: exact DFU present, normal absent | DFU `PASS`; normal-mode advisory `EXPECTED ABSENT - DEVICE IS IN DFU MODE`, never `BLOCKED` |
| C | Normal-mode ID present, DFU absent | `BLOCKED` |
| D | Camera DFU only | `BLOCKED` |
| E | Generic DFU-sounding name, unrelated InstanceId | `BLOCKED` |
| F | Exact DFU plus camera DFU | `PASS`, matched only by the exact entry |
| G | Exact normal plus exact DFU simultaneously | `NEEDS_REVIEW - BOTH NORMAL AND DFU IDENTITIES PRESENT SIMULTANEOUSLY`, both `InstanceId`s reported |
| H | No devices present | `BLOCKED` |
| I | Device enumeration error | `BLOCKED - WINDOWS DEVICE API UNAVAILABLE`, exact error text present |
| J | Complete sequential wrapper (function-level, synthetic - see note below) | All four stages (Preflight/ArtifactHashVerify/DeviceDetect/RecoveryReadiness equivalents) clear |
| K | Camera DFU never determines PASS | Confirmed `BLOCKED`, never `PASS` |
| L | Canonical Git-blob integrity tests (Blob Test A-M) | All still passing, no regression |
| M | Zero-flash guarantee | No flashing/install/repair pattern found in the script's own source text |

**All 43 assertions in `tools/pre_flash_safeguard_gate.tests.ps1` passed**
(6 pre-existing device-identity tests, 6 pre-existing Ancestry tests, 1
real-repo assertion, 14 Canonical Git Blob Integrity Fix tests, and 13
new State Tests A-M).

**Important honesty note on Test J**: this sandbox has no real Windows
machine, no physical Flipper Zero, and no real qFlipper installation, so
Test J does not - and cannot - execute the script's four modes in
sequence against real hardware. It instead calls the exact same
decision functions the live script calls for each mode
(`Get-BaselineAncestryDiffResult`, the artifact size/hash comparison
logic, `Get-NormalModeDetectionResult`, `Get-DfuDetectionResult`, and
`Get-RecoveryModeNormalIdentityAdvisory`) with synthetic inputs matching
each stage's PASS scenario, and confirms none of them independently
blocks a valid sequential state transition. It is a function-level
composition proof, not a real end-to-end hardware run.

Real execution against this repository's actual current HEAD in this
sandbox: `-Mode RecoveryReadiness` and `-Mode DeviceDetect` both still
correctly report `BLOCKED - WINDOWS DEVICE API UNAVAILABLE` (via
`Get-PnpDevice` genuinely being unavailable here), with the normal-mode
check in `RecoveryReadiness` now shown as
`INFORMATIONAL - BLOCKED - WINDOWS DEVICE API UNAVAILABLE` rather than
independently contributing a second, redundant block - confirming the
fix behaves correctly in this environment's real (if hardware-less)
conditions, not only in synthetic fixtures.

## Zero-flash status

No flashing, firmware installation, or qFlipper Repair/Update/Install
action was added, invoked, or made reachable by this fix. `grep` across
the diff for flashing/installer patterns
(`Invoke-Flash`, `Flash-Device`, `dfu-util`, `ST-LINK_CLI`,
`STM32CubeProgrammer`, qFlipper repair/install/force-update invocations)
found no matches. `tools/pre_flash_safeguard_gate.ps1` retains zero
flashing code path of any kind, unchanged from every prior phase.

## Files changed by this fix

- `tools/pre_flash_safeguard_gate.ps1` - `Get-RecoveryModeNormalIdentityAdvisory`
  added; the main-body device-detection block for `-Mode RecoveryReadiness`
  now routes the normal-mode result through this advisory instead of
  reporting it as a direct, independent requirement.
  `Get-DfuDetectionResult`, `Get-NormalModeDetectionResult`,
  `Test-FlipperNormalModeIdentity`, `Test-FlipperDfuIdentity`, and
  `-Mode DeviceDetect`'s own handling are unchanged.
- `tools/pre_flash_safeguard_gate.tests.ps1` - State Tests A-M added.
- `docs/PRE_FLASH_DEVICE_STATE_MACHINE_FIX.md` - this document.

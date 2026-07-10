# Device Identity Hardening

Docs only. Records the exact USB device identities this project's gate
scripts rely on, the false-positive history that made hardening necessary,
and the regression evidence that both `tools/pre_flash_safeguard_gate.ps1`
(hardened in the Pre-Flash Safeguard Correctness Patch) and
`tools/final_hardware_gate.ps1` (hardened in this phase) now determine
device identity solely from exact USB `InstanceId` fragments - never from
`FriendlyName`.

## Exact identities enforced

| Mode | Exact `InstanceId` substring |
|---|---|
| Normal (application firmware) | `VID_0483&PID_5740` |
| DFU / recovery (STM32 bootloader) | `VID_0483&PID_DF11` |

Both are checked via `.ToUpperInvariant().Contains(...)` against the
device's real Windows `InstanceId` string - never a regex against
`FriendlyName`, never a partial/fuzzy match, never case-sensitive in a way
that could miss a real match.

Note that `VID_0483&PID_DF11` is ST Microelectronics's **generic** STM32
DFU bootloader identity, shared by many STM32-based devices in DFU mode -
it is the correct, documented identity for Flipper Zero's own bootloader,
but it is not literally unique to Flipper hardware. This is inherent to
how STM32 DFU mode enumerates and is not something either script can
change; what these scripts guarantee is that this exact identity is
required, and that nothing looser (a name, a partial ID, a heuristic) can
substitute for it.

## False-positive history

**The defect** (found via real hardware evidence, fixed in the Pre-Flash
Safeguard Correctness Patch - see
`docs/PRE_FLASH_SAFEGUARD_CORRECTNESS_PATCH.md`): the original DFU
detection logic in `tools/pre_flash_safeguard_gate.ps1` matched on
`$_.FriendlyName -match 'STM32 BOOTLOADER|DFU' -or $_.InstanceId -match
[regex]::Escape('VID_0483&PID_DF11')`. The `-or FriendlyName -match
'...DFU'` clause meant **any** device whose Windows-assigned name merely
contained the word "DFU" - including a completely unrelated webcam's own
DFU-capable firmware-update mode (`Camera DFU Device`,
`USB\VID_04F2&PID_B83E...`) - would satisfy the match and be reported as a
detected Flipper Zero in recovery mode, with no real Flipper connected at
all.

**Where it was fixed**: `tools/pre_flash_safeguard_gate.ps1`, during the
correctness patch (already complete before this phase).

**Where it was also found, disclosed, and now fixed**:
`tools/final_hardware_gate.ps1`'s live "Flipper Zero detection" check used
the identical pattern:
`Where-Object { $_.FriendlyName -match $Config.deviceDetection.expectedFriendlyNameSubstring -or $_.InstanceId -match [regex]::Escape($Config.deviceDetection.expectedVidPid) }`.
This was disclosed as a real, open, unfixed-at-the-time finding in
`docs/KNOWN_ISSUES.md` at the end of the correctness patch phase (rather
than being incorrectly claimed as immune) and is the exact defect this
phase's Part 2 resolves.

## The fix (both scripts, same pattern)

- **Enumeration/evaluation separation**: `Get-PresentPnpDevices` is the
  only function in either script that calls the real `Get-PnpDevice`
  cmdlet. It returns a plain `{ Success; Devices; ErrorType; ErrorMessage
  }` structure.
- **Pure identity functions**: `Test-FlipperNormalModeIdentity` and
  `Test-FlipperDfuIdentity` take only an `InstanceId` string and return a
  boolean - no `FriendlyName` parameter exists on these functions at all.
- **Pure classification functions**: `Get-NormalModeDetectionResult` and
  `Get-DfuDetectionResult` take an enumeration-result object and return a
  `{ Status; Detail }` structure. `FriendlyName` appears **only** in the
  human-readable `Detail` text after a real exact match has already been
  found by `InstanceId` alone - it is read for display, never for
  deciding PASS/BLOCKED.
- Both scripts also report "generic DFU-like" devices (matched loosely by
  `FriendlyName` or a bare `DF11` substring) purely for operator
  awareness in the `BLOCKED` Detail text (e.g. "your webcam's DFU mode is
  not your Flipper") - this broader lookup is explicitly documented as
  never contributing to a PASS.
- A dot-source testability guard
  (`$script:IsDotSourced = ($MyInvocation.InvocationName -eq '.')`) lets
  each script's companion `.tests.ps1` file load only these pure
  functions, with zero hardware calls and zero side effects, and exercise
  them against synthetic fixtures.

`tools/final_hardware_gate.ps1`'s only live caller of this logic is its
existing normal-mode "Flipper Zero detection" check - no new mode, no new
hardware capability, and no new live DFU-detection code path was added.
`Get-DfuDetectionResult` exists in that file so its identity logic is
regression-tested (per this phase's required Tests G-M) even though no
live mode currently invokes it; this does not expand what the script does
against real hardware.

## FriendlyName prohibition

In both scripts, `FriendlyName` is:

- **Never** used to determine a PASS.
- **Never** used to determine identity at all (the pure identity functions
  do not accept it as a parameter).
- Displayed **only** in `Detail` text, and only after `InstanceId` alone
  has already produced a real match or a real "generic-but-wrong-device"
  finding.

This is a deliberate, permanent design constraint, not a temporary
mitigation - any future change reintroducing a `FriendlyName`-based
identity decision in either script would be a regression of this fix.

## Regression results

### `tools/pre_flash_safeguard_gate.ps1` (fixed in the correctness patch,
unaffected by this phase)

| Test | Scenario | Result |
|---|---|---|
| Test A | Exact Flipper DFU identity | `PASS` |
| Test B | Unrelated camera DFU device (`VID_04F2&PID_B83E`, "Camera DFU Device") | `BLOCKED` |
| Test C | Generic "DFU in FS Mode" name, non-Flipper VID:PID | `BLOCKED` |
| Test D | Normal-mode Flipper identity fed to the DFU-specific check | `BLOCKED` (sanity: same fixture PASSes the normal-mode check) |
| Test E | Camera DFU + exact Flipper DFU together | `PASS`, matched only by the exact entry |

### `tools/final_hardware_gate.ps1` (hardened in this phase)

| Test | Scenario | Result |
|---|---|---|
| Test G | Exact normal-mode Flipper identity (`USB\VID_0483&PID_5740\...`) | `PASS` |
| Test H | Exact Flipper DFU identity (`USB\VID_0483&PID_DF11\...`) | `PASS` (recovery) |
| Test I | Camera DFU device (`USB\VID_04F2&PID_B83E...`, "Camera DFU Device") | `BLOCKED` |
| Test J | Generic DFU-sounding name, unrelated InstanceId | `BLOCKED` |
| Test K | Normal-mode Flipper identity fed to the DFU-specific check | `BLOCKED` |
| Test L | Camera DFU + exact Flipper DFU together | `PASS`, matched only by the exact entry |
| Test M | FriendlyName says "Flipper" but the InstanceId's USB IDs are wrong | `BLOCKED` (both normal-mode and DFU checks) |

All 8 assertions in `tools/final_hardware_gate.tests.ps1` pass, run for
real via `pwsh` in this session against synthetic fixtures - no real
hardware or Windows environment was needed or used for these tests.

## Files changed for this phase's hardening

- `tools/final_hardware_gate.ps1` - device-identity functions, enumeration/
  evaluation separation, dot-source guard, and generalized `Add-Result`
  status handling added, mirroring the already-proven pattern in
  `tools/pre_flash_safeguard_gate.ps1`; the live "Flipper Zero detection"
  check now calls the hardened, exact-`InstanceId`-only path. qFlipper
  detection (a separate, application-install check, not a USB device
  identity check) and the gated flash-confirmation path are unchanged.
- `tools/final_hardware_gate.tests.ps1` - new regression test harness
  (Tests G-M).
- `docs/DEVICE_IDENTITY_HARDENING.md` - this document.

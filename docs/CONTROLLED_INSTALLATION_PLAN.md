# Controlled Installation Plan

**Status: PLANNING DOCUMENT ONLY. No installation has occurred. This
document describes a procedure for a human operator to execute later, on
their own Windows PC with their own physical Flipper Zero. Nothing in
this document is a claim that any step below has been performed.**

This plan exists to make the eventual controlled installation of the
accepted Custom-Flipper 20-app firmware baseline onto one physical
Flipper Zero as safe, deliberate, and reversible as reasonably possible.
It is not a release. It is not automated flashing. It does not authorize
radio, security, credential, or access-control testing.

## Reference facts (as of this planning phase)

| Item | Value |
|---|---|
| Repository | `XXBlackMartinXX/Custom-Flipper` |
| Implementation branch | `integration/fcc-id-lookup-one-app-import` |
| Documentation branch | `claude/flipper-custom-firmware-cxrcer` |
| Accepted build baseline commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` |
| Accepted CI run | `29068148596` |
| Finalization run | `29096377711` |
| Current tooling/docs revision | `046e5d1a6073732b5a10572705a972e297a1b6a0` (or a later descendant accepted by the repository safeguard) |
| Primary installation artifact | `flipper-z-f7-update-local.tgz` — size `2,891,859` bytes, SHA256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` |
| Recovery-only artifact | `firmware.dfu` — size `862,833` bytes, SHA256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` |
| Normal-mode USB identity | `VID_0483&PID_5740` |
| DFU/recovery USB identity | `VID_0483&PID_DF11` |
| Firmware installation performed | **NO** |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** |

---

## A. Scope and safety boundary

- **One physical Flipper Zero only.** This plan does not cover fleet
  installs, multiple devices, or repeated installs on the same device
  within one session.
- **One installation attempt only per execution of this plan.** If the
  attempt fails, follow the recovery decision tree (Section L) rather
  than repeating the install.
- `flipper-z-f7-update-local.tgz` is the **primary and only** intended
  installation artifact for this plan.
- `firmware.dfu` is **recovery-only**. It is never selected as the
  routine installation method.
- **No automatic fallback** from the `.tgz` installer to `.dfu` recovery
  is permitted at any point — falling back to recovery is always a
  separate, explicitly human-authorized decision (Section L).
- This plan does not claim, produce, or authorize a release. Completing
  every step in this plan does not itself make the build release-ready.

## B. Preconditions

Confirm every item below before proceeding to Section C. If any item is
not satisfied, stop and resolve it first — do not continue past it.

- [ ] A Windows PC is available and is the machine that will run
      qFlipper for this install.
- [ ] qFlipper is installed on that Windows PC (official build).
- [ ] A known-good USB data cable (not a charge-only cable) is available.
- [ ] The Flipper Zero's battery is sufficiently charged (recommended:
      visibly above a low-battery warning, ideally >50%).
- [ ] A microSD card is inserted in the Flipper Zero and is recognized
      by the device.
- [ ] The device currently boots normally into its existing firmware.
- [ ] qFlipper, when the device is connected in normal mode, sees and
      identifies the device correctly.
- [ ] The verified artifact directory (containing the exact,
      hash-matched `flipper-z-f7-update-local.tgz` and `firmware.dfu`)
      is available locally on the Windows PC.
- [ ] The DFU/recovery path has already been demonstrated reachable on
      this device in an earlier phase (exact identity
      `VID_0483&PID_DF11` observed) — this plan does not re-derive that
      demonstration, only relies on it having occurred.
- [ ] The operator is personally comfortable proceeding. If not, stop
      here — discomfort alone is sufficient reason not to continue.

## C. Backup procedure

Complete and document all of the following before touching the
installer:

1. Perform a qFlipper-supported backup of supported device
   settings/progress/pairing data, using qFlipper's own backup feature.
2. Copy the microSD card's important contents to a timestamped folder on
   the PC (e.g. `flipper_sd_backup_YYYYMMDD_HHMMSS/`).
3. Record the following, verbatim, before continuing:
   - Current installed firmware version (as shown by qFlipper or the
     device's own About/System screen).
   - qFlipper version.
   - Device name (as configured in qFlipper).
   - Normal-mode USB `InstanceId` (from Windows Device Manager or the
     safeguard script's own detection output).
   - Backup folder path(s) used in steps 1–2.
4. Confirm the verified `firmware.dfu` recovery artifact is still present
   locally and its hash still matches
   `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d`
   (re-run `-Mode ArtifactHashVerify` if there is any doubt — do not
   assume a prior verification still holds if the file could have moved
   or been touched since).
5. Keep the official/stable Flipper Zero firmware recovery option
   available (e.g. via qFlipper's own official-firmware recovery flow),
   in case Section L's recovery path is needed.
6. Close every other program that might access the device over USB
   (other serial monitors, other Flipper tools, terminal emulators
   attached to the device's COM port, etc.) so qFlipper has exclusive
   access.

**Do not proceed past this section if any of the following are true:**
the backup failed or is incomplete; the microSD is missing or not
recognized; the qFlipper connection is unstable; the device battery is
critically low; the USB connection is intermittent; the recovery
artifact is missing; artifact hashes no longer match; or the operator is
uncomfortable proceeding.

## D. Just-in-time checks

Immediately before opening the installer file, re-run all three of the
following from the repository root on the Windows PC, in this order:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\pre_flash_safeguard_gate.ps1 `
  -Mode Preflight

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\pre_flash_safeguard_gate.ps1 `
  -Mode ArtifactHashVerify `
  -ArtifactDir "<verified-artifact-directory>"

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\pre_flash_safeguard_gate.ps1 `
  -Mode DeviceDetect
```

Replace `<verified-artifact-directory>` with the actual path containing
both `flipper-z-f7-update-local.tgz` and `firmware.dfu`.

**All three runs must show:**

- `Preflight` passes with no `FAIL`, no `BLOCKED`, and no unresolved
  `NEEDS_REVIEW`.
- `ArtifactHashVerify` shows both the updater and the firmware recovery
  hash checks as `PASS`.
- `DeviceDetect` shows the exact normal-mode identity `VID_0483&PID_5740`
  as `PASS`.

If any of the three runs shows a `FAIL`, a `BLOCKED`, or an unresolved
`NEEDS_REVIEW` — **do not open the installer file**. Stop and treat this
as `INSTALLATION BLOCKED` for this session.

## E. Human authorization gate

Before opening the installer file in qFlipper, the operator must type,
exactly, character for character:

```
I UNDERSTAND THE RISK AND AUTHORIZE ONE CONTROLLED INSTALL
```

Any other response — a paraphrase, a partial match, "yes", "ok", or
silence — means: stop, do not open the file, and classify this attempt
as `USER DECLINED INSTALLATION`.

This phrase authorizes **only** the selection/opening of the verified
updater package in qFlipper's file picker. It does **not** automate,
approve in advance, or substitute for qFlipper's own final installation
confirmation — that confirmation remains a separate, manual human click
inside qFlipper itself, performed by the operator, never by a script or
an assistant.

## F. qFlipper installation procedure

1. Open the already-installed, official qFlipper application manually.
2. Confirm qFlipper displays the correct, expected Flipper Zero (check
   the device name and/or serial recorded in Section C.3).
3. In qFlipper, choose the **Install from file** function (not "Update",
   not "Repair", not any automatic online-update path).
4. In the file picker, select **only**:
   ```
   flipper-z-f7-update-local.tgz
   ```
   from the verified artifact directory recorded in Section D.
5. Before clicking any further confirmation, verify on-screen: the
   folder path, the exact filename, the file size (`2,891,859` bytes),
   and that this is the file whose hash was just re-verified in Section
   D.
6. **Do not select `firmware.dfu`** for this step, under any
   circumstance — it is recovery-only.
7. **Do not select** a ZIP archive, a validation bundle, a `.fap`
   bundle, or any other updater package that may exist in the same
   directory.
8. The final qFlipper installation confirmation is performed by the
   human operator, manually, inside qFlipper's own UI. No script,
   tool, or assistant clicks this confirmation.
9. Once installation begins:
   - Do not disconnect USB.
   - Do not close qFlipper.
   - Do not reboot the PC.
   - Do not press any Flipper Zero buttons unless qFlipper's own UI
     explicitly instructs it.
   - Do not remove the microSD card.
   - Do not start another device-management tool that might also try to
     access the device over USB.

If qFlipper refuses the `.tgz` package: do not switch to `.dfu`, do not
rename or repack the file, do not retry repeatedly. Capture the exact
error text and qFlipper's log, and classify this attempt
`INSTALLATION BLOCKED / UPDATE PACKAGE REJECTED`. Stop.

If qFlipper crashes or loses connection before writing begins: do not
immediately retry. Determine whether the Flipper Zero still boots
normally, preserve qFlipper's logs, and classify this attempt
`INSTALLATION INTERRUPTED / DEVICE STATE REVIEW REQUIRED`. Stop.

If qFlipper reports success: wait for the device to complete its own
reboot. Do not assume success merely because qFlipper's progress bar
finished — wait until the device's own screen is responsive before
concluding anything.

## G. Stop conditions

Stop immediately, without proceeding further, if any of the following
occur at any point in this procedure:

- qFlipper rejects the update package.
- The device disconnects unexpectedly.
- The USB connection becomes unstable or intermittent.
- qFlipper unexpectedly requests a Repair or Erase action that was not
  anticipated by this plan.
- The wrong artifact is selected (including any accidental selection of
  `firmware.dfu`).
- A hash or size mismatch is discovered at any point, even after
  Section D's checks passed.
- The microSD card is not recognized at any point.
- The backup (Section C) did not complete.
- Any unexpected destructive-sounding prompt appears.
- The device does not reboot after the reported installation.
- The device enters a boot loop.
- The device crashes or freezes.
- The operator becomes uncomfortable continuing, for any reason.

## H. Immediate post-install boot checks

After qFlipper reports the installation complete, verify, in this exact
order, before doing anything else:

1. The device powers on.
2. The desktop appears on the device screen.
3. Buttons respond to input.
4. There is no boot loop.
5. There is no crash screen.
6. There is no freeze.
7. There is no unexpected, unrequested entry into recovery mode.
8. The microSD card is recognized by the device.
9. USB reconnects normally after the post-install reboot.
10. qFlipper reconnects and detects the device in normal mode.
11. Windows Device Manager (or the safeguard script) confirms the exact
    normal-mode identity `VID_0483&PID_5740`.
12. Installed firmware/version information is visible and consistent
    with the newly installed build.
13. The device can perform one additional normal reboot and return
    cleanly to the desktop.

Do not open any custom app until every item above has passed. Classify
this stage as either `CORE BOOT PASS` or
`CORE BOOT FAILED — RECOVERY REQUIRED`.

## I. Safe core smoke checks

Only after `CORE BOOT PASS`, perform these low-risk checks:

- Navigate the desktop.
- Open the Main Menu.
- Open Settings.
- Open the Storage page.
- Confirm microSD status is shown correctly.
- Open About/System information.
- Confirm USB reconnects cleanly after being briefly re-plugged, if
  tested.
- Test backlight/volume controls, where normally available on this
  device.
- Confirm a clean exit from every menu opened (Back returns correctly,
  no freeze).

## J. Low-risk app launch-only checks

For this installation phase only, perform launch-and-exit checks for
these low-risk, purely local apps (no external files, no radio, no
credentials):

- `programmer_calc`
- `vin_decoder`
- `quadratic_solver`
- `sudoku`
- `chess`
- `2048`
- `minesweeper_redux`
- `resistors`
- `crypto_dictionary`
- `fap_boilerplate`

For each app, confirm:

- It is visible in the app menu.
- It launches.
- It renders a usable screen.
- Back exits it cleanly.
- No crash occurs.
- No freeze occurs.
- No reboot occurs.

**This is not the full 20-app functional test.** Storage/file-viewing
apps and any app requiring external files belong to a separate, later,
staged hardware smoke-test phase, not this installation phase.

## K. Forbidden tests

The following are explicitly out of scope for this installation phase,
and for the low-risk app checks in Section J, under all circumstances:

- RF/Sub-GHz transmission or reception.
- NFC.
- RFID.
- iButton.
- BadUSB.
- BLE transmission.
- GPIO.
- Infrared transmission.
- Cloning of any signal, card, key, or credential.
- Replay attacks.
- Brute-force attempts.
- Bypass attempts of any kind.
- Jamming.
- Deauthentication.
- HID injection.
- Handling of real credentials, passwords, or secrets.
- Testing against any access-control system.
- Handling of wallets, seed phrases, or private keys.
- Testing against any unauthorized device or system.

## L. Recovery decision tree

If the device does not boot normally after installation:

1. Do not panic.
2. Do not repeatedly power-cycle the device.
3. Attempt exactly one normal reboot using the device's own
   Left + Back button combination.
4. If normal boot still fails:
   - Enter exact DFU mode and verify the exact identity
     `VID_0483&PID_DF11` (never a generic "DFU"-named or unrelated
     device).
   - Open qFlipper.
   - Preserve logs and, if useful, photos of the device screen.
5. Do not start qFlipper's Repair function automatically.
6. Before any recovery action, explain clearly to the operator that
   qFlipper's repair/recovery flow may reset internal device data.
7. Require the operator to type, exactly:
   ```
   I AUTHORIZE OFFICIAL FIRMWARE RECOVERY
   ```
   before any recovery action is taken. Any other response means: do
   not proceed with recovery yet.
8. When recovery is authorized, prefer restoring the official/stable
   Flipper Zero firmware over any other option.
9. Do not attempt to reinstall the custom build repeatedly during a
   recovery attempt — one clean recovery to official/stable firmware
   takes priority over retrying the custom install.
10. After recovery, verify the device boots normally again before
    concluding the recovery attempt.

Applicable final classifications for a failed or interrupted attempt:

- `INSTALLATION FAILED — RECOVERED TO OFFICIAL/STABLE FIRMWARE`
- `INSTALLATION FAILED — RECOVERY STILL REQUIRED`
- `INSTALLATION INTERRUPTED — DEVICE REMAINS OPERATIONAL`

---

## Companion documents

- `docs/CONTROLLED_INSTALLATION_OPERATOR_CHECKLIST.md` — printable,
  unchecked checklist mirroring this plan's sections.
- `docs/CONTROLLED_INSTALLATION_EVIDENCE_TEMPLATE.md` — blank
  evidence-capture template for the operator to fill in during/after
  execution.
- `docs/CONTROLLED_INSTALLATION_RESULTS.md` — status stub, currently
  `NOT PERFORMED`.
- `docs/POST_INSTALL_CORE_BOOT_REPORT.md` — blank template, currently
  `NOT PERFORMED`.
- `docs/POST_INSTALL_LOW_RISK_SMOKE_REPORT.md` — blank template,
  currently `NOT PERFORMED`.
- `docs/ROLLBACK_READINESS_AFTER_INSTALL.md` — recovery-readiness
  planning document, currently `NOT PERFORMED`.

## Status of this plan

This document describes a procedure only. As of this writing:

- No firmware has been written to any device under this plan.
- No qFlipper installation has been executed under this plan.
- No boot validation has been completed under this plan.
- No custom app hardware testing has been completed under this plan.
- Release status remains **TEST-READY ONLY / NOT RELEASE-READY**.

The next required action is a human operator executing this plan on
their own Windows PC with their own physical Flipper Zero, then
reporting the real outcome so the companion result documents can be
filled in honestly.

# Phase 2A — Automation Limitations

Docs only. This is an honest accounting of what the Phase 2A validation tooling
(`tools/phase2a_validate.ps1`) can and cannot prove, so that a green run is
never mistaken for more coverage than it actually provides.

**Phase 2A.6 update**: the script was executed for real for the first time
this round (in a cloud sandbox, with PowerShell installed specifically for
this — not on the project owner's Windows machine; see
`PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`), which found and fixed two script
bugs. Neither fix changes anything below — GUI-level app navigation still
requires human observation or deeper firmware/RPC automation that doesn't
exist, hardware flashing/testing is still not performed, and release-ready is
still not claimed. This update exists only to confirm those limitations were
re-checked, not to loosen any of them.

## What can be fully automated today

These are checked by the script with no human involvement, in every
environment where the relevant tool (`git`, or `fbt.cmd` + toolchain) is
available:

- Branch and commit identity
- Working-tree cleanliness before/after
- Submodule initialization and pin correctness
- Presence of all 5 Phase 2A app directories
- `application.fam` parseability, `appid=`/`name=` presence
- App ID uniqueness within the batch and against the base firmware
- The SAM-removal grep sweep (absence of `sam`/`stm32_sam`/`flipchess_voice`/
  `speech`/`voice` in `chess`)
- The risky-keyword substring sweep across the 5 app directories (with every
  match surfaced, not filtered)
- Firmware and updater-package build invocation and exit-code capture
- Build artifact existence, non-emptiness, and size recording
- Per-app `.fap` output existence under `build\f7-firmware-C\.extapps\`
- Connected-device detection on Windows (via `Get-PnpDevice`)

## What cannot be automated without physical device access

- Whether the firmware actually boots on real hardware
- Whether any app actually appears in its expected menu category on the real
  device UI
- Whether any app actually launches, renders, and responds to button input
- Whether chess's save file is actually written, actually resumes correctly,
  and actually stays confined to `/ext/apps_data/flipchess/` during real play
- Battery/power behavior, long-run stability, behavior across real
  flash/reflash cycles

None of this can be inferred from source review or a successful compile alone
— it requires the specific combination of real firmware running on a real
STM32WB55 with a real display and buttons, which this project's cloud sandbox
has never had access to (see `PHASE0_SOURCE_VERIFICATION.md`) and which no
static script can substitute for.

## What cannot be automated without GUI automation / RPC support

Even with a device physically connected to a Windows machine, this project has
not established (and does not assume) a reliable way to script the following
without a human watching the screen:

- Confirming the menu actually *shows* "Network Subnet Helper" / "Programmer
  Calculator" / "VIN Decoder" / "Flipper95" / "Chess" in the right category,
  as opposed to just existing as a compiled binary
- Driving on-screen navigation (which screen appeared, did a button press
  move the cursor/selection where expected)
- Reading calculated/displayed values off the screen to confirm correctness
- Confirming absence of unexpected on-screen errors/warnings during use

Flipper Zero does expose a serial CLI (used for things like `device_info`,
storage listing, and a handful of other commands), but this project has not
verified or built support for using it as a general "press this input, read
this screen region" automation interface for arbitrary already-running apps.
Building and validating such a harness (if it's even fully possible with
Flipper's existing firmware APIs, without adding new instrumentation to the
5 apps themselves) would be a substantial project of its own, out of scope for
Phase 2A/2A.5, and is not attempted here.

## Why app launch/navigation may require either hardware observation or a future test harness

Two honest paths exist to eventually automate GUI-level checks, neither
implemented yet:

1. **Hardware observation, permanently**: accept that menu/navigation/display
   correctness is inherently a human-in-the-loop check for a device with this
   form factor, and keep using
   `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` for it indefinitely. This is
   the only path this project currently relies on.
2. **A future in-firmware or RPC test harness**: a dedicated instrumentation
   layer (e.g. a debug build that logs scene transitions over serial, or a
   screen-capture/RPC bridge) could in principle make some of this scriptable.
   This does not exist today, has not been designed, and is explicitly **not**
   part of this phase — building it would itself be a new feature requiring
   its own review, and is not implied or promised by anything in this
   document.

## Why release-ready is still not claimed

Automated validation, even a fully green `AUTOMATED VALIDATION PASS` across
Static and Build modes, only proves the repository and the compiled artifacts
are in the state this tooling knows how to check. It does not, and cannot by
itself, prove:

- Real hardware boots and runs the firmware correctly
- Any app is usable, correct, or crash-free in practice
- The project's full release-gate checklist (which covers more than Phase 2A
  alone) has been satisfied

Release-readiness requires human-observed hardware testing (the smoke test)
plus that broader checklist — neither of which this tooling performs or
substitutes for. **Release status remains TEST-READY ONLY / NOT
RELEASE-READY**, and **hardware flashing/testing remains NOT PERFORMED**,
regardless of what this validation tooling reports, until a human actually
runs the hardware-assisted checks and reports real results.

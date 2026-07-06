# Known Issues

## Environment / process (not firmware defects)

1. **RESOLVED — vendor toolchain unreachable from the cloud build environment.**
   Unleashed's `fbt` downloads a pinned, patched ARM GCC 12.3 toolchain from
   `update.flipperzero.one`; the cloud session's network egress policy returned HTTP
   403 for that host (policy denial, confirmed via the proxy status endpoint). This is
   resolved by building locally instead: a local Windows 11 build using the real
   pinned toolchain via `.\fbt.cmd` completed successfully — see `BUILD_LOG.md` and
   `LOCAL_WINDOWS_BUILD_HANDOFF.md` §7. This item no longer blocks anything; kept here
   for the historical record and because the cloud sandbox itself is still blocked
   (relevant again only if a future cloud-only build is attempted).
2. **RESOLVED (was: substituted toolchain).** The cloud session's substitute toolchain
   experiment (Ubuntu `gcc-arm-none-eabi` 13.2 + pip Python/SCons, with two local
   `-Wno-error=` flags in a throwaway `/tmp` clone) is superseded by item 1 above and
   was never part of this repository's history — see `BUILD_LOG.md` for the full
   record, kept for its diagnostic value only.
3. **No physical Flipper Zero exists in the cloud AI session's environment.** Boot,
   flashing, app loader, and hardware-interaction testing described in the project's
   QA phases have not been performed by any AI session and cannot be performed by one.
   The project owner has a local Windows machine and could perform real hardware
   testing there; none has been done yet — the local build pass so far was build-only,
   by explicit instruction (no flashing).

## Firmware / content (resolved item)

4. **RESOLVED — `chess`'s bundled SAM text-to-speech component had no valid
   open-source license.** `applications_user/chess/sam/stm32_sam.{h,cpp}` (Phase 2A,
   `integration/phase2a-first-batch`) was a port of `s-macke/SAM`, whose own README
   explicitly states the code is reverse-engineered 1980s "abandonware" from a
   defunct company, with no rights holder able to grant a license — only a
   speculative "might qualify as Fair Use" claim, not a license grant. Full
   investigation in `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`. Decision: **SAM LICENSE
   UNCLEAR / REMOVE SAM VOICE FEATURE ENTIRELY** — implemented in commit `6359f87`:
   `sam/stm32_sam.{h,cpp}` and `helpers/flipchess_voice.{cpp,h}` were deleted from
   the repository outright (not merely gated out of the build), all call sites
   removed, confirmed by a full grep sweep showing zero remaining
   `sam`/`voice`/`speech` references anywhere in `chess`. The removal was never a
   safety/hardware-capability issue (the component had no radio/GPIO/HID access) —
   it was a distribution/compliance issue, and it is now closed. **Build-confirmed**:
   the project owner's real local Windows build at commit
   `5e5e0ecf225be947a754e537670a6421838b939b` passed both `.\fbt.cmd COMPACT=1
   DEBUG=0` and `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`, with both artifacts
   present (`firmware.dfu` 862,825 bytes; updater `.tgz` 2,732,909 bytes). Full
   detail in `PHASE2A_BUILD_REPORT.md`. Hardware flashing/testing: **NOT
   PERFORMED** — release status remains **TEST-READY ONLY / NOT RELEASE-READY**.

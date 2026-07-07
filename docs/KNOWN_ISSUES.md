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
   **Phase 2A.6 update**: the new `tools/phase2a_validate.ps1 -Mode Build` was
   confirmed, in this same cloud sandbox, to be blocked for a second, more basic
   reason beyond the network policy above — `fbt.cmd` is a Windows batch file, and
   this sandbox is Linux, so it can't even be launched as a process here (separate
   from whether the toolchain download itself is reachable). Same category of
   environment limitation, not a new issue: a real Build-mode result from this
   tooling still requires the project owner's own Windows machine.
   **Phase 2C.2 update**: reconfirmed a third time against the 10-app Phase 2C
   batch (`sd_info`, `docviewlite` added) — same `BLOCKED` result, same reason.
   Real CI Build validation (GitHub Actions, `windows-latest`) passed instead;
   see `docs/PHASE2C_2_BUILD_REPORT.md`. Nothing new introduced by this update.
2. **RESOLVED (was: substituted toolchain).** The cloud session's substitute toolchain
   experiment (Ubuntu `gcc-arm-none-eabi` 13.2 + pip Python/SCons, with two local
   `-Wno-error=` flags in a throwaway `/tmp` clone) is superseded by item 1 above and
   was never part of this repository's history — see `BUILD_LOG.md` for the full
   record, kept for its diagnostic value only.
3. **OPEN — no physical Flipper Zero and no Windows machine exist in the cloud AI
   session's environment.** Boot, flashing, app loader, and hardware-interaction
   testing described in the project's QA phases have not been performed by any AI
   session and cannot be performed by one. The project owner has a local Windows
   machine and could perform real hardware testing there; none has been done yet —
   the local build pass so far was build-only, by explicit instruction (no
   flashing). **Phase 2A.12 update**: `tools/phase2a_hardware_gate.ps1` now exists
   and automates the non-GUI preconditions for hardware-assisted validation
   (artifact hash verification, device detection, tooling detection, a
   flash-confirmation gate), but it was only exercised in this same cloud sandbox,
   where `Get-PnpDevice` itself is unavailable (Linux, not Windows) and no device
   is attached — see `docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md`. The underlying
   limitation is unchanged: this item stays open until run for real on a Windows
   machine with a physical device attached. **Phase 2B.4 update**:
   `tools/phase2b_hardware_gate.ps1` extends the same gate to the full 8-app Phase
   2B baseline; also only exercised in this same cloud sandbox, same result
   (`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`) for the same reason —
   see `docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md`. Still open for the same
   underlying reason; nothing new introduced by this update. **Phase 2C.4
   update**: `tools/phase2c_hardware_gate.ps1` extends the same gate to the
   full 10-app Phase 2C baseline; also only exercised in this same cloud
   sandbox, same result (`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`)
   for the same reason — see `docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md`.
   This phase also fixed a separate, minor tooling limitation carried over
   from Phase 2A's/2B's own hardware-gate scripts (second-granularity
   report filenames could collide on rapid repeated invocations, though
   this was never itself a tracked item here) — the Phase 2C script now
   uses a millisecond-precision timestamp plus a random suffix, verified
   collision-free under a deliberate rapid-invocation test. Still open for
   the same underlying device/Windows-machine reason; nothing else new
   introduced by this update.
5. **RESOLVED — cloud sandbox cannot download GitHub Actions artifacts or push git
   tags.** Two separate, confirmed network/policy restrictions were hit during
   Phase 2A.10: (a) GitHub Actions artifact downloads always redirect to Azure Blob
   Storage (`*.blob.core.windows.net`), blocked by this session's egress policy;
   (b) pushing git tags through this session's own git relay returned a `403`.
   **Resolved in Phase 2A.11** by moving both operations into a GitHub Actions
   workflow (`.github/workflows/phase2a-finalize-baseline.yml`) that runs entirely
   on GitHub's own Windows infrastructure using its own `GITHUB_TOKEN` — it
   downloaded the real CI artifacts, computed real SHA-256 hashes, and pushed both
   baseline tags successfully (run
   [`28859929957`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28859929957)).
   See `docs/PHASE2A_ARTIFACT_HASHES.md` for the real, generated hash values. Kept
   here for the historical record; no longer blocks anything.

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
6. **OPEN — `fcc_id_lookup` (Phase 2C candidate, not imported) has no `LICENSE`
   file in the exact RogueMaster-vendored source this project cites.** Phase
   2C.1's real source read of `applications/external/fcc_id_lookup/` at commit
   `472f6925e8aca9bd031cb37e3cb80b551772c957` found no `LICENSE` file, no SPDX
   identifier, and no copyright header anywhere in its source. Strong
   corroborating evidence (a real, confirmed MIT license, Copyright (c) 2026
   lsr, found directly at the exact upstream repository this app's own
   `fap_weburl` field names, `github.com/lrehmann/fcc-id-lookup-flipper`,
   same author, near-identical code) exists, but is not commit-pinned to the
   specific historical revision RogueMaster vendored. Full detail in
   `PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`. **This is a materially
   lower-severity issue than item 4 above** (`chess`'s SAM component) — no
   unresolved copyright dispute, no commercial content, no capability
   concern — with a clear, low-effort resolution path: include the confirmed
   upstream `LICENSE` file at actual import time. **This app has not been
   imported** (per `docs/PHASE2C_1_GO_NO_GO.md`, it is deferred, not part of
   the current 2-app cleared batch) and stays open until that specific
   license confirmation happens.
   **Phase 2C.2 update**: `sd_info` and `docviewlite` were imported for
   real in Phase 2C.2 (see `docs/PHASE2C_2_GO_NO_GO.md`); `fcc_id_lookup`
   was correctly **not** imported and no substitute app was added. This
   item remains open, unaffected by that import, until its own dedicated
   license-confirmation follow-up happens.

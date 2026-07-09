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
   introduced by this update. **Phase 2D.4 update**:
   `tools/phase2d_hardware_gate.ps1` extends the same gate to the full
   13-app Phase 2D baseline (adding `resistors`, `crypto_dictionary`, and
   `2048`-specific storage checks); also only exercised in this same cloud
   sandbox, same result (`HARDWARE VALIDATION BLOCKED - DEVICE NOT
   AVAILABLE`) for the same reason — see
   `docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md`. This update additionally
   attempted a real artifact download via the GitHub API (a valid signed
   Azure Blob Storage URL was obtained for the accepted CI run's firmware
   artifact), which confirmed the same egress block tracked in item 5
   below still applies to this session — a synthetic hash-mismatch test
   was run instead, clearly labeled as not real artifact verification.
   Still open for the same underlying device/Windows-machine reason;
   nothing else new introduced by this update. **Phase 2E.4 update**:
   `tools/phase2e_hardware_gate.ps1` extends the same gate to the full
   16-app Phase 2E baseline (adding `image_viewer`, `boilerplate`, and
   `minesweeper`-specific storage checks, plus a new automated check
   confirming `applications_user/image_viewer/example_images/` remains
   absent); also only exercised in this same cloud sandbox, same result
   (`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`) for the same
   reason — see `docs/PHASE2E_HARDWARE_ASSISTED_RESULTS.md`. The real
   Phase 2E CI artifacts (run `28968511276`) again could not be
   downloaded due to the same Azure Blob Storage egress block tracked in
   item 5 below; a synthetic hash-mismatch test was run instead, clearly
   labeled as not real artifact verification. The collision-resistant
   report-filename fix (Phase 2C.4) was re-confirmed via a 5-way
   simultaneous invocation stress test producing 10 distinct report files
   with zero overwrites — no collision regression introduced. The
   `image_viewer/example_images/` absence check passed in every run this
   phase; the excluded directory was not reintroduced. Still open for the
   same underlying device/Windows-machine reason; nothing else new
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
   license-confirmation follow-up happens. **Phase 2D planning update**:
   `fcc_id_lookup` was explicitly excluded from Phase 2D candidate
   consideration per the project owner's own instruction, not
   re-reviewed, and not part of the recommended Phase 2D batch (see
   `docs/PHASE2D_CANDIDATE_REVIEW.md`). Still open, unaffected by this
   planning phase, until its own dedicated license-confirmation
   follow-up happens. **Phase 2D.1 update**: `fcc_id_lookup` was again
   explicitly excluded from Phase 2D.1's pre-import verification pass, per
   the project owner's own instruction not to import or re-review it in
   that phase (see `docs/PHASE2D_1_GO_NO_GO.md`). Not touched, not
   re-reviewed, not resolved by that pass. Still open until its own
   dedicated license-confirmation follow-up happens. **Phase 2D.2
   update**: `fcc_id_lookup` was again not imported and not re-reviewed
   during Phase 2D.2's actual import of `resistors`/`crypto_dictionary`/
   `2048` (see `docs/PHASE2D_2_GO_NO_GO.md`). Still open, unaffected.
7. **REOPENED as of Phase 2F.2 (was: RESOLVED as of Phase 2D.3) — the
   `updater_package` `fbt.cmd` build target's failure has recurred,
   reproducibly, on the 19-app Phase 2F batch.** Phase 2D.2's real CI validation
   (`.github/workflows/phase2d-windows-validation.yml`) ran 3 times
   total: the first attempt (run `28905289140`) passed cleanly in full,
   including the updater `.tgz` (2,783,994 bytes). The second attempt
   (run `28906654889`, at a commit that only changed an unrelated
   artifact-upload workflow step) failed with the firmware build and all
   13 `.fap` outputs still succeeding, but the separate `updater_package`
   invocation of `fbt.cmd` failing to launch as a process at all
   ("fbt.cmd could not be launched as a process on this machine/OS"). A
   `rerun_failed_jobs` re-run on a **different** GitHub-hosted runner
   instance reproduced the identical failure at the identical step, for
   the identical commit — ruling out a one-off single-runner flake.
   Full per-attempt detail in `docs/PHASE2D_2_BUILD_REPORT.md`. **This is
   not evidence of a defect in `resistors`, `crypto_dictionary`, or
   `2048`'s own source** — none of the 3 apps' source changed between the
   passing and failing attempts, and the firmware itself (plus all 13
   `.fap` outputs, including the 3 new apps) continued to build correctly
   on every attempt. The most likely explanation, based on available
   evidence, is a Windows-runner-level resource constraint (e.g. disk
   space or process contention from running two full `fbt.cmd`
   invocations back-to-back against a now-13-app batch, larger than
   Phase 2C's 10-app batch) — but this cannot be confirmed further from
   this session, since GitHub Actions artifact-log downloads redirect to
   Azure Blob Storage, which remains blocked by this session's egress
   policy (the same limitation as item 5 above, before its Phase 2A.11
   resolution route — that workaround moved the *download* into a GitHub
   Actions workflow using the runner's own token, but does not help
   diagnose a failure *within* that same kind of workflow run).
   **Phase 2D.2A resolution**: a 4th real CI attempt (`28925181640`, at
   a docs-only commit, no script change) passed in full using the exact
   same unmodified script that had just failed twice — proving the
   failure was intermittent (2 of 4 pre-fix attempts passed, ~50%), not
   deterministic. Applied a narrow fix scoped to the `updater_package`
   call site only in `tools/phase2a_validate.ps1`: added non-secret
   diagnostics (disk space, `fbt.cmd` metadata, PowerShell/OS version,
   Windows Defender status, PATH) and switched the launch mechanism from
   PowerShell's `&` call operator to an explicit `cmd /c` wrapper — same
   build target, same arguments, same pass/fail logic. Confirmed via 2 of
   2 real, independent post-fix CI attempts (run `28938933924`, attempts
   1 and 2, the second via `rerun_workflow_run` on a different runner
   instance): both passed in full, `updater_package` PASS, all 13 `.fap`
   outputs present, `.fap` artifact upload working. See
   `docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md` and
   `docs/PHASE2D_2A_CI_REMEDIATION_LOG.md` for full detail. No app source
   or firmware/core source changed at any point in this investigation.
   This is reported as resolved-with-a-caveat, not a triumphant
   certainty: 2 post-fix passes cannot statistically prove the fix is
   what caused the improvement, given the pre-fix ~50% base rate — but
   the fix itself is real, narrow, safe, and twice-verified. Per the
   updated `docs/PHASE2D_2_GO_NO_GO.md`, Phase 2D.3 (CI baseline
   acceptance) is now an allowed next step, pending the project owner's
   own explicit request. **Phase 2D.3 update**: a 3rd real, independent
   post-fix CI attempt (run `28941093859`, at the actual current branch
   HEAD, on a 3rd different runner instance) also passed in full —
   `updater_package` PASS, updater `.tgz` 2,783,170 bytes, all 13 `.fap`
   outputs present. This run is the one Phase 2D.3's acceptance record
   and finalize-baseline workflow are built against. Item remained
   RESOLVED through Phase 2D.4, Phase 2E planning/2E.1/2E.2/2E.3/2E.4,
   and Phase 2F planning/2F.1; the two pre-fix Phase 2D failures remain
   preserved, never erased, in
   `docs/PHASE2D_2A_UPDATER_PACKAGE_BLOCKER_ANALYSIS.md`.
   **Phase 2F.2 update — REOPENED**: real CI validation of the 19-app
   Phase 2F batch (run `28979764650`) ran twice, on two independent
   GitHub-hosted Windows runner instances (confirmed by differing
   `fbt.cmd` file timestamps and volume serial numbers). **Both attempts
   failed identically**: Static PASS, firmware build PASS (862,825
   bytes both times, unchanged from the accepted Phase 2E baseline
   size), but `updater_package` failed to launch as a process on both
   attempts, with byte-identical error text
   ("fbt.cmd could not be launched as a process on this machine/OS") to
   the original Phase 2D.2 pre-fix failures. `build\f7-firmware-C\.extapps`
   was confirmed empty of all 19 expected `.fap` files on both attempts
   — a detail not previously confirmed one way or the other during the
   original Phase 2D.2/2D.2A investigation, since that diagnostic
   logging did not exist early enough in that investigation to check it.
   The `.fap`-artifact upload step still produced a non-empty,
   identically-sized (115,177 bytes) but differently-hashed artifact on
   both attempts — contents not independently verified, since
   downloading it hit the same Azure Blob Storage egress block as every
   prior phase's own artifact-download attempts. **0 of 2 real Phase
   2F.2 CI attempts passed** — a materially worse rate than the ~50%
   (2 of 4) pre-fix rate observed in Phase 2D.2, though the sample size
   here (2) is too small to establish a new base rate with confidence.
   **Not evidence of a defect in `qrcode`, `hex_viewer`, or
   `barcode_gen`'s own source** — no compile error or app-specific
   failure text appears anywhere in either attempt's log, and the
   firmware itself built correctly both times. Full detail in
   `docs/PHASE2F_2_BUILD_REPORT.md` and `docs/PHASE2F_2_GO_NO_GO.md`. A
   narrow Phase 2F.2A remediation plan (more CI attempts to establish a
   real base rate, direct build-log inspection, a diagnostic step
   listing `build\f7-firmware-C\` contents right after the firmware
   build, and direct inspection of the anomalous `.fap`-artifact
   contents) is proposed in `docs/PHASE2F_2_GO_NO_GO.md` but **not
   implemented** — pending the project owner's own explicit further
   request. Phase 2F.2 does not pass, and Phase 2F.3 does not start,
   until this item is resolved again.

# Phase 2F.2A — Diagnostic Log

Docs only. Chronological record of every diagnostic/remediation change
made in Phase 2F.2A, the exact files changed, every real CI run ID
dispatched, and what each run's evidence showed. See
`docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` for the narrative root-cause
analysis this log supports.

## Change / run sequence

| # | Commit | File(s) changed | Change | CI run ID | Result |
|---|---|---|---|---|---|
| 1 | `224a9b0` | `tools/phase2a_validate.ps1` | Added pre-firmware-build diagnostics, expanded PSVersionTable/process-image dump, FAP-search diagnostics (build-scoped + repo-wide + named-app checks + upload-glob check), console-visible launch-exception text (`Write-Host`) for both firmware-build and `updater_package` catch blocks | `29003000398` | **Crashed before `updater_package`** — self-inflicted `PropertyNotFoundException` in new FAP-search code. Firmware build itself confirmed PASS (exit 0) for the first time with full diagnostic visibility. |
| 2 | `0260ca6` | `tools/phase2a_validate.ps1` | Fixed the crash: wrapped `if(){@(...)}else{@()}` FAP-search assignments in an outer `@(...)` (root cause: inner `@()` alone does not survive being returned through an `if`-expression when the taken branch produces zero pipeline output — reproduced locally in an isolated pwsh script) | `29003824450` | **Got past the crash.** Revealed the real root cause: `LAUNCH EXCEPTION ... System.Management.Automation.RemoteException: applications_user\barcode_gen\views\create_view.c: In function 'text_input_callback':` — not a process-launch failure. `PowerShell edition: Desktop` confirmed (despite `shell: pwsh`). 0/19 FAPs found anywhere in the repo. |
| 3 | `8e5f78f` | `tools/phase2a_validate.ps1` | Scoped `$ErrorActionPreference = 'Continue'` around just the `updater_package` `cmd /c` invocation (restored via `finally`); `$LASTEXITCODE` remains authoritative | `29004603660` | **Fix confirmed working.** No more launch exception. Real result: `fbt.cmd launched and exited 2` — a genuine build failure now surfaced instead of a tooling abort. |
| 4 | `d1a2de7` | `tools/phase2a_validate.ps1` | Added a diagnostic to print the last 150 lines of the `updater_package` build log directly to console | `29005529368` | **Revealed the real compiler error**: `create_view.c:165:5: error: implicit declaration of function 'text_input_show_illegal_symbols' [-Werror=implicit-function-declaration]`. `findmy.fap`/`hid_usb.fap`/`hid_ble.fap`/`mfkey.fap`/`2048_improved.fap` all built successfully before `scons` stopped on this error. |
| 5 | `b6445ed` | `applications_user/barcode_gen/views/create_view.c` | Removed 5 dead call sites to `text_input_show_illegal_symbols()` (2 were accidental upstream duplicate calls) — a function from an unwired custom-keyboard fork, never valid for the app's real (system) `TextInput` instance. Explicitly approved by the user via `AskUserQuestion` after presenting the evidence. | `29013915792` | **Build fully PASSED**: `updater_package` PASS exit 0, `firmware.dfu` PASS, updater `.tgz` PASS, **Per-app FAP output verification PASS** (all 19). Static regressed to `NEEDS_REVIEW` — 1 previously-reviewed match's line number shifted (348 → 341) from the 7-line removal. |
| 6 | `78914b3` | `tools/phase2f_validate_config.json` | Updated the `reviewedFalsePositives` entry for the `create_view.c` "Unable" match from line 348 to line 341; content hash unchanged (recomputed locally: `4015651920f2ad319eac8c64e7adad90f6941ed2fdbad3402a8a4d94e8171c11`, byte-identical to the original review) | `29015213503` | **First full pass**: `Static: PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build: PASS`, `Overall: AUTOMATED VALIDATION PASS`. `firmware.dfu` 862,825 bytes. Updater `.tgz` 2,877,979 bytes. All 19 FAPs found. |
| 7 | (same as #6, `78914b3`) | — | Second independent dispatch, same commit, distinct runner instance, to satisfy the 2-independent-passes requirement | `29015788839` | **Second full pass, confirming #6**: identical classification. `firmware.dfu` 862,825 bytes (identical). Updater `.tgz` 2,878,003 bytes (24-byte difference — expected, embedded build metadata). All 19 FAPs found. |

## FAP-search evidence progression

| Run | `.extapps` exists (pre-build check) | `.fap` files found anywhere in repo (post-firmware-build, pre-`updater_package`) | Per-app FAP verification (post-`updater_package`) |
|---|---|---|---|
| `28979764650` (both attempts, pre-Phase-2F.2A) | False | Not checked (diagnostic didn't exist yet) | FAIL — 0/19 |
| `29003824450` | False | **0** (repo-wide search); `qrcode.fap`/`hex_viewer.fap`/`barcode_app.fap` all explicitly `NOT FOUND` | Not reached (launch exception) |
| `29004603660` | False | 0 | FAIL — 0/19 (real exit-code-2 failure, not launch abort) |
| `29005529368` | False | 0 | FAIL — 0/19 (real compile error surfaced) |
| `29013915792` | False (pre-build check always runs before the build) | 0 (same pre-build checkpoint) | **PASS — 19/19** (post-build, after the barcode_gen fix) |
| `29015213503` | False (pre-build checkpoint) | 0 (pre-build checkpoint) | **PASS — 19/19** |
| `29015788839` | False (pre-build checkpoint) | 0 (pre-build checkpoint) | **PASS — 19/19** |

Note: the "`.extapps` exists: False" / "0 .fap files found" lines are a
**pre-firmware-build diagnostic checkpoint** that always runs before any
build attempt in a given job, by design (to record the clean starting
state) — this is expected and does not indicate a problem; the real
signal is the **post-`updater_package` "Per-app FAP output verification"**
result, which is what changed from FAIL to PASS across this
investigation.

## `updater_package` invocation evidence

- Confirmed **still** using the Phase 2D.2A `cmd /c` launch wrapper
  (`cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0 updater_package" *> $updaterLogPath`)
  throughout Phase 2F.2A — never reverted, never needed further
  mechanism changes. The actual defect was the surrounding
  `$ErrorActionPreference` handling, not the launch mechanism itself.
- Real exception type across the whole investigation, first captured in
  run `29003824450`: `System.Management.Automation.RemoteException`,
  wrapping native stderr text — never an `ApplicationFailedException` or
  any other genuine process-launch-failure exception type. This
  retroactively means the original "fbt.cmd could not be launched as a
  process on this machine/OS" classification recorded for the 2 original
  Phase 2F.2 failures (and, by extension, the similar-sounding Phase
  2D.2A findings) most likely described the same underlying
  stderr-escalation mechanism, not a literal inability to start the
  process — though the 2 original Phase 2F.2 attempts' own raw exception
  text was never recovered (their log files remain undownloadable), so
  this is stated as a strong inference from the mechanism now proven,
  not as directly re-confirmed evidence for those 2 specific runs.

## Artifact-upload evidence

- The original `phase2f-fap-artifacts` 115,177-byte anomaly (non-empty
  artifact despite 0/19 named FAPs found, on both original attempts) was
  **not independently re-investigated** in Phase 2F.2A — artifact
  downloads remained blocked by the same Azure Blob Storage egress
  restriction (`CONNECT tunnel failed, response 403`) every attempt this
  entire project has made has hit. This remains an open, unexplained
  detail from the original 2 failures specifically; it does not affect
  the Phase 2F.2A resolution, since the 2 final confirming runs' own
  `.fap` artifact uploads now contain the real, verified 19 FAP files
  (confirmed via the "Per-app FAP output verification: PASS" check
  reading the same `.extapps` directory the upload step globs).

## Final diagnostic interpretation

Two independent, real defects compounded to produce the original
blockage:

1. **CI/tooling**: Windows PowerShell's native-command stderr handling,
   combined with `$ErrorActionPreference = 'Stop'`, escalated an ordinary
   compiler diagnostic line to a terminating exception, hiding every
   subsequent line of real build output (including the actual error) and
   misclassifying the result as an environment/launch problem for the
   entire history of this failure class in this project.
2. **App source**: `barcode_gen`'s `create_view.c` called a function
   (`text_input_show_illegal_symbols`) belonging to an alternate,
   never-wired-in custom keyboard implementation bundled in the same app
   directory — a real, if narrow, upstream defect that had never
   compiled under this project's toolchain (which treats
   implicit-function-declaration as a hard error), independent of the CI
   tooling issue.

Fixing only the tooling issue would have surfaced the compile error
without resolving it; fixing only the source issue would never have been
discovered, since the tooling bug prevented the real error from ever
being seen. Both were required, in the order they were found, and both
are now confirmed resolved by 2 independent full-pass CI runs.

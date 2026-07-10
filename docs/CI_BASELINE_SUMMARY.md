# CI Baseline Summary — Full 7-Milestone Consolidation

Docs-only. Consolidates real GitHub Actions CI results across all 7
accepted milestones. Every run ID, commit SHA, and hash below is drawn
from each phase's own `ACCEPTANCE_RECORD.md`/`ARTIFACT_HASHES.md`/
`ARTIFACT_MANIFEST.md`/`GO_NO_GO.md` documents — none is fabricated or
estimated.

## Final accepted baseline

| Field | Value |
|---|---|
| Accepted branch | `integration/fcc-id-lookup-one-app-import` |
| Accepted commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` (`8626572`) |
| Accepted CI run | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) |
| Finalization run | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) |
| `firmware.dfu` | 862,833 bytes, SHA-256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` |
| `flipper-z-f7-update-local.tgz` | 2,891,859 bytes, SHA-256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` |
| Custom app count | 20/20 confirmed present |
| Static validation | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| Build validation | `PASS` (firmware, `updater_package`, all 20 `.fap` outputs) |
| Classification | **NON-HARDWARE CI BASELINE ACCEPTED** |

## Per-milestone CI run history

| Milestone | Accepted CI run | Finalization run | Accepted commit | firmware.dfu (bytes / SHA-256) | Updater .tgz (bytes / SHA-256) | Apps | Static result |
|---|---|---|---|---|---|---|---|
| Phase 2A | [`28814008347`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347) | [`28859929957`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28859929957) | `718eec5fe115c9e0467a8d07d974947a85b27cf6` | 862,825 / `7c74895107eb5c98c7241ea0d55565ed5e3931ce6f8e7137adba9dc77c0fdfe2` | 2,733,074 / `8f1afbd81c603104f94aaa72d89b1bf6185c7cb9103b352748b7b3a4305e3d52` | 5 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| Phase 2B | [`28877810474`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474) | [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603) | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` | 862,825 / `f74cf3be4b7d9e7fe87a08aec3f77a55982d0d6fcd08c61d46cc84a3237a3e75` | 2,742,659 / `6be763ec646c30261ccd943dd6c71f2cde3525b87c468eb574db67d7d840b9d7` | 8 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (110 matches) |
| Phase 2C | [`28897702247`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28897702247) | [`28899393035`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28899393035) | `969054ee9f802f72be1064a62052c4be82a91783` | 862,825 / `236ea92dfa826fe2459df3413e18952e0807775ed1f5c65737581e5c5c1934e8` | 2,757,340 / `d2fd4847830c311b487457e29f3ca285b009b2ca6735257739a4198711157632` | 10 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (139 matches) |
| Phase 2D | [`28941093859`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28941093859) | [`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724) | `d0812638a02c50389b9e713ad98f2c8215b75dd5` | 862,825 / `4f3703a8778543257759f367bc02f50d440ef85d21da05b630f705564084b6a8` | 2,783,170 / `3e015f6c0b303536fab14e4a8b85233b8c439c0f642087cb92f3781bf1b16c49` | 13 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (189 matches) |
| Phase 2E | [`28968511276`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28968511276) | [`28972160432`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28972160432) | `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` | 862,825 / `e7068bf952a12051e668bdc40db6823c41ff55659f5410977361d2aea9f1ffce` | 2,831,378 / `16b35fcc844abac5f6bfeded6b8f79d5066a0411ac7c1f128aa6406251aee5c3` | 16 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (373 matches) |
| Phase 2F | [`29017861599`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29017861599) | [`29027115867`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29027115867) | `37d11cada5a83afdeb752c6b2106216d7fc09b9f` | 862,825 / `27f60598d43657710207510520159ba6626722a2825ed8adf5768d002a3a005b` | 2,878,428 / `341fa331625c488ff8c6bf079ed0c82b553ef1a11441687a81139464f3f91772` | 19 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (464 matches) |
| fcc_id_lookup | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` | 862,833 / `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` | 2,891,859 / `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` | 20 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (475 matches total, 11 new) |

Note: each milestone's accepted CI run is the run independently
confirmed to be at the true current branch HEAD at finalization time —
several milestones (Phase 2D, 2E, 2F, and `fcc_id_lookup`) had an
earlier CI run superseded by a later one after a subsequent docs commit
moved HEAD forward; the table above lists only the final accepted run
for each milestone, per this project's standing baseline-selection
rule. `fcc_id_lookup`.fap grew from 862,833/2,891,283 bytes at its
first real CI pass (run `29067243595`) to 2,891,859 bytes at the
accepted run (`29068148596`) — both are genuine CI artifacts, the
accepted run superseding the earlier one under that same rule.

## FAP verification summary

Every milestone's validator (`tools/phase2a_validate.ps1`) performs a
per-app FAP-output check against that milestone's `expectedApps` list —
not merely an aggregate file count. All milestones confirm 100% of
expected `.fap` files present:

| Milestone | Expected custom FAPs | Found |
|---|---|---|
| 2A | 5 | 5/5 |
| 2B | 8 | 8/8 |
| 2C | 10 | 10/10 |
| 2D | 13 | 13/13 |
| 2E | 16 | 16/16 |
| 2F | 19 | 19/19 |
| fcc_id_lookup | 20 | 20/20 (including `fcc_id_lookup.fap`, 20,196 bytes, SHA-256 `168025ddcffb01f94e1af8eefcead2ac80d69f6b7ad9856a603e1a7d30317658`) |

## `updater_package` CI tooling history

Two distinct real defects were found and fixed across the project's CI
history, both fully documented with real CI run evidence:

### Phase 2D.2A — intermittent `updater_package` remediation

**Symptom**: `updater_package` intermittently failed with a generic
`BLOCKED — fbt.cmd could not be launched as a process on this machine/OS`
on 2 of 4 real pre-fix CI attempts (run `28906654889`, both its
original execution and its rerun, on two different runner instances,
same commit `e01370d`). The firmware build itself and all 13 `.fap`
outputs never failed — 6-for-6 across the whole investigation.

**Root cause**: Not definitively proven — classified as the most likely
hypothesis, not a confirmed fact: intermittent Windows-runner-level
resource/timing variance when launching a second `fbt.cmd` invocation
immediately after a heavy first one, in the same CI job.

**Fix applied** (scoped to `tools/phase2a_validate.ps1`'s
`updater_package` call site only): added non-secret pre-flight
diagnostics, and changed the launch mechanism from PowerShell's `&`
call operator to an explicit `cmd /c ".\fbt.cmd COMPACT=1 DEBUG=0
updater_package"` wrapper — same build target/arguments/exit-code
logic, only the process-launch mechanism changed.

**Result**: confirmed by 2 consecutive independent post-fix CI passes
(run `28938933924`, both attempts). Classified "RESOLVED WITH
INTERMITTENT PRE-FIX FAILURE NOTE" — not claimed as statistically
proven causal, only that the fix is real, narrow, and CI-confirmed.

### Phase 2F.2A — stderr-handling/tooling fix (plus a real app-source fix)

**Symptom**: `updater_package` failed identically on 2 consecutive real
CI attempts in Phase 2F.2 (run `28979764650`, both attempts, different
runner instances, same commit `e5d2905`) with the same generic
"could not be launched as a process" text.

**Root cause** (identified via a 7-step real-CI investigation,
runs `29003000398` through `29015788839`): under Windows PowerShell's
`$ErrorActionPreference = 'Stop'`, a native command's routine stderr
output (an ordinary GCC compiler diagnostic line) was being escalated
into a terminating exception, aborting the whole `updater_package`
invocation before it could finish or emit the real underlying error —
regardless of whether that stderr line was fatal or not.

**Fix applied**: scoped `$ErrorActionPreference = 'Continue'` around
just the `updater_package` `cmd /c` invocation (restored via `finally`),
relying on `$LASTEXITCODE` as the authoritative signal, matching the
pattern already used at the firmware-build call site (commit `8e5f78f`,
run `29004603660`).

**Real app-source defect this uncovered**: once the tooling fix let the
real compiler error surface, it read:
`applications_user\barcode_gen\views\create_view.c:165:5: error:
implicit declaration of function 'text_input_show_illegal_symbols'`.
`create_view.c` was calling a function belonging only to `barcode_gen`'s
own bundled, never-wired-in custom keyboard fork; the app's actual
`text_input` widget is the **system** `TextInput` module, which has no
such function. Fixed by removing the 5 dead call sites (2 were
accidental upstream duplicate calls), commit `b6445ed`, explicitly
user-approved via `AskUserQuestion` before any source was touched.

**Result**: confirmed by 2 independent full-pass CI runs
(`29015213503`, `29015788839`), both `Static:
PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build: PASS`, all 19 `.fap`
outputs present including `qrcode.fap`/`hex_viewer.fap`/
`barcode_app.fap`. Classified "RESOLVED."

### `fcc_id_lookup` baseline — final pass

The accepted `fcc_id_lookup` CI run (`29068148596`) and its
finalization run (`29096377711`) both completed cleanly with no
`updater_package` anomaly of any kind — the two tooling fixes above
remained stable through this milestone with no further remediation
required.

## Final CI classification

**NON-HARDWARE CI BASELINE ACCEPTED.**

All 7 milestones independently CI-validated on real GitHub-hosted
`windows-latest` runners, all 12 baseline tags independently re-verified
via `git ls-remote --tags origin` during this audit with zero drift from
their recorded targets, zero unresolved `updater_package`/build-tooling
defect remaining. No hardware-assisted validation has been performed at
any milestone.

# Phase 2F.2 — Go / No-Go

Docs only. This is the closing decision document for Phase 2F.2 —
implementation/import of the cleared Phase 2F tiny batch.

## Final classification: **PHASE 2F.2 IMPORT PASS WITH CI TOOLING + APP SOURCE REMEDIATION**

All 3 cleared apps (`qrcode`, `hex_viewer`, `barcode_gen`) were imported
one at a time, each preserving full provenance and license text, each
statically clean. The 19-app batch's firmware build passed consistently
from the very first real CI attempt. The separate `updater_package`
build sub-step initially **failed to launch as a process on 2 of 2 real
CI attempts**, reproduced identically on two different GitHub-hosted
runner instances for the same commit, with the per-app `.fap` output
directory confirmed to contain none of the 19 expected named files on
either attempt — this was investigated in full in **Phase 2F.2A** (see
`docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
`docs/PHASE2F_2A_DIAGNOSTIC_LOG.md`), which found and fixed **two real,
distinct defects**: (1) a CI/tooling defect in the shared validator
script (Windows PowerShell escalating a routine compiler stderr line to
a terminating exception under `$ErrorActionPreference = 'Stop'`,
misclassifying a real, unfinished build attempt as a process-launch
failure), and (2) a real app-source defect in `barcode_gen` (5 dead
calls to a function belonging to an unwired, never-integrated custom
keyboard fork bundled in the app, fixed with explicit user approval after
the evidence was presented). Both fixes are now confirmed by **2
independent, fully-passing real Windows CI runs** (`29015213503` and
`29015788839`): Static `PASS_WITH_REVIEWED_FALSE_POSITIVES`, Build
`PASS` (firmware, `updater_package`, and all 19 `.fap` outputs — including
`qrcode.fap`, `hex_viewer.fap`, `barcode_app.fap` — confirmed present on
both runs). Phase 2F.2 now genuinely passes.

## Imported apps

| App | License | Import commit | Static scan | Storage behavior | Firmware build | Updater package build | FAP output |
|---|---|---|---|---|---|---|---|
| `qrcode` | MIT (confirmed, full text; bundles a third-party MIT QR-encoding library, attributed) | `79f50cc` | Clean — 8 benign `ble`-substring false positives | Confirmed app-private/read-only, one-time benign legacy-folder migration | PASS | PASS (after Phase 2F.2A) | Present (after Phase 2F.2A) |
| `hex_viewer` | MIT (confirmed, full text) | `04715de` | Clean — 37 benign `ble`-substring false positives | Confirmed genuinely read-only for viewed files, app-private settings only | PASS | PASS (after Phase 2F.2A) | Present (after Phase 2F.2A) |
| `barcode_gen` | MIT (confirmed, full text; real appid `barcode_app`) | `2512644` | Clean — 46 benign `ble`-substring false positives (line renumbered in Phase 2F.2A, content unchanged) | Confirmed app-private storage only, bundled encoding tables confirmed standard technical data | PASS | PASS (after Phase 2F.2A source fix, commit `b6445ed`) | Present (after Phase 2F.2A) |

Plus infrastructure commits: `862fd8e` (validator config,
`tools/phase2f_validate_config.json`), `683137d` (CI workflow,
`.github/workflows/phase2f-windows-validation.yml`). Plus Phase 2F.2A
remediation commits: `0260ca6`, `8e5f78f`, `d1a2de7` (all
`tools/phase2a_validate.ps1`, CI/tooling diagnostics and fix), `b6445ed`
(`applications_user/barcode_gen/views/create_view.c`, app-source fix),
`78914b3` (`tools/phase2f_validate_config.json`, reviewed-false-positive
line-number update). See `docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` for the full
commit/run table.

## Skipped/deferred apps

- **`fcc_id_lookup`** — **not imported, not re-reviewed.** Remains
  deferred per `docs/PHASE2C_1_GO_NO_GO.md` on its own, separate,
  unrelated license-evidence gap. Not touched by this phase.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — none imported, none re-reviewed, per this phase's
  explicit hard exclusions.

## Code changed summary

- **Added**: `applications_user/qrcode/` (7 files), `applications_user/hex_viewer/`
  (26 files), `applications_user/barcode_gen/` (29 files), 6 exception
  lines in `applications_user/.gitignore` (one pair per app),
  `tools/phase2f_validate_config.json`,
  `.github/workflows/phase2f-windows-validation.yml`.
- **Changed in Phase 2F.2A** (see `docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` for
  the full commit table): `tools/phase2a_validate.ps1` (CI/tooling
  diagnostics + the `$ErrorActionPreference` fix — the shared validator
  script, same file every phase's CI-tooling fixes since Phase 2D.2A have
  touched), `tools/phase2f_validate_config.json` (1 reviewed-false-
  positive line-number update, content unchanged), and exactly **one**
  app-source file: `applications_user/barcode_gen/views/create_view.c`
  (5 dead lines removed, user-approved). No other `applications_user/`
  app was touched.
- **Not touched**: `applications/` (base firmware source), `build/`,
  `dist/`, `toolchain/`, any Phase 2A/2B/2C/2D/2E app directory, any
  firmware binary, any updater package, and every `barcode_gen` file
  other than `views/create_view.c`. No core firmware modification was
  made or needed — confirmed directly, since the firmware build itself
  succeeded unmodified across every real CI attempt in this entire
  investigation.
- **Not imported**: `applications_user/fcc_id_lookup/` does not exist on
  this branch. `image_viewer/example_images/` remains absent, untouched
  by this phase. `qrcode`'s `ss1.png`/`ss2.png`, `hex_viewer`'s
  `img/1.png`/`img/2.png`, and `barcode_gen`'s `img/`/`screenshots/`
  (README illustration images, not referenced by any manifest or source)
  were excluded for cleanliness only — confirmed absent by directory
  listing.

## Build/CI status

- **Local build**: `BUILD BLOCKED / ENVIRONMENT` — toolchain download
  blocked by this session's egress policy, the same root cause every
  prior phase has hit. Not faked as a pass. Unaffected by, and unrelated
  to, the Phase 2F.2A CI findings below.
- **Local static validation**: `PASS_WITH_REVIEWED_FALSE_POSITIVES` (464
  matches, all reviewed, zero unreviewed, zero high-confidence-unsafe;
  re-verified locally after the Phase 2F.2A source fix, with the 1
  affected reviewed-false-positive's line number corrected).
- **CI (real, GitHub Actions `windows-latest`) — original 2 attempts**:
  Static **PASS** on both. Firmware build **PASS** on both (862,825
  bytes, identical both times). `updater_package` build **BLOCKED** on
  both ("fbt.cmd could not be launched as a process on this machine/OS,"
  byte-identical error text). Per-app FAP output verification **FAIL**
  on both (0 of 19 expected files found). See
  `docs/PHASE2F_2_BUILD_REPORT.md` for full evidence.
- **CI — Phase 2F.2A resolution, 2 independent full passes**: run
  `29015213503` and run `29015788839`, both `Static:
  PASS_WITH_REVIEWED_FALSE_POSITIVES`, `Build: PASS`, `Overall:
  AUTOMATED VALIDATION PASS`. `updater_package` PASS exit 0 on both.
  `firmware.dfu` 862,825 bytes on both. Updater `.tgz` 2,877,979 /
  2,878,003 bytes respectively (expected minor variance from embedded
  build metadata). **All 19 `.fap` outputs confirmed present on both
  runs**, including `qrcode.fap`, `hex_viewer.fap`, `barcode_app.fap` by
  name. See `docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` and
  `docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` for the full root-cause evidence
  and commit/run sequence.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's or Phase 2F.2A's workflow or script changes. No device,
no flash, at any point across this entire investigation.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.** Build is now verified via 2
independent real CI passes; hardware validation has not been performed
for this batch, so release-readiness does not advance beyond
test-ready.

## Phase 2F.2A resolution summary

See `docs/PHASE2F_2A_CI_BLOCKER_ANALYSIS.md` (full narrative root-cause
analysis) and `docs/PHASE2F_2A_DIAGNOSTIC_LOG.md` (exact commit/run
table) for the complete investigation. In short: the original 2/2
identical failures were **not** an intermittent Windows-runner condition
of the kind Phase 2D.2A described — they were two compounding, real,
deterministic defects: (1) a CI/tooling defect in the shared validator
script that escalated a routine compiler stderr line into a terminating
exception, permanently hiding the real build error behind a
misleading "process could not be launched" classification, and (2) a
genuine app-source defect in `barcode_gen` (dead calls to an unwired
custom-keyboard-fork function). Both are now fixed and confirmed by 2
independent full-pass CI runs, satisfying this project's requirement of
2 independent post-remediation confirmations given the original 2/2
failure history.

## Next allowed gate

**Phase 2F.2 now passes** (Static PASS, Build PASS including
`updater_package` and all 19 `.fap` outputs verified present on 2
independent real CI runs). **Phase 2F.3 is now allowed to begin**, at
the project owner's discretion. Hardware-assisted validation and full
release-readiness remain separately gated — neither has been performed
for this batch, and neither is claimed here.

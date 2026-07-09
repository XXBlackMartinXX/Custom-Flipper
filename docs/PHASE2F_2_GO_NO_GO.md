# Phase 2F.2 — Go / No-Go

Docs only. This is the closing decision document for Phase 2F.2 —
implementation/import of the cleared Phase 2F tiny batch.

## Final classification: **PHASE 2F.2 BUILD BLOCKED / REPRODUCIBLE UPDATER_PACKAGE CI TOOLING**

This is **not** a pass, and is reported honestly as such rather than
rounded up. All 3 cleared apps (`qrcode`, `hex_viewer`, `barcode_gen`)
were imported one at a time, each preserving full provenance and license
text, each statically clean, and the resulting 19-app batch's **firmware
build itself passed consistently on 2 of 2 real Windows CI attempts**, at
the exact expected size both times. However, the separate
`updater_package` build sub-step — which packages the built firmware and
`.fap` outputs into the distributable updater `.tgz` — **failed to
launch as a process on 2 of 2 real CI attempts**, reproduced identically
on two different GitHub-hosted runner instances for the same commit, and
the per-app `.fap` output directory was confirmed to contain none of the
19 expected named files on either attempt. This is a real,
currently-unresolved CI/tooling-environment finding — not evidence of a
source defect in `qrcode`, `hex_viewer`, or `barcode_gen`'s own code, but
it is not swept aside either, and Phase 2F.2 does not pass until it is
resolved.

## Imported apps

| App | License | Import commit | Static scan | Storage behavior | Firmware build | Updater package build | FAP output |
|---|---|---|---|---|---|---|---|
| `qrcode` | MIT (confirmed, full text; bundles a third-party MIT QR-encoding library, attributed) | `79f50cc` | Clean — 8 benign `ble`-substring false positives | Confirmed app-private/read-only, one-time benign legacy-folder migration | PASS, 2/2 | BLOCKED, 0/2 | Missing, 0/2 |
| `hex_viewer` | MIT (confirmed, full text) | `04715de` | Clean — 37 benign `ble`-substring false positives | Confirmed genuinely read-only for viewed files, app-private settings only | PASS, 2/2 | BLOCKED, 0/2 | Missing, 0/2 |
| `barcode_gen` | MIT (confirmed, full text; real appid `barcode_app`) | `2512644` | Clean — 46 benign `ble`-substring false positives | Confirmed app-private storage only, bundled encoding tables confirmed standard technical data | PASS, 2/2 | BLOCKED, 0/2 | Missing, 0/2 |

Plus infrastructure commits: `862fd8e` (validator config,
`tools/phase2f_validate_config.json`), `683137d` (CI workflow,
`.github/workflows/phase2f-windows-validation.yml`).

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
- **Not touched**: `applications/` (base firmware source), `build/`,
  `dist/`, `toolchain/`, any Phase 2A/2B/2C/2D/2E app directory, any
  firmware binary, any updater package. No core firmware modification
  was made or needed — confirmed directly, since the firmware build
  itself succeeded unmodified on both real CI attempts.
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
  prior phase has hit. Not faked as a pass.
- **Local static validation**: `PASS_WITH_REVIEWED_FALSE_POSITIVES` (464
  matches, all reviewed, zero unreviewed, zero high-confidence-unsafe).
- **CI (real, GitHub Actions `windows-latest`)**: Static **PASS** on both
  attempts. Firmware build **PASS** on both attempts (862,825 bytes,
  identical both times). `updater_package` build **BLOCKED** on both
  attempts ("fbt.cmd could not be launched as a process on this
  machine/OS," byte-identical error text). Per-app FAP output
  verification **FAIL** on both attempts (0 of 19 expected files found).
  See `docs/PHASE2F_2_BUILD_REPORT.md` for full evidence from both
  attempts.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's workflow or script changes. No device, no flash, at any
point in this phase.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.** Unchanged from the Phase 2E
baseline this batch builds on. Not eligible to advance further given the
current Build status.

## Why this is not classified as intermittent (yet)

Phase 2D.2A's own `updater_package` launch-failure finding was
established as **intermittent** based on 4 total real CI attempts (2
pass, 2 fail — roughly 50%). This phase has only 2 real attempts so far,
and **both failed identically** — this is consistent with either (a) a
recurrence of the same underlying intermittent Windows-runner
class of issue Phase 2D.2A described, simply not yet having drawn a
passing attempt in this smaller 2-attempt sample, or (b) a new, more
consistently reproducible regression distinct from Phase 2D.2A's
finding. This report does not guess which. The additional, not
previously observed detail that `.extapps` was confirmed **completely
empty of any of the 19 named FAP files even before `updater_package` was
attempted** (whereas Phase 2D.2A's own diagnostic logging did not exist
early enough in that investigation to confirm or rule out the same
condition at the time) is recorded as an open question requiring direct
investigation with real log-file access, not resolved by inference in
this session.

## Proposed Phase 2F.2A remediation plan (not implemented — planning only)

Per explicit instruction, this plan is not executed in this phase. If the
project owner requests it, a future Phase 2F.2A should:

1. **Attempt at least 1–2 additional real CI runs** (via
   `workflow_dispatch` or `rerun_failed_jobs`) to build a larger sample
   size before concluding whether this is intermittent (matching Phase
   2D.2A's own 4-attempt methodology) or consistently reproducible.
2. **Obtain real access to the actual `build_firmware_*.log` and
   `build_updater_*.log` files** (currently only available as workflow
   artifacts, blocked from direct download in this AI session's sandbox
   by the same confirmed Azure Blob Storage egress restriction every
   prior phase has hit) — ideally by having a human with real CI access
   download and inspect them, or by adding a diagnostic step that prints
   the tail of these log files directly to the console output so they
   are visible in `get_job_logs` without requiring an artifact download.
3. **Add a diagnostic step immediately after the firmware build**
   (before the existing pre-updater_package diagnostics) that lists the
   actual contents of `build\f7-firmware-C\` (not just checks whether
   `.extapps` exists) — to determine definitively whether the firmware
   build's own scons invocation is silently failing to build any
   external app FAPs at all in this environment, independent of whether
   `updater_package` itself can launch.
4. **Investigate the `phase2f-fap-artifacts` upload anomaly directly**
   (115,177 bytes uploaded on both attempts, despite the per-appid check
   finding zero of the 19 expected files) — a human with real artifact
   download access should inspect what is actually inside that ZIP, since
   this AI session's sandbox cannot.
5. **Determine whether the narrow `cmd /c` launch-mechanism fix from
   Phase 2D.2A is still effective**, or whether it requires further
   adjustment for a 19-app batch (a larger app count than Phase 2D.2A's
   own 13-app batch was tested against) — e.g. a longer timeout, a
   different working-directory assumption, or a resource-contention
   issue specific to compiling a larger external-app set.
6. **Only if a real, reproducible root cause is found and fixed**, treat
   Phase 2F.2 as passing at that point — do not retroactively call the
   current 2-attempt evidence a pass regardless of what Phase 2F.2A
   finds.

## Next allowed gate

**None advance automatically.** Phase 2F.2 does not currently pass.
The next allowed step is either:
- **Phase 2F.2A** (the remediation plan above), if and when the project
  owner explicitly requests it; or
- **Additional CI re-runs** of the existing, unmodified workflow, if the
  project owner wants more data points before committing to a
  remediation phase.

**Phase 2F.3 is not started, and must not start, until Phase 2F.2
actually passes** (Static PASS, Build PASS including `updater_package`
and all 19 `.fap` outputs verified present). Hardware-assisted validation
and release-readiness both remain blocked regardless, until real
hardware validation is actually complete and explicitly accepted.

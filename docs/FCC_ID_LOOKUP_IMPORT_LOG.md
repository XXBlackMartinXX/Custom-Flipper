# FCC ID Lookup — Import Log

Records the real, actual import of `fcc_id_lookup`, mirroring the format
of this project's existing per-batch `PHASEX_2_IMPORT_LOG.md` documents.
This is a dedicated one-app import, not a new Phase 2G/2H batch.

## Branch

`integration/fcc-id-lookup-one-app-import`, created from the latest
pushed `integration/phase2f-first-batch`
(commit `107a964`, the `fcc_id_lookup` pre-import verification commit).

## Source repo and exact pinned commit

| Field | Value |
|---|---|
| Source repo | `RogueMaster/flipperzero-firmware-wPlugins` |
| Pinned commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/fcc_id_lookup/` |

## Imported path

`applications_user/fcc_id_lookup/`

## Import commit

`579b355` ("fcc: import fcc_id_lookup")

## Files imported

All 5 upstream files, copied byte-identical (verified via `diff`/`cmp`
against the pinned-commit source before commit — zero refactoring, zero
comment changes, zero provenance changes):

- `README.md` (786 bytes)
- `application.fam` (444 bytes)
- `fcc_id_lookup.c` (48,569 bytes / 1,414 lines)
- `fcc_id_lookup_icon.png` (96 bytes)
- `fcc_qr_code.h` (1,719 bytes)

Plus one new file, not present upstream:

- `LICENSE` (1,060 bytes) — the confirmed upstream MIT License text
  (Copyright (c) 2026 lsr), added per the license-resolution phase's
  import-time condition.

Plus one narrow, non-source change required for git tracking:
`applications_user/.gitignore` was updated with a new
`!/fcc_id_lookup/` / `!/fcc_id_lookup/**` allowlist entry, following this
project's own established per-app explicit-exception pattern (every
prior imported app has an identical pair of entries).

## Upstream MIT LICENSE evidence added

The confirmed upstream MIT `LICENSE` (fetched live from
`raw.githubusercontent.com/lrehmann/fcc-id-lookup-flipper/main/LICENSE`,
independently confirmed to match the canonical MIT License template
exactly, copyright line "Copyright (c) 2026 lsr") was added at
`applications_user/fcc_id_lookup/LICENSE` in the same import commit. Full
resolution chain in `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`; full
attribution detail in `docs/FCC_ID_LOOKUP_LICENSE_ATTRIBUTION.md` and
`docs/FCC_ID_LOOKUP_THIRD_PARTY_NOTICES.md`.

## FCC database not bundled — confirmation

Confirmed by direct directory listing after import:
`applications_user/fcc_id_lookup/` contains exactly 6 files, none of
which is a database, binary blob, or archive of any kind. The optional
~8.9 MB FCC frequency/applicant database was not fetched, not added, and
is not part of this import in any form.

## Compile fixes

**None.** All 5 upstream source/asset files were imported byte-identical
to the pinned-commit source, with no modification of any kind. No
app-local compile fix was needed or made in this phase; whether the app
compiles cleanly against this project's current firmware baseline is
determined by the real CI build (see `docs/FCC_ID_LOOKUP_BUILD_REPORT.md`
for the actual result).

## Validator config and CI workflow

- `tools/fcc_id_lookup_validate_config.json` — a superset of
  `tools/phase2f_validate_config.json`, extending `expectedApps` to 20
  (the 19 already-accepted apps plus `fcc_id_lookup`), with new
  `allowedSourcePaths`, `expectedAppPrivateStoragePaths`, and 11 new
  `reviewedFalsePositives` entries for `fcc_id_lookup`'s own reviewed
  keyword matches.
- `.github/workflows/fcc-id-lookup-windows-validation.yml` — modeled
  directly on `phase2f-windows-validation.yml`: Static + Build on
  `windows-latest`, uploads validation reports and build artifacts as
  workflow artifacts only, never runs `-Mode HardwareAssisted`.
- Commit `b3e428a` ("fcc: add validation config and workflow").

## Real static validation result

`tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/fcc_id_lookup_validate_config.json`, run for real against the
actually-imported source: all 20 app directories present, all 20
`application.fam` files parse, all 20 appids unique, zero appid
collision vs base firmware, chess SAM removal still clean, risky keyword
scan `PASS_WITH_REVIEWED_FALSE_POSITIVES` (475 matches, all reviewed,
zero unreviewed, zero high-confidence-unsafe). Full detail in
`docs/FCC_ID_LOOKUP_SAFETY_REVIEW.md`.

## Local build status

**BUILD BLOCKED / ENVIRONMENT.** `fbt.cmd` is confirmed (via `file
fbt.cmd`, not assumed) to be a DOS/Windows batch file; this AI session
runs in a Linux sandbox and cannot execute it. This is the same,
already-documented environment limitation as every prior phase's own
local-build attempt — not a defect in `fcc_id_lookup`. Real build
validation proceeds via CI (`docs/FCC_ID_LOOKUP_BUILD_REPORT.md`).

## Final import status

**FCC_ID_LOOKUP IMPORT PASS.** Real CI run
([`29067243595`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29067243595),
commit `ff5a69b`) confirmed `Static: PASS_WITH_REVIEWED_FALSE_POSITIVES`,
`Build: PASS`, `firmware.dfu` (862,833 bytes) and updater `.tgz`
(2,891,283 bytes) both generated, all 20 expected `.fap` outputs present
including `fcc_id_lookup.fap`. Full detail in
`docs/FCC_ID_LOOKUP_BUILD_REPORT.md`; final classification in
`docs/FCC_ID_LOOKUP_GO_NO_GO.md`.

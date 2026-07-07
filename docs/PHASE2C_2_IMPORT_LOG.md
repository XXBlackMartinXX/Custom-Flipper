# Phase 2C.2 — Import Log

Docs only, describing real code changes made in this phase. This is the
factual record of what was imported, from where, and how it was verified
— not a claim of hardware-tested or release-ready status.

## Branch

- **Working branch**: `integration/phase2c-first-batch`, created from
  `integration/phase2b-first-batch` at commit `270f72f` (the Phase 2C.1
  pre-import verification commit) — the latest pushed state of the
  integration branch at the start of this phase.
- **Phase 2A baseline tags** (`phase2a-ci-baseline-20260707`,
  `phase2a-acceptance-record-20260707`) and **Phase 2B baseline tags**
  (`phase2b-ci-baseline-20260707`, `phase2b-acceptance-record-20260707`)
  were not touched, moved, or overwritten. They still point at their
  original commits.
- `integration/phase2a-first-batch` and `integration/phase2b-first-batch`
  themselves were not modified in this phase.

## Source repo and exact source commit

- **Source repository**: `RogueMaster/flipperzero-firmware-wPlugins`
- **Exact source commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the
  same commit verified in Phase 2C.1
  (`docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`). Re-fetched fresh in
  this phase (a separate `git fetch --depth 1 origin <sha>` into a scratch
  clone outside this repository) and re-verified byte-for-byte identical
  to the Phase 2C.1 evidence (`LICENSE` SHA-256 hashes matched exactly for
  both apps before any file was copied).

## App import order

1. `sd_info`
2. `docviewlite`

Exactly as recommended in `docs/PHASE2C_1_GO_NO_GO.md`'s reduced 2-app
cleared batch. `fcc_id_lookup` was **not imported** — deferred per that
same document, not substituted with any other app.

## Per-app import commit

| App | Source path (upstream) | Destination path (this repo) | Import commit |
|---|---|---|---|
| `sd_info` | `applications/external/sd_info/` | `applications_user/sd_info/` | `4e17278` — "phase2c: import sd_info" |
| `docviewlite` | `applications/external/docviewlite/` | `applications_user/docviewlite/` | `4fab909` — "phase2c: import docviewlite" |

Following these, one infrastructure commit was made:
`8cc20e2` — "phase2c: add validator config and CI workflow for the 10-app
batch" — adds `tools/phase2c_validate_config.json` (a superset of
`tools/phase2b_validate_config.json`, which remains frozen/untouched) and
`.github/workflows/phase2c-windows-validation.yml` (modeled directly on
`phase2b-windows-validation.yml`).

## License preservation

Each app's own `LICENSE` file was copied verbatim, byte-for-byte, along
with `README.md`. No license text, copyright notice, or attribution was
edited, removed, or rewritten. `sd_info`'s `LICENSE` (GPLv3, full text)
and `docviewlite`'s `LICENSE` (MIT, full text) were re-hashed immediately
after copying and confirmed to match the exact SHA-256 values recorded in
Phase 2C.1 before either commit was made. See
`docs/PHASE2C_2_LICENSE_ATTRIBUTION.md` and
`docs/PHASE2C_THIRD_PARTY_NOTICES.md` for the full attribution record.

## Compile fixes

**None required.** No source file in either app was modified during
import. Each app's `entry_point` (from `application.fam`) was confirmed
to match a real function defined in that app's own source
(`sd_card_info_app` in `main.c`; `docviewlite_app` in `docviewlite.c`)
before committing. No core firmware file (anything outside
`applications_user/<app>/`) was touched.

One repository-infrastructure file *was* touched, but it is not app
source: `applications_user/.gitignore` uses a blanket `*` ignore with
explicit `!/appname/` exceptions (the same pattern already used for the 8
Phase 2A/2B apps) — a `!/sd_info/` and `!/docviewlite/` exception pair was
added, one per app, in that app's own import commit.

`docviewlite`'s `application.fam` declares `fap_icon_assets="images"`
even though no `images/` directory exists in the vendored source (a
finding already recorded in Phase 2C.1). Per this phase's explicit
"do not improve app features during import" instruction, this was left
exactly as vendored, not edited preemptively — the actual Static/Build
validation run (see `docs/PHASE2C_2_BUILD_REPORT.md`) is the real test of
whether this is tolerated by `fbt`, not a guess made at import time.

## Static scan result (per app)

Both apps were scanned individually immediately after being copied into
`applications_user/`, before committing — see
`docs/PHASE2C_2_SAFETY_REVIEW.md` for the full per-app detail. Summary:

| App | appid collision | Real unsafe-keyword matches | `ble`-substring false positives |
|---|---|---|---|
| `sd_info` | None | Zero | 4 (lines 121, 163, 164, 489 — all `"double"`/`"enabled"`) |
| `docviewlite` | None | Zero | 25 (lines 9, 22, 58, 73, 86, 660, 661, 667, 668, 688, 689, 695, 696, 757, 799, 810, 813, 819, 820, 824, 830, 831, 835, 839, 916 — `"variable"`/`"available"`/`"enabled"`/`"scrolling"`) |

After both were committed, the combined 10-app batch (8 Phase 2A/2B + 2
Phase 2C) was validated together via
`tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2c_validate_config.json`, run for real in this session (pwsh
is available in this sandbox): all 10 app directories present, all 10
`application.fam` parse and appid-match, all 10 appids unique with no
collision against base `applications/`, chess's SAM removal still
confirmed clean, and the risky-keyword scan found all 139 substring
matches (138 pre-existing Phase 2A/2B + 1 new: `docviewlite.c` line 86,
initially missed on the first pass and corrected before the final commit)
accounted for by an individually-reviewed entry — zero unreviewed, zero
high-confidence-unsafe. Classification: **`PASS_WITH_REVIEWED_FALSE_POSITIVES`**.

## Final batch status

**Both apps imported, committed, and statically clean.** See
`docs/PHASE2C_2_GO_NO_GO.md` for the final Phase 2C.2 classification,
`docs/PHASE2C_2_BUILD_REPORT.md` for local/CI build status, and
`docs/PHASE2C_2_SAFETY_REVIEW.md` for the full safety-scan detail.

**No firmware/app code outside `applications_user/sd_info/`,
`applications_user/docviewlite/`, and `applications_user/.gitignore` was
changed.** `fcc_id_lookup` was not imported and no substitute app was
added. No hardware was touched. No release was published. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**.

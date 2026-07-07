# Phase 2B.2 — Import Log

Docs only, describing real code changes made in this phase. This is the
factual record of what was imported, from where, and how it was verified
— not a claim of hardware-tested or release-ready status.

## Branch

- **Working branch**: `integration/phase2b-first-batch`, created from
  `integration/phase2a-first-batch` at commit `c5c45b2` (the Phase 2B.1
  pre-import verification commit) — the latest pushed state of the
  integration branch at the start of this phase.
- **Phase 2A baseline tags** (`phase2a-ci-baseline-20260707`,
  `phase2a-acceptance-record-20260707`) were not touched, moved, or
  overwritten. They still point at their original commits on
  `integration/phase2a-first-batch`.
- `integration/phase2a-first-batch` itself was not modified in this phase.

## Source repo and exact source commit

- **Source repository**: `RogueMaster/flipperzero-firmware-wPlugins`
- **Exact source commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the
  same commit verified in Phase 2B.1
  (`docs/PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`). Re-fetched fresh in
  this phase (a separate `git fetch --depth 1 origin <sha>` into a scratch
  clone outside this repository) and re-verified byte-for-byte identical
  to the Phase 2B.1 evidence (`LICENSE` SHA-256 hashes matched exactly for
  all 3 apps before any file was copied).

## App import order

1. `flipfetch`
2. `quadratic_solver`
3. `sudoku`

Exactly as recommended in `docs/PHASE2B_RECOMMENDED_BATCH.md`.

## Per-app import commit

| App | Source path (upstream) | Destination path (this repo) | Import commit |
|---|---|---|---|
| `flipfetch` | `applications/external/flipfetch/` | `applications_user/flipfetch/` | `e6d4286` — "phase2b: import flipfetch" |
| `quadratic_solver` | `applications/external/quadratic_solver/` | `applications_user/quadratic_solver/` | `367bdb9` — "phase2b: import quadratic_solver" |
| `sudoku` | `applications/external/sudoku/` | `applications_user/sudoku/` | `2c6ff1c` — "phase2b: import sudoku" |

Preceding these, one infrastructure commit was made first:
`a6633ad` — "phase2b: add optional -ConfigPath to validator
(backward-compatible)" — adds a single optional parameter to
`tools/phase2a_validate.ps1` so it can validate a different app batch via
an alternate config file, without touching Phase 2A's own default
behavior or config. Following the 3 app-import commits, one more
commit, `50dfe2f` — "phase2b: add validator config and CI workflow for
the 8-app batch" — adds `tools/phase2b_validate_config.json` and
`.github/workflows/phase2b-windows-validation.yml`.

## License preservation

Each app's own `LICENSE` file was copied verbatim, byte-for-byte, along
with `README.md` and (where present) `changelog.md`/`CHANGELOG.md`/
`README_catalog.md` and `screenshots/`. No license text, copyright notice,
or attribution was edited, removed, or rewritten. See
`docs/PHASE2B_2_LICENSE_ATTRIBUTION.md` and
`docs/PHASE2B_THIRD_PARTY_NOTICES.md` for the full attribution record.

## Compile fixes

**None required.** No source file in any of the 3 apps was modified during
import. Each app's `entry_point` (from `application.fam`) was confirmed
to match a real function defined in that app's own source
(`flipfetch_app` in `flipfetch.c`, `main_quadratic_solver_app` in
`app.c`, `sudoku_main` in `sudoku.c`) before committing. No core firmware
file (anything outside `applications_user/<app>/`) was touched.

One repository-infrastructure file *was* touched, but it is not app
source: `applications_user/.gitignore` uses a blanket `*` ignore with
explicit `!/appname/` exceptions (the same pattern already used for the 5
Phase 2A apps) — a `!/flipfetch/`, `!/quadratic_solver/`, and `!/sudoku/`
exception pair was added, one per app, in that app's own import commit.
Without this, `git add` silently refuses to stage the new app directories
at all (confirmed directly: the first `git add` attempt for `flipfetch`
returned "The following paths are ignored by one of your .gitignore
files" before this was diagnosed and fixed).

## Static scan result (per app)

All 3 apps were scanned individually immediately after being copied into
`applications_user/`, before committing — see
`docs/PHASE2B_2_SAFETY_REVIEW.md` for the full per-app detail. Summary:

| App | appid collision | Real unsafe-keyword matches | `ble`-substring false positives |
|---|---|---|---|
| `flipfetch` | None | Zero | Zero |
| `quadratic_solver` | None | Zero | 5 (lines 36, 77, 81, 85, 218 — all `"double"`/`"enabled"`) |
| `sudoku` | None | Zero | 1 (line 674 — `"enabled"`) |

After all 3 were committed, the combined 8-app batch (5 Phase 2A + 3
Phase 2B) was validated together via
`tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2b_validate_config.json`, run for real in this session: all 8
app directories present, all 8 `application.fam` parse and appid-match,
all 8 appids unique with no collision against base `applications/`,
chess's SAM removal still confirmed clean, and the risky-keyword scan
found all 110 substring matches (104 pre-existing Phase 2A + 6 new Phase
2B) accounted for by an individually-reviewed entry — zero unreviewed,
zero high-confidence-unsafe.

## Final batch status

**All 3 apps imported, committed, and statically clean.** See
`docs/PHASE2B_2_GO_NO_GO.md` for the final Phase 2B.2 classification,
`docs/PHASE2B_2_BUILD_REPORT.md` for local/CI build status, and
`docs/PHASE2B_2_SAFETY_REVIEW.md` for the full safety-scan detail.

**No firmware/app code outside `applications_user/flipfetch/`,
`applications_user/quadratic_solver/`, `applications_user/sudoku/`, and
`applications_user/.gitignore` was changed.** No hardware was touched. No
release was published. Hardware flashing/testing remains **NOT
PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

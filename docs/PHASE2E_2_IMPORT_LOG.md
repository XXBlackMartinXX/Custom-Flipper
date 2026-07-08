# Phase 2E.2 — Import Log

Docs + real app source. Records exactly what was imported, from where, in
what order, and what each commit contains, for the Phase 2E cleared 3-app
batch (`image_viewer`, `boilerplate`, `minesweeper`) on top of the 13
already-accepted Phase 2A/2B/2C/2D apps.

## Branch and source provenance

- **Implementation branch**: `integration/phase2e-first-batch`, created
  from `integration/phase2d-first-batch` at commit `209066b` (Phase
  2E.1's own final commit).
- **Source repository**: `RogueMaster/flipperzero-firmware-wPlugins`.
- **Source commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the
  exact same commit Phase 2E.1 verified, fetched fresh a second time via
  a shallow `git fetch --depth 1 origin <sha>` into a scratch clone
  outside this repository, then `git rev-parse FETCH_HEAD` confirmed
  against the pinned SHA before any file was copied. No discrepancy from
  the Phase 2E.1 verification docs.
- **Source paths used**: `applications/external/image_viewer/`,
  `applications/external/boilerplate/`,
  `applications/external/minesweeper/` — the exact paths recorded in
  `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`.

## Import order and commits

| Order | App | Commit | Imported path |
|---|---|---|---|
| 1 | `image_viewer` | `3b20db6` — "phase2e: import image_viewer" | `applications_user/image_viewer/` |
| 2 | `boilerplate` | `74d0927` — "phase2e: import boilerplate" | `applications_user/boilerplate/` |
| 3 | `minesweeper` | `d82c0ff` — "phase2e: import minesweeper" | `applications_user/minesweeper/` |

Each app was imported and committed individually — one commit per app,
each verified (license evidence preserved, `application.fam` parses,
appid uniqueness, static safety scan) before moving to the next, per
`docs/PHASE2E_INTEGRATION_PLAN.md`'s discipline.

Two follow-up commits completed the batch's tooling:

- `db48d32` — "Add Phase 2E validator config (16-app superset)"
- `59b5132` — "Add Phase 2E Windows CI validation workflow"

No compile fixes were required for any of the 3 apps — the real CI Build
run (see `docs/PHASE2E_2_BUILD_REPORT.md`) succeeded on the first attempt
with the imported source completely unmodified from upstream (aside from
the one documented `application.fam` line removal for `image_viewer`,
below).

## Per-app import scope

### `image_viewer` (commit `3b20db6`)

Imported: `application.fam` (with the `fap_file_assets = "example_images"`
line removed — the only textual change made to any upstream file in this
batch), `LICENSE`, `README.md`, `CHANGELOG.md`, `main.cpp`,
`assets/icon.png`.

**Explicitly excluded, per the Phase 2E.1 import-scope condition**:
`example_images/` (all 3 bundled `.bm` files — `cat.bm`, `dolphin.bm`,
and `spongebob.bm`, the last of which Phase 2E.1 decoded and visually
confirmed to depict a recognizable trademarked/copyrighted cartoon
character with no attribution anywhere in the app). **No SpongeBob or
SpongeBob-like image, and no other example image from that directory,
was imported at any point in this phase.** Confirmed directly:
`main.cpp` does not reference any bundled filename by name (it opens
whatever file the user selects via the standard file-browser dialog), so
excluding the directory did not require any code change and did not
break the build — confirmed by the real CI Build PASS.

### `boilerplate` (commit `74d0927`)

Imported: `application.fam`, `README.md`, `docs/README.md`,
`docs/changelog.md`, `boilerplate.c`, `boilerplate.h`, `helpers/` (9
files), `scenes/` (12 files), `views/` (6 files), `icons/` (2 files).

No `LICENSE` file was invented — none exists upstream, confirmed by
Phase 2E.1's exhaustive file listing and re-confirmed at import time.
`README.md`'s own "## Licensing" section ("This code is open-source and
may be used for whatever you want to do with it.") is preserved verbatim,
unedited, in the imported copy — this is the app's license-evidence
record, and it is recorded here as a distinct, weaker evidence tier than
a formal license file, not silently upgraded to "MIT." Nothing was
excluded from this app's import scope.

### `minesweeper` (commit `d82c0ff`)

Imported: `application.fam`, `LICENSE`, `README.md`, `minesweeper.c`,
`minesweeper.h`, `engine/` (5 files), `helpers/` (9 files), `scenes/` (11
files, including a `README.md`), `views/` (6 files), `assets/` (29
files).

**Excluded for cleanliness only, no provenance concern**: `img/`
(screenshots and GIFs, not referenced by `application.fam`) and
`docs/changelog.md` (informational only) — the same "unreferenced
directory" precedent Phase 2D.1 applied to `resistors`.

## License preservation confirmed

- `image_viewer/LICENSE`: full, unmodified MIT License text (Ivan
  Polushin/polioan, 2024) — byte-identical to the upstream file.
- `boilerplate/README.md`: full, unmodified "## Licensing" section
  preserved verbatim — no separate `LICENSE` file exists upstream, none
  was invented here.
- `minesweeper/LICENSE`: full, unmodified MIT License text (Alexander
  Rodriguez/squee72564, 2024) — byte-identical to the upstream file.

## Static scan result

`tools/phase2e_validate_config.json` (16-app superset, built on top of
the frozen `tools/phase2d_validate_config.json`) was created with 184 new
reviewed-false-positive entries (373 total, up from 189) covering every
`"ble"`-substring hit found in the 3 newly-imported apps' actual source
(all inside benign identifiers like `variable`, `enabled`, `solvable`,
`double` — zero real capability keyword matches). A local
`-Mode Static` run (after initializing this session's git submodules
fresh over real network access) returned
**`PASS_WITH_REVIEWED_FALSE_POSITIVES`** — 373 matches, all reviewed,
zero unreviewed, zero high-confidence-unsafe. The real CI run
(`28966234832`) independently reproduced the identical result. See
`docs/PHASE2E_2_SAFETY_REVIEW.md` for the full per-app breakdown.

## Final batch status

**All 3 apps imported, committed individually, statically clean, and
confirmed by a real, successful CI Build run** (firmware + updater
package + all 16 `.fap` outputs, including `image_viewer.fap`,
`fap_boilerplate.fap`, and `minesweeper_redux.fap`). See
`docs/PHASE2E_2_BUILD_REPORT.md` for the full CI evidence and
`docs/PHASE2E_2_GO_NO_GO.md` for the final classification. No firmware/
core source (`applications/`, `lib/`, etc.) was touched at any point in
this phase. No hardware was touched, no `HardwareAssisted` mode was run.

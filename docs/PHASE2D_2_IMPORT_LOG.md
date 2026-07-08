# Phase 2D.2 — Import Log

Docs + real app source. Records exactly what was imported, from where, in
what order, and what each commit contains, for the Phase 2D cleared
3-app batch (`resistors`, `crypto_dictionary`, `2048`) on top of the 10
already-accepted Phase 2A/2B/2C apps.

## Branch and source provenance

- **Implementation branch**: `integration/phase2d-first-batch`, created
  from `integration/phase2c-first-batch` at commit `6031e8b` (Phase 2D.1's
  own final commit).
- **Source repository**: `RogueMaster/flipperzero-firmware-wPlugins`.
- **Source commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the
  exact same commit Phase 2D.1 verified, fetched fresh a second time via
  a shallow `git fetch --depth 1 origin <sha>` into a scratch clone
  outside this repository, then `git rev-parse FETCH_HEAD` confirmed
  against the pinned SHA before any file was copied. No discrepancy from
  the Phase 2D.1 planning docs.
- **Source paths used**: `applications/external/resistors/`,
  `applications/external/crypto_dictionary/`,
  `applications/external/2048/` — the exact paths recorded in
  `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`.

## Import order and commits

| Order | App | Commit | Imported path |
|---|---|---|---|
| 1 | `resistors` | `621229a` — "phase2d: import resistors" | `applications_user/resistors/` |
| 2 | `crypto_dictionary` | `f9fcc57` — "phase2d: import crypto_dictionary" | `applications_user/crypto_dictionary/` |
| 3 | `2048` | `52b1361` — "phase2d: import 2048" | `applications_user/2048/` |

Each app was imported and committed individually — one commit per app,
each verified (LICENSE preserved, `application.fam` parses, appid
uniqueness, static safety scan) before moving to the next, per
`docs/PHASE2D_INTEGRATION_PLAN.md`'s discipline.

Two follow-up commits completed the batch's tooling:

- `41597a9` — "phase2d: add Phase 2D validator config (13-app superset)"
- `263a019` — "phase2d: add Phase 2D Windows CI validation workflow"
- `e01370d` — "phase2d: fix .fap artifact upload dot-directory exclusion in CI workflow" (a real CI-tooling bug found and fixed on this branch's first real CI run — see `docs/PHASE2D_2_BUILD_REPORT.md`)

## Per-app import scope

### `resistors` (commit `621229a`)

Imported: `application.fam`, `LICENSE`, `README.md`, `resistors.png`,
`images/` (5 files: `box_8x22.png`, `r3.png`, `r4.png`, `r5.png`,
`r6.png`), `src/` (13 files).

**Explicitly excluded**, per the Phase 2D.1 import-scope condition:
`.flipcorg/` (624K, catalog-listing banner/gallery images),
`design/` (64K, icon design-source images — includes the two files with
unclear photographic-reference provenance, `resistor_5_src.jpg` and
`resistor_4_src.webp`), `img/` (36K, 2 screenshots), `screenshots/`
(1.6MB, README/catalog screenshots including a `v0/` subfolder). None of
these are referenced by `application.fam` and none are build inputs —
confirmed by inspecting the manifest (`fap_icon="resistors.png"`,
`fap_icon_assets="images"` only) before the import, and confirmed again
by the real CI build succeeding without them (see
`docs/PHASE2D_2_BUILD_REPORT.md`).

### `crypto_dictionary` (commit `f9fcc57`)

Imported: `application.fam`, `LICENSE`, `README.md`, `main.c`,
`app/app.{c,h}`, `buffer/dynamic_buffer.{c,h}`,
`callbacks/callbacks.{c,h}`, `constants/constants.h`,
`resource/resource.{c,h}`, `scenes/scene_manager.{c,h}`,
`scenes/scenes.{c,h}`, `icons/crypto_dict_icon.png`, and all 14 bundled
glossary text files under `resources/` (13 `resources/symmetric_cipher/*.txt`
plus `resources/about/{algorithms,github}.txt` and
`resources/development.txt`).

**Explicitly excluded**: `.flipcorg/` (catalog-listing banner images —
not referenced by `application.fam`, no provenance concern of its own,
excluded purely for import cleanliness).

### `2048` (commit `52b1361`)

Imported: `application.fam`, `LICENSE`, `README.md`,
`README-catalog.md`, `game_2048.png`, `game_2048.c`,
`array_utils.{c,h}`, `digits.h`.

**Explicitly excluded**: `images/` and `img/` (4 gameplay screenshots
total — not referenced by `application.fam`, no provenance concern of
their own, excluded for import cleanliness and consistency with the
`resistors` precedent).

## No source changes outside each app's own directory

Confirmed by `git diff --stat` at each commit (see below) — every commit
touches only the one app's own new directory, plus
`applications_user/.gitignore` (adding that app's explicit exception to
the blanket ignore, one line-pair at a time, mirroring the exact pattern
used for every prior phase's apps).

## Compile fixes

**None required.** All 3 apps compiled and linked as-is, unmodified from
the vendored source, in the real CI build (see
`docs/PHASE2D_2_BUILD_REPORT.md`).

## Static scan result at import time

Each app's actually-imported files (not the full upstream directory) were
scanned individually at import time for all 22 required keywords. See
`docs/PHASE2D_2_SAFETY_REVIEW.md` for the full per-app result, including
a correction to Phase 2D.1's own `resistors` finding.

## Final batch status

All 3 apps (`resistors`, `crypto_dictionary`, `2048`) imported, committed
individually, and confirmed to compile and produce their expected `.fap`
output in real CI. `fcc_id_lookup` was not imported, not re-reviewed, and
remains untouched — exactly as instructed. No other app was imported. No
core firmware (`applications/`, `lib/`, etc.) was modified.

**This log does not itself constitute a build/release acceptance** — see
`docs/PHASE2D_2_BUILD_REPORT.md` for the real build result (which
includes a genuine, reproducible CI blocker in the separate
`updater_package` step) and `docs/PHASE2D_2_GO_NO_GO.md` for the final
classification.

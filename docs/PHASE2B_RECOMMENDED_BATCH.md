# Phase 2B — Recommended Batch

Docs only. Planning only. **No code has been imported.** This selects a
tiny candidate batch from the 18-app pool in `PHASE2B_CANDIDATE_REVIEW.md`
for a *future*, separately-approved implementation phase — the same
"selection is not an action" discipline `PHASE1_6_FIRST_BATCH_SELECTION.md`
used for Phase 2A.

## Selection logic

Phase 2A's own first-batch reasoning was: pick the most conservative
possible slice — least storage/hardware footprint, simplest file
structure, some category spread — to re-validate the import pipeline
before anything larger. This recommendation applies the identical logic to
the Phase 2B pool, since that pipeline (one app per commit, static
validation after each, CI validation, this same acceptance-record
discipline) is exactly what would be reused, not redesigned.

From the 18-candidate pool, this recommendation excludes:

- `c_book` — flagged `NEEDS REVIEW` for an unresolved copyright question
  over its bundled K&R book text (see `PHASE2B_LICENSE_REVIEW.md`); not
  recommended for any batch until that is resolved.
- `animation_switcher`, `theme_manager` — both write to shared
  `/ext/dolphin/` storage rather than app-private storage. Not rejected
  (both have their own confirmed backup logic), just not first-Phase-2B-
  batch material while 15 other candidates have zero or fully
  app-private storage footprint instead.
- `resistors`, `boilerplate`, `hex_viewer`, `minesweeper`,
  `barcode_gen` — all fine, but larger (13–21 files, or in `resistors`'
  case, a disproportionately large ~2.3MB asset footprint per Phase 1.5) —
  reasonable for a *second* Phase 2B batch, not the most conservative
  possible first slice.
- `image_viewer`, `crypto_dictionary`, `fcc_id_lookup`, `qrcode`,
  `docviewlite` — all fine and simple, but not selected below purely to
  keep the tiny batch at the "ideal" size of 3 rather than the maximum of
  5; good candidates for the next batch after this one.

## The recommended tiny batch: 3 apps

### 1. `flipfetch`

- **Source path**: `applications/external/flipfetch/`
- **Expected category**: Tools
- **Why selected**: Confirmed by Phase 1.6 source audit to have **zero**
  storage API usage and zero hardware API usage of any kind — a
  single-file device-info display ("neofetch"-style). The simplest
  possible entry in the entire candidate pool.
- **Why safe enough for planning**: No HAL capability hits of any class in
  the existing audit; nothing to re-derive.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 1 file, no HAL calls

### 2. `quadratic_solver`

- **Source path**: `applications/external/quadratic_solver/`
- **Expected category**: Tools
- **Why selected**: Confirmed zero storage, zero hardware API usage,
  single file — pure computation (quadratic equation solving), directly
  analogous in risk profile to Phase 2A's `vin_decoder`/`flipper95` picks.
- **Why safe enough for planning**: Same as above — audited, zero
  capability hits, single file.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 1 file, pure math logic

### 3. `sudoku`

- **Source path**: `applications/external/sudoku/`
- **Expected category**: Games
- **Why selected**: Single file, confirmed zero hardware API usage, only
  storage behavior is a private save file (own game state) — the same
  "one app-private-storage pick to test that pattern" role `chess` played
  in the Phase 2A batch, but at far lower structural complexity (1 file
  vs. 17 files + two vendored libraries). Also gives this tiny batch a
  second category (Games) instead of an all-Tools batch.
- **Why safe enough for planning**: Audited, zero HAL capability hits;
  private-storage-only pattern is well understood from Phase 2A's own
  `chess` precedent.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Low — 1 file, app-private storage
  only (no shared-directory writes, unlike `animation_switcher`/
  `theme_manager`)

## Import order recommendation

1. `flipfetch` first — simplest possible single-file, zero-storage,
   zero-hardware app; mirrors Phase 2A's use of `flipper95` as a
   build-health sanity check before anything else.
2. `quadratic_solver` second — same risk profile as #1, confirms the
   pipeline handles a second, independent zero-storage app cleanly.
3. `sudoku` third and last — the one app in this batch that touches
   storage at all (private save file only); sequencing it last means any
   storage-related build/validation issue is isolated to the final,
   most-scrutinized step rather than the first.

This mirrors the exact ordering discipline used in Phase 2A (simplest/
zero-capability apps first, the one storage-touching app last), not a new
convention.

## What this batch explicitly is not

- Not an import. No files from any of these 3 apps have been copied into
  `applications/` or `applications_user/` in this phase.
- Not a build attempt. No `fbt`/`fbt.cmd` invocation was made against any
  of these 3 apps.
- Not a claim that these 3 are bug-free, hardware-tested, or
  release-ready — none of that has been evaluated for these apps at all
  yet; only their *safety/capability profile* has been reviewed, via the
  existing Phase 1.6 audit.
- Not authorization to proceed. See `PHASE2B_GO_NO_GO.md` for the
  conditions that must be met before an actual implementation phase can
  begin, and note that even a clean GO here requires the project owner's
  own separate, explicit request to start import — same standing rule as
  every prior phase transition in this project.

# Phase 2C — Recommended Batch

Docs only. Planning only. **No code has been imported.** This selects a
tiny candidate batch from the 12-app pool in `PHASE2C_CANDIDATE_REVIEW.md`
for a *future*, separately-approved implementation phase — the same
"selection is not an action" discipline `PHASE1_6_FIRST_BATCH_SELECTION.md`
and `PHASE2B_RECOMMENDED_BATCH.md` used for their own batches.

## Selection logic

Every prior batch in this project picked the most conservative possible
slice first: least storage/hardware footprint, simplest file structure,
before anything larger. This recommendation applies the identical logic
here, going one step more conservative than Phase 2B's own batch: Phase
2B's tiny batch included one app-private-storage *write* (`sudoku`'s save
file). This batch's three picks have **zero storage writes at all** — two
are pure read-only (of a user-selected file or bundled data) and one reads
device metadata only. This is deliberately the most conservative slice
remaining in the pool, not an arbitrary pick.

## The recommended tiny batch: 3 apps

### 1. `sd_info`

- **Source path**: `applications/external/sd_info/` (RogueMaster) →
  expected `applications_user/sd_info/` on import, matching this
  project's established per-app layout
- **Expected category**: Tools
- **Why selected**: Confirmed by the Phase 1.6 source audit to be a single
  file with **read-only** storage access (SD card metadata only — no
  writes of any kind) and zero hardware-peripheral API usage.
- **Why safe enough for planning**: No HAL capability hits of any class;
  the simplest possible storage profile in the entire pool (read-only,
  not even a save file).
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 1 file, no writes, no HAL
  calls beyond a read-only card-info query

### 2. `fcc_id_lookup`

- **Source path**: `applications/external/fcc_id_lookup/` →
  expected `applications_user/fcc_id_lookup/`
- **Expected category**: Tools
- **Why selected**: 2 files, confirmed zero hardware API usage, storage
  limited to reading its own bundled reference database — no user data
  written, no external I/O.
- **Why safe enough for planning**: Audited, zero capability hits beyond a
  read of bundled, non-executable reference data.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 2 files, read-only
  bundled-data lookup

### 3. `docviewlite`

- **Source path**: `applications/external/docviewlite/` →
  expected `applications_user/docviewlite/`
- **Expected category**: Tools
- **Why selected**: Single file, confirmed zero hardware API usage,
  storage limited to reading a user-selected document — the same
  "opens a file the user picked" pattern already proven safe by
  `hex_viewer`'s and `image_viewer`'s Phase 1.6 audit findings (neither of
  which is in this specific batch, but the pattern itself is well
  understood).
- **Why safe enough for planning**: Audited, zero capability hits; adds a
  distinct sub-category (document viewer) rather than duplicating
  `sd_info`/`fcc_id_lookup`'s "lookup/reference" shape.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 1 file, read-only

## Why no game or write-storage app is in this batch

Unlike Phase 2A (which included `chess`, one private-save app) and Phase
2B (which included `sudoku`, one private-save app), this batch
deliberately contains **no** storage-writing app at all. This is not a
category-diversity regression — it reflects that this pool's remaining
zero-write apps (`sd_info`, `fcc_id_lookup`, `docviewlite`) are a strictly
more conservative slice than the pool's write-storage apps (`2048`,
`minesweeper`, `boilerplate`), and the task's own selection guidance
("recommend a tiny batch only... do not pad the batch with questionable
apps") favors the most conservative available slice over forcing category
spread. A future batch drawing from the still-open pool
(`2048`, `minesweeper`, `resistors`, `hex_viewer`, `image_viewer`,
`boilerplate`, `qrcode`, `barcode_gen`, `crypto_dictionary`) can reintroduce
a private-save-file pick and category spread, the same way this project
has always sequenced "simplest first, then broaden."

## Import order recommendation

1. `sd_info` first — single file, read-only, simplest possible storage
   profile (a read without even a save file) — mirrors how
   `flipfetch`/`flipper95` served as build-health sanity checks in prior
   batches.
2. `fcc_id_lookup` second — same zero-write profile, confirms the
   pipeline handles a second, independent bundled-data-reading app
   cleanly.
3. `docviewlite` third and last — the one app in this batch whose
   behavior depends on a user-selected file at runtime rather than only
   bundled/fixed data, so any file-handling edge case is isolated to the
   final, most-scrutinized step.

## What this batch explicitly is not

- Not an import. No files from any of these 3 apps have been copied into
  `applications/` or `applications_user/` in this phase.
- Not a build attempt. No `fbt`/`fbt.cmd` invocation was made against any
  of these 3 apps.
- Not a claim that these 3 are bug-free, hardware-tested, or
  release-ready — only their safety/capability profile (via the existing
  Phase 1.6 audit) has been reviewed.
- Not authorization to proceed. See `PHASE2C_GO_NO_GO.md` for the
  conditions that must be met before an actual implementation phase can
  begin, and note that even a clean GO here requires the project owner's
  own separate, explicit request to start Phase 2C.1 verification, let
  alone import.

# Phase 2E — Recommended Batch

Docs only. Planning only. Recommends a tiny batch drawn from
`docs/PHASE2E_CANDIDATE_REVIEW.md`'s 6-app pool. **Nothing in this
document imports, copies, or builds any app.**

## Recommended tiny batch (3 apps)

| Import order | App | Category | Source path (expected) | Risk class | Validation difficulty (expected) |
|---|---|---|---|---|---|
| 1 | `image_viewer` | Media | `applications/external/image_viewer/` | LOW | Low — 1 file, simplest in the pool |
| 2 | `boilerplate` | Tools/Educational | `applications/external/boilerplate/` | LOW | Medium — 21 files, template structure |
| 3 | `minesweeper` | Games | `applications/external/minesweeper/` | LOW | Medium — 20 files, largest pure game in the pool |

This is within the requested "ideal 2–3 apps" range. `hex_viewer`,
`qrcode`, and `barcode_gen` were deliberately left out of this specific
slice (see "Why the other 3 are not in this batch" below) — they remain
in the clean candidate pool for a subsequent batch, not rejected.

## Why each app is selected

### `image_viewer`

- **Why selected**: The cleanest, simplest candidate remaining in the
  pool — a single source file (`main.cpp`), per Phase 1.6's own audit.
  Fills a genuine gap (no image viewer currently in the accepted
  baseline) with the lowest possible build-surface risk of any candidate
  reviewed.
- **Why safe enough for planning**: Zero HAL capability hits across all 8
  classes scanned (storage, GPIO, Sub-GHz, IR, NFC/RFID/iButton, BLE,
  USB/HID). Storage behavior is described as reading a user-selected
  image only — no write behavior identified. This phase's own special
  caution ("must be checked for read-only file behavior and no unsafe
  file writes") is treated as a Phase 2E.1 confirmation requirement, not
  a blocker to planning-stage inclusion, consistent with how this
  project has always sequenced storage confirmation.
- **Expected category**: Media (matches its existing `fap_category`
  declaration per Phase 1.5).
- **Expected risk level**: LOW.
- **Expected validation difficulty**: Low — smallest file count of any
  candidate in this or any prior batch's recommended set.

### `boilerplate`

- **Why selected**: Not selected merely to fill the batch — per Phase
  1.5's and Phase 1.6's own language, it is "directly useful for this
  project's own future app development, not just an end-user feature"
  and "itself directly useful as this project's own dev-tool reference."
  A FAP starter-project template has standing value to this project
  independent of any end-user feature count.
- **Why safe enough for planning**: Zero HAL capability hits. Storage
  behavior is explicitly "demonstrates a save-file pattern" — the same
  well-understood app-private pattern already proven safe by
  `chess`/`sudoku`/`2048`, not an ambiguous "touches storage APIs"
  description.
- **Expected category**: Tools/Educational (matches its existing
  `fap_category` declaration).
- **Expected risk level**: LOW.
- **Expected validation difficulty**: Medium — 21 files (helpers/views/
  scenes), the largest file count in this specific batch, though
  structurally a template app rather than a feature-dense one.

### `minesweeper`

- **Why selected**: A well-known, popular game genuinely missing from
  the accepted baseline's Games category (currently `chess`, `sudoku`,
  `2048`). Rounds out the Games category with a fourth, distinct title.
- **Why safe enough for planning**: Zero HAL capability hits. Storage
  behavior is explicitly confirmed via a dedicated storage helper
  (`helpers/mine_sweeper_storage.c`) for save/config — the same
  app-private pattern already proven safe by `chess`/`sudoku`/`2048`,
  satisfying this phase's own special caution ("should be checked for
  app-private save/high-score behavior only" — the existing citation
  already describes exactly that pattern, to be confirmed directly at
  Phase 2E.1).
- **Expected category**: Games (matches its existing `fap_category`
  declaration).
- **Expected risk level**: LOW.
- **Expected validation difficulty**: Medium — 20 files, "the largest
  file count of the pure games" per Phase 1.6's own note; budget extra
  build-verification time, the same discipline already applied to
  `chess`/`hex_viewer`/`upython` in prior phases.

## Why `hex_viewer`, `qrcode`, and `barcode_gen` are not in this batch

Not rejected — all 3 remain in the candidate pool for a later batch. Not
selected for this specific tiny slice because each has a storage
description in the existing audit that does not explicitly rule out a
write:

- **`hex_viewer`**: "2 files touch storage APIs" — does not explicitly
  confirm read-only behavior the way `resistors`'s "**None**" did for a
  true zero-storage app.
- **`qrcode`**: storage field is simply "Local" with no further detail at
  all — the weakest evidence of any candidate in the entire pool.
- **`barcode_gen`**: "3 files touch storage" — same ambiguity as
  `hex_viewer`.

Given this project's own Phase 2C.1 experience finding a real,
previously-unassumed storage write in `sd_info` (planning assumed
zero-storage; a fresh source read found real, controlled writes), this
phase treats that same kind of ambiguity as a reason to defer these 3 to
a later batch — where a fresh Phase-X.1 source read can resolve it
directly — rather than assume read-only behavior for this batch's own
sake. This mirrors exactly how Phase 2D's own planning treated the same
3 apps for the same reason.

## Import order recommendation

1. **`image_viewer`** first — simplest file count (1 file), most
   confidently read-only description of the 3, lowest possible
   build-surface risk. Mirrors how `flipfetch`/`quadratic_solver` (single-
   file apps) were sequenced first in prior batches.
2. **`boilerplate`** second — moderate file count (21), explicit
   app-private save-file pattern, real standing dev-tool value.
3. **`minesweeper`** third — largest file count (20) and the only one of
   the 3 whose "largest pure game" classification suggests the longest
   real build-verification effort; sequencing it last means any
   build-time or asset-size surprise is isolated to the final,
   most-time-consuming import rather than blocking the other two.

Each app is imported, committed, and validated (Static, then Build)
individually before the next begins — no batch-wide commit, per this
project's standing one-app-at-a-time discipline (see
`docs/PHASE2E_INTEGRATION_PLAN.md`).

## What this document does not do

- Does not import any app.
- Does not modify `applications/`, `applications_user/`, or any firmware
  source.
- Does not run a build.
- Does not touch hardware or run `HardwareAssisted` mode.
- Does not claim release-ready or hardware-tested status.

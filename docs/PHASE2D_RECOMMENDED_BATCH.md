# Phase 2D — Recommended Batch

Docs only. Planning only. **No code has been imported.** This selects a
tiny candidate batch from the 9-app pool in `docs/PHASE2D_CANDIDATE_REVIEW.md`
for a *future*, separately-approved implementation phase — the same
"selection is not an action" discipline every prior batch-recommendation
document in this project has used.

## Selection logic

Every prior batch picked the most conservative possible slice first:
least storage/hardware footprint, simplest file structure, strongest
evidence quality, before anything larger or more ambiguous. This
recommendation applies the identical logic here, with one specific
addition learned from Phase 2C.1's real finding: apps whose Phase 1.6
storage description is vague or ambiguous about read-vs-write behavior
(`hex_viewer`, `qrcode`, `barcode_gen` — see the confidence table in
`docs/PHASE2D_CANDIDATE_REVIEW.md`) are deliberately **not** selected for
this most-conservative first slice, even though none are excluded from
the pool outright. This is not a rejection of those three — it is the
same "not the most conservative possible first slice" reasoning Phase 2B
applied to `resistors`/`boilerplate`/`hex_viewer`/`minesweeper`/
`barcode_gen` in its own recommended-batch document, now applied one
level more precisely using the specific evidence-quality distinction this
phase's own candidate review surfaced.

## The recommended tiny batch: 3 apps

### 1. `resistors`

- **Source path**: `applications/external/resistors/`
- **Expected category**: Tools
- **Why selected**: Confirmed by the Phase 1.6 source audit to have
  **zero** storage of any kind ("**None**" — the most explicit, most
  confident storage classification in the entire 9-app pool) and zero
  hardware-peripheral API usage. A resistor color-code calculator — pure
  computation, directly analogous in risk profile to
  `programmer_calc`/`quadratic_solver`, both already accepted.
- **Why safe enough for planning**: No HAL capability hits of any class;
  the cleanest possible storage classification available in this pool.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Low-Medium — 13 files, and Phase
  1.5 separately flagged a disproportionately large ~2.3MB on-disk
  footprint (likely icon/reference assets) worth budgeting extra
  build-verification time for, the same discipline already applied to
  `chess`/`upython` in prior phases.

### 2. `crypto_dictionary`

- **Source path**: `applications/external/crypto_dictionary/`
- **Expected category**: Tools/Educational
- **Why selected**: Confirmed by the Phase 1.6 source audit to be "a
  pure reference/glossary app, no crypto *operations* performed on user
  data" — reads bundled cipher-glossary text resources only, zero
  hardware-peripheral API usage. This is exactly the "offline glossary"
  case the project owner's special-caution instruction for this app
  names as acceptable to keep in planning (as opposed to a wallet/key/
  credential/seed-phrase-handling tool, which it is confirmed not to be).
- **Why safe enough for planning**: Audited, zero capability hits;
  storage behavior is explicitly read-only (bundled text), the second
  most explicit storage classification in this pool after `resistors`.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Low-Medium — 13 files plus bundled
  reference text; the bundled glossary's own content provenance (not a
  safety question, a documentation-attribution one) should be spot-checked
  at Phase 2D.1, per `docs/PHASE2D_LICENSE_REVIEW.md`.

### 3. `2048`

- **Source path**: `applications/external/2048/`
- **Expected category**: Games
- **Why selected**: Confirmed by the Phase 1.6 source audit to have
  zero hardware-peripheral API usage, with storage limited to a
  private high-score save — the same app-private-storage pattern
  already proven safe twice in this project (`chess` in Phase 2A,
  `sudoku` in Phase 2B), and the simplest possible file count (4 files)
  of any app in the pool that exercises that pattern. Also gives this
  tiny batch a second category (Games) instead of an all-Tools batch,
  reintroducing the private-save-file pick this project's own Phase 2C
  recommended-batch document noted a future batch could bring back.
- **Why safe enough for planning**: Audited, zero HAL capability hits;
  private-storage-only pattern is well understood from `chess`'s and
  `sudoku`'s own precedent, and — unlike `sd_info`'s real Phase 2C.1
  surprise — this is explicitly described as a conventional save-file
  write, not a shared-directory or SD-card-root write, in the existing
  audit.
- **Expected risk level**: LOW
- **Expected validation difficulty**: Very low — 4 files, one
  well-understood app-private storage write to confirm at actual import
  time (the exact private path is not yet confirmed in this phase and
  should be recorded at Phase 2D.1, the same discipline already applied
  to `sudoku`'s path before it existed).

## Why `hex_viewer`, `qrcode`, `barcode_gen`, `minesweeper`, `image_viewer`, and `boilerplate` are not in this batch

Not rejected — all 6 remain in the candidate pool for a later batch. Not
selected for this specific tiny slice because:

- **`hex_viewer`, `qrcode`, `barcode_gen`** — each has a storage
  description in the existing audit that does not explicitly rule out a
  write ("touch storage APIs," or, for `qrcode`, simply "Local" with no
  further detail at all). Given this project's own Phase 2C.1 experience
  finding a real, previously-unassumed storage write in `sd_info`, this
  phase treats that same kind of ambiguity as a reason to defer to a
  later batch (where a fresh Phase-X.1 source read can resolve it
  directly) rather than assume read-only behavior for a "most
  conservative first slice."
- **`minesweeper`** — same private-save pattern as `2048`, but larger
  (20 files, "largest file count of the pure games" per Phase 1.6) —
  reasonable for a *second* batch, not needed alongside `2048` for the
  same role in this one.
- **`image_viewer`** — otherwise clean and simple (1 file), but bundles
  3 example bitmap files whose own provenance is unconfirmed (see
  `docs/PHASE2D_CANDIDATE_REVIEW.md`) — a license-evidence question, not
  a safety one, but one this phase prefers to resolve in a dedicated
  pass rather than wave through in the most conservative slice.
- **`boilerplate`** — per the project owner's own explicit instruction,
  not selected merely to fill the batch; it is a dev-tool template
  rather than an end-user app, and its inclusion is a separate decision
  for a future batch, not automatic.

## Import order recommendation

1. `resistors` first — zero storage, zero hardware, the cleanest
   possible classification in the pool; mirrors how `flipfetch`/
   `sd_info` served as build-health sanity checks in prior batches.
2. `crypto_dictionary` second — same zero-write-storage profile
   (read-only bundled text), confirms the pipeline handles a second,
   independent zero-write app cleanly.
3. `2048` third and last — the one app in this batch that writes to
   storage at all (private high-score save only); sequencing it last
   means any storage-related build/validation issue is isolated to the
   final, most-scrutinized step, the same ordering discipline every
   prior batch in this project has used for its one storage-touching
   pick.

## What this batch explicitly is not

- Not an import. No files from any of these 3 apps have been copied into
  `applications/` or `applications_user/` in this phase.
- Not a build attempt. No `fbt`/`fbt.cmd` invocation was made against any
  of these 3 apps.
- Not a claim that these 3 are bug-free, hardware-tested, or
  release-ready — only their safety/capability profile (via the existing
  Phase 1.6 audit) has been reviewed.
- Not authorization to proceed. See `docs/PHASE2D_GO_NO_GO.md` for the
  conditions that must be met before an actual implementation phase can
  begin, and note that even a clean GO here requires the project owner's
  own separate, explicit request to start Phase 2D.1 verification, let
  alone import.

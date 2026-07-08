# Phase 2E — Candidate Review

Docs only. Planning only. **No code has been imported, no application
source has been freshly read in this phase.** This review is grounded
entirely in the already-completed Phase 1.5/1.6 audit work and the Phase
2B/2C/2D planning and import record, re-screened against the now-13-app
accepted Phase 2D baseline. Where existing audit evidence is insufficient
to make a claim, this document says `NEEDS REVIEW` rather than guessing.
This phase did not attempt a fresh network read of the RogueMaster source
tree — real source/license re-verification is explicitly deferred to
Phase 2E.1, per `docs/PHASE2E_NEXT_GATE.md`, the same sequencing every
prior planning phase in this project has followed.

## Source docs consulted

| Doc | What it contributed |
|---|---|
| `PHASE1_5_HIGH_VALUE_SHORTLIST.md` | 195-app candidate pool, first-pass metadata triage |
| `PHASE1_5_TOP_25_CANDIDATES.md` | The 25-app shortlist every phase in this project has drawn from |
| `PHASE1_6_TOP25_SOURCE_AUDIT.md` | The individual `.c`/`.h`/`.cpp` source audit of all 25 (real API-usage grep + read, against RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) — the primary evidence base for this review, re-read verbatim in this phase to avoid relying on memory of prior citations |
| `docs/PHASE2D_CANDIDATE_REVIEW.md`, `docs/PHASE2D_RECOMMENDED_BATCH.md` | Phase 2D's own planning pass over the post-2C pool — confirms exactly which 6 apps remained un-selected after Phase 2D's batch, and the exact reasoning for each (this is the direct ancestor of this document's candidate pool) |
| `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`, `docs/PHASE2D_2_SAFETY_REVIEW.md` | The real, fresh-source-read lesson this project keeps re-learning: a citation-only review can miss a real storage-behavior detail (`sd_info`'s SD-benchmark writes were the original instance; this phase applies the same caution to `hex_viewer`/`qrcode`/`barcode_gen`'s own storage ambiguity below) |
| `docs/PHASE2D_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md` | Confirms the current accepted 13-app baseline and hardware-gate status (`BLOCKED - DEVICE NOT AVAILABLE`), to correctly exclude already-imported apps |
| `docs/KNOWN_ISSUES.md` | `fcc_id_lookup`'s open license-evidence gap (item 6) and the hardware-unavailability item (item 3), both confirmed still open and out of scope for this phase |

No new source files were fetched or read in this phase. All per-app
capability findings below are the Phase 1.6 audit's findings, cited
verbatim, not re-derived.

## Already-imported apps excluded

All 13 apps currently in the accepted Phase 2D baseline are removed from
consideration entirely: `network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`, `flipfetch`, `quadratic_solver`,
`sudoku`, `sd_info`, `docviewlite`, `resistors`, `crypto_dictionary`,
`2048`.

## Deferred apps excluded and why

These 6 are excluded from this phase's candidate pool outright, per the
project owner's explicit instruction, and are not re-reviewed here:

| App | Why previously flagged |
|---|---|
| `fcc_id_lookup` | The RogueMaster-vendored copy has no `LICENSE` file, no SPDX identifier, no copyright header anywhere in its source (Phase 2C.1 finding, `docs/KNOWN_ISSUES.md` item 6). Strong corroborating MIT evidence exists at the true upstream repository but is not commit-pinned to the vendored revision. Per explicit instruction, not resolved and not re-reviewed in this phase — requires a separate, narrow license-resolution phase. |
| `upython` | Real `furi_hal_gpio_write`/`furi_hal_gpio_read`/GPIO-interrupt bindings and real `furi_hal_infrared_async_tx_start` (IR transmit) exposed to any user-authored MicroPython script. Safety-exclusion list — hardware/control capability risk. |
| `iconedit` | `panels/send_usb.c` calls `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` directly — mechanically USB HID keystroke injection. Safety-exclusion list. |
| `c_book` | Bundles verbatim `.txt` chapters of "The C Programming Language" (K&R, Prentice Hall) — a commercially published, copyrighted work with no confirmed distribution right. Unresolved copyright question. |
| `animation_switcher` | Writes to the shared `/ext/dolphin/manifest.txt`, not app-private storage. |
| `theme_manager` | Writes to `/ext/dolphin/` (with a confirmed backup step), same shared-directory consideration as `animation_switcher`. |

No new evidence was gathered on any of these 6 in this phase — this is a
restatement of the existing record, per the task's explicit "do not
reopen `fcc_id_lookup`" instruction and the project owner's explicit list
of the other 5.

## Candidate pool considered (6 apps)

The Phase 1.5 Top 25, minus the 13 already-imported apps and the 6
excluded apps above, leaves exactly the 6 candidates the project owner's
own instructions named — the same 6 Phase 2D's own planning explicitly
held back for "a later batch":

| # | App | Category | Phase 1.6 audit decision | File count | Storage behavior (verbatim from Phase 1.6) | Hardware behavior |
|---|---|---|---|---|---|---|
| 1 | `minesweeper` | Games | APPROVE | 20 | Local/private (save/config via `helpers/mine_sweeper_storage.c`) | None |
| 2 | `hex_viewer` | Tools | APPROVE | 20 | Local (reads the file the user opens; 2 files touch storage APIs) | None |
| 3 | `image_viewer` | Media | APPROVE | 1 (+3 bundled example bitmaps) | Local (reads user-selected image) | None |
| 4 | `boilerplate` | Tools/Educational | APPROVE | 21 | Local (demonstrates a save-file pattern) | None |
| 5 | `qrcode` | Tools | APPROVE | 3 | Local | None |
| 6 | `barcode_gen` | Tools | APPROVE | 16 (+4 bundled encoding tables) | Local (reads bundled tables + user text; 3 files touch storage) | None |

## Candidates kept for possible Phase 2E

All 6 above remain in the pool as safe-enough-for-planning at the
capability level (zero hardware-peripheral hits across all 6, per Phase
1.6's 8-class HAL scan: storage, GPIO, Sub-GHz, IR, NFC/RFID/iButton,
BLE, USB/HID, plus a generic unsafe-keyword pass). `docs/PHASE2E_RECOMMENDED_BATCH.md`
selects a tiny subset for actual near-term recommendation and leaves the
rest for a later batch — none are rejected outright by this review.

## Safety-screening summary

All 6 candidates were confirmed by the Phase 1.6 source audit to have
**zero** matches against the eight HAL capability classes scanned. None
touch any capability on this project's safety-exclusion list. Applying
this phase's specific special-caution instructions:

- **`qrcode`/`barcode_gen`**: both are confirmed local display/generation
  utilities only — `qrcode` "displays QR codes from user input,"
  `barcode_gen` "displays barcodes from user input using bundled encoding
  tables." Neither has any network, credential, scanner-emulation, HID,
  or NFC behavior per the Phase 1.6 capability scan (zero HAL hits for
  either). Flipper Zero itself has no camera, so "scanner emulation" is
  not even physically possible for either app on this hardware. Per this
  phase's own caution instruction ("if either includes network behavior,
  credential handling, scanner emulation, HID, NFC, access-control
  behavior, or stored sensitive payload workflows, mark DEFER"), neither
  meets any of those disqualifying conditions per the existing audit —
  but see the storage-behavior caution below, which is the actual reason
  neither is in this phase's recommended batch.
- **`hex_viewer`/`image_viewer`**: per this phase's own caution
  instruction ("must be checked for read-only file behavior and no
  unsafe file writes"), neither has been freshly re-verified in this
  citation-only phase. `hex_viewer`'s Phase 1.6 record ("2 files touch
  storage APIs") does not explicitly confirm read-only; `image_viewer`'s
  record ("Local (reads user-selected image)") is somewhat more
  confidently read-only-worded but still not exhaustively confirmed. See
  the storage/hardware behavior summary below for how each is treated as
  a result.
- **`minesweeper`**: per this phase's own caution instruction ("should be
  checked for app-private save/high-score behavior only"), Phase 1.6
  explicitly confirms save/config via a dedicated storage helper
  (`helpers/mine_sweeper_storage.c`) — the same well-understood
  app-private pattern already proven safe by `chess`/`sudoku`/`2048`. No
  indication of any write outside an app-private path in the existing
  record; the exact path itself is not yet confirmed (see risk register).
- **`boilerplate`**: per this phase's own caution instruction ("should
  not be selected merely to fill the batch unless it is a real useful
  app with clean build value and clear licensing"), Phase 1.6's own
  language is that it is "exactly what it says — a FAP starter template,
  itself directly useful as this project's own dev-tool reference" — a
  real, standing justification independent of batch-filling, carried
  forward from Phase 1.5's own note ("directly useful for this project's
  own future app development, not just an end-user feature").

## License-screening summary

**This is the same gap every prior planning phase in this project has
documented, and it is still open for all 6 of these apps.** The Phase 1.6
audit screened for hardware capability and storage behavior, not per-app
SPDX license identifiers or bundled-content copyright status. Real
license verification (the Phase 2B.1/2C.1/2D.1 pattern: a fresh network
read of each app's actual `LICENSE` file at the pinned RogueMaster
commit) has not been repeated for any of these 6 in this phase, because
this phase is planning-only and explicitly does not re-verify sources.

One candidate carries an extra, specific note beyond the routine gap:

- **`image_viewer`** bundles 3 example `.bm` bitmap files as resources.
  Unlike `barcode_gen`'s encoding tables (implementations of public
  technical standards) or a glossary's definitional text, example bitmap
  images could plausibly be original artwork with their own provenance
  question — flagged, not resolved, the same note carried forward
  unchanged from `docs/PHASE2D_CANDIDATE_REVIEW.md`.
- **`barcode_gen`**'s bundled encoding tables (Code39/128/128C/Codabar)
  are very likely implementations of public technical standards (barcode
  symbologies are published specifications, not creative works), but this
  has not been confirmed against an actual license/attribution file in
  any phase to date.

All other candidates either have no bundled third-party content at all,
or bundle content whose nature makes a copyright block unlikely — none of
this is confirmed against an actual `LICENSE` file in this phase. See
`docs/PHASE2E_LICENSE_REVIEW.md` for the honest per-recommended-app
confidence level.

## Dependency-surface summary

Per the Phase 1.6 audit, none of the 6 candidates declare external
`requires=[...]` dependencies beyond the default FAP toolchain. File
counts range from 1 (`image_viewer`) to 21 (`boilerplate`). `minesweeper`
(20 files) is "the largest file count of the pure games" per Phase 1.6's
own note, worth budgeting extra build-verification time for, consistent
with how this project has treated similarly file-heavy apps (`chess`,
`hex_viewer`, `upython`) in prior phases.

## Storage/hardware behavior summary

- **Private-storage writes** (own save/config file, the same
  app-private pattern already proven safe by `chess`/`sudoku`/`2048`):
  `minesweeper` (save/config), `boilerplate` (demonstration save
  pattern).
- **Read-only local storage only** (per Phase 1.6's description, not yet
  independently re-confirmed in this phase): `hex_viewer`, `image_viewer`,
  `qrcode`, `barcode_gen`. **Caution, carried forward unchanged from
  Phase 2D's own planning**: Phase 1.6's own wording for `hex_viewer`
  ("2 files touch storage APIs") and `barcode_gen` ("3 files touch
  storage") does not explicitly rule out a write call the same way it
  explicitly did for zero-storage apps like `resistors` ("**None**") —
  this project's own Phase 2C.1 experience with `sd_info` (assumed
  zero-storage in planning, found to have real writes on fresh source
  read) is the exact reason this ambiguity is flagged here rather than
  resolved by assumption. `qrcode`'s Phase 1.6 storage field is simply
  "Local" with no further detail at all — the weakest evidence of any
  candidate in this pool. `image_viewer`'s field ("reads user-selected
  image") is more confidently read-only-worded, but still not
  exhaustively confirmed against the actual source in this phase.

## Confidence level per candidate

| App | Safety confidence | License confidence | Storage-behavior confidence | Build-risk confidence | Overall |
|---|---|---|---|---|---|
| `minesweeper` | High | Medium (no SPDX check performed) | High (explicitly save/config via a dedicated storage helper) | Medium (20 files, largest pure game in the pool) | Medium-High |
| `hex_viewer` | High | Medium | **Medium — read-vs-write not explicitly confirmed** ("2 files touch storage APIs") | Medium (20 files) | Medium |
| `image_viewer` | High | Medium (bundled bitmaps, provenance not confirmed) | Medium-High (described as read-only, not exhaustively confirmed) | High (1 file) | Medium-High |
| `boilerplate` | High | Medium | High (explicitly a save-file demonstration) | Medium (21 files) | Medium-High |
| `qrcode` | High | Medium | **Low-Medium — storage field is bare "Local" with no further detail** | High (3 files) | Medium |
| `barcode_gen` | High | Medium (bundled tables likely standard-format data, not confirmed) | **Medium — read-vs-write not explicitly confirmed** ("3 files touch storage") | Medium (16 files + bundled tables) | Medium |

"Medium" license confidence across the whole pool reflects an honest
gap, not a specific finding of a problem — the same status every prior
planning phase in this project has recorded before its own Phase-X.1
verification pass closed it. `docs/PHASE2E_LICENSE_REVIEW.md` recommends
the same be done for whichever apps this package recommends, before any
actual import commit.

## Stop point

This is a review only. No app listed here has been copied into
`applications/` or `applications_user/`, no build was attempted, and no
decision beyond "worth recommending for the next planning artifact" was
made. See `docs/PHASE2E_RECOMMENDED_BATCH.md` for the actual tiny-batch
recommendation drawn from this pool.

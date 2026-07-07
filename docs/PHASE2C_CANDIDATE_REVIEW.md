# Phase 2C — Candidate Review

Docs only. Planning only. **No code has been imported, no application
source has been freshly read in this phase.** This review is grounded
entirely in the already-completed Phase 1.5/1.6 audit work and the Phase
2B planning/import record, re-screened against the now-larger set of 8
apps already accepted into the baseline. Where existing audit evidence is
insufficient, this document says `NEEDS REVIEW` rather than guessing. This
phase did not attempt a fresh network read of the RogueMaster source tree
(unlike Phase 2B.1, which had that access for a narrow, separately
approved verification pass) — real source/license re-verification is
explicitly deferred to Phase 2C.1, per `docs/PHASE2C_NEXT_GATE.md`.

## Source docs consulted

| Doc | What it contributed |
|---|---|
| `PHASE1_5_HIGH_VALUE_SHORTLIST.md` | 195-app candidate pool, first-pass metadata triage |
| `PHASE1_5_TOP_25_CANDIDATES.md` | The 25-app shortlist this review (still) starts from — no app outside this list has ever been considered by any phase |
| `PHASE1_5_EXCLUSION_LIST.md` | What was already excluded before the Top 25 existed |
| `PHASE1_6_TOP25_SOURCE_AUDIT.md` | The individual `.c`/`.h`/`.cpp` source audit of all 25 (real API-usage grep + read, against RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) — the primary evidence base for this review |
| `PHASE1_6_FIRST_BATCH_SELECTION.md`, `PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md` | Which apps became Phase 2A and why; the deferred/noted items in isolation |
| `docs/PHASE2B_CANDIDATE_REVIEW.md`, `docs/PHASE2B_RECOMMENDED_BATCH.md`, `docs/PHASE2B_RISK_REGISTER.md`, `docs/PHASE2B_LICENSE_REVIEW.md` | Phase 2B's own planning pass over the post-2A pool — this review's direct predecessor and template |
| `docs/PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`, `docs/PHASE2B_1_IMPORT_READINESS_MATRIX.md`, `docs/PHASE2B_1_GO_NO_GO.md` | Confirms real MIT license findings for `flipfetch`/`quadratic_solver`/`sudoku` (now imported) — evidence those 3 are correctly excluded here, not a source for the Phase 2C pool itself |
| `docs/PHASE2B_2_IMPORT_LOG.md`, `docs/PHASE2B_2_SAFETY_REVIEW.md`, `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md` | Confirms exactly what was imported in Phase 2B.2 and on what evidence, so this review excludes the right 3 apps |
| `docs/PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` | Reused discipline: a prior audit pass can miss a real licensing problem (chess's SAM component) that only a dedicated review catches — applied again below to flag rather than clear anything on citation alone |

No new source files were fetched or read in this phase. All per-app
capability findings below are the Phase 1.6 audit's findings, cited, not
re-derived.

## Already-imported apps excluded

All 8 apps currently in the accepted Phase 2B baseline are removed from
consideration entirely:

`network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95`, `chess`
(Phase 2A) and `flipfetch`, `quadratic_solver`, `sudoku` (Phase 2B).

## Hard-deferred apps excluded (per this phase's explicit instructions)

These 5 are excluded from this phase's candidate pool outright, per the
project owner's explicit instruction, and are not re-reviewed here:

| App | Why previously flagged (from Phase 1.6 / Phase 2B) |
|---|---|
| `upython` | Real `furi_hal_gpio_write`/`furi_hal_gpio_read`/GPIO-interrupt bindings and real `furi_hal_infrared_async_tx_start` (IR transmit) exposed to any user-authored MicroPython script. On this project's explicit safety-exclusion list (GPIO write/control, IR transmit/control). |
| `iconedit` | `panels/send_usb.c` calls `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` directly — the "send to PC" feature is mechanically USB HID keystroke injection. On this project's explicit safety-exclusion list (BadUSB/HID injection). |
| `c_book` | Bundles verbatim `.txt` chapters of "The C Programming Language" (K&R, Prentice Hall) — a commercially published, copyrighted work with no confirmed distribution right. Unresolved copyright question, not a capability issue. |
| `animation_switcher` | Writes to the shared `/ext/dolphin/manifest.txt`, not app-private storage. Has its own restore logic, not unsafe, but a different storage-risk class than a private save file. |
| `theme_manager` | Writes to `/ext/dolphin/` (with a confirmed backup-to-`/ext/dolphin_backup/` step first), same shared-directory consideration as `animation_switcher`. |

No new evidence was gathered on any of these 5 in this phase — this is a
restatement of the existing record, per the task's explicit "hard-defer
unless specifically re-reviewed in a future separate phase" instruction.
None of them are recommended below.

## Candidate pool considered (12 apps)

The Phase 1.5 Top 25, minus the 8 already-imported apps and the 5
hard-deferred apps above, leaves exactly 12 candidates:

| # | App | Category | Phase 1.6 audit decision | File count | Storage behavior | Hardware behavior |
|---|---|---|---|---|---|---|
| 1 | `2048` | Games | APPROVE | 4 | Local/private (high-score save) | None |
| 2 | `minesweeper` | Games | APPROVE | 20 | Local/private (save/config) | None |
| 3 | `resistors` | Tools | APPROVE | 13 (~2.3MB assets) | None | None |
| 4 | `hex_viewer` | Tools | APPROVE | 20 | Local (reads user-selected file) | None |
| 5 | `docviewlite` | Tools | APPROVE | 1 | Local (reads user-selected document) | None |
| 6 | `image_viewer` | Media | APPROVE | 1 (+3 bundled example bitmaps) | Local (reads user-selected image) | None |
| 7 | `boilerplate` | Tools/Educational | APPROVE | 21 | Local (demonstrates save-file pattern) | None |
| 8 | `sd_info` | Tools | APPROVE | 1 | Local (reads card metadata only, read-only) | None |
| 9 | `qrcode` | Tools | APPROVE | 3 | Local (reads user input) | None |
| 10 | `barcode_gen` | Tools | APPROVE | 16 (+4 bundled encoding tables) | Local (reads bundled tables + user text) | None |
| 11 | `fcc_id_lookup` | Tools | APPROVE | 2 | Local (reads bundled data, read-only) | None |
| 12 | `crypto_dictionary` | Tools/Educational | APPROVE | 13 (+bundled reference text) | Local (reads bundled text resources) | None |

## Candidates kept for possible Phase 2C

All 12 above remain in the pool as safe-enough-for-planning. None are
rejected outright by this review; `PHASE2C_RECOMMENDED_BATCH.md` selects a
tiny subset for actual near-term recommendation and leaves the rest for a
later batch.

## Safety-screening summary

All 12 candidates were confirmed by the Phase 1.6 source audit to have
**zero** matches against the eight HAL capability classes scanned
(storage beyond local/private/read-only use, GPIO, Sub-GHz, Infrared,
NFC/RFID/iButton, BLE, USB/HID). None touch Sub-GHz, NFC/RFID/iButton,
GPIO, Infrared transmit, BLE, or HID — the apps that did (`upython`,
`iconedit`) are already excluded above, and the two shared-storage apps
(`animation_switcher`, `theme_manager`) are hard-deferred per this phase's
instructions, not part of this 12-app pool.

## License-screening summary

**This is the same gap Phase 2B's own candidate review documented, and it
is still open for all 12 of these apps.** The Phase 1.6 audit screened for
hardware capability and storage behavior, not per-app SPDX license
identifiers or bundled-content copyright status. Phase 2B.1 later closed
this gap for 3 specific apps (`flipfetch`, `quadratic_solver`, `sudoku`)
via a real network read of their upstream `LICENSE` files — that
verification effort has not been repeated for any of these 12, because
this phase is planning-only and explicitly does not re-verify sources.

Two candidates carry an extra, specific note beyond the routine gap:

- **`image_viewer`** bundles 3 example `.bm` bitmap files as resources.
  Unlike `barcode_gen`'s encoding tables (implementations of public
  technical standards) or `fcc_id_lookup`'s database (derived from US FCC
  public records), example bitmap images could plausibly be original
  artwork with their own provenance question — not flagged as a problem,
  but flagged as needing the same kind of dedicated look Phase 2B.1 gave
  `flipfetch`/`quadratic_solver`/`sudoku`, before any import commit.
- **`crypto_dictionary`** bundles a cipher glossary as reference text.
  Unlike `c_book`'s verbatim commercial-book chapters, a glossary of
  standard cryptographic terminology is very unlikely to be an
  original-authorship copyright concern in the same way, but its
  provenance has likewise not been confirmed in any phase to date.

All other candidates either have no bundled third-party content at all, or
bundle content whose nature (public technical standards, public records)
makes a copyright block unlikely — none of this is confirmed against an
actual `LICENSE` file in this phase. See `PHASE2C_LICENSE_REVIEW.md` for
the honest per-recommended-app confidence level.

## Dependency-surface summary

Per the Phase 1.6 audit, none of the 12 candidates declare external
`requires=[...]` dependencies beyond the default FAP toolchain. File
counts range from 1 (`docviewlite`, `image_viewer`, `sd_info`) to 21
(`boilerplate`). `resistors` (13 files, ~2.3MB) and `barcode_gen`
(16 files + 4 bundled tables) have larger on-disk footprints than their
file counts alone suggest, consistent with how Phase 2B flagged the same
apps for a later, non-first batch.

## Storage/hardware behavior summary

- **Zero storage of any kind**: `resistors`.
- **Read-only local storage only** (no writes at all): `docviewlite`,
  `image_viewer`, `sd_info`, `fcc_id_lookup`, `crypto_dictionary`,
  `qrcode`, `barcode_gen`, `hex_viewer` — these read a user-selected file,
  a bundled resource, or card metadata, and do not persist any new state.
- **Private-storage writes** (own save/config file, app-private path
  pattern, same class already proven safe by `chess`/`sudoku`):
  `2048` (high-score), `minesweeper` (save/config), `boilerplate`
  (demonstration save pattern).
- **Zero hardware-peripheral behavior** (no GPIO/Sub-GHz/IR/NFC/BLE/HID)
  across all 12, confirmed by the Phase 1.6 audit's capability scan.

## Confidence level per candidate

| App | Safety confidence | License confidence | Build-risk confidence | Overall |
|---|---|---|---|---|
| `2048` | High | Medium (no SPDX check performed) | High (4 files) | High |
| `minesweeper` | High | Medium | Medium (20 files, largest pure game) | Medium-High |
| `resistors` | High | Medium | Medium (13 files, larger asset footprint) | Medium-High |
| `hex_viewer` | High | Medium | Medium (20 files) | Medium-High |
| `docviewlite` | High | Medium | High (1 file) | High |
| `image_viewer` | High | Medium (bundled bitmaps, provenance not confirmed) | High (1 file) | Medium-High |
| `boilerplate` | High | Medium | Medium (21 files) | Medium-High |
| `sd_info` | High | Medium | High (1 file, read-only) | High |
| `qrcode` | High | Medium | High (3 files) | High |
| `barcode_gen` | High | Medium (bundled tables likely standard-format data, not confirmed) | Medium (16 files + bundled tables) | Medium-High |
| `fcc_id_lookup` | High | Medium (bundled DB likely public-record data, not confirmed) | High (2 files, read-only) | High |
| `crypto_dictionary` | High | Medium (bundled glossary text, provenance not confirmed) | Medium (13 files + bundled text) | Medium |

"Medium" license confidence across the whole pool reflects an honest gap,
not a specific finding of a problem — the same status Phase 2B's review
gave `flipfetch`/`quadratic_solver`/`sudoku` before Phase 2B.1 closed it
with a real source read. `PHASE2C_LICENSE_REVIEW.md` recommends the same
be done for whichever apps this package recommends, before any actual
import commit.

## Stop point

This is a review only. No app listed here has been copied into
`applications/` or `applications_user/`, no build was attempted, and no
decision beyond "worth recommending for the next planning artifact" was
made. See `PHASE2C_RECOMMENDED_BATCH.md` for the actual tiny-batch
recommendation drawn from this pool.

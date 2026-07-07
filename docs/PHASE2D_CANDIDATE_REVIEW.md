# Phase 2D — Candidate Review

Docs only. Planning only. **No code has been imported, no application
source has been freshly read in this phase.** This review is grounded
entirely in the already-completed Phase 1.5/1.6 audit work and the Phase
2C planning/import record, re-screened against the now-10-app accepted
baseline. Where existing audit evidence is insufficient to make a claim,
this document says `NEEDS REVIEW` rather than guessing. This phase did
not attempt a fresh network read of the RogueMaster source tree — real
source/license re-verification is explicitly deferred to Phase 2D.1, per
`docs/PHASE2D_NEXT_GATE.md`, the same sequencing every prior planning
phase in this project has followed.

## Source docs consulted

| Doc | What it contributed |
|---|---|
| `PHASE1_5_HIGH_VALUE_SHORTLIST.md` | 195-app candidate pool, first-pass metadata triage |
| `PHASE1_5_TOP_25_CANDIDATES.md` | The 25-app shortlist every phase in this project has drawn from |
| `PHASE1_6_TOP25_SOURCE_AUDIT.md` | The individual `.c`/`.h`/`.cpp` source audit of all 25 (real API-usage grep + read, against RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) — the primary evidence base for this review, re-read verbatim in this phase to avoid relying on memory of prior citations |
| `docs/PHASE2C_CANDIDATE_REVIEW.md`, `docs/PHASE2C_RECOMMENDED_BATCH.md` | Phase 2C's own planning pass over the post-2B pool — confirms exactly which 9 apps remained un-selected after Phase 2C's batch, and why |
| `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`, `docs/PHASE2C_2_SAFETY_REVIEW.md` | The real, fresh-source-read lesson this project keeps re-learning: a citation-only review can miss a real storage-behavior detail (`sd_info`'s SD-benchmark writes) that only a dedicated Phase-X.1-style source read catches — applied here as a reason to flag, not assume, several apps' exact storage behavior below |
| `docs/PHASE2C_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md` | Confirms the current accepted 10-app baseline and hardware-gate status, to correctly exclude already-imported apps |
| `docs/KNOWN_ISSUES.md` | `fcc_id_lookup`'s open license-evidence gap (item 6), confirmed still open and out of scope for this phase |

No new source files were fetched or read in this phase. All per-app
capability findings below are the Phase 1.6 audit's findings, cited
verbatim, not re-derived.

## Already-imported apps excluded

All 10 apps currently in the accepted Phase 2C baseline are removed from
consideration entirely: `network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`, `flipfetch`, `quadratic_solver`,
`sudoku`, `sd_info`, `docviewlite`.

## Deferred apps excluded and why

These 6 are excluded from this phase's candidate pool outright, per the
project owner's explicit instruction, and are not re-reviewed here:

| App | Why previously flagged |
|---|---|
| `upython` | Real `furi_hal_gpio_write`/`furi_hal_gpio_read`/GPIO-interrupt bindings and real `furi_hal_infrared_async_tx_start` (IR transmit) exposed to any user-authored MicroPython script. Safety-exclusion list. |
| `iconedit` | `panels/send_usb.c` calls `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` directly — mechanically USB HID keystroke injection. Safety-exclusion list. |
| `c_book` | Bundles verbatim `.txt` chapters of "The C Programming Language" (K&R, Prentice Hall) — a commercially published, copyrighted work with no confirmed distribution right. Unresolved copyright question. |
| `animation_switcher` | Writes to the shared `/ext/dolphin/manifest.txt`, not app-private storage. |
| `theme_manager` | Writes to `/ext/dolphin/` (with a confirmed backup step), same shared-directory consideration as `animation_switcher`. |
| `fcc_id_lookup` | **Deferred, not hard-excluded for capability reasons** — the RogueMaster-vendored copy has no `LICENSE` file, no SPDX identifier, no copyright header anywhere in its source (Phase 2C.1 finding, `docs/KNOWN_ISSUES.md` item 6). Strong corroborating MIT evidence exists at the true upstream repository but is not commit-pinned to the vendored revision. Per explicit instruction, not resolved and not re-reviewed in this phase — remains excluded from Phase 2D planning entirely, not merely "kept in the pool for later." |

No new evidence was gathered on any of these 6 in this phase — this is a
restatement of the existing record, per the task's explicit "hard-defer
unless specifically re-reviewed in a future separate phase" instruction.

## Candidate pool considered (9 apps)

The Phase 1.5 Top 25, minus the 10 already-imported apps and the 6
excluded apps above, leaves exactly the 9 candidates the project owner's
own instructions named:

| # | App | Category | Phase 1.6 audit decision | File count | Storage behavior (verbatim from Phase 1.6) | Hardware behavior |
|---|---|---|---|---|---|---|
| 1 | `2048` | Games | APPROVE | 4 | Local/private (high-score save) | None |
| 2 | `minesweeper` | Games | APPROVE | 20 | Local/private (save/config via `helpers/mine_sweeper_storage.c`) | None |
| 3 | `resistors` | Tools | APPROVE | 13 (~2.3MB assets) | **None** | None |
| 4 | `hex_viewer` | Tools | APPROVE | 20 | Local (reads the file the user opens; 2 files touch storage APIs) | None |
| 5 | `image_viewer` | Media | APPROVE | 1 (+3 bundled example bitmaps) | Local (reads user-selected image) | None |
| 6 | `boilerplate` | Tools/Educational | APPROVE | 21 | Local (demonstrates a save-file pattern) | None |
| 7 | `qrcode` | Tools | APPROVE | 3 | Local | None |
| 8 | `barcode_gen` | Tools | APPROVE | 16 (+4 bundled encoding tables) | Local (reads bundled tables + user text; 3 files touch storage) | None |
| 9 | `crypto_dictionary` | Tools/Educational | APPROVE | 13 (+bundled reference text) | Local (reads bundled text resources) | None |

## Candidates kept for possible Phase 2D

All 9 above remain in the pool as safe-enough-for-planning at the
capability level (zero hardware-peripheral hits across all 9, per Phase
1.6's 8-class HAL scan). `docs/PHASE2D_RECOMMENDED_BATCH.md` selects a
tiny subset for actual near-term recommendation and leaves the rest for a
later batch — none are rejected outright by this review.

## Safety-screening summary

All 9 candidates were confirmed by the Phase 1.6 source audit to have
**zero** matches against the eight HAL capability classes scanned
(Sub-GHz, NFC/RFID/iButton, GPIO, Infrared transmit, BLE, USB/HID, plus
storage and a generic unsafe-keyword pass). None touch any capability on
this project's safety-exclusion list. Applying this phase's specific
special-caution instructions to the two apps named explicitly:

- **`qrcode`/`barcode_gen`**: both are confirmed local display/generation
  utilities only — `qrcode` "displays QR codes from user input,"
  `barcode_gen` "displays barcodes from user input using bundled encoding
  tables." Neither has any network, credential, scanner-emulation, HID,
  or NFC behavior per the Phase 1.6 capability scan (zero HAL hits for
  either). Flipper Zero itself has no camera, so "scanner emulation" is
  not even physically possible for either app on this hardware — this is
  confirmed by the capability scan, not merely inferred from the absence
  of a camera.
- **`crypto_dictionary`**: confirmed to be "a pure reference/glossary
  app, no crypto *operations* performed on user data" — it reads bundled
  cipher-glossary text resources only. No keys, wallets, credentials,
  tokens, seed phrases, encryption workflows, or sensitive-data handling
  of any kind found. This matches the "offline glossary" case the
  project owner's special-caution instruction says may remain in
  planning.

## License-screening summary

**This is the same gap every prior planning phase in this project has
documented, and it is still open for all 9 of these apps.** The Phase
1.6 audit screened for hardware capability and storage behavior, not
per-app SPDX license identifiers or bundled-content copyright status.
Real license verification (the Phase 2B.1/2C.1 pattern: a fresh network
read of each app's actual `LICENSE` file at the pinned RogueMaster
commit) has not been repeated for any of these 9 in this phase, because
this phase is planning-only and explicitly does not re-verify sources.

Two candidates carry an extra, specific note beyond the routine gap:

- **`image_viewer`** bundles 3 example `.bm` bitmap files as resources.
  Unlike `barcode_gen`'s encoding tables (implementations of public
  technical standards) or `crypto_dictionary`'s glossary (definitions,
  not creative works), example bitmap images could plausibly be original
  artwork with their own provenance question — flagged, not resolved,
  same as this exact note in `docs/PHASE2C_CANDIDATE_REVIEW.md` before
  it existed for this pool.
- **`barcode_gen`**'s bundled encoding tables (Code39/128/128C/Codabar)
  are very likely implementations of public technical standards (barcode
  symbologies are published specifications, not creative works), but this
  has not been confirmed against an actual license/attribution file in
  any phase to date.

All other candidates either have no bundled third-party content at all,
or bundle content whose nature makes a copyright block unlikely — none
of this is confirmed against an actual `LICENSE` file in this phase. See
`docs/PHASE2D_LICENSE_REVIEW.md` for the honest per-recommended-app
confidence level.

## Dependency-surface summary

Per the Phase 1.6 audit, none of the 9 candidates declare external
`requires=[...]` dependencies beyond the default FAP toolchain. File
counts range from 1 (`image_viewer`) to 21 (`boilerplate`). `resistors`
(13 files, ~2.3MB) has a disproportionately larger on-disk footprint than
its file count alone suggests (per Phase 1.5's own note), worth budgeting
extra build-verification time for, consistent with how this project has
treated similarly asset-heavy apps (`chess`, `upython`) in prior phases.

## Storage/hardware behavior summary

- **Zero storage of any kind**: `resistors`.
- **Read-only local storage only** (per Phase 1.6's description, not yet
  independently re-confirmed in this phase): `hex_viewer`, `image_viewer`,
  `qrcode`, `barcode_gen`, `crypto_dictionary`. **Caution**: Phase 1.6's
  own wording for `hex_viewer` ("2 files touch storage APIs") and
  `barcode_gen` ("3 files touch storage") does not explicitly rule out a
  write call the same way it explicitly did for zero-storage apps like
  `resistors` ("**None**") — this project's own Phase 2C.1 experience
  with `sd_info` (assumed zero-storage in planning, found to have real
  writes on fresh source read) is the exact reason this ambiguity is
  flagged here rather than resolved by assumption. `qrcode`'s Phase 1.6
  storage field is simply "Local" with no further detail at all — the
  weakest evidence of any candidate in this pool.
- **Private-storage writes** (own save/config file, the same
  app-private pattern already proven safe by `chess`/`sudoku`):
  `2048` (high-score), `minesweeper` (save/config), `boilerplate`
  (demonstration save pattern).

## Confidence level per candidate

| App | Safety confidence | License confidence | Storage-behavior confidence | Build-risk confidence | Overall |
|---|---|---|---|---|---|
| `2048` | High | Medium (no SPDX check performed) | High (explicitly "high-score save," a well-understood pattern) | High (4 files) | High |
| `minesweeper` | High | Medium | High (explicitly save/config) | Medium (20 files, largest pure game) | Medium-High |
| `resistors` | High | Medium | High (explicitly "**None**") | Medium (13 files, larger asset footprint) | Medium-High |
| `hex_viewer` | High | Medium | **Medium — read-vs-write not explicitly confirmed** ("2 files touch storage APIs") | Medium (20 files) | Medium |
| `image_viewer` | High | Medium (bundled bitmaps, provenance not confirmed) | Medium-High (described as read-only, not exhaustively confirmed) | High (1 file) | Medium-High |
| `boilerplate` | High | Medium | High (explicitly a save-file demonstration) | Medium (21 files) | Medium-High |
| `qrcode` | High | Medium | **Low-Medium — storage field is bare "Local" with no further detail** | High (3 files) | Medium |
| `barcode_gen` | High | Medium (bundled tables likely standard-format data, not confirmed) | **Medium — read-vs-write not explicitly confirmed** ("3 files touch storage") | Medium (16 files + bundled tables) | Medium |
| `crypto_dictionary` | High | Medium (bundled glossary text, provenance not confirmed) | High (explicitly "reads bundled text resources," and explicitly confirmed "no crypto operations performed on user data") | Medium (13 files + bundled text) | Medium-High |

"Medium" license confidence across the whole pool reflects an honest
gap, not a specific finding of a problem — the same status every prior
planning phase in this project has recorded before its own Phase-X.1
verification pass closed it. `docs/PHASE2D_LICENSE_REVIEW.md` recommends
the same be done for whichever apps this package recommends, before any
actual import commit.

## Stop point

This is a review only. No app listed here has been copied into
`applications/` or `applications_user/`, no build was attempted, and no
decision beyond "worth recommending for the next planning artifact" was
made. See `docs/PHASE2D_RECOMMENDED_BATCH.md` for the actual tiny-batch
recommendation drawn from this pool.

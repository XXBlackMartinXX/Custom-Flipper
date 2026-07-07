# Phase 2B — Candidate Review

Docs only. Planning only. **No code has been imported, no application
source has been read fresh in this phase** — this review is grounded
entirely in the already-completed Phase 1.5/1.6 audit work, re-screened
against what Phase 2A actually imported. Where the existing audit evidence
is insufficient to make a claim, this document says `NEEDS REVIEW` rather
than guessing. This environment has no local clone of the RogueMaster
source tree to re-verify anything fresh in this phase; every finding below
is a citation of prior work, not a new source read.

## Source docs consulted

| Doc | What it contributed |
|---|---|
| `PHASE1_5_HIGH_VALUE_SHORTLIST.md` | 195-app candidate pool, first-pass metadata triage |
| `PHASE1_5_TOP_25_CANDIDATES.md` | The 25-app shortlist this review starts from |
| `PHASE1_5_EXCLUSION_LIST.md` | What was already excluded before the Top 25 existed (RF-transmit games, HID-wedge tool, locksmith-adjacent tools, thin-description apps) |
| `PHASE1_6_TOP25_SOURCE_AUDIT.md` | The individual `.c`/`.h`/`.cpp` source audit of all 25 (real API-usage grep + read, against RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) — the primary evidence base for this review |
| `PHASE1_6_FIRST_BATCH_SELECTION.md` | Confirms exactly which 5 of the 25 became Phase 2A, and why |
| `PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md` | The 3 approve-with-notes apps and the 1 deferred app, in isolation |
| `PHASE1_CURATION_MATRIX.md`, `PHASE1_RISK_REGISTER.md`, `PHASE1_FEATURE_INVENTORY.md`, `PHASE1_RECOMMENDED_INTEGRATION_PLAN.md` | Supporting context, general risk/integration framework |
| `docs/PHASE2A_ACCEPTANCE_RECORD.md`, `docs/PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`, and other Phase 2A docs | To exclude apps already imported and reuse the exact license-review discipline that caught chess's SAM problem |
| `docs/CREDITS.md`, `docs/THIRD_PARTY_NOTICES.md` | Existing attribution/third-party-notice conventions this review follows |

No new source files were fetched or read in this phase. All per-app
capability findings below are the Phase 1.6 audit's findings, cited, not
re-derived.

## Candidate list reviewed

The full Phase 1.5 Top 25, minus the 5 apps Phase 2A already imported:

| # | App | Category | Phase 1.6 audit decision | Status for Phase 2B |
|---|---|---|---|---|
| 1 | `chess` | Games | APPROVE | **Already imported (Phase 2A)** — excluded |
| 2 | `2048` | Games | APPROVE | Candidate pool |
| 3 | `minesweeper` | Games | APPROVE | Candidate pool |
| 4 | `sudoku` | Games | APPROVE | Candidate pool |
| 5 | `programmer_calc` | Tools | APPROVE | **Already imported (Phase 2A)** — excluded |
| 6 | `resistors` | Tools | APPROVE | Candidate pool |
| 7 | `network_subnet` | Tools | APPROVE | **Already imported (Phase 2A)** — excluded |
| 8 | `quadratic_solver` | Tools | APPROVE | Candidate pool |
| 9 | `hex_viewer` | Tools | APPROVE | Candidate pool |
| 10 | `docviewlite` | Tools | APPROVE | Candidate pool |
| 11 | `image_viewer` | Media | APPROVE | Candidate pool |
| 12 | `boilerplate` | Tools/Educational | APPROVE | Candidate pool |
| 13 | `upython` | Tools | **DEFER** (real GPIO write + IR transmit exposed to user scripts) | Excluded — safety exclusion, see below |
| 14 | `iconedit` | Tools | APPROVE WITH NOTES (real USB HID keystroke injection in one file) | Excluded — safety exclusion, see below |
| 15 | `sd_info` | Tools | APPROVE | Candidate pool |
| 16 | `flipfetch` | Tools | APPROVE | Candidate pool |
| 17 | `flipper95` | Tools | APPROVE | **Already imported (Phase 2A)** — excluded |
| 18 | `animation_switcher` | Settings | APPROVE WITH NOTES (writes to shared `/ext/dolphin/`, not app-private) | Candidate pool (lower priority) |
| 19 | `theme_manager` | Settings | APPROVE WITH NOTES (writes to shared `/ext/dolphin/`, has backup logic) | Candidate pool (lower priority) |
| 20 | `qrcode` | Tools | APPROVE | Candidate pool |
| 21 | `barcode_gen` | Tools | APPROVE | Candidate pool |
| 22 | `vin_decoder` | Tools | APPROVE | **Already imported (Phase 2A)** — excluded |
| 23 | `fcc_id_lookup` | Tools | APPROVE | Candidate pool |
| 24 | `crypto_dictionary` | Tools/Educational | APPROVE | Candidate pool |
| 25 | `c_book` | Tools/Educational | APPROVE (hardware/storage only — **not** license-screened for bundled book text) | Candidate pool, flagged — see License-screening summary |

## Duplicates/overlaps with Phase 2A removed

Five apps are removed from consideration entirely because they are already
imported and accepted as part of the Phase 2A baseline: `chess`,
`programmer_calc`, `network_subnet`, `vin_decoder`, `flipper95`. This leaves
**18 candidates** in the active Phase 2B pool.

## Candidates excluded and why (safety exclusions, not just deferred)

- **`upython`** — Phase 1.6 source audit found real `furi_hal_gpio_write()`/
  `furi_hal_gpio_read()`/GPIO-interrupt bindings and real
  `furi_hal_infrared_async_tx_start()` (IR transmit, not receive-only)
  exposed to any MicroPython script it runs. This is a real hardware
  read/write and infrared-transmit capability, which is on this phase's
  explicit safety-exclusion list ("GPIO write/control", "IR transmit/control
  unless clearly harmless and explicitly deferred"). **Canary applied**:
  stop and mark DEFER. Not recommended for any near-term batch; would need
  its own dedicated capability-review phase (e.g. shipping with the
  hardware modules compiled out) before ever being reconsidered.
- **`iconedit`** — Phase 1.6 source audit found `panels/send_usb.c` calls
  `furi_hal_hid_kb_press()`/`furi_hal_hid_kb_release()` directly: the "send
  to PC" feature works by typing data as keystrokes, mechanically identical
  to how BadUSB payloads operate, regardless of the benign fixed payload.
  This is on this phase's explicit safety-exclusion list
  ("BadUSB/HID injection"). **Canary applied**: stop and mark DEFER for
  this phase. The core icon-editing functionality is not itself unsafe, but
  this review does not recommend importing an app whose source contains a
  real HID-injection code path without a dedicated stripping/gating
  decision — that decision is out of scope for a planning-only phase.

Neither exclusion is a claim that these apps are malicious — both were
rated APPROVE / APPROVE WITH NOTES for their evident *intent*. They are
excluded because their actual compiled capability crosses this phase's own
explicit safety boundary, and this phase's mandate is to recommend only
what is safe enough for **planning**, let alone import.

## Candidates kept for possible Phase 2B (18)

`2048`, `minesweeper`, `sudoku`, `resistors`, `quadratic_solver`,
`hex_viewer`, `docviewlite`, `image_viewer`, `boilerplate`, `sd_info`,
`flipfetch`, `animation_switcher`, `theme_manager`, `qrcode`,
`barcode_gen`, `fcc_id_lookup`, `crypto_dictionary`, `c_book`.

## Safety-screening summary

All 18 remaining candidates were confirmed by the Phase 1.6 source audit to
have **zero** matches against the eight HAL capability classes scanned
(storage beyond local/private use, GPIO, Sub-GHz, Infrared, NFC/RFID/
iButton, BLE, USB/HID) **except** two storage-pattern notes:

- `animation_switcher` and `theme_manager` write to the shared
  `/ext/dolphin/` directory (base firmware's own animation subsystem data),
  not app-private storage. Not a safety-exclusion-list item (no
  RF/NFC/GPIO/HID/IR/BLE involved), but a materially different storage-risk
  class than a private save file. Both have their own confirmed
  backup/restore logic in source, per the Phase 1.6 audit.

No candidate in the kept-18 pool touches Sub-GHz, NFC/RFID/iButton, GPIO,
Infrared transmit, BLE, or HID — the two apps that did (`upython`,
`iconedit`) are excluded above, not included in this pool.

## License-screening summary

**This is the one area where the existing Phase 1.6 audit is materially
incomplete for this pool**, and this review does not pretend otherwise: the
Phase 1.6 audit screened for *hardware capability and storage behavior*,
not per-app SPDX license identifiers or bundled-content copyright status.
Phase 1.5's baseline bar ("real author/README/`fap_weburl`/version on
file") is attribution evidence, not a license-compatibility confirmation —
this is the same gap that let chess's unlicensed SAM speech-synth component
through Phase 1.6's audit undetected until a dedicated license review
(`PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`) was run against it specifically.

One candidate in this pool needs exactly that kind of dedicated review
before it can be recommended for import, applying the missing-evidence
canary rather than assuming it's fine:

- **`c_book`** — described in Phase 1.5/1.6 as "an on-device copy of 'The C
  Programming Language' (K&R), Flipper Edition," bundling `.txt` chapters
  of that book as data resources. K&R's book is a commercially published,
  copyrighted work (Prentice Hall) — not public domain, not a permissively
  licensed reference text. Bundling verbatim book text as an app resource
  is a real, unresolved copyright question that the Phase 1.6 audit did not
  address (it only confirmed the app has no unsafe hardware/storage
  behavior). **This review does not have evidence the bundled text has a
  clear distribution right and marks it `NEEDS REVIEW` per the canary "if
  any app has unclear license or bundled third-party code without
  provenance, stop and mark DEFER."** See `PHASE2B_LICENSE_REVIEW.md`.

All other 17 candidates in the pool either have no bundled third-party
content at all, or bundle content that is not itself creative/copyrightable
in the way book text is (e.g. `barcode_gen`'s bundled encoding-format
tables are implementations of public technical standards; `fcc_id_lookup`'s
bundled database is derived from US FCC public records). None of these are
confirmed against an actual LICENSE file in this phase — see
`PHASE2B_LICENSE_REVIEW.md` for the honest per-app confidence level.

## Dependency-surface summary

Per the Phase 1.6 audit, none of the 18 kept candidates declare external
`requires=[...]` dependencies beyond the default FAP toolchain. File counts
range from 1 (`sudoku`, `quadratic_solver`, `flipfetch`, `sd_info`) to 21
(`boilerplate`). `resistors` (13 files) was separately flagged in Phase 1.5
as "2.3MB, likely icon/reference assets" — larger on-disk footprint than
its file count alone suggests, worth budgeting extra build-verification
time for, consistent with how `upython`/`chess` were treated in Phase 2A
planning.

## Confidence level per candidate

| App | Safety confidence | License confidence | Build-risk confidence | Overall |
|---|---|---|---|---|
| `2048` | High (audit-confirmed, zero HAL hits) | Medium (no SPDX check performed) | High (4 files) | High |
| `minesweeper` | High | Medium | Medium (20 files, largest pure game) | Medium-High |
| `sudoku` | High | Medium | High (1 file) | High |
| `resistors` | High | Medium | Medium (13 files, larger asset footprint) | Medium-High |
| `quadratic_solver` | High | Medium | High (1 file) | High |
| `hex_viewer` | High | Medium | Medium (20 files) | Medium-High |
| `docviewlite` | High | Medium | High (1 file) | High |
| `image_viewer` | High | Medium | High (1 file, 3 bundled example bitmaps — need provenance check) | Medium-High |
| `boilerplate` | High | Medium | Medium (21 files) | Medium-High |
| `sd_info` | High | Medium | High (1 file) | High |
| `flipfetch` | High | Medium | High (1 file) | High |
| `animation_switcher` | Medium (shared-storage write, mitigated by own restore logic) | Medium | Medium (18 files) | Medium |
| `theme_manager` | Medium (shared-storage write, has confirmed backup logic) | Medium | Low-Medium (1 large file) | Medium |
| `qrcode` | High | Medium | High (3 files) | High |
| `barcode_gen` | High | Medium (bundled tables likely standard-format data, not confirmed) | Medium (16 files + bundled tables) | Medium-High |
| `fcc_id_lookup` | High | Medium (bundled DB likely public-record data, not confirmed) | High (2 files) | Medium-High |
| `crypto_dictionary` | High | Medium (bundled glossary text, provenance not confirmed) | Medium (13 files + bundled text) | Medium |
| `c_book` | High (hardware/storage only) | **Low — real unresolved copyright question, see above** | Medium (13 files + bundled book text) | **Low — NEEDS REVIEW, recommend DEFER** |

"Medium" license confidence across most of the pool reflects an honest
gap, not a specific finding of a problem — it means "no per-app SPDX/
LICENSE file has actually been read yet in this phase," which
`PHASE2B_LICENSE_REVIEW.md` recommends closing before each app's own
import commit, the same discipline Phase 2A already used for `chess`.

## Stop point

This is a review only. No app listed here has been copied into
`applications/` or `applications_user/`, no build was attempted, and no
decision beyond "worth recommending for the next planning artifact" was
made. See `PHASE2B_RECOMMENDED_BATCH.md` for the actual tiny-batch
recommendation drawn from this pool.

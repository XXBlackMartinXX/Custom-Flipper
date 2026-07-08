# Phase 2F — Candidate Review

Docs only. Planning only. **No code has been imported, no application
source has been freshly read in this phase.** This review is grounded
entirely in the already-completed Phase 1.5/1.6 audit work and the Phase
2B/2C/2D/2E planning and import record, re-screened against the
now-16-app accepted Phase 2E baseline. Where existing audit evidence is
insufficient to make a claim, this document says `NEEDS REVIEW` rather
than guessing. This phase did not attempt a fresh network read of the
RogueMaster source tree — real source/license re-verification is
explicitly deferred to Phase 2F.1, per `docs/PHASE2F_NEXT_GATE.md`, the
same sequencing every prior planning phase in this project has followed.

## Source docs consulted

| Doc | What it contributed |
|---|---|
| `PHASE1_5_HIGH_VALUE_SHORTLIST.md` | 195-app candidate pool, first-pass metadata triage |
| `PHASE1_5_TOP_25_CANDIDATES.md` | The 25-app shortlist every phase in this project has drawn from |
| `PHASE1_6_TOP25_SOURCE_AUDIT.md` | The individual `.c`/`.h`/`.cpp` source audit of all 25 (real API-usage grep + read, against RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) — the primary evidence base for this review, re-read verbatim in this phase to avoid relying on memory of prior citations |
| `docs/PHASE2E_CANDIDATE_REVIEW.md`, `docs/PHASE2E_RECOMMENDED_BATCH.md` | Phase 2E's own planning pass over the post-2D pool — confirms exactly which 3 apps remained un-selected after Phase 2E's batch (`hex_viewer`, `qrcode`, `barcode_gen`), and the exact reasoning for each (this is the direct ancestor of this document's candidate pool) |
| `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`, `docs/PHASE2E_2_SAFETY_REVIEW.md` | The real, fresh-source-read lesson this project keeps re-learning: a citation-only review can miss a real storage-behavior detail (`sd_info`'s SD-benchmark writes were the original instance in Phase 2C.1) — this phase applies the same caution to `hex_viewer`/`qrcode`/`barcode_gen`'s own storage descriptions below |
| `docs/PHASE2E_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2E_HARDWARE_ASSISTED_RESULTS.md` | Confirms the current accepted 16-app baseline and hardware-gate status (`BLOCKED - DEVICE NOT AVAILABLE`), to correctly exclude already-imported apps |
| `docs/KNOWN_ISSUES.md` | `fcc_id_lookup`'s open license-evidence gap (item 6) and the hardware-unavailability item (item 3), both confirmed still open and out of scope for this phase |

No new source files were fetched or read in this phase. All per-app
capability findings below are the Phase 1.6 audit's findings, cited
verbatim, not re-derived.

## Already-imported apps excluded

All 16 apps currently in the accepted Phase 2E baseline are removed from
consideration entirely: `network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`, `flipfetch`, `quadratic_solver`,
`sudoku`, `sd_info`, `docviewlite`, `resistors`, `crypto_dictionary`,
`2048`, `image_viewer`, `boilerplate`, `minesweeper`.

## Hard-deferred apps excluded and why

These 6 are excluded from this phase's candidate pool outright, per the
project owner's explicit instruction, and are not re-reviewed here:

| App | Why previously flagged |
|---|---|
| `fcc_id_lookup` | The RogueMaster-vendored copy has no `LICENSE` file, no SPDX identifier, no copyright header anywhere in its source (Phase 2C.1 finding, `docs/KNOWN_ISSUES.md` item 6). Strong corroborating MIT evidence exists at the true upstream repository but is not commit-pinned to the vendored revision. Per explicit instruction, not resolved and not re-reviewed in this phase — requires a separate, narrow license-resolution phase. |
| `upython` | Real `furi_hal_gpio_write`/`furi_hal_gpio_read`/GPIO-interrupt bindings and real `furi_hal_infrared_async_tx_start` (IR transmit) exposed to any user-authored MicroPython script (Phase 1.6 finding). Safety-exclusion list — hardware/control capability risk. |
| `iconedit` | `panels/send_usb.c` calls `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` directly — mechanically USB HID keystroke injection (Phase 1.6 finding). Safety-exclusion list. |
| `c_book` | Bundles verbatim `.txt` chapters of "The C Programming Language" (K&R, Prentice Hall) — a commercially published, copyrighted work with no confirmed distribution right. Unresolved copyright question. |
| `animation_switcher` | Writes to the shared `/ext/dolphin/manifest.txt`, not app-private storage (Phase 1.6 finding). |
| `theme_manager` | Writes to `/ext/dolphin/` (with a confirmed backup step), same shared-directory consideration as `animation_switcher`. |

No new evidence was gathered on any of these 6 in this phase — this is a
restatement of the existing record, per the task's explicit "do not
reopen `fcc_id_lookup`" instruction and the project owner's explicit list
of the other 5.

## Candidate pool considered (3 apps)

The Phase 1.5 Top 25, minus the 16 already-imported apps and the 6
hard-deferred apps above, leaves exactly the 3 candidates the project
owner's own task message names as the remaining pool: `hex_viewer`,
`qrcode`, `barcode_gen`. This is the entire remaining clean candidate
pool from the original Top 25 — nothing outside this list is considered
in this phase.

## Per-candidate summary

### `hex_viewer`

- **Source path**: `applications/external/hex_viewer/` (upstream RogueMaster path; not yet re-confirmed against the currently pinned commit in this phase)
- **Phase 1.6 finding**: 20 files across `helpers/`, `views/`, `scenes/`. Confirmed: hex viewer for user-selected files. Storage: "Local (reads the file the user opens; 2 files touch storage APIs)." No hardware/radio capability identified. Risk fields: Low-Med build difficulty, Low hardware risk. **APPROVE** in the Phase 1.6 audit.
- **Confidence level**: **Medium.** The Phase 1.6 citation says "reads the file the user opens" but does not explicitly rule out a write/edit/patch code path in the 2 files that "touch storage APIs" — the app's name implies pure viewing, but "touch storage APIs" is not itself proof of read-only behavior. Per this phase's own special-caution instruction and the Phase 2C.1 precedent (`sd_info`'s storage behavior was undersold at planning stage), this ambiguity is flagged as **NEEDS DIRECT VERIFICATION**, not assumed clean.

### `qrcode`

- **Source path**: `applications/external/qrcode/` (upstream RogueMaster path; not yet re-confirmed against the currently pinned commit in this phase)
- **Phase 1.6 finding**: 3 files. Confirmed: displays QR codes from user input. Storage: "Local." No hardware/radio capability identified. Risk fields: Low build difficulty, Low hardware risk. **APPROVE** in the Phase 1.6 audit.
- **Confidence level**: **High.** Smallest and simplest of the 3 (3 files), a single clearly-scoped display function, no bundled data files, no capability findings of any kind in the Phase 1.6 source read. Still requires the standard Phase 2F.1 direct re-read (per this project's own discipline — a citation is not a substitute for reading the actual source at import-verification time), but nothing in the existing record suggests a surprise is likely.

### `barcode_gen`

- **Source path**: `applications/external/barcode_gen/` (upstream RogueMaster path; not yet re-confirmed against the currently pinned commit in this phase)
- **Phase 1.6 finding**: 16 files, plus 4 bundled encoding-table text files (Code39/128/128C/Codabar) as data resources. Confirmed: displays barcodes from user input using bundled encoding tables. Storage: "Local (reads bundled tables + user text; 3 files touch storage)." No hardware/radio capability identified. Risk fields: Low-Med build difficulty, Low hardware risk. **APPROVE** in the Phase 1.6 audit.
- **Confidence level**: **Medium-High.** The bundled encoding-table text files are standard, publicly documented barcode-symbology lookup tables (Code39/128/128C/Codabar are open technical standards, not creative works or proprietary data), which is a materially lower provenance concern than `image_viewer`'s bundled bitmap images were. The "3 files touch storage APIs" note carries the same ambiguity as `hex_viewer`'s — likely reading the bundled tables, but not yet confirmed to exclude any write path — so this is also flagged for direct Phase 2F.1 verification rather than assumed.

## Safety-screening summary

None of the 3 candidates appears anywhere on this project's own
safety-exclusion list (Sub-GHz/RF, NFC/RFID/iButton, BadUSB/HID
injection, BLE, GPIO, IR transmit, credential/token/password/seed-phrase/
private-key/wallet handling, cloning, brute force, jamming, deauth,
bypass, or any unauthorized-access/security-abuse behavior) per the
existing Phase 1.6 source audit. All 3 were audited at the `.c`/`.h`
source level (not just `application.fam`/README) in that pass. No new
safety-keyword scan was run in this phase — the existing Phase 1.5/1.6
scan results are cited, not re-derived.

## License-screening summary

No per-app `LICENSE` file, SPDX header, or license text has actually
been read for any of the 3 candidates in this phase, or in any prior
phase — this is a planning-only review. `application.fam` for all 3
declares no license field per Phase 1.5's own screening column ("None
declared"). This is the same routine gap every phase's planning-stage
license review has recorded before its own X.1 verification phase
resolved it (see `docs/PHASE2F_LICENSE_REVIEW.md` for the per-app
detail).

## Dependency-surface summary

| App | File count | Bundled data | External dependencies noted |
|---|---|---|---|
| `hex_viewer` | 20 files | None | None declared |
| `qrcode` | 3 files | None | None declared |
| `barcode_gen` | 16 files | 4 bundled encoding-table `.txt` files (Code39/128/128C/Codabar) | None declared |

All 3 are small (3-20 files), well within the range of every prior
phase's own batch sizes, with no unusual build dependencies noted in the
Phase 1.5/1.6 audits.

## Storage/hardware behavior summary

No hardware capability (RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR) was
identified for any of the 3 candidates in the Phase 1.6 source audit.
Storage behavior is described only at a coarse level ("touches storage
APIs") for `hex_viewer` and `barcode_gen`, without confirming read-only
vs. read/write — this ambiguity is the single most important open
question this planning phase identifies, and is carried forward as an
explicit Phase 2F.1 verification condition for both apps in
`docs/PHASE2F_RECOMMENDED_BATCH.md`. `qrcode`'s storage note ("Local")
carries no such ambiguity flag in the existing record.

## Phase 2F is planning only

**Nothing in this document, or in any other Phase 2F planning
deliverable, imports code, modifies `applications/` or
`applications_user/`, or changes any firmware/app source.** All 3
candidates require real source/license verification at Phase 2F.1 before
any import decision, exactly as every prior phase's planning-stage
review required before its own X.1 phase.

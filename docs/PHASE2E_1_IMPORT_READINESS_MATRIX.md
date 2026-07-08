# Phase 2E.1 — Import Readiness Matrix

Docs only. Pre-import verification only. **No app code has been
imported.** Consolidated table drawn from the full findings in
`PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` — read that document for full
evidence (file listings, exact grep results, exact source excerpts, the
decoded-bitmap finding); this matrix is a summary view, not a substitute.

| App | Source path | appid | Declared license | License confidence | Bundled data/code status | Safety status | Dependency status | Storage status | Build risk | Import readiness | Required attribution | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `image_viewer` | `applications/external/image_viewer/` | `image_viewer` | MIT (full text confirmed in vendored copy) | **High** — real, unmodified license text present directly in the artifact that would be imported | **`example_images/` (3 bundled `.bm` files) — real, confirmed problem.** Decoded and visually inspected: `spongebob.bm` clearly depicts a recognizable trademarked/copyrighted character (SpongeBob SquarePants). `dolphin.bm`/`cat.bm` are also unattributed and unconfirmed. None are required for the app to build or function. | **Clean** — zero matches across all 22 required keywords in `main.cpp`, the only source file | None declared beyond default FAP toolchain | **Confirmed read-only** — `FSAM_READ`/`FSOM_OPEN_EXISTING` only, no write call anywhere in the 120-line source (read in full) | Low — single-file app, simplest build surface reviewed in this project's history | **CLEARED FOR IMPORT WITH CONDITION** | MIT notice/attribution to Ivan Polushin (polioan) | **Import only `application.fam` (with `fap_file_assets = "example_images"` removed), `LICENSE`, `README.md`, `CHANGELOG.md`, `main.cpp`, `assets/icon.png`. Do not import `example_images/` or any of its 3 `.bm` files under any circumstance.** |
| `boilerplate` | `applications/external/boilerplate/` | `fap_boilerplate` (not `boilerplate` — a real discrepancy from the Phase 1.5/1.6 directory-name assumption) | Informal permissive grant in `README.md`'s "## Licensing" section ("open-source and may be used for whatever you want to do with it") — **no `LICENSE` file exists** | **Medium-High** — real, explicit, unambiguous author statement, but not a formal SPDX-identified license text; a materially weaker evidence class than `image_viewer`'s/`minesweeper`'s real `LICENSE` files, though far stronger than `fcc_id_lookup`'s total silence | None found — entire tree is the author's own template/demonstration code; `docs/` subdirectory is informational only, not a build input | **Clean** — zero matches across all 22 required keywords across the full tree; only benign `notification_message()`/`furi_hal_speaker_*` (haptic/LED/sound) and a standard `dolphin_deed()` gamification call | None declared beyond default FAP toolchain | **Confirmed app-private** — writes only to `/ext/apps_data/boilerplate/boilerplate.conf`, exact path confirmed directly in `helpers/boilerplate_storage.h` | Medium — 29 `.c`/`.h` files across `helpers/`/`scenes/`/`views/`, template structure | **CLEARED FOR IMPORT WITH NOTE** | Preserve `README.md`'s exact "## Licensing" section verbatim in this project's own `CREDITS.md`/`THIRD_PARTY_NOTICES.md` entry, since no separate `LICENSE` file text exists to cite instead | Real, working dev-tool value confirmed directly (complete demonstration of Start Screen, Menu, File Browser, Text/Number Input, Settings, haptic/sound/LED, app-private storage) — not filler. No source changes needed outside its own directory. |
| `minesweeper` | `applications/external/minesweeper/` | `minesweeper_redux` (not `minesweeper` — a real discrepancy from the Phase 1.5/1.6 directory-name assumption; actively published on the official Flipper Lab app catalog) | MIT (full text confirmed in vendored copy) | **High** — real, unmodified license text present directly in the artifact that would be imported | 8×8 tile sprites, 10×10 icon, 55×52 "crying dolphin" game-over sprite, and a 13-frame start-screen animation are all small, original-style game sprites (confirmed by direct inspection) — no character-identification concern like `image_viewer`'s. `img/` (screenshots/GIFs) and `docs/changelog.md` are not referenced by `application.fam`, not a build input | **Clean** — zero matches across all 22 required keywords, and zero mentions of any hardware-peripheral term at all (broader scan than the required 22) | `engine/mstarlib_helpers.h` includes M\*LIB's `m-deque.h` — **already satisfied by this project's existing `lib/mlib` base-firmware submodule**, not a new bundled/vendored dependency. No `requires=[...]` declared | **Confirmed app-private**, with a real, positive nuance: atomic write-then-rename via a temp file (`.../mine_sweeper_redux.conf.tmp` → `.../mine_sweeper_redux.conf`), exact path confirmed directly in `helpers/mine_sweeper_config.h` | Medium — 32 `.c`/`.h` files across `engine/`/`helpers/`/`scenes/`/`views/`, largest of this batch's 3 apps, consistent with Phase 1.6's "largest file count of the pure games" note | **CLEARED FOR IMPORT** | MIT notice/attribution to Alexander Rodriguez (squee72564) | No import-scope condition beyond excluding the non-build-input `img/` directory for cleanliness (no provenance concern of its own). No source changes needed outside its own directory. |

## Reading this matrix

- **"Import readiness" is the authoritative field** — everything else is
  supporting evidence for that conclusion. `CLEARED FOR IMPORT` (with or
  without a condition/note) here means ready for the next gate (Phase
  2E.2 implementation), not built, not hardware-tested, not
  release-ready.
- **All 3 apps in this batch are cleared** — the same outcome class as
  Phase 2D.1 (all 3 cleared), materially different from Phase 2C.1 (1 of
  3 deferred on a license-evidence gap). No app is DEFERRED, BLOCKED, or
  demoted to NEEDS REVIEW.
- **`image_viewer` carries a real, substantive import-scope condition,
  not a routine one.** Unlike `resistors`'s/`2048`'s Phase 2D.1
  conditions (excluding non-build-input directories with no specific
  identified content problem), `image_viewer`'s condition excludes
  content that was directly, positively identified as a recognizable
  trademarked/copyrighted character (`spongebob.bm`). This is the exact
  scenario this phase's own special-caution instruction anticipated, and
  it resolves cleanly: the content is excludable, and is excluded,
  without disqualifying the app's own clean, MIT-licensed wrapper code.
- **`boilerplate`'s license evidence is real but non-standard.** This is
  recorded honestly as a distinct, weaker-but-real evidence tier — not
  silently treated as equivalent to a formal MIT `LICENSE` file, and not
  treated as a missing-evidence DEFER situation either, since the
  author's own explicit, broad permissive statement is directly readable
  in the artifact that would be imported.
- **No app in this matrix touches Sub-GHz, NFC/RFID/iButton, GPIO,
  Infrared transmit, BLE, or HID** — all three were confirmed clean
  against the full 22-keyword safety scan, against real source, not a
  citation.
- **Two real appid discrepancies were found** (`fap_boilerplate` and
  `minesweeper_redux`, vs. the directory-name assumptions
  `boilerplate`/`minesweeper` used throughout Phase 1.5/1.6/Phase 2E
  planning) — neither is a safety or license concern, but both are
  recorded precisely here so a future Phase 2E.2 implementation uses the
  correct manifest-declared appid, not the assumed one.

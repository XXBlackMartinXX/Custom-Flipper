# Phase 2D.1 — Import Readiness Matrix

Docs only. Pre-import verification only. **No app code has been
imported.** Consolidated table drawn from the full findings in
`PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` — read that document for full
evidence (file listings, exact grep results, exact source excerpts); this
matrix is a summary view, not a substitute.

| App | Source path | appid | Declared license | License confidence | Bundled data/code status | Safety status | Dependency status | Storage status | Build risk | Import readiness | Required attribution | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `resistors` | `applications/external/resistors/` | `resistance_calculator` | MIT (full text confirmed in vendored copy) | **High** — real, unmodified license text present directly in the artifact that would be imported | Shipped assets (`resistors.png`, `images/`, ~28K) are original 1-bit pixel-art icons, no provenance concern. ~2.3MB of non-shipped upstream directories (`.flipcorg/`, `design/`, `img/`, `screenshots/`) are **not build inputs**; two files within them (`design/resistor_{4,5}_src.*`) have unclear photographic-reference provenance — **recommended excluded from import entirely**, not guessed or blocked | **Clean** — zero matches across all 22 required keywords, no substring false positives of any kind | None declared beyond default FAP toolchain; 2 `src/` files use internal (`applications/services/gui/...`) include paths rather than the public `gui/` API — a build-risk item, not a dependency-license item | **Confirmed zero** — no storage API (`storage_`, `file_stream`, `stream_`, `FSAM_`, `FSOM_`, etc.) referenced anywhere in `src/` | Low-Medium — the 2 internal-header includes noted above are unconfirmed against this project's exact firmware-base layout; a genuine Static/Build-validation-time question | **CLEARED FOR IMPORT** | MIT notice/attribution to Lewis Westbury (original author) and the `shalebridge` fork credited in `README.md` for the 1.4 feature set | **Import only `application.fam`, `src/`, `resistors.png`, `images/`, `LICENSE`, `README.md`. Do not import `.flipcorg/`, `design/`, `img/`, `screenshots/`.** |
| `crypto_dictionary` | `applications/external/crypto_dictionary/` | `crypto_dict` | GPLv3 (full text confirmed in vendored copy) | **High** — real, unmodified license text present directly in the artifact that would be imported | 14 bundled glossary `.txt` files (symmetric-cipher reference cards) — public, non-copyrightable technical specifications in a distinctive original authorial style; no third-party attribution found or needed. `.flipcorg/` catalog-banner images exist but are not a build input | **Clean** — zero real hits anywhere in the app directory, including inside the bundled glossary text itself; confirmed no user-secret/credential/wallet/seed/token/password handling of any kind (read-only glossary display only, `FSAM_READ`/`FSOM_OPEN_EXISTING` confirmed, no cryptographic operations performed) | None declared beyond default FAP toolchain | **Confirmed read-only** — no `FSAM_WRITE`/`FSOM_CREATE*` call exists anywhere in the source | Low — small, self-contained codebase, no unusual build inputs | **CLEARED FOR IMPORT** | GPLv3 notice/license preservation (standard) | No import-scope condition beyond excluding the non-build-input `.flipcorg/` directory for cleanliness (no provenance concern of its own) |
| `2048` | `applications/external/2048/` | `2048_improved` | MIT (full text confirmed in vendored copy) | **High** — real, unmodified license text present directly in the artifact that would be imported | `digits.h` bitmap font data is original, self-authored pixel data, no provenance concern. `images/`/`img/` (4 gameplay screenshots) are not referenced by `application.fam` and are not a build input, no provenance concern of their own — recommended excluded from import for cleanliness only | **Clean** — zero real hits; `table`-substring false positives only (`is_table_updated`, matching the same benign class established in Phase 2B.1/2C.1); one standard `dolphin_deed()` call to Flipper's own built-in gamification API, not a capability concern | None declared beyond default FAP toolchain | **Confirmed app-scoped, with a real nuance**: writes to `/ext/apps_data/game_2048/game_2048.save` via a hardcoded literal `EXT_PATH(...)` string (not the idiomatic `APP_DATA_PATH` appid-based macro used by `chess`/`sudoku`), functionally private/non-colliding either way, plus a one-time, silently-no-op-on-fresh-install legacy-path migration check (`/ext/apps/Games/game_2048.save`) | Low — small codebase, no unusual build inputs, storage nuance is a documentation precision item, not a build blocker | **CLEARED FOR IMPORT** | MIT notice/attribution to Eugene Kirzhanov (2022); README already carries design-inspiration credits (`DroomOne`, `x27`) that are not code dependencies | **Import only `application.fam`, `array_utils.{c,h}`, `digits.h`, `game_2048.c`, `game_2048.png`, `LICENSE`, `README.md`. `images/`/`img/` may be excluded for cleanliness.** Storage documentation must state the hardcoded-path/legacy-migration nuance precisely, not describe it as unqualified "zero-risk app-private save." |

## Reading this matrix

- **"Import readiness" is the authoritative field** — everything else is
  supporting evidence for that conclusion. `CLEARED FOR IMPORT` here means
  ready for the next gate (Phase 2D.2 implementation), not built, not
  hardware-tested, not release-ready.
- **All 3 apps in this batch are cleared** — this is a materially
  different outcome than Phase 2C.1 (2 of 3 cleared, 1 deferred on a
  license-evidence gap). No license, safety, or capability blocker was
  found for any of the 3 apps in this batch.
- **Two of the three apps (`resistors`, `2048`) carry an import-scope
  condition, not a DEFER.** The condition is procedural (which files to
  actually copy into `applications_user/` at import time), not a
  disqualifying finding about the app's own functional code — the
  functional code and its own license are fully cleared in both cases.
  This distinction matters: an import-scope condition means "import this,
  not that directory," not "do not import this app."
- **No app in this matrix touches Sub-GHz, NFC/RFID/iButton, GPIO,
  Infrared transmit, BLE, or HID** — all three were confirmed clean
  against the full 22-keyword safety scan (18 original plus 4 new for this
  phase), against real source, not a citation.
- **`crypto_dictionary`'s glossary text was specifically checked** against
  the new "content-only glossary/reference hit" category this phase
  introduced, and against the new `seed`/`wallet`/`private key`/`secret`
  keywords — it produced zero hits of any kind, a cleaner result than the
  Phase 2D risk register's own cautious anticipation.

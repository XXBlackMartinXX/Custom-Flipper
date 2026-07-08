# Phase 2F.1 — Import Readiness Matrix

Docs only. Pre-import verification only. **No app code has been
imported.** Summarizes `docs/PHASE2F_1_SOURCE_LICENSE_VERIFICATION.md`'s
per-app findings into a single reference table.

| App | Source path | appid | Declared license | License confidence | Bundled data/code/assets/table status | Safety status | Dependency status | Storage status | Build risk | Import readiness | Required attribution | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `qrcode` | `applications/external/qrcode/` | `qrcode` (matches planning) | MIT | High — full `LICENSE` file read, copyright confirmed | **Bundled MIT QR-encoding library** (ricmoo/Project Nayuki), attributed inline in `qrcode.c`'s own header and in `README.md` | Clean — zero real matches across full keyword scan | None declared | App-private (`/ext/apps_data/qrcodes/`); read-only for QR content; one-time benign legacy-folder migration at launch (same pattern as `2048`) | Low-Medium (1,967 source lines, mostly the bundled library) | **CLEARED FOR IMPORT** | Preserve `LICENSE` verbatim; credit Bob Matcuk (wrapper) + Richard Moore/Project Nayuki (bundled library) | Bundled library is the same one historically vendored in base `flipperzero-firmware`'s own `lib/` directory |
| `hex_viewer` | `applications/external/hex_viewer/` | `hex_viewer` (matches planning) | MIT | High — full `LICENSE` file read, copyright confirmed | None identified | Clean — zero matches of any kind, including false positives | None declared | App-private only; **confirmed genuinely read-only** for viewed files (`FSAM_READ`/`FSOM_OPEN_EXISTING` only); own settings file at `/ext/apps_data/hex_viewer/` | Low-Medium (20 files, largest of the 3, no unusual libraries) | **CLEARED FOR IMPORT** | Preserve `LICENSE` verbatim; credit Roman Shchekin (QtRoS) | Resolves the Phase 2F planning-stage storage ambiguity definitively — no write/edit/patch path against the viewed file exists anywhere in source |
| `barcode_gen` | `applications/external/barcode_gen/` | **`barcode_app`** (discrepancy — directory name ≠ appid, same class as `boilerplate`/`minesweeper` in Phase 2E) | MIT | High — full `LICENSE` file read, copyright confirmed | **4 bundled standard technical-data encoding tables** (Code39/128/128C/Codabar bar-pattern lookup tables), correctly declared via `fap_file_assets` | Clean — 2 benign `@author`/`author:` false positives on "auth," zero real matches | None declared | App-private only (`/ext/apps_data/barcodes/`); bundled encoding tables read-only via `APP_ASSETS_PATH` | Low-Medium (16 files + 4 bundled data files, already correctly packaged) | **CLEARED FOR IMPORT** | Preserve `LICENSE` verbatim; credit Kingal1337 (Alan Tsui), Z0wl, @teeebor, thevan4 per README credits | Resolves the Phase 2F planning-stage storage ambiguity and bundled-table provenance question definitively |

## Aggregate result

**3 of 3 apps CLEARED FOR IMPORT.** Zero apps deferred, zero apps
blocked, zero apps needing further review. The original 3-app
recommended batch remains valid at full size — no reduction is
required.

See `docs/PHASE2F_1_GO_NO_GO.md` for the formal Phase 2F.1 gate
decision and next-gate determination.

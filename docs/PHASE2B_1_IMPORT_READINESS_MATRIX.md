# Phase 2B.1 — Import Readiness Matrix

Docs only. Pre-import verification only. **No app code has been imported.**
Summarizes `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md` as a single
comparison table. All evidence is from a fresh source read against
`RogueMaster/flipperzero-firmware-wPlugins` commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` in this same phase — not
carried forward from the earlier, citation-only Phase 2B planning pass.

| App | Source path | appid | Declared license | License confidence | Safety status | Dependency status | Storage status | Build risk | Import readiness | Required attribution | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `flipfetch` | `applications/external/flipfetch/` | `flipfetch` | MIT (real `LICENSE` file read, SHA-256 `82bf9aac...`) | **High** — confirmed, standard unmodified MIT text | Clean — zero keyword hits of any kind (real or false-positive) across all 18 required capability keywords | None declared (`requires=` absent) | None writable; one read-only free-space query (`storage_common_fs_info`) | Very low — 166 lines, 1 file, standard includes only | **CLEARED FOR IMPORT** | Ismael A. Rodríguez, MIT copyright + permission notice | Simplest of the 3; single file, single author, single upstream repo |
| `quadratic_solver` | `applications/external/quadratic_solver/` | `quadratic_solver` | MIT (real `LICENSE` file read, SHA-256 `3b2dee56...`) | **High** — confirmed, standard unmodified MIT text | Clean — zero real keyword hits; 5 `ble`-substring false positives at lines 36/77/81/85 (`"double"`) and 218 (`"enabled"`), same class Phase 2A already resolved 102 times | None declared | None — no `storage/storage.h` include at all | Very low — 225 lines, 1 file (`app.c`), pure math + GUI | **CLEARED FOR IMPORT** | paul-sopin, MIT copyright + permission notice | Ships a `screenshots/` folder (3 PNGs) that is documentation-only, not part of the built `.fap` |
| `sudoku` | `applications/external/sudoku/` | `sudoku` | MIT (real `LICENSE` file read, SHA-256 `b65e22a5...`) | **High** — confirmed, standard unmodified MIT text | Clean — zero real keyword hits; 1 `ble`-substring false positive at line 674 (`"enabled"`) | None declared | **Real, but confirmed app-private only**: `APP_DATA_PATH("save.dat")` save/load, same pattern as `chess` (Phase 2A) — not a shared-directory write | Low — 689 lines, 1 file (`sudoku.c`), largest of the 3 but still single-file | **CLEARED FOR IMPORT** | profelis, MIT copyright + permission notice | Also uses `dolphin_deed()` for standard XP/achievement tracking — benign, used throughout the existing app ecosystem; ships a `screenshots/` folder (2 PNGs), documentation-only |

## Legend

- **License confidence**: `High` = a real `LICENSE` file was fetched and
  read in full in this phase, text confirmed as an unmodified standard
  license body. This phase found no app in this batch below `High`.
- **Safety status**: results of the mandatory 18-keyword scan
  (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
  `furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
  `furi_hal_infrared_async_tx_start`, `badusb`, `ble`, `deauth`, `jam`,
  `brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`),
  run against each app's real, freshly-fetched source file(s) in full.
- **Import readiness**: `CLEARED FOR IMPORT` / `DEFER` / `BLOCKED` /
  `NEEDS REVIEW` — see `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md` for the
  full per-app reasoning behind each classification.

## Aggregate

**3 of 3 apps: CLEARED FOR IMPORT.** No app in this batch requires
deferral or blocking. The original 3-app recommended batch from
`PHASE2B_RECOMMENDED_BATCH.md` remains fully valid and does not need to
shrink. See `PHASE2B_1_GO_NO_GO.md` for the final classification and next
allowed gate.

# Storage and Data Behavior Audit — Full 20-App Consolidation

Docs-only. Consolidated storage/data-behavior record for all 20 custom
apps, drawn from each phase's `SAFETY_REVIEW.md` and `IMPORT_LOG.md`
documents and direct source inspection. All storage behavior described
below is confirmed by direct source-code read, not assumed; no phase
claims hardware-observed storage behavior — this is source/CI-level
verification only.

## Per-app storage behavior

| App | Behavior class | Detail |
|---|---|---|
| `network_subnet` | Not documented individually | No storage-API flag raised in Phase 2A's combined scan |
| `programmer_calc` | Not documented individually | No storage-API flag raised in Phase 2A's combined scan |
| `vin_decoder` | Not documented individually | No storage-API flag raised in Phase 2A's combined scan |
| `flipper95` | No storage access | Compute-only CLI commands |
| `chess` | App-private write | `helpers/flipchess_file.c` → `EXT_PATH("apps_data/flipchess")/board_fen.txt`(`.bak`) |
| `flipfetch` | Read-only | Single `storage_common_fs_info()` call to display free SD space; no file opened or written |
| `quadratic_solver` | No storage access | No `storage/storage.h` include, no storage API call anywhere in source |
| `sudoku` | **App-private write** | `APP_DATA_PATH("save.dat")` → `/ext/apps_data/sudoku/save.dat`, via `storage_file_open/read/write` + `storage_simply_remove` |
| `sd_info` | **Controlled temporary benchmark writes/deletes at SD-card root** | `TEST_FILE_PATH = "/ext/sdtest.tmp"`; 48× 32KB block write/read/verify/delete cycles; each block deleted immediately after its own verify; only runs on explicit user-initiated "start test" action; not app-private (SD root, not `/ext/apps_data/sd_info/`), not persistent, not automatic |
| `docviewlite` | **Read-only** | One `storage_file_open(FSAM_READ, FSOM_OPEN_EXISTING)` call on a user-selected `.txt` file (standard Flipper file-browser dialog); zero write calls anywhere in the 984-line source |
| `resistors` | No storage access | Zero storage API usage of any kind |
| `crypto_dictionary` | **Read-only bundled glossary access** | Opens only its own bundled `resources/**/*.txt` cipher-glossary files via `FSAM_READ`/`FSOM_OPEN_EXISTING`; no write call anywhere; no text-input field or path for user-supplied data to enter |
| `2048` | **App-scoped save path** | `/ext/apps_data/game_2048/game_2048.save`, via hardcoded `EXT_PATH(...)` literal (not the `APP_DATA_PATH` macro, but functionally app-scoped and non-colliding); one-time no-op legacy-path migration check on load |
| `image_viewer` | **Read-only, user-selected file** | `file_stream_open(FSAM_READ, FSOM_OPEN_EXISTING)` is the only storage call; opens whatever file the user selects at runtime via the standard file browser; default browse directory `/ext/apps_assets/image_viewer`; zero writes of any kind |
| `boilerplate` | App-private write | `helpers/boilerplate_storage.c` writes one settings file at `/ext/apps_data/boilerplate/boilerplate.conf`; no shared/root-level writes |
| `minesweeper` | App-private write, atomic | `helpers/mine_sweeper_storage.c` writes via atomic write-then-rename: `.../mine_sweeper_redux.conf.tmp` → `.../mine_sweeper_redux.conf`, both under `/ext/apps_data/mine_sweeper_redux/`; no shared/root-level writes |
| `qrcode` | Read-only for content, **legacy-folder migration** | QR content read-only (`flipper_format_read_*` only, no write function). At every launch: `storage_common_copy(ANY_PATH("qrcodes"), QRCODE_FOLDER)` then `storage_common_remove(ANY_PATH("qrcodes"))` — migrates data from the old shared `qrcodes` folder path to the app's new `QRCODE_FOLDER` path, then removes the old folder; same benign migration class as `2048`'s legacy-path check |
| `hex_viewer` | **Read-only viewed files + app-private settings** | Viewed files opened `FSAM_READ`/`FSOM_OPEN_EXISTING` only — no write/edit/patch/overwrite/delete call touches a viewed file anywhere in the source. Settings (4 boolean toggles) stored app-privately at `/ext/apps_data/hex_viewer/` |
| `barcode_gen` | **App-private storage** | Confined to `/ext/apps_data/barcodes/` for all create/edit/rename/delete operations (`storage_simply_mkdir`, `storage_common_rename`, `storage_simply_remove`); no scanner-emulation, access-control, HID, NFC, or USB behavior; no persistent sensitive-payload storage beyond user-chosen barcode data/filename |
| `fcc_id_lookup` | **Read-only, app-scoped, optional database access** | Zero write-capable storage calls anywhere (11 call sites inventoried: seek/read/size/is_open/close/free/alloc/open, all read-side). Optional external database (`fcc_freq_v2.bin`, not bundled) resolves to app-scoped `/ext/apps_assets/fcc_id_lookup/`; graceful in-app setup-hint shown if the file is absent, no crash |

## App-private writes

`chess`, `sudoku`, `2048`, `boilerplate`, `minesweeper`, and
`barcode_gen` all write exclusively under their own `/ext/apps_data/
<app>/` (or equivalent app-scoped) directory. None of these apps writes
to a shared or root-level path.

## Read-only behavior

`flipfetch` (SD-space query only), `docviewlite`, `crypto_dictionary`,
`image_viewer`, `hex_viewer` (viewed files), and `fcc_id_lookup` perform
no writes of any kind — confirmed by direct source inspection finding
zero `FSAM_WRITE`/`FSOM_CREATE*`/`storage_file_write` calls in each.

## Optional external data / database files not bundled

- **`fcc_id_lookup`** — the ~8.9MB FCC frequency/applicant database
  (`fcc_freq_v2.bin`) is a separate, optional, end-user-sourced download
  placed at `/ext/apps_assets/fcc_id_lookup/`. Not bundled, not
  committed anywhere in this repository. The app degrades gracefully
  (setup-hint message) if absent.

No other app in the project references an optional external
database.

## Shared/root-level write risks

**One identified case, reviewed and accepted**: `sd_info`'s
`/ext/sdtest.tmp*` benchmark files are written at the SD-card root
rather than an app-private path. Reviewed and accepted as safe because
the writes are transient (each block deleted immediately after its own
verify), user-initiated (only on explicit "start test" action, never
automatic), and touch no shared configuration file. No other app in the
project writes to a shared or root-level location — the two candidate
apps that would have (`animation_switcher`, `theme_manager`, both
writing to `/ext/dolphin/`) were excluded from import specifically for
this reason and are documented in
`docs/THIRD_PARTY_LICENSE_AUDIT.md`.

## Temporary files

`sd_info`'s `/ext/sdtest.tmp*` block files (see above) and
`minesweeper`'s `.conf.tmp` atomic-write intermediate file are the only
two temporary-file patterns identified in the project. Both are
self-cleaning: `sd_info` deletes each block immediately after its own
verify; `minesweeper`'s `.tmp` file is renamed to its final name on
successful write (standard atomic-write pattern, not a leftover
artifact).

## Migration behavior

Two apps perform a one-time, bounded, self-cleaning data migration on
launch:

- **`2048`** — checks a legacy save-file path
  (`/ext/apps/Games/game_2048.save`) on load; a silent no-op on a fresh
  import since no such file exists.
- **`qrcode`** — copies the old shared `qrcodes` folder into the app's
  new `QRCODE_FOLDER` path, then removes the old folder, at every
  launch (`storage_common_copy` + `storage_common_remove`).

Both are the same benign migration class: reading from/removing an old
location and consolidating into the app's own path, not writing to a
new shared location.

## User-selected file behavior

`docviewlite` and `image_viewer` both open files chosen by the user
through the standard Flipper file-browser dialog — neither hardcodes a
specific filename or path beyond a default browse directory
(`/ext/apps_assets/image_viewer` for `image_viewer`). Both are strictly
read-only for the user-selected file; neither writes to it, renames it,
or deletes it.

## Summary

Of 20 apps: 6 perform no storage access at all, 6 are strictly
read-only, 6 write exclusively to app-private paths, 1 (`qrcode`)
combines read-only content access with a bounded legacy-folder
migration, and 1 (`sd_info`) performs the project's only
non-app-scoped writes — transient, user-initiated, and reviewed as
safe. No app performs a persistent shared/root-level write. No database
or bundled data file exceeds a few kilobytes except `crypto_dictionary`'s
14 cipher-glossary text files (all read-only, all bundled at import
time) and `barcode_gen`'s 4 encoding-table text files (same).

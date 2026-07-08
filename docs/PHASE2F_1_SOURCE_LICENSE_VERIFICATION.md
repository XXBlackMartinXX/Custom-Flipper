# Phase 2F.1 — Source and License Verification

Docs only. Pre-import verification only. **No app code has been imported.**
This is a genuine, fresh source-level verification pass — unlike the
Phase 2F planning package (`PHASE2F_CANDIDATE_REVIEW.md`,
`PHASE2F_LICENSE_REVIEW.md`), which was citation-only (drawing on the
existing Phase 1.6 audit), this phase had real, working network access and
fetched the actual source. Every finding below is from files actually read
in this session, not carried forward from any prior audit.

## Evidence source

- **Repository**: `RogueMaster/flipperzero-firmware-wPlugins` (the same
  fork every prior Phase 1/2A/2B/2C/2D/2E source audit has cited).
- **Commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same
  commit `PHASE1_6_TOP25_SOURCE_AUDIT.md`,
  `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`,
  `PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`,
  `PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`, and
  `PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` all audited, fetched fresh
  via a blobless clone plus cone sparse-checkout limited to the 3 target
  app directories, then `git checkout 472f6925e8aca9bd031cb37e3cb80b551772c957`,
  with the resulting `git log -1` hash independently confirmed to match
  exactly. **No discrepancy found** between this source and what the
  Phase 2F planning docs assumed — no stop/discrepancy report is needed.
- **Method**: sparse checkout into a scratch directory outside this
  repository, then direct `cat`/`grep`/`wc`/`find` against the real
  checked-out files. Nothing was fetched into, or committed from, this
  project's own working tree — the scratch clone lives entirely outside
  `/home/user/Custom-Flipper` and is not part of any commit.

## Apps reviewed (exactly the 3 in scope)

`qrcode`, `hex_viewer`, `barcode_gen`. No other app was fetched, read, or
considered. `fcc_id_lookup`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, `theme_manager`, and `image_viewer/example_images/`
were not touched in this phase, per the explicit hard exclusions.

---

## `qrcode`

| Field | Value |
|---|---|
| Upstream source path | `applications/external/qrcode/` — confirmed present, matches planning docs |
| App directory name | `qrcode` |
| `application.fam` | Present, confirmed |
| appid | `qrcode` — **matches** the planning-stage assumption, no discrepancy |
| App name (manifest) | "QR Code" |
| `fap_author` | Bob Matcuk |
| `fap_weburl` | `https://github.com/bmatcuk/flipperzero-qrcode` |
| `fap_version` | 2.1 |
| Source files | `qrcode.c` (956 lines), `qrcode.h` (96 lines), `qrcode_app.c` (915 lines) |
| Asset/data files | `icons/qrcode_10px.png` (declared via `fap_icon_assets`); `ss1.png`, `ss2.png` (README screenshots only, not referenced by `application.fam`, not packaged into the build) |
| Generated files | None found |
| Source path conflict with existing imported app | None — `qrcode` appid does not collide with any of the 16 already-imported appids or any base `applications/` appid |

**License evidence**: Full, unmodified MIT `LICENSE` file present at the app root. Copyright (c) 2022 Bob Matcuk. No missing-license issue.

**Bundled third-party code — real finding**: `qrcode.c`/`qrcode.h` is a **bundled third-party QR-encoding library**, not the wrapper author's own original algorithm. The file's own header reads:

> "This library is written and maintained by Richard Moore. Major parts were derived from Project Nayuki's library. Copyright (c) 2017 Richard Moore (https://github.com/ricmoo/QRCode). Copyright (c) 2017 Project Nayuki (https://www.nayuki.io/page/qr-code-generator-library)"

Both are **MIT-licensed**, fully compatible with the wrapper app's own MIT license and with GPLv3 firmware distribution. The app's own `README.md` independently corroborates this: "This application uses the [QRCode] library by ricmoo. This is the same library that is in the lib directory of the flipper-firmware repo (which was originally included for a now-removed demo app), but modified slightly to fix some compiler errors and allow the explicit selection of the qrcode mode." This is real, direct, in-file attribution — not an unresolved provenance question. Both original copyright notices remain intact in the file header, satisfying MIT's attribution requirement.

**License compatible with GPLv3 firmware distribution**: Yes — MIT is a well-established GPLv3-compatible permissive license (the same reasoning already applied to every other MIT-licensed app in this project).

**Attribution requirements**: Preserve the full `LICENSE` file verbatim at import; preserve the `qrcode.c`/`qrcode.h` in-file copyright header exactly as-is (already satisfies MIT's requirement); credit Bob Matcuk (wrapper) and Richard Moore/Project Nayuki (bundled library) in the project's third-party notices.

### Safety/API scan (real, direct grep against the actual source)

Full keyword list scanned across `qrcode.c`, `qrcode.h`, `qrcode_app.c`:
`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `ble`, `deauth`, `jam`,
`brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`,
`seed`, `wallet`, `private key`, `secret`, `access`, `auth`, `scan`,
`camera`, `hid_`.

**Result: zero real unsafe/capability matches.** All hits were benign
content-only or false positives:
- 3 hits on "AUTHORS"/comment text inside the MIT license boilerplate — content-only, not a capability.
- 1 comment "the funny zigzag scan" — refers to the QR matrix's own internal data-layout scanning algorithm (part of the encoding library itself), not a hardware or security scanner.
- No `ble`/`auth`/`credential`/`password`/`token` matches of any kind (not even a substring false positive).

### Storage/dependency verification (real, direct source read)

- **Storage behavior — confirmed, not assumed**: `qrcode_app.c` defines `QRCODE_FOLDER = EXT_PATH("apps_data/qrcodes")` — an app-scoped, app-private path. The app is **read-only for QR content**: `qrcode_load_file()` opens a user-selected `.qrcode` file and reads `Message`/`QRMode`/`QRVersion`/`QRECC` fields via `flipper_format_read_*` calls only. **No `flipper_format_write_*`, `storage_file_write`, or any save/write function exists anywhere in `qrcode_app.c`** — this version of the app has no "save a newly created QR code" feature; it only displays QR codes generated from pre-existing `.qrcode` text files (created by hand, by another tool, or by a prior app version).
- **One real storage write pattern found — a one-time legacy-path migration**, run unconditionally at every app launch: `storage_common_copy(storage, ANY_PATH("qrcodes"), QRCODE_FOLDER)` followed by `storage_common_remove(storage, ANY_PATH("qrcodes"))` — copies any content from a legacy root-level `qrcodes` folder into the new app-scoped folder, then deletes the old location. This is the **exact same pattern** already accepted for `2048` in Phase 2D.2 (`EXT_PATH("apps_data/game_2048")` plus a legacy-path migration check) — a silent no-op if the legacy folder doesn't exist, real but bounded, self-cleaning, one-time behavior, not an ongoing shared-storage write.
- **Dependencies**: None declared beyond the bundled `qrcode.c`/`qrcode.h` library (already covered above).
- **Hardware/peripheral behavior**: None. No RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR usage anywhere in the source.
- **Sensitive user data**: The app displays whatever text the user's own `.qrcode` file contains. The README documents a common real-world use case (encoding WiFi SSID/password into a QR code for sharing, per the WPA WiFi-QR convention used by many commercial router setup cards) — this is the user's own choice of what text to encode, not the app extracting, storing, or transmitting credentials on its own initiative. No persistent storage of any payload beyond what the user already saved into their own `.qrcode` file before opening it. Not classified as a credential-handling capability in the safety-exclusion-list sense.

### Build-risk estimate

Small-to-medium (1,967 total source lines across 3 files, largely the bundled encoding library). No unusual libraries beyond the bundled QR-encoding code itself. No generated files. Expected `.fap` output name: `qrcode.fap` (matches appid). No source path conflict. No source changes anticipated outside this app's own directory.

### Conclusion: **CLEARED FOR IMPORT**

---

## `hex_viewer`

| Field | Value |
|---|---|
| Upstream source path | `applications/external/hex_viewer/` — confirmed present, matches planning docs |
| App directory name | `hex_viewer` |
| `application.fam` | Present, confirmed |
| appid | `hex_viewer` — **matches** the planning-stage assumption, no discrepancy |
| App name (manifest) | "HEX Viewer" |
| `fap_author` | QtRoS |
| `fap_version` | (2, 0) |
| Source files | 20 files across `helpers/` (haptic, LED, speaker, storage), `views/` (start screen), `scenes/` (menu, open, scroll, settings, info, start screen) |
| Asset/data files | `icons/hex_10px.png`/`.bmp` (declared via `fap_icon_assets`); `img/1.png`, `img/2.png` (README screenshots only, not referenced by `application.fam`) |
| Generated files | None found |
| Source path conflict with existing imported app | None |

**License evidence**: Full, unmodified MIT `LICENSE` file present at the app root. Copyright (c) 2022 Roman Shchekin. No missing-license issue.

**Bundled third-party code/data/assets**: None identified. All 20 files are the author's own implementation (confirmed by direct read of every `helpers/`, `views/`, and `scenes/` file).

**License compatible with GPLv3 firmware distribution**: Yes — MIT, same reasoning as every other MIT-licensed app in this project.

**Attribution requirements**: Preserve the full `LICENSE` file verbatim at import; credit Roman Shchekin (QtRoS) in the project's third-party notices.

### Safety/API scan (real, direct grep against the actual source, all 20 files)

Same full keyword list as `qrcode`, scanned recursively across every `.c`/`.h` file in the app directory.

**Result: zero matches of any kind** — not even a benign false positive. No `ble`, `auth`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`, `seed`, `wallet`, `private key`, `secret` substring anywhere in the source.

`helpers/hex_viewer_haptic.c`, `helpers/hex_viewer_led.c`, and `helpers/hex_viewer_speaker.c` use only the base firmware's own standard, safe `notification_message()` API (vibration/LED feedback via the shared `NotificationApp` record — the same mechanism used throughout the base firmware and every already-accepted app that provides UI feedback) and `furi_hal_speaker_start`/`stop`/`acquire`/`release` (the standard, safe beeper API used for simple tones, not a radio or security-relevant peripheral). All three are gated behind user-configurable settings toggles (`app->haptic`, `app->led`, `app->speaker`) read from the app's own config file. No GPIO write, no RF, no unsafe hardware control of any kind.

### Storage/dependency verification (real, direct source read) — **resolves the Phase 2F planning ambiguity**

Phase 2F planning flagged `hex_viewer`'s "2 files touch storage APIs" citation as needing direct confirmation of read-only behavior before import. Both files have now been read in full:

- **`helpers/hex_viewer_storage.c`** (the 2 files cited are this `.c` and its `.h`) contains exactly two categories of storage behavior:
  1. **`hex_viewer_open_file()`/`hex_viewer_read_file()`** — opens the user-selected file via `buffered_file_stream_open(..., FSAM_READ, FSOM_OPEN_EXISTING)` and reads it via `stream_read()`. **`FSAM_READ` only — no write, edit, patch, overwrite, or delete call touches the viewed file anywhere in the source.** This confirms the app is genuinely read-only for the file it views, exactly as its name and README ("view various files as HEX") describe.
  2. **`hex_viewer_save_settings()`/`hex_viewer_read_settings()`** — writes/reads the app's own config file at `CONFIG_FILE_DIRECTORY_PATH = EXT_PATH("apps_data/hex_viewer")`, storing only 4 boolean toggle values (`Haptic`, `Led`, `Speaker`, `SaveSettings`). This is a **confirmed app-private path**, not shared or root-level storage. The one delete call in this file (`storage_simply_remove`) operates only on the app's own settings file, as part of an overwrite-by-delete-then-recreate pattern — not on the viewed file.
- **No scene file** (`hex_viewer_scene_menu.c`, `hex_viewer_scene_open.c`, `hex_viewer_scene_scroll.c`, `hex_viewer_scene_settings.c`, `hex_viewer_scene_info.c`, `hex_viewer_scene_startscreen.c`) contains any storage/remove/delete/rename/write call — confirmed by direct grep across all scene files.
- **Dependencies**: None declared.
- **Hardware/peripheral behavior**: None beyond the standard notification/speaker feedback already described. No RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR.
- **Sensitive user data**: None handled — the app views whatever file the user selects; no credential, token, or secret-specific logic exists.

**The special-caution stop condition ("if it edits, patches, overwrites, deletes, or writes user-selected files, mark DEFER") does not trigger.** The app has zero write capability against any file the user opens.

### Build-risk estimate

Low-Medium (20 files, largest of the 3, but no unusual libraries, no bundled data assets beyond icons). Expected `.fap` output name: `hex_viewer.fap` (matches appid). No source path conflict. No source changes anticipated outside this app's own directory.

### Conclusion: **CLEARED FOR IMPORT**

---

## `barcode_gen`

| Field | Value |
|---|---|
| Upstream source path | `applications/external/barcode_gen/` — confirmed present, matches planning docs |
| App directory name | `barcode_gen` |
| `application.fam` | Present, confirmed |
| appid | **`barcode_app`** — **DISCREPANCY from the planning-stage assumption** (`barcode_gen`, the directory-name assumption used since Phase 1). Same class of finding as `boilerplate` (`fap_boilerplate`) and `minesweeper` (`minesweeper_redux`) in Phase 2E.1 — a real, harmless directory-name-vs-appid mismatch, not a license or safety issue. Recorded precisely so no reader is misled by older planning docs. |
| App name (manifest) | "Barcode App" |
| `fap_author` | Kingal1337 |
| `fap_weburl` | `https://github.com/Kingal1337/flipper-barcode-generator` |
| `fap_version` | 1.4 |
| Source files | 16 files: `barcode_app.c`/`.h`, `barcode_utils.c`/`.h`, `barcode_validator.c`/`.h`, `encodings.c`/`.h`, `views/barcode_view.c`/`.h`, `views/create_view.c`/`.h`, `views/message_view.c`/`.h`, `keyboard/text_input.c`/`.h` |
| Asset/data files | **4 bundled encoding-table `.txt` files** (`code39_encodings.txt`, `code128_encodings.txt`, `code128c_encodings.txt`, `codabar_encodings.txt`) under `barcode_encoding_files/`, correctly declared via `fap_file_assets="barcode_encoding_files"`; keyboard icon `.png` files under `keyboard/icons/` (declared via `fap_icon_assets`); `img/`/`screenshots/` (README illustration screenshots only, not referenced by `application.fam`, duplicated across two directories in the upstream tree) |
| Generated files | None found |
| Source path conflict with existing imported app | None — `barcode_app` appid does not collide with any of the 16 already-imported appids or any base `applications/` appid |

**License evidence**: Full, unmodified MIT `LICENSE` file present at the app root. Copyright (c) 2023 Alan Tsui (the real name behind the `Kingal1337` GitHub handle — the same "real name in copyright, handle in `fap_author`" pattern already seen for `minesweeper`/squee72564 in Phase 2E). No missing-license issue for the wrapper app.

**Bundled third-party code/data — real finding, now directly confirmed**: The 4 bundled encoding-table `.txt` files were read in full. All 4 contain nothing but raw character-to-bar-width-pattern lookup tables for their respective barcode symbologies (e.g. `code39_encodings.txt`: `0: 000110100`, `1: 100100001`, ...; `codabar_encodings.txt` includes 2 explanatory comment lines about bar/space alternation convention). **These are standard, publicly documented technical specification data** for internationally standardized barcode symbologies (Code 39, Code 128, Code 128C, Codabar) — the character-to-bar-pattern mapping is dictated by the published symbology specification itself, not original creative expression by any single author. This confirms the Phase 2F planning assessment: a materially lower provenance concern than a creative work (like `image_viewer`'s excluded bitmap images), and the tables are correctly packaged as declared app assets, not vendored/uncredited code.

**Other bundled code**: `keyboard/text_input.c`/`.h` (817 lines) is a custom on-screen keyboard widget with no separate copyright header of its own; the README's credits list attributes it to "thevan4 - Added custom keyboard." No separate third-party license notice exists for this file, but the app's single top-level `LICENSE` file is the same all-app-covering pattern already accepted for every other app in this project (e.g. `boilerplate`, `minesweeper`) — not itself a missing-license issue, just noted for completeness.

**License compatible with GPLv3 firmware distribution**: Yes — MIT, same reasoning as every other MIT-licensed app in this project. The bundled encoding tables, being non-copyrightable technical/factual data, carry no separate license requirement.

**Attribution requirements**: Preserve the full `LICENSE` file verbatim at import; credit Kingal1337 (Alan Tsui), Z0wl (Code128-C support), @teeebor (menu code snippet), and thevan4 (custom keyboard) per the README's own credits section, in the project's third-party notices.

### Safety/API scan (real, direct grep against the actual source, all 16 files)

Same full keyword list as `qrcode`/`hex_viewer`, scanned recursively.

**Result: zero real unsafe/capability matches.** The only 2 substring hits on `auth` were both `@author`/`author:` attribution comments in `views/create_view.c` and `barcode_app.c` — confirmed benign false positives, not authentication logic. No `ble`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`, `seed`, `wallet`, `private key`, `secret`, `scan` (as in scanner), `camera`, or `hid_` match anywhere.

### Storage/dependency verification (real, direct source read) — **resolves the Phase 2F planning ambiguity**

Phase 2F planning flagged `barcode_gen`'s "3 files touch storage APIs" citation as needing direct confirmation before import. All storage-touching code has now been read:

- **`barcode_app.h`** defines `DEFAULT_USER_BARCODES = EXT_PATH("apps_data/barcodes")` — a confirmed app-scoped, app-private path (the app's own `README.md` independently corroborates this: "Note: Barcode save locations have been moved from `/barcodes` to `/apps_data/barcodes`" — a deliberate, documented improvement by the author, not an accident this review discovered).
- **`views/create_view.c`** performs create/edit/rename/delete operations (`storage_simply_remove`, `storage_common_rename`) exclusively on paths constructed from `DEFAULT_USER_BARCODES` — confirmed by reading the exact path-construction code (`furi_string_alloc_set(DEFAULT_USER_BARCODES)` followed by appending the user-chosen filename). No write, rename, or delete call touches any path outside this app-private folder.
- **`barcode_app.c`** calls `storage_simply_mkdir(storage, DEFAULT_USER_BARCODES)` once, to ensure the app-private folder exists — the only other storage call in this file.
- **The 4 bundled encoding-table files are read-only**, accessed via the standard `APP_ASSETS_PATH(...)` macro (the FAP asset-bundling mechanism, resolving to the app's own bundled read-only resource directory) — no write call touches them anywhere in the source.
- **Dependencies**: None declared beyond the bundled encoding-table data (already covered above).
- **Hardware/peripheral behavior**: None. No RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR usage. No scanner-emulation, HID, or USB behavior of any kind — this is a display/generation app only, confirmed by the absence of any `hid_`/`usb_hid`/`camera`/scanner-related code.
- **Sensitive user data**: The app displays/encodes whatever text the user types when creating a barcode. No credential-specific handling, no network behavior, no access-control use case identified anywhere in the source.

**The special-caution stop conditions for `barcode_gen` (credential-payload workflow, access-control use, scanner-emulation, HID/NFC/USB behavior, network behavior, persistent sensitive-payload storage, unclear bundled-table provenance) do not trigger.**

### Build-risk estimate

Low-Medium (16 files plus the 4 bundled encoding-table files, already correctly declared via `fap_file_assets`). No unusual libraries. Expected `.fap` output name: **`Barcode_app.fap`** (per the app's own `appid="barcode_app"` and its README's own build instructions, which name the exact output path — note the manifest's `appid` is lowercase `barcode_app` but the README's documented build output capitalizes it as `Barcode_app.fap`; the real, build-produced filename is derived from `appid` per the FAP build system's own convention and should be confirmed at actual build time rather than assumed from the README text alone). No source path conflict. No source changes anticipated outside this app's own directory.

### Conclusion: **CLEARED FOR IMPORT**

---

## Summary

| App | appid confirmed | License | Bundled third-party content | Safety scan | Storage confirmed | Conclusion |
|---|---|---|---|---|---|---|
| `qrcode` | `qrcode` (matches) | MIT | Yes — bundled MIT QR-encoding library (ricmoo/Nayuki), attributed inline | Clean | App-private + one-time benign legacy migration | **CLEARED FOR IMPORT** |
| `hex_viewer` | `hex_viewer` (matches) | MIT | None | Clean | App-private only; confirmed read-only for viewed files | **CLEARED FOR IMPORT** |
| `barcode_gen` | `barcode_app` (**discrepancy**, directory name ≠ appid) | MIT | Yes — 4 standard technical-data encoding tables, correctly declared | Clean | App-private only | **CLEARED FOR IMPORT** |

All 3 apps are cleared for import. No app is deferred or blocked. The
original 3-app recommended batch remains valid at full size. See
`docs/PHASE2F_1_GO_NO_GO.md` for the formal gate decision.

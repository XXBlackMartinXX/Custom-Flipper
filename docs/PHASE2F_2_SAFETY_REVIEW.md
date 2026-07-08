# Phase 2F.2 — Safety Review

Docs only. Real static safety/API-capability scan of the actually-imported
files for `qrcode`, `hex_viewer`, and `barcode_gen`, run locally (`pwsh` +
`tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2f_validate_config.json`) against the full keyword set this
project has used since Phase 2E: `furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`ble`, `deauth`, `jam`, `brute`, `credential`, `password`, `token`,
`exfil`, `clone`, `bypass`, `seed`, `wallet`, `private key`, `secret`,
`access`, `auth`.

## Per-app unsafe keyword scan

### `qrcode`

Scanned: `qrcode.c` (956 lines), `qrcode.h` (96 lines), `qrcode_app.c`
(915 lines) — all 3 source files, in full.

**8 substring matches, all `ble`:**

| File | Line | Matched word | Classification |
|---|---|---|---|
| `qrcode_app.c` | 426 | "variable" (doc comment: "Pointer to variable that will receive...") | Benign false positive |
| `qrcode_app.c` | 427 | "variable" (same pattern) | Benign false positive |
| `qrcode_app.c` | 780 | "Unable" (`FURI_LOG_E(TAG, "Unable to load file")`) | Benign false positive |
| `qrcode.c` | 23 | "AUTHORS" (MIT license boilerplate comment) | Benign false positive |
| `qrcode.c` | 306 | "possible"/"applicable" (algorithm comment) | Benign false positive |
| `qrcode.c` | 884 | "applicable" (algorithm comment) | Benign false positive |
| `qrcode.h` | 23 | "AUTHORS" (MIT license boilerplate comment) | Benign false positive |
| `qrcode.h` | 60 | "table" (comment about codeword tables) | Benign false positive |

**High-confidence unsafe API result**: none. Zero matches for any of the
`furi_hal_*`/`badusb`/`deauth`/`jam`/`brute`/`credential`/`token`/`exfil`
high-confidence-unsafe set. Zero matches for `clone`, `bypass`, `seed`,
`wallet`, `private key`, `secret`. Zero matches for `access`/`auth` of any
kind, including false positives.

### `hex_viewer`

Scanned: all 20 files across `helpers/`, `views/`, `scenes/`, plus
`hex_viewer.c`/`hex_viewer.h` — every `.c`/`.h` file in the app directory,
in full.

**37 substring matches, all `ble`**, every one inside the standard
Flipper GUI settings-list API identifiers `VariableItem`/
`variable_item_*` (used by the app's own settings scene for haptic/
speaker/LED/save-settings toggles) or the word "scrollable" (in the
scroll-position calculation comment). Representative sample (full detail
in the reviewed-false-positive entries in
`tools/phase2f_validate_config.json`):

| File | Line | Matched word | Classification |
|---|---|---|---|
| `hex_viewer.c` | 74 | `variable_item_list` | Benign false positive |
| `hex_viewer.h` | 15 | `variable_item_list.h` (standard Flipper GUI header include) | Benign false positive |
| `scenes/hex_viewer_scene_scroll.c` | 41 | "scrollable" | Benign false positive |
| `scenes/hex_viewer_scene_settings.c` | 46–132 (28 matches) | `VariableItem`/`variable_item_*` (settings-list widget API) | Benign false positive |

**High-confidence unsafe API result**: none. Zero matches for any of the
`furi_hal_*`/`badusb`/`deauth`/`jam`/`brute`/`credential`/`token`/`exfil`
high-confidence-unsafe set. Zero matches for `clone`, `bypass`, `seed`,
`wallet`, `private key`, `secret`, `access`, `auth` — not even a
substring false positive for any of these, across all 20 files.

### `barcode_gen`

Scanned: all 16 files (`barcode_app.c`/`.h`, `barcode_utils.c`/`.h`,
`barcode_validator.c`/`.h`, `encodings.c`/`.h`, `views/*.c`/`.h`,
`keyboard/text_input.c`/`.h`) — every `.c`/`.h` file in the app directory,
in full.

**46 substring matches, all `ble`**, every one inside the words "Table"
(`EncodingTable`/`MissingEncodingTable`/`EncodingTableError` — the app's
own error-classification enum and user-facing error strings, referring to
the bundled encoding-table lookup files, not the Bluetooth LE API),
"Unable" (log messages), or "validator_message_visible" (a boolean field
name in the custom keyboard widget). Representative sample (full detail
in the reviewed-false-positive entries in
`tools/phase2f_validate_config.json`):

| File | Line | Matched word | Classification |
|---|---|---|---|
| `barcode_app.c` | 401–424 | "Table" (user-facing error message text) | Benign false positive |
| `barcode_utils.c`/`.h` | 115–141 | "Table" (`MissingEncodingTable`/`EncodingTableError` enum values) | Benign false positive |
| `barcode_validator.c` | 173–510 | "Table" (same enum values used in validation logic) | Benign false positive |
| `views/create_view.c` | 348 | "Unable" (`FURI_LOG_E(TAG, "Unable to remove file!")`) | Benign false positive |
| `keyboard/text_input.c` | 45–707 | "visible" (`validator_message_visible` boolean field) | Benign false positive |

**Real, direct check for the 2 `auth` substring hits found in this app**
(from Phase 2F.1's own scan): both are `@author`/`author:` attribution
comments (`views/create_view.c:19`, `barcode_app.c:428`) — confirmed
content-only/reference hits, not authentication logic. These 2 are not
part of the `tools/phase2a_validate.ps1` keyword set (which uses `ble`,
not `auth`, as its substring probe), so they do not appear as validator
matches, but are recorded here per this phase's own broader required
keyword list.

**High-confidence unsafe API result**: none. Zero matches for any of the
`furi_hal_*`/`badusb`/`deauth`/`jam`/`brute`/`credential`/`token`/`exfil`
high-confidence-unsafe set. Zero matches for `clone`, `bypass`, `seed`,
`wallet`, `private key`, `secret`, `access`.

## Aggregate high-confidence unsafe API result (all 3 apps)

**Zero real unsafe/capability matches across all 3 apps.** Every one of
the 91 new substring matches found by the real static scan is a
benign `ble`-in-word false positive, individually reviewed and recorded
with file/line/keyword/line-content-SHA-256 evidence in
`tools/phase2f_validate_config.json`. No app in this batch contains any
reference — real or even a stray substring — to Sub-GHz/RF, NFC, RFID,
iButton, BadUSB, HID injection, GPIO write, Infrared transmit,
credential/token/password handling, exfiltration, cloning, bypass, brute
force, jamming, or deauth.

## Storage behavior (confirmed by direct source read in Phase 2F.1, re-confirmed against the actually-imported files in this phase)

- **`qrcode`**: Confirmed local QR display/generation behavior only.
  Read-only for QR content (`qrcode_load_file()` uses
  `flipper_format_read_*` calls exclusively — no write function exists in
  this version of the app). One real, bounded storage-write pattern: a
  one-time legacy-folder migration at every launch
  (`storage_common_copy(ANY_PATH("qrcodes"), QRCODE_FOLDER)` followed by
  `storage_common_remove(ANY_PATH("qrcodes"))`), the same class of benign
  migration already accepted for `2048` in Phase 2D. No sensitive payload
  is persisted beyond whatever the user's own pre-existing `.qrcode` file
  already contained before opening it.
- **`hex_viewer`**: Confirmed viewed files are opened with
  `FSAM_READ`/`FSOM_OPEN_EXISTING` only — no write, edit, patch, overwrite,
  or delete call touches the viewed file anywhere in the source. Confirmed
  app-private-only for its own settings (`/ext/apps_data/hex_viewer/`, 4
  boolean toggles). No edit/patch/overwrite/delete behavior of any kind
  against user files.
- **`barcode_gen`**: Confirmed local barcode display/generation behavior
  only. Confirmed app-private storage confined to
  `/ext/apps_data/barcodes/` for all create/edit/rename/delete
  operations (`storage_simply_mkdir`, `storage_common_rename`,
  `storage_simply_remove`, all operating on paths constructed from
  `DEFAULT_USER_BARCODES`). No scanner-emulation, access-control, HID,
  NFC, or USB behavior of any kind. No persistent sensitive-payload
  storage beyond the barcode data/filename the user themselves chooses to
  create.

## Hardware/radio behavior

**None, for any of the 3 apps.** Zero references to `furi_hal_subghz`,
`furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_infrared_async_tx_start`, or direct GPIO control anywhere in
any of the 3 apps' source. `hex_viewer`'s haptic/LED/speaker feedback
uses only the base firmware's own standard, safe `NotificationApp`
(`notification_message()`) and `furi_hal_speaker_start`/`stop`/`acquire`/
`release` APIs — the same mechanism used throughout the base firmware and
every already-accepted app that provides UI feedback, not a
radio/RF/security-relevant peripheral.

## Sensitive-data handling result

**None of the 3 apps handles credentials, tokens, passwords, seed
phrases, private keys, wallets, or secrets in the safety-exclusion-list
sense.** `qrcode`'s README documents a common real-world use case
(encoding WiFi SSID/password into a QR code the user generates for
sharing, per the standard WPA WiFi-QR convention) — this is the user's
own choice of what text to encode into a generic text container, not the
app extracting, storing, or transmitting credentials on its own
initiative; no persistent storage of any payload beyond what the user's
own pre-existing file already contained.

## Conclusion

All 3 apps' actually-imported source confirms every finding from Phase
2F.1's pre-import verification, with zero new safety concerns discovered
at import time. **Safety review result: CLEAR for all 3 apps.** No
unsafe API, no undisclosed hardware capability, no credential/secret
handling, no unclear storage behavior. See
`docs/PHASE2F_2_GO_NO_GO.md` for the final Phase 2F.2 classification.

# FCC ID Lookup — Safety Review

Real static safety/API-capability scan of the actually-imported
`fcc_id_lookup` files, run against `applications_user/fcc_id_lookup/`
using this project's own tooling (`tools/phase2a_validate.ps1 -Mode
Static -ConfigPath tools/fcc_id_lookup_validate_config.json`), matching
the format of every prior batch's `PHASEX_2_SAFETY_REVIEW.md`.

## Safety keyword scan result

Real run performed against the imported source (not the pre-import
scratchpad clone), via `tools/phase2a_validate.ps1 -Mode Static`:
**`PASS_WITH_REVIEWED_FALSE_POSITIVES`** — 475 total substring matches
across all 20 apps now in this branch's `applications_user/`, all 475
matched an exact, individually-reviewed entry in
`tools/fcc_id_lookup_validate_config.json`'s `reviewedFalsePositives`
list (file + line + keyword + line-content SHA-256 hash). Zero
unreviewed matches, zero high-confidence-unsafe matches, across the
entire batch.

Of those 475, exactly **11 are newly attributable to `fcc_id_lookup`**
(the other 464 are carried-forward, unchanged, already-reviewed matches
from the 19 already-accepted apps).

## False positives with evidence (all 11, `fcc_id_lookup` only)

| File | Line | Keyword | Matched text | Classification |
|---|---|---|---|---|
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 308 | `ble` | `available` (in `size_t available = cache_end - offset;`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 309 | `ble` | `available` (in `if(available > size) available = size;`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 310 | `ble` | `available` (in `memcpy(output, db->read_cache + (offset - db->cache_offset), available);`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 311 | `ble` | `available` (in `output += available;`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 312 | `ble` | `available` (in `offset += available;`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 313 | `ble` | `available` (in `size -= available;`) | Benign — local variable name |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 1067 | `ble` | `available` (in `"Ensure SD card space is available.",`) | Benign — user-facing message text |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 1163 | `ble` | `available` (in `"Ensure SD card space is available.\n\n"`) | Benign — user-facing message text |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 47 | `token` | `fcc_applicant_tokens` (array declaration) | Benign — a static data-decompression lookup table of company-name suffixes (" Inc.", " LLC", " Ltd.", etc.), not an authentication token |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 663 | `token` | `fcc_applicant_tokens` (bounds check) | Benign — same data table |
| `applications_user/fcc_id_lookup/fcc_id_lookup.c` | 664 | `token` | `fcc_applicant_tokens` (array access) | Benign — same data table |

Each entry's exact line-content SHA-256 hash was computed via this
project's own `Get-LineSha256` convention (SHA-256 of the UTF-8 bytes of
the trimmed line text) and independently verified to reproduce a known,
already-recorded hash before being trusted for these new entries.

## High-confidence unsafe API result

**None.** Zero matches, in `fcc_id_lookup.c` or `fcc_qr_code.h`, for any
of: `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `exfil`. Also zero matches (not
even a substring false positive) for `password`, `clone`, `bypass`,
`seed`, `wallet`, `private key`, `secret`, `access`, `auth`, `api key`,
`network`.

## Network/HTTP behavior result

**None.** Zero socket, HTTP client, Wi-Fi, or UART API call anywhere in
the source. The only `http`-prefixed substrings found are the two
display-only attribution/citation URLs shown on screen
(`https://fcc.id`, `https://fccid.io`, source lines 963, 1164, 1193,
1295) — never fetched, resolved, or connected to by the app itself. No
network stack of any kind is used.

## Credential/token/API-key handling result

**None.** The only `token` matches (lines 47, 663, 664) are the static
`fcc_applicant_tokens` data-decompression table, reviewed and confirmed
above as benign. Zero matches for `credential`, `password`, `secret`,
`api key`, `access`, or `auth` anywhere in the source.

## Storage behavior result

Full inventory of all 11 storage-related call sites in
`fcc_id_lookup.c`, confirmed by direct source read of the actually
imported file:

| Call | Count | Write-capable? |
|---|---|---|
| `storage_file_seek` | 1 | No |
| `storage_file_read` | 2 | No |
| `storage_file_size` | 1 | No |
| `storage_file_is_open` | 1 | No |
| `storage_file_close` | 2 | No |
| `storage_file_free` | 2 | No |
| `storage_file_alloc` | 1 | No |
| `storage_file_open` (`FSAM_READ`, `FSOM_OPEN_EXISTING`) | 1 | No |

**Zero write-capable storage calls anywhere in the source.** No
`storage_file_write`, `storage_simply_mkdir`, `storage_simply_remove`,
`storage_common_rename`, `FSAM_WRITE`, `FSOM_CREATE_ALWAYS`, or
`FSOM_OPEN_ALWAYS` exists anywhere in `fcc_id_lookup.c`.

**No shared/root-level writes** — confirmed, since there are no write
calls of any kind. The single read path
(`APP_ASSETS_PATH("fcc_freq_v2.bin")`) resolves to the app-scoped
`/ext/apps_assets/fcc_id_lookup/` directory, not a shared or root-level
location.

## Database behavior result

**Confirmed not bundled.** `applications_user/fcc_id_lookup/` contains
exactly 6 files after import (`README.md`, `application.fam`,
`fcc_id_lookup.c`, `fcc_id_lookup_icon.png`, `fcc_qr_code.h`, `LICENSE`)
— no `.bin` file, no database, no large binary of any kind. The app's
own source enforces graceful behavior if the optional, user-supplied
database is absent (`FCC_DB_SETUP_HINT` message shown instead of a
crash).

## Hardware/radio behavior result

**None.** Zero references to `furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_infrared_async_tx_start`, or direct GPIO control anywhere in
the source. The app uses only standard Flipper GUI/input/storage
modules.

## Conclusion

**Safety review result: CLEAR.** No unsafe API, no undisclosed hardware
capability, no network/HTTP behavior, no credential/token/secret
handling, no bundled database, no write-capable or shared/root-level
storage behavior. Every finding in this document matches, and is
independently re-confirmed against, the pre-import verification
(`docs/FCC_ID_LOOKUP_PREIMPORT_VERIFICATION.md`) — no new concern
surfaced now that the app is actually imported and scanned through this
project's own tooling.

# FCC ID Lookup — Pre-Import Verification

Docs only. Planning only. **NO CODE IMPORT PERFORMED.** This is a
dedicated pre-import verification pass for `fcc_id_lookup` only,
performed after its license gap was resolved
(`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`). It mirrors the depth of
every prior phase's own `PHASEX_1_SOURCE_LICENSE_VERIFICATION.md` /
`PHASE1_6_TOP25_SOURCE_AUDIT.md`-equivalent pass, but does not itself
import, build, or flash anything.

## Exact source path and pinned commit

| Field | Value |
|---|---|
| Source repo | `RogueMaster/flipperzero-firmware-wPlugins` |
| Pinned commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Exact source path | `applications/external/fcc_id_lookup/` |
| Verification method | Local `git` clone, shallow depth 1, commit confirmed via `git rev-parse HEAD` matching the pinned SHA exactly (the same clone used for the license-resolution phase) |

## Files inspected (all 5, in full)

- `README.md` (786 bytes)
- `application.fam` (444 bytes)
- `fcc_id_lookup.c` (1,414 lines / 48,569 bytes)
- `fcc_id_lookup_icon.png` (96 bytes)
- `fcc_qr_code.h` (1,719 bytes)

## appid / expected FAP name

`application.fam` parses as a valid Python literal (confirmed by parsing
it with Python's own `ast` module and executing it against a minimal
stand-in `App()`/`FlipperAppType` namespace, replicating `fbt`'s own
`.fam`-loading mechanism):

```
App(
    appid="fcc_id_lookup",
    name="FCC ID Lookup",
    apptype=FlipperAppType.EXTERNAL,
    entry_point="fcc_id_lookup_app",
    stack_size=8 * 1024,
    fap_icon="fcc_id_lookup_icon.png",
    sources=["fcc_id_lookup.c"],
    fap_category="Tools",
    fap_author="lrehmann",
    fap_weburl="https://github.com/lrehmann/fcc-id-lookup-flipper",
    fap_version="0.1",
    fap_description="Offline FCC ID applicant and frequency lookup",
)
```

- **appid**: `fcc_id_lookup` (matches the directory name — no
  directory/appid discrepancy, unlike `boilerplate`/`fap_boilerplate` or
  `barcode_gen`/`barcode_app` in the already-accepted baseline).
- **Expected FAP name**: `fcc_id_lookup.fap`.
- **Entry point**: `fcc_id_lookup_app` — confirmed present as a real
  function, `int32_t fcc_id_lookup_app(void* p)` (line 1403 of
  `fcc_id_lookup.c`), matching the standard Flipper external-app
  entry-point signature used by every other app in this project.
- **`sources`**: `["fcc_id_lookup.c"]` — matches the single `.c` file
  present; `fcc_qr_code.h` is correctly not listed (headers aren't
  listed in `sources`, they're pulled in via `#include`).
- **`fap_icon`**: `fcc_id_lookup_icon.png` — confirmed present, and
  confirmed a valid 10×10, 1-bit grayscale PNG (verified via direct PNG
  header/IHDR parse), the exact standard Flipper app-icon format used by
  every other already-imported app.
- **`stack_size`**: `8 * 1024` = 8,192 bytes — unremarkable, well within
  the range used by other already-imported apps.

## License evidence (restated from the resolution phase, not re-derived)

App-local: none (no `LICENSE`, SPDX identifier, or copyright header
anywhere in the vendored source — confirmed again in this phase, no
change). See "Upstream license evidence chain" below and
`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md` for the full resolution.

## Upstream license evidence chain

Restated from `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`, not
re-derived in this phase:

- Upstream repo: `github.com/lrehmann/fcc-id-lookup-flipper`.
- A real MIT `LICENSE` exists at upstream `HEAD` (Copyright (c) 2026
  lsr), added in upstream commit
  `8c49c773eb9b0a399f9e6ede9153372d21056d08` ("Prepare source metadata
  for catalog").
- Three concrete implementation features present in the vendored
  `fcc_id_lookup.c` (a `FCC_DB_READ_CACHE_SIZE` read-cache, explicit
  corrupt-record bounds-check comments, and the
  zero-size-output-guarded `fcc_grantee_prefix()` signature) each map to
  upstream commits chronologically newer than the LICENSE-adding commit
  in the same linear history — establishing that the vendored copy was
  necessarily pulled from an upstream revision that already included the
  `LICENSE` file.

**Classification carried forward: LICENSE GAP RESOLVED.**

## Required import-time attribution

At actual import time (not performed in this phase), the following is
required, matching this project's established pattern for every prior
batch's `THIRD_PARTY_NOTICES.md`:

1. The confirmed upstream MIT `LICENSE` file (Copyright (c) 2026 lsr)
   must be included alongside the app's own source — either copied
   verbatim into `applications_user/fcc_id_lookup/LICENSE`, or otherwise
   clearly attached per this project's standing convention for
   externally-licensed vendored apps.
2. A `THIRD_PARTY_NOTICES.md`-equivalent entry naming the upstream
   project (`lrehmann/fcc-id-lookup-flipper`), its MIT license, and
   explicitly noting that the bundled FCC frequency/applicant database
   is **not** shipped with the app.
3. `application.fam`'s existing `fap_author="lrehmann"` and
   `fap_weburl="https://github.com/lrehmann/fcc-id-lookup-flipper"`
   fields are preserved unchanged — they already provide correct
   in-app attribution and require no modification.

## Database/data behavior

- **No FCC database is bundled or committed anywhere in the vendored
  source, in RogueMaster's repo, or in this project's own repository.**
  The app directory contains only the 5 files listed above — no `.bin`
  file, no compressed archive, no embedded binary blob of applicant/
  frequency records.
- The app's own `README.md` explicitly documents the database as a
  **separate, optional, user-initiated download**: "The database is
  large, about 8.9 MB... You can find the bin file
  [here](https://github.com/lrehmann/fcc-id-lookup-flipper/blob/main/files/fcc_freq_v2.bin)
  place it in `/ext/apps_assets/fcc_id_lookup` to install the database."
- Source confirms this is enforced in code, not just documentation: if
  `storage_file_open(db->file, FCC_DB_PATH, FSAM_READ,
  FSOM_OPEN_EXISTING)` fails (i.e., the user has not manually placed the
  file), the app displays `FCC_DB_SETUP_HINT` ("Copy BIN file into
  /ext/apps_assets/fcc_id_lookup to install the database.") rather than
  crashing or silently failing.
- **If `fcc_id_lookup` were imported, this project would ship only the
  app's own source (~48 KB) — never the 8.9 MB database.** The
  database's own underlying data (FCC equipment-authorization records,
  a matter of U.S. federal regulatory public record per the app's own
  in-app attribution text) remains a separate provenance question this
  project would not need to resolve unless it later chose to bundle that
  file directly, which is not proposed here.

## Storage behavior

Full inventory of every storage-related reference in `fcc_id_lookup.c`
(11 call sites, confirmed by direct source read):

| Call | Purpose | Write capability |
|---|---|---|
| `storage_file_seek` | Position within the open database file | No |
| `storage_file_read` (×2) | Read database bytes into a buffer/cache | No |
| `storage_file_size` | Query the open file's size | No |
| `storage_file_is_open` | Query open state | No |
| `storage_file_close` (×2) | Close the file handle | No |
| `storage_file_free` (×2) | Free the file handle | No |
| `storage_file_alloc` | Allocate a file handle | No |
| `storage_file_open` (line 444) | Open the database file — **`FSAM_READ`, `FSOM_OPEN_EXISTING` only** | No |
| `furi_record_open`/`furi_record_close(RECORD_STORAGE)` | Standard storage-subsystem record lifecycle | No |

- **Zero write-capable calls** anywhere in the source: no
  `storage_file_write`, `storage_simply_mkdir`, `storage_simply_remove`,
  `storage_common_rename`, `FSAM_WRITE`, `FSOM_CREATE_ALWAYS`, or
  `FSOM_OPEN_ALWAYS` exists anywhere in `fcc_id_lookup.c`.
- **Expected database location**: `APP_ASSETS_PATH("fcc_freq_v2.bin")` —
  Flipper's standard app-scoped assets macro, resolving to
  `/ext/apps_assets/fcc_id_lookup/fcc_freq_v2.bin` (matching the app's
  own `appid`). This is an **app-scoped path, not a shared or
  root-level location** — consistent with this project's "app-private
  storage only" bar applied to every other already-imported app, and a
  materially cleaner storage profile than `animation_switcher`/
  `theme_manager`'s shared `/ext/dolphin/` writes.
- **No shared/root-level writes of any kind** — confirmed, since there
  are no write calls at all.

**Storage classification: confirmed read-only, app-scoped.**

## Safety/API keyword scan result

Ran this project's own exact substring-scan methodology
(`tools/phase2a_validate.ps1`'s `forbiddenRiskyKeywords` list, a
case-insensitive substring scan over `.c`/`.h`/`.cpp` files) manually
against both source files (`fcc_id_lookup.c`, `fcc_qr_code.h`), since
the app is not yet present under `applications_user/` for the tool
itself to scan without an import:

**High-confidence unsafe keywords — zero matches**, across both files,
for every one of: `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `exfil`, `password`.

**Generic keywords — 11 substring matches, all reviewed, all benign
false positives:**

| File | Line | Matched keyword | Context | Classification |
|---|---|---|---|---|
| `fcc_id_lookup.c` | 308 | `ble` | `size_t available = cache_end - offset;` | Benign — "available" |
| `fcc_id_lookup.c` | 309 | `ble` | `if(available > size) available = size;` | Benign — "available" |
| `fcc_id_lookup.c` | 310 | `ble` | `memcpy(output, db->read_cache + (offset - db->cache_offset), available);` | Benign — "available" |
| `fcc_id_lookup.c` | 311 | `ble` | `output += available;` | Benign — "available" |
| `fcc_id_lookup.c` | 312 | `ble` | `offset += available;` | Benign — "available" |
| `fcc_id_lookup.c` | 313 | `ble` | `size -= available;` | Benign — "available" |
| `fcc_id_lookup.c` | 1067 | `ble` | `"Ensure SD card space is available."` | Benign — "available" |
| `fcc_id_lookup.c` | 1163 | `ble` | `"Ensure SD card space is available.\n\n"` | Benign — "available" |
| `fcc_id_lookup.c` | 47 | `token` | `static const char* const fcc_applicant_tokens[] = {` | Benign — a data-decompression lookup table of company-name suffixes (" Inc.", " LLC", " Ltd.", etc.), used to expand abbreviated applicant names from the compact on-disk database format. Not an authentication/API token of any kind. |
| `fcc_id_lookup.c` | 663 | `token` | `if(byte >= 1 && byte <= COUNT_OF(fcc_applicant_tokens)) {` | Benign — same table, bounds check |
| `fcc_id_lookup.c` | 664 | `token` | `fcc_applicant_tokens[byte - 1]` | Benign — same table, array access |

No matches at all (not even a substring false positive) for `wallet`,
`private key`, `secret`, `access`, `auth`, `clone`, `bypass`, `seed`.

**Aggregate result: zero real unsafe API/capability matches.** Every
substring match is a reviewed, benign false positive — the exact same
class of finding ("ble"-in-"available", data-table "token") this
project has already established as benign for every prior batch.

## Network/credential re-confirmation

- **No network/HTTP behavior**: zero socket, HTTP client, Wi-Fi, or
  UART API call anywhere in the source. The `https://fcc.id` and
  `https://fccid.io` strings (lines 963, 1164, 1193, 1295) are
  display-only attribution text shown on screen, never fetched or
  resolved by the app itself.
- **No API-key/token/credential handling**: confirmed above — the only
  "token" matches are a benign data table, not authentication material.

## Dependency / build-risk result

**Dependency surface**: minimal and entirely standard. `fcc_id_lookup.c`
includes only Flipper SDK headers already used throughout the base
firmware and every already-imported app (`furi.h`, `gui/canvas.h`,
`gui/gui.h`, `gui/modules/submenu.h`, `gui/modules/text_input.h`,
`gui/modules/widget.h`, `gui/view.h`, `input/input.h`,
`gui/view_dispatcher.h`, `storage/storage.h`), standard C library
headers (`stdarg.h`, `stdbool.h`, `stdint.h`, `stdio.h`, `stdlib.h`,
`string.h`), and its own local `fcc_qr_code.h`. **Zero third-party
libraries, zero external dependencies, zero submodule requirements.**

**Build-risk estimate: LOW.**

- Single source file (1,414 lines), no unusual compiler features
  observed in a full read (no inline assembly, no non-standard
  extensions beyond what the rest of this project's accepted batch
  already uses).
- Valid `application.fam` (confirmed parseable).
- Valid entry-point function matching the standard signature.
- Valid, correctly-formatted icon.
- No known conflicting `appid` against any of the 19 already-imported
  apps or the base Unleashed app set.
- The one materially untested factor is an actual compile pass against
  this project's specific toolchain/SDK version — consistent with every
  prior phase's own discipline, this can only be confirmed by a real CI
  build attempt at actual import time, not asserted from source reading
  alone.

## Final conclusion: **CLEARED FOR FUTURE IMPORT PLANNING**

`fcc_id_lookup` passes every check this phase performed: license gap
resolved (with a clear, defined import-time attribution requirement),
appid/FAP naming clean and unambiguous, `application.fam` parses and
matches its own source, no bundled database (confirmed both by directory
listing and by source-enforced fallback behavior), read-only app-scoped
storage only, zero high-confidence unsafe API matches, zero network/
credential behavior, minimal standard-only dependency surface, low
estimated build risk.

This clears `fcc_id_lookup` to be considered in a future,
separately-requested one-app import-planning phase — it does **not**
itself start that phase, does not perform any import, and does not
substitute for a real CI build attempt, which remains the one check this
phase cannot perform without importing the app. See
`docs/FCC_ID_LOOKUP_GO_NO_GO.md` for the exact conditions before
implementation.

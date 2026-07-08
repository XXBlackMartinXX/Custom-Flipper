# Phase 2D.2 — Safety Review

Docs only. Real static safety/API-capability scan of the actually-imported
files for `resistors`, `crypto_dictionary`, and `2048`, run both locally
(`pwsh` + `tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2d_validate_config.json`) and in real CI, against all 22
required keywords (the original 18 plus `seed`/`wallet`/`private key`/
`secret`).

## A correction to Phase 2D.1: `resistors` did have benign substring hits

`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` stated, for `resistors`:
"**Zero real matches, and zero raw substring matches at all** —... this
codebase does not even contain any of the common false-positive trigger
words (no `double`, `table`, `enabled`, `variable`, etc...)."

**This was too strong, and incorrect.** When building
`tools/phase2d_validate_config.json`'s `reviewedFalsePositives` entries
at actual import time, a direct re-scan of the imported
`resistors/src/resistor_logic.c` and `resistor_logic.h` found **6 real
substring matches**, all the same benign `ble`-inside-`double` class
already established for other apps in this project (`chess`,
`flipper95`):

| File | Line | Matched word |
|---|---|---|
| `applications_user/resistors/src/resistor_logic.c` | 90 | `double` (in `double get_resistance_decimal(...)`) |
| `applications_user/resistors/src/resistor_logic.c` | 115 | `double` (in `double decode_resistance_number(...)`) |
| `applications_user/resistors/src/resistor_logic.c` | 118 | `double` (in `double decimal = get_resistance_decimal(...)`) |
| `applications_user/resistors/src/resistor_logic.c` | 129 | `double` (in `char* calculate_decimal_places(double value)`) |
| `applications_user/resistors/src/resistor_logic.c` | 147 | `double` (in `double value = decode_resistance_number(...)`) |
| `applications_user/resistors/src/resistor_logic.h` | 33 | `double` (in `extern double resistor_multiplier;`) |

All 6 are the standard C `double` floating-point type keyword, used
throughout `resistor_logic.c`/`.h` for resistance/tolerance arithmetic —
not the Bluetooth LE API, and not a capability of any kind. These are
exactly the same class of finding already documented and accepted for
`chess`, `flipper95`, `programmer_calc`, and now `2048` in this project's
own validator configs.

**Why the Phase 2D.1 statement was wrong**: that phase's own combined
keyword scan (covering all 3 apps at once) *did* actually surface these 5
of the 6 matches in its raw output (line 118 was missed even there), but
the phase's written conclusion for `resistors` incorrectly summarized the
result as "zero... at all," most likely because a later, narrower
`furi_hal`-only grep (which genuinely did return zero matches) was
conflated with the full-keyword scan's result when writing the prose.
This is a documentation-accuracy error, not a safety finding — the
matches themselves were always benign, and this correction does not
change `resistors`'s clearance or the app's safety classification. It is
recorded here because this project's own discipline (established by the
`sd_info` and `fcc_id_lookup` corrections in Phase 2C.1) is to name and
fix a citation error honestly rather than let an inaccurate summary stand
uncorrected once a fresh scan reveals it.

All 6 matches (plus one more found during config-building for line 118)
are now recorded as individually-reviewed `reviewedFalsePositives` entries
in `tools/phase2d_validate_config.json`, each keyed to the exact file,
line number, keyword, and a SHA-256 hash of the exact trimmed line text —
the same auditable mechanism used throughout this project.

## Per-app keyword scan result (all 22 required keywords)

### `resistors`

- **Matches**: 6, all `double`-substring (see table above). Zero matches
  for any other keyword (no `furi_hal_*`, `badusb`, `deauth`, `jam`,
  `brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`,
  `seed`, `wallet`, `private key`, `secret`).
- **Classification**: benign false positive (all 6).
- **furi_hal usage**: zero, confirmed by a dedicated grep across all of
  `src/`.

### `crypto_dictionary`

- **Matches**: zero in any `.c`/`.h`/`.txt` file that is part of the
  actual scan scope (`riskyKeywordScanFileExtensions`: `.c`, `.h`,
  `.cpp`). The `LICENSE` file (GPLv3 boilerplate) contains several
  `ble`-substring hits inside ordinary English words ("available,"
  "reasonable," "responsible," "applicable," "password" — the last one
  from the phrase "special password or key for unpacking," standard GPLv3
  license text, not app behavior) — but `LICENSE` is outside the scan's
  file-extension scope by design (the scan targets source code, not
  license/documentation prose), so these produce no findings requiring
  review.
- **Content-only glossary/reference hits**: none of the 22 keywords
  (including this phase's new `seed`/`wallet`/`private key`/`secret`)
  appear anywhere in the 14 bundled glossary `.txt` files. Those files
  discuss only public cipher specifications (key size, block size,
  rounds, structure) — the special-caution "content-only glossary/
  reference hit" category this phase introduced was anticipated but not
  actually needed for this app; the content is cleaner than expected.
- **Classification**: clean — no matches to classify at all.
- **furi_hal usage**: zero.
- **Special-caution confirmation**: directly confirmed (`app/app.c`,
  `resource/resource.c`, `scenes/scenes.c`) that the app opens its own
  bundled glossary files with `FSAM_READ`/`FSOM_OPEN_EXISTING` only (no
  `FSAM_WRITE`/`FSOM_CREATE*` call exists anywhere in the source),
  performs no cryptographic operations on any data, and has no text-input
  field or any other path by which user-supplied data could enter the
  app. It does not request, store, generate, transform, or display any
  user credential, wallet key, token, seed phrase, password, or secret.

### `2048`

- **Matches**: several, all the same `ble`-inside-`table`/`is_table_updated`
  class already established in `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`
  (this app names its game-board array `table`). All confirmed benign and
  recorded as individually-reviewed entries in
  `tools/phase2d_validate_config.json`.
- **Classification**: benign false positive (all).
- **furi_hal usage**: zero, confirmed by a dedicated grep across
  `game_2048.c`, `array_utils.c`, `array_utils.h`, `digits.h`. One
  `dolphin_deed(DolphinDeedPluginGameStart)` call — Flipper's own
  standard built-in gamification/XP API, not a hardware or safety concern.

## High-confidence unsafe keyword result

**Zero matches, unreviewed or otherwise**, against any of the 15
high-confidence unsafe keywords (`furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`deauth`, `jam`, `brute`, `credential`, `token`, `exfil`) across all 3
apps. This is a hard-FAIL condition if triggered and unreviewed; it did
not trigger for any of the 3 apps in this batch.

## Storage/hardware behavior (directly confirmed, matching Phase 2D.1)

- **`resistors`**: **zero storage API usage** — no `storage_`,
  `file_stream`, `RECORD_STORAGE`, `FSAM_`, or `FSOM_` reference anywhere
  in `src/`. Zero `furi_hal` usage of any kind.
- **`crypto_dictionary`**: **read-only only** — opens its own bundled
  glossary files via `FSAM_READ`/`FSOM_OPEN_EXISTING`; no write call
  anywhere. Zero `furi_hal` usage.
- **`2048`**: writes to `/ext/apps_data/game_2048/game_2048.save` via a
  hardcoded `EXT_PATH("apps_data/game_2048")` literal (not the
  appid-based `APP_DATA_PATH` macro `chess`/`sudoku` use) — functionally
  app-scoped and non-colliding either way. Also performs a one-time
  legacy-path migration check against `/ext/apps/Games/game_2048.save`
  on load, silently a no-op on this fresh import (no such file exists).
  No write to any shared or root-level location. Zero `furi_hal` usage.

## Conclusion

**No real unsafe/capability use found in any of the 3 apps.** All
substring matches across all 3 apps are confirmed benign and individually
reviewed with exact evidence in `tools/phase2d_validate_config.json`.
Storage behavior for all 3 apps is directly confirmed (not assumed) and
matches the Phase 2D.1 findings, with the `resistors` documentation
correction noted above. This safety review does not itself constitute a
build/release acceptance — see `docs/PHASE2D_2_BUILD_REPORT.md` and
`docs/PHASE2D_2_GO_NO_GO.md`.

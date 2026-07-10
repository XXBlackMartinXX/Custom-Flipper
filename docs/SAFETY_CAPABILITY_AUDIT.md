# Safety / Capability Audit — Full 20-App Consolidation

Docs-only. Consolidates the static safety/API-capability scan results
across all 7 accepted milestones (Phase 2A–2F, `fcc_id_lookup`), drawn
from each phase's own `SAFETY_REVIEW.md` document. **This is a source
code and CI-level static analysis audit only — no hardware testing has
been performed at any point in this project.**

## High-confidence unsafe API result

**Zero matches, in every phase, with no exception.** The 15-keyword
high-confidence-unsafe list (`furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`,
`furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `exfil`, plus the base RF/hardware set) returned zero
matches against every one of the 20 apps, confirmed independently in
each phase's own safety review:

| Phase | Apps scanned | High-confidence unsafe matches |
|---|---|---|
| 2A | network_subnet, programmer_calc, vin_decoder, flipper95, chess | 0 |
| 2B | flipfetch, quadratic_solver, sudoku | 0 |
| 2C | sd_info, docviewlite | 0 |
| 2D | resistors, crypto_dictionary, 2048 | 0 |
| 2E | image_viewer, boilerplate, minesweeper | 0 |
| 2F | qrcode, hex_viewer, barcode_gen | 0 |
| fcc_id_lookup | fcc_id_lookup | 0 |

No app in the project's history has ever triggered a stop, DEFER, or
FAILED safety classification.

## Reviewed false positives summary

Every substring match against the safety keyword list was individually
reviewed (file, line, keyword, and a SHA-256 hash of the trimmed line
text, recorded in each phase's `tools/phaseX_validate_config.json`).
Running cumulative totals as stated in each phase's own document:

| Phase | New matches this phase | Cumulative total | Classification |
|---|---|---|---|
| 2A | (pre-dates the full keyword-count methodology; combined hardware-API grep only, zero matches) | — | Clean |
| 2B | 6 | 6 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| 2C | 29 | ~35 (2B+2C cumulative, per 2C doc) | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| 2D | ~154 (resistors ~6, 2048 several, crypto_dictionary 0) | 189 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| 2E | 184 | 373 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| 2F | 91 (qrcode 8, hex_viewer 37, barcode_gen 46) | 464 | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |
| fcc_id_lookup | 11 | **475** | `PASS_WITH_REVIEWED_FALSE_POSITIVES` |

**Zero unreviewed matches at any point.** Every one of the 475 final
cumulative matches is individually accounted for.

Representative examples, quoted from the source reviews:

- `docviewlite`/`sd_info`/`fcc_id_lookup` — the keyword `ble` matching
  inside the word `available` (e.g. `size_t available = cache_end -
  offset;`) — a local variable name, not a Bluetooth LE API reference.
- `quadratic_solver`/`sudoku`/`image_viewer`/`boilerplate`/`minesweeper`
  — `ble` matching inside `enabled` (`view_port_enabled_set(...)`, a
  standard GUI API call) or `variable`/`VariableItem` (the settings-list
  GUI widget).
- `resistors`/`crypto_dictionary` (via its `LICENSE` file, outside scan
  scope) — the C keyword `double`, or GPLv3 boilerplate text containing
  the word "password" in a standard license clause.
- `fcc_id_lookup` — `token` matching `fcc_applicant_tokens`, a static
  data-decompression lookup table of company-name suffixes (" Inc.",
  " LLC", " Ltd."), not an authentication token.
- `barcode_gen` — `Table` matching inside `EncodingTable`/
  `MissingEncodingTable` (the app's own error-classification enum, not
  the Bluetooth LE API), plus 2 real `auth` substring hits confirmed as
  `@author`/`author:` attribution comments only.

**One documentation-accuracy correction, not a safety finding**: Phase
2D.1 had incorrectly claimed `resistors` had zero substring matches at
all; Phase 2D.2's re-scan found 6 real `double`-keyword matches, all
benign. The underlying code was never unsafe — only the earlier claim
of "zero matches" was wrong, and it was self-corrected before
finalization.

## Per-app safety status

All 20 apps: **CLEAR.** See `docs/CUSTOM_APP_INVENTORY.md` for the
per-app safety-notes column. No app carries an open or unresolved
safety finding.

## RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR status

**Zero real hardware-capability API usage across all 20 apps, in every
phase, with no exception.** No app references `furi_hal_subghz`,
`furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_infrared_async_tx_start`, `furi_hal_gpio_write`,
`furi_hal_hid`, `furi_hal_usb_hid`, or any BadUSB/deauth/jam capability
anywhere in its source. The only hardware-adjacent APIs found anywhere
in the project are `furi_hal_speaker_*` (audio) and
`notification_message()` (haptic/LED), used by `boilerplate`,
`minesweeper`, and `hex_viewer` for standard user-feedback purposes —
explicitly confirmed as not safety-exclusion-list capabilities in each
respective review. `vin_decoder` (a vehicle-data tool) was specifically
re-confirmed to have zero GPIO/CAN/vehicle-hardware API usage despite
its subject matter.

## Credential/token/password/seed/private-key/wallet status

**Zero real matches in any phase — only reviewed benign false
positives.** No app handles credentials, tokens, passwords, seed
phrases, private keys, wallets, or secrets in the safety-exclusion-list
sense. The only near-misses are the `available`/`enabled`/`token`-table
substring matches documented above. `crypto_dictionary` (a cipher-name
glossary) was specifically confirmed to contain none of the scanned
keywords in its own bundled data files.

## Network/API-key status

**Zero real network calls anywhere in the project.** Only two documents
address this as a dedicated topic: Phase 2A ("No networking APIs
referenced by any of the 5") and `fcc_id_lookup`'s review ("Zero
socket, HTTP client, Wi-Fi, or UART API call anywhere in the source").
The only URLs found in any app's UI text are `fcc_id_lookup`'s
`https://fcc.id` and `https://fccid.io` citation links, shown on-screen
for attribution only and never fetched, resolved, or connected to by
the app itself. No other app in the project contains any URL or
network-related string.

## Storage safety status

Write-capable storage calls were found in 6 of the 20 apps, all
confirmed app-private (`/ext/apps_data/<app>/`) except one:

| App | Write location | App-private? |
|---|---|---|
| `chess` | `/ext/apps_data/flipchess/board_fen.txt` | Yes |
| `sudoku` | `/ext/apps_data/sudoku/save.dat` | Yes |
| `sd_info` | `/ext/sdtest.tmp*` (SD-card root) | **No** — but transient, user-initiated, self-cleaning (see below) |
| `2048` | `/ext/apps_data/game_2048/game_2048.save` | Yes (hardcoded literal, functionally app-scoped) |
| `boilerplate` | `/ext/apps_data/boilerplate/boilerplate.conf` | Yes |
| `minesweeper` | `/ext/apps_data/mine_sweeper_redux/` (atomic write) | Yes |
| `qrcode` | Legacy-folder migration (bounded, self-cleaning, then removed) | Yes (app path), transitional read of an old shared path |
| `barcode_gen` | `/ext/apps_data/barcodes/` | Yes |

**`sd_info` is the one app in the project whose write target is not
app-scoped** — its 48-block SD-speed-test writes land at the SD-card
root (`/ext/sdtest.tmp*`), not under `/ext/apps_data/sd_info/`. This was
explicitly reviewed and accepted as safe because: each block file is
deleted immediately after its own read-back verification (not
persistent), the test only runs on explicit user action (not
automatic), and no shared configuration file is touched. It is a
disclosed-and-accepted item, not a false positive and not a code
change — full detail in `docs/STORAGE_AND_DATA_BEHAVIOR_AUDIT.md`.

The remaining 14 apps perform no storage writes at all (read-only or no
storage API usage).

## Hardware/radio behavior status

**None, project-wide.** See the RF/Sub-GHz/NFC/RFID/iButton/BadUSB/
BLE/GPIO/IR section above — this holds identically for all 20 apps.

## Remaining limitations

- **This is a static source-code and CI-level analysis only.** No phase
  has ever claimed hardware-flashed or on-device behavioral testing.
- **No physical Flipper Zero and no Windows machine exist in this
  project's environment** — hardware-assisted validation has never
  progressed past preflight/report-only/detect-device checks.
- **`docs/KNOWN_ISSUES.md` on the documentation branch is not fully
  current with this integration branch** — as of this audit, that file
  still describes `fcc_id_lookup` as "not yet imported," while the
  integration branch has it imported and baseline-finalized. This is a
  documentation-currency gap between the two branches, not an
  unresolved safety concern. See
  `docs/REMAINING_GAPS_AND_NEXT_ACTIONS.md`.

## Final conclusion

- **No hardware testing has been performed at any point in this
  project.**
- **No release-ready claim is made by this or any prior audit.**
  Release status remains **TEST-READY ONLY / NOT RELEASE-READY**.
- **This safety review is source/CI-based only** — every finding above
  reflects static keyword scanning, direct source inspection, and real
  GitHub Actions CI build results on `windows-latest` runners. It does
  not, and cannot, substitute for on-device behavioral verification.

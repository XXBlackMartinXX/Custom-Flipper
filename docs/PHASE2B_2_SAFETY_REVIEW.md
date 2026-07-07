# Phase 2B.2 — Safety Review

Docs only. Records the real, per-app safety/capability scan run against
the actual imported source in `applications_user/flipfetch/`,
`applications_user/quadratic_solver/`, and `applications_user/sudoku/` —
re-run against the files as committed to this repository, not merely
carried forward from Phase 2B.1's pre-import copy (though the content is
byte-for-byte identical, confirmed by matching `LICENSE` SHA-256 hashes).

## Scan method

Full 19-keyword case-insensitive substring scan (`furi_hal_subghz`,
`furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`,
`furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `ble`, `deauth`, `jam`,
`brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`)
against every `.c`/`.h`/`.fam` file in each app's imported directory,
run directly with `grep -inE` against the real, committed files in this
repository.

## `flipfetch`

- **Files scanned**: `flipfetch.c`, `application.fam`
- **Real unsafe/capability matches**: **Zero.** No match for any of the
  19 keywords, including `ble`.
- **Benign false positives**: None.
- **Needs review**: None.
- **Storage behavior**: One read-only call,
  `storage_common_fs_info(storage, STORAGE_EXT_PATH_PREFIX, &total,
  &free_space)`, to display free SD space in the info screen. No file is
  opened, created, or written.
- **Hardware/radio behavior**: None. Includes are `furi.h`, `gui/gui.h`,
  `furi_hal.h`, `furi_hal_power.h`, `storage/storage.h`, `string.h`,
  `stdio.h` — reads firmware version, battery percent/voltage/charging
  state, uptime, and free heap via ordinary `furi_hal_power_*`/
  `furi_hal_version_*` read APIs. No Sub-GHz, NFC, RFID, iButton, BLE,
  GPIO, Infrared, or USB HID API is referenced anywhere.
- **Conclusion**: Clean.

## `quadratic_solver`

- **Files scanned**: `app.c`, `application.fam`
- **Real unsafe/capability matches**: **Zero.**
- **Benign false positives**: **5**, all the `ble` keyword matching
  inside unrelated words:

  | Line | Text | Matched word |
  |---|---|---|
  | 36 | `snprintf(buf, size, "%s = %.5f", label, (double)rounded);` | `double` |
  | 77 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->a);` | `double` |
  | 81 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->b);` | `double` |
  | 85 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->c);` | `double` |
  | 218 | `view_port_enabled_set(app->view_port, false);` | `enabled` |

  Each is recorded in `tools/phase2b_validate_config.json`'s
  `reviewedFalsePositives` with the exact file path, line number, keyword,
  and a SHA-256 hash of the trimmed line text (computed with the
  validator's own `Get-LineSha256` function against the real, committed
  file — not approximated). None reference the Bluetooth LE API in any
  way; `app.c` includes no BLE-related header at all.
- **Needs review**: None.
- **Storage behavior**: **None.** No `storage/storage.h` include, no
  storage API call anywhere in the file.
- **Hardware/radio behavior**: None. Includes are `furi.h`, `gui/gui.h`,
  `input/input.h`, `stdlib.h`, `string.h`, `stdio.h`, `math.h` — pure
  arithmetic (quadratic formula) plus GUI drawing and D-pad input
  handling.
- **Conclusion**: Clean.

## `sudoku`

- **Files scanned**: `sudoku.c`, `application.fam`
- **Real unsafe/capability matches**: **Zero.**
- **Benign false positives**: **1**:

  | Line | Text | Matched word |
  |---|---|---|
  | 674 | `view_port_enabled_set(view_port, false);` | `enabled` |

  Recorded in `tools/phase2b_validate_config.json`'s
  `reviewedFalsePositives` the same way as `quadratic_solver`'s above.
- **Needs review**: None.
- **Storage behavior**: **Real, app-private save/load** — lines 101–131
  use `storage_file_open`/`storage_file_read`/`storage_file_write`/
  `storage_simply_remove` against `SAVE_FILE`, defined as
  `APP_DATA_PATH("save.dat")`. Traced through the real Flipper storage
  source (`storage.h`: `APP_DATA_PATH(path)` expands to
  `"/data/" path`; `storage_processing.c`: the storage service resolves
  the virtual `/data` prefix to `/ext/apps_data/<appid>` at runtime,
  using the launched thread's own registered appid) — for `sudoku`, whose
  `application.fam` declares `appid="sudoku"`, this resolves to
  `/ext/apps_data/sudoku/save.dat`. This is the same app-private storage
  pattern already accepted for `chess` in Phase 2A (`/ext/apps_data/
  flipchess/`), not a shared-directory write like
  `animation_switcher`/`theme_manager` (both still excluded from this
  batch). Not confirmed by an actual device/SD-card observation — that
  remains a hardware-smoke-test-checklist item, per the same standing
  discipline applied to every other app's private-storage claim in this
  project.
- **Hardware/radio behavior**: None beyond storage. Includes are
  `stdio.h`, `furi.h`, `furi_hal.h`, `dolphin/dolphin.h`, `gui/gui.h`,
  `input/input.h`, `notification/notification_messages.h`,
  `storage/storage.h`. `dolphin_deed(DolphinDeedPluginGameStart)` and
  `dolphin_deed(DolphinDeedPluginGameWin)` are standard Dolphin XP/
  achievement-tracking calls used throughout the existing Flipper app
  ecosystem — not a capability concern.
- **Conclusion**: Clean; one real, confirmed app-private storage path.

## High-confidence unsafe API result (all 3 apps combined)

**Zero matches**, across all 15 `highConfidenceUnsafeKeywords`
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`) in any of the 3 newly-imported apps' source
or manifest files. No app in this batch required a stop, a DEFER, or a
FAILED classification.

## Storage behavior summary

| App | Writes storage | App-private only |
|---|---|---|
| `flipfetch` | No (read-only free-space query) | N/A |
| `quadratic_solver` | No | N/A |
| `sudoku` | Yes | Yes — `/ext/apps_data/sudoku/` (source-derived, not hardware-confirmed) |

## Hardware/radio behavior summary

None of the 3 apps reference Sub-GHz, NFC, RFID, iButton, BadUSB, BLE,
GPIO write, or Infrared transmit APIs anywhere in their source. No RF,
wireless, or GPIO-control behavior of any kind was added to this
firmware by this batch.

## Conclusion

**All 3 apps are safe per this scan: zero real unsafe-capability matches,
all `ble`-substring hits accounted for as benign, one confirmed
app-private storage path (`sudoku`), zero hardware/radio behavior.** This
scan does not, and cannot, substitute for actual GUI-level or hardware
observation — see `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` for what
still requires a human on real hardware, unperformed as of this phase.

# Phase 2C.2 — Safety Review

Docs only. Real static scan of the actual imported source, performed
immediately after each app was copied into `applications_user/` and again
against the combined 10-app batch via
`tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2c_validate_config.json`, run for real in this session.

## Scope

Exactly the 2 apps imported in this phase: `sd_info`, `docviewlite`.
`fcc_id_lookup` and every hard-excluded app (`upython`, `iconedit`,
`c_book`, `animation_switcher`, `theme_manager`) were not touched.

## Unsafe-keyword scan (18 required keywords, both apps)

`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `ble`, `deauth`, `jam`,
`brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`.

### `sd_info` (`applications_user/sd_info/main.c`, 498 lines)

**Zero real unsafe/capability matches.** 4 substring hits, all classified
as benign false positives:

| Line | Matched text | Keyword | Classification | Evidence |
|---|---|---|---|---|
| 121 | `double size = bytes;` | `ble` | Benign false positive | `"ble"` is a substring of `"double"` |
| 163 | `(double)results->read_speed,` | `ble` | Benign false positive | `"ble"` is a substring of `"double"` |
| 164 | `(double)results->write_speed);` | `ble` | Benign false positive | `"ble"` is a substring of `"double"` |
| 489 | `view_port_enabled_set(app->view_port, false);` | `ble` | Benign false positive | `"ble"` is a substring of `"enabled"` |

No `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `password`, `token`, `exfil`, `clone`, or `bypass` reference
anywhere in the file.

### `docviewlite` (`applications_user/docviewlite/docviewlite.c`, 984 lines)

**Zero real unsafe/capability matches.** 25 substring hits, all
classified as benign false positives (all `ble`-inside-an-ordinary-word,
the same class established throughout Phase 2A/2B):

| Line | Matched word | Keyword | Classification |
|---|---|---|---|
| 9 | `variable_item_list` (header include) | `ble` | Benign false positive |
| 22 | `available` (comment) | `ble` | Benign false positive |
| 58 | `enabled` (comment) | `ble` | Benign false positive |
| 73 | `scrolling` (comment) | `ble` | Benign false positive |
| 86 | `VariableItemList` | `ble` | Benign false positive |
| 660, 688, 813 | `VariableItem` | `ble` | Benign false positive |
| 661, 689 | `variable_item_get_context` | `ble` | Benign false positive |
| 667, 695 | `variable_item_get_current_value_index` | `ble` | Benign false positive |
| 668, 820, 831 | `variable_item_set_current_value_text` | `ble` | Benign false positive |
| 696 | `variable_item_set_current_value_text` | `ble` | Benign false positive |
| 757, 799 | `scrolling` (comment) | `ble` | Benign false positive |
| 810 | `variable_item_list_alloc` | `ble` | Benign false positive |
| 819 | `variable_item_set_current_value_index` | `ble` | Benign false positive |
| 824 | `variable_item_list_add` | `ble` | Benign false positive |
| 830 | `variable_item_set_current_value_index` | `ble` | Benign false positive |
| 835, 839 | `variable_item_list_get_view` | `ble` | Benign false positive |
| 916 | `variable_item_list_free` | `ble` | Benign false positive |

No `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `password`, `token`, `exfil`, `clone`, or `bypass` reference
anywhere in the file.

## High-confidence unsafe API result

**Zero matches against any `highConfidenceUnsafeKeywords` entry
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`) in either app.** No hard-FAIL condition was
triggered by this batch. Per the task's own stop instruction ("if any real
unsafe/capability use appears, stop immediately, do not continue the
batch, mark app DEFER/FAILED") — this instruction was not invoked because
no real unsafe/capability use was found in either app, confirmed by direct
source read, not inferred from Phase 2C.1's citation alone.

## Storage behavior

### `sd_info`

**Real, but controlled and non-persistent.** Confirmed by direct source
read (`main.c` lines ~283–360): the app's SD-card speed test — triggered
only by an explicit user action ("Press OK to start test", gated by the
`is_testing` state flag) — performs 48 write/read/verify/delete cycles of
32KB blocks at `/ext/sdtest.tmp*` (SD-card root, defined by
`#define TEST_FILE_PATH "/ext/sdtest.tmp"`). Each block file is created,
written, read back, verified, and removed (`storage_simply_remove()`)
within the same loop iteration — nothing persists across a normal test
run. This is:

- **Not app-private** — `/ext/sdtest.tmp*` is at the SD-card root, not
  under `/ext/apps_data/sd_info/`.
- **Not persistent** — every test file is deleted immediately after its
  own read-back check.
- **Not automatic** — only runs when the user explicitly starts the test
  from the app's own UI; never on launch, in the background, or without
  interaction.
- **Not a shared-config modification** — unlike `animation_switcher`/
  `theme_manager`'s `/ext/dolphin/manifest.txt` writes, this touches no
  firmware-shared configuration or state; it is a disposable, self-named
  temp file, gone by the time the test completes.

**No app-private write is required or performed** — the app has no
save/config file of its own; the SD-card info display itself
(`storage_common_fs_info`) is read-only.

### `docviewlite`

**Confirmed read-only.** `storage_file_open(file, file_path, FSAM_READ,
FSOM_OPEN_EXISTING)` followed by `storage_file_read()` (lines ~279, ~298)
— `file_path` comes from the standard Flipper file-browser dialog
(`dialogs/dialogs.h`), i.e. a user-selected `.txt` file. **No write call
of any kind exists anywhere in the 984-line source.** No app-private
storage, no shared-config modification, no persistent state of any kind.

## Hardware/radio behavior

**Zero, in both apps.** No Sub-GHz, NFC/RFID/iButton, GPIO write,
Infrared transmit, BLE, or USB/HID capability of any kind — confirmed by
the full keyword scan above finding no real match against any of those
API classes in either app's actual source.

## Conclusion

**Both `sd_info` and `docviewlite` pass this phase's safety review.**
Neither app was found to touch any capability on this project's
safety-exclusion list (RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR),
neither contains credential/token/password/exfiltration/clone/bypass
behavior, and neither required a stop-and-defer decision. `sd_info`'s
real, corrected storage-risk profile (transient, self-cleaning,
user-initiated SD-root benchmark writes) is documented explicitly, not
smoothed over, consistent with the Phase 2C.1 finding that first surfaced
it.

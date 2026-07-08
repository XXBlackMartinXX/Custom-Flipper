# Phase 2E.2 — Safety Review

Docs only. Real static safety/API-capability scan of the actually-imported
files for `image_viewer`, `boilerplate`, and `minesweeper`, run both
locally (`pwsh` + `tools/phase2a_validate.ps1 -Mode Static -ConfigPath
tools/phase2e_validate_config.json`) and in real CI (run `28966234832`),
against all 17 keywords this phase's task specification named (the same
`furi_hal_*`/`badusb`/`ble`/`deauth`/`jam`/`brute`/`credential`/
`password`/`token`/`exfil`/`clone`/`bypass`/`seed`/`wallet`/`private key`/
`secret` set every prior phase has used).

## Per-app unsafe keyword scan

### `image_viewer`

Scanned: `main.cpp` (the only source file, 120 lines, read in full).

**1 substring match** — `ble`, on line 106:

| File | Line | Matched word | Classification |
|---|---|---|---|
| `applications_user/image_viewer/main.cpp` | 106 | `view_port_enabled_set` (call to the standard Flipper GUI API `view_port_enabled_set`) | **Benign false positive** — the substring `ble` occurs inside the word `enabled`, part of a standard GUI API name, not the Bluetooth LE API. |

**High-confidence unsafe API result**: none. Zero matches for any of
`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `deauth`, `jam`, `brute`,
`credential`, `token`, `exfil`, `clone`, `bypass`, `seed`, `wallet`,
`private key`, `secret`.

### `boilerplate`

Scanned: all `.c`/`.h` files under `helpers/`, `scenes/`, `views/`, plus
`boilerplate.c`/`boilerplate.h` (29 files total).

**Substring matches**: all `ble`, all inside the words `variable`
(`VariableItem`/`variable_item_*` — the standard Flipper GUI settings-list
API) and `enabled` (haptic/speaker/LED/save-settings toggle state).
Representative sample (full detail in the reviewed-false-positive entries
in `tools/phase2e_validate_config.json`):

| File | Line | Matched word | Classification |
|---|---|---|---|
| `applications_user/boilerplate/boilerplate.c` | 77 | `variable_item_list` | Benign false positive — standard GUI list-widget API name. |
| `applications_user/boilerplate/boilerplate.h` | 38 | `VariableItemList` | Benign false positive — same API, type name. |
| `applications_user/boilerplate/scenes/boilerplate_scene_settings.c` | 46-115 (multiple) | `variable_item_get_context`, `variable_item_set_current_value_text`, `variable_item_get_current_value_index`, etc. | Benign false positive — standard GUI settings-list API calls. |

**High-confidence unsafe API result**: none. Zero matches for any of the
17 high-severity keywords. The only hardware-adjacent APIs present are
`notification_message()` (haptic/LED, standard Flipper notification
service) and `furi_hal_speaker_acquire`/`furi_hal_speaker_start`/
`furi_hal_speaker_stop`/`furi_hal_speaker_release` (standard on-device
audio, not a safety-exclusion-list capability). One `dolphin_deed()` call
(`views/boilerplate_scene_2.c`) — Flipper's own standard gamification/
XP-tracking API, not a storage or hardware capability.

### `minesweeper`

Scanned: all `.c`/`.h` files under `engine/`, `helpers/`, `scenes/`,
`views/`, plus `minesweeper.c`/`minesweeper.h` (32 files total).

**Substring matches**: all `ble`, inside `variable`/`VariableItem`
(settings-list API), `enabled` (feedback/wrap-around toggle state), and
`solvable`/`is_solvable`/`ensure_solvable` (this app's own board-verifier
feature name, a real gameplay term, not a capability). Representative
sample:

| File | Line | Matched word | Classification |
|---|---|---|---|
| `applications_user/minesweeper/engine/mine_sweeper_solver.c` | 15 | `is_solvable` | Benign false positive — the board-solver feature's own boolean flag name. |
| `applications_user/minesweeper/helpers/mine_sweeper_storage.c` | 60-74 (multiple) | `feedback_enabled`, `wrap_enabled`, `ensure_solvable_board` | Benign false positive — settings field names persisted to the config file. |
| `applications_user/minesweeper/scenes/settings_scene.c` | 36-340 (multiple) | `VariableItem`, `variable_item_*` | Benign false positive — standard GUI settings-list API. |

**High-confidence unsafe API result**: none. Zero matches for any of the
17 high-severity keywords, and — going beyond the required list — zero
mentions anywhere in this app's source of `furi_hal_gpio`, `subghz`,
`nfc`, `rfid`, `ibutton`, `infrared`, or `furi_hal_usb` in any form. The
only hardware-adjacent APIs present are `notification_message()` and the
standard speaker API (identical in nature to `boilerplate`'s usage
above), plus one `dolphin_deed()` call (`minesweeper.c`).

## Aggregate scan totals

184 new substring matches across the 3 apps (all keyword `ble`), added to
the existing 189 from Phase 2A-2D, for **373 total** entries in
`tools/phase2e_validate_config.json`'s `reviewedFalsePositives` list.
**Every single match in all 3 apps is a benign false positive** — none
required any code change, none is a real capability use, and none is
merely a "content-only reference hit" (unlike `crypto_dictionary`'s
glossary text in Phase 2D, none of these 3 apps contain any bundled text
that discusses security/capability terminology at all). Both the local
run and the real CI run (`28966234832`) independently confirmed **zero
unreviewed matches, zero high-confidence-unsafe matches**.

## Storage behavior

- **`image_viewer`**: **read-only**, confirmed directly by a full read of
  `main.cpp` — `file_stream_open(stream, path, FSAM_READ,
  FSOM_OPEN_EXISTING)` is the only storage call; no `FSAM_WRITE` or
  `FSOM_CREATE*` call exists anywhere in the file. No persistent write of
  any kind.
- **`boilerplate`**: **app-private only**, confirmed directly —
  `helpers/boilerplate_storage.c` writes exactly one settings file at
  `/ext/apps_data/boilerplate/boilerplate.conf` (path built from
  `helpers/boilerplate_storage.h`'s own `#define`s). No write to any
  shared or root-level location.
- **`minesweeper`**: **app-private only**, confirmed directly —
  `helpers/mine_sweeper_storage.c` writes settings via an atomic
  write-then-rename pattern (temp file `.../mine_sweeper_redux.conf.tmp`
  → `.../mine_sweeper_redux.conf`, both under
  `/ext/apps_data/mine_sweeper_redux/`, path built from
  `helpers/mine_sweeper_config.h`'s own `#define`s). No write to any
  shared or root-level location.

## Hardware/radio behavior

**None, for any of the 3 apps.** Zero `furi_hal_subghz`, `furi_hal_nfc`,
`furi_hal_rfid`, `furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, or `furi_hal_infrared_async_tx_start` references
anywhere across all 3 apps' actual imported source.

## Sensitive-data handling result

**None, for any of the 3 apps.** Zero matches for `credential`,
`password`, `token`, `exfil`, `brute`, `seed`, `wallet`, `private key`, or
`secret` anywhere across all 3 apps' actual imported source. None of the
3 handles user secrets, keys, wallets, seed phrases, tokens, passwords,
or credentials in any form.

## Conclusion

**No real unsafe/capability use found in any of the 3 apps.** All 184 new
substring matches are confirmed benign and individually reviewed with
exact evidence in `tools/phase2e_validate_config.json`. Storage behavior
is directly confirmed (not assumed) and matches — and, for `boilerplate`
and `minesweeper`, refines with an exact path — the Phase 2E.1 findings.
This safety review does not itself constitute a hardware-tested or
release-ready claim; it is a source-level and CI-level static
confirmation only.

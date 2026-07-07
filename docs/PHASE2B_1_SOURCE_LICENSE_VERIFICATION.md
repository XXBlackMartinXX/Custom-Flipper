# Phase 2B.1 — Source and License Verification

Docs only. Pre-import verification only. **No app code has been imported.**
This is a genuine, fresh source-level verification pass — unlike the
Phase 2B planning package (`PHASE2B_CANDIDATE_REVIEW.md`,
`PHASE2B_LICENSE_REVIEW.md`), which was citation-only because no source
access existed in that session, this phase had real, working network
access to `raw.githubusercontent.com` and `github.com`'s git-over-HTTPS
endpoint (both previously untested for this specific host/protocol
combination — `api.github.com` and GitHub's HTML pages remain blocked with
`403`, consistent with every prior phase's findings, but plain git clone
and raw-file fetch are not). Every finding below is from files actually
read in this session, not carried forward from a prior audit.

## Evidence source

- **Repository**: `RogueMaster/flipperzero-firmware-wPlugins` (the same
  fork every prior Phase 1/2A source audit has cited)
- **Commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same
  commit `PHASE1_6_TOP25_SOURCE_AUDIT.md` audited, fetched fresh via a
  shallow `git fetch --depth 1 origin <sha>` against the real upstream
  repository in this session, not reused from any cached/prior result.
- **Method**: `git checkout <sha> -- applications/external/<app>` for each
  of the 3 apps into a scratch directory outside this repository, then
  direct `cat`/`grep`/`file`/`sha256sum` against the real checked-out
  files. Nothing was fetched into, or committed from, this project's own
  working tree — the scratch clone lives entirely outside
  `/home/user/Custom-Flipper` and is not part of any commit.

## Apps reviewed (exactly the 3 in scope)

`flipfetch`, `quadratic_solver`, `sudoku`. No other app was fetched,
read, or considered. `c_book`, `upython`, `iconedit`,
`animation_switcher`, and `theme_manager` were not touched in this phase.

---

## `flipfetch`

| Field | Value |
|---|---|
| Source path | `applications/external/flipfetch/` |
| appid | `flipfetch` |
| App name (manifest) | `Flipfetch` |
| Category | Tools |
| Author (`fap_author`) | Ismael A. Rodríguez |
| Upstream repo (`fap_weburl`) | `https://github.com/alexroses47/flipper-flipfetch` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `flipfetch.c` (166 lines, 4,969 bytes), `flipfetch.png` (96 bytes, 10×10 1-bit PNG — standard app icon) |
| Bundled third-party code | **None.** Single self-contained source file. |

**License evidence found**: A real `LICENSE` file is present at the app
root, full text read directly:

> MIT License — Copyright (c) 2026 Ismael A. Rodríguez — [standard MIT
> permission/warranty text]

**Declared license: MIT.** No missing-evidence gap — the file exists, was
read in full, and its text is the standard, unmodified MIT license body.
SHA-256 of the exact file as fetched: `82bf9aacd466c35be23d4f10bc73fa4ab175294cfcbb32d46ae4db44c6781c81`.

**Safety/API scan** (full file read, 166 lines): includes are
`furi.h`, `gui/gui.h`, `furi_hal.h`, `furi_hal_power.h`, `storage/storage.h`,
`string.h`, `stdio.h`. Grep for all 18 required capability keywords
(`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
`furi_hal_hid`, `furi_hal_usb_hid`, `furi_hal_gpio_write`,
`furi_hal_infrared_async_tx_start`, `badusb`, `ble`, `deauth`, `jam`,
`brute`, `credential`, `password`, `token`, `exfil`, `clone`, `bypass`):
**zero matches of any kind**, real or false-positive. The only "storage"
API used is `storage_common_fs_info()` — a **read-only** free-space query
used to display "SD free" in the info screen — not a write, not a
save/load path.

**Classification of storage/hardware findings**: benign, read-only,
device-info display only (`furi_hal_version_get_firmware_version()`,
`furi_hal_power_get_pct()`, battery voltage, uptime, free heap, free SD
space).

### `flipfetch` conclusion: **CLEARED FOR IMPORT**

---

## `quadratic_solver`

| Field | Value |
|---|---|
| Source path | `applications/external/quadratic_solver/` |
| appid | `quadratic_solver` |
| App name (manifest) | `Quadratic Solver` |
| Category | Tools |
| Author (`fap_author`) | paul-sopin |
| Upstream repo (`fap_weburl`) | `https://github.com/paul-sopin/flipper-quadratic-solver` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `changelog.md`, `app.c` (225 lines, 6,677 bytes), `quadratic_solver.png` (95 bytes, 10×10 1-bit PNG), `screenshots/` (3 PNGs — documentation-only images referenced by neither `application.fam` nor `app.c`, not part of the built `.fap`) |
| Bundled third-party code | **None.** Single self-contained source file. |

**License evidence found**: A real `LICENSE` file is present, full text
read directly:

> MIT License — Copyright (c) 2025 paul-sopin — [standard MIT
> permission/warranty text]

**Declared license: MIT.** SHA-256 of the exact file as fetched:
`3b2dee56c094664bb9ec081ace3700495449254eeaf61eabedd1333561fb5eaa`.

**Safety/API scan** (full file read, 225 lines): includes are `furi.h`,
`gui/gui.h`, `input/input.h`, `stdlib.h`, `string.h`, `stdio.h`, `math.h`
— **no `storage/storage.h`, no `furi_hal.h` at all.** Grep for the 18
required keywords found **6 raw substring hits, all false positives**,
all from the case-insensitive `ble` pattern matching inside unrelated
English words:

| Line | Text | Why it's a false positive |
|---|---|---|
| 36 | `snprintf(buf, size, "%s = %.5f", label, (double)rounded);` | `"double"` contains the substring `ble` |
| 77 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->a);` | same — `"double"` |
| 81 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->b);` | same — `"double"` |
| 85 | `snprintf(buf, sizeof(buf), "%s%.1f", ..., (double)app->c);` | same — `"double"` |
| 218 | `view_port_enabled_set(app->view_port, false);` | `"enabled"` contains the substring `ble` |

None of these is a real Bluetooth/BLE API reference — `app.c` does not
include any BLE header and has no radio behavior of any kind. This is the
exact same class of false positive (`"ble"` as a substring of an ordinary
word) that Phase 2A's own risky-keyword scan hit 102 times and resolved
via its reviewed-false-positive allowlist — not a new or different
pattern.

**Storage/hardware findings**: **zero.** No storage API call anywhere in
the file; pure arithmetic (quadratic formula) and GUI/input handling.

### `quadratic_solver` conclusion: **CLEARED FOR IMPORT**

---

## `sudoku`

| Field | Value |
|---|---|
| Source path | `applications/external/sudoku/` |
| appid | `sudoku` |
| App name (manifest) | `Sudoku` |
| Category | Games |
| Author (`fap_author`) | profelis |
| Upstream repo (`fap_weburl`) | `https://github.com/profelis/fz-sudoku` |
| Version | `1.2` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `README_catalog.md`, `CHANGELOG.md`, `sudoku.c` (689 lines, 24,383 bytes), `sudoku.png` (98 bytes, 10×10 1-bit PNG), `screenshots/` (2 PNGs, documentation-only) |
| Bundled third-party code | **None.** Single self-contained source file. |

**License evidence found**: A real `LICENSE` file is present, full text
read directly:

> The MIT License (MIT) — Copyright © 2023 @profelis — [standard MIT
> permission/warranty text]

**Declared license: MIT.** SHA-256 of the exact file as fetched:
`b65e22a506115b1466b23a0a5590406ff1360e6d93482b833bae57984de63758`.

**Safety/API scan** (full file read, 689 lines): includes are `stdio.h`,
`furi.h`, `furi_hal.h`, `dolphin/dolphin.h`, `gui/gui.h`, `input/input.h`,
`notification/notification_messages.h`, `storage/storage.h`. Grep for the
17 hardware/security-sensitive keywords (excluding `ble`, handled
separately below) found **zero matches** — no Sub-GHz, NFC, RFID,
iButton, HID, USB HID, GPIO write, Infrared transmit, BadUSB, deauth, jam,
brute, credential, password, token, exfil, clone, or bypass references
anywhere in the file. One `ble`-substring hit, same false-positive class
as `quadratic_solver`'s:

| Line | Text | Why it's a false positive |
|---|---|---|
| 674 | `view_port_enabled_set(view_port, false);` | `"enabled"` contains the substring `ble` |

**Storage findings — real, and verified app-private**: `sudoku` does
write to storage — a save/load path for game state, using
`storage_file_open`/`storage_file_read`/`storage_file_write` at lines
101–131. The save path is defined as:

```c
#define SAVE_FILE APP_DATA_PATH("save.dat")
```

`APP_DATA_PATH(...)` is the Flipper SDK's standard app-private-storage
macro (the same pattern `chess`'s save file uses, confirmed in Phase 2A —
resolves to a path under this app's own private data directory, not a
shared system directory). This is **not** a shared-storage write like
`animation_switcher`/`theme_manager`'s `/ext/dolphin/manifest.txt` — it is
exactly the private-save-file pattern this project has already accepted
once for `chess`.

`dolphin_deed(DolphinDeedPluginGameStart)` and
`dolphin_deed(DolphinDeedPluginGameWin)` (lines 559, 651) are standard
Dolphin XP/achievement-tracking calls used throughout the existing Flipper
app ecosystem (including base-firmware games) — not a safety concern, not
a hardware-control capability, purely a stats increment.

### `sudoku` conclusion: **CLEARED FOR IMPORT**

---

## Aggregate result

| App | License | Safety/API | Storage | Dependencies | Conclusion |
|---|---|---|---|---|---|
| `flipfetch` | MIT, confirmed | Zero real/false-positive hits | Read-only (free-space query) | None declared | **CLEARED FOR IMPORT** |
| `quadratic_solver` | MIT, confirmed | Zero real hits; 5 `ble`-substring false positives (`double`, `enabled`) | None | None declared | **CLEARED FOR IMPORT** |
| `sudoku` | MIT, confirmed | Zero real hits; 1 `ble`-substring false positive (`enabled`) | Real, app-private only (`APP_DATA_PATH`) | None declared | **CLEARED FOR IMPORT** |

All 3 declared licenses are **MIT**, a permissive license fully compatible
with distribution alongside this project's GPLv3-licensed firmware base
(MIT does not restrict inclusion in a GPLv3 work; see
`PHASE2B_LICENSE_REVIEW.md`'s Phase 2B.1 addendum for the compatibility
reasoning). **Attribution is required** for all 3 under MIT's own terms
(the copyright notice and permission text must be preserved) — this is a
straightforward `CREDITS.md`/`THIRD_PARTY_NOTICES.md` entry at actual
import time, the same discipline already used for every upstream project
this repository references.

No app in this batch requires deferral or blocking on license or safety
grounds. The 6 total `ble`-substring false positives found (5 in
`quadratic_solver`, 1 in `sudoku`) are not suppressed here — they are
recorded with exact line numbers for the standard per-line
reviewed-false-positive treatment already used throughout Phase 2A, to be
applied against `tools/phase2a_validate_config.json` once these files
actually land at their real destination paths in this repository (not
before — the config's reviewed-false-positive entries are keyed on exact
file path, which does not exist yet for unimported files).

## What this verification does not cover

- **No build was attempted.** File presence and content were read; none
  of the 3 apps was compiled.
- **No hardware testing was performed.**
- **This is not a claim of bug-free or release-ready status** — only that
  each app's declared license is real and confirmed, and its source
  contains no unsafe capability per the required keyword scan.
- **Import itself has not happened.** See `PHASE2B_1_GO_NO_GO.md` for the
  next allowed step.

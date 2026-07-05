# Phase 1.6 — Top 25 Source Audit

Docs only. No firmware source changed, nothing imported, nothing built, no hardware
touched. This is the individual source-level review promised at the end of
`PHASE1_5_TOP_25_CANDIDATES.md` — every app below had its actual `.c`/`.h`/`.cpp`
files (not just `application.fam` and README) read or grepped for real API usage,
against the RogueMaster clone at commit `472f6925e8aca9bd031cb37e3cb80b551772c957`.

## Method

For each app: full file listing, non-source-file listing (assets/scripts/binaries),
and a targeted grep for real Flipper HAL API usage in eight capability classes
(storage, GPIO, Sub-GHz, Infrared, NFC/RFID/iButton, BLE, USB/HID, and a generic
unsafe-keyword pass for `system()`/`exec()`/`popen`/hardcoded paths). Every capability
hit was then opened and read to confirm what it actually does — a grep match is a
lead, not a verdict, per this project's established discipline.

**This audit found two apps whose metadata-only read in Phase 1.5 significantly
understated their real hardware capability** — both are called out below and neither
is going into the first integration batch as a result. This is exactly why the
source audit step exists rather than trusting `fap_description`/README alone.

## The two findings that changed the picture

### `upython` — real GPIO write + Infrared transmit exposed to user scripts

`fap_description` said "Compile and execute MicroPython scripts," which reads as a
pure software sandbox. Reading `lib/micropython-port/mp_flipper_modflipperzero_gpio.c`
and `lib/micropython-port/mp_flipper_modflipperzero_infrared.c` shows the Python
runtime exposes real hardware bindings to any script it runs:
`furi_hal_gpio_write()`/`furi_hal_gpio_read()`/GPIO interrupt callbacks, and
`furi_hal_infrared_async_tx_start()` (real IR transmit, not just receive). The
"unsafe keyword" grep hits on `exec`/`ALLOC_EXEC` are normal MicroPython VM internals
(every Python implementation has an `exec()` builtin and a bytecode/JIT allocator) —
not a red flag by themselves — but combined with real GPIO write and IR transmit
bindings, this app is a **generic hardware-scriptable environment**, not a closed
calculator-style tool. That's a materially different risk class than its Phase 1.5
description suggested.

### `iconedit` — the "send to PC" feature is real USB HID keystroke injection

`panels/send_usb.c` includes `furi_hal_usb_hid.h` and calls
`furi_hal_hid_kb_press()` / `furi_hal_hid_kb_release()` / `furi_hal_hid_kb_release_all()`
directly. The feature ("send an edited icon to a PC-side Python receiver script") is
benign in intent, but mechanically it works by **typing every byte of the icon data
as keyboard keystrokes** into whatever window has focus on the connected computer —
the same OS-level mechanism a BadUSB payload uses, just with fixed, self-authored
data instead of an arbitrary attacker payload. Nothing in the name, category
(`Tools`), or `fap_description` ("Icon editor") gave any hint of this.

## Full audit table (all 25)

Legend for repeated values: "Local/private" storage = reads/writes only its own
save file, config, or a user-selected file the user explicitly opened — normal,
expected app behavior, not a risk. "None" for a capability column means the grep
found zero real API usage of that class anywhere in the app's source, confirmed by
the capability scan above (see method).

| App | Files inspected | Purpose confirmed from source | Storage behavior | Hardware behavior | Safety/legal risk | Hardware risk | Build/integration risk | Dependency risk | Overlap risk | Decision |
|---|---|---|---|---|---|---|---|---|---|---|
| `chess` | 17 `.c`/`.h`/`.cpp` across `helpers/`, `views/`, `scenes/`, plus a bundled `smallchesslib` and `stm32_sam` (software speech synth) library | Confirmed: full chess implementation with haptic feedback and speech-synthesized voice announcements | Local/private (own save-game file via `helpers/flipchess_file.c`) | None (GPIO/SubGHz/IR/NFC/BLE/USB — zero hits) | None identified | None | Low-Med — bundles two small third-party libs (chess engine, SAM speech synth) that need their own license check before import, but both are self-contained, no external build deps | Low — self-contained, no `requires=[...]` beyond default | None found vs. base | **APPROVE** |
| `2048` | 4 files | Confirmed: 2048 puzzle port | Local/private (high-score save) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `minesweeper` | 20 files across `helpers/`, `views/`, `engine/`, `scenes/` | Confirmed: full Minesweeper with a solver/hint engine | Local/private (save/config via `helpers/mine_sweeper_storage.c`) | None | None identified | None | Low-Med — largest file count of the pure games, still self-contained | Low | None found | **APPROVE** |
| `sudoku` | 1 file | Confirmed: Sudoku implementation | Local/private (save) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `programmer_calc` | 14 files | Confirmed: base-conversion/bitwise calculator, pure computation | **None** (zero storage API calls found) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `resistors` | 13 files under `src/` | Confirmed: resistor color-code calculator, pure computation | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `network_subnet` | 16 files across `views/`, `scenes/`, `core/` | Confirmed: IPv4 subnet math tool, pure computation | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `quadratic_solver` | 1 file | Confirmed: quadratic-equation solver, pure computation | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `hex_viewer` | 20 files across `helpers/`, `views/`, `scenes/` | Confirmed: hex viewer for user-selected files | Local (reads the file the user opens; 2 files touch storage APIs) | None | None identified | None | Low-Med | Low | None found | **APPROVE** |
| `docviewlite` | 1 file | Confirmed: simple document viewer | Local (reads user-selected document) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `image_viewer` | 1 file (`main.cpp`) | Confirmed: image viewer, ships 3 example `.bm` bitmap files | Local (reads user-selected image) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `boilerplate` | 21 files — a full template app with helpers/views/scenes | Confirmed: it's exactly what it says — a FAP starter template, itself directly useful as this project's own dev-tool reference | Local (demonstrates a save-file pattern) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `upython` | ~230 files (bundles a full MicroPython port + Flipper HAL bindings + example scripts) | Confirmed: on-device MicroPython interpreter — but with real GPIO write and Infrared-transmit bindings exposed to user scripts (see finding above) | Local (script files, 3 files touch storage) | **Real**: GPIO read/write/interrupts, Infrared async TX (transmit, not just receive) | Needs review — capability is user-script-driven, not a pre-built attack, but the sandbox has no restriction preventing a script from being an IR-transmit or GPIO-control payload | **Real GPIO + IR transmit capability** — disqualifies it from any "no hardware-control risk" batch | Highest of the 25 — ~230 files, largest and most complex single import in this set, expect the longest real build-verification effort | Bundles its own vendored MicroPython fork (`lib/micropython/`) — needs its own license/provenance check (MicroPython is MIT-licensed upstream, but this is a customized fork, not verified against upstream MicroPython in this pass) | None found vs. base | **DEFER (approved-later)** — highest standalone value of the 25, but needs a dedicated capability-review pass (should Python scripts be allowed unrestricted GPIO/IR access, or should this ship with the hardware modules stripped for a first import?) before any integration, and should never be in a "boring first batch" |
| `iconedit` | 34 files across `panels/`, `utils/` | Confirmed: icon editor with PNG import, drawing tools, and a "send to PC" export feature | Local (edited icon file; 3 files touch storage) | **Real**: USB HID keystroke injection (`furi_hal_hid_kb_press`/`release`) used by the "send to PC" feature (see finding above) | Feature intent is benign (data export via a workaround transport), but mechanism is indistinguishable from BadUSB at the OS level | HID keystroke injection present | Medium | Low | None found | **APPROVE WITH NOTES** — the core icon-editing functionality is fine; recommend the `panels/send_usb.c` feature specifically be stripped or gated behind an explicit expert flag before import, not treated as a normal Tools-category feature |
| `sd_info` | 1 file | Confirmed: displays SD card info, read-only | Local (reads card metadata only) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `flipfetch` | 1 file | Confirmed: displays device info ("neofetch"-style) | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `flipper95` | 1 file | Confirmed: pure CPU stress test (prime-number crunching), no I/O at all | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `animation_switcher` | 18 files across `views/`, `scenes/` | Confirmed: manages dolphin animation "playlists" | **Writes to the shared system directory `/ext/dolphin/manifest.txt`**, not app-private storage (2 files) — confirmed by reading the actual paths in source | None (no GPIO/RF/NFC/BLE/USB) | Low — modifies a shared resource, but has restore-from-backup logic in its own code | None (no hardware peripherals touched, storage-only) | Low-Med | Low | Shares the `/ext/dolphin/` directory with the base firmware's own animation system — not a code overlap, but a runtime-data overlap worth knowing about | **APPROVE WITH NOTES** — fine functionally, flagged because it touches shared system storage rather than an app-private folder; kept out of the first (most conservative) batch on that basis alone |
| `theme_manager` | 1 file (large — theme installer) | Confirmed: installs/manages dolphin animation theme packs from SD card | **Explicitly backs up `/ext/dolphin/` to `/ext/dolphin_backup/` before writing** — read directly in source (`theme_manager_backup_dolphin()`), a responsible, safety-conscious design | None | Low — same shared-directory consideration as `animation_switcher`, but with its own confirmed backup/restore safety net | None | Low-Med | Low | Same `/ext/dolphin/` shared-directory note as above | **APPROVE WITH NOTES** — same reasoning as `animation_switcher`; the backup-before-write behavior specifically is a point in its favor, not a concern |
| `qrcode` | 3 files | Confirmed: displays QR codes from user input | Local | None | None identified | None | Low | Low | None found | **APPROVE** |
| `barcode_gen` | 16 files, plus 4 bundled encoding-table text files (Code39/128/128C/Codabar) as data resources | Confirmed: displays barcodes from user input using bundled encoding tables | Local (reads bundled tables + user text; 3 files touch storage) | None | None identified | None | Low-Med | Low | None found | **APPROVE** |
| `vin_decoder` | 1 file | Confirmed: pure VIN decode/lookup logic, no vehicle interaction of any kind | **None** | None | None identified | None | Low | Low | None found | **APPROVE** |
| `fcc_id_lookup` | 2 files | Confirmed: offline FCC ID/frequency lookup against a bundled database | Local (reads bundled data; 1 file touches storage) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `crypto_dictionary` | 13 files, plus bundled reference `.txt` resources (cipher glossary entries) | Confirmed: pure reference/glossary app, no crypto *operations* performed on user data | Local (reads bundled text resources) | None | None identified | None | Low | Low | None found | **APPROVE** |
| `c_book` | 13 files, plus bundled `.txt` chapters of K&R's "The C Programming Language" | Confirmed: pure e-book reader for a specific bundled text | Local (reads bundled text resources) | None | None identified | None | Low | Low | None found | **APPROVE** |

## Aggregate result

- **APPROVE: 21 of 25**
- **APPROVE WITH NOTES: 3 of 25** (`iconedit`, `animation_switcher`, `theme_manager`)
- **DEFER (approved-later): 1 of 25** (`upython`)
- **REJECT: 0 of 25** — nothing in the Top 25 warranted outright rejection; the
  curation work in Phase 1/1.5 already filtered those out before this list existed.

See `PHASE1_6_REJECTED_OR_DEFERRED_TOP25.md` for the deferred/noted items in isolation
and `PHASE1_6_FIRST_BATCH_SELECTION.md` for which 5 of the 21 clean approvals were
chosen for an actual first integration attempt.

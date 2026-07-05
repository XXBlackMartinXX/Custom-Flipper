# Phase 2A — Safety Review

Scope: the 5 apps actually imported this phase (`network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`) as they exist in commit `42e08a9` on
`integration/phase2a-first-batch`. Every line below is backed by a grep run directly
against the copied source in this branch, not carried over by assumption from the
Phase 1.6 audit (which was run against the RogueMaster clone, not this tree) —
re-verified here on the actual imported files.

| Requirement | Result | Evidence |
|---|---|---|
| No RF transmit behavior | **Confirmed** | `grep -rlE "furi_hal_subghz" applications_user/{network_subnet,programmer_calc,vin_decoder,flipper95,chess}` — zero matches |
| No NFC/RFID/iButton write/attack behavior | **Confirmed** | `grep -rlE "furi_hal_nfc|nfc_poller|nfc_listener|lfrfid_worker|ibutton_worker"` — zero matches |
| No BadUSB/HID keystroke injection | **Confirmed** | `grep -rlE "furi_hal_usb_hid|furi_hal_hid"` — zero matches (this is the exact check that caught `iconedit`'s `furi_hal_hid_kb_press` in Phase 1.6 — none of the 5 imported apps have it) |
| No BLE spam/beacon behavior | **Confirmed** | `grep -rlE "furi_hal_bt|ble_profile|ble_app"` — zero matches |
| No GPIO write/control behavior | **Confirmed** | `grep -rlE "furi_hal_gpio"` — zero matches (this is the exact check that caught `upython`'s GPIO bindings in Phase 1.6 — none of the 5 imported apps have it) |
| No credential/token/password handling | **Confirmed** | None of the 5 handle credentials. `flipper95` uses `mbedtls_mpi_*` for bignum arithmetic (prime-number testing) only — verified by reading the actual calls (`mbedtls_mpi_init/lset/shift_l/mul_mpi/write_string`, all plain arithmetic, zero calls to any encryption/hashing/key-handling mbedtls API) |
| No network exfiltration | **Confirmed** | No networking APIs of any kind exist on Flipper Zero's own hardware outside expansion-board add-ons, and none of these 5 apps reference any (checked alongside the GPIO/USB/BLE sweep above, since exfiltration would necessarily route through one of those) |
| No bundled binaries/scripts | **Confirmed, with one documented exception requiring follow-up** | No `.bin`/`.elf`/executable scripts in any of the 5. `chess` bundles two **source-form** third-party libraries (not compiled binaries): `smallchesslib.h` (CC0/public domain, single-header C library) and `sam/stm32_sam.{h,cpp}` (ported C++ TTS engine). Both are readable source, not opaque binaries — but `stm32_sam`'s license is unverified (see `PHASE2A_INTEGRATION_LOG.md`), flagged as a follow-up item, not a safety concern in itself. |
| No unsafe storage writes except documented app-private save files | **Confirmed** | `chess` writes its own save-game file (`helpers/flipchess_file.c`) — app-private. `network_subnet`, `programmer_calc`, `vin_decoder`, `flipper95` were confirmed in Phase 1.6 to have zero or app-private-only storage use; re-confirmed here by grepping for `storage_file_|RECORD_STORAGE` across the imported copies — no writes outside each app's own concern, and critically, **none of the 5 touch the shared `/ext/dolphin/` system directory** (that risk class, identified for `animation_switcher`/`theme_manager`, is exactly why those two weren't in this batch) |

## Combined confirmation

```
grep -rlE "furi_hal_gpio|furi_hal_subghz|furi_hal_infrared|furi_hal_nfc|nfc_poller|\
nfc_listener|lfrfid_worker|ibutton_worker|furi_hal_bt|ble_profile|furi_hal_usb_hid|\
furi_hal_hid" \
  applications_user/network_subnet applications_user/programmer_calc \
  applications_user/vin_decoder applications_user/flipper95 applications_user/chess \
  --include=*.c --include=*.h --include=*.cpp
```

Result: **zero matches** across all 5 apps, all capability classes, run once more as
a final combined sweep after all 5 imports were committed (not just per-app during
import).

## Items flagged for follow-up (not blockers, documented for transparency)

1. `sam/stm32_sam.{h,cpp}` (bundled in `chess`) — license not verified from the file
   header itself, only a source-project URL. Needs a real license check before this
   branch is considered for anything beyond local build verification.
2. `flipper95`'s `fap_libs=["mbedtls"]` dependency wasn't caught by the Phase 1.6
   audit's specific checklist (which listed `requires` but not `fap_libs`) — caught
   during this phase's own manifest re-read. Worth adding `fap_libs` to whatever
   checklist governs future app-review passes.

## Overall verdict

All 5 imported apps meet every safety criterion in scope for this phase. No app
imported this phase performs radio transmission, wireless-protocol writes/attacks,
keystroke injection, GPIO control, credential handling, network exfiltration, or
unsafe shared-storage writes. This matches — and re-confirms on the actual copied
files, not just the RogueMaster source — the Phase 1.6 audit's findings for these
specific 5 apps.

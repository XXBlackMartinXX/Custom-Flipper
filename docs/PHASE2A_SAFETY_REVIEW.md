# Phase 2A — Safety Review

**v2** — re-run against the rebuilt tree (real git submodules, see
`PHASE2A_INTEGRATION_LOG.md` for why the branch was rebuilt). The rebuild changed
nothing about the 5 imported apps' own content, and none of these findings changed;
re-verified rather than assumed carried-over.

Scope: the 5 apps imported this phase (`network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`) as they exist in commit `202245e` (current tip)
on `integration/phase2a-first-batch`. Every line below is backed by a grep run
directly against the copied source in this branch.

| Requirement | Result | Evidence |
|---|---|---|
| No RF transmit behavior | **Confirmed** | `grep -rlE "furi_hal_subghz"` across all 5 apps — zero matches |
| No NFC/RFID/iButton write/attack behavior | **Confirmed** | `grep -rlE "furi_hal_nfc\|nfc_poller\|nfc_listener\|lfrfid_worker\|ibutton_worker"` — zero matches |
| No BadUSB/HID keystroke injection | **Confirmed** | `grep -rlE "furi_hal_usb_hid\|furi_hal_hid"` — zero matches |
| No BLE spam/beacon behavior | **Confirmed** | `grep -rlE "furi_hal_bt\|ble_profile\|ble_app"` — zero matches |
| No GPIO write/control behavior | **Confirmed** | `grep -rlE "furi_hal_gpio"` — zero matches |
| No credential/token/password handling | **Confirmed** | `flipper95`'s `mbedtls_mpi_*` calls re-confirmed as pure bignum arithmetic only |
| No network exfiltration | **Confirmed** | No networking APIs referenced by any of the 5 |
| No bundled binaries/scripts | **Confirmed, one documented follow-up item** | `chess` bundles two **source-form** libraries; `sam/stm32_sam` license still unverified (unchanged from v1 finding) |
| No unsafe storage writes except documented app-private save files | **Confirmed** | None of the 5 touch the shared `/ext/dolphin/` system directory; `chess`'s save file remains app-private |

## Combined confirmation (re-run on rebuilt tree)

```
grep -rlE "furi_hal_gpio|furi_hal_subghz|furi_hal_infrared|furi_hal_nfc|nfc_poller|\
nfc_listener|lfrfid_worker|ibutton_worker|furi_hal_bt|ble_profile|furi_hal_usb_hid|\
furi_hal_hid" \
  applications_user/network_subnet applications_user/programmer_calc \
  applications_user/vin_decoder applications_user/flipper95 applications_user/chess \
  --include=*.c --include=*.h --include=*.cpp
```

Result: **zero matches**, same as v1.

## Items flagged for follow-up (unchanged from v1)

1. `sam/stm32_sam.{h,cpp}` (bundled in `chess`) — license not verified from the file
   header itself, only a source-project URL.
2. `flipper95`'s `fap_libs=["mbedtls"]` — now doubly confirmed benign, and doubly
   confirmed to reference a real, present submodule in this rebuilt base (not just
   "a file that happens to exist" as in the flattened v1 tree).

## Overall verdict

Unchanged from v1: all 5 imported apps meet every safety criterion in scope for
this phase. The branch rebuild (real submodules replacing flattened files) changed
nothing about app safety — it only fixed the base's own buildability. No app
imported this phase performs radio transmission, wireless-protocol writes/attacks,
keystroke injection, GPIO control, credential handling, network exfiltration, or
unsafe shared-storage writes.

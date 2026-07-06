# Phase 2A — Safety Review

**v4** — the post-SAM-removal tree has now been real-build-confirmed (see
`PHASE2A_BUILD_REPORT.md`: local Windows build PASS at commit `5e5e0ec`, both
`fbt.cmd` targets, both artifacts present). v3 covered the removal itself (commit
`6359f87`; see `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`) before that rebuild had
happened. v2 was re-run against the rebuilt tree with real git submodules (see
`PHASE2A_INTEGRATION_LOG.md`). Findings below are otherwise unchanged from v3 —
nothing about app safety changed with the rebuild, only its confirmation status.

Scope: the 5 apps imported this phase (`network_subnet`, `programmer_calc`,
`vin_decoder`, `flipper95`, `chess`) as they exist in commit `5e5e0ec` (current tip)
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
| No bundled binaries/scripts | **Confirmed — unclear-license code removed entirely** | `chess`'s SAM text-to-speech component (`sam/stm32_sam.{h,cpp}`, `helpers/flipchess_voice.{cpp,h}`), whose upstream (`s-macke/SAM`) had no valid open-source license (self-described "abandonware," only a speculative Fair Use claim — see `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`), has been **deleted from the repository**, not just excluded from the build. `chess` now bundles only `smallchesslib` (CC0/public domain, source-form, no compiled binaries). |
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

## Items flagged for follow-up

1. `sam/stm32_sam.{h,cpp}` (formerly bundled in `chess`) — **resolved and closed**.
   Never a safety/hardware-capability issue (it had no radio/GPIO/HID access — a
   pure audio synthesis routine feeding the same speaker API any app can use); it
   was a licensing/distribution-compliance issue, and it's now moot: the component
   was removed from the repository entirely (commit `6359f87`), not merely disabled.
2. `flipper95`'s `fap_libs=["mbedtls"]` — now doubly confirmed benign, and doubly
   confirmed to reference a real, present submodule in this rebuilt base (not just
   "a file that happens to exist" as in the flattened v1 tree).

## Overall verdict

All 5 imported apps meet every safety criterion in scope for this phase, confirmed
on a real, independently-verified local Windows build **at the current tip**
(commit `5e5e0ec`, post-SAM-removal — see `PHASE2A_BUILD_REPORT.md`). No app
imported this phase performs radio transmission, wireless-protocol writes/attacks,
keystroke injection, GPIO control, credential handling, network exfiltration, or
unsafe shared-storage writes. The one previously-open item — `chess`'s SAM
text-to-speech licensing question — is closed: the component has been removed from
the repository outright, not disabled or gated, and that removal itself is now
build-confirmed, not just statically validated. **Hardware flashing/testing
remains NOT PERFORMED** — a passing build is not a hardware test, and nothing here
should be read as implying otherwise.

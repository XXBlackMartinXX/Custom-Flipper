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
| No bundled binaries/scripts | **Confirmed no binaries; one licensing follow-up now resolved to a decision** | `chess` bundles two **source-form** libraries, no compiled binaries. `sam/stm32_sam`'s license investigation is now complete — see `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`: the original upstream project (`s-macke/SAM`) explicitly has no license (self-described "abandonware," only a speculative Fair Use claim). Decision: **SAM LICENSE UNCLEAR / DISABLE VOICE FEATURE** — implementation (a code change) is pending separate approval, not yet done. |
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

1. `sam/stm32_sam.{h,cpp}` (bundled in `chess`) — **investigation complete**, see
   `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`. Not a safety/hardware-capability issue
   (this component has no radio/GPIO/HID access either — it's a pure audio
   synthesis routine feeding the same speaker API any app can use); it's a
   licensing/distribution-compliance issue, tracked separately. Remains an open
   item until the recommended code change (disable/remove the voice feature) is
   approved and applied.
2. `flipper95`'s `fap_libs=["mbedtls"]` — now doubly confirmed benign, and doubly
   confirmed to reference a real, present submodule in this rebuilt base (not just
   "a file that happens to exist" as in the flattened v1 tree).

## Overall verdict

All 5 imported apps meet every safety criterion in scope for this phase, confirmed
again on a real, independently-verified local Windows build (see
`PHASE2A_BUILD_REPORT.md`). No app imported this phase performs radio transmission,
wireless-protocol writes/attacks, keystroke injection, GPIO control, credential
handling, network exfiltration, or unsafe shared-storage writes. One open item
remains, and it is a **licensing/attribution** question, not a safety one: `chess`'s
bundled SAM text-to-speech component has no valid open-source license upstream
(see `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`), and a code change to disable that
specific feature is recommended but not yet applied, pending approval.

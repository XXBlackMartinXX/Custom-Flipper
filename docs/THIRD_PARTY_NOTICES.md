# Third-Party Notices

This project's build base (Unleashed Firmware, in turn derived from Flipper Zero
Official Firmware) bundles third-party libraries as git submodules, each under its own
license. This project does not alter those licenses and preserves all upstream notices
unmodified.

Submodules present in the verified base (`DarkFlippers/unleashed-firmware`, `dev`
branch, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c`), per `.gitmodules`:

- `lib/mbedtls` — Mbed-TLS/mbedtls (Apache-2.0 / GPLv2, dual-licensed by upstream)
- `lib/libusb_stm32` — flipperdevices/libusb_stm32 (Apache-2.0)
- `lib/microtar` — third-party tar reader (MIT)
- `lib/mlib` — P-p-H-d/mlib (BSD-3-Clause / LGPL, dual-licensed by upstream)
- `lib/nanopb` — nanopb/nanopb (zlib license)
- `lib/stm32wb_cmsis`, `lib/stm32wb_hal`, `lib/stm32wb_copro` — STMicroelectronics
  vendor HAL/CMSIS code (BSD-3-Clause, ST-specific terms — see each submodule's own
  LICENSE)

This list reflects the top-level `.gitmodules` entries observed during Phase 0
verification and is not yet a full recursive third-party license audit (that requires
Phase 1 feature/dependency inventory, not yet performed). Do not treat this as a
complete or final third-party notice for release purposes.

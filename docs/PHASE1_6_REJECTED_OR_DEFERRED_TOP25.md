# Phase 1.6 — Rejected or Deferred (Top 25)

Docs only. Nothing here has been imported or built. Of the 25 apps individually
source-audited in `PHASE1_6_TOP25_SOURCE_AUDIT.md`, none were rejected outright —
the earlier Phase 1/1.5 curation had already filtered the genuinely unsafe apps out
before this list was assembled. Three apps were downgraded from a clean "approve" to
a qualified status after reading their actual source, and are recorded here in
isolation so they aren't lost track of.

## Deferred (approved-later) — needs its own dedicated review before any integration

### `upython`

- **Source path**: `applications/external/upython/`
- **Exact reason**: Source audit found real `furi_hal_gpio_write()`/
  `furi_hal_gpio_read()`/GPIO-interrupt bindings and real
  `furi_hal_infrared_async_tx_start()` (IR **transmit**, not just receive) exposed
  to any MicroPython script it runs. `fap_description` ("Compile and execute
  MicroPython scripts") gave no hint of this — it reads as a closed software
  sandbox and isn't one.
- **Why not rejected outright**: The capability is user-script-driven, not a
  pre-built attack tool, and this is the single highest-value entry in the whole
  Top 25 (a real, general-purpose on-device scripting environment). Rejecting it
  permanently would be throwing away a lot of value over a solvable problem.
- **What "approved-later" requires before reconsideration**: A real decision on
  whether the shipped build should include the GPIO/Infrared Python modules at all,
  or ship with them compiled out for a first import (revisit for a "full" pass
  later, once there's an actual security-review phase and expert-only build-flag
  mechanism in place, per the project's Tier 5 discipline for lab-only features).
  This is exactly the kind of app that Tier 5 (lab-only, expert-flag-gated) was
  designed for — it shouldn't be evaluated under the same bar as a calculator.
- **Not in the first batch**: correct call regardless of how the above review goes —
  it's too complex (largest file count of the 25 by a wide margin) and too capable
  for a "keep it boring" first pipeline test either way.

## Approved with notes — fine to integrate later, but not in the first (most conservative) batch

### `iconedit`

- **Exact reason for the "with notes" qualifier**: `panels/send_usb.c` calls
  `furi_hal_hid_kb_press()`/`furi_hal_hid_kb_release()` directly — the "send edited
  icon to a PC" feature works by typing the icon data as keystrokes, mechanically
  identical to how a BadUSB payload types text, just with fixed, self-authored data.
  Nothing in the name/category/description suggested this.
- **Not a rejection because**: The core icon-editing functionality (drawing, PNG
  import, file save) has zero hardware-API involvement and is exactly what the app
  claims to be. The keystroke-injection behavior is isolated to one file
  (`panels/send_usb.c`) supporting one optional feature.
- **Condition for future integration**: Strip or gate `panels/send_usb.c`
  specifically behind an explicit expert-only flag (consistent with how the project
  treats any HID-injection-capable code, regardless of how benign the specific
  payload is), rather than shipping it as an ordinary Tools-category default.

### `animation_switcher` and `theme_manager`

- **Exact reason for the "with notes" qualifier**: Both write to
  `/ext/dolphin/manifest.txt` — a **shared system directory** used by the base
  firmware's own dolphin-animation subsystem — rather than an app-private data
  folder. This isn't a defect; it's literally these apps' entire purpose (managing
  animation themes), but it's a materially different storage-risk class than a
  private save file.
- **Point in their favor**: `theme_manager`'s source was confirmed to explicitly
  back up `/ext/dolphin/` to `/ext/dolphin_backup/` before writing
  (`theme_manager_backup_dolphin()`), and `animation_switcher` has its own
  restore-from-backup logic too — both show real defensive design around the
  shared-directory risk, not carelessness.
- **Not in the first batch because**: With 19 other clean, fully-private-or-
  zero-storage apps available, there was no reason to accept even a well-mitigated
  shared-directory risk in the very first pipeline-validation batch. Both are
  reasonable candidates for a second batch.

## Everything else in the Top 25 (21 apps)

Confirmed clean by source audit — see `PHASE1_6_TOP25_SOURCE_AUDIT.md` for the full
per-app table. Five of the 21 were selected for the actual first batch in
`PHASE1_6_FIRST_BATCH_SELECTION.md`; the remaining 16 are approved and available for
a subsequent batch once the first one's pipeline is validated.

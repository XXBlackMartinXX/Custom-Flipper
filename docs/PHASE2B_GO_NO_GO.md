# Phase 2B — Go / No-Go

Docs only. Planning only. This is the closing decision document for the
Phase 2B planning package — it recommends a path, it does not take it.

## Final recommendation: **GO WITH CONDITIONS**

Phase 2B **planning** (this package) is complete and finds a genuinely
small, low-risk tiny batch worth recommending for a *future* implementation
phase. Phase 2B **implementation** is not started by this recommendation —
it requires the project owner's own separate, explicit request, and even
then only under the conditions below.

This recommendation is deliberately not a plain "GO": one candidate in the
broader pool (`c_book`) surfaced a real, unresolved licensing question that
the prior Phase 1.6 audit did not catch (it screened hardware/storage
capability, not bundled-content copyright), which is exactly the kind of
finding that justifies "with conditions" rather than an unqualified GO.

## Exact tiny batch recommended

From `PHASE2B_RECOMMENDED_BATCH.md`, in this import order:

1. `flipfetch` (Tools) — LOW risk, zero storage/hardware capability
2. `quadratic_solver` (Tools) — LOW risk, zero storage/hardware capability
3. `sudoku` (Games) — LOW risk, zero hardware capability, app-private
   storage only

All 3 were confirmed by the existing Phase 1.6 source audit to have zero
matches against every hardware-capability class this project screens for
(Sub-GHz, NFC/RFID/iButton, BadUSB/HID, BLE, GPIO, Infrared transmit), and
none bundle third-party code or content of any kind.

## Apps explicitly deferred

- **`c_book`** — **DEFER (licensing)**. Bundles verbatim `.txt` chapters of
  a commercially copyrighted book ("The C Programming Language," K&R,
  Prentice Hall) with no confirmed distribution right. Needs a dedicated
  license/provenance review (the same kind `chess`'s SAM component
  received in Phase 2A) before it can be reconsidered for any batch. See
  `PHASE2B_LICENSE_REVIEW.md`.
- **`upython`** — **DEFER (safety/capability)**. Real `furi_hal_gpio_write`/
  `furi_hal_gpio_read`/GPIO-interrupt and `furi_hal_infrared_async_tx_start`
  (IR transmit) bindings exposed to user-authored scripts. On this
  project's explicit safety-exclusion list. Needs a dedicated
  capability-review phase (e.g. a build variant with those Python HAL
  modules compiled out) before reconsideration — this is exactly the class
  of feature this project's Tier 5 lab-only/expert-flag discipline exists
  for, not an ordinary Tools-category app.
- **`iconedit`** — **DEFER (safety/capability)**. Real
  `furi_hal_hid_kb_press`/`release` (USB HID keystroke injection) in one
  file (`panels/send_usb.c`) supporting an optional "send to PC" feature.
  On this project's explicit safety-exclusion list. The core icon-editing
  functionality is not itself unsafe; reconsideration would require that
  one file to be stripped or gated behind an explicit expert-only flag,
  not shipped as an ordinary default.
- **`animation_switcher`, `theme_manager`** — deferred to a *later* Phase
  2B batch, not excluded outright. Both write to the shared `/ext/dolphin/`
  directory rather than app-private storage; both have their own confirmed
  backup/restore logic, so this is a "not the most conservative first
  slice" call, not a safety rejection.
- **`resistors`, `boilerplate`, `hex_viewer`, `minesweeper`,
  `barcode_gen`, `image_viewer`, `crypto_dictionary`, `fcc_id_lookup`,
  `qrcode`, `docviewlite`, `2048`** — all remain in the clean candidate
  pool (see `PHASE2B_CANDIDATE_REVIEW.md`) for a subsequent batch; none
  were rejected, only not selected for this specific tiny first slice.

## Conditions before implementation

1. **The project owner must explicitly request Phase 2B implementation
   start** — this package, on its own, does not authorize that, no matter
   how clean this recommendation reads.
2. **Each of the 3 recommended apps must have its actual source
   (application.fam, `.c`/`.h` files, and any bundled resources) freshly
   read at real import time** — this planning phase's review is a citation
   of the existing Phase 1.6 audit, not a new source read, because this
   environment has no local source clone to read one from.
3. **Each app's actual license file/header must be read and recorded**
   before its import commit — this planning phase marked all 3 as `NEEDS
   REVIEW` (routine) rather than falsely declaring them license-clean; see
   `PHASE2B_LICENSE_REVIEW.md`.
4. **The existing Phase 2A validation pipeline must be reused unmodified**
   — `tools/phase2a_validate.ps1`, its reviewed-false-positive allowlist
   mechanism, the GitHub Actions CI workflow, and the artifact-hash/tag
   finalization workflow. No gate may be weakened, bypassed, or skipped to
   accommodate this batch.
5. **One-app-at-a-time, commit-per-app, rebuild-after-each** — per
   `PHASE2B_INTEGRATION_PLAN.md`.
6. **No hardware-connected validation mode is run against a Phase 2B
   commit until that commit reaches a clean Static+Build CI result** —
   same ordering Phase 2A followed.
7. **`c_book`'s license question, and `upython`/`iconedit`'s capability
   questions, remain open** and are not resolved by this package; none of
   the 3 may be imported under this recommendation regardless of how the
   3-app tiny batch goes.

## Prompt canaries for Phase 2B implementation

Carried forward verbatim for whoever executes a future implementation
phase:

- If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR, stop
  and mark DEFER unless already proven harmless and explicitly approved.
- If any app has unclear license or bundled third-party code without
  provenance, stop and mark DEFER.
- If any app requires hardware testing before basic CI confidence, stop
  and mark DEFER.
- If any app requires source changes outside its own app directory, stop
  and mark NEEDS REVIEW.
- If the plan tries to import code in this phase, stop immediately; this
  phase is planning only.
- If evidence is missing, write NEEDS REVIEW instead of guessing.
- Never claim hardware-tested, release-ready, safe-to-flash, or bug-free.

## Statement

**PHASE 2B PLANNING ONLY / NO CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was read, modified, or built in this phase. No
hardware was touched. Hardware flashing/testing remains **NOT PERFORMED**.
Release status remains **TEST-READY ONLY / NOT RELEASE-READY**, unchanged
from the Phase 2A baseline this plan builds on.

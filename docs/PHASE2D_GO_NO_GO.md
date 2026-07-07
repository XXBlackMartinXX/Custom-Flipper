# Phase 2D — Go / No-Go

Docs only. Planning only. This is the closing decision document for the
Phase 2D planning package — it recommends a path, it does not take it.

## Final recommendation: **GO WITH CONDITIONS**

Phase 2D **planning** (this package) is complete and finds a genuinely
small, low-risk tiny batch worth recommending for a *future* implementation
phase. Phase 2D **implementation/import** is not started by this
recommendation — it requires the project owner's own separate, explicit
request, and even then only after Phase 2D.1 (pre-import source/license
verification) separately passes.

This recommendation is "with conditions" rather than a plain "GO" for the
same reason every prior planning phase in this project has been
conditional: no per-app `LICENSE` file has actually been read for any of
the 3 recommended apps in this phase (that verification is explicitly
deferred to Phase 2D.1), and two of the three carry a specific,
named follow-up item (`resistors`'s bundled ~2.3MB asset footprint's own
provenance; `crypto_dictionary`'s glossary text's own provenance) worth
flagging explicitly rather than waving through.

## Exact tiny batch recommended

From `docs/PHASE2D_RECOMMENDED_BATCH.md`, in this import order:

1. `resistors` (Tools) — LOW risk, zero storage (the most explicit
   zero-storage classification in the pool), zero hardware capability
2. `crypto_dictionary` (Tools/Educational) — LOW risk, zero storage
   (reads bundled glossary text only), zero hardware capability,
   confirmed pure reference tool with no crypto operations on user data
3. `2048` (Games) — LOW risk, zero hardware capability, app-private
   high-score save only (the same pattern already proven safe by
   `chess`/`sudoku`)

All 3 were confirmed by the existing Phase 1.6 source audit to have zero
matches against every hardware-capability class this project screens for
(Sub-GHz, NFC/RFID/iButton, BadUSB/HID, BLE, GPIO, Infrared transmit).

## Apps explicitly deferred

- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — hard-excluded per this phase's explicit
  instructions, unchanged from their prior-phase status. Not re-reviewed.
- **`fcc_id_lookup`** — **remains deferred**, unchanged from Phase 2C.1's
  finding (no `LICENSE` file in the RogueMaster-vendored copy). Not
  re-reviewed, not included in Phase 2D planning, not resolved by this
  package. Its resolution requires a separate, narrow license-follow-up
  phase, per the project owner's own explicit instruction.
- **`hex_viewer`, `qrcode`, `barcode_gen`** — remain in the clean
  candidate pool (see `docs/PHASE2D_CANDIDATE_REVIEW.md`) for a
  subsequent batch; not selected for this specific tiny slice because
  their existing storage-behavior descriptions do not explicitly rule out
  a write, and this project's own Phase 2C.1 experience with `sd_info`
  (assumed zero-storage, found to write) is the specific reason that
  ambiguity is treated as a reason to defer to a future batch rather than
  assume read-only behavior now.
- **`minesweeper`, `image_viewer`, `boilerplate`** — remain in the clean
  candidate pool; not selected for this specific tiny slice for the
  reasons detailed in `docs/PHASE2D_RECOMMENDED_BATCH.md` (larger file
  count for `minesweeper` relative to `2048`'s equivalent role; unconfirmed
  bundled-bitmap provenance for `image_viewer`; explicit instruction not
  to select `boilerplate` merely to fill the batch).

## Conditions before implementation

1. **The project owner must explicitly request Phase 2D.1 (pre-import
   verification) start** — this package, on its own, does not authorize
   that, no matter how clean this recommendation reads.
2. **Each of the 3 recommended apps must have its actual source
   (application.fam, `.c`/`.h` files, and any bundled resources) freshly
   read at Phase 2D.1** — this planning phase's review is a citation of
   the existing Phase 1.6 audit, not a new source read.
3. **Each app's actual license file/header must be read and recorded**
   before its import commit — this planning phase marked all 3 as `NEEDS
   REVIEW` (routine) rather than falsely declaring them license-clear; see
   `docs/PHASE2D_LICENSE_REVIEW.md`. `resistors`'s bundled asset footprint
   and `crypto_dictionary`'s glossary text provenance specifically must be
   confirmed, not just cited.
4. **`2048`'s and `resistors`'s exact storage/behavior must be confirmed
   directly from real source at Phase 2D.1**, not assumed from the Phase
   1.6 citation — the same lesson Phase 2C.1 taught with `sd_info`.
5. **The existing validation pipeline must be reused unmodified** —
   `tools/phase2a_validate.ps1` (with `-ConfigPath` pointed at an updated
   config if the project owner wants one), its reviewed-false-positive
   allowlist mechanism, the GitHub Actions CI workflow pattern, and the
   artifact-hash/tag finalization workflow pattern. No gate may be
   weakened, bypassed, or skipped to accommodate this batch.
6. **One-app-at-a-time, commit-per-app, rebuild-after-each** — per
   `docs/PHASE2D_INTEGRATION_PLAN.md`.
7. **No hardware-connected validation mode is run against a Phase 2D
   commit until that commit reaches a clean Static+Build CI result** —
   same ordering as every prior phase.
8. **`upython`/`iconedit`/`c_book`/`animation_switcher`/`theme_manager`'s
   prior exclusion reasons and `fcc_id_lookup`'s license question remain
   open** and are not resolved by this package; none of those 6 may be
   imported under this recommendation regardless of how this 3-app tiny
   batch goes.

## Prompt canaries for Phase 2D implementation

Carried forward verbatim for whoever executes a future implementation
phase:

- If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR, stop
  and mark DEFER unless already proven harmless and explicitly approved.
- If any app has unclear license or bundled third-party code/data
  without provenance, stop and mark DEFER.
- If any app requires hardware testing before basic CI confidence, stop
  and mark DEFER.
- If any app requires source changes outside its own app directory, stop
  and mark NEEDS REVIEW.
- If any app handles credentials, tokens, passwords, seed phrases, keys,
  exfiltration, bypass, cloning, brute force, or HID injection, mark
  DEFER.
- If the plan tries to import code in this phase, stop immediately; this
  phase is planning only.
- If evidence is missing, write NEEDS REVIEW instead of guessing.
- Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free.

## Statement

**PHASE 2D PLANNING ONLY / NO CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was read, modified, or built in this phase. No
hardware was touched, no hardware-connected validation mode was run.
Hardware flashing/testing remains **NOT PERFORMED**. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**, unchanged from the
Phase 2C baseline this plan builds on. `fcc_id_lookup` remains deferred,
unresolved, and untouched by this phase.

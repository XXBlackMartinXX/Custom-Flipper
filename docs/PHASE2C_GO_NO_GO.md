# Phase 2C — Go / No-Go

Docs only. Planning only. This is the closing decision document for the
Phase 2C planning package — it recommends a path, it does not take it.

## Final recommendation: **GO WITH CONDITIONS**

Phase 2C **planning** (this package) is complete and finds a genuinely
small, low-risk tiny batch worth recommending for a *future* implementation
phase. Phase 2C **implementation/import** is not started by this
recommendation — it requires the project owner's own separate, explicit
request, and even then only after Phase 2C.1 (pre-import source/license
verification) separately passes.

This recommendation is "with conditions" rather than a plain "GO" for the
same reason every prior planning phase in this project has been
conditional: no per-app `LICENSE` file has actually been read for any of
the 3 recommended apps in this phase (that verification is explicitly
deferred to Phase 2C.1), and `fcc_id_lookup`'s bundled reference database
carries one specific provenance question (public-FCC-record derivation,
described but not independently confirmed) worth flagging explicitly
rather than waving through.

## Exact tiny batch recommended

From `PHASE2C_RECOMMENDED_BATCH.md`, in this import order:

1. `sd_info` (Tools) — LOW risk, zero storage writes (read-only card info), zero hardware capability
2. `fcc_id_lookup` (Tools) — LOW risk, zero storage writes (reads bundled data only), zero hardware capability
3. `docviewlite` (Tools) — LOW risk, zero storage writes (reads user-selected file only), zero hardware capability

All 3 were confirmed by the existing Phase 1.6 source audit to have zero
matches against every hardware-capability class this project screens for
(Sub-GHz, NFC/RFID/iButton, BadUSB/HID, BLE, GPIO, Infrared transmit), and
none write any new persistent state.

## Apps explicitly deferred

- **`upython`, `iconedit`** — hard-deferred per this phase's explicit
  instructions, unchanged from their Phase 2B safety-exclusion status
  (real GPIO/IR-transmit capability and real USB-HID-injection capability,
  respectively). Not re-reviewed in this phase.
- **`c_book`** — hard-deferred per this phase's explicit instructions,
  unchanged from its Phase 2B licensing-exclusion status (bundles
  verbatim copyrighted book text with no confirmed distribution right).
  Not re-reviewed in this phase.
- **`animation_switcher`, `theme_manager`** — hard-deferred per this
  phase's explicit instructions, unchanged from their Phase 2B status
  (shared `/ext/dolphin/` writes rather than app-private storage). Not
  re-reviewed in this phase.
- **`2048`, `minesweeper`, `resistors`, `hex_viewer`, `image_viewer`,
  `boilerplate`, `qrcode`, `barcode_gen`, `crypto_dictionary`** — remain in
  the clean candidate pool (see `PHASE2C_CANDIDATE_REVIEW.md`) for a
  subsequent batch; none were rejected, only not selected for this
  specific tiny slice, which deliberately prioritized zero-write apps over
  apps with a private save file or larger asset footprint.

## Conditions before implementation

1. **The project owner must explicitly request Phase 2C.1 (pre-import
   verification) start** — this package, on its own, does not authorize
   that, no matter how clean this recommendation reads.
2. **Each of the 3 recommended apps must have its actual source
   (application.fam, `.c`/`.h` files, and any bundled resources) freshly
   read at Phase 2C.1** — this planning phase's review is a citation of
   the existing Phase 1.6 audit, not a new source read.
3. **Each app's actual license file/header must be read and recorded**
   before its import commit — this planning phase marked all 3 as `NEEDS
   REVIEW` (routine) rather than falsely declaring them license-clear; see
   `PHASE2C_LICENSE_REVIEW.md`. `fcc_id_lookup`'s bundled database
   provenance specifically must be confirmed, not just cited.
4. **The existing validation pipeline must be reused unmodified** —
   `tools/phase2a_validate.ps1` (with `-ConfigPath` pointed at an updated
   config if the project owner wants one), its reviewed-false-positive
   allowlist mechanism, the GitHub Actions CI workflow pattern, and the
   artifact-hash/tag finalization workflow pattern. No gate may be
   weakened, bypassed, or skipped to accommodate this batch.
5. **One-app-at-a-time, commit-per-app, rebuild-after-each** — per
   `PHASE2C_INTEGRATION_PLAN.md`.
6. **No hardware-connected validation mode is run against a Phase 2C
   commit until that commit reaches a clean Static+Build CI result** —
   same ordering as every prior phase.
7. **`upython`/`iconedit`'s capability questions and `c_book`'s license
   question, and `animation_switcher`/`theme_manager`'s shared-storage
   status, remain open** and are not resolved by this package; none of
   those 5 may be imported under this recommendation regardless of how
   this 3-app tiny batch goes.

## Prompt canaries for Phase 2C implementation

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

**PHASE 2C PLANNING ONLY / NO CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was read, modified, or built in this phase. No
hardware was touched, no hardware-connected validation mode was run.
Hardware flashing/testing remains **NOT PERFORMED**. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**, unchanged from the
Phase 2B baseline this plan builds on.

---

## Phase 2C.1 update: pre-import verification result

**Phase 2C.1 classification: `PHASE 2C.1 NEEDS REVIEW`.** See
`docs/PHASE2C_1_GO_NO_GO.md`, `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`,
and `docs/PHASE2C_1_IMPORT_READINESS_MATRIX.md` for full detail.

Real, direct network access to the actual upstream RogueMaster source
(commit `472f6925e8aca9bd031cb37e3cb80b551772c957`, the same commit every
prior audit in this project has cited) resolved the license-evidence gap
this document originally flagged for 2 of the 3 recommended apps:

- **`sd_info`**: **CONFIRMED — GPLv3**, real `LICENSE` file read directly
  from the vendored source. Also carries a real, material correction: this
  app is not zero-storage as this document and the planning package
  assumed — it performs a real, transient, self-cleaning, explicitly
  user-initiated SD-card read/write benchmark at `/ext/sdtest.tmp*` (not
  app-private, not persistent, not automatic, not a safety-exclusion-list
  capability). Cleared for import with this corrected risk understanding.
- **`docviewlite`**: **CONFIRMED — MIT**, real `LICENSE` file read
  directly from the vendored source. Storage behavior confirmed exactly as
  assumed (read-only, user-selected file only). Cleared for import, with
  one build-risk note (a manifest field referencing a non-existent
  `images/` asset directory, to be observed at Static/Build validation
  time).
- **`fcc_id_lookup`**: **Not resolved — elevated to DEFER.** The
  RogueMaster-vendored copy of this app has no `LICENSE` file, no SPDX
  header, and no copyright notice anywhere in its source. Strong
  corroborating evidence (a real, confirmed MIT license, same author, same
  project, found at the exact upstream repository this app's manifest
  links to) exists, but is not commit-pinned to the specific historical
  revision RogueMaster vendored — per this phase's own license canary,
  that is not sufficient to declare the license proven. This is a
  materially lower-severity DEFER than `c_book`'s (no unresolved copyright
  question, no commercial content, no capability concern — a clear,
  low-effort resolution path exists) but it is real and unresolved as of
  this update. The 8.9MB reference database originally flagged for a
  provenance check turned out not to be part of the vendored source tree
  at all, narrowing rather than widening this app's licensing surface.

**The original 3-app batch does not remain fully valid.** It shrinks to a
**2-app cleared batch**: `sd_info`, `docviewlite`. `fcc_id_lookup` is
deferred, not substituted with a different app, per this phase's explicit
instruction not to auto-substitute.

This document's original "GO WITH CONDITIONS" recommendation and its
numbered conditions list above are **superseded for condition #3
specifically** (the license-read condition — now satisfied for 2 of the 3
apps, still open for the third) but otherwise still apply in full — in
particular, condition #1 (the project owner's own explicit request is
still required to start implementation) remains exactly as written; this
verification pass satisfies condition #2 for all 3 apps (fresh source was
read for all 3) and condition #3 for 2 of the 3, but does not itself
constitute condition #1.

**No app code was imported in Phase 2C.1.** Hardware flashing/testing
remains **NOT PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

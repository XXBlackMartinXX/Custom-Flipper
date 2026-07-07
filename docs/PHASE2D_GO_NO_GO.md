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

---

## Phase 2D.1 update: pre-import verification result

**Phase 2D.1 classification: `PHASE 2D.1 PRE-IMPORT VERIFICATION PASS`.**
See `docs/PHASE2D_1_GO_NO_GO.md`, `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`,
and `docs/PHASE2D_1_IMPORT_READINESS_MATRIX.md` for full detail.

Real, direct network access to the actual upstream RogueMaster source
(commit `472f6925e8aca9bd031cb37e3cb80b551772c957`, the same commit every
prior audit in this project has cited, confirmed with no discrepancy)
resolved the license-evidence gap this document originally flagged for
all 3 recommended apps — this time with a fully clean result:

- **`resistors`**: **CONFIRMED — MIT**, real `LICENSE` file read directly
  from the vendored source. The bundled-asset-provenance question this
  document flagged is resolved by scope: the actual build inputs
  (`resistors.png`, `images/`) are small, original icon assets with no
  provenance concern; the ~2.3MB of non-build-input upstream directories
  that do carry an unclear-provenance question (two photographic
  reference images under `design/`) are excluded from the import scope
  entirely, the same strategy already used for `fcc_id_lookup`'s database
  in Phase 2C.1. Cleared for import with this narrowed scope.
- **`crypto_dictionary`**: **CONFIRMED — GPLv3**, real `LICENSE` file read
  directly from the vendored source. The glossary-provenance question is
  resolved favorably: the bundled reference text is original,
  non-copyrightable technical content in a distinctive personal style, and
  a full keyword scan (including this phase's new
  `seed`/`wallet`/`private key`/`secret` terms) found zero matches
  anywhere, including inside the glossary text. Directly confirmed
  read-only, no cryptographic operations on user data, no
  credential/secret handling of any kind. Cleared for import, no
  conditions beyond standard GPLv3 attribution.
- **`2048`**: **CONFIRMED — MIT**, real `LICENSE` file read directly from
  the vendored source. Storage behavior confirmed app-scoped
  (`/ext/apps_data/game_2048/`), with a real, directly-observed nuance
  (hardcoded literal path rather than the idiomatic appid-based macro,
  plus a one-time legacy-path migration check) that does not change its
  clearance but must be documented precisely. Cleared for import.

**The original 3-app batch remains fully valid — no reduction, no
substitution.** This is a materially different, cleaner outcome than
Phase 2C.1 (where `fcc_id_lookup` was elevated to DEFER on a genuine
license-evidence gap): all 3 apps in this batch had a real, readable
`LICENSE` file present directly in the exact artifact this project would
import, and none exhibited a hardware-capability, safety, or
secret-handling concern.

This document's original "GO WITH CONDITIONS" recommendation and its
numbered conditions list above are **now satisfied for condition #3**
(the license-read condition — confirmed for all 3 apps) and condition #4
(`2048`'s and `resistors`'s exact storage/behavior confirmed directly from
real source, per above) — condition #1 (the project owner's own explicit
request is still required to start implementation) remains exactly as
written; this verification pass satisfies condition #2 for all 3 apps
(fresh source was read for all 3) and condition #3/#4 in full, but does
not itself constitute condition #1.

**No app code was imported in Phase 2D.1.** Hardware flashing/testing
remains **NOT PERFORMED**. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**. `fcc_id_lookup` remains deferred, unresolved, and
untouched by this phase — not re-reviewed, not reconsidered, exactly as
instructed.

# Phase 2E — Go / No-Go

Docs only. Planning only. This is the closing decision document for the
Phase 2E planning package — it recommends a path, it does not take it.

## Final recommendation: **GO WITH CONDITIONS**

Phase 2E **planning** (this package) is complete and finds a genuinely
small, low-risk tiny batch worth recommending for a *future* implementation
phase. Phase 2E **implementation/import** is not started by this
recommendation — it requires the project owner's own separate, explicit
request, and even then only after Phase 2E.1 (pre-import source/license
verification) separately passes.

This recommendation is "with conditions" rather than a plain "GO" for the
same reason every prior planning phase in this project has been
conditional: no per-app `LICENSE` file has actually been read for any of
the 3 recommended apps in this phase (that verification is explicitly
deferred to Phase 2E.1), and one of the three carries a specific, named
follow-up item (`image_viewer`'s 3 bundled example bitmap files' own
provenance) worth flagging explicitly rather than waving through.

## Exact tiny batch recommended

From `docs/PHASE2E_RECOMMENDED_BATCH.md`, in this import order:

1. `image_viewer` (Media) — LOW risk, the simplest build surface of any
   app recommended in this project's history (1 file), described as
   read-only per existing citation
2. `boilerplate` (Tools/Educational) — LOW risk, app-private
   demonstration save file (the same pattern already proven safe by
   `chess`/`sudoku`/`2048`), real standing value as this project's own
   dev-tool template
3. `minesweeper` (Games) — LOW risk, app-private save/config via a
   dedicated storage helper, rounds out the Games category with a fourth
   distinct title

All 3 were confirmed by the existing Phase 1.6 source audit to have zero
matches against every hardware-capability class this project screens for
(Sub-GHz, NFC/RFID/iButton, BadUSB/HID, BLE, GPIO, Infrared transmit).

## Apps explicitly deferred

- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — hard-excluded per this phase's explicit
  instructions, unchanged from their prior-phase status. Not re-reviewed.
- **`fcc_id_lookup`** — **remains deferred**, unchanged from Phase 2C.1's
  finding (no `LICENSE` file in the RogueMaster-vendored copy). Not
  re-reviewed, not included in Phase 2E planning, not resolved by this
  package. Its resolution requires a separate, narrow license-follow-up
  phase, per the project owner's own explicit instruction.
- **`hex_viewer`, `qrcode`, `barcode_gen`** — remain in the clean
  candidate pool (see `docs/PHASE2E_CANDIDATE_REVIEW.md`) for a
  subsequent batch; not selected for this specific tiny slice because
  their existing storage-behavior descriptions do not explicitly rule out
  a write, and this project's own Phase 2C.1 experience with `sd_info`
  (assumed zero-storage, found to write) is the specific reason that
  ambiguity is treated as a reason to defer to a future batch rather than
  assume read-only behavior now.

## Conditions before implementation

1. **The project owner must explicitly request Phase 2E.1 (pre-import
   verification) start** — this package, on its own, does not authorize
   that, no matter how clean this recommendation reads.
2. **Each of the 3 recommended apps must have its actual source
   (application.fam, `.c`/`.h`/`.cpp` files, and any bundled resources)
   freshly read at Phase 2E.1** — this planning phase's review is a
   citation of the existing Phase 1.6 audit, not a new source read.
3. **Each app's actual license file/header must be read and recorded**
   before its import commit — this planning phase marked all 3 as `NEEDS
   REVIEW` (routine) rather than falsely declaring them license-clear; see
   `docs/PHASE2E_LICENSE_REVIEW.md`. `image_viewer`'s bundled bitmap
   provenance specifically must be confirmed, not just cited.
4. **`image_viewer`'s read-only storage characterization must be
   confirmed directly from real source at Phase 2E.1**, not assumed from
   the Phase 1.6 citation — the same lesson Phase 2C.1 taught with
   `sd_info`. `boilerplate`'s and `minesweeper`'s exact app-private save
   paths must also be confirmed and recorded, the same discipline applied
   to every prior app's own path.
5. **The existing validation pipeline must be reused unmodified** —
   `tools/phase2a_validate.ps1` (with `-ConfigPath` pointed at an updated
   config if the project owner wants one), its reviewed-false-positive
   allowlist mechanism, the GitHub Actions CI workflow pattern, and the
   artifact-hash/tag finalization workflow pattern. No gate may be
   weakened, bypassed, or skipped to accommodate this batch.
6. **One-app-at-a-time, commit-per-app, rebuild-after-each** — per
   `docs/PHASE2E_INTEGRATION_PLAN.md`.
7. **No hardware-connected validation mode is run against a Phase 2E
   commit until that commit reaches a clean Static+Build CI result** —
   same ordering as every prior phase.
8. **`upython`/`iconedit`/`c_book`/`animation_switcher`/`theme_manager`'s
   prior exclusion reasons and `fcc_id_lookup`'s license question remain
   open** and are not resolved by this package; none of those apps may be
   imported under this recommendation regardless of how this 3-app tiny
   batch goes.

## Prompt canaries for Phase 2E implementation

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

**PHASE 2E PLANNING ONLY / NO CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was read, modified, or built in this phase. No
hardware was touched, no hardware-connected validation mode was run.
Hardware flashing/testing remains **NOT PERFORMED**. Release status
remains **TEST-READY ONLY / NOT RELEASE-READY**, unchanged from the
Phase 2D baseline this plan builds on. `fcc_id_lookup` remains deferred,
unresolved, and untouched by this phase.

---

## Phase 2E.1 update: pre-import verification result

**Phase 2E.1 classification: `PHASE 2E.1 PRE-IMPORT VERIFICATION PASS`.**
See `docs/PHASE2E_1_GO_NO_GO.md`, `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`,
and `docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md` for the full, real
verification pass performed against the pinned RogueMaster commit
(`472f6925e8aca9bd031cb37e3cb80b551772c957`).

**All 3 recommended apps are cleared for import**, resolving this
document's own "with conditions" caveat above:

- **`image_viewer`**: MIT license confirmed directly. **Real finding**:
  its bundled `example_images/spongebob.bm` was decoded and visually
  confirmed to depict a recognizable trademarked cartoon character with
  no attribution — resolved by excluding the entire `example_images/`
  directory from the import scope (not required for the app to function).
- **`boilerplate`**: no formal `LICENSE` file exists, but `README.md`
  contains a real, explicit permissive statement, treated as sufficient
  evidence — recorded as a distinct, honest evidence tier, not upgraded
  to "MIT-equivalent." Real appid discrepancy found (`fap_boilerplate`,
  not `boilerplate`).
- **`minesweeper`**: MIT license confirmed directly. Real appid
  discrepancy found (`minesweeper_redux`, not `minesweeper`). No
  conditions beyond routine attribution.

No app was deferred or blocked. The original 3-app batch and its import
order (`image_viewer` → `boilerplate` → `minesweeper`) remain valid,
unchanged. **No code was imported in Phase 2E.1** — it is verification
only. Hardware testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup` remains
deferred, unresolved, and untouched. Next gate: **Phase 2E.2 —
implementation/import of this exact cleared 3-app batch**, on the project
owner's own separate, explicit request only.

# Phase 2F — Go / No-Go

Docs only. Planning only. This is the closing decision document for
Phase 2F planning — recommending whether, and how, a future Phase 2F.1
verification phase should proceed.

## Final recommendation: **GO WITH CONDITIONS**

## Exact tiny batch recommended

All 3 remaining candidates from the original Top 25
(`docs/PHASE1_5_TOP_25_CANDIDATES.md`), per
`docs/PHASE2F_RECOMMENDED_BATCH.md`:

1. `qrcode`
2. `hex_viewer`
3. `barcode_gen`

This is the entire remaining clean candidate pool — recommending all 3
does not pad the batch, since no additional candidate exists in the
Top 25 without either being already imported (16 apps) or hard-deferred
(`fcc_id_lookup`, `upython`, `iconedit`, `c_book`, `animation_switcher`,
`theme_manager`).

## Apps explicitly deferred

- **`fcc_id_lookup`** — unresolved app-local license-evidence gap. Not
  reopened or re-reviewed in this phase, per explicit instruction.
  Requires a separate, narrow license-resolution phase.
- **`upython`** — real GPIO write and Infrared-transmit bindings exposed
  to user scripts (Phase 1.6 finding). Hardware/control capability risk;
  safety-exclusion list.
- **`iconedit`** — literal USB HID keystroke injection via its "send to
  PC" feature (Phase 1.6 finding). Safety-exclusion list.
- **`c_book`** — bundles verbatim copyrighted book chapters (K&R) with no
  confirmed distribution right. Unresolved copyright question.
- **`animation_switcher`** — writes to the shared `/ext/dolphin/`
  directory, not app-private storage.
- **`theme_manager`** — writes to `/ext/dolphin/` (with a confirmed
  backup step), same shared-directory consideration.

None of these 6 is reconsidered by this document. All remain in their
existing deferred/excluded status.

## Conditions before implementation

1. **Phase 2F.1 pre-import source/license verification must pass** for
   each app individually before it is imported — this document does not
   itself clear any app for import.
2. **`hex_viewer`'s storage behavior must be directly confirmed
   read-only** (or, if any write path exists, confirmed to be
   app-private and safe) before import — the single most important
   open condition from this planning phase, per
   `docs/PHASE2F_RISK_REGISTER.md`.
3. **`barcode_gen`'s storage behavior must be directly confirmed** in the
   same way, and its 4 bundled encoding-table files' provenance must be
   confirmed as standard-technical-data transcriptions.
4. **`qrcode` must be directly confirmed** to have no credential-payload
   workflow, access-control use, network behavior, or persistent
   sensitive-payload storage, despite the existing record showing no
   such concern.
5. **All 3 apps' real licenses must be read directly** at Phase 2F.1 —
   none has been confirmed beyond the routine "no license field
   declared" citation in this phase.
6. **A per-app deferral does not block the rest of the batch.** If, say,
   `hex_viewer` is deferred at Phase 2F.1 for an unresolved write path,
   `qrcode` and `barcode_gen` may still proceed (pending their own
   verification), per the per-app stop-condition discipline.

## Prompt canaries for Phase 2F implementation

A future Phase 2F implementation session must treat any of the following
as an immediate stop, exactly as this planning phase itself has:

- If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR, stop
  and mark **DEFER** unless already proven harmless and explicitly
  approved.
- If any app has an unclear license or bundled third-party code/data/
  assets/text without provenance, stop and mark **DEFER**.
- If any app requires hardware testing before basic CI confidence, stop
  and mark **DEFER**.
- If any app requires source changes outside its own app directory, stop
  and mark **NEEDS REVIEW**.
- If any app handles credentials, tokens, passwords, seed phrases,
  private keys, wallets, exfiltration, bypass, cloning, brute force, or
  HID injection, mark **DEFER**.
- If `qrcode` or `barcode_gen` includes access-control, credential
  encoding, scanner emulation, HID/NFC/USB behavior, or persistent
  sensitive payloads, mark **DEFER**.
- Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free.

## Statement

**PHASE 2F PLANNING ONLY / NO CODE IMPORT PERFORMED.**

This document, and every other Phase 2F planning deliverable in this
package, is documentation and planning only. `applications/`,
`applications_user/`, and all firmware/app source remain unmodified.
`integration/phase2f-first-batch` does not exist as of this document.
Hardware remains **NOT PERFORMED**. Release status remains **TEST-READY
ONLY / NOT RELEASE-READY**.

---

## Phase 2F.1 update: pre-import verification result

**Phase 2F.1 classification: `PHASE 2F.1 PRE-IMPORT VERIFICATION PASS`.**
See `docs/PHASE2F_1_GO_NO_GO.md`, `docs/PHASE2F_1_SOURCE_LICENSE_VERIFICATION.md`,
and `docs/PHASE2F_1_IMPORT_READINESS_MATRIX.md` for the full, real
verification pass performed against the pinned RogueMaster commit
(`472f6925e8aca9bd031cb37e3cb80b551772c957`).

**All 3 recommended apps are cleared for import**, resolving this
document's own "with conditions" caveat above:

- **`qrcode`**: MIT license confirmed directly. Bundles a third-party
  MIT-licensed QR-encoding library (Richard Moore/ricmoo, derived from
  Project Nayuki's library), attributed inline — fully compatible, no
  separate concern. Storage confirmed app-private, read-only for QR
  content, with one benign one-time legacy-folder migration at launch
  (the same pattern already accepted for `2048`).
- **`hex_viewer`**: MIT license confirmed directly. **Real finding**:
  the planning-stage storage ambiguity is fully resolved — a direct
  source read confirms the app is genuinely read-only for viewed files
  (`FSAM_READ` only, no write/edit/patch path), with its only write
  behavior confined to its own app-private settings file. The
  special-caution DEFER condition for this app does not trigger.
- **`barcode_gen`**: MIT license confirmed directly. Real appid
  discrepancy found (`barcode_app`, not `barcode_gen`). **Real
  finding**: the 4 bundled encoding-table files were read in full and
  confirmed to be standard, publicly documented technical-specification
  data (not a creative work), correctly declared via `fap_file_assets`.
  Storage confirmed app-private only.

No app was deferred or blocked. The original 3-app batch and its import
order (`qrcode` → `hex_viewer` → `barcode_gen`) remain valid, unchanged.
**No code was imported in Phase 2F.1** — it is verification only.
Hardware testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**. `fcc_id_lookup` remains
deferred, unresolved, and untouched. Next gate: **Phase 2F.2 —
implementation/import of this exact cleared 3-app batch**, on the project
owner's own separate, explicit request only.

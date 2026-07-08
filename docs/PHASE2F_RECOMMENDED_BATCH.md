# Phase 2F — Recommended Batch

Docs only. Planning only. Recommends a tiny batch drawn from the 3-app
candidate pool reviewed in `docs/PHASE2F_CANDIDATE_REVIEW.md`. **No code
is imported by this document.**

## Recommended tiny batch: all 3 remaining candidates

| App | Expected source path | Expected import appid |
|---|---|---|
| `hex_viewer` | `applications/external/hex_viewer/` | `hex_viewer` (not yet confirmed — Phase 2F.1 to verify against the actual `application.fam`, following the exact same discipline that caught `boilerplate`'s real `fap_boilerplate` appid and `minesweeper`'s real `minesweeper_redux` appid in Phase 2E) |
| `qrcode` | `applications/external/qrcode/` | `qrcode` (not yet confirmed) |
| `barcode_gen` | `applications/external/barcode_gen/` | `barcode_gen` (not yet confirmed) |

This is the entire remaining clean candidate pool from the original
Top 25 (`docs/PHASE1_5_TOP_25_CANDIDATES.md`) — recommending all 3 does
not "pad" the batch, since no 4th or later candidate exists in that pool
without either being already imported or hard-deferred.

## Why each app is selected

- **`hex_viewer`**: A genuine developer/diagnostic gap-filler (view
  arbitrary files as hex) with no equivalent already in the accepted
  16-app baseline. Small (20 files), no bundled data, no hardware
  capability identified.
- **`qrcode`**: A broadly useful, mature (v2.1) display utility. The
  smallest and simplest of the 3 (3 files), with the cleanest existing
  audit record of any candidate reviewed in this phase.
- **`barcode_gen`**: A complementary display utility to `qrcode`
  (different code format, same category), whose only bundled data is 4
  standard, publicly documented barcode-symbology lookup tables — an
  open-technical-standard provenance profile, materially different from
  (and lower-risk than) `image_viewer`'s bundled bitmap images.

## Why each app is safe enough for planning

All 3 passed the Phase 1.6 individual source-level audit (`.c`/`.h`
read, not just manifest/README) with **APPROVE** and no safety-keyword
hits, no RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR capability, and no
credential/token/password/bypass/cloning behavior of any kind. Nothing
found in the existing record disqualifies any of the 3 from planning —
the only open questions (below) are storage-behavior precision for
`hex_viewer` and `barcode_gen`, both explicitly named as Phase 2F.1
verification conditions rather than treated as resolved.

## Expected app category

| App | Expected category (`fap_category`) |
|---|---|
| `hex_viewer` | Tools |
| `qrcode` | Tools |
| `barcode_gen` | Tools |

## Expected risk level

| App | Expected risk level |
|---|---|
| `hex_viewer` | LOW-MEDIUM (pending Phase 2F.1 storage confirmation) |
| `qrcode` | LOW |
| `barcode_gen` | LOW-MEDIUM (pending Phase 2F.1 storage confirmation) |

See `docs/PHASE2F_RISK_REGISTER.md` for the full per-app risk breakdown.

## Expected validation difficulty

| App | Expected validation difficulty |
|---|---|
| `hex_viewer` | Low-Medium — largest of the 3 (20 files), but no unusual build dependencies noted |
| `qrcode` | Low — smallest and simplest of the 3 |
| `barcode_gen` | Low-Medium — 16 files plus 4 bundled data files to verify are correctly packaged (`fap_file_assets`) |

## Import order recommendation

1. **`qrcode`** first — lowest file count, cleanest existing audit
   record, no bundled-data packaging step to get right. Establishes the
   updated validator config and CI workflow cleanly before tackling the
   two apps with an open storage question.
2. **`hex_viewer`** second — confirm its real storage behavior (read-only
   vs. any write/edit path) before committing to app-private-storage
   claims in any doc.
3. **`barcode_gen`** third — confirm its bundled encoding-table packaging
   (`fap_file_assets`) and storage behavior last, since it has the most
   moving parts (bundled data + storage ambiguity) of the 3.

This mirrors the established one-app-at-a-time, commit-per-app,
validate-after-each discipline from every prior phase's own integration
plan (`docs/PHASE2E_INTEGRATION_PLAN.md` and earlier).

## App-specific verification conditions for Phase 2F.1

- **`hex_viewer`**: Direct source read of the "2 files [that] touch
  storage APIs" (per `docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`) is required
  to confirm whether this app is purely read-only (viewing) or has any
  write/edit/patch code path. If any write capability is found that
  writes outside an app-private path, or edits/patches the file being
  viewed, re-classify **DEFER** per this phase's own special-caution
  instruction — do not import on the assumption that "viewer" in the
  name guarantees read-only behavior.
- **`qrcode`**: Direct source read to confirm no credential-payload
  workflow, no access-control use case, no network behavior, no
  NFC/HID/USB behavior, and no persistent storage of sensitive payloads.
  The existing record shows none of this, but Phase 2F.1 must confirm it
  directly rather than rely on the Phase 1.6 citation alone.
- **`barcode_gen`**: Direct source read of the "3 files [that] touch
  storage APIs" to confirm they are reading the 4 bundled encoding-table
  files (and/or user-entered text), not writing anywhere unexpected.
  Also confirm the same absence-of-credential-payload/access-control/
  scanner-emulation/HID/NFC/USB/network-behavior conditions as `qrcode`.
  If any of these special-caution conditions are found, re-classify
  **DEFER**.
- **All 3**: Confirm real license status (declared license unknown from
  existing docs for all 3 — see `docs/PHASE2F_LICENSE_REVIEW.md`),
  confirm the real upstream source at whatever commit is current at
  verification time, and confirm no source changes would be required
  outside each app's own directory.

## What this document does not do

This document does not import any code, does not modify
`applications/` or `applications_user/`, and does not start Phase 2F.1
— it only records the recommended batch and the exact conditions that
must be verified before import, per `docs/PHASE2F_NEXT_GATE.md`.

# Phase 2F.1 — Go / No-Go

Docs only. Pre-import verification only. This is the closing decision
document for Phase 2F.1 — it recommends a path, it does not take it.

## Final Phase 2F.1 classification: **PHASE 2F.1 PRE-IMPORT VERIFICATION PASS**

All 3 apps in the Phase 2F recommended tiny batch (`qrcode`,
`hex_viewer`, `barcode_gen`) are **cleared for import**. This is a clean
pass, not a NEEDS REVIEW or partial one — no app in this batch carries an
unresolved license gap that blocks import, an undisclosed hardware
capability, a credential/secret-handling concern, or copied commercial
content without rights. The two named open questions from Phase 2F
planning (`hex_viewer`'s and `barcode_gen`'s ambiguous "touches storage
APIs" citations) have both been directly resolved by reading the actual
source — both apps confirmed app-private-only, with `hex_viewer`
additionally confirmed genuinely read-only for the files it views.

## Apps cleared for implementation

1. **`qrcode`** (Tools) — MIT license confirmed directly in the vendored
   source (full, unmodified text, Bob Matcuk, 2022). Zero real
   safety/API-capability hits. **Real finding, not a blocker**: bundles a
   third-party MIT-licensed QR-encoding library (Richard Moore/ricmoo,
   derived from Project Nayuki's library), attributed inline in the
   file's own header and independently corroborated by the app's own
   README — the same library historically vendored in base
   `flipperzero-firmware`'s own `lib/` directory. Storage confirmed
   app-private (`/ext/apps_data/qrcodes/`), read-only for QR content,
   with one benign one-time legacy-folder migration at launch (the same
   pattern already accepted for `2048` in Phase 2D).
2. **`hex_viewer`** (Tools) — MIT license confirmed directly in the
   vendored source (full, unmodified text, Roman Shchekin, 2022). Zero
   safety/API-capability hits of any kind, including false positives.
   **The single most important finding of this phase**: Phase 2F
   planning's open storage-behavior question is now **fully resolved** —
   a direct read of `helpers/hex_viewer_storage.c` confirms the app opens
   user-selected files with `FSAM_READ`/`FSOM_OPEN_EXISTING` only, with
   no write, edit, patch, overwrite, or delete call touching the viewed
   file anywhere in the source. Its only storage write is its own
   app-private settings file (`/ext/apps_data/hex_viewer/hex_viewer.conf`,
   4 boolean toggles). The special-caution DEFER condition for this app
   does not trigger.
3. **`barcode_gen`** (Tools) — MIT license confirmed directly in the
   vendored source (full, unmodified text, Alan Tsui, 2023). Real appid
   discrepancy found: the manifest declares `barcode_app`, not
   `barcode_gen` — the same class of directory-name-vs-appid mismatch
   already seen for `boilerplate`/`minesweeper` in Phase 2E, harmless.
   Zero real safety/API-capability hits (2 benign `@author`/`author:`
   false positives on "auth"). **Real finding, not a blocker**: the 4
   bundled encoding-table `.txt` files were read in full and confirmed to
   contain nothing but standard, publicly documented barcode-symbology
   character-to-bar-pattern data (Code 39/128/128C/Codabar) — a
   technical-specification fact table, not a creative work, correctly
   declared via `fap_file_assets`. Storage confirmed app-private only
   (`/ext/apps_data/barcodes/`), with the bundled tables accessed
   read-only via the standard `APP_ASSETS_PATH` mechanism.

## Apps deferred/blocked and why

**None.** All 3 apps in the recommended batch passed verification with
no deferral or block. `fcc_id_lookup`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, `theme_manager` remain untouched, unreviewed, and
excluded, per this phase's explicit hard exclusions — not re-evaluated
here.

## Whether the original 3-app batch remains valid

**Yes, unchanged.** All 3 apps cleared; no substitution, no reduction,
and no expansion is needed or was made.

## Whether batch size must shrink

**No.** The batch remains the full 3 apps: `qrcode`, `hex_viewer`,
`barcode_gen`.

## Exact next allowed gate

**Phase 2F.2 — implementation/import of the exact cleared 3-app batch**,
following `docs/PHASE2F_INTEGRATION_PLAN.md`'s one-app-at-a-time,
commit-per-app, validate-after-each discipline, in the recommended import
order (`qrcode` → `hex_viewer` → `barcode_gen`) — **only on the project
owner's own explicit further request.** This document does not start
Phase 2F.2. Hardware-assisted validation and release-readiness both
remain blocked regardless, until real hardware validation is actually
complete and explicitly accepted.

## Boundaries honored

No app code was imported in this phase. `applications/` and
`applications_user/` remain unmodified. No firmware/app source was
touched. No hardware was flashed. `image_viewer/example_images/` was not
touched and remains excluded. `fcc_id_lookup` was not reopened or
re-reviewed. Release status remains **TEST-READY ONLY / NOT
RELEASE-READY**.

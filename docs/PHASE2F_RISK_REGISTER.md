# Phase 2F — Risk Register

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2F_RECOMMENDED_BATCH.md`. Risk classes are assigned on the
existing Phase 1.6 audit record — real, direct source verification at
Phase 2F.1 may adjust any of these, per the stop-condition discipline
below.

## `hex_viewer`

| Field | Value |
|---|---|
| **Risk class** | **LOW-MEDIUM** (pending Phase 2F.1 storage confirmation) |
| Safety risks | None identified in the Phase 1.6 source audit — no RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR capability, no credential/token/password handling. |
| Build risks | Low — 20 files across `helpers/`, `views/`, `scenes/`, no unusual build dependencies noted. Largest of the 3 candidates, but well within the size range of every prior phase's own successfully-imported apps. |
| Dependency risks | None declared per Phase 1.5/1.6. |
| Storage risks | **The single named risk for this app.** Phase 1.6 records "2 files touch storage APIs" without confirming read-only vs. read/write. If those files include any write, edit, or patch code path against the file being viewed (or anywhere outside an app-private path), this is a real, not merely theoretical, storage risk — the exact class of finding Phase 2C.1 produced for `sd_info`, whose planning-stage "zero-storage" assumption turned out to be wrong. |
| Licensing risks | Unconfirmed — `application.fam` declares no license field (routine gap, same as every other candidate at this stage). See `docs/PHASE2F_LICENSE_REVIEW.md`. |
| UI/runtime risks | None identified — a file-browser-driven viewer app, the same UI pattern as `docviewlite` and `image_viewer`, both already accepted without incident. |
| Likely false-positive keywords | Possible `read`/`write`/`open`/`file` substring hits in the static validator's keyword scan (benign — these are the app's own literal storage-API calls, not the safety-exclusion-list categories); possible `hex` substring interactions with no safety relevance. |
| Exact mitigation | Phase 2F.1 must read the actual 2 files that touch storage APIs directly, quote the exact API calls found, and record a definitive read-only-or-not-and-why-safe determination before any import decision. |
| Stop conditions | If any write path is found writing outside an app-private path, or if the app can modify (not just display) the file it opens, re-classify **DEFER** immediately — do not import. |

## `qrcode`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified in the Phase 1.6 source audit — no RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR capability, no credential/token/password handling, no access-control use case. |
| Build risks | Minimal — 3 files, the smallest and simplest of the 3 candidates. |
| Dependency risks | None declared per Phase 1.5/1.6. |
| Storage risks | Minimal — Phase 1.6 records storage as "Local" with no ambiguity flag (unlike `hex_viewer`/`barcode_gen`). Still to be directly confirmed at Phase 2F.1, not assumed. |
| Licensing risks | Unconfirmed — `application.fam` declares no license field (routine gap). See `docs/PHASE2F_LICENSE_REVIEW.md`. |
| UI/runtime risks | None identified — a display-only utility (renders a QR code from user-entered text/data). |
| Likely false-positive keywords | Possible `code` substring interactions (benign — "QR code" is the app's own name/purpose, not a safety-exclusion-list category). |
| Exact mitigation | Phase 2F.1 direct source read to confirm no credential-payload encoding workflow, no network behavior, and no persistent storage of sensitive payloads, per this project's special-caution instruction for QR-code apps specifically. |
| Stop conditions | If the app includes any credential-payload workflow, access-control use, network behavior, NFC/HID/USB behavior, scanner-emulation, or persistent sensitive-payload storage, re-classify **DEFER** immediately. |

## `barcode_gen`

| Field | Value |
|---|---|
| **Risk class** | **LOW-MEDIUM** (pending Phase 2F.1 storage confirmation) |
| Safety risks | None identified in the Phase 1.6 source audit — no RF/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR capability, no credential/token/password handling, no access-control use case. |
| Build risks | Low-Medium — 16 files plus 4 bundled encoding-table `.txt` data files that must be correctly packaged via `fap_file_assets` (the same manifest mechanism `image_viewer`'s exclusion touched in Phase 2E, and `crypto_dictionary`'s bundled glossary files used cleanly in Phase 2D). |
| Dependency risks | None declared beyond the 4 bundled data files themselves. |
| Storage risks | Phase 1.6 records "3 files touch storage APIs" (reading bundled tables + user text) without an explicit read-only confirmation — the same class of ambiguity as `hex_viewer`, though the "bundled tables + user text" framing suggests read-oriented use more strongly than `hex_viewer`'s note does. |
| Licensing risks | Unconfirmed for the wrapper app — `application.fam` declares no license field (routine gap). **Additional, lower-severity question**: the 4 bundled encoding-table files (Code39/128/128C/Codabar) are standard, publicly documented barcode-symbology lookup tables — an open-technical-standard provenance profile, not a creative work, but their exact source/authorship within this specific app has not been directly confirmed. See `docs/PHASE2F_LICENSE_REVIEW.md`. |
| UI/runtime risks | None identified — a display-only utility (renders a barcode from user-entered text using a selected symbology). |
| Likely false-positive keywords | Possible `code`/`scan` substring interactions (benign — "barcode" and encoding-table references, not the safety-exclusion-list "scanner-emulation" concept, which refers to acting as a hardware scanner/reader, not displaying a barcode). |
| Exact mitigation | Phase 2F.1 must read the actual 3 files that touch storage APIs directly, confirm they only read the bundled tables/user text (not write anywhere unexpected), and confirm the 4 bundled `.txt` files are correctly declared in `fap_file_assets` if imported. |
| Stop conditions | If any write path is found writing outside an app-private path, or if the app includes any credential-payload workflow, access-control use, scanner-emulation, HID/NFC/USB behavior, network behavior, or persistent sensitive-payload storage, re-classify **DEFER** immediately. |

## Cross-cutting stop conditions (apply to all 3 apps)

- If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR, stop
  and mark **DEFER** unless already proven harmless and explicitly
  approved — none of the 3 currently shows this, but Phase 2F.1 must
  re-confirm directly.
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
- If evidence is missing at Phase 2F.1, write **NEEDS REVIEW** instead of
  guessing — the same discipline this planning document itself follows.

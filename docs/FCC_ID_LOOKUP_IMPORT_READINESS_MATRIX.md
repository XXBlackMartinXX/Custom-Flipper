# FCC ID Lookup — Import Readiness Matrix

Docs only. Planning only. **NO CODE IMPORT PERFORMED.** Single-app
matrix, mirroring the format of every prior phase's own
`PHASEX_1_IMPORT_READINESS_MATRIX.md`.

| Field | Value |
|---|---|
| **App** | `fcc_id_lookup` |
| **Source path** | `applications/external/fcc_id_lookup/` (RogueMaster/flipperzero-firmware-wPlugins, commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) |
| **appid** | `fcc_id_lookup` |
| **Expected FAP** | `fcc_id_lookup.fap` |
| **Declared license** | None app-local. Upstream: MIT (Copyright (c) 2026 lsr, `github.com/lrehmann/fcc-id-lookup-flipper`) |
| **License confidence** | **RESOLVED** — commit-pinned via source-content dependency chain (see `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`), conditioned on including the upstream `LICENSE` file at actual import time |
| **Bundled data/assets status** | Clean. Only a 96-byte icon (`fcc_id_lookup_icon.png`, valid 10×10 1-bit PNG) and a 1,719-byte compile-time QR-code bitmap (`fcc_qr_code.h`, author-generated). No third-party content bundled. |
| **Optional external database status** | Not bundled, not committed anywhere. A ~8.9 MB FCC frequency/applicant database is a separate, optional, user-initiated download (per the app's own `README.md` and a source-enforced fallback hint if absent) — this project would never ship it even if the app were imported. |
| **Safety status** | **CLEAR.** Zero high-confidence unsafe API/capability keyword matches (no RF/Sub-GHz, NFC, RFID, iButton, BadUSB, HID, GPIO write, IR transmit, credential, exfil, brute, jam, deauth). 11 generic-keyword substring matches, all reviewed and confirmed benign ("available", a data-decompression token table). No network/HTTP behavior — all URL strings are display-only. |
| **Storage status** | **CLEAR — read-only, app-scoped.** All 11 storage-related call sites are read/open/close/free lifecycle operations; the single `storage_file_open` call uses `FSAM_READ`/`FSOM_OPEN_EXISTING` only. Zero write-capable calls anywhere. Database path (`APP_ASSETS_PATH("fcc_freq_v2.bin")`) resolves to an app-scoped `/ext/apps_assets/fcc_id_lookup/` location, not shared or root-level. |
| **Dependency status** | **CLEAR — minimal, standard-only.** Flipper SDK GUI/input/storage headers plus standard C library headers only. Zero third-party libraries, zero submodules, zero unusual dependencies. |
| **Build risk** | **LOW.** Valid, parseable `application.fam`; valid entry-point function matching the standard signature; valid icon; single 1,414-line source file with no unusual compiler constructs observed. The one untested factor — an actual compile pass — can only be confirmed by a real CI build at future import time, not from source review alone. |
| **Import readiness** | **CLEARED FOR FUTURE IMPORT PLANNING** — not itself an import approval; see `docs/FCC_ID_LOOKUP_GO_NO_GO.md` for exact conditions before implementation. |
| **Required attribution** | (1) Confirmed upstream MIT `LICENSE` file included at import time; (2) a `THIRD_PARTY_NOTICES.md`-equivalent entry naming `lrehmann/fcc-id-lookup-flipper` and its MIT license, explicitly noting the database is not bundled; (3) existing `fap_author`/`fap_weburl` fields preserved unchanged. |
| **Notes** | No `appid` or FAP-name conflict with any of the 19 already-imported apps or the base Unleashed app set. Directory name and `appid` match exactly (`fcc_id_lookup` = `fcc_id_lookup`), unlike `boilerplate`/`fap_boilerplate` or `barcode_gen`/`barcode_app` in the current baseline — no naming discrepancy to document at import time. |

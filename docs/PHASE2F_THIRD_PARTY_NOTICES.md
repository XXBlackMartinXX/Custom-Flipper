# Phase 2F — Third-Party Notices

Docs only. This is the Phase 2F counterpart to
`docs/THIRD_PARTY_NOTICES.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md`,
`docs/PHASE2C_THIRD_PARTY_NOTICES.md`, `docs/PHASE2D_THIRD_PARTY_NOTICES.md`,
and `docs/PHASE2E_THIRD_PARTY_NOTICES.md`: it lists the individually-authored,
individually-licensed apps imported into `applications_user/` as part of
Phase 2F, each preserving its own author's copyright and license terms.
The full, authoritative license/attribution evidence for each app remains
in that app's own imported directory — this document is an index and
summary, not a substitute for reading those files directly.

## Apps

### `qrcode`

| Field | Value |
|---|---|
| App name | QR Code |
| appid | `qrcode` |
| Author | Bob Matcuk |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/bmatcuk/flipperzero-qrcode`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/qrcode/` |
| Imported to | `applications_user/qrcode/` |
| Full license text | `applications_user/qrcode/LICENSE` (copied verbatim) |
| **Bundled third-party code** | `qrcode.c`/`qrcode.h` — a QR-encoding library by Richard Moore (ricmoo), derived from Project Nayuki's QR-code-generator library. Both MIT-licensed, both copyright notices preserved in the file's own header. The same library historically vendored in base `flipperzero-firmware`'s own `lib/` directory (per the app's own README). |
| Excluded content | `ss1.png`, `ss2.png` (README screenshot images) — not referenced by `application.fam` or source, excluded for cleanliness only. |

### `hex_viewer`

| Field | Value |
|---|---|
| App name | HEX Viewer |
| appid | `hex_viewer` |
| Author | Roman Shchekin (QtRoS) |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/hex_viewer/` |
| Imported to | `applications_user/hex_viewer/` |
| Full license text | `applications_user/hex_viewer/LICENSE` (copied verbatim) |
| Bundled content | None — the entire imported tree is the author's own implementation. |
| Excluded content | `img/1.png`, `img/2.png` (README screenshot images) — not referenced by `application.fam` or source, excluded for cleanliness only. |

### `barcode_gen`

| Field | Value |
|---|---|
| App name | Barcode App |
| appid | `barcode_app` (not `barcode_gen` — the directory-name assumption used since Phase 1) |
| Author | Kingal1337 (Alan Tsui) |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/Kingal1337/flipper-barcode-generator`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/barcode_gen/` |
| Imported to | `applications_user/barcode_gen/` |
| Full license text | `applications_user/barcode_gen/LICENSE` (copied verbatim) |
| Additional credits (per the app's own README) | Z0wl — added Code128-C support; @teeebor — menu code snippet; thevan4 — added custom keyboard |
| **Bundled third-party data** | 4 encoding-table `.txt` files (`code39_encodings.txt`, `code128_encodings.txt`, `code128c_encodings.txt`, `codabar_encodings.txt`) under `barcode_encoding_files/`, correctly declared via `fap_file_assets`. These contain standard, publicly documented barcode-symbology character-to-bar-pattern lookup tables (technical specification data dictated by the published symbology standards themselves), not a creative work — no separate attribution beyond the app's own MIT license is required. |
| Excluded content | `img/`, `screenshots/` (two duplicate sets of README illustration images) — not referenced by `application.fam` or source, excluded for cleanliness only. |

## Not part of this batch

`fcc_id_lookup` remains deferred (unresolved license-evidence gap, see
`docs/KNOWN_ISSUES.md`) and is not listed here. `upython`, `iconedit`,
`c_book`, `animation_switcher`, and `theme_manager` were not imported or
re-reviewed in this phase.

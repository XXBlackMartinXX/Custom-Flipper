# Phase 2F.2 — License Attribution

Docs only. Records the real license evidence and attribution actions
taken for the 3 apps actually imported in this phase, building directly
on the real source read already performed in Phase 2F.1
(`docs/PHASE2F_1_SOURCE_LICENSE_VERIFICATION.md`) and re-confirmed
byte-for-byte in this phase before any commit was made.

## `qrcode` — MIT (wrapper) + MIT (bundled third-party library)

| Field | Value |
|---|---|
| Declared license (wrapper) | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/qrcode/LICENSE` |
| Copyright holder (wrapper) | Bob Matcuk (2022) |
| Author (`fap_author`) | Bob Matcuk |
| Source repository | `https://github.com/bmatcuk/flipperzero-qrcode` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork, the pinned commit this whole project cites) |
| Source path (upstream) | `applications/external/qrcode/` |
| Local imported path | `applications_user/qrcode/` |
| Import commit | `79f50cc` |

**MIT compatibility**: permissive, GPLv3-compatible (on the FSF's own
compatible-license list) — the same reasoning already applied to every
other MIT-licensed app in this project.

**Bundled third-party code — real finding**: `qrcode.c`/`qrcode.h` is a
third-party QR-encoding library, not the wrapper author's own algorithm.

| Field | Value |
|---|---|
| Declared license (bundled library) | **MIT License** |
| Evidence | In-file header at the top of `qrcode.c`/`qrcode.h`, preserved verbatim |
| Copyright holders | Richard Moore (2017, https://github.com/ricmoo/QRCode); Project Nayuki (2017, https://www.nayuki.io/page/qr-code-generator-library) |
| Corroborating evidence | The wrapper app's own `README.md`: "This application uses the [QRCode] library by ricmoo. This is the same library that is in the lib directory of the flipper-firmware repo... but modified slightly to fix some compiler errors and allow the explicit selection of the qrcode mode." |

**Attribution action taken**: the full, unmodified `LICENSE` file (Bob
Matcuk) was preserved verbatim at `applications_user/qrcode/LICENSE`.
The bundled `qrcode.c`/`qrcode.h` files' own in-file MIT copyright header
(Richard Moore/Project Nayuki) was preserved unmodified — both
attributions are satisfied without needing a separate third-party
`NOTICE` file, since MIT only requires the copyright/permission notice
to remain with the software. An entry has also been added to
`docs/PHASE2F_THIRD_PARTY_NOTICES.md` recording both the wrapper author
and the bundled library's authors for quick reference.

**Excluded content**: `ss1.png`/`ss2.png` (README screenshot images,
not referenced by `application.fam` or source) excluded for cleanliness
only — not a provenance concern, not required for the app to build or
function.

## `hex_viewer` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/hex_viewer/LICENSE` |
| Copyright holder | Roman Shchekin (2022) |
| Author (`fap_author`) | QtRoS |
| Source repository | RogueMaster fork (no separate individual upstream repository URL declared in `application.fam`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path (upstream) | `applications/external/hex_viewer/` |
| Local imported path | `applications_user/hex_viewer/` |
| Import commit | `04715de` |

**MIT compatibility**: permissive, GPLv3-compatible, same reasoning as
`qrcode` above.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/hex_viewer/LICENSE`. An entry
has also been added to `docs/PHASE2F_THIRD_PARTY_NOTICES.md`.

**Bundled third-party code/data**: none identified. All 20 files are the
author's own implementation, confirmed by direct read of every file in
Phase 2F.1 and re-confirmed at import time.

**Excluded content**: `img/1.png`, `img/2.png` (README screenshot
images, not referenced by `application.fam` or source) excluded for
cleanliness only.

## `barcode_gen` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/barcode_gen/LICENSE` |
| Copyright holder | Alan Tsui (2023) |
| Author (`fap_author`) | Kingal1337 (the real name behind this GitHub handle is the LICENSE's own copyright holder, Alan Tsui — the same "real name in copyright, handle in `fap_author`" pattern already seen for `minesweeper`/squee72564 in Phase 2E) |
| Source repository | `https://github.com/Kingal1337/flipper-barcode-generator` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path (upstream) | `applications/external/barcode_gen/` |
| Local imported path | `applications_user/barcode_gen/` |
| Import commit | `2512644` |

**MIT compatibility**: permissive, GPLv3-compatible, same reasoning as
`qrcode`/`hex_viewer` above.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/barcode_gen/LICENSE`. An entry
has also been added to `docs/PHASE2F_THIRD_PARTY_NOTICES.md`, including
the README's own additional credits (Z0wl — Code128-C support; @teeebor
— menu code snippet; thevan4 — custom keyboard).

**Real appid discrepancy, recorded precisely**: the manifest declares
`appid="barcode_app"`, not `barcode_gen` (the directory-name assumption
used since Phase 1). This does not affect license status — noted here so
a reader cross-referencing older planning docs isn't misled.

**Encoding-table provenance note**: the 4 bundled encoding-table files
(`code39_encodings.txt`, `code128_encodings.txt`,
`code128c_encodings.txt`, `codabar_encodings.txt`) were preserved
unmodified under `barcode_encoding_files/`, correctly declared via
`fap_file_assets`. These files contain nothing but standard, publicly
documented barcode-symbology character-to-bar-pattern lookup tables —
technical specification data (the character-to-bar-pattern mapping is
dictated by the published symbology standard itself), not a creative
work requiring separate attribution beyond the app's own top-level MIT
license.

**Excluded content**: `img/` and `screenshots/` (two duplicate sets of
README illustration images, not referenced by `application.fam` or
source) excluded for cleanliness only.

## Bundled third-party code/data/assets/table status summary

| App | Bundled third-party content | Status |
|---|---|---|
| `qrcode` | MIT QR-encoding library (Richard Moore/ricmoo, Project Nayuki) | Preserved with in-file attribution intact |
| `hex_viewer` | None | N/A |
| `barcode_gen` | 4 standard technical-data encoding tables | Preserved, correctly declared via `fap_file_assets`, non-copyrightable factual data |

## Summary

| App | License | Evidence tier | Bundled third-party content |
|---|---|---|---|
| `qrcode` | MIT (wrapper) + MIT (bundled library) | High (formal `LICENSE` file + in-file header) | Bundled MIT QR-encoding library, attributed |
| `hex_viewer` | MIT | High (formal `LICENSE` file) | None |
| `barcode_gen` | MIT | High (formal `LICENSE` file) | 4 standard technical-data encoding tables |

See `docs/PHASE2F_THIRD_PARTY_NOTICES.md` for the consolidated,
quick-reference notice entries.

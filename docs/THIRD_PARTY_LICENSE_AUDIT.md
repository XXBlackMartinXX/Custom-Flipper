# Third-Party License Audit — Full 20-App Consolidation

Docs-only. Consolidates license, provenance, and attribution evidence
for all 20 imported apps plus the 6 deferred/excluded candidates, drawn
from each phase's own `LICENSE_ATTRIBUTION.md`/`THIRD_PARTY_NOTICES.md`/
`LICENSE_REVIEW.md` documents and direct inspection of each app's
`LICENSE`/`README.md`. All 20 apps trace to vendored source repository
`RogueMaster/flipperzero-firmware-wPlugins` at pinned commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`.

## Per-app license table

| App | License | Copyright holder | Original upstream repo | Evidence source doc(s) |
|---|---|---|---|---|
| `network_subnet` | Not found — no LICENSE file; attribution via `fap_author`/README only | — | `aaumkar/network_subnet` | `docs/PHASE2A_INTEGRATION_LOG.md` |
| `programmer_calc` | GPLv3 | (FSF standard, no individual name in-file) | `armixz/Flipper-Zero-Programmer-Calculator` | `docs/PHASE2A_INTEGRATION_LOG.md` |
| `vin_decoder` | GPLv3 | (FSF standard, no individual name in-file) | `evillero/vin_decoder` | `docs/PHASE2A_INTEGRATION_LOG.md` |
| `flipper95` | Not found — no LICENSE file; attribution via `fap_author`/README only | — | `CookiePLMonster/flipper-bakery` | `docs/PHASE2A_INTEGRATION_LOG.md` |
| `chess` | MIT (game/UI); CC0 (bundled `smallchesslib`) | Struan Clark (2023) | `xtruan/flipper-chess` | `docs/PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` |
| `flipfetch` | MIT | Ismael A. Rodríguez (2026) | `alexroses47/flipper-flipfetch` | `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md` |
| `quadratic_solver` | MIT | paul-sopin (2025) | `paul-sopin/flipper-quadratic-solver` | `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md` |
| `sudoku` | MIT | @profelis (2023) | `profelis/fz-sudoku` | `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md` |
| `sd_info` | GPLv3 (full 674-line FSF text) | (FSF standard) | `Sladkisnovraper/SD-Info-For-Flipper-Zero` | `docs/PHASE2C_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2C_THIRD_PARTY_NOTICES.md` |
| `docviewlite` | MIT | C0D3-5T3W (2025-2030) | `C0d3-5t3w/docviewlite` | `docs/PHASE2C_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2C_THIRD_PARTY_NOTICES.md` |
| `resistors` | MIT | Lewis Westbury (2023) | `instantiator/flipper-zero-experimental-apps` (features via `shalebridge` fork) | `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2D_THIRD_PARTY_NOTICES.md` |
| `crypto_dictionary` | GPLv3 (full FSF text) | (FSF standard) | `armixz/Flipper-Zero-Crypto-Dictionary` | `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2D_THIRD_PARTY_NOTICES.md` |
| `2048` | MIT | Eugene Kirzhanov (2022) | No source repo declared; design credit only (not code) to DroomOne/x27 | `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2D_THIRD_PARTY_NOTICES.md` |
| `image_viewer` | MIT | Ivan Polushin (2024) | `polioan/flipper-zero-image-viewer` | `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` |
| `boilerplate` | **Informal permissive grant, no formal LICENSE file** (see quote below) | leedave | `leedave/flipper-zero-fap-boilerplate` | `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` |
| `minesweeper` | MIT | Alexander Rodriguez (2024) | `squee72564/F0_Minesweeper_Fap` | `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` |
| `qrcode` | MIT (wrapper) + MIT (bundled 3rd-party library, see below) | Bob Matcuk (2022, wrapper); Richard Moore/ricmoo (2017) + Project Nayuki (2017) (library) | `bmatcuk/flipperzero-qrcode` | `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2F_THIRD_PARTY_NOTICES.md` |
| `hex_viewer` | MIT | Roman Shchekin/QtRoS (2022) | Not individually declared (RogueMaster fork only) | `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2F_THIRD_PARTY_NOTICES.md` |
| `barcode_gen` | MIT | Alan Tsui (2023, GitHub handle Kingal1337) | `Kingal1337/flipper-barcode-generator` (contributors: Z0wl, @teeebor, thevan4) | `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md`, `docs/PHASE2F_THIRD_PARTY_NOTICES.md` |
| `fcc_id_lookup` | MIT (confirmed at true upstream; not present in the vendored copy — see resolution chain below) | lsr (2026) | `lrehmann/fcc-id-lookup-flipper` | `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`, `docs/FCC_ID_LOOKUP_LICENSE_ATTRIBUTION.md`, `docs/FCC_ID_LOOKUP_THIRD_PARTY_NOTICES.md` |

**License-tier summary**: 12 apps MIT, 4 apps GPLv3, 1 app MIT+CC0
(`chess`), 1 app MIT-wrapper+MIT-library (`qrcode`), 1 app README-only
permissive (`boilerplate`), 2 apps with no LICENSE file found
(`network_subnet`, `flipper95`) — attribution preserved via
`fap_author`/`fap_weburl`/README in both cases, no license type
asserted. None of these is treated as an unresolved gap requiring
action: GPLv3 apps are compatible with the GPLv3-licensed firmware base
they ship alongside, and the two no-LICENSE apps carry the same
attribution discipline (author name, upstream URL preserved unchanged)
this project applies uniformly regardless of license formality.

## Notable evidence, quoted verbatim

### `boilerplate` — README-only permissive statement

From the app's own `README.md` "## Licensing" section:

> "This code is open-source and may be used for whatever you want to do
> with it."

No formal `LICENSE` file exists upstream. Recorded explicitly as a real
but non-SPDX, non-formal evidence tier — not upgraded to "MIT" or any
named license by this project.

### `qrcode` — bundled third-party QR-generation library

`qrcode.c`/`qrcode.h` is not the wrapper author's own algorithm — it is
the QRCode library by Richard Moore (ricmoo, 2017,
`github.com/ricmoo/QRCode`), derived from Project Nayuki's library
(2017, `nayuki.io/page/qr-code-generator-library`). MIT-licensed; the
in-file copyright header is preserved verbatim at the top of
`qrcode.c`/`qrcode.h`. Corroborated by the wrapper's own `README.md`:

> "This application uses the [QRCode] library by ricmoo. This is the
> same library that is in the lib directory of the flipper-firmware
> repo... but modified slightly to fix some compiler errors and allow
> the explicit selection of the qrcode mode."

### `barcode_gen` — encoding-table provenance

The 4 bundled files (`code39_encodings.txt`, `code128_encodings.txt`,
`code128c_encodings.txt`, `codabar_encodings.txt`) contain:

> "standard, publicly documented barcode-symbology character-to-bar-
> pattern lookup tables — technical specification data (the character-
> to-bar-pattern mapping is dictated by the published symbology standard
> itself), not a creative work requiring separate attribution beyond the
> app's own top-level MIT license."

### `fcc_id_lookup` — upstream MIT LICENSE evidence

The vendored copy has no in-repo `LICENSE`, SPDX header, or copyright
notice. The confirmed upstream MIT license (Copyright (c) 2026 lsr) was
tied to the exact vendored revision via a source-content dependency
chain, not calendar-date matching alone: three concrete implementation
features in the vendored `fcc_id_lookup.c` (a `FCC_DB_READ_CACHE_SIZE`
read-cache; corrupt-record bounds-checking comments; the zero-size-
output-guarded `fcc_grantee_prefix()` signature) each map to specific
upstream commits (`3d67e17`, `c3197a9`, `d0d5772`) that post-date the
upstream commit that added the LICENSE file
(`8c49c773eb9b0a399f9e6ede9153372d21056d08`). Conclusion: "the vendored
copy was necessarily pulled from an upstream revision that already
included the MIT LICENSE file." Classified **LICENSE GAP RESOLVED**,
conditioned on including the confirmed upstream LICENSE text at import
time — which was done. The optional ~8.9MB FCC frequency database
(`fcc_freq_v2.bin`) was never bundled; it remains a separate,
user-downloaded asset.

### `image_viewer/example_images` — excluded because of unclear provenance, including `spongebob.bm`

The upstream `example_images/` directory contained 3 bundled `.bm` demo
images: `cat.bm`, `dolphin.bm`, `spongebob.bm`. None were imported. Per
`docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`, each file was
individually decoded and rendered:

> "`spongebob.bm`: the decoded bitmap clearly and unambiguously depicts
> a recognizable cartoon character matching SpongeBob SquarePants — a
> square-bodied face with large round eyes is directly visible in the
> rendered output... SpongeBob SquarePants is a trademarked and
> copyrighted character owned by Paramount/Nickelodeon (Viacom
> International). No license, attribution, or fair-use rationale for
> this specific image exists anywhere in the app's LICENSE, README.md,
> or CHANGELOG.md."

`dolphin.bm` and `cat.bm` were excluded alongside it on the same
unconfirmed-provenance basis (not independently identified as specific
copyrighted characters, but no attribution evidence exists for them
either). The `fap_file_assets = "example_images"` line was removed from
the imported `application.fam` — the only textual edit made to any
upstream file across the whole Phase 2E batch. Confirmed the app does
not require this directory to build or run (it opens whatever file the
user selects at runtime). Confirmed on disk:
`applications_user/image_viewer/example_images/` does not exist.

## Deferred/excluded apps — full license/provenance reasoning

Six candidates from the project's audited Top-25 shortlist
(`docs/PHASE1_5_TOP_25_CANDIDATES.md`, individually source-audited in
`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`, both on the documentation branch)
were considered and never imported (one was later resolved — see below):

- **`fcc_id_lookup`** — originally deferred from Phase 2C.1 through
  Phase 2G for a license-evidence gap (no LICENSE, SPDX, or copyright
  header in the vendored source). **Resolved and imported** via a
  dedicated narrow license-resolution phase — see the evidence chain
  above. No longer deferred; it is the 20th app.
- **`upython`** — excluded for a hardware/control capability risk: real
  `furi_hal_gpio_write`/`furi_hal_gpio_read` and
  `furi_hal_infrared_async_tx_start` (IR transmit) exposed to any
  arbitrary user-authored script, undisclosed in the app's own
  description.
- **`iconedit`** — excluded for a BadUSB/HID injection capability risk:
  `furi_hal_hid_kb_press()`/`furi_hal_hid_kb_release()` used directly to
  type edited-icon data as keystrokes, mechanically identical to a
  BadUSB payload mechanism.
- **`c_book`** — deferred for an unresolved copyright question (full
  detail below).
- **`animation_switcher`** — excluded for a shared/root-level storage
  write: writes to `/ext/dolphin/manifest.txt`, not app-private storage.
- **`theme_manager`** — excluded for the same shared/root-level storage
  write class: writes to `/ext/dolphin/`, with a confirmed
  backup-before-write step.

### `c_book` — the copyrighted-book-content concern

First flagged in `docs/PHASE2B_LICENSE_REVIEW.md`:

> "The bundled content is not code, it is the verbatim (or near-verbatim)
> text of a commercially published, copyrighted book ('The C
> Programming Language' by Kernighan & Ritchie, published by Prentice
> Hall). This is categorically different from bundling an MIT/BSD-
> licensed code library — book text of this kind is not open-source-
> licensed at all... No provenance for a legitimate distribution right
> over the bundled book text has been found or asserted anywhere in the
> Phase 1 material."

Decision: "DEFER, pending a dedicated review, following the exact same
discipline `chess`'s SAM component went through in Phase 2A." Restated
identically as one of the 6 hard-deferred apps through Phase 2G:
"Top-25 source audit only confirmed the app's own code was a 'pure
e-book reader,' not that the bundled content was clear to redistribute."
Phase 2G's stop condition for reconsidering it: "A confirmed
redistribution right for the bundled text is obtained, or the app is
re-scoped to ship without the copyrighted content bundled." **Remains
deferred/blocked** — not resolved, not imported, no redistribution
right has been established.

### Unresolved license gaps

**None for any of the 20 imported apps.** `boilerplate`'s informal
README-only permissive statement and the two no-LICENSE apps
(`network_subnet`, `flipper95`) are disclosed lower-evidence-tier cases,
not gaps requiring further action — each still carries preserved
author/upstream-URL attribution. `c_book` remains outside the imported
set specifically because of its unresolved copyright status, which is
why it was never imported rather than a defect in an imported app.

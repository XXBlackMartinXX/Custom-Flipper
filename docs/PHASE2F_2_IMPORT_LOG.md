# Phase 2F.2 — Import Log

Docs only except for the actual app source (which lives under
`applications_user/`, not here). Records exactly what was imported, from
where, and in what order.

## Branch

`integration/phase2f-first-batch`, created from
`integration/phase2e-first-batch` at commit `fcdbb29` (the final Phase
2F.1 commit).

## Source repository and exact source commit

`RogueMaster/flipperzero-firmware-wPlugins` at
`472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same commit
verified in Phase 2F.1 (`docs/PHASE2F_1_SOURCE_LICENSE_VERIFICATION.md`),
re-fetched fresh via a blobless clone plus cone sparse-checkout for this
implementation phase, with the resulting `git log -1` hash independently
confirmed to match exactly. No discrepancy found.

## App import order

1. `qrcode`
2. `hex_viewer`
3. `barcode_gen`

Exactly the order recommended in `docs/PHASE2F_RECOMMENDED_BATCH.md` and
`docs/PHASE2F_1_GO_NO_GO.md`.

## Per-app import commit, source path, and imported path

| App | Import commit | Upstream source path | Local imported path |
|---|---|---|---|
| `qrcode` | `79f50cc` | `applications/external/qrcode/` | `applications_user/qrcode/` |
| `hex_viewer` | `04715de` | `applications/external/hex_viewer/` | `applications_user/hex_viewer/` |
| `barcode_gen` | `2512644` | `applications/external/barcode_gen/` | `applications_user/barcode_gen/` |

Plus infrastructure commits: `862fd8e` (validator config,
`tools/phase2f_validate_config.json`), `683137d` (CI workflow,
`.github/workflows/phase2f-windows-validation.yml`).

## License preservation

All 3 apps' full, unmodified `LICENSE` files (all MIT) were copied
verbatim into their respective imported directories — no license file
was invented, edited, or omitted. All 3 apps' `README.md` files were
preserved unmodified.

## `qrcode` third-party MIT library attribution

`qrcode.c`/`qrcode.h` (the bundled QR-encoding library by Richard
Moore/ricmoo, derived from Project Nayuki's library) was imported
unmodified from the RogueMaster source, preserving its own in-file MIT
copyright header exactly as found — both the wrapper app's `LICENSE`
(Bob Matcuk) and the bundled library's in-file header (Richard Moore/
Project Nayuki) are preserved, satisfying MIT's attribution requirement
for both. See `docs/PHASE2F_2_LICENSE_ATTRIBUTION.md` for full detail.

## `barcode_gen` encoding-table provenance note

The 4 bundled encoding-table files (`code39_encodings.txt`,
`code128_encodings.txt`, `code128c_encodings.txt`,
`codabar_encodings.txt`) were imported unmodified under
`barcode_encoding_files/`, exactly matching the `fap_file_assets`
declaration in the upstream `application.fam`. These are standard,
publicly documented barcode-symbology character-to-bar-pattern lookup
tables (technical specification data, not a creative work), confirmed
directly in Phase 2F.1.

## Compile fixes

**None required or made.** No file was edited for compilation purposes.
The only content-level changes made at import time were the exclusion of
non-functional README illustration images/screenshots (detailed below),
which is a cleanliness-only removal, not a compile fix, refactor, or
feature change.

## Content excluded at import (cleanliness only, not a provenance concern)

- `qrcode`: `ss1.png`, `ss2.png` (README screenshot images) — not
  referenced by `application.fam` or any source file; confirmed by direct
  grep before removal.
- `hex_viewer`: `img/1.png`, `img/2.png` (README screenshot images) — not
  referenced by `application.fam` or any source file; confirmed by direct
  grep before removal.
- `barcode_gen`: `img/` and `screenshots/` (two duplicate sets of README
  illustration images) — not referenced by `application.fam` or any
  source file; confirmed by direct grep before removal.

None of the above are required for any of the 3 apps to build or
function. No SpongeBob or SpongeBob-like image, and nothing resembling
`image_viewer`'s excluded `example_images/` situation, is present in any
of the 3 — these are plain product-usage screenshots, not bundled example
content with its own provenance question.

## Static scan result

`tools/phase2f_validate_config.json` (19-app superset) was created and a
real static validation pass was run via `tools/phase2a_validate.ps1
-Mode Static` in this session. Result: **91 new risky-keyword substring
matches found in the 3 new apps, all benign "ble"-in-word false
positives** (`variable`, `Table`, `applicable`, `scrollable`, `unable`,
`capable`, `visible`) — reviewed and added to
`tools/phase2f_validate_config.json`'s `reviewedFalsePositives` list with
real file/line/keyword/line-content-SHA-256 evidence. Zero unreviewed
matches, zero high-confidence-unsafe matches, 464 total across the full
19-app batch. See `docs/PHASE2F_2_SAFETY_REVIEW.md` for the full
per-app breakdown.

## Final batch status

All 3 apps imported successfully, one at a time, each in its own commit.
No compile fixes were required. No core firmware (`applications/`) was
touched. Appid uniqueness confirmed across all 19 apps (no collision with
any base-firmware app or any other already-imported app). See
`docs/PHASE2F_2_GO_NO_GO.md` for the final Phase 2F.2 classification,
pending the real CI Build result.

# Phase 2E — Third-Party Notices

Docs only. This is the Phase 2E counterpart to
`docs/THIRD_PARTY_NOTICES.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md`,
`docs/PHASE2C_THIRD_PARTY_NOTICES.md`, and
`docs/PHASE2D_THIRD_PARTY_NOTICES.md`: it lists the individually-authored,
individually-licensed apps imported into `applications_user/` as part of
Phase 2E, each preserving its own author's copyright and license terms.
The full, authoritative license/attribution evidence for each app remains
in that app's own imported directory — this document is an index and
summary, not a substitute for reading those files directly.

## Apps

### `image_viewer`

| Field | Value |
|---|---|
| App name | Image viewer |
| appid | `image_viewer` |
| Author | Ivan Polushin (polioan) |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/polioan/flipper-zero-image-viewer`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/image_viewer/` |
| Imported to | `applications_user/image_viewer/` |
| Full license text | `applications_user/image_viewer/LICENSE` (copied verbatim; SHA-256 `9033a7e2bc385ce398e36f2b9bf4aa190f6a2974ba08b534e567b0b962dc1ee4`) |
| **Excluded content** | **`example_images/` (3 bundled `.bm` demo images: `cat.bm`, `dolphin.bm`, `spongebob.bm`) was NOT imported.** `spongebob.bm` was decoded and visually confirmed in Phase 2E.1 to depict a recognizable trademarked/copyrighted cartoon character (SpongeBob SquarePants) with no attribution or redistribution-rights evidence anywhere in the app. `dolphin.bm`/`cat.bm` are excluded on the same unconfirmed-provenance basis. None of the 3 are required for the app to build or function — its actual code opens whatever file the user selects via the standard file browser, with no hardcoded reference to any bundled filename. The corresponding `fap_file_assets = "example_images"` manifest line was removed. See `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` and `docs/PHASE2E_2_LICENSE_ATTRIBUTION.md` for full detail. |

### `boilerplate`

| Field | Value |
|---|---|
| App name | FAP Boilerplate |
| appid | `fap_boilerplate` (not `boilerplate` — the directory-name assumption used in prior planning docs) |
| Author | leedave |
| License / evidence tier | **No formal `LICENSE` file exists upstream.** `README.md`'s own "## Licensing" section states verbatim: "This code is open-source and may be used for whatever you want to do with it." Recorded as a real but non-formal, non-SPDX evidence tier — not labeled "MIT" or any other named license. |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/leedave/flipper-zero-fap-boilerplate`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/boilerplate/` |
| Imported to | `applications_user/boilerplate/` |
| License evidence location | `applications_user/boilerplate/README.md`, "## Licensing" section (preserved verbatim, no separate `LICENSE` file invented) |
| Bundled content | None — entire tree is the author's own template/demonstration code and icon assets |

### `minesweeper`

| Field | Value |
|---|---|
| App name | Minesweeper Redux |
| appid | `minesweeper_redux` (not `minesweeper` — the directory-name assumption used in prior planning docs) |
| Author | Alexander Rodriguez (squee72564) |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/squee72564/F0_Minesweeper_Fap`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/minesweeper/` |
| Imported to | `applications_user/minesweeper/` |
| Full license text | `applications_user/minesweeper/LICENSE` (copied verbatim; SHA-256 `ca3bfe383b2927db68210582fd1b71032cbc7d7bdfd899af86a5c71db12681ff`) |
| Bundled content | Original, self-authored sprite/icon assets only (8×8 tiles, icon, game-over sprite, start-screen animation) — no third-party attribution required. One third-party header dependency (M\*LIB's `m-deque.h`) already provided by this project's existing `lib/mlib` base-firmware submodule, not a new bundled dependency. |
| Import note | `img/` (screenshots/GIFs) and `docs/changelog.md` excluded for cleanliness only, not referenced by `application.fam`, no provenance concern of their own |

## Not part of this batch

`fcc_id_lookup` remains deferred (unresolved license-evidence gap, see
`docs/KNOWN_ISSUES.md` item 6) and is not listed here. `hex_viewer`,
`qrcode`, `barcode_gen`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, and `theme_manager` were not imported or
re-reviewed in this phase.

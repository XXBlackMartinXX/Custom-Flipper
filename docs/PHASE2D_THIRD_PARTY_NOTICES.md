# Phase 2D — Third-Party Notices

Docs only. This is the Phase 2D counterpart to
`docs/THIRD_PARTY_NOTICES.md`, `docs/PHASE2B_THIRD_PARTY_NOTICES.md`, and
`docs/PHASE2C_THIRD_PARTY_NOTICES.md`: it lists the individually-authored,
individually-licensed apps imported into `applications_user/` as part of
Phase 2D, each preserving its own author's copyright and license terms.
The full, authoritative license text for each app remains in that app's
own `LICENSE` file in its imported directory — this document is an index
and summary, not a substitute for reading those files directly.

## Apps

### `resistors`

| Field | Value |
|---|---|
| App name | Resistance Calculator |
| appid | `resistance_calculator` |
| Author | Lewis Westbury (original); feature additions in v1.4 credited to the `shalebridge` fork |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/instantiator/flipper-zero-experimental-apps`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/resistors/` |
| Imported to | `applications_user/resistors/` |
| Full license text | `applications_user/resistors/LICENSE` (copied verbatim; SHA-256 `bf379221d73cdf51ecc347b5d2cdfd6d9cb0b862848cf7d64241643d22d8224e`) |
| Import note | Imported scope excludes `.flipcorg/`, `design/`, `img/`, `screenshots/` — non-build-input catalog/documentation directories, two of whose files have unclear photographic-reference provenance; see `docs/PHASE2D_2_LICENSE_ATTRIBUTION.md` |

### `crypto_dictionary`

| Field | Value |
|---|---|
| App name | Crypto Dictionary |
| appid | `crypto_dict` |
| Author | armixz |
| License | GPLv3 |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/armixz/Flipper-Zero-Crypto-Dictionary`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/crypto_dictionary/` |
| Imported to | `applications_user/crypto_dictionary/` |
| Full license text | `applications_user/crypto_dictionary/LICENSE` (copied verbatim; SHA-256 `605e9047a563c5c8396ffb18232aa4304ec56586aee537c45064c6fb425e44ad`) |
| Bundled content | 14 original glossary `.txt` reference files under `resources/` (symmetric-cipher specifications) — original authorship, no separate third-party attribution required |

### `2048`

| Field | Value |
|---|---|
| App name | 2048 (Improved) |
| appid | `2048_improved` |
| Author | Eugene Kirzhanov |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/2048/` |
| Imported to | `applications_user/2048/` |
| Full license text | `applications_user/2048/LICENSE` (copied verbatim; SHA-256 `b3fd6903a2acfae0c552d79850dbb65fac262716df402772b6a2e90e6ef5199b`) |
| Import note | Imported scope excludes `images/`, `img/` (gameplay screenshots, not build inputs) |

## Notes

- All original authorship, copyright notices, and license headers in each
  app's own files are preserved unmodified. This project does not claim
  authorship of any app above.
- MIT (`resistors`, `2048`) is on the FSF's own GPL-compatible license
  list. GPLv3 (`crypto_dictionary`) is the same license as this project's
  firmware base — the most direct compatibility case available.
- **`fcc_id_lookup` is deliberately not listed here** — it was not
  imported in this phase. It is deferred pending a license-evidence
  resolution; see `docs/PHASE2C_1_GO_NO_GO.md` and
  `docs/KNOWN_ISSUES.md` item 6. It will be added to this document only
  if and when it is actually imported in a future phase.
- This document will be extended, not replaced, if a future Phase 2D
  batch imports additional apps.

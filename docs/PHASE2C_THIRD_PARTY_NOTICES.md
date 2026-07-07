# Phase 2C — Third-Party Notices

Docs only. This is the Phase 2C counterpart to `docs/THIRD_PARTY_NOTICES.md`
and `docs/PHASE2B_THIRD_PARTY_NOTICES.md`: it lists the individually-
authored, individually-licensed apps imported into `applications_user/`
as part of Phase 2C, each preserving its own author's copyright and
license terms. The full, authoritative license text for each app remains
in that app's own `LICENSE` file in its imported directory — this
document is an index and summary, not a substitute for reading those
files directly.

## Apps

### `sd_info`

| Field | Value |
|---|---|
| App name | SD Info |
| appid | `sd_info` |
| Author | sergo |
| License | GPLv3 |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/Sladkisnovraper/SD-Info-For-Flipper-Zero`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/sd_info/` |
| Imported to | `applications_user/sd_info/` |
| Full license text | `applications_user/sd_info/LICENSE` (copied verbatim; SHA-256 `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`) |

### `docviewlite`

| Field | Value |
|---|---|
| App name | Doc Viewer Lite |
| appid | `docviewlite` |
| Author | C0D3-5T3W |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/C0d3-5t3w/docviewlite`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/docviewlite/` |
| Imported to | `applications_user/docviewlite/` |
| Full license text | `applications_user/docviewlite/LICENSE` (copied verbatim; SHA-256 `61f23cb99a91d229c9d018d9aaff7b9e824cdfa23548a1a9302eda3d5a185e12`) |

## Notes

- All original authorship, copyright notices, and license headers in each
  app's own files are preserved unmodified. This project does not claim
  authorship of either app above.
- Neither app bundles any further third-party code of its own — see
  `docs/PHASE2C_2_LICENSE_ATTRIBUTION.md` for the full reasoning.
- GPLv3 (`sd_info`) is the same license as this project's firmware base —
  the most direct compatibility case available. MIT (`docviewlite`) is
  compatible with inclusion in this project's GPLv3-licensed firmware
  base; see `docs/PHASE2C_2_LICENSE_ATTRIBUTION.md` for the compatibility
  note.
- **`fcc_id_lookup` is deliberately not listed here** — it was not
  imported in this phase. It is deferred pending a license-evidence
  resolution; see `docs/PHASE2C_1_GO_NO_GO.md` and
  `docs/KNOWN_ISSUES.md` item 6. It will be added to this document only
  if and when it is actually imported in a future phase.
- This document will be extended, not replaced, if a future Phase 2C
  batch imports additional apps.

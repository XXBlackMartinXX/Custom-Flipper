# Phase 2B — Third-Party Notices

Docs only. This is the Phase 2B counterpart to the base-firmware
`docs/THIRD_PARTY_NOTICES.md`: it lists the individually-authored,
individually-licensed apps imported into `applications_user/` as part of
Phase 2B, each preserving its own author's copyright and license terms.
The full, authoritative license text for each app remains in that app's
own `LICENSE` file in its imported directory — this document is an index
and summary, not a substitute for reading those files directly.

## Apps

### `flipfetch`

| Field | Value |
|---|---|
| App name | Flipfetch |
| appid | `flipfetch` |
| Author | Ismael A. Rodríguez |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/alexroses47/flipper-flipfetch`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/flipfetch/` |
| Imported to | `applications_user/flipfetch/` |
| Full license text | `applications_user/flipfetch/LICENSE` (copied verbatim; SHA-256 `82bf9aacd466c35be23d4f10bc73fa4ab175294cfcbb32d46ae4db44c6781c81`) |

### `quadratic_solver`

| Field | Value |
|---|---|
| App name | Quadratic Solver |
| appid | `quadratic_solver` |
| Author | paul-sopin |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/paul-sopin/flipper-quadratic-solver`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/quadratic_solver/` |
| Imported to | `applications_user/quadratic_solver/` |
| Full license text | `applications_user/quadratic_solver/LICENSE` (copied verbatim; SHA-256 `3b2dee56c094664bb9ec081ace3700495449254eeaf61eabedd1333561fb5eaa`) |

### `sudoku`

| Field | Value |
|---|---|
| App name | Sudoku |
| appid | `sudoku` |
| Author | @profelis |
| License | MIT |
| Source repository | `https://github.com/RogueMaster/flipperzero-firmware-wPlugins` (vendored copy imported from; original individual project: `https://github.com/profelis/fz-sudoku`) |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path | `applications/external/sudoku/` |
| Imported to | `applications_user/sudoku/` |
| Full license text | `applications_user/sudoku/LICENSE` (copied verbatim; SHA-256 `b65e22a506115b1466b23a0a5590406ff1360e6d93482b833bae57984de63758`) |

## Notes

- All original authorship, copyright notices, and license headers in each
  app's own files are preserved unmodified. This project does not claim
  authorship of any of the 3 apps above.
- None of the 3 apps bundles any further third-party code of its own —
  see `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md` for the full reasoning.
- MIT is compatible with inclusion in this project's GPLv3-licensed
  firmware base; see `docs/PHASE2B_2_LICENSE_ATTRIBUTION.md` for the
  compatibility note.
- This document will be extended, not replaced, if a future Phase 2B
  batch imports additional apps.

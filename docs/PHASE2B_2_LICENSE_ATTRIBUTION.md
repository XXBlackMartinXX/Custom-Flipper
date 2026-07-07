# Phase 2B.2 — License Attribution

Docs only. Records the license evidence and attribution actions taken for
the 3 apps actually imported in this phase, re-confirmed against the
files as committed to this repository.

## MIT license evidence for each app

| App | Declared license | LICENSE file present in this repo | SHA-256 (matches Phase 2B.1 evidence) |
|---|---|---|---|
| `flipfetch` | MIT | `applications_user/flipfetch/LICENSE` | `82bf9aacd466c35be23d4f10bc73fa4ab175294cfcbb32d46ae4db44c6781c81` |
| `quadratic_solver` | MIT | `applications_user/quadratic_solver/LICENSE` | `3b2dee56c094664bb9ec081ace3700495449254eeaf61eabedd1333561fb5eaa` |
| `sudoku` | MIT | `applications_user/sudoku/LICENSE` | `b65e22a506115b1466b23a0a5590406ff1360e6d93482b833bae57984de63758` |

All three hashes were recomputed directly against the files now committed
in `applications_user/` in this repository and matched the Phase 2B.1
pre-import evidence exactly — confirming the imported files are
byte-for-byte identical to what was verified before import, not a
different or edited copy.

## Author / source / path / commit

| App | Author (`fap_author`) | Source repository | Source commit | Source path (upstream) | Destination path (this repo) |
|---|---|---|---|---|---|
| `flipfetch` | Ismael A. Rodríguez | `RogueMaster/flipperzero-firmware-wPlugins` | `472f6925e8aca9bd031cb37e3cb80b551772c957` | `applications/external/flipfetch/` | `applications_user/flipfetch/` |
| `quadratic_solver` | paul-sopin | `RogueMaster/flipperzero-firmware-wPlugins` | `472f6925e8aca9bd031cb37e3cb80b551772c957` | `applications/external/quadratic_solver/` | `applications_user/quadratic_solver/` |
| `sudoku` | @profelis | `RogueMaster/flipperzero-firmware-wPlugins` | `472f6925e8aca9bd031cb37e3cb80b551772c957` | `applications/external/sudoku/` | `applications_user/sudoku/` |

Original upstream repos (per each app's own `fap_weburl`, the individual
author's own project this code was originally contributed from before
RogueMaster vendored it): `github.com/alexroses47/flipper-flipfetch`,
`github.com/paul-sopin/flipper-quadratic-solver`,
`github.com/profelis/fz-sudoku`.

## Attribution actions taken

- Each app's own `LICENSE` file was copied verbatim into its destination
  directory — the primary, authoritative attribution record, unedited.
- Each app's own `README.md` (and, where present, `changelog.md`/
  `CHANGELOG.md`/`README_catalog.md`) was copied verbatim alongside it.
- `docs/PHASE2B_THIRD_PARTY_NOTICES.md` was created, listing all 3 apps'
  name, author, license, source repository, source commit, and source
  path, and pointing back to each app's own in-tree `LICENSE` file as the
  full license text — the same discipline `docs/THIRD_PARTY_NOTICES.md`
  already uses for the base firmware's own vendored submodules.
- No copyright notice or MIT permission-notice text was removed, edited,
  or rewritten anywhere in this phase.

## Third-party bundled code status

**None of the 3 apps bundles any third-party code.** Each is a single
self-contained implementation by its own named author:

- `flipfetch`: one source file (`flipfetch.c`), no vendored libraries.
- `quadratic_solver`: one source file (`app.c`), no vendored libraries.
- `sudoku`: one source file (`sudoku.c`), no vendored libraries.

This is a materially simpler license posture than `chess` (which bundles
`smallchesslib` and, formerly, the since-removed `stm32_sam`) or the
still-deferred `upython` (which bundles a customized MicroPython fork) —
there is nothing beyond each app's own single MIT-licensed file and its
own icon/screenshot assets to account for.

## GPLv3 compatibility

MIT is a permissive license with no restriction on inclusion in a
GPLv3-licensed larger work (this project's firmware base). This is the
standard, uncontested compatibility relationship — MIT is on the FSF's own
list of GPL-compatible free software licenses — not a novel determination
made for this project.

# Phase 2E.2 — License Attribution

Docs only. Records the real license evidence and attribution actions
taken for the 3 apps actually imported in this phase, building directly
on the real source read already performed in Phase 2E.1
(`docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md`) and re-confirmed
byte-for-byte in this phase before any commit was made.

## `image_viewer` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/image_viewer/LICENSE` |
| SHA-256 (as imported) | `9033a7e2bc385ce398e36f2b9bf4aa190f6a2974ba08b534e567b0b962dc1ee4` |
| Copyright holder | Ivan Polushin (2024) |
| Author (`fap_author`) | polioan |
| Source repository | `https://github.com/polioan/flipper-zero-image-viewer` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork, the pinned commit this whole project cites) |
| Source path (upstream) | `applications/external/image_viewer/` |
| Local imported path | `applications_user/image_viewer/` |
| Import commit | `3b20db6` |

**MIT compatibility**: permissive, GPLv3-compatible (on the FSF's own
compatible-license list) — the same reasoning already applied to every
other MIT-licensed app in this project.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/image_viewer/LICENSE`. An entry
has also been added to `docs/PHASE2E_THIRD_PARTY_NOTICES.md` recording
the author, license, and source for quick reference.

**Bundled third-party code/data — excluded, not imported**: the
`example_images/` directory (3 bundled `.bm` demo images —
`cat.bm`, `dolphin.bm`, `spongebob.bm`) was **not imported**, per the
Phase 2E.1 import-scope condition. `spongebob.bm` was decoded and
visually confirmed in Phase 2E.1 to depict a recognizable
trademarked/copyrighted cartoon character (SpongeBob SquarePants) with no
attribution or redistribution-rights evidence anywhere in the app.
`dolphin.bm`/`cat.bm` are excluded alongside it on the same
unconfirmed-provenance basis. The corresponding `fap_file_assets =
"example_images"` line was removed from the imported `application.fam`.
Only `application.fam` (edited as above), `LICENSE`, `README.md`,
`CHANGELOG.md`, `main.cpp`, and `assets/icon.png` were imported; none of
the excluded material is referenced by `main.cpp` or required for the
app to build or function — confirmed both by direct source read and by
the real CI Build PASS.

## `boilerplate` — informal permissive grant (README-only, no LICENSE file)

| Field | Value |
|---|---|
| Declared license / evidence tier | **No formal `LICENSE` file exists upstream.** `README.md`'s own "## Licensing" section states: "This code is open-source and may be used for whatever you want to do with it." This is real, direct, explicit author evidence — but a materially weaker, non-SPDX evidence tier than a formal license file, and is recorded as such, not upgraded to "MIT" or any other named license. |
| Evidence | Full, unmodified "## Licensing" section, present verbatim at `applications_user/boilerplate/README.md` |
| Copyright/author | leedave |
| Author (`fap_author`) | leedave |
| Source repository | `https://github.com/leedave/flipper-zero-fap-boilerplate` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path (upstream) | `applications/external/boilerplate/` |
| Local imported path | `applications_user/boilerplate/` |
| Import commit | `74d0927` |

**Attribution action taken**: no `LICENSE` file was invented. The exact
"## Licensing" text was preserved unedited in the imported
`README.md`, and the same text is quoted verbatim in
`docs/PHASE2E_THIRD_PARTY_NOTICES.md` as this app's license-evidence
record.

**Bundled third-party code/data**: none. The entire imported tree
(`helpers/`, `scenes/`, `views/`, `icons/`, `docs/`) is the author's own
demonstration/template code and icon assets — no vendored third-party
material was found in Phase 2E.1 and none was introduced at import time.

**Real appid discrepancy, recorded precisely**: the manifest declares
`appid="fap_boilerplate"`, not `boilerplate` (the directory-name
assumption used since Phase 1.5). This does not affect license status —
noted here so a reader cross-referencing older planning docs isn't
misled.

## `minesweeper` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/minesweeper/LICENSE` |
| SHA-256 (as imported) | `ca3bfe383b2927db68210582fd1b71032cbc7d7bdfd899af86a5c71db12681ff` |
| Copyright holder | Alexander Rodriguez (2024) |
| Author (`fap_author`) | squee72564 (a commented-out `fap_author = "Alexander Rodriguez"` line in `application.fam` confirms the same real name as the `LICENSE` copyright line) |
| Source repository | `https://github.com/squee72564/F0_Minesweeper_Fap` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Source path (upstream) | `applications/external/minesweeper/` |
| Local imported path | `applications_user/minesweeper/` |
| Import commit | `d82c0ff` |

**MIT compatibility**: permissive, GPLv3-compatible, same reasoning as
`image_viewer` above.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/minesweeper/LICENSE`. An entry
has also been added to `docs/PHASE2E_THIRD_PARTY_NOTICES.md`.

**Bundled third-party code/data**: none identified as third-party — all
sprite assets (8×8 tiles, icon, "crying dolphin" game-over sprite,
13-frame start-screen animation) are original, self-authored game
artwork, confirmed by direct inspection in Phase 2E.1 and re-confirmed at
import time. The app's one third-party header dependency (M\*LIB's
`m-deque.h`) is already provided by this project's existing `lib/mlib`
base-firmware submodule — not a new bundled dependency, nothing to
attribute beyond what the base firmware already does.

`img/` (screenshots/GIFs, not referenced by `application.fam`) and
`docs/changelog.md` were excluded from the import for cleanliness only —
no provenance concern of their own.

**Real appid discrepancy, recorded precisely**: the manifest declares
`appid="minesweeper_redux"`, not `minesweeper`. Noted here for the same
reason as `boilerplate` above.

## Summary

| App | License | Evidence tier | Excluded content |
|---|---|---|---|
| `image_viewer` | MIT | High (formal LICENSE file) | `example_images/` (3 files, including confirmed trademarked-character image) |
| `boilerplate` | Informal permissive grant | Medium-High (real, explicit, but non-formal) | None |
| `minesweeper` | MIT | High (formal LICENSE file) | `img/`, `docs/changelog.md` (cleanliness only) |

See `docs/PHASE2E_THIRD_PARTY_NOTICES.md` for the consolidated,
quick-reference notice entries.

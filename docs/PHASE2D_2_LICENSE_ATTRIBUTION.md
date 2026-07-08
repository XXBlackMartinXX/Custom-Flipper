# Phase 2D.2 — License Attribution

Docs only. Records the real license evidence and attribution actions
taken for the 3 apps actually imported in this phase, building directly
on the real source read already performed in Phase 2D.1
(`docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md`) and re-confirmed
byte-for-byte in this phase before any commit was made.

## `resistors` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/resistors/LICENSE` |
| SHA-256 (as imported) | `bf379221d73cdf51ecc347b5d2cdfd6d9cb0b862848cf7d64241643d22d8224e` |
| Copyright holder | Lewis Westbury (2023) |
| Author (`fap_author`) | Lewis Westbury |
| Source repository | `https://github.com/instantiator/flipper-zero-experimental-apps` (original); `README.md` also credits the `shalebridge` fork for the 1.4 feature set |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork, the pinned commit this whole project cites) |
| Source path (upstream) | `applications/external/resistors/` |
| Local imported path | `applications_user/resistors/` |
| Import commit | `621229a` |

**MIT compatibility**: permissive, GPLv3-compatible (on the FSF's own
compatible-license list) — the same reasoning already applied to
`flipfetch`/`quadratic_solver`/`sudoku`/`docviewlite`/`2048`.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/resistors/LICENSE`. An entry has
also been added to `docs/PHASE2D_THIRD_PARTY_NOTICES.md` recording the
author, license, and source for quick reference.

**Bundled third-party code/data**: none in the imported scope. The
upstream repository's `.flipcorg/`, `design/`, `img/`, and `screenshots/`
directories (~2.3MB combined) — including two files with unclear
photographic-reference provenance (`design/resistor_4_src.webp`,
`design/resistor_5_src.jpg`) — were **not imported**, per the Phase 2D.1
import-scope condition. Only `application.fam`, `src/`, `resistors.png`,
`images/`, `LICENSE`, and `README.md` were imported; none of the excluded
material is referenced by `application.fam` or required for the build
(confirmed by the real CI build succeeding without it).

## `crypto_dictionary` — GPLv3

| Field | Value |
|---|---|
| Declared license | **GPLv3** (GNU General Public License, Version 3) |
| Evidence | Full, unmodified FSF license text, present at `applications_user/crypto_dictionary/LICENSE` |
| SHA-256 (as imported) | `605e9047a563c5c8396ffb18232aa4304ec56586aee537c45064c6fb425e44ad` |
| Author (`fap_author`) | armixz |
| Source repository | `https://github.com/armixz/Flipper-Zero-Crypto-Dictionary` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork) |
| Source path (upstream) | `applications/external/crypto_dictionary/` |
| Local imported path | `applications_user/crypto_dictionary/` |
| Import commit | `f9fcc57` |

**GPLv3 compatibility**: the most direct possible compatibility case
available to this project — the app is licensed under the exact same
license as the firmware base itself (the same class of finding as
`sd_info` in Phase 2C.1/2C.2).

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim, satisfying GPLv3's own attribution/notice
requirements. An entry has also been added to
`docs/PHASE2D_THIRD_PARTY_NOTICES.md`.

**Bundled third-party code/data**: the app bundles 14 glossary `.txt`
files (`resources/symmetric_cipher/*.txt`, `resources/about/*.txt`,
`resources/development.txt`) describing public, non-copyrightable
symmetric-cipher specifications, in a distinctive original authorial
style — confirmed in Phase 2D.1 and re-confirmed here to have no
third-party attribution requirement of their own. The upstream
repository's `.flipcorg/` catalog-banner directory was not imported
(not referenced by `application.fam`, no provenance concern of its own).

## `2048` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/2048/LICENSE` |
| SHA-256 (as imported) | `b3fd6903a2acfae0c552d79850dbb65fac262716df402772b6a2e90e6ef5199b` |
| Copyright holder | Eugene Kirzhanov (2022) |
| Author (`fap_author`) | eugene-kirzhanov |
| Source repository | none declared in `application.fam`; `README.md` credits Eugene Kirzhanov, with design-inspiration (not code) credits to `DroomOne`'s FlappyBird and `x27`'s "15" game |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork) |
| Source path (upstream) | `applications/external/2048/` |
| Local imported path | `applications_user/2048/` |
| Import commit | `52b1361` |

**MIT compatibility**: same reasoning as `resistors` above.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim. `README.md` and `README-catalog.md` (both imported
unmodified) already carry the author's own credits. An entry has also
been added to `docs/PHASE2D_THIRD_PARTY_NOTICES.md`.

**Bundled third-party code/data**: none. `digits.h`'s hardcoded 14×14
pixel bitmap array is original, self-authored data specific to this app,
not a third-party font or asset. The upstream repository's `images/` and
`img/` directories (4 gameplay screenshots, not referenced by
`application.fam`) were not imported, for cleanliness — no provenance
concern of their own.

## Summary

| App | License | Attribution complete | Bundled 3rd-party content | Excluded material |
|---|---|---|---|---|
| `resistors` | MIT | Yes — `LICENSE` preserved verbatim | None in imported scope | `.flipcorg/`, `design/`, `img/`, `screenshots/` (unclear-provenance reference photos + catalog material) |
| `crypto_dictionary` | GPLv3 | Yes — `LICENSE` preserved verbatim | 14 original glossary `.txt` files, no 3rd-party attribution needed | `.flipcorg/` (catalog material) |
| `2048` | MIT | Yes — `LICENSE` preserved verbatim | None | `images/`, `img/` (screenshots) |

All 3 licenses were confirmed by direct byte-level read of the actual
imported artifact, not assumed or cited from a prior phase without
re-verification. `docs/PHASE2D_THIRD_PARTY_NOTICES.md` has been created
with a formal entry for each app. No app in this batch bundles any
copied, unattributed, or rights-unclear third-party code or creative
text within its actually-imported scope.

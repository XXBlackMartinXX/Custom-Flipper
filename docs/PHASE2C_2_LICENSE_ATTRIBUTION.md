# Phase 2C.2 — License Attribution

Docs only. Records the real license evidence and attribution actions
taken for the 2 apps actually imported in this phase, building directly
on the real source read already performed in Phase 2C.1
(`docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`) and re-confirmed
byte-for-byte in this phase before either commit was made.

## `sd_info` — GPLv3

| Field | Value |
|---|---|
| Declared license | **GPLv3** (GNU General Public License, Version 3) |
| Evidence | Full, unmodified, 674-line FSF license text, present at `applications_user/sd_info/LICENSE` |
| SHA-256 (re-verified in this phase, matches Phase 2C.1 exactly) | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` |
| Author (`fap_author`) | sergo |
| Source repository | `https://github.com/Sladkisnovraper/SD-Info-For-Flipper-Zero` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork, the pinned commit this whole project cites) |
| Source path (upstream) | `applications/external/sd_info/` |
| Local imported path | `applications_user/sd_info/` |
| Import commit | `4e17278` |

**GPLv3 compatibility**: this is the most direct possible compatibility
case available to this project — the app is licensed under the exact same
license as the firmware base itself. No cross-license reasoning is
required (unlike the MIT-into-GPLv3 case already documented for the Phase
2B batch).

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/sd_info/LICENSE` — this is the
complete GPLv3 grant, satisfying GPLv3's own attribution/notice
requirements on its own. An entry has also been added to
`docs/PHASE2C_THIRD_PARTY_NOTICES.md` recording the author, license, and
source for quick reference alongside every other imported app's notice.

**Bundled third-party code**: none. Single self-contained source file
(`main.c`).

## `docviewlite` — MIT

| Field | Value |
|---|---|
| Declared license | **MIT License** |
| Evidence | Full, unmodified MIT text, present at `applications_user/docviewlite/LICENSE` |
| SHA-256 (re-verified in this phase, matches Phase 2C.1 exactly) | `61f23cb99a91d229c9d018d9aaff7b9e824cdfa23548a1a9302eda3d5a185e12` |
| Copyright holder | C0D3-5T3W (2025-2030) |
| Author (`fap_author`) | C0d3-5t3w |
| Source repository | `https://github.com/C0d3-5t3w/docviewlite` |
| Source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` (RogueMaster fork) |
| Source path (upstream) | `applications/external/docviewlite/` |
| Local imported path | `applications_user/docviewlite/` |
| Import commit | `4fab909` |

**MIT compatibility**: permissive, GPLv3-compatible (on the FSF's own
compatible-license list) — the same reasoning already applied to
`flipfetch`/`quadratic_solver`/`sudoku` in Phase 2B.1.

**Attribution action taken**: the full, unmodified `LICENSE` file was
preserved verbatim at `applications_user/docviewlite/LICENSE`, satisfying
MIT's requirement that "the above copyright notice and this permission
notice shall be included in all copies or substantial portions of the
Software." An entry has been added to
`docs/PHASE2C_THIRD_PARTY_NOTICES.md`.

**Bundled third-party code**: none. Single self-contained source file
(`docviewlite.c`). The manifest's `fap_icon_assets="images"` reference to
a non-existent directory is a build-configuration question, not a
third-party-content question — see `docs/PHASE2C_2_BUILD_REPORT.md`.

## `fcc_id_lookup` — not imported, license status unchanged

Not part of this import. Its license-evidence gap (no `LICENSE` file in
the RogueMaster-vendored copy; strong but not commit-pinned corroborating
MIT evidence at the true upstream repository) remains exactly as recorded
in `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` and
`docs/KNOWN_ISSUES.md` item 6. Nothing in this phase changes that status.

## Summary

| App | License | Evidence strength | Attribution action | Third-party content |
|---|---|---|---|---|
| `sd_info` | GPLv3 | High — full text, re-verified byte-identical | `LICENSE` preserved; `THIRD_PARTY_NOTICES.md` entry added | None |
| `docviewlite` | MIT | High — full text, re-verified byte-identical | `LICENSE` preserved; `THIRD_PARTY_NOTICES.md` entry added | None |
| `fcc_id_lookup` | Not present in vendored copy (deferred) | Low-Medium — corroborating only | N/A — not imported | N/A — not imported |

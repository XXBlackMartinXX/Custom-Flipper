# Phase 2B — License Review

Docs only. Planning only. Covers the 3 apps recommended in
`PHASE2B_RECOMMENDED_BATCH.md`, plus a note on the one candidate
(`c_book`) excluded from the pool specifically for a licensing reason.

## Honest scope statement

**No per-app `LICENSE` file, SPDX header, or license text has actually
been read in this phase.** This environment has no local clone of the
RogueMaster source tree to read one from, and this is a planning-only
phase by explicit instruction. Everything below is either (a) a citation
of what the existing Phase 1.5/1.6 audits already recorded (author/README/
`fap_weburl`/version presence — attribution evidence, not a license-text
confirmation), or (b) an honest `NEEDS REVIEW` for anything those audits
did not check. This mirrors, rather than repeats, the gap that let
`chess`'s unlicensed SAM speech-synth component through the Phase 1.6
audit undetected until `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md` was run
against it as a dedicated pass — the same dedicated pass is what these 3
apps (and `c_book`) would need at actual import time, not a re-run of this
planning document.

## `flipfetch`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — not captured by the Phase 1.5/1.6 audits (they confirmed a real author/README/`fap_weburl`/version exist, per the Top-25 baseline bar, but did not record an SPDX identifier or read a `LICENSE` file). |
| Source of license evidence | Phase 1.5 baseline screening only (attribution present, not license text). |
| Bundled third-party code | None identified — single file, no vendored sub-libraries per Phase 1.6 audit. |
| Missing/unclear license issue | The license itself has not been confirmed, but there is no indication of a third-party-code provenance problem (single self-contained file). |
| Acceptable for import planning | Yes — nothing found that would block planning; the actual `LICENSE`/header must be read and recorded before an actual import commit. |
| Legal review needed | Standard read-the-actual-license-file step at import time, same as any other app — not an elevated concern. |
| Should be deferred | No. |

## `quadratic_solver`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as `flipfetch`. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code | None identified — single file, pure computation, per Phase 1.6 audit. |
| Missing/unclear license issue | Not confirmed, no third-party-provenance concern identified. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step, not elevated. |
| Should be deferred | No. |

## `sudoku`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as the other two. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code | None identified — single file, per Phase 1.6 audit. Sudoku as a puzzle concept is not copyrightable; only this specific implementation's code license matters, and that has not been read yet. |
| Missing/unclear license issue | Not confirmed, no third-party-provenance concern identified. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step, not elevated. |
| Should be deferred | No. |

## Excluded-from-pool note: `c_book`

Not part of the recommended batch, but recorded here because it is
specifically a **licensing** exclusion, not a safety/capability one — the
opposite of `upython`/`iconedit`, which were excluded for hardware
capability reasons in `PHASE2B_CANDIDATE_REVIEW.md`.

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW / likely problematic** — not confirmed either way in this phase, but the *nature* of the bundled content raises a real concern independent of whatever the wrapper app code's own license is. |
| Source of license evidence | Phase 1.5/1.6 description only: "an on-device copy of 'The C Programming Language' (K&R), Flipper Edition," bundling `.txt` chapters of that book as data resources. |
| Bundled third-party code | **The bundled content is not code, it is the verbatim (or near-verbatim) text of a commercially published, copyrighted book** ("The C Programming Language" by Kernighan & Ritchie, published by Prentice Hall). This is categorically different from bundling an MIT/BSD-licensed code library — book text of this kind is not open-source-licensed at all, and Phase 1.6's audit did not evaluate this because its scope was hardware/storage capability, not copyright. |
| Missing/unclear license issue | **Yes — this is exactly the missing/unclear-license case the task's own canary describes**: "If any app has unclear license or bundled third-party code without provenance, stop and mark DEFER." No provenance for a legitimate distribution right over the bundled book text has been found or asserted anywhere in the Phase 1 material. |
| Acceptable for import planning | **No — excluded from the recommended batch on this basis.** Kept in the broader candidate pool list in `PHASE2B_CANDIDATE_REVIEW.md` only for completeness/traceability, not as a live recommendation. |
| Legal review needed | **Yes, a real one** — not the standard read-the-header step. Someone would need to confirm whether the bundled text is (a) actually verbatim book excerpts (would need an explicit rights grant from the publisher/authors' estate, which is very unlikely to exist for a hobbyist Flipper app), (b) a public-domain/differently-licensed derivative work in fact, or (c) something this project's own reading of "Flipper Edition" is mischaracterizing (e.g. it might just be original tutorial content *inspired by* K&R's structure, not the actual text — that would change the answer entirely, but has not been confirmed either way in any document available in this phase). |
| Should be deferred | **Yes — DEFER**, pending that dedicated review, following the exact same discipline `chess`'s SAM component went through in Phase 2A. |

## What would resolve `c_book`'s open question

The same kind of dedicated review `PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`
performed for the SAM speech-synth library: read the actual bundled `.txt`
files' content and any accompanying license/attribution note in the real
RogueMaster source, and determine plainly whether they are verbatim
copyrighted book text (blocking), a differently-licensed derivative
(potentially fine), or original content mischaracterized by this project's
own shorthand description (potentially fine). Until that read happens,
this review does not recommend treating `c_book` as available for import,
consistent with never claiming a license is clear without having actually
read it.

## Summary

| App | License status | Recommendation |
|---|---|---|
| `flipfetch` | NEEDS REVIEW (routine — read at import time) | Acceptable for import planning |
| `quadratic_solver` | NEEDS REVIEW (routine — read at import time) | Acceptable for import planning |
| `sudoku` | NEEDS REVIEW (routine — read at import time) | Acceptable for import planning |
| `c_book` | NEEDS REVIEW (elevated — real unresolved copyright question) | **DEFER**, excluded from this batch |

No license has been declared clean by this document for any app — "routine"
above means the gap is the same ordinary read-the-license-file step every
prior Phase 2A app also required, not a finding of an actual problem;
"elevated" means an actual, specific, unresolved concern exists.

---

## Phase 2B.1 verification update (real source read — supersedes the "routine NEEDS REVIEW" status above for the 3 in-batch apps)

**This section adds new, direct evidence gathered in Phase 2B.1. The
planning-phase content above is left unmodified as the historical record
of what was and wasn't known at that time; do not read this section as
retroactively editing it.**

In Phase 2B.1, this environment had real, working network access to fetch
actual upstream source — something the original planning phase explicitly
lacked. A real `git fetch`/`checkout` of
`RogueMaster/flipperzero-firmware-wPlugins` at commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` (the exact commit the original
Phase 1.6 audit cited) retrieved each app's actual `LICENSE` file, read in
full:

| App | Declared license (confirmed by direct read) | LICENSE file SHA-256 | Copyright holder |
|---|---|---|---|
| `flipfetch` | MIT | `82bf9aacd466c35be23d4f10bc73fa4ab175294cfcbb32d46ae4db44c6781c81` | Ismael A. Rodríguez (2026) |
| `quadratic_solver` | MIT | `3b2dee56c094664bb9ec081ace3700495449254eeaf61eabedd1333561fb5eaa` | paul-sopin (2025) |
| `sudoku` | MIT | `b65e22a506115b1466b23a0a5590406ff1360e6d93482b833bae57984de63758` | @profelis (2023) |

**GPLv3 compatibility**: MIT is a permissive license. It imposes no
restriction on inclusion within a GPLv3-licensed larger work — a
GPLv3 project may include MIT-licensed components, and the combined
distribution as a whole remains GPLv3-compliant, provided MIT's own two
conditions are met (below). This is the standard, uncontested
compatibility relationship between MIT and GPLv3 (MIT is on the FSF's own
list of GPL-compatible free software licenses) — not a novel or contested
determination.

**Attribution required**: Yes, for all 3 — MIT requires "The above
copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software." This means each app's
copyright notice must be preserved (in-file, as already present in each
app's own source) and each author's name + the MIT notice text recorded in
this project's `docs/CREDITS.md`/`docs/THIRD_PARTY_NOTICES.md` at actual
import time — a normal, routine attribution step, not a blocker.

**Bundled third-party code**: None found in any of the 3 — each is a
single self-contained source file (or `app.c` alone, for
`quadratic_solver`) with no vendored sub-libraries, unlike `chess` (which
bundles `smallchesslib`/`stm32_sam`) or `upython` (which bundles a
MicroPython fork).

**Missing license evidence**: None remaining. All 3 `LICENSE` files were
located, fetched, and read in full in this phase.

### Updated summary (Phase 2B.1 supersedes the planning-phase row for these 3 apps)

| App | License status (Phase 2B.1) | Recommendation |
|---|---|---|
| `flipfetch` | **CONFIRMED — MIT, real LICENSE file read** | Cleared for import |
| `quadratic_solver` | **CONFIRMED — MIT, real LICENSE file read** | Cleared for import |
| `sudoku` | **CONFIRMED — MIT, real LICENSE file read** | Cleared for import |
| `c_book` | Unchanged — still NEEDS REVIEW (elevated), not in scope for Phase 2B.1 | Still DEFER, excluded |

`c_book` was explicitly out of scope for Phase 2B.1 (per the hard
exclusions in that phase's instructions: "do not revisit or import
`c_book`") — its elevated licensing concern from the planning phase stands
exactly as recorded above, unresolved, until a future dedicated pass
addresses it specifically.

See `docs/PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md` for the complete,
per-app evidence (file listings, safety/API scan results, storage
findings) behind this update.

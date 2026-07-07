# Phase 2C — License Review

Docs only. Planning only. Covers the 3 apps recommended in
`PHASE2C_RECOMMENDED_BATCH.md`.

## Honest scope statement

**No per-app `LICENSE` file, SPDX header, or license text has actually
been read in this phase.** This is a planning-only phase by explicit
instruction, and real source/license verification is deliberately deferred
to Phase 2C.1 (see `docs/PHASE2C_NEXT_GATE.md`) — the same sequencing
Phase 2B used, where Phase 2B's own planning document recorded all 3 of
its recommended apps as `NEEDS REVIEW (routine)` and only Phase 2B.1,
a separate, explicitly-approved verification phase, obtained and read the
real `LICENSE` files. Everything below is either (a) a citation of what
the existing Phase 1.5/1.6 audits already recorded (author/README/
`fap_weburl`/version presence — attribution evidence, not a license-text
confirmation), or (b) an honest `NEEDS REVIEW` for anything those audits
did not check.

## `sd_info`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — not captured by the Phase 1.5/1.6 audits (they confirmed a real author/README/`fap_weburl`/version exist, per the Top-25 baseline bar, but did not record an SPDX identifier or read a `LICENSE` file). |
| Source of license evidence | Phase 1.5 baseline screening only (attribution present, not license text). |
| Bundled third-party code | None identified — single file, no vendored sub-libraries per Phase 1.6 audit. |
| Missing/unclear license issue | The license itself has not been confirmed, but there is no indication of a third-party-code provenance problem (single self-contained file, read-only card-info query). |
| Acceptable for import planning | Yes — nothing found that would block planning; the actual `LICENSE`/header must be read and recorded before an actual import commit, at Phase 2C.1. |
| Legal review needed | Standard read-the-actual-license-file step at import time, same as any other app — not an elevated concern. |
| Should be deferred | No. |

## `fcc_id_lookup`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as `sd_info`. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code | **Bundles a reference database** of FCC ID/frequency data, described in Phase 1.5/1.6 as derived from US FCC public records — a materially different case from `c_book`'s copyrighted book text, since compiled facts/public-record data are generally not independently copyrightable in the way creative text is. **Not confirmed** against the database's actual source/compilation method in this phase, though. |
| Missing/unclear license issue | The wrapper app code's own license is unconfirmed (routine gap). The bundled database's provenance is described but not verified — flagged for a specific check at Phase 2C.1, not treated as clear. |
| Acceptable for import planning | Yes — the "public records" characterization from Phase 1.5/1.6 is a reasonable basis for planning-stage inclusion, but is not a substitute for confirming it directly before import. |
| Legal review needed | Slightly elevated over the routine step: confirm at Phase 2C.1 that the bundled database is actually compiled from public FCC records (as described) and not a third-party proprietary compilation with its own separate license. Not expected to be a problem, but not yet confirmed either. |
| Should be deferred | No — acceptable for planning with this specific verification flagged for Phase 2C.1. |

## `docviewlite`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as the other two. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code | None identified — single file, per Phase 1.6 audit. The app reads user-selected documents at runtime; it does not bundle any document content of its own. |
| Missing/unclear license issue | Not confirmed, no third-party-provenance concern identified — there is no bundled content to raise one. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step, not elevated. |
| Should be deferred | No. |

## Summary

| App | License status | Recommendation |
|---|---|---|
| `sd_info` | NEEDS REVIEW (routine — read at Phase 2C.1) | Acceptable for import planning |
| `fcc_id_lookup` | NEEDS REVIEW (routine for wrapper code; specific bundled-database provenance check flagged for Phase 2C.1) | Acceptable for import planning, with that one specific check flagged |
| `docviewlite` | NEEDS REVIEW (routine — read at Phase 2C.1) | Acceptable for import planning |

No license has been declared clean by this document for any app —
"routine" above means the gap is the same ordinary read-the-license-file
step every prior app also required before its own import, not a finding of
an actual problem. None of the 3 recommended apps carry an elevated
concern of the kind `c_book` did in Phase 2B (verbatim copyrighted book
text) or `upython`/`iconedit` did (real hardware-capability exposure) —
this batch was deliberately selected to avoid both classes of concern.

## What Phase 2C.1 would need to do (not performed here)

Mirroring exactly what Phase 2B.1 did for `flipfetch`/`quadratic_solver`/
`sudoku`: obtain real network access to the actual upstream source
(`RogueMaster/flipperzero-firmware-wPlugins` at the same audited commit,
or whatever commit is current at that time), fetch each of these 3 apps'
actual `LICENSE` files, read them in full, confirm GPLv3 compatibility
(the same permissive-license compatibility analysis already applied to
the 3 Phase 2B apps), and — specifically for `fcc_id_lookup` — read the
bundled database file's own header/source comment (if any) to confirm its
public-record provenance directly rather than relying on the Phase 1.5/1.6
description alone. Until that happens, this document does not declare any
of these 3 apps license-clear, consistent with never claiming a license is
confirmed without having actually read it.

---

## Phase 2C.1 verification update (real source read — supersedes the "routine NEEDS REVIEW" status above for `sd_info` and `docviewlite`)

**This section adds new, direct evidence gathered in Phase 2C.1. The
planning-phase content above is left unmodified as the historical record
of what was and wasn't known at that time; do not read this section as
retroactively editing it.**

In Phase 2C.1, this environment had real, working network access to fetch
actual upstream source. A real `git fetch`/`checkout` of
`RogueMaster/flipperzero-firmware-wPlugins` at commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` (the exact commit the original
Phase 1.6 audit and Phase 2B.1 both cited) retrieved each app's actual
`LICENSE` file (where present) — read in full:

| App | Declared license (confirmed by direct read) | LICENSE file SHA-256 | Copyright holder |
|---|---|---|---|
| `sd_info` | **GPLv3** (full, unmodified FSF text) | `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986` | Not individually named in-file (standard for many hobbyist GPLv3 projects — the LICENSE file itself is the operative grant) |
| `docviewlite` | **MIT** | `61f23cb99a91d229c9d018d9aaff7b9e824cdfa23548a1a9302eda3d5a185e12` | C0D3-5T3W (2025-2030) |
| `fcc_id_lookup` | **No LICENSE file in the vendored copy at all** — see below | N/A (file does not exist in the artifact reviewed) | N/A |

**`sd_info` — GPLv3 compatibility**: this is the most direct possible
compatibility case available to this project — the app is licensed under
the exact same license as the firmware base itself, so no cross-license
compatibility analysis is even required (unlike the MIT-into-GPLv3
reasoning needed for the Phase 2B batch). **Attribution required**: yes,
per GPLv3's standard terms (preserve the license text) — routine, not
elevated.

**`docviewlite` — MIT compatibility**: same reasoning already applied to
`flipfetch`/`quadratic_solver`/`sudoku` in Phase 2B.1 — MIT is a
permissive, GPLv3-compatible license (on the FSF's own compatible-license
list). **Attribution required**: yes, per MIT's standard terms.

**`fcc_id_lookup` — the one open item, and it is *worse* than this
planning document's original "routine NEEDS REVIEW," not better.** The
planning-phase content above assumed the only gap was "no SPDX identifier
read yet" (the same routine gap every app in this project starts with).
The real Phase 2C.1 source read found something more specific: **the
RogueMaster-vendored copy has no `LICENSE` file, no SPDX header, and no
copyright notice anywhere in its source at all** — not merely unread, but
absent from the artifact. A real, confirmed MIT license (Copyright (c)
2026 lsr) was found at the exact upstream repository this app's own
`fap_weburl` names, and the code is clearly the same project (near-identical
source, same author), but that evidence is not commit-pinned to the
specific historical revision RogueMaster vendored. Per Phase 2C.1's own
license canary ("if any app license cannot be proven, mark that app
DEFER"), this app is now classified **DEFER**, not "acceptable for
planning" as this document originally said. This is still a **much lower
severity concern than `c_book`'s** (no unresolved copyright question, no
commercial content, an easy resolution path: include the confirmed
upstream `LICENSE` at actual import time) — but it is a real, specific
finding this planning-phase document did not anticipate, and it is
recorded honestly rather than smoothed over.

**Bundled data clarification for `fcc_id_lookup`**: the 8.9MB reference
database this planning document flagged for "a specific bundled-database
provenance check" turns out not to be part of the vendored source tree at
all — it is a separate, optional, user-supplied asset (confirmed via
`APP_ASSETS_PATH` and graceful missing-file handling in the real source).
This narrows, rather than widens, the licensing surface for this specific
app's import: only the ~48KB wrapper code's own license is in question,
not the database's.

### Updated summary (Phase 2C.1 supersedes the planning-phase rows above)

| App | License status (Phase 2C.1) | Recommendation |
|---|---|---|
| `sd_info` | **CONFIRMED — GPLv3, real LICENSE file read** | Cleared for import |
| `docviewlite` | **CONFIRMED — MIT, real LICENSE file read** | Cleared for import |
| `fcc_id_lookup` | **Elevated to DEFER — no LICENSE file in the vendored copy; strong but not commit-pinned corroborating MIT evidence at the true upstream repo** | DEFER, excluded from the near-term batch pending a dedicated follow-up license confirmation (low-effort, not equivalent to `c_book`'s unresolved status) |

See `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` for the complete,
per-app evidence (file listings, exact grep results, full SHA-256 hashes)
behind this update.

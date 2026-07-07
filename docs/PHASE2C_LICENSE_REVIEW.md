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

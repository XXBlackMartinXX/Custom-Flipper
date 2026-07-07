# Phase 2D — License Review

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2D_RECOMMENDED_BATCH.md`.

## Honest scope statement

**No per-app `LICENSE` file, SPDX header, or license text has actually
been read in this phase.** This is a planning-only phase by explicit
instruction, and real source/license verification is deliberately
deferred to Phase 2D.1 (see `docs/PHASE2D_NEXT_GATE.md`) — the same
sequencing Phase 2C used, where Phase 2C's own planning document recorded
all 3 of its recommended apps as `NEEDS REVIEW (routine)` and only Phase
2C.1, a separate, explicitly-approved verification phase, obtained and
read the real `LICENSE` files (finding, in that instance, that
`fcc_id_lookup`'s vendored copy had none at all — the exact kind of gap
this routine step exists to catch). Everything below is either (a) a
citation of what the existing Phase 1.5/1.6 audits already recorded
(author/README/`fap_weburl`/version presence — attribution evidence, not
a license-text confirmation), or (b) an honest `NEEDS REVIEW` for
anything those audits did not check.

## `resistors`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — not captured by the Phase 1.5/1.6 audits (they confirmed a real author/README/`fap_weburl`/version exist, per the Top-25 baseline bar, but did not record an SPDX identifier or read a `LICENSE` file). |
| Source of license evidence | Phase 1.5 baseline screening only (attribution present, not license text). |
| Bundled third-party code/data | None identified as *code* — the ~2.3MB footprint Phase 1.5 flagged is described as "likely icon/reference assets," not vendored code. The nature of those assets (self-authored vs. sourced elsewhere) has not been confirmed in any phase and should be checked at Phase 2D.1 alongside the license itself. |
| Missing/unclear license issue | The wrapper app's own license is unconfirmed (routine gap). The bundled asset footprint's provenance is a real open question, flagged here for the first time at this level of specificity — not yet a finding of a problem, but not yet cleared either. |
| Acceptable for import planning | Yes — nothing found that would block planning; the actual `LICENSE`/header and the bundled-asset provenance must both be confirmed at Phase 2D.1. |
| Legal review needed | Slightly elevated over the routine step specifically for the bundled asset footprint (confirm it is not a rights-encumbered third-party icon set); the wrapper code's own license is a standard read-the-file step. |
| Should be deferred | No — acceptable for planning with the asset-provenance check specifically flagged for Phase 2D.1. |

## `crypto_dictionary`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as `resistors`. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data | **Bundles a cipher-terminology glossary** as reference text. Confirmed by Phase 1.6 to be definitional/reference content, not functional cryptographic code operating on user data. Cipher terminology itself (e.g. "Caesar cipher," "one-time pad") is standard technical vocabulary, not creative-work text in the way `c_book`'s verbatim K&R chapters were — a materially different, much lower-severity case. Not yet confirmed against an actual license/attribution file. |
| Missing/unclear license issue | The wrapper app code's own license is unconfirmed (routine gap). The bundled glossary text's authorship/provenance is unconfirmed but low-concern given its technical-reference nature — flagged for confirmation at Phase 2D.1, not treated as clear. |
| Acceptable for import planning | Yes — the "offline glossary" characterization from Phase 1.6 is a reasonable basis for planning-stage inclusion, matching the project owner's own special-caution instruction for this app. |
| Legal review needed | Standard read-at-import-time step for the wrapper code; a light confirmation that the glossary text is original or otherwise freely reproducible reference material, not copied verbatim from a specific copyrighted source (e.g. a textbook) — lower bar than `c_book`'s concern, but not zero effort. |
| Should be deferred | No. |

## `2048`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as the other two. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data | None identified — 4 files, per Phase 1.6 audit. The 2048 puzzle *concept* is not copyrightable (as already established for `sudoku` in Phase 2B); only this specific implementation's code license matters, and that has not been read yet. |
| Missing/unclear license issue | Not confirmed, no third-party-provenance concern identified. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step, not elevated. |
| Should be deferred | No. |

## Summary

| App | License status | Recommendation |
|---|---|---|
| `resistors` | NEEDS REVIEW (routine for wrapper code; specific bundled-asset provenance check flagged for Phase 2D.1) | Acceptable for import planning, with that one specific check flagged |
| `crypto_dictionary` | NEEDS REVIEW (routine for wrapper code; light glossary-provenance confirmation flagged for Phase 2D.1) | Acceptable for import planning |
| `2048` | NEEDS REVIEW (routine — read at Phase 2D.1) | Acceptable for import planning |

No license has been declared clean by this document for any app —
"routine" above means the gap is the same ordinary read-the-license-file
step every prior app in this project also required before its own
import, not a finding of an actual problem. None of the 3 recommended
apps carry an elevated concern of the kind `c_book` did (verbatim
copyrighted book text) or `fcc_id_lookup` did (no license file at all in
the vendored copy) — this batch was deliberately selected to avoid both
classes of concern, per `docs/PHASE2D_RECOMMENDED_BATCH.md`'s selection
logic.

## What Phase 2D.1 would need to do (not performed here)

Mirroring exactly what Phase 2B.1 and Phase 2C.1 did for their own
batches: obtain real network access to the actual upstream source
(`RogueMaster/flipperzero-firmware-wPlugins` at the same audited commit,
or whatever commit is current at that time), fetch each of these 3 apps'
actual `LICENSE` files, read them in full, confirm GPLv3/MIT (or
whatever license is found) compatibility, and — specifically — confirm
`resistors`'s bundled asset footprint's own provenance and
`crypto_dictionary`'s glossary text's own provenance, rather than
assuming either from the Phase 1.6 description alone. Until that
happens, this document does not declare any of these 3 apps
license-clear, consistent with never claiming a license is confirmed
without having actually read it.

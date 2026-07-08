# Phase 2F — License Review

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2F_RECOMMENDED_BATCH.md`.

## Honest scope statement

**No per-app `LICENSE` file, SPDX header, or license text has actually
been read in this phase.** This is a planning-only phase by explicit
instruction, and real source/license verification is deliberately
deferred to Phase 2F.1 (see `docs/PHASE2F_NEXT_GATE.md`) — the same
sequencing Phase 2B/2C/2D/2E used, where each planning document recorded
its recommended apps as `NEEDS REVIEW (routine)` and only the
corresponding X.1 phase, a separate, explicitly-approved verification
phase, obtained and read the real `LICENSE` files (finding, for
`fcc_id_lookup` in Phase 2C.1, that the vendored copy had none at all —
the exact kind of gap this routine step exists to catch). Everything
below is either (a) a citation of what the existing Phase 1.5/1.6 audits
already recorded (author/README/`fap_weburl`/version presence —
attribution evidence, not a license-text confirmation), or (b) an honest
`NEEDS REVIEW` for anything those audits did not check.

## `hex_viewer`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — not captured by the Phase 1.5/1.6 audits (they confirmed a real author/README/`fap_weburl`/version exist, per the Top-25 baseline bar, but did not record an SPDX identifier or read a `LICENSE` file). `application.fam` itself declares no license field ("None declared" per Phase 1.5's own screening column). |
| Source of license evidence | Phase 1.5 baseline screening only (attribution present, not license text). |
| Bundled third-party code/data/assets/text | None identified — Phase 1.6 describes 20 files across `helpers/`, `views/`, `scenes/` as the app's own implementation, no vendored third-party material noted. |
| Missing/unclear license issue | The wrapper app's own license is unconfirmed (routine gap only) — no additional named provenance concern beyond that. |
| Acceptable for import planning | Yes — nothing found that would block planning; the actual `LICENSE`/header must be confirmed at Phase 2F.1. |
| Legal review needed | Standard read-at-import-time step only; no elevated concern identified. |
| Should be deferred | No, on license grounds — but see `docs/PHASE2F_RISK_REGISTER.md` for the separate, unresolved storage-behavior question that could independently trigger deferral at Phase 2F.1. |

## `qrcode`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as `hex_viewer`. `application.fam` declares no license field. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data/assets/text | None identified — Phase 1.6 describes a self-contained 3-file implementation, no vendored third-party material noted. |
| Missing/unclear license issue | The wrapper code's own license is unconfirmed (routine gap only) — no additional named concern beyond that. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step only; no elevated concern identified. |
| Should be deferred | No. |

## `barcode_gen`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as the other two. `application.fam` declares no license field. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data/assets/text | **4 bundled encoding-table `.txt` files** (Code39/128/128C/Codabar), per Phase 1.6. These are standard, publicly documented barcode-symbology lookup tables (open technical standards, e.g. Code 39/128 character-to-bar-pattern mappings), not creative works — a materially lower provenance concern than `image_viewer`'s bundled bitmap images were, but their exact source/authorship within this specific app has not been directly confirmed in any phase. |
| Missing/unclear license issue | The wrapper app's own license is unconfirmed (routine gap). The 4 bundled encoding-table files' exact provenance (authored for this app vs. transcribed from a public standard document) is a real, named, unresolved question — lower severity than a creative-work provenance question, but not yet cleared. |
| Acceptable for import planning | Yes — nothing found that would block planning; both the wrapper's `LICENSE`/header and the bundled tables' provenance must be confirmed at Phase 2F.1. |
| Legal review needed | Slightly elevated over the routine step, specifically for the 4 bundled encoding-table files (confirm they are standard-technical-data transcriptions, not a third-party author's original creative compilation with its own separate rights). |
| Should be deferred | No — acceptable for planning with the bundled-table provenance specifically flagged for Phase 2F.1. |

## Clear statement

**Direct source/license verification is still required before import**
for all 3 apps above. Nothing in this document authorizes import — it
records the current state of license evidence (routine `NEEDS REVIEW`
for all 3, with an additional named provenance question for
`barcode_gen`'s bundled encoding tables) so that Phase 2F.1 knows exactly
what to confirm, the same sequencing every prior phase in this project
has used.

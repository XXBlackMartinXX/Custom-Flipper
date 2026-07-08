# Phase 2E — License Review

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2E_RECOMMENDED_BATCH.md`.

## Honest scope statement

**No per-app `LICENSE` file, SPDX header, or license text has actually
been read in this phase.** This is a planning-only phase by explicit
instruction, and real source/license verification is deliberately
deferred to Phase 2E.1 (see `docs/PHASE2E_NEXT_GATE.md`) — the same
sequencing Phase 2B/2C/2D used, where each planning document recorded its
recommended apps as `NEEDS REVIEW (routine)` and only the corresponding
X.1 phase, a separate, explicitly-approved verification phase, obtained
and read the real `LICENSE` files (finding, for `fcc_id_lookup` in Phase
2C.1, that the vendored copy had none at all — the exact kind of gap
this routine step exists to catch). Everything below is either (a) a
citation of what the existing Phase 1.5/1.6 audits already recorded
(author/README/`fap_weburl`/version presence — attribution evidence, not
a license-text confirmation), or (b) an honest `NEEDS REVIEW` for
anything those audits did not check.

## `image_viewer`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — not captured by the Phase 1.5/1.6 audits (they confirmed a real author/README/`fap_weburl`/version exist, per the Top-25 baseline bar, but did not record an SPDX identifier or read a `LICENSE` file). `application.fam` itself declares no license field ("None declared" per Phase 1.5's own screening column). |
| Source of license evidence | Phase 1.5 baseline screening only (attribution present, not license text). |
| Bundled third-party code/data/assets/text | **3 bundled example `.bm` bitmap files.** Phase 1.6 confirms these ship with the app; their own authorship/provenance (original artwork authored for this app vs. sourced from elsewhere) has not been confirmed in any phase. This is a real, named, unresolved question — more significant than a technical-standard data table (like `barcode_gen`'s) because example images could plausibly be original creative work with their own separate rights holder. |
| Missing/unclear license issue | The wrapper app's own license is unconfirmed (routine gap). The bundled bitmap files' provenance is a real open question, carried forward unchanged from `docs/PHASE2D_CANDIDATE_REVIEW.md`'s identical note — not yet a finding of a problem, but not yet cleared either. |
| Acceptable for import planning | Yes — nothing found that would block planning; the actual `LICENSE`/header and the bundled-bitmap provenance must both be confirmed at Phase 2E.1. |
| Legal review needed | Slightly elevated over the routine step specifically for the 3 bundled bitmap files (confirm they are not rights-encumbered third-party images); the wrapper code's own license is a standard read-the-file step. |
| Should be deferred | No — acceptable for planning with the bitmap-provenance check specifically flagged for Phase 2E.1. |

## `boilerplate`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as `image_viewer`. `application.fam` declares no license field. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data/assets/text | None identified — Phase 1.6 describes this as "a full template app with helpers/views/scenes," self-authored demonstration code, not vendored third-party material. |
| Missing/unclear license issue | The wrapper/template code's own license is unconfirmed (routine gap only) — no additional named concern beyond that. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step only; no elevated concern identified. |
| Should be deferred | No. |

## `minesweeper`

| Field | Value |
|---|---|
| Declared license | **NEEDS REVIEW** — same gap as the other two. `application.fam` declares no license field. |
| Source of license evidence | Phase 1.5 baseline screening only. |
| Bundled third-party code/data/assets/text | None identified as third-party — Phase 1.6 describes a self-contained implementation ("full Minesweeper with a solver/hint engine") across `helpers/`, `views/`, `engine/`, `scenes/`; no bundled external assets, text, or data files noted. |
| Missing/unclear license issue | The wrapper code's own license is unconfirmed (routine gap only) — no additional named concern beyond that. |
| Acceptable for import planning | Yes. |
| Legal review needed | Standard read-at-import-time step only; no elevated concern identified. |
| Should be deferred | No. |

## Clear statement

**Direct source/license verification is still required before import**
for all 3 apps above. Nothing in this document authorizes import — it
records the current state of license evidence (routine `NEEDS REVIEW`
for all 3, with an additional named provenance question for
`image_viewer`'s bundled bitmaps) so that Phase 2E.1 knows exactly what
to confirm, the same sequencing every prior phase in this project has
used.

---

## Phase 2E.1 update: real license verification performed — all 3 resolved

**This section supersedes the planning-stage `NEEDS REVIEW` status above
for the current decision point. The original planning-stage findings
above are left unmodified as the historical record; do not read this as
retroactively editing them.** Phase 2E.1 obtained real network access to
the pinned RogueMaster commit (`472f6925e8aca9bd031cb37e3cb80b551772c957`)
and read each app's actual `LICENSE`/`README`/source directly. Full
evidence is in `docs/PHASE2E_1_SOURCE_LICENSE_VERIFICATION.md` and
`docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`; this is a summary.

- **`image_viewer`**: **RESOLVED — MIT**, full unmodified license text
  confirmed directly (Ivan Polushin/polioan, 2024). The planning-stage
  bundled-bitmap provenance question was not merely resolved but
  **confirmed to be a real problem**: `spongebob.bm` (one of the 3
  bundled example images) was decoded and visually confirmed to depict a
  recognizable trademarked/copyrighted cartoon character with no
  attribution anywhere in the app. Resolution: exclude the entire
  `example_images/` directory from the import scope (none of the 3 files
  are required for the app to build or function) — not a license
  blocker for the app's own MIT-licensed wrapper code, but a hard
  import-scope condition.
- **`boilerplate`**: **RESOLVED — informal permissive grant, not a formal
  license.** No `LICENSE` file exists (confirmed by an exhaustive file
  listing), but `README.md`'s own "## Licensing" section states plainly
  "This code is open-source and may be used for whatever you want to do
  with it." Treated as sufficient, real evidence to clear the app for
  import — recorded honestly as a weaker evidence tier than a formal
  license text, not silently upgraded to "MIT-equivalent." Condition:
  preserve this exact statement in the project's own attribution record
  at import time.
- **`minesweeper`**: **RESOLVED — MIT**, full unmodified license text
  confirmed directly (Alexander Rodriguez/squee72564, 2024). No bundled
  third-party code/data/assets/text found beyond original game sprites;
  its one third-party header dependency (M\*LIB's `m-deque.h`) is already
  satisfied by this project's existing `lib/mlib` base-firmware
  submodule. No import-scope condition beyond routine MIT attribution.

**All 3 apps: CLEARED FOR IMPORT** (two with a condition/note, detailed
above and in `docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`). See
`docs/PHASE2E_1_GO_NO_GO.md` for the final Phase 2E.1 classification.
Direct source/license verification is complete for this batch — the next
gate is Phase 2E.2 implementation, on explicit request only.

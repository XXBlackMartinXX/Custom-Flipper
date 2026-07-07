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

---

## Phase 2D.1 verification update (real source read — supersedes the "routine NEEDS REVIEW" status above for all 3 apps)

**This section adds new, direct evidence gathered in Phase 2D.1. The
planning-phase content above is left unmodified as the historical record
of what was and wasn't known at that time; do not read this section as
retroactively editing it.**

In Phase 2D.1, this environment had real, working network access to fetch
actual upstream source. A real `git fetch`/`checkout` of
`RogueMaster/flipperzero-firmware-wPlugins` at commit
`472f6925e8aca9bd031cb37e3cb80b551772c957` (the exact commit every prior
audit in this project has cited, confirmed via `git rev-parse FETCH_HEAD`
with no discrepancy) retrieved each app's actual `LICENSE` file — all 3
were present, and all 3 were read in full:

| App | Declared license (confirmed by direct read) | Copyright holder |
|---|---|---|
| `resistors` | **MIT** (full, unmodified text) | Lewis Westbury (2023) |
| `crypto_dictionary` | **GPLv3** (full, unmodified FSF text) | Not individually named in-file (standard for many hobbyist GPLv3 projects) |
| `2048` | **MIT** (full, unmodified text) | Eugene Kirzhanov (2022) |

**All 3 apps had a real `LICENSE` file present directly in the exact
vendored artifact this project would import** — a materially different
(and better) outcome than Phase 2C.1, where `fcc_id_lookup`'s vendored
copy had no `LICENSE` file at all. No license-evidence gap exists for any
of these 3 apps' own code.

**`resistors` — MIT compatibility**: same reasoning already applied to
`flipfetch`/`quadratic_solver`/`sudoku`/`docviewlite`. **Attribution
required**: yes, per MIT's standard terms, crediting Lewis Westbury and
the `shalebridge` fork `README.md` itself already credits for the 1.4
feature set.

**`resistors` — the bundled-asset-provenance question, resolved by scope,
not by guessing.** The planning-phase content above flagged this app's
"~2.3MB bundled asset footprint" for a specific provenance check. The
real source read found this figure describes the *upstream repository*
as a whole, not the build's actual inputs: `application.fam` only
references `resistors.png` (4K) and `images/` (24K) — small, original,
1-bit pixel-art icons with no provenance concern. The remaining ~2.3MB
(`.flipcorg/`, `design/`, `img/`, `screenshots/`) is not consumed by the
build at all, and two files within it
(`design/resistor_{4,5}_src.jpg`/`.webp`) have genuinely unclear
photographic-reference provenance (no EXIF, no credit, no separate
asset license). **Resolution**: those directories are excluded from the
import scope entirely — the same strategy this project used for
`fcc_id_lookup`'s 8.9MB database in Phase 2C.1 (scope the import to what
is actually needed and has clear provenance, rather than either
guessing the unclear material is fine or blocking the whole app over
content it doesn't need to ship). This is a **narrowing, not a
disqualification** — `resistors` remains cleared.

**`crypto_dictionary` — GPLv3 compatibility**: the most direct possible
compatibility case — the app is licensed under the exact same license as
this project's own firmware base (same class of finding as `sd_info` in
Phase 2C.1). **Attribution required**: yes, per GPLv3's standard terms.

**`crypto_dictionary` — glossary-provenance question, resolved
favorably.** The planning-phase content above (and the Phase 2D risk
register) flagged a specific concern that the glossary text might contain
copied third-party material, or might itself trigger safety-keyword
false positives (e.g. "credential," "brute force"). The real source read
found the 14 bundled `resources/symmetric_cipher/*.txt` files are short,
distinctively hand-authored ASCII-art reference cards (a consistent
personal style, including idiosyncratic spelling) describing only public,
non-copyrightable cipher specifications (key size, block size, rounds) —
no verbatim third-party text, and a full keyword scan (including this
phase's new `seed`/`wallet`/`private key`/`secret` terms) found **zero
matches anywhere**, including inside the glossary text itself. The app
was also directly confirmed to open its glossary files with
`FSAM_READ`/`FSOM_OPEN_EXISTING` only (no write call anywhere in the
source) and to perform no cryptographic operations on any data — it only
displays static reference text. This fully confirms, rather than merely
accepts on citation, the special-caution requirement that this app
handles no user credentials, wallet keys, tokens, seed phrases,
passwords, or secrets.

**`2048` — MIT compatibility**: same reasoning as `resistors` above.
**Attribution required**: yes, per MIT's standard terms; `README.md`
already credits Eugene Kirzhanov (2022).

**`2048` — storage behavior, confirmed with a real nuance.** The
planning-phase content above assumed a simple app-private high-score
save, matching `chess`/`sudoku`'s precedent. The real source read
confirms the save is effectively app-scoped
(`/ext/apps_data/game_2048/game_2048.save`) but built from a **hardcoded
literal path** rather than the idiomatic `APP_DATA_PATH` appid-based
macro `chess`/`sudoku` use, and additionally performs a one-time,
silently-no-op-on-fresh-install migration check against a legacy save
location (`/ext/apps/Games/game_2048.save`). Neither nuance changes the
app's clearance — the save remains non-colliding and non-shared — but
both are recorded precisely rather than smoothed into an unqualified
"zero-risk app-private save," the same discipline Phase 2C.1 applied to
`sd_info`'s SD-benchmark writes (a materially larger finding there; this
one is minor by comparison).

### Updated summary (Phase 2D.1 supersedes the planning-phase rows above)

| App | License status (Phase 2D.1) | Recommendation |
|---|---|---|
| `resistors` | **CONFIRMED — MIT, real LICENSE file read.** Bundled-asset-provenance question resolved by excluding the unclear-provenance, non-build-input directories from import scope | Cleared for import, with the import-scope condition recorded in `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` |
| `crypto_dictionary` | **CONFIRMED — GPLv3, real LICENSE file read.** Glossary-provenance question resolved favorably — original, non-copyrightable technical content, zero sensitive-keyword matches | Cleared for import, no conditions beyond standard GPLv3 attribution |
| `2048` | **CONFIRMED — MIT, real LICENSE file read.** Storage behavior confirmed app-scoped, with a documented hardcoded-path/legacy-migration nuance | Cleared for import, with the storage-documentation precision noted above |

See `docs/PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` for the complete,
per-app evidence (file listings, exact grep results, exact source
excerpts) behind this update, and `docs/PHASE2D_1_GO_NO_GO.md` for the
resulting batch recommendation.

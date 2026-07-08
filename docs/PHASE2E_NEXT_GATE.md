# Phase 2E — Next Gate

Docs only. This defines the gate that must be reviewed after Phase 2E
planning (this package) before any further phase — including Phase 2E.1
verification or Phase 2E implementation/import — is even considered. It
does not itself authorize either; it defines the checkpoint that comes
before that decision is made, mirroring `docs/PHASE2D_NEXT_GATE.md`'s
role for the Phase 2D batch.

## The gate, in order

1. **Phase 2E planning result must be reviewed first.** The project owner
   reviews `docs/PHASE2E_CANDIDATE_REVIEW.md`,
   `docs/PHASE2E_RECOMMENDED_BATCH.md`, `docs/PHASE2E_RISK_REGISTER.md`,
   `docs/PHASE2E_LICENSE_REVIEW.md`, `docs/PHASE2E_INTEGRATION_PLAN.md`,
   and this package's closing recommendation in
   `docs/PHASE2E_GO_NO_GO.md` (**GO WITH CONDITIONS**).

2. **If GO or GO WITH CONDITIONS**: the next gate is **Phase 2E.1 —
   pre-import source/license verification**, mirroring exactly what Phase
   2B.1, Phase 2C.1, and Phase 2D.1 did for their own batches: obtain
   real network access to the upstream RogueMaster source, fetch and read
   each of the 3 recommended apps' (`image_viewer`, `boilerplate`,
   `minesweeper`) actual `LICENSE` files and full source, confirm license
   compatibility and no undisclosed hardware/storage capability, and
   specifically confirm `image_viewer`'s bundled example bitmap files'
   own provenance, plus `boilerplate`'s and `minesweeper`'s exact
   app-private save paths. Phase 2E.1 is itself still verification-only —
   it does not import code either.

3. **Phase 2E implementation/import must not start until Phase 2E.1
   passes.** Even a clean Phase 2E.1 pass does not itself start import —
   as with every prior phase transition in this project, the project
   owner must explicitly request that import begin, following
   `docs/PHASE2E_INTEGRATION_PLAN.md`'s one-app-at-a-time,
   commit-per-app, validate-after-each discipline.

4. **If Phase 2E.1 finds a problem** (unclear license, undisclosed
   hardware capability, an actual storage-write behavior contradicting
   this planning phase's citation — the exact class of finding Phase
   2C.1 produced for `sd_info` — or source changes required outside an
   app's own directory), the affected app is re-classified DEFER or
   NEEDS REVIEW and is not imported until that specific problem is
   resolved — this does not automatically disqualify the other apps in
   the batch, per the per-app stop-condition discipline in
   `docs/PHASE2E_RISK_REGISTER.md`.

5. **Hardware remains NOT PERFORMED.** No hardware-connected validation
   mode, and no flashing, is authorized by this document or by Phase
   2E.1 — those remain gated behind their own CI-baseline-first ordering,
   identical to every prior phase's hardware gate
   (`tools/phase2a_hardware_gate.ps1`, `tools/phase2b_hardware_gate.ps1`,
   `tools/phase2c_hardware_gate.ps1`, `tools/phase2d_hardware_gate.ps1`),
   the last of which currently classifies as
   `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` in this AI
   session's own sandbox.

6. **Release-ready remains blocked**, regardless of which path is taken,
   until real hardware validation is actually complete (both the
   automated checks and a human-observed GUI checklist) and explicitly
   accepted — nothing in this document, or in Phase 2E.1, on its own,
   ever constitutes that acceptance.

7. **`fcc_id_lookup` remains deferred** until its license-evidence gap is
   resolved in a separate, narrow phase dedicated to exactly that
   question — nothing in Phase 2E planning, Phase 2E.1, or any future
   Phase 2E implementation resolves it as a side effect.

## Current status against this gate (as of Phase 2E planning): PLANNING COMPLETE, AWAITING REVIEW

| Step | Status |
|---|---|
| Phase 2E candidate review | Complete — `docs/PHASE2E_CANDIDATE_REVIEW.md` |
| Phase 2E recommended batch | Complete — 3 apps (`image_viewer`, `boilerplate`, `minesweeper`), `docs/PHASE2E_RECOMMENDED_BATCH.md` |
| Phase 2E risk register | Complete — `docs/PHASE2E_RISK_REGISTER.md` |
| Phase 2E license review | Complete (citation-only, all 3 marked routine `NEEDS REVIEW`) — `docs/PHASE2E_LICENSE_REVIEW.md` |
| Phase 2E integration plan | Complete — `docs/PHASE2E_INTEGRATION_PLAN.md` |
| Phase 2E go/no-go | **GO WITH CONDITIONS** — `docs/PHASE2E_GO_NO_GO.md` |
| Phase 2E.1 (pre-import verification) | **Not started.** Requires the project owner's own explicit further request. |
| Phase 2E implementation/import | **Not started.** Gated behind Phase 2E.1 passing, then its own separate explicit request. |
| Hardware-assisted validation | Unchanged from Phase 2D.4 — `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, see `docs/PHASE2D_HARDWARE_ASSISTED_RESULTS.md`. Nothing in this phase touches hardware. |
| `fcc_id_lookup` license gap | Unchanged — still open, see `docs/KNOWN_ISSUES.md` item 6. Not touched by this phase. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Next allowed paths

- **Path A — Phase 2E.1 pre-import source/license verification**, only
  once the project owner explicitly requests it: fresh network read of
  `image_viewer`/`boilerplate`/`minesweeper`'s actual upstream source and
  `LICENSE` files, the same discipline Phase 2B.1, Phase 2C.1, and Phase
  2D.1 applied to their own batches.
- **Path B — a different/expanded planning pass**, if the project owner
  wants to reconsider batch composition (e.g. draw in `hex_viewer`,
  `qrcode`, or `barcode_gen` instead, once their storage ambiguity is
  separately resolved) before committing to Phase 2E.1.
- **Path C — `fcc_id_lookup`'s narrow license follow-up**, entirely
  separate from Phase 2E: fetch the confirmed upstream `LICENSE`
  (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it applied to
  the specific historical revision RogueMaster vendored, before that app
  can be reconsidered for any future batch. Not resolved by this
  document, and not part of Phase 2E's own scope.

Neither Path A nor Path B is started by this document, and Path C is
explicitly out of scope for Phase 2E entirely.

## What this gate does not authorize

- **Does not start Phase 2E.1.** See Path A above — verification only, on
  explicit request.
- **Does not start Phase 2E implementation/import.** That requires Phase
  2E.1 to pass first, and then its own further explicit request — two
  separate gates, not one.
- **Does not constitute hardware testing.** Hardware testing remains
  whatever a human actually performs on real hardware with a filled-in
  smoke-test checklist — nothing less, and nothing in this document
  changes that.
- **Does not resolve `fcc_id_lookup`'s license gap.** See Path C above —
  a separate, narrow, explicitly-requested follow-up outside Phase 2E's
  own scope.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2E
  alone.

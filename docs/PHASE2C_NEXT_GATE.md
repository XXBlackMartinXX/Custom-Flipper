# Phase 2C — Next Gate

Docs only. This defines the gate that must be reviewed after Phase 2C
planning (this package) before any further phase — including Phase 2C.1
verification or Phase 2C implementation/import — is even considered. It
does not itself authorize either; it defines the checkpoint that comes
before that decision is made, mirroring `docs/PHASE2B_NEXT_GATE.md`'s role
for the Phase 2B batch.

## The gate, in order

1. **Phase 2C planning result must be reviewed first.** The project owner
   reviews `docs/PHASE2C_CANDIDATE_REVIEW.md`,
   `docs/PHASE2C_RECOMMENDED_BATCH.md`, `docs/PHASE2C_RISK_REGISTER.md`,
   `docs/PHASE2C_LICENSE_REVIEW.md`, `docs/PHASE2C_INTEGRATION_PLAN.md`,
   and this package's closing recommendation in
   `docs/PHASE2C_GO_NO_GO.md` (**GO WITH CONDITIONS**).

2. **If GO or GO WITH CONDITIONS**: the next gate is **Phase 2C.1 —
   pre-import source/license verification**, mirroring exactly what Phase
   2B.1 did for `flipfetch`/`quadratic_solver`/`sudoku`: obtain real
   network access to the upstream RogueMaster source, fetch and read each
   of the 3 recommended apps' (`sd_info`, `fcc_id_lookup`, `docviewlite`)
   actual `LICENSE` files and full source, confirm GPLv3 compatibility and
   no undisclosed hardware/storage capability, and specifically confirm
   `fcc_id_lookup`'s bundled database provenance. Phase 2C.1 is itself
   still verification-only — it does not import code either.

3. **Phase 2C implementation/import must not start until Phase 2C.1
   passes.** Even a clean Phase 2C.1 pass does not itself start import —
   as with every prior phase transition in this project, the project owner
   must explicitly request that import begin, following
   `docs/PHASE2C_INTEGRATION_PLAN.md`'s one-app-at-a-time,
   commit-per-app, validate-after-each discipline.

4. **If Phase 2C.1 finds a problem** (unclear license, undisclosed
   hardware capability, source changes required outside an app's own
   directory), the affected app is re-classified DEFER or NEEDS REVIEW and
   is not imported until that specific problem is resolved — this does
   not automatically disqualify the other apps in the batch, per the
   per-app stop-condition discipline in `docs/PHASE2C_RISK_REGISTER.md`.

5. **Hardware remains NOT PERFORMED.** No hardware-connected validation
   mode, and no flashing, is authorized by this document or by Phase 2C.1
   — those remain gated behind their own CI-baseline-first ordering,
   identical to Phase 2A's and Phase 2B's hardware gates
   (`tools/phase2a_hardware_gate.ps1`, `tools/phase2b_hardware_gate.ps1`),
   both of which currently classify as `HARDWARE VALIDATION BLOCKED -
   DEVICE NOT AVAILABLE` in this AI session's own sandbox.

6. **Release-ready remains blocked**, regardless of which path is taken,
   until real hardware validation is actually complete (both the automated
   checks and a human-observed GUI checklist) and explicitly accepted —
   nothing in this document, or in Phase 2C.1, on its own, ever
   constitutes that acceptance.

## Current status against this gate (as of Phase 2C planning): PLANNING COMPLETE, AWAITING REVIEW

| Step | Status |
|---|---|
| Phase 2C candidate review | Complete — `docs/PHASE2C_CANDIDATE_REVIEW.md` |
| Phase 2C recommended batch | Complete — 3 apps (`sd_info`, `fcc_id_lookup`, `docviewlite`), `docs/PHASE2C_RECOMMENDED_BATCH.md` |
| Phase 2C risk register | Complete — `docs/PHASE2C_RISK_REGISTER.md` |
| Phase 2C license review | Complete (citation-only, all 3 marked routine `NEEDS REVIEW`) — `docs/PHASE2C_LICENSE_REVIEW.md` |
| Phase 2C integration plan | Complete — `docs/PHASE2C_INTEGRATION_PLAN.md` |
| Phase 2C go/no-go | **GO WITH CONDITIONS** — `docs/PHASE2C_GO_NO_GO.md` |
| Phase 2C.1 (pre-import verification) | **Not started.** Requires the project owner's own explicit further request. |
| Phase 2C implementation/import | **Not started.** Gated behind Phase 2C.1 passing, then its own separate explicit request. |
| Hardware-assisted validation | Unchanged from Phase 2B.4 — `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, see `docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md`. Nothing in this phase touches hardware. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Next allowed paths

- **Path A — Phase 2C.1 pre-import source/license verification**, only
  once the project owner explicitly requests it: fresh network read of
  `sd_info`/`fcc_id_lookup`/`docviewlite`'s actual upstream source and
  `LICENSE` files, the same discipline Phase 2B.1 applied to its own
  3-app batch.
- **Path B — a different/expanded planning pass**, if the project owner
  wants to reconsider batch composition (e.g. draw from the remaining
  9-app pool instead, or revisit one of the 5 hard-deferred apps with a
  dedicated capability/license review of its own) before committing to
  Phase 2C.1.

Neither path is started by this document.

## What this gate does not authorize

- **Does not start Phase 2C.1.** See Path A above — verification only, on
  explicit request.
- **Does not start Phase 2C implementation/import.** That requires Phase
  2C.1 to pass first, and then its own further explicit request — two
  separate gates, not one.
- **Does not constitute hardware testing.** Hardware testing remains
  whatever a human actually performs on real hardware with a filled-in
  smoke-test checklist — nothing less, and nothing in this document
  changes that.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2C
  alone.

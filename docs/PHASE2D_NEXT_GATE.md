# Phase 2D — Next Gate

Docs only. This defines the gate that must be reviewed after Phase 2D
planning (this package) before any further phase — including Phase 2D.1
verification or Phase 2D implementation/import — is even considered. It
does not itself authorize either; it defines the checkpoint that comes
before that decision is made, mirroring `docs/PHASE2C_NEXT_GATE.md`'s
role for the Phase 2C batch.

## The gate, in order

1. **Phase 2D planning result must be reviewed first.** The project owner
   reviews `docs/PHASE2D_CANDIDATE_REVIEW.md`,
   `docs/PHASE2D_RECOMMENDED_BATCH.md`, `docs/PHASE2D_RISK_REGISTER.md`,
   `docs/PHASE2D_LICENSE_REVIEW.md`, `docs/PHASE2D_INTEGRATION_PLAN.md`,
   and this package's closing recommendation in
   `docs/PHASE2D_GO_NO_GO.md` (**GO WITH CONDITIONS**).

2. **If GO or GO WITH CONDITIONS**: the next gate is **Phase 2D.1 —
   pre-import source/license verification**, mirroring exactly what Phase
   2B.1 and Phase 2C.1 did for their own batches: obtain real network
   access to the upstream RogueMaster source, fetch and read each of the
   3 recommended apps' (`resistors`, `crypto_dictionary`, `2048`) actual
   `LICENSE` files and full source, confirm license compatibility and no
   undisclosed hardware/storage capability, and specifically confirm
   `resistors`'s bundled asset footprint's own provenance and
   `crypto_dictionary`'s glossary text's own provenance. Phase 2D.1 is
   itself still verification-only — it does not import code either.

3. **Phase 2D implementation/import must not start until Phase 2D.1
   passes.** Even a clean Phase 2D.1 pass does not itself start import —
   as with every prior phase transition in this project, the project
   owner must explicitly request that import begin, following
   `docs/PHASE2D_INTEGRATION_PLAN.md`'s one-app-at-a-time,
   commit-per-app, validate-after-each discipline.

4. **If Phase 2D.1 finds a problem** (unclear license, undisclosed
   hardware capability, an actual storage-write behavior contradicting
   this planning phase's citation — the exact class of finding Phase
   2C.1 produced for `sd_info` — or source changes required outside an
   app's own directory), the affected app is re-classified DEFER or
   NEEDS REVIEW and is not imported until that specific problem is
   resolved — this does not automatically disqualify the other apps in
   the batch, per the per-app stop-condition discipline in
   `docs/PHASE2D_RISK_REGISTER.md`.

5. **Hardware remains NOT PERFORMED.** No hardware-connected validation
   mode, and no flashing, is authorized by this document or by Phase
   2D.1 — those remain gated behind their own CI-baseline-first ordering,
   identical to every prior phase's hardware gate
   (`tools/phase2a_hardware_gate.ps1`, `tools/phase2b_hardware_gate.ps1`,
   `tools/phase2c_hardware_gate.ps1`), all of which currently classify as
   `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` in this AI
   session's own sandbox.

6. **Release-ready remains blocked**, regardless of which path is taken,
   until real hardware validation is actually complete (both the
   automated checks and a human-observed GUI checklist) and explicitly
   accepted — nothing in this document, or in Phase 2D.1, on its own,
   ever constitutes that acceptance.

7. **`fcc_id_lookup` remains deferred** until its license-evidence gap is
   resolved in a separate, narrow phase dedicated to exactly that
   question — nothing in Phase 2D planning, Phase 2D.1, or any future
   Phase 2D implementation resolves it as a side effect.

## Current status against this gate (as of Phase 2D planning): PLANNING COMPLETE, AWAITING REVIEW

| Step | Status |
|---|---|
| Phase 2D candidate review | Complete — `docs/PHASE2D_CANDIDATE_REVIEW.md` |
| Phase 2D recommended batch | Complete — 3 apps (`resistors`, `crypto_dictionary`, `2048`), `docs/PHASE2D_RECOMMENDED_BATCH.md` |
| Phase 2D risk register | Complete — `docs/PHASE2D_RISK_REGISTER.md` |
| Phase 2D license review | Complete (citation-only, all 3 marked routine `NEEDS REVIEW`) — `docs/PHASE2D_LICENSE_REVIEW.md` |
| Phase 2D integration plan | Complete — `docs/PHASE2D_INTEGRATION_PLAN.md` |
| Phase 2D go/no-go | **GO WITH CONDITIONS** — `docs/PHASE2D_GO_NO_GO.md` |
| Phase 2D.1 (pre-import verification) | **Not started.** Requires the project owner's own explicit further request. |
| Phase 2D implementation/import | **Not started.** Gated behind Phase 2D.1 passing, then its own separate explicit request. |
| Hardware-assisted validation | Unchanged from Phase 2C.4 — `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, see `docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md`. Nothing in this phase touches hardware. |
| `fcc_id_lookup` license gap | Unchanged — still open, see `docs/KNOWN_ISSUES.md` item 6. Not touched by this phase. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Next allowed paths

- **Path A — Phase 2D.1 pre-import source/license verification**, only
  once the project owner explicitly requests it: fresh network read of
  `resistors`/`crypto_dictionary`/`2048`'s actual upstream source and
  `LICENSE` files, the same discipline Phase 2B.1 and Phase 2C.1 applied
  to their own batches.
- **Path B — a different/expanded planning pass**, if the project owner
  wants to reconsider batch composition (e.g. draw from the remaining
  6-app pool instead — `minesweeper`, `hex_viewer`, `image_viewer`,
  `boilerplate`, `qrcode`, `barcode_gen` — or revisit one of the 6
  hard-deferred/excluded apps with a dedicated capability/license review
  of its own) before committing to Phase 2D.1.
- **Path C — `fcc_id_lookup`'s narrow license follow-up**, entirely
  separate from Phase 2D: fetch the confirmed upstream `LICENSE`
  (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it applied to
  the specific historical revision RogueMaster vendored, before that app
  can be reconsidered for any future batch. Not resolved by this
  document, and not part of Phase 2D's own scope.

Neither Path A nor Path B is started by this document, and Path C is
explicitly out of scope for Phase 2D entirely.

## What this gate does not authorize

- **Does not start Phase 2D.1.** See Path A above — verification only, on
  explicit request.
- **Does not start Phase 2D implementation/import.** That requires Phase
  2D.1 to pass first, and then its own further explicit request — two
  separate gates, not one.
- **Does not constitute hardware testing.** Hardware testing remains
  whatever a human actually performs on real hardware with a filled-in
  smoke-test checklist — nothing less, and nothing in this document
  changes that.
- **Does not resolve `fcc_id_lookup`'s license gap.** See Path C above —
  a separate, narrow, explicitly-requested follow-up outside Phase 2D's
  own scope.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2D
  alone.

---

## Phase 2D.3 update: CI baseline acceptance and artifact hash finalization

**This section supersedes the planning-stage gate above for the current
decision point. The original content is left unmodified as the
historical record; do not read this as retroactively editing it.**

Phase 2D.1 (pre-import verification), Phase 2D.2 (implementation/import,
3 apps: `resistors`, `crypto_dictionary`, `2048`), and Phase 2D.2A
(`updater_package` CI blocker diagnosis and remediation) have all
completed. Phase 2D.3 (this update) creates the formal CI baseline
acceptance record and finalizes real artifact hashes — see
`docs/PHASE2D_3_ACCEPTANCE_RECORD.md`, `docs/PHASE2D_3_ARTIFACT_MANIFEST.md`,
`docs/PHASE2D_3_ARTIFACT_HASHES.md`, and `docs/PHASE2D_3_GO_NO_GO.md`.

### Current status against this gate (as of Phase 2D.3)

| Step | Status |
|---|---|
| Phase 2D planning | Complete — **GO WITH CONDITIONS** |
| Phase 2D.1 (pre-import verification) | Complete — all 3 apps cleared |
| Phase 2D.2 (implementation/import) | Complete — **PHASE 2D.2 IMPORT PASS WITH CI TOOLING REMEDIATION NOTE** |
| Phase 2D.2A (`updater_package` CI blocker) | Complete — **RESOLVED** (with an honest intermittent-pre-fix-failure caveat, never erased) |
| Phase 2D.3 (CI baseline acceptance / hash finalization) | See `docs/PHASE2D_3_GO_NO_GO.md` for the real, current result |
| Hardware-assisted validation | Unchanged — no device, no Windows machine available in this AI session's environment |
| `fcc_id_lookup` license gap | Unchanged — still open, untouched by any Phase 2D sub-phase |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged |

### Next allowed paths (from Phase 2D.3 onward)

- **If Phase 2D.3 finalization PASSES** (real artifact hashes generated,
  both baseline tags created/verified): the next allowed path is either
  **a Phase 2D hardware-assisted validation gate** (modeled on
  `tools/phase2c_hardware_gate.ps1`, only if/when a device and Windows
  machine become available, and only on explicit request) or
  **Phase 2E planning only** (not import) — both require the project
  owner's own separate, explicit request, exactly as every prior phase
  transition in this project has required.
- **If artifact hashing or tag creation is blocked**: that must be
  resolved before any further Phase 2D or Phase 2E gate — see
  `docs/PHASE2D_3_GO_NO_GO.md`'s "Finalization workflow result" section
  for the real, current blocker if one exists, and
  `docs/KNOWN_ISSUES.md` for its tracked status.
- **Hardware remains unavailable in this AI session's own environment.**
  This is labeled clearly and does not block non-hardware planning (e.g.
  Phase 2E candidate review), but it does block any release-ready claim
  — nothing in Phase 2D.3 changes that.
- **`fcc_id_lookup` remains deferred** until its license-evidence gap is
  resolved in a separate, narrow phase dedicated to exactly that
  question — nothing in Phase 2D.3 resolves it as a side effect.
- **Release-ready remains blocked** regardless of which path is taken,
  until real hardware validation is actually complete (both the
  automated checks and a human-observed GUI checklist) and explicitly
  accepted — nothing in this document, or in Phase 2D.3, on its own,
  ever constitutes that acceptance.

Neither a hardware gate nor Phase 2E planning is started by this
document.

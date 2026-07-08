# Phase 2F — Next Gate

Docs only. This defines the gate that must be reviewed after Phase 2F
planning (this package) before any further phase — including Phase 2F.1
verification or Phase 2F implementation/import — is even considered. It
does not itself authorize either; it defines the checkpoint that comes
before that decision is made, mirroring `docs/PHASE2E_NEXT_GATE.md`'s
role for the Phase 2E batch.

## The gate, in order

1. **Phase 2F planning result must be reviewed first.** The project owner
   reviews `docs/PHASE2F_CANDIDATE_REVIEW.md`,
   `docs/PHASE2F_RECOMMENDED_BATCH.md`, `docs/PHASE2F_RISK_REGISTER.md`,
   `docs/PHASE2F_LICENSE_REVIEW.md`, `docs/PHASE2F_INTEGRATION_PLAN.md`,
   and this package's closing recommendation in
   `docs/PHASE2F_GO_NO_GO.md` (**GO WITH CONDITIONS**).

2. **If GO or GO WITH CONDITIONS**: the next gate is **Phase 2F.1 —
   pre-import source/license verification**, mirroring exactly what Phase
   2B.1, Phase 2C.1, Phase 2D.1, and Phase 2E.1 did for their own
   batches: obtain real network access to the upstream RogueMaster
   source, fetch and read each of the 3 recommended apps'
   (`hex_viewer`, `qrcode`, `barcode_gen`) actual `LICENSE` files and full
   source, confirm license compatibility and no undisclosed hardware/
   storage capability, and specifically confirm `hex_viewer`'s and
   `barcode_gen`'s exact storage behavior (the named open question from
   this planning phase) plus `barcode_gen`'s bundled encoding-table
   provenance. Phase 2F.1 is itself still verification-only — it does
   not import code either.

3. **Phase 2F implementation/import must not start until Phase 2F.1
   passes.** Even a clean Phase 2F.1 pass does not itself start import —
   as with every prior phase transition in this project, the project
   owner must explicitly request that import begin, following
   `docs/PHASE2F_INTEGRATION_PLAN.md`'s one-app-at-a-time,
   commit-per-app, validate-after-each discipline.

4. **If Phase 2F.1 finds a problem** (unclear license, undisclosed
   hardware capability, an actual storage-write behavior contradicting
   this planning phase's citation — the exact class of finding Phase
   2C.1 produced for `sd_info`, and the specific risk this phase already
   flags for `hex_viewer`/`barcode_gen` — or source changes required
   outside an app's own directory), the affected app is re-classified
   `DEFER` or `NEEDS REVIEW` and is not imported until that specific
   problem is resolved — this does not automatically disqualify the
   other apps in the batch, per the per-app stop-condition discipline in
   `docs/PHASE2F_RISK_REGISTER.md`.

5. **Hardware remains NOT PERFORMED.** No hardware-connected validation
   mode, and no flashing, is authorized by this document or by Phase
   2F.1 — those remain gated behind their own CI-baseline-first ordering,
   identical to every prior phase's hardware gate
   (`tools/phase2a_hardware_gate.ps1`, `tools/phase2b_hardware_gate.ps1`,
   `tools/phase2c_hardware_gate.ps1`, `tools/phase2d_hardware_gate.ps1`,
   `tools/phase2e_hardware_gate.ps1`), the last of which currently
   classifies as `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` in
   this AI session's own sandbox.

6. **Release-ready remains blocked**, regardless of which path is taken,
   until real hardware validation is actually complete (both the
   automated checks and a human-observed GUI checklist) and explicitly
   accepted — nothing in this document, or in Phase 2F.1, on its own,
   ever constitutes that acceptance.

7. **`fcc_id_lookup` remains deferred** until its license-evidence gap is
   resolved in a separate, narrow phase dedicated to exactly that
   question — nothing in Phase 2F planning, Phase 2F.1, or any future
   Phase 2F implementation resolves it as a side effect.

8. **`image_viewer/example_images/` remains excluded.** No SpongeBob or
   SpongeBob-like image, and no other example image from that directory
   (`cat.bm`, `dolphin.bm`, `spongebob.bm`), is reintroduced by this
   document or by anything Phase 2F does — this exclusion is unrelated
   to the Phase 2F candidate pool and remains untouched regardless.

## Current status against this gate (as of Phase 2F planning): PLANNING COMPLETE, AWAITING REVIEW

| Step | Status |
|---|---|
| Phase 2F candidate review | Complete — `docs/PHASE2F_CANDIDATE_REVIEW.md` |
| Phase 2F recommended batch | Complete — 3 apps (`hex_viewer`, `qrcode`, `barcode_gen`), `docs/PHASE2F_RECOMMENDED_BATCH.md` |
| Phase 2F risk register | Complete — `docs/PHASE2F_RISK_REGISTER.md` |
| Phase 2F license review | Complete (citation-only, all 3 marked routine `NEEDS REVIEW`) — `docs/PHASE2F_LICENSE_REVIEW.md` |
| Phase 2F integration plan | Complete — `docs/PHASE2F_INTEGRATION_PLAN.md` |
| Phase 2F go/no-go | **GO WITH CONDITIONS** — `docs/PHASE2F_GO_NO_GO.md` |
| Phase 2F.1 (pre-import verification) | **Not started.** Requires the project owner's own explicit further request. |
| Phase 2F implementation/import | **Not started.** Gated behind Phase 2F.1 passing, then its own separate explicit request. |
| Hardware-assisted validation | Unchanged from Phase 2E.4 — `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, see `docs/PHASE2E_HARDWARE_ASSISTED_RESULTS.md`. Nothing in this phase touches hardware. |
| `fcc_id_lookup` license gap | Unchanged — still open, see `docs/KNOWN_ISSUES.md`. Not touched by this phase. |
| `image_viewer/example_images/` | Unchanged — still excluded, confirmed absent. Not touched by this phase. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Next allowed paths

- **Path A — Phase 2F.1 pre-import source/license verification**, only
  once the project owner explicitly requests it: fresh network read of
  `hex_viewer`/`qrcode`/`barcode_gen`'s actual upstream source and
  `LICENSE` files, the same discipline Phase 2B.1, Phase 2C.1, Phase
  2D.1, and Phase 2E.1 applied to their own batches.
- **Path B — a different/expanded planning pass**, if the project owner
  wants to reconsider batch composition — though note the Phase 2F
  candidate pool (`hex_viewer`, `qrcode`, `barcode_gen`) is the entire
  remaining clean pool from the original Top 25; an expanded pass would
  require either resolving one of the 6 hard-deferred apps' specific
  concerns first, or a fresh Phase 1-style bulk triage beyond the
  original 681-app/Top-25 scope.
- **Path C — `fcc_id_lookup`'s narrow license follow-up**, entirely
  separate from Phase 2F: fetch the confirmed upstream `LICENSE`
  (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it applied to
  the specific historical revision RogueMaster vendored, before that app
  can be reconsidered for any future batch. Not resolved by this
  document, and not part of Phase 2F's own scope.

Neither Path A nor Path B is started by this document, and Path C is
explicitly out of scope for Phase 2F entirely.

## What this gate does not authorize

- **Does not start Phase 2F.1.** See Path A above — verification only, on
  explicit request.
- **Does not start Phase 2F implementation/import.** That requires Phase
  2F.1 to pass first, and then its own further explicit request — two
  separate gates, not one.
- **Does not constitute hardware testing.** Hardware testing remains
  whatever a human actually performs on real hardware with a filled-in
  smoke-test checklist — nothing less, and nothing in this document
  changes that.
- **Does not resolve `fcc_id_lookup`'s license gap.** See Path C above —
  a separate, narrow, explicitly-requested follow-up outside Phase 2F's
  own scope.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2F
  alone.
- **Does not reintroduce `image_viewer/example_images/`.** That exclusion
  is unrelated to and unaffected by anything in this document.

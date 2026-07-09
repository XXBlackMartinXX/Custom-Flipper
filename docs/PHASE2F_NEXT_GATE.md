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

---

## Phase 2F.3 update: CI baseline acceptance and artifact hash finalization

**This section supersedes the planning-stage gate above for the current
decision point. The original content is left unmodified as the
historical record; do not read this as retroactively editing it.**

Phase 2F.1 (pre-import verification), Phase 2F.2 (implementation/import,
3 apps: `qrcode`, `hex_viewer`, `barcode_gen`), and Phase 2F.2A
(root-cause remediation of the `updater_package`/`.fap` blockage found in
Phase 2F.2) have all completed. Phase 2F.3 (this update) creates the
formal CI baseline acceptance record and finalizes real artifact hashes —
see `docs/PHASE2F_3_ACCEPTANCE_RECORD.md`,
`docs/PHASE2F_3_ARTIFACT_MANIFEST.md`, `docs/PHASE2F_3_ARTIFACT_HASHES.md`,
and `docs/PHASE2F_3_GO_NO_GO.md`.

### Current status against this gate (as of Phase 2F.3)

| Step | Status |
|---|---|
| Phase 2F planning | Complete — **GO WITH CONDITIONS** |
| Phase 2F.1 (pre-import verification) | Complete — all 3 apps cleared |
| Phase 2F.2 (implementation/import) | Initially **BUILD BLOCKED**; see Phase 2F.2A |
| Phase 2F.2A (root-cause remediation) | Complete — **RESOLVED**, 2 real defects fixed (CI/tooling + app-source), confirmed by 2 independent full-pass CI runs |
| Phase 2F.2 (final reclassification) | **PHASE 2F.2 IMPORT PASS WITH CI TOOLING + APP SOURCE REMEDIATION** |
| Phase 2F.3 (CI baseline acceptance / hash finalization) | See `docs/PHASE2F_3_GO_NO_GO.md` for the real, current result |
| Hardware-assisted validation | Unchanged — no device, no Windows machine available in this AI session's environment |
| `fcc_id_lookup` license gap | Unchanged — still open, untouched by any Phase 2F sub-phase |
| `image_viewer/example_images/` | Unchanged — still excluded, confirmed absent |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged |

### Next allowed paths (from Phase 2F.3 onward)

- **If Phase 2F.3 finalization PASSES** (real artifact hashes generated,
  both baseline tags created/verified): the next allowed path is either
  **a Phase 2F hardware-assisted validation gate** (modeled on
  `tools/phase2e_hardware_gate.ps1`, only if/when a device and Windows
  machine become available, and only on explicit request) or
  **Phase 2G planning only** (not import, and only if there remains a
  safe candidate pool — the Phase 2F candidate pool was the entire
  remaining clean pool from the original Top 25, so a Phase 2G planning
  pass would need to start from a fresh triage or resolve one of the
  hard-deferred apps' specific concerns first) — both require the project
  owner's own separate, explicit request, exactly as every prior phase
  transition in this project has required.
- **If artifact hashing or tag creation is blocked**: that must be
  resolved before any further Phase 2F or Phase 2G gate — see
  `docs/PHASE2F_3_GO_NO_GO.md`'s "Finalization workflow result" section
  for the real, current blocker if one exists, and
  `docs/KNOWN_ISSUES.md` for its tracked status.
- **Hardware remains unavailable in this AI session's own environment.**
  This is labeled clearly and does not block non-hardware planning, but
  it does block any release-ready claim — nothing in Phase 2F.3 changes
  that.
- **`fcc_id_lookup` remains deferred** until its license-evidence gap is
  resolved in a separate, narrow phase dedicated to exactly that
  question — nothing in Phase 2F.3 resolves it as a side effect.
- **`image_viewer/example_images/` remains excluded** — nothing in Phase
  2F.3 changes that.
- **Release-ready remains blocked** regardless of which path is taken,
  until real hardware validation is actually complete (both the
  automated checks and a human-observed GUI checklist) and explicitly
  accepted — nothing in this document, or in Phase 2F.3, on its own,
  ever constitutes that acceptance.

Neither a hardware gate nor Phase 2G planning is started by this
document.

---

## Phase 2F.4 update: hardware-assisted validation gate

**This section supersedes the Phase 2F.3 update above for the current
decision point. The original content and the Phase 2F.3 update are left
unmodified as the historical record; do not read this as retroactively
editing either.**

Phase 2F.4 built and executed `tools/phase2f_hardware_gate.ps1` (modeled
on `tools/phase2e_hardware_gate.ps1`, extended to all 19 apps in the
accepted Phase 2F baseline, with 2 new Preflight-level checks: the
`image_viewer/example_images/` absence check carried forward unchanged,
and a new `barcode_gen` source-fix preservation check). See
`docs/PHASE2F_HARDWARE_ASSISTED_VALIDATION.md`,
`docs/PHASE2F_HARDWARE_ASSISTED_RESULTS.md`, and
`docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` for the full detail.

### Current status against this gate (as of Phase 2F.4)

| Step | Status |
|---|---|
| Phase 2F planning through Phase 2F.3 | Complete — see prior sections above |
| Phase 2F.4 hardware gate tooling | Complete — `tools/phase2f_hardware_gate.ps1`, `tools/phase2f_hardware_gate_config.json` |
| Phase 2F.4 hardware gate execution | Real runs performed in this AI session's own Linux sandbox — see `docs/PHASE2F_HARDWARE_ASSISTED_RESULTS.md` |
| Final classification | **`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`** — no Windows machine, no physical Flipper Zero, no qFlipper in this environment |
| Real artifact hash verification | **NOT RUN** — real CI artifacts could not be downloaded (same Azure Blob Storage `403` egress limitation as every prior phase); a synthetic mismatch test (random data at the exact expected sizes) proved the comparison logic correctly produces `FAIL`, clearly labeled as synthetic |
| GUI smoke test | **NOT PERFORMED** — no human observed a real device screen; all 19 apps enumerated as `REQUIRES_HUMAN_OBSERVATION`, pointing to `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` |
| Flashing | **NOT PERFORMED, NOT OFFERED** — `-AllowFlashPrompt` was never passed |
| `fcc_id_lookup` license gap | Unchanged — still open, untouched by Phase 2F.4 |
| `image_viewer/example_images/` | Unchanged — still excluded, confirmed absent by every run |
| `barcode_gen` source fix (commit `b6445ed`) | Confirmed preserved by every run — new dedicated Preflight check |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged |

### Next allowed paths (from Phase 2F.4 onward)

- **Since this run classified `HARDWARE VALIDATION BLOCKED - DEVICE NOT
  AVAILABLE`** (no device, not a failure): per this phase's own governing
  instructions, **Phase 2G planning may still start, but only as
  non-hardware-dependent planning** — the same class of work Phase 2F
  planning itself was (candidate review, risk register, license review,
  integration plan) — not import, and only if there remains a safe
  candidate pool. A Phase 2G planning pass would need to start from a
  fresh triage or resolve one of the hard-deferred apps' specific
  concerns first, since the Phase 2F candidate pool was the entire
  remaining clean pool from the original Top 25.
- **A real hardware-assisted validation run** remains available any time a
  Windows machine and a physical Flipper Zero become available — re-run
  `tools/phase2f_hardware_gate.ps1 -Mode HardwareAssisted` (and, before
  that, `-Mode HashVerify` against real downloaded artifacts) and complete
  `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real device.
  Nothing in Phase 2F.4 blocks this from happening later.
- **Release-ready remains blocked** regardless of which path is taken,
  until real hardware validation is actually complete (both the automated
  checks and a human-observed GUI checklist) and explicitly accepted —
  nothing in this document, or in Phase 2F.4, on its own, ever
  constitutes that acceptance.
- **`fcc_id_lookup` remains deferred** until its license-evidence gap is
  resolved in a separate, narrow phase dedicated to exactly that
  question — nothing in Phase 2F.4 resolves it as a side effect.
- **`image_viewer/example_images/` remains excluded** — nothing in Phase
  2F.4 changes that.

Phase 2G planning (non-hardware-dependent only, per the classification
above) is the only path this document leaves open next, and it is not
started by this document — it requires the project owner's own separate,
explicit request, exactly as every prior phase transition in this project
has required.

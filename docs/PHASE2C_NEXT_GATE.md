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

## Current status against this gate (as of Phase 2C.4): HARDWARE GATE ACTIVE, BLOCKED (DEVICE NOT AVAILABLE)

| Step | Status |
|---|---|
| Phase 2C candidate review | Complete — `docs/PHASE2C_CANDIDATE_REVIEW.md` |
| Phase 2C recommended batch | Complete — original 3-app recommendation (`sd_info`, `fcc_id_lookup`, `docviewlite`), `docs/PHASE2C_RECOMMENDED_BATCH.md` |
| Phase 2C risk register | Complete — `docs/PHASE2C_RISK_REGISTER.md` |
| Phase 2C license review | Complete — `docs/PHASE2C_LICENSE_REVIEW.md`, updated with real Phase 2C.1 findings |
| Phase 2C integration plan | Complete — `docs/PHASE2C_INTEGRATION_PLAN.md` |
| Phase 2C go/no-go | **GO WITH CONDITIONS** — `docs/PHASE2C_GO_NO_GO.md`, updated with Phase 2C.1 result |
| Phase 2C.1 (pre-import verification) | **`NEEDS REVIEW`** — real source read confirmed `sd_info` (GPLv3) and `docviewlite` (MIT) cleared; `fcc_id_lookup` **DEFER** (no `LICENSE` file in the vendored copy). Batch reduced to 2 apps. See `docs/PHASE2C_1_GO_NO_GO.md`. |
| Phase 2C.2 implementation/import | **`PHASE 2C.2 IMPORT PASS`** — `sd_info` and `docviewlite` imported one at a time on `integration/phase2c-first-batch`; `fcc_id_lookup` not imported, no substitute added. Real CI (Static + Build) passed on GitHub-hosted `windows-latest` (run `28897702247`). See `docs/PHASE2C_2_GO_NO_GO.md`. |
| Phase 2C.3 CI baseline acceptance | **`PHASE 2C.3 BASELINE ACCEPTANCE PASS`** — see `docs/PHASE2C_3_ACCEPTANCE_RECORD.md`. Artifact hashes finalized for real (`docs/PHASE2C_3_ARTIFACT_HASHES.md`), both `phase2c-ci-baseline-20260707`/`phase2c-acceptance-record-20260707` tags created. See `docs/PHASE2C_3_GO_NO_GO.md`. |
| Phase 2C.4 hardware-assisted validation | **`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`** — `tools/phase2c_hardware_gate.ps1` and `tools/phase2c_hardware_gate_config.json` now exist, covering all 10 apps, and were exercised for real in this AI session's own sandbox (no Windows, no device, no qFlipper). See `docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md` for the full per-mode results, including a synthetic-artifact hash-mismatch test proving the comparison logic is correct. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Phase 2C hardware gate (Phase 2C.4): now active

`tools/phase2c_hardware_gate.ps1` and `tools/phase2c_hardware_gate_config.json`
now exist, covering all 10 apps in the accepted Phase 2C baseline (the
Phase 2C counterpart to `tools/phase2a_hardware_gate.ps1`/
`tools/phase2b_hardware_gate.ps1`, both of which remain untouched and
still valid for their own accepted baselines). It has been exercised for
real in this AI session's own sandbox (no Windows, no physical device),
where it correctly and honestly classified as
`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` — see
`docs/PHASE2C_HARDWARE_ASSISTED_RESULTS.md` for the full per-mode
results. This run also fixed a real, minor tooling limitation carried
over from Phase 2A's and Phase 2B's own hardware gates (second-granularity
report filenames could collide on rapid repeated invocations) by using a
millisecond-precision timestamp plus a random hex suffix — verified
directly in this phase with a deliberate zero-delay rapid-invocation test
that produced zero collisions.

**Phase 2D planning remains gated on Phase 2C.4's actual classification**,
per the following rule:

- If a real Phase 2C.4 run reaches **PASS** or **PASS WITH HUMAN
  OBSERVATION** (i.e. hardware-connected checks pass and the human-observed
  `docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` is completed for all 10
  apps), Phase 2D planning may start.
- If Phase 2C.4 is **BLOCKED** (as it currently is, in this sandbox — no
  device available), Phase 2D planning may still start, but **only** if it
  is clearly labeled as non-hardware-dependent planning (candidate
  app identification/audit only) — never as a substitute for, or a way to
  skip, actual hardware testing, and never as authorization to import
  code.
- If Phase 2C.4 **FAILS** (e.g. an artifact hash mismatch against the real
  accepted artifacts, or a real device/GUI check finding a defect), Phase
  2D planning and import must not start until the failure is root-caused
  and resolved.

Given the current classification (`HARDWARE VALIDATION BLOCKED - DEVICE
NOT AVAILABLE`), Phase 2D planning may proceed **only** as clearly-labeled
non-hardware-dependent planning, and only once the project owner
explicitly requests it — the same standing rule as every prior phase
transition in this project. **Release-ready remains blocked regardless of
which path is taken, until real hardware validation is actually complete
(both the automated checks and the human-observed GUI checklist) and
explicitly accepted** — nothing in this document, on its own, ever
constitutes that acceptance. `fcc_id_lookup` remains deferred until its
license-evidence gap is resolved in a separate, narrow phase — nothing in
Phase 2C.4 changes that.

## Next allowed paths

- **Path A — Phase 2C hardware-assisted validation on real hardware**,
  only if/when the project owner has physical access to a Flipper Zero
  and a Windows machine, and explicitly requests it:
  `tools/phase2c_hardware_gate.ps1 -Mode HardwareAssisted -ArtifactDir
  <path>` (device detection + real artifact hash verification against
  `docs/PHASE2C_3_ARTIFACT_HASHES.md`'s values + flash-confirmation gate,
  never an automatic flash) and, separately, walking through
  `docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real device for
  all 10 apps, recording results in a filled-in copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
- **Path B — Phase 2D planning only**, not import, and only once the
  project owner explicitly requests it — identical discipline to every
  prior planning phase in this project: candidate review from the
  remaining Phase 1.5 pool (9 apps: `2048`, `minesweeper`, `resistors`,
  `hex_viewer`, `image_viewer`, `boilerplate`, `qrcode`, `barcode_gen`,
  `crypto_dictionary`), license review, risk register, integration plan,
  go/no-go, before any code import. Per the gating rule above, only
  non-hardware-dependent planning may proceed while Phase 2C.4 remains
  BLOCKED.
- **Path C — `fcc_id_lookup`'s narrow license follow-up**, separate from
  both of the above: fetch the confirmed upstream `LICENSE`
  (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it applied to
  the specific historical revision RogueMaster vendored, before that app
  can rejoin any future batch. Not resolved by this document.

None of these paths is started by this document.

## What this gate does not authorize

- **Does not start Phase 2D.** See Path B above — planning only, on
  explicit request, and even then, import is a separate step requiring
  its own further explicit request.
- **Does not constitute hardware testing.** Hardware testing is
  `docs/PHASE2C_HARDWARE_SMOKE_TEST_CHECKLIST.md` (all 10 apps) actually
  being run on a real device by a human, with results recorded — nothing
  less.
- **Does not resolve `fcc_id_lookup`'s license gap.** See Path C above —
  a separate, narrow, explicitly-requested follow-up.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2C
  alone.

# Phase 2B — Next Gate

Docs only. This defines the gate that must be passed after Phase 2B.2
(implementation/import) before any further phase — including Phase 2C or
Phase 2B hardware-assisted validation — is even considered. It does not
itself authorize either; it defines the checkpoint that comes before that
decision is made, mirroring `docs/PHASE2A_NEXT_GATE.md`'s role for the
Phase 2A batch.

## The gate, in order

1. **Run Static validation** against the 8-app Phase 2B config:
   ```powershell
   .\tools\phase2a_validate.ps1 -Mode Static -ConfigPath .\tools\phase2b_validate_config.json -ExpectedCommit <commit-you-are-testing>
   ```
   Must reach `PASS_WITH_REVIEWED_FALSE_POSITIVES` or `PASS` (after
   reviewing and confirming benign any `NEEDS_REVIEW` items).

2. **Run Build validation** the same way, with `-Mode Build`. Must reach
   PASS with both `firmware.dfu` and the updater `.tgz` present and
   non-empty, and all 8 `.fap` outputs present.

   **Primary path**: the GitHub Actions workflow
   `.github/workflows/phase2b-windows-validation.yml` (manual dispatch, or
   automatic on push to `integration/phase2b-first-batch`) — the same
   real-Windows-runner mechanism Phase 2A relies on.

3. **Finalize artifact hashes and baseline tags**: run
   `.github/workflows/phase2b-finalize-baseline.yml` against the accepted
   CI run, producing real SHA-256 hashes in
   `docs/PHASE2B_3_ARTIFACT_HASHES.md` and the two immutable tags
   (`phase2b-ci-baseline-20260707`, `phase2b-acceptance-record-20260707`).

4. **Collect results.** Keep the JSON + Markdown reports (they land in
   `reports\phase2b\`, timestamped, uploaded as the
   `phase2b-validation-reports` workflow artifact).

5. **Classify the overall outcome** — same three-way classification Phase
   2A uses: `AUTOMATED VALIDATION PASS` / `AUTOMATED VALIDATION FAILED` /
   `NEEDS REVIEW`.

## Current status against this gate (as of Phase 2B.4): GATE PASSED, BASELINE FINALIZED, HARDWARE GATE BLOCKED (DEVICE NOT AVAILABLE)

| Step | Status |
|---|---|
| Static validation | `PASS_WITH_REVIEWED_FALSE_POSITIVES` — CI run `28877810474`. All 110 risky-keyword substring matches (104 Phase 2A + 6 new) resolved via the reviewed-false-positive allowlist; zero unreviewed, zero high-confidence-unreviewed. |
| Build validation | **PASS** — same CI run. `firmware.dfu` 862,825 bytes, updater `.tgz` 2,742,659 bytes, all 8 `.fap` outputs present. |
| Hardware-assisted validation | **Gate built and exercised, classification `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.** `tools/phase2b_hardware_gate.ps1` exists and was run for real in the AI session's own (non-Windows, deviceless) sandbox; see `docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md` for the full per-mode results. No physical Flipper Zero and no Windows machine were available to complete device-connected or GUI-level checks. GitHub Actions itself still never invokes `-Mode HardwareAssisted` (neither `phase2b-windows-validation.yml` nor `phase2b-finalize-baseline.yml` contains that code path, by design) — hardware-assisted validation is only ever run locally, by an operator with real hardware. |
| Overall CI conclusion (verified via GitHub API) | **success** |
| Recorded classification | **`CI WINDOWS VALIDATION PASS WITH REVIEWED FALSE POSITIVES`** |
| Artifact hash finalization (Phase 2B.3) | **Finalized.** `.github/workflows/phase2b-finalize-baseline.yml` ran successfully (run [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603)) — real SHA-256 hashes generated for `firmware.dfu`/updater `.tgz`, both baseline tags (`phase2b-ci-baseline-20260707`, `phase2b-acceptance-record-20260707`) created and pushed. See `docs/PHASE2B_3_ARTIFACT_HASHES.md` and `docs/PHASE2B_3_GO_NO_GO.md`. |

**This gate's CI portion is PASSED**, at commit
`50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` on
`integration/phase2b-first-batch`, per CI run
[`28877810474`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474).
The formal, locked record of exactly what this does and does not mean is
`docs/PHASE2B_3_ACCEPTANCE_RECORD.md` — its final classification is
**`PHASE 2B ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY`**, narrower than
"gate passed" might otherwise suggest: it covers source/build/static
verification only, nothing about hardware or release-readiness.

## Phase 2B hardware gate (Phase 2B.4): now active

`tools/phase2b_hardware_gate.ps1` and `tools/phase2b_hardware_gate_config.json`
now exist, covering all 8 apps in the accepted Phase 2B baseline (the
Phase 2B counterpart to `tools/phase2a_hardware_gate.ps1`, which remains
untouched and still valid for the Phase 2A-only baseline). It has been
exercised for real in this AI session's own sandbox (no Windows, no
physical device), where it correctly and honestly classified as
`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE` — see
`docs/PHASE2B_HARDWARE_ASSISTED_RESULTS.md` for the full per-mode
results, including a deliberate synthetic-artifact hash-mismatch test
proving the comparison logic is correct.

**Phase 2C planning remains gated on Phase 2B.4's actual classification**,
per the following rule:

- If a real Phase 2B.4 run reaches **PASS** or **PASS WITH HUMAN
  OBSERVATION** (i.e. hardware-connected checks pass and the human-observed
  `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md` is completed for all 8
  apps), Phase 2C planning may start.
- If Phase 2B.4 is **BLOCKED** (as it currently is, in this sandbox — no
  device available), Phase 2C planning may still start, but **only** if it
  is clearly labeled as non-hardware-dependent planning (candidate
  app identification/audit only) — never as a substitute for, or a way to
  skip, actual hardware testing, and never as authorization to import
  code.
- If Phase 2B.4 **FAILS** (e.g. an artifact hash mismatch against the real
  accepted artifacts, or a real device/GUI check finding a defect), Phase
  2C planning and import must not start until the failure is root-caused
  and resolved.

Given the current classification (`HARDWARE VALIDATION BLOCKED - DEVICE
NOT AVAILABLE`), Phase 2C planning may proceed **only** as clearly-labeled
non-hardware-dependent planning, and only once the project owner
explicitly requests it — the same standing rule as every prior phase
transition in this project. **Release-ready remains blocked regardless of
which path is taken, until real hardware validation is actually complete
(both the automated checks and the human-observed GUI checklist) and
explicitly accepted** — nothing in this document, on its own, ever
constitutes that acceptance.

## Next allowed paths

- **Path A — Phase 2B hardware-assisted validation on real hardware**,
  only if/when the project owner has physical access to a Flipper Zero
  and a Windows machine, and explicitly requests it:
  `tools/phase2b_hardware_gate.ps1 -Mode HardwareAssisted -ArtifactDir
  <path>` (device detection + real artifact hash verification against
  `docs/PHASE2B_3_ARTIFACT_HASHES.md`'s values + flash-confirmation gate,
  never an automatic flash) and, separately, walking through
  `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real device for
  all 8 apps, recording results in a filled-in copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
- **Path B — Phase 2C planning only**, not import, and only once the
  project owner explicitly requests it — identical discipline to Phase
  2B's own planning phase: candidate review, license review, risk
  register, integration plan, go/no-go, before any code import. Per the
  gating rule above, only non-hardware-dependent planning may proceed
  while Phase 2B.4 remains BLOCKED.

## What this gate does not authorize (still true after CI acceptance)

- **Does not start Phase 2C.** See Path B above — planning only, on
  explicit request, and even then, import is a separate step requiring
  its own further explicit request.
- **Does not constitute hardware testing.** Hardware testing is
  `docs/PHASE2B_HARDWARE_SMOKE_TEST_CHECKLIST.md` (all 8 apps) actually
  being run on a real device by a human, with results recorded — nothing
  less.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2B
  alone.

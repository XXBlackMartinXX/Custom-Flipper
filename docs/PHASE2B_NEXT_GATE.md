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

## Current status against this gate (as of Phase 2B.3): GATE PASSED (CI), FINALIZATION IN PROGRESS

| Step | Status |
|---|---|
| Static validation | `PASS_WITH_REVIEWED_FALSE_POSITIVES` — CI run `28877810474`. All 110 risky-keyword substring matches (104 Phase 2A + 6 new) resolved via the reviewed-false-positive allowlist; zero unreviewed, zero high-confidence-unreviewed. |
| Build validation | **PASS** — same CI run. `firmware.dfu` 862,825 bytes, updater `.tgz` 2,742,659 bytes, all 8 `.fap` outputs present. |
| Hardware-assisted validation | **NOT RUN** — not attempted anywhere, and never will be by the GitHub Actions path: neither `phase2b-windows-validation.yml` nor `phase2b-finalize-baseline.yml` contains a code path capable of invoking `-Mode HardwareAssisted`, by design. |
| Overall CI conclusion (verified via GitHub API) | **success** |
| Recorded classification | **`CI WINDOWS VALIDATION PASS WITH REVIEWED FALSE POSITIVES`** |
| Artifact hash finalization (Phase 2B.3) | **In progress** — `.github/workflows/phase2b-finalize-baseline.yml` created in this phase; see `docs/PHASE2B_3_GO_NO_GO.md` for the real result once it has run. |

**This gate's CI portion is PASSED**, at commit
`50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` on
`integration/phase2b-first-batch`, per CI run
[`28877810474`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474).
The formal, locked record of exactly what this does and does not mean is
`docs/PHASE2B_3_ACCEPTANCE_RECORD.md` — its final classification is
**`PHASE 2B ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY`**, narrower than
"gate passed" might otherwise suggest: it covers source/build/static
verification only, nothing about hardware or release-readiness.

## Next allowed paths, conditional on Phase 2B.3's actual finalization result

**If Phase 2B.3 finalization PASSES** (both artifact hashes generated and
both tags pushed, or already existing and pointing at the expected
commits):

- **Path A — Phase 2B hardware-assisted validation**, only if/when the
  project owner has physical access to a Flipper Zero and a Windows
  machine, and explicitly requests it. `tools/phase2a_hardware_gate.ps1`
  already exists and is batch-agnostic for device detection/tooling
  detection/flash-confirmation (it only needs an `-ArtifactDir` pointing
  at a locally-downloaded copy of the Phase 2B artifacts to hash-verify
  against `docs/PHASE2B_3_ARTIFACT_HASHES.md`'s values — no code change
  to that script is required, though its own config
  (`tools/phase2a_hardware_gate_config.json`) still references the Phase
  2A-only hash values specifically and would need a Phase-2B-pointing
  variant, not created in this phase since no device is available to use
  it against here).
- **Path B — Phase 2C planning only**, not import, and only once the
  project owner explicitly requests it — identical discipline to Phase
  2B's own planning phase: candidate review, license review, risk
  register, integration plan, go/no-go, before any code import.

**If artifact hashing or tag creation is blocked** (e.g. the finalization
workflow fails, or a tag already exists pointing somewhere unexpected):
that specific blocker must be resolved — or explicitly, honestly
documented as an accepted, unresolved environment limitation — before any
further implementation phase (2B hardware gate or 2C) begins. Planning
work that does not depend on the blocked artifact (e.g. Phase 2C
candidate review, which only needs the accepted Phase 2B *app list*, not
its hashes) is not automatically blocked by this, but should note the
open item.

**Hardware remaining unavailable** (the current, expected state — no
device, no Windows machine in this AI session's environment) does **not**
block non-hardware planning (Path B above, or continuing to iterate on
tooling/docs). It **does** block any release-ready claim, any
hardware-tested claim, and Path A actually being exercised for real
(as opposed to merely existing as ready-to-run tooling).

## What this gate does not authorize (still true after CI acceptance)

- **Does not start Phase 2C.** See Path B above — planning only, on
  explicit request, and even then, import is a separate step requiring
  its own further explicit request.
- **Does not constitute hardware testing.** Hardware testing is
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` (extended with per-app
  sections for `flipfetch`/`quadratic_solver`/`sudoku`, not yet added)
  actually being run on a real device by a human, with results recorded
  — nothing less.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2B
  alone.

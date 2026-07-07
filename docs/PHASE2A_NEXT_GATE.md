# Phase 2A — Next Gate

Docs only. This defines the gate that must be passed after Phase 2A.5
(automated validation tooling) before any further phase — including Phase 2B —
is even considered. It does not itself authorize Phase 2B; it defines the
checkpoint that comes before that decision is made at all.

## The gate, in order

1. **Run Static validation.**
   ```powershell
   .\tools\phase2a_validate.ps1 -Mode Static -ExpectedCommit <commit-you-are-testing>
   ```
   Must reach `AUTOMATED VALIDATION PASS` (after reviewing and confirming
   benign any `NEEDS_REVIEW` items — see `PHASE2A_AUTOMATED_VALIDATION.md` for
   how to interpret the risky-keyword scan's expected false positives).

2. **Run Build validation.**
   ```powershell
   .\tools\phase2a_validate.ps1 -Mode Build -ExpectedCommit <commit-you-are-testing>
   ```
   Must reach PASS with both `firmware.dfu` and the updater `.tgz` present and
   non-empty, and all 5 `.fap` outputs present. If this environment cannot
   build (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md` for this project's own
   BLOCKED example), run it on a real Windows machine instead.

   **Since the project owner does not currently have Claude Desktop or local
   Claude Code available to drive their own Windows machine, the primary way
   to run this step is now the GitHub Actions workflow**:
   **Actions tab → "Phase 2A Windows Validation" → Run workflow** (or simply
   push to `integration/phase2a-first-batch`, which triggers it
   automatically). This runs Static then Build on a real GitHub-hosted
   Windows runner and uploads the reports + `firmware.dfu`/updater `.tgz` as
   workflow artifacts. See `docs/PHASE2A_GITHUB_ACTIONS_VALIDATION.md` for
   the full explanation, and `.github/workflows/phase2a-windows-validation.yml`
   for the workflow itself.

3. **Optionally run Hardware-Assisted validation** — only if a Flipper Zero is
   physically connected and you deliberately choose to run it:
   ```powershell
   .\tools\phase2a_validate.ps1 -Mode HardwareAssisted -ExpectedCommit <commit-you-are-testing>
   ```
   This step is optional at this gate specifically because Static+Build PASS
   is the minimum bar to even consider hardware testing — it is not optional
   forever; real hardware testing via
   `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` is still required before
   any release-readiness claim, per `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md`.

4. **Collect results.** Keep the JSON + Markdown reports from each run (they
   land in `reports\phase2a\`, timestamped). If hardware-assisted testing was
   performed, also fill in a copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.

5. **Classify the overall outcome:**

   - **AUTOMATED VALIDATION PASS** — Static and Build both came back PASS
     (after human review of any NEEDS_REVIEW items), with no unresolved FAIL
     or BLOCKED entries. This means the repository and build are in the
     expected state; it does **not** by itself mean hardware-tested or
     release-ready.
   - **AUTOMATED VALIDATION FAILED** — any real FAIL exists in Static or
     Build. Stop here. Diagnose and fix the underlying cause (following this
     project's standing rule: root-cause it, don't patch around it) before
     re-running the gate from step 1.
   - **NEEDS REVIEW** — some checks came back BLOCKED (environment-specific,
     like the toolchain-host block in this project's cloud sandbox) or
     produced a NEEDS_REVIEW that a human has not yet manually confirmed as
     benign. Resolve/review each one, then re-run to reach a clean
     classification before proceeding.

   When Static + Build both come back clean via the **GitHub Actions**
   path specifically (the real Windows-machine confirmation this project
   currently relies on), record the status as:
   **`CI WINDOWS VALIDATION PASS / HARDWARE NOT TESTED / NOT RELEASE READY`**
   — this is deliberately a more specific label than the generic
   `AUTOMATED VALIDATION PASS` above: it names *where* the confirmation came
   from (a GitHub-hosted Windows runner, not the project owner's own
   machine, and not a full release audit) and repeats, in the label itself,
   that hardware testing and release-readiness are still separate, unmet
   requirements.

## Current status against this gate (as of this document — Phase 2A.10): GATE PASSED

| Step | Status |
|---|---|
| Static validation | `PASS_WITH_REVIEWED_FALSE_POSITIVES` — CI run `28814008347`. All 104 risky-keyword substring matches resolved via the reviewed-false-positive allowlist; zero unreviewed, zero high-confidence-unreviewed. |
| Build validation | **PASS** — same CI run. `firmware.dfu` 862,825 bytes, updater `.tgz` 2,733,074 bytes, all 5 `.fap` outputs present, SAM removal verified. |
| Hardware-assisted validation | **NOT RUN** — not attempted anywhere, and never will be by the GitHub Actions path: that workflow contains no code path capable of invoking `-Mode HardwareAssisted`, by design. |
| Overall CI conclusion (verified via GitHub API) | **success** |
| Recorded classification | **`CI WINDOWS VALIDATION PASS WITH REVIEWED FALSE POSITIVES`** |
| Artifact hash finalization (Phase 2A.10) | **Attempted, blocked by a genuine environment network-policy limitation** (this sandbox cannot reach the Azure Blob Storage host GitHub Actions artifact downloads redirect to — confirmed 403, same class as the toolchain-host block elsewhere in this project). **Not faked** — see `docs/PHASE2A_ARTIFACT_HASHES.md` and `docs/PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`'s "Phase 2A.10" section. Does not affect the acceptance below (artifact sizes were already confirmed by the CI run itself). |

**This gate is now PASSED**, at commit `718eec5fe115c9e0467a8d07d974947a85b27cf6`
on `integration/phase2a-first-batch`, per CI run
[`28814008347`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347).
The formal, locked record of exactly what this does and does not mean is
`docs/PHASE2A_ACCEPTANCE_RECORD.md` — its final classification is
**`PHASE 2A ACCEPTED FOR NON-HARDWARE CI BASELINE ONLY`**, which is narrower
than "gate passed" might otherwise suggest: it covers source/build/static
verification only, nothing about hardware or release-readiness.

## Next allowed paths (unchanged since Phase 2A.9)

With the gate passed, exactly two paths are authorized from here — nothing
else, and neither happens automatically:

**Path A — Hardware-assisted validation**, only if/when the project owner
has physical access to a Flipper Zero and explicitly requests it. This means
running `tools/phase2a_validate.ps1 -Mode HardwareAssisted` (device
detection + read-only preflight only, per its own design) and, separately,
walking through `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the real
device, recording results in a filled-in copy of
`docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`. Nothing about this path is
scheduled or assumed — it starts only when the project owner says so.

**Path B — Phase 2B planning only**, not import, and only once the project
owner explicitly requests it. "Planning only" means: identifying and
proposing a small, safe next batch of candidate apps (drawing on the
existing Phase 1/1.6 audit work), subject to the exact same gates this batch
went through — individual source/license audit, safety review, Static+Build
CI validation, and this same acceptance-record discipline. It does **not**
mean starting to import code. **Phase 2B code import must not start until
the project owner explicitly requests it** — this document, on its own,
never authorizes that step, no matter how clean Phase 2A's CI result is.

Both paths are optional and mutually non-exclusive; picking one does not
foreclose the other, and picking neither (staying at the current accepted
baseline) is also a valid outcome.

## What this gate does not authorize (still true after acceptance)

- **Does not start Phase 2B.** See Path B above — planning only, on explicit
  request, and even then, import is a separate step requiring its own
  further explicit request.
- **Does not constitute hardware testing.** Hardware testing is
  `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` actually being run on a
  real device by a human, with results recorded in a filled-in copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md` — nothing less.
- **Does not constitute release-readiness.** That also requires the
  project's full release-gate checklist, which spans more than Phase 2A
  alone.

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

## What this gate does not authorize

- **Passing this gate does not start Phase 2B.** Phase 2B (further app
  imports, or any expanded scope) requires its own separate, explicit approval
  from the project owner, independent of this gate's outcome.
- **Passing this gate does not constitute hardware testing.** Hardware testing
  is `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md` actually being run on a
  real device by a human, with results recorded in a filled-in copy of
  `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md` — nothing less.
- **Passing this gate does not constitute release-readiness.** That also
  requires the project's full release-gate checklist, which spans more than
  Phase 2A alone.

## Current status against this gate (as of this document — Phase 2A.8)

| Step | Status |
|---|---|
| Static validation | Executed against the Phase 2A.8 fix commit (`8d21138`, cloud sandbox) — `PASS_WITH_REVIEWED_FALSE_POSITIVES` (exit 0). All 104 risky-keyword substring matches now resolve via the new reviewed-false-positive allowlist; zero unreviewed, zero high-confidence-unreviewed. |
| Build validation | **Real Windows Build PASS already achieved** via GitHub Actions run `28808570107` (head SHA `6920b408...`): `firmware.dfu` 862,825 bytes, updater `.tgz` 2,732,904 bytes, all 5 `.fap` outputs present, SAM removal verified. **That specific run's overall workflow conclusion was `failure`**, but purely because of the now-fixed Static/risky-keyword-scan gap (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`'s "Phase 2A.8" section) — not a Build problem. The fix (commit `8d21138`) has not yet been exercised through an actual new GitHub Actions run as of this document. |
| Hardware-assisted validation | **NOT RUN** — not attempted anywhere, and never will be by the GitHub Actions path either: that workflow contains no code path capable of invoking `-Mode HardwareAssisted`, by design (see `PHASE2A_GITHUB_ACTIONS_VALIDATION.md`). |
| Overall classification | **NEEDS REVIEW** — pending a real re-run of the GitHub Actions workflow against the fix commit, to confirm the same real Build PASS now comes with a genuinely green overall workflow result |

**Immediate next action**: trigger the "Phase 2A Windows Validation" workflow
again (manually via the Actions tab, or by pushing to
`integration/phase2a-first-batch`, which this round's commits already did)
against a commit that includes the Phase 2A.8 fix (`8d21138` or later), and
confirm the workflow's overall conclusion is now green. If it is, record
status as
**`CI WINDOWS VALIDATION PASS / HARDWARE NOT TESTED / NOT RELEASE READY`**. If
it still fails, diagnose from the uploaded reports/logs before assuming
anything about the firmware — check whether it's a genuinely new/unreviewed
risky-keyword match, a real build problem, or another validator/workflow gap
— and fix the underlying validator, workflow, or (only if a real app defect
is proven) firmware issue before re-running. Do not proceed to Phase 2B in
the meantime.

**Not proceeding to Phase 2B.** This document defines the gate for future
runs of this tooling; it does not, on its own, close the gate — that requires
an actual passing run of `tools/phase2a_validate.ps1` (via GitHub Actions or
a real Windows machine), review of its output, and (separately, when the
project owner chooses) real hardware-assisted testing.

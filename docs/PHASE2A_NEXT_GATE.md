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
   BLOCKED example), run it on the Windows machine that already has a working
   toolchain.

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

## Current status against this gate (as of this document)

| Step | Status |
|---|---|
| Static validation | Manually reproduced and reviewed in the cloud sandbox — PASS (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`). The script itself (`tools/phase2a_validate.ps1`) has not yet been executed anywhere, including this check. |
| Build validation | BLOCKED in the cloud sandbox (toolchain host policy-denied, same root cause documented throughout this project). Independently known-PASS via the project owner's manual local Windows build at commit `5e5e0ecf225be947a754e537670a6421838b939b` — not yet re-verified through this new tooling on that machine. |
| Hardware-assisted validation | NOT RUN — no device connected to this sandbox; this sandbox is also not Windows. |
| Overall classification | **NEEDS REVIEW** (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md` for the full reasoning) |

**Not proceeding to Phase 2B.** This document defines the gate for future
runs of this tooling; it does not, on its own, close the gate — that requires
an actual run of `tools/phase2a_validate.ps1` on the real Windows build
machine, review of its output, and (separately, when the project owner
chooses) real hardware-assisted testing.

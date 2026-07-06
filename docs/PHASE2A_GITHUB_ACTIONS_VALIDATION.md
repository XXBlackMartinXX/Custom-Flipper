# Phase 2A — GitHub Actions Windows Validation

Docs + tooling only. No firmware/app code changed by this document or by
`.github/workflows/phase2a-windows-validation.yml`. This explains why this
workflow exists, what it validates, what it does not, how to run it, where to
find its output, and how to interpret the result.

## Why this exists

Phase 2A.6 and the start of Phase 2A.7 both needed the hardened
`tools/phase2a_validate.ps1` run on a real Windows machine — the cloud
sandbox this project's AI sessions run in is Linux and cannot execute
`fbt.cmd` at all (see `PHASE2A_AUTOMATED_VALIDATION_RESULTS.md`). The
original plan for that was the project owner's own Windows machine
(`C:\Github\Custom-Flipper-phase2a-build`) via Claude Desktop or local
Claude Code. **The project owner does not currently have either of those
available.**

This workflow is the replacement path: a **GitHub-hosted `windows-latest`
runner** is a real Windows machine with a real network connection (able to
reach the vendor toolchain host that this project's cloud sandbox cannot),
so it can run `.\fbt.cmd` for real and give a genuine Build-mode result —
without requiring Claude Desktop, local Claude Code, or any local Windows
setup from the project owner at all. It's triggered from the GitHub web UI
with one click.

## What this workflow validates

`.github/workflows/phase2a-windows-validation.yml`, job `validate`, on
`windows-latest`:

1. Checks out `integration/phase2a-first-batch` with all submodules
   (`submodules: recursive`, `fetch-depth: 0`)
2. Prints the branch/commit under test and confirms
   `tools/phase2a_validate.ps1` and `tools/phase2a_validate_config.json`
   exist (fails fast with a clear message if not — e.g. wrong branch)
3. Ensures a `python` is on `PATH` (pinned via `actions/setup-python`,
   defensively, since `fbt.cmd`'s own toolchain bootstrap needs it)
4. Runs `tools/phase2a_validate.ps1 -Mode Static -ExpectedCommit $env:GITHUB_SHA`
5. Runs `tools/phase2a_validate.ps1 -Mode Build -ExpectedCommit $env:GITHUB_SHA`
   (this actually invokes `.\fbt.cmd COMPACT=1 DEBUG=0` and
   `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package`, on a real Windows machine,
   with real network access to the toolchain host)
6. Prints `git status --short` after both runs
7. Uploads the JSON/Markdown validation reports as a workflow artifact
8. Uploads `build\f7-firmware-C\firmware.dfu` and
   `dist\f7-C\flipper-z-f7-update-local.tgz` as a separate workflow artifact
   (only these two files — never the `toolchain\` directory, never anything
   else under `build\`/`dist\`)
9. Prints an explicit "Hardware-assisted validation: NOT RUN" / "Hardware
   flashing/testing: NOT PERFORMED" notice in the job log, every run,
   regardless of outcome

The job fails (red X) whenever either `phase2a_validate.ps1` invocation exits
non-zero — the script's own exit codes (0=PASS, 1=FAILED, 2=NEEDS
REVIEW/BLOCKED) are propagated directly as the step's exit code, so a
`NEEDS_REVIEW` or `BLOCKED` result surfaces as a failed workflow run
requiring human review, exactly like a real `FAIL` would — nothing is
silently downgraded to green.

## What this workflow does not validate

- **Nothing hardware-assisted, ever.** `-Mode HardwareAssisted` is never
  invoked anywhere in this workflow — there is no code path in the workflow
  file that could call it, and there is no physical Flipper Zero attached to
  a GitHub-hosted runner for it to detect even if it were. Hardware-assisted
  validation is out of scope for CI by construction, not by a flag that
  could be flipped.
- **Nothing about real hardware or GUI-level app behavior.** A successful
  Build-mode result here proves the firmware compiles and the 5 Phase 2A
  apps' `.fap` outputs exist — it says nothing about whether they boot,
  render correctly, or behave correctly on a real device. See
  `PHASE2A_HARDWARE_SMOKE_TEST_PLAN.md` for what still requires a human with
  a physical device.
- **Nothing about release-readiness.** A green run here is
  `CI WINDOWS VALIDATION PASS`, not release-ready — see
  `PHASE2A_NEXT_GATE.md`.
- **This workflow never flashes anything, never claims hardware testing
  occurred, and never commits anything back to the repository.** Reports
  and build artifacts are uploaded as workflow artifacts only; nothing is
  auto-committed.

## How to run it manually

1. On GitHub, open the repository → **Actions** tab.
2. In the left sidebar, select **Phase 2A Windows Validation**.
3. Click **Run workflow**, choose the `integration/phase2a-first-batch`
   branch (or whichever branch/commit you want validated), and click
   **Run workflow** again to confirm.
4. It also runs automatically on every push to `integration/phase2a-first-batch`,
   so a manual trigger is only needed for re-runs, other branches, or
   on-demand checks.

## Where to find reports and artifacts

Once the run finishes (or even while it's still running, for partial
results):

1. Open the run from the **Actions** tab.
2. Scroll to the **Artifacts** section at the bottom of the run summary page.
3. Two artifacts are produced, every run, regardless of PASS/FAIL:
   - **`phase2a-validation-reports`** — the timestamped JSON + Markdown
     reports from both the Static and Build runs (and the raw `fbt.cmd`
     build logs, if a build was attempted).
   - **`phase2a-firmware-artifacts`** — `firmware.dfu` and the updater
     `.tgz`, if the build produced them. If the build failed or didn't run,
     this artifact may be empty or missing entirely (`if-no-files-found:
     warn` — the workflow won't hide a build failure by failing the upload
     step too).
4. Artifacts are retained for 90 days, then automatically deleted by GitHub.

## How to interpret PASS / FAIL / BLOCKED / NEEDS_REVIEW

Same meaning as documented in `PHASE2A_AUTOMATED_VALIDATION.md`:

| Status | Meaning here |
|---|---|
| Workflow run: green check | Both Static and Build exited 0 (clean PASS) |
| Workflow run: red X | At least one of Static/Build exited non-zero — open the uploaded reports to see exactly which check(s) failed, were BLOCKED, or need review |

Unlike the cloud sandbox (which structurally cannot run a build at all), a
`BLOCKED` result on this Windows runner would mean something genuinely worth
investigating — e.g. the toolchain download failing for a real reason on
GitHub's infrastructure — rather than the sandbox's known, permanent,
environment-level limitation. Always read the actual report contents rather
than only the pass/fail color, since (as designed) some findings are
expected to require a one-time human confirmation rather than indicating a
real problem — e.g. the risky-keyword scan's substring matches, which are
known to include benign false positives that still need a human's eyes on
the list at least once per reviewed commit.

### Worked example: Run `28808570107` (Phase 2A.7 → 2A.8)

The very first run of this workflow (run ID `28808570107`, head SHA
`6920b408...`) is a useful worked example of the distinction above. GitHub
Actions reported the workflow **conclusion as `failure`** — but the *actual*
Windows Build step passed cleanly: `firmware.dfu` (862,825 bytes) and the
updater `.tgz` (2,732,904 bytes) both built, all 5 apps' `.fap` outputs
existed, SAM removal verification passed. The failure came entirely from
Static mode's risky-keyword scan reporting `NEEDS_REVIEW` (exit code 2) for
104 substring matches that had *already* been manually reviewed and
confirmed benign back in Phase 2A.5/2A.6 — the validator simply had no way,
before Phase 2A.8, to record "this exact match was already reviewed and is
fine," so it re-reported the same 104 already-known-benign matches as
needing review, forever, on every run.

**This was a CI policy/validator gap, not a firmware defect, not a hardware
result, and not a release-readiness claim.** Phase 2A.8 fixed it by adding a
structured, per-line reviewed-false-positive allowlist to
`tools/phase2a_validate_config.json` (never a blanket "ignore this keyword"
rule — see `PHASE2A_AUTOMATED_VALIDATION.md`'s "Reviewed-false-positive
allowlist" section for the exact mechanism). A subsequent run against a
commit that includes that fix is expected to show a real green workflow run
for the same underlying Windows Build result. If you see a red X on a run of
this workflow, always check *which* step and *which specific check* failed
before assuming the firmware or apps are broken — the uploaded reports name
the exact check, and the reviewed-false-positive mechanism means a red X is
much more likely to reflect a genuinely new or high-confidence finding now
than a stale, already-reviewed one.

## What has not changed

**Hardware flashing/testing remains NOT PERFORMED.** **Release status
remains TEST-READY ONLY / NOT RELEASE-READY.** This workflow, even with a
fully green run, does not change either of those — it only replaces *how* a
genuine Windows Static+Build result gets produced, given the project owner's
current lack of a Claude Desktop / local Claude Code path to their own
Windows machine.

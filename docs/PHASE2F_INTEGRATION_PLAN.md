# Phase 2F — Integration Plan

Docs only. Planning only. **This document describes how a future,
separately-approved Phase 2F implementation would proceed — it does not
itself start that implementation.** Every mechanism described here already
exists and was already exercised in Phase 2A, Phase 2B, Phase 2C, Phase
2D, and Phase 2E; this plan proposes reusing it unmodified, not
redesigning it.

## Branch strategy

- **Proposed implementation branch name**: `integration/phase2f-first-batch`,
  branched from the accepted Phase 2E baseline commit
  (`dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` on
  `integration/phase2e-first-batch`, or the branch's later HEAD if the
  project owner prefers), the same "new named branch per batch"
  convention `integration/phase2e-first-batch` itself established
  relative to `integration/phase2d-first-batch`.
- Continue mirroring every accepted docs/tooling commit to
  `claude/flipper-custom-firmware-cxrcer`, the same discipline used
  throughout every prior phase.
- No branch is created, renamed, merged, or force-pushed by this planning
  phase itself. `integration/phase2f-first-batch` does not exist yet as
  of this document.

## Import order

Per `docs/PHASE2F_RECOMMENDED_BATCH.md`, pending each app's own Phase
2F.1 verification passing first:

1. `qrcode`
2. `hex_viewer`
3. `barcode_gen`

## One-app-at-a-time rule

Identical to the rule every prior phase actually followed: each app is
added in its own commit, and the tree is rebuilt/re-validated after each
individual addition before the next app is started. No two apps are ever
combined into a single import commit. If one app in the sequence has a
problem (most likely candidate: `hex_viewer`'s or `barcode_gen`'s
unresolved storage-behavior question — see
`docs/PHASE2F_RISK_REGISTER.md`), it is diagnosed and fixed (or deferred)
on its own — it does not block or get bundled with the next app. If
`hex_viewer` or `barcode_gen` is deferred at Phase 2F.1, `qrcode` alone
(or `qrcode` plus whichever of the two clears) may still proceed as a
smaller batch — this plan does not require all 3 to clear together.

## Commit-per-app rule

Each app's import commit contains exactly that app's source files plus its
own `application.fam`, its own `applications_user/.gitignore` exception
entries (the `!/appname/` and `!/appname/**` pattern every prior batch has
added for each of its apps), and any required one-line registration entry
— the same scope discipline every prior phase used.

## Static validation after each app

After each individual app's import commit, re-run the project's static
validator (the `tools/phase2e_validate_config.json`-style
keyword/appid/manifest scan, extended to a new
`tools/phase2f_validate_config.json` covering the growing 17-, 18-, and
eventually 19-app superset) before moving to the next app — the same
per-app-then-batch validation cadence every prior phase used, catching a
bad import immediately rather than after all 3 apps have landed.

## Build validation after each app if feasible

Local build remains expected to be `BUILD BLOCKED / ENVIRONMENT` in this
AI session's own cloud sandbox, for the same reason recorded in every
prior phase's own build report (`update.flipperzero.one` egress `403`,
or — on Linux — `fbt.cmd` itself being a Windows batch file). This is not
a defect; it is the same pre-existing environment limitation. A GitHub
Actions Windows CI workflow (modeled on
`.github/workflows/phase2e-windows-validation.yml`, renamed
`phase2f-windows-validation.yml`) provides the real build validation
after the full batch, per the CI-validation-after-batch step below.

## CI validation after batch

After all approved apps in the batch are imported (all 3, or fewer if
`hex_viewer`/`barcode_gen` are deferred at Phase 2F.1), dispatch a real
GitHub Actions Windows CI run covering the full resulting app set (16 +
however many of the 3 clear), reusing the exact `updater_package`
CI-tooling remediation established in Phase 2D.2A and carried forward
unchanged through Phase 2E — no CI tooling change is anticipated to be
necessary for this batch, since none of the 3 candidates is expected to
introduce a new build-tooling class of problem.

## Reviewed false-positive workflow reuse

Reuse the exact reviewed-false-positive discipline from every prior
phase: any new risky-keyword substring match introduced by the 3 new
apps (e.g. `hex_viewer`'s own name containing "hex," possible `code`/
`scan` substrings in `qrcode`/`barcode_gen`) is individually reviewed,
recorded as a reviewed false positive with its exact justification, and
the static validator's reviewed-false-positive list is extended — never
silently ignored, never used to weaken the validator's own detection
logic.

## Artifact hash finalization reuse

Reuse the exact Phase 2A.11/2B.3/2C.3/2D.3/2E.3 finalize-baseline
workflow pattern: a `phase2f-finalize-baseline.yml` GitHub Actions
workflow, running on a GitHub-hosted Windows runner, downloads the
accepted CI run's real artifacts, computes real SHA-256 hashes via
`Get-FileHash`, patches the pending docs in place, and creates
`phase2f-ci-baseline-<date>`/`phase2f-acceptance-record-<date>` tags,
refusing to overwrite either if it already exists and points elsewhere —
unmodified from the Phase 2E.3 mechanism.

## Hardware gate only after CI baseline acceptance

A `tools/phase2f_hardware_gate.ps1` (modeled on
`tools/phase2e_hardware_gate.ps1`) would only be built and exercised
after the Phase 2F CI baseline acceptance record exists — the same
ordering every prior phase has followed (hardware gate is Phase 2F.4,
never earlier). This plan does not build or invoke that script.

## No release-ready claim

Nothing in this plan, or in any future Phase 2F implementation it
describes, constitutes a release-ready claim. Release-readiness requires
real, human-observed hardware validation across the entire accepted app
set, explicitly accepted — unchanged from every prior phase's own
position.

## Rollback plan

Identical to every prior phase's rollback discipline
(`docs/PHASE2A_FLASHING_PRECHECK.md` §5, batch-agnostic): if a future
Phase 2F import introduces a build failure, a safety-scan finding, or any
other stop-condition trigger, the specific problematic commit is
reverted (not force-pushed over) and the branch returns to its last known
good state before continuing with the remaining apps in the batch, per
the per-app stop-condition discipline in `docs/PHASE2F_RISK_REGISTER.md`.

## Stop conditions

- Any of the cross-cutting or per-app stop conditions in
  `docs/PHASE2F_RISK_REGISTER.md` are triggered at Phase 2F.1 — the
  affected app is re-classified `DEFER` or `NEEDS REVIEW` and is not
  imported until resolved; this does not automatically disqualify the
  other apps in the batch.
- A real CI Build failure that is not resolved by a narrow, documented
  fix within the scope of this batch's own apps.
- Any finding that an app requires a source change outside its own app
  directory (re-classify `NEEDS REVIEW`, per the prompt-canary rule).
- Any finding that an app touches the safety-exclusion list
  (RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR/credential/bypass/
  cloning/brute-force/HID-injection) — re-classify `DEFER` immediately.

## What this document does not do

This document does not create `integration/phase2f-first-batch`, does
not import any code, does not modify `applications/` or
`applications_user/`, and does not start Phase 2F.1 — it only describes
how a future, separately-approved implementation would proceed.

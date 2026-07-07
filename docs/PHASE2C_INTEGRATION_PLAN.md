# Phase 2C — Integration Plan

Docs only. Planning only. **This document describes how a future,
separately-approved Phase 2C implementation would proceed — it does not
itself start that implementation.** Every mechanism described here already
exists and was already exercised in Phase 2A and Phase 2B; this plan
proposes reusing it unmodified, not redesigning it.

## Branch strategy

- **Proposed implementation branch name**: `integration/phase2c-first-batch`,
  branched from the accepted Phase 2B baseline commit
  (`50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` on
  `integration/phase2b-first-batch`), the same "new named branch per
  batch" convention `integration/phase2b-first-batch` itself established
  relative to `integration/phase2a-first-batch`.
- Continue mirroring every accepted docs/tooling commit to
  `claude/flipper-custom-firmware-cxrcer`, the same discipline used
  throughout Phase 2A and Phase 2B.
- No branch is created, renamed, merged, or force-pushed by this planning
  phase itself. `integration/phase2c-first-batch` does not exist yet as of
  this document.

## Import order

Per `PHASE2C_RECOMMENDED_BATCH.md`:

1. `sd_info`
2. `fcc_id_lookup`
3. `docviewlite`

## One-app-at-a-time rule

Identical to the rule Phase 2A and Phase 2B actually followed: each app is
added in its own commit, and the tree is rebuilt/re-validated after each
individual addition before the next app is started. No two apps are ever
combined into a single import commit. If one app in the sequence has a
problem, it is diagnosed and fixed (or deferred) on its own — it does not
block or get bundled with the next app.

## Commit-per-app rule

Each app's import commit contains exactly that app's source files plus its
own `application.fam`, its own `applications_user/.gitignore` exception
entries (the `!/appname/` and `!/appname/**` pattern Phase 2B.2 had to add
for each of its 3 apps), and any required one-line registration entry —
the same scope discipline Phase 2A and Phase 2B used.

## Static validation after each app

After each app's commit: `tools/phase2a_validate.ps1 -Mode Static
-ConfigPath tools/phase2b_validate_config.json -ExpectedCommit <commit>`
(or an updated `tools/phase2c_validate_config.json`, an 11-app superset,
if the project owner wants Phase 2C tracked in its own config file the
same way Phase 2B's config superseded Phase 2A's for validation purposes —
either reuses the same `-ConfigPath` mechanism added in Phase 2B.2, not a
new mechanism). Any new risky-keyword match introduced by a Phase 2C app
must go through the exact same reviewed-false-positive process already
documented (individually keyed on file path + line number + keyword +
SHA-256 of the trimmed line text) — never a blanket suppression, never
skipped.

## Build validation after each app, if feasible

After each app's commit: the same `-Mode Build` validation, on a real
Windows machine or via a Phase-2C-named GitHub Actions workflow modeled
directly on `.github/workflows/phase2b-windows-validation.yml` (itself
modeled on Phase 2A's). Must confirm `firmware.dfu` and the updater `.tgz`
both present and non-empty, and all expected `.fap` outputs (the existing
8 plus however many of this batch's 3 have been imported so far) present.

## CI validation after batch

After all 3 apps are imported and each individually Static/Build-clean:
one more full CI run covering the complete 11-app batch together,
mirroring exactly how Phase 2B's CI run `28877810474` validated its
8-app batch together as the final step before that batch's acceptance
record was written.

## Reviewed false-positive workflow reuse

The existing reviewed-false-positive allowlist mechanism (currently in
`tools/phase2b_validate_config.json`) is reused as-is — no new mechanism
is proposed. Any new match this batch introduces gets its own new entry,
keyed the same way; existing Phase 2A/2B entries are untouched (any future
edit to one of those matched lines automatically reverts it to unreviewed,
by design — this batch's work must not weaken that).

## Artifact hash finalization reuse

If/when this batch reaches its own accepted CI baseline, the existing
finalize-baseline workflow mechanism (real SHA-256 hashing and
tag-pushing done entirely on GitHub's own Windows infrastructure, per
Phase 2A.11/Phase 2B.3) is reused, producing a new set of finalized hashes
and baseline tags for the Phase-2C-inclusive commit — not overwriting the
existing Phase 2A or Phase 2B tags, which remain untouched, immutable
references to their own baselines.

## Hardware gate only after CI baseline acceptance

Exactly the same ordering Phase 2A and Phase 2B both followed: no
hardware-facing validation mode beyond `Preflight`/`ReportOnly` is run
against a Phase-2C-inclusive commit until that commit has its own clean
Static+Build CI result. Given the current Phase 2B.4 classification
(`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, no physical device
or Windows machine available to this AI session), a Phase 2C hardware
gate would face the identical structural blocker unless the project owner
performs it themselves on real hardware. This plan does not run
`HardwareAssisted` mode and does not flash hardware — this phase is
planning only.

## No release-ready claim

Nothing in this plan, or in any future execution of it, constitutes a
release-readiness claim on its own. Release-readiness requires the
project's full release-gate checklist (real hardware flashing/testing,
completed by a human) — a clean CI result for a Phase-2C-inclusive commit
would mean the same narrow thing Phase 2A's and Phase 2B's acceptance
records mean: a CI-baseline-only acceptance, not release-readiness.

## Rollback plan

Identical mechanism to Phase 2A's and Phase 2B's own rollback discipline:
each app's import is a single, isolated commit touching only that app's
own files plus its manifest-registration/`.gitignore`-exception lines, so
rolling back any single app means reverting that one commit (or removing
that app's files + registration entry and rebuilding to confirm a clean
return to the prior baseline) without affecting the other 2 apps in the
batch, or anything from Phase 2A/2B. If a problem is found only after the
full-batch CI run, the same per-commit granularity means the specific
offending app's commit can be identified and reverted without discarding
the other two.

## Stop conditions

- **Stop immediately if this plan, or any future execution of it, is asked
  to import code in what is still a planning-only phase** — this document
  describes a future plan, it does not authorize starting it.
- **Stop and mark DEFER** if any of the 3 apps' real source (read at actual
  import time, i.e. at Phase 2C.1) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability this planning phase's citation-only review
  did not catch.
- **Stop and mark DEFER** if any of the 3 apps turns out to have an
  unclear license or unattributed bundled third-party code at actual
  verification time.
- **Stop and mark NEEDS REVIEW** if any app requires source changes
  outside its own app directory.
- **Stop and root-cause, don't route around**, any Static/Build validation
  FAIL.
- **Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free** at any point in this plan's execution, regardless of how
  clean CI results look.
- **Phase 2C implementation itself does not start from this document** —
  it requires the project owner's own separate, explicit request, exactly
  as every phase transition in this project has required so far, and even
  then, per `docs/PHASE2C_NEXT_GATE.md`, the next actual step is Phase
  2C.1 pre-import source/license verification, not import itself.

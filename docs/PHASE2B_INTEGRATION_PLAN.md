# Phase 2B — Integration Plan

Docs only. Planning only. **This document describes how a future,
separately-approved Phase 2B implementation would proceed — it does not
itself start that implementation.** Every mechanism described here already
exists and was already exercised in Phase 2A; this plan proposes reusing
it unmodified, not redesigning it.

## Branch strategy

- Continue using `integration/phase2a-first-batch` as the working branch
  for actual import work, exactly as Phase 2A did — no new branch is
  proposed. (If the project owner later prefers a dedicated
  `integration/phase2b-...` branch to keep the two batches' history
  separable, that is their call to make at implementation time, not a
  decision this planning phase makes for them.)
- Continue mirroring every accepted docs/tooling commit to
  `claude/flipper-custom-firmware-cxrcer`, the same discipline used
  throughout Phase 2A and Phase 2A.9–2A.12.
- No branch is created, renamed, merged, or force-pushed by this planning
  phase itself.

## Import order

Per `PHASE2B_RECOMMENDED_BATCH.md`:

1. `flipfetch`
2. `quadratic_solver`
3. `sudoku`

## One-app-at-a-time rule

Identical to the rule Phase 2A actually followed: each app is added in its
own commit, and the tree is rebuilt/re-validated after each individual
addition before the next app is started. No two apps are ever combined
into a single import commit. If one app in the sequence has a problem, it
is diagnosed and fixed (or deferred) on its own — it does not block or get
bundled with the next app, and the next app is not started until the
current one reaches a clean state or is explicitly deferred.

## Commit-per-app rule

Each app's import commit contains exactly that app's source files plus its
own `application.fam` and any required one-line registration entry — the
same scope discipline Phase 2A used (and the same discipline this very
planning phase's own commit validation follows: docs-only in, docs-only
out).

## Static validation after each app

After each app's commit: `tools/phase2a_validate.ps1 -Mode Static
-ExpectedCommit <commit>`, reusing the existing risky-keyword scan and
`highConfidenceUnsafeKeywords` hard-fail tier unmodified. Any new
risky-keyword match introduced by a Phase 2B app must go through the exact
same reviewed-false-positive process already documented in
`PHASE2A_AUTOMATED_VALIDATION.md` (individually keyed on file path + line
number + keyword + SHA-256 of the trimmed line text) — never a blanket
suppression, never skipped.

## Build validation after each app, if feasible

After each app's commit: `tools/phase2a_validate.ps1 -Mode Build
-ExpectedCommit <commit>` on a real Windows machine, or via the existing
`.github/workflows/phase2a-windows-validation.yml` GitHub Actions workflow
(the same real Windows-runner path Phase 2A relied on throughout, since
this cloud sandbox cannot run `fbt.cmd` at all — a Windows batch file
cannot even be launched as a process here, a structural limitation
documented since Phase 2A.6). Must confirm `firmware.dfu` and the updater
`.tgz` both present and non-empty, and all expected `.fap` outputs
(Phase 2A's 5 plus however many of this batch's 3 have been imported so
far) present.

## CI validation after batch

After all 3 apps are imported and each individually Static/Build-clean:
one more full CI run (`Phase 2A Windows Validation` workflow, or its
Phase-2B-renamed equivalent if the project owner wants a distinct
workflow name) covering the complete batch together, mirroring exactly how
Phase 2A's CI run `28814008347` validated all 5 apps together as the final
step before that batch's acceptance record was written.

## Reviewed false-positive workflow reuse

The existing `tools/phase2a_validate_config.json` reviewed-false-positive
allowlist mechanism is reused as-is — no new mechanism is proposed. Any
new match this batch introduces gets its own new entry, keyed the same
way; existing Phase 2A entries are untouched (any future edit to one of
those matched lines automatically reverts it to unreviewed, by design —
this batch's work must not weaken that).

## Artifact hash finalization reuse

If/when this batch reaches its own accepted CI baseline, the existing
`.github/workflows/phase2a-finalize-baseline.yml` mechanism (real SHA-256
hashing and tag-pushing done entirely on GitHub's own Windows
infrastructure, per Phase 2A.11) is reused, producing a new set of
finalized hashes and baseline tags for the Phase-2B-inclusive commit — not
overwriting the existing Phase 2A tags (`phase2a-ci-baseline-20260707`,
`phase2a-acceptance-record-20260707`), which remain untouched, immutable
references to the Phase 2A-only baseline.

## No hardware gate until CI passes

Exactly the same ordering Phase 2A itself follows: `tools/
phase2a_hardware_gate.ps1 -Mode HardwareAssisted` (or any hardware-facing
mode beyond `Preflight`/`ReportOnly`) is not run against a Phase-2B-
inclusive commit until that commit has its own clean Static+Build CI
result. Hardware-assisted validation continuing to report `BLOCKED -
DEVICE NOT AVAILABLE` (as it currently does for the Phase 2A baseline, per
`docs/PHASE2A_HARDWARE_ASSISTED_RESULTS.md`) does not block CI validation
or this planning work — but it does mean, per `docs/PHASE2A_NEXT_GATE.md`'s
Phase-2B-gating rule, that Phase 2B *implementation* is only appropriate as
non-hardware-dependent work until either a real hardware-assisted run
happens or the project owner makes an explicit informed decision to
proceed without one.

## No release-ready claim

Nothing in this plan, or in any future execution of it, constitutes a
release-readiness claim on its own. Release-readiness requires the
project's full release-gate checklist (real hardware flashing/testing via
`docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md`, completed by a human, plus
whatever additional criteria that checklist's parent gate defines) — a
clean CI result for a Phase-2B-inclusive commit would mean the same narrow
thing Phase 2A's acceptance record means: **`PHASE 2B ACCEPTED FOR
NON-HARDWARE CI BASELINE ONLY`**, if and when that point is actually
reached.

## Rollback plan

Identical mechanism to Phase 2A's own rollback discipline (see
`PHASE2A_ROLLBACK_PLAN.md`): each app's import is a single, isolated commit
touching only that app's own files plus one manifest-registration line, so
rolling back any single app means reverting that one commit (or removing
that app's files + registration entry and rebuilding to confirm a clean
return to the prior baseline) without affecting the other 2 apps in the
batch, or anything from Phase 2A. If a problem is found only after the
full-batch CI run, the same per-commit granularity means the specific
offending app's commit can be identified and reverted without discarding
the other two.

## Stop conditions

- **Stop immediately if this plan, or any future execution of it, is asked
  to import code in what is still a planning-only phase** — this document
  describes a future plan, it does not authorize starting it.
- **Stop and mark DEFER** if any of the 3 apps' real source (read at actual
  import time) shows RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR
  capability this planning phase's citation-only review did not catch.
- **Stop and mark DEFER** if any of the 3 apps turns out to have an
  unclear license or unattributed bundled third-party code at actual import
  time.
- **Stop and mark NEEDS REVIEW** if any app requires source changes outside
  its own app directory (e.g. anything beyond a simple, additive one-line
  registration entry).
- **Stop and root-cause, don't route around**, any Static/Build validation
  FAIL — the same standing rule applied throughout every prior phase of
  this project (e.g. the `protobuf_version.h` root-cause fix in Phase 2A).
- **Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free** at any point in this plan's execution, regardless of how clean
  CI results look.
- **Phase 2B implementation itself does not start from this document** —
  it requires the project owner's own separate, explicit request, exactly
  as every phase transition in this project has required so far.

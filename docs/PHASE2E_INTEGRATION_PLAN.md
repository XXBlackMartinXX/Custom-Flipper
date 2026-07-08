# Phase 2E — Integration Plan

Docs only. Planning only. **This document describes how a future,
separately-approved Phase 2E implementation would proceed — it does not
itself start that implementation.** Every mechanism described here already
exists and was already exercised in Phase 2A, Phase 2B, Phase 2C, and
Phase 2D; this plan proposes reusing it unmodified, not redesigning it.

## Branch strategy

- **Proposed implementation branch name**: `integration/phase2e-first-batch`,
  branched from the accepted Phase 2D baseline commit
  (`d0812638a02c50389b9e713ad98f2c8215b75dd5` on
  `integration/phase2d-first-batch`, or the branch's later HEAD if the
  project owner prefers), the same "new named branch per batch"
  convention `integration/phase2d-first-batch` itself established
  relative to `integration/phase2c-first-batch`.
- Continue mirroring every accepted docs/tooling commit to
  `claude/flipper-custom-firmware-cxrcer`, the same discipline used
  throughout every prior phase.
- No branch is created, renamed, merged, or force-pushed by this planning
  phase itself. `integration/phase2e-first-batch` does not exist yet as
  of this document.

## Import order

Per `docs/PHASE2E_RECOMMENDED_BATCH.md`:

1. `image_viewer`
2. `boilerplate`
3. `minesweeper`

## One-app-at-a-time rule

Identical to the rule every prior phase actually followed: each app is
added in its own commit, and the tree is rebuilt/re-validated after each
individual addition before the next app is started. No two apps are ever
combined into a single import commit. If one app in the sequence has a
problem, it is diagnosed and fixed (or deferred) on its own — it does not
block or get bundled with the next app.

## Commit-per-app rule

Each app's import commit contains exactly that app's source files plus its
own `application.fam`, its own `applications_user/.gitignore` exception
entries (the `!/appname/` and `!/appname/**` pattern every prior batch has
added for each of its apps), and any required one-line registration entry
— the same scope discipline every prior phase used.

## Static validation after each app

After each app's commit: `tools/phase2a_validate.ps1 -Mode Static
-ConfigPath tools/phase2e_validate_config.json -ExpectedCommit <commit>`
(a new, 16-app superset config file, if the project owner wants Phase 2E
tracked in its own config the same way each prior phase's config
superseded the last for validation purposes — reuses the same
`-ConfigPath` mechanism added in Phase 2B.2, not a new mechanism). Any new
risky-keyword match introduced by a Phase 2E app must go through the
exact same reviewed-false-positive process already documented
(individually keyed on file path + line number + keyword + SHA-256 hash
of the trimmed line text) — never a blanket suppression, never skipped.
None of the 3 recommended apps is expected to produce a foreseeable
false-positive category the way `crypto_dictionary`'s glossary text did
in Phase 2D, but any unexpected match still gets the same individual
review, not an assumption of safety.

## Build validation after each app, if feasible

After each app's commit: the same `-Mode Build` validation, on a real
Windows machine or via a Phase-2E-named GitHub Actions workflow modeled
directly on `.github/workflows/phase2d-windows-validation.yml`. Must
confirm `firmware.dfu` and the updater `.tgz` both present and non-empty,
and all expected `.fap` outputs (the existing 13 plus however many of
this batch's 3 have been imported so far) present. Given Phase 1.6's own
flag that `minesweeper` and `boilerplate` are the larger file counts in
this batch (20 and 21 files respectively), budget extra
build-verification time for those two commits specifically, the same
discipline already applied to `chess`/`resistors`/`upython` in prior
phases. Also apply the Phase 2D.2A-established `cmd /c` launch-mechanism
fix for the `updater_package` call site unchanged — that remediation is
shared tooling (`tools/phase2a_validate.ps1`), not app-specific, and this
plan does not propose touching it.

## CI validation after batch

After all 3 apps are imported and each individually Static/Build-clean:
one more full CI run covering the complete 16-app batch together,
mirroring exactly how Phase 2D's CI run `28941093859` validated its
13-app batch together as the final step before that batch's acceptance
record was written.

## Reviewed false-positive workflow reuse

The existing reviewed-false-positive allowlist mechanism (currently in
`tools/phase2d_validate_config.json`, 189 entries) is reused as-is — no
new mechanism is proposed. Any new match this batch introduces gets its
own new entry, keyed the same way; existing entries from every prior
phase are untouched (any future edit to one of those matched lines
automatically reverts it to unreviewed, by design — this batch's work
must not weaken that).

## Artifact hash finalization reuse

If/when this batch reaches its own accepted CI baseline, the existing
finalize-baseline workflow mechanism (real SHA-256 hashing and
tag-pushing done entirely on GitHub's own Windows infrastructure, per
Phase 2A.11/Phase 2B.3/Phase 2C.3/Phase 2D.3) is reused, producing a new
set of finalized hashes and baseline tags for the Phase-2E-inclusive
commit — not overwriting the existing Phase 2A/2B/2C/2D tags, which
remain untouched, immutable references to their own baselines.

## Hardware gate only after CI baseline acceptance

Exactly the same ordering every prior phase followed: no hardware-facing
validation mode beyond `Preflight`/`ReportOnly` is run against a
Phase-2E-inclusive commit until that commit has its own clean
Static+Build CI result. Given the current Phase 2D.4 classification
(`HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, no physical device
or Windows machine available to this AI session), a Phase 2E hardware
gate would face the identical structural blocker unless the project owner
performs it themselves on real hardware. This plan does not run
`HardwareAssisted` mode and does not flash hardware — this phase is
planning only.

## No release-ready claim

Nothing in this plan, or in any future execution of it, constitutes a
release-readiness claim on its own. Release-readiness requires the
project's full release-gate checklist (real hardware flashing/testing,
completed by a human) — a clean CI result for a Phase-2E-inclusive commit
would mean the same narrow thing every prior phase's acceptance record
means: a CI-baseline-only acceptance, not release-readiness.

## Rollback plan

Identical mechanism to every prior phase's own rollback discipline: each
app's import is a single, isolated commit touching only that app's own
files plus its manifest-registration/`.gitignore`-exception lines, so
rolling back any single app means reverting that one commit (or removing
that app's files + registration entry and rebuilding to confirm a clean
return to the prior baseline) without affecting the other 2 apps in the
batch, or anything from Phase 2A/2B/2C/2D. If a problem is found only
after the full-batch CI run, the same per-commit granularity means the
specific offending app's commit can be identified and reverted without
discarding the other two.

## Stop conditions

- **Stop immediately if this plan, or any future execution of it, is asked
  to import code in what is still a planning-only phase** — this document
  describes a future plan, it does not authorize starting it.
- **Stop and mark DEFER** if any of the 3 apps' real source (read at actual
  import time, i.e. at Phase 2E.1) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability this planning phase's citation-only review
  did not catch.
- **Stop and mark DEFER** if any of the 3 apps turns out to have an
  unclear license or unattributed bundled third-party code/data at actual
  verification time — this specifically includes `image_viewer`'s 3
  bundled example bitmap files, whose provenance is a named open question
  in `docs/PHASE2E_LICENSE_REVIEW.md`.
- **Stop and mark DEFER** if any of the 3 apps is found to handle
  credentials, tokens, passwords, seed phrases, keys, exfiltration,
  bypass, cloning, brute force, or HID injection.
- **Stop and mark NEEDS REVIEW** if any app requires source changes
  outside its own app directory.
- **Stop and re-classify storage risk** if any of the 3 apps is found on
  fresh source read to actually write storage outside an app-private
  path — the exact `sd_info` precedent from Phase 2C.1, applied here in
  advance specifically because `image_viewer`'s read-only characterization
  is not yet exhaustively confirmed.
- **Stop and root-cause, don't route around**, any Static/Build validation
  FAIL.

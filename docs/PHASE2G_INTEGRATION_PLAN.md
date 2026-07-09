# Phase 2G — Integration Plan

Docs only. Planning only. No code is imported by this document.

## No implementation branch proposed

Since `docs/PHASE2G_RECOMMENDED_BATCH.md` recommends **no import batch**,
this document does not propose an `integration/phase2g-first-batch`
branch, an import order, a commit-per-app discipline, or any of the
batch-execution mechanics that would normally follow a GO/GO WITH
CONDITIONS recommendation. Standing up an implementation branch with
nothing safe to import in it would be inconsistent with this phase's own
conclusion.

## Recommended non-import alternatives

Restated from `docs/PHASE2G_RECOMMENDED_BATCH.md`, in order of likely
value:

1. **Phase 2F hardware-assisted validation on a real device.** The
   tooling (`tools/phase2f_hardware_gate.ps1`,
   `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md`) is complete and ready
   to run the moment a Windows machine and a physical Flipper Zero
   become available. This is the highest-value next action available to
   this project overall, independent of any Phase 2G decision, since it
   is the actual blocker on any future release-readiness consideration.
2. **A narrow `fcc_id_lookup` license-resolution phase.** Fetch the
   confirmed upstream `LICENSE` (`github.com/lrehmann/fcc-id-lookup-flipper`)
   and confirm it applies to the exact vendored revision
   (`472f6925e8aca9bd031cb37e3cb80b551772c957`). A narrow,
   well-scoped, low-effort follow-up that could clear exactly one of the
   6 hard-deferred apps without touching the other 5.
3. **Documentation consolidation.** This project now has over 140
   phase-specific docs across two branches; a consolidation pass (a
   single up-to-date status index, cross-reference cleanup) would improve
   navigability without touching any source.
4. **Validator/CI/tooling hardening.** `tools/phase2a_validate.ps1` and
   the various `phaseXX-*.yml` workflows have each been extended
   incrementally per-phase; a dedicated hardening pass (consolidating
   duplicated logic, adding regression tests for the Phase 2D.2A/2F.2A
   stderr-handling fix specifically) would reduce the chance of a similar
   CI blocker recurring in any future phase.
5. **Third-party notice audit.** A consolidated cross-phase audit of
   every `THIRD_PARTY_NOTICES.md` file, to confirm consistency and
   completeness across all 19 imported apps in one place, rather than
   spread across 5 separate phase-specific documents.
6. **Release-readiness gap audit, without a release claim.** A survey
   document listing exactly what remains before a real release-ready
   determination could be made — hardware validation completion being
   the largest single gap, plus a final confirmation that every existing
   `THIRD_PARTY_NOTICES.md`/`LICENSE_ATTRIBUTION.md` is complete and
   consistent. This survey would not itself claim release-ready.
7. **A dedicated, fresh Phase 1-style bulk triage of the remaining
   ~170-app pool**, only if the project owner wants app expansion to
   continue at all beyond the audited Top 25 — a distinct, larger
   undertaking requiring its own explicit commissioning, not something
   this document starts.

## Explicit statement

**Phase 2G implementation/import is not recommended.** No branch is
created, no app directory is copied, no build is attempted, and no
firmware or app source changes as a result of this document.

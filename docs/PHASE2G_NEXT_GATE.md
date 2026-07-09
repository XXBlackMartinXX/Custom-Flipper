# Phase 2G — Next Gate

Docs only. This defines the gate that must be reviewed after Phase 2G
planning (this package) before any further phase is even considered. It
does not itself authorize anything — it defines the checkpoint that
comes before that decision is made, mirroring
`docs/PHASE2F_NEXT_GATE.md`'s role for Phase 2F planning.

## Phase 2G result: NO-GO / CLEAN CANDIDATE POOL EXHAUSTED

See `docs/PHASE2G_GO_NO_GO.md` for the full classification.
**Phase 2G implementation/import is not the next gate.**

## Current status against this gate

| Step | Status |
|---|---|
| Phase 2G candidate review | Complete — `docs/PHASE2G_CANDIDATE_REVIEW.md` |
| Phase 2G recommended batch | **None recommended** — `docs/PHASE2G_RECOMMENDED_BATCH.md` |
| Phase 2G risk register | Complete (risk of continuing / hard-deferred restatement) — `docs/PHASE2G_RISK_REGISTER.md` |
| Phase 2G license review | Complete (no new review; existing gaps preserved) — `docs/PHASE2G_LICENSE_REVIEW.md` |
| Phase 2G integration plan | **No implementation branch proposed**; non-import alternatives listed — `docs/PHASE2G_INTEGRATION_PLAN.md` |
| Phase 2G go/no-go | **NO-GO / CLEAN CANDIDATE POOL EXHAUSTED** — `docs/PHASE2G_GO_NO_GO.md` |
| Phase 2G.1 (pre-import verification) | **Not applicable.** No candidate exists to verify. |
| Phase 2G implementation/import | **Not started, not recommended.** |
| Hardware-assisted validation | Unchanged from Phase 2F.4 — `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`, see `docs/PHASE2F_HARDWARE_ASSISTED_RESULTS.md`. Nothing in this phase touches hardware. |
| `fcc_id_lookup` license gap | Unchanged — still open, see `docs/KNOWN_ISSUES.md` item 6. Not touched by this phase. |
| `image_viewer/example_images/` | Unchanged — still excluded, confirmed absent. Not touched by this phase. |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** — unchanged. |

## Next allowed paths

Since Phase 2G is NO-GO, the next gate is **not** Phase 2G
implementation. Recommended, in order of likely value (restated from
`docs/PHASE2G_RECOMMENDED_BATCH.md`):

- **Path A — Phase 2F hardware-assisted validation on real hardware**,
  once a Windows machine and a physical Flipper Zero become available:
  run `tools/phase2f_hardware_gate.ps1 -Mode HardwareAssisted` for real,
  then complete `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` on the
  device. The single highest-value action available to this project
  right now, independent of any Phase 2G outcome.
- **Path B — a narrow `fcc_id_lookup` license-resolution phase**: fetch
  the confirmed upstream `LICENSE`
  (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it applies to
  the exact vendored revision. Explicitly out of Phase 2G's own scope
  per this phase's instructions, but available as its own, separate,
  narrow follow-up.
- **Path C — a maintenance/QA consolidation phase**: documentation
  consolidation, validator/CI/tooling hardening, or a third-party notice
  audit — see `docs/PHASE2G_INTEGRATION_PLAN.md` for the full list.
- **Path D — a release-readiness gap audit without a release claim**: a
  survey of exactly what remains before real release-ready status could
  be considered, without itself claiming it.
- **Path E — a dedicated, fresh Phase 1-style bulk triage** of the
  remaining ~170-app pool, only if the project owner wants app expansion
  to continue at all beyond the audited Top 25. A distinct, larger
  undertaking requiring its own explicit commissioning.

None of Paths A-E is started by this document — each requires the
project owner's own separate, explicit request, exactly as every prior
phase transition in this project has required.

## What this gate does not authorize

- **Does not start Phase 2G implementation/import.** There is no
  candidate to import.
- **Does not constitute hardware testing.** Hardware remains **NOT
  PERFORMED**. Nothing in this document runs `-Mode HardwareAssisted`,
  flashes a device, or claims hardware-tested status.
- **Does not resolve `fcc_id_lookup`'s license gap.** See Path B above —
  a separate, narrow, explicitly-requested follow-up, not resolved here.
- **Does not reintroduce `image_viewer/example_images/`.** That
  exclusion is unrelated to and unaffected by anything in this document.
- **Does not weaken or revert the Phase 2F.2A `barcode_gen` source fix.**
  Nothing in this document touches source.
- **Does not constitute release-readiness.** Release status remains
  **TEST-READY ONLY / NOT RELEASE-READY.**

Hardware remains **NOT PERFORMED**. Release-ready remains **blocked**.
`fcc_id_lookup` remains **deferred** unless separately resolved.
`image_viewer/example_images/` remains **excluded**.

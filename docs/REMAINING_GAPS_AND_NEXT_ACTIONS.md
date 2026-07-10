# Remaining Gaps and Next Actions

Docs-only. Honest inventory of what this project has **not** done,
following the full non-hardware 20-app baseline and this consolidation
audit, plus the recommended order of next actions.

## What has not been done

- **Real hardware validation has not been performed.** No physical
  Flipper Zero device exists in this project's environment at any
  point in its history. No `-Mode HardwareAssisted` workflow invocation
  has ever progressed past a preflight/report-only/detect-device check
  (Phase 2D's hardware gate tooling exists and was exercised in those
  three non-flashing modes only).
- **GUI smoke testing has not been performed.** No human has observed
  any of the 20 apps running on a real device screen, navigating their
  menus, or exercising their UI flows interactively.
- **Rollback has not been verified on device.** `docs/PHASE2A_ROLLBACK_PLAN.md`
  documents a rollback procedure, but it has never been executed against
  real hardware — it is a plan, not a demonstrated recovery.
- **No release candidate has been declared.** No version number, release
  branch, or release tag has been created for this firmware build at any
  point.
- **No release-ready claim has been made or is made by this audit.**
  Every phase and this consolidation both explicitly state **TEST-READY
  ONLY / NOT RELEASE-READY**.
- **`docs/KNOWN_ISSUES.md` on the documentation branch is not fully
  current with the integration branch.** As of this audit, it still
  describes `fcc_id_lookup` as "not yet imported," while the integration
  branch has it imported and baseline-finalized. This is a
  documentation-currency gap, not a safety or functional defect — see
  the KNOWN_ISSUES decision recorded in this audit's `BUILD_LOG.md`
  entry.

## Remaining deferred apps

Six candidates from the project's audited Top-25 shortlist were
considered and never imported; five remain deferred/excluded (the sixth,
`fcc_id_lookup`, was resolved and imported):

| App | Status | Blocking reason |
|---|---|---|
| `upython` | Excluded | Undisclosed GPIO write + IR-transmit capability exposed to arbitrary user scripts |
| `iconedit` | Excluded | BadUSB/HID keystroke-injection capability |
| `c_book` | Deferred | Unresolved copyright status of bundled K&R book text |
| `animation_switcher` | Excluded | Shared/root-level `/ext/dolphin/` write |
| `theme_manager` | Excluded | Shared/root-level `/ext/dolphin/` write |

None of these five is reconsidered by this audit. The broader ~170-app
candidate pool beyond the audited Top-25 has never received individual
per-app source-level verification and remains untouched.

## Recommended next actions, in order

1. **Final 20-app hardware-assisted validation on real Windows +
   Flipper Zero.** This is the single largest remaining gap: every
   result in this project to date is static-source and CI-build
   verification only. A real device and a real Windows machine (or a
   CI runner with genuine hardware access) are required to flash,
   boot, and interactively exercise all 20 apps, plus verify the
   rollback plan actually recovers a device.
2. **Release-readiness gap audit, without a release claim.** Once
   hardware validation exists, a dedicated audit should identify what
   (if anything) remains between "hardware-validated" and
   "release-ready" — versioning scheme, changelog format, release
   packaging — without itself declaring release-ready.
3. **Docs/tooling cleanup.** Reconcile the documentation branch's
   `KNOWN_ISSUES.md` currency gap noted above; consider whether the
   now-large `docs/` directory (150+ files) would benefit from an index
   or archival pass, without altering any accepted phase's historical
   record.
4. **Optional fresh bulk triage, only if app expansion resumes.** The
   Phase 2G NO-GO conclusion (clean, audited candidate pool exhausted)
   still stands. Any future app-count expansion beyond today's 20 should
   start with a new Phase-1-style bulk triage and source audit of the
   ~170-app untouched pool, or a resolution of one of the 5 remaining
   deferred apps' specific blocking concerns — not an ad hoc import.

## Explicit boundaries carried forward

- No hardware will be flashed by this document or this audit.
- No release-ready claim is made.
- This audit does not start hardware validation, release-readiness
  work, or a new import batch — each remains a separate,
  explicitly-requested future step.

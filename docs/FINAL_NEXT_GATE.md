# Final Next Gate — Decision Tree After This Hardware-Gate Pack

Docs only. Defines the allowed next steps after the final 20-app
hardware-assisted validation gate pack (`tools/final_hardware_gate.ps1`,
`tools/final_hardware_gate_config.json`,
`docs/FINAL_HARDWARE_ASSISTED_VALIDATION.md`,
`docs/FINAL_HARDWARE_ASSISTED_RESULTS.md`,
`docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`), based on the actual
classification recorded in `docs/FINAL_HARDWARE_ASSISTED_RESULTS.md`.

## Current classification

**HARDWARE VALIDATION BLOCKED — DEVICE NOT AVAILABLE.** No physical
Flipper Zero and no Windows machine exist in this project's environment.
This is a structural blocker, not a defect and not a quality gap in the
accepted non-hardware CI baseline.

## Decision tree

### If final hardware validation is BLOCKED because no device is available (current state)

The next recommended gate is one of:

1. **Real hardware validation, when a device becomes available.** A
   human with a Windows machine and a physical Flipper Zero runs
   `tools/final_hardware_gate.ps1 -Mode Preflight`, then `-Mode
   HashVerify` against the real downloaded CI artifacts, then `-Mode
   DetectDevice`/`-Mode HardwareAssisted`, then completes
   `docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md` for all 20 apps and
   records results in a filled-in copy of
   `docs/PHASE2A_HARDWARE_TEST_RESULTS_TEMPLATE.md`.
2. **A release-readiness gap audit, without a release claim.** This
   audit may proceed in parallel with (1) — it identifies what
   documentation, versioning, or packaging work remains before a
   release could be considered, without itself declaring release-ready
   or starting a release.

Both are legitimate next steps; neither is started by this document.

### If final hardware validation FAILS

If a future real run of `tools/final_hardware_gate.ps1
-Mode HardwareAssisted` (or the smoke-test checklist) produces a real
`FAIL` — a hash mismatch, a regressed source fix (`barcode_gen`,
`fcc_id_lookup` LICENSE), a reintroduced excluded asset
(`image_viewer/example_images/`), an accidentally-present FCC database,
a crash, an unexpected hardware activation, or an unexpected persistent
storage write — then:

- A release-readiness gap audit **may** document the failure honestly.
- **No release-candidate path may start until the failure is
  resolved.** The specific defect must be root-caused and fixed (or
  the finding must be shown to be a false positive, following this
  project's established review discipline), and the gate re-run to a
  real `PASS` before any release consideration resumes.

### If final hardware validation PASSes with real device evidence

If a future real run achieves `HARDWARE VALIDATION PASS WITH HUMAN
OBSERVATION PENDING` and the smoke-test checklist is then completed for
all 20 apps with no global fail condition, recorded honestly:

- The next gate is a **release-readiness gap audit** — not an automatic
  release. Passing hardware validation is necessary but not sufficient
  for release-readiness.

### Release-ready remains blocked until all of the following are explicitly complete

- Real hardware validation (device detection + artifact hash
  verification against real downloaded artifacts + a completed
  `HardwareAssisted` run with no FAIL/BLOCKED).
- GUI smoke testing (`docs/FINAL_HARDWARE_SMOKE_TEST_CHECKLIST.md`, all
  20 apps, no global fail condition).
- Rollback verification on a real device (per
  `docs/PHASE2A_FLASHING_PRECHECK.md` §5).
- License audit (already complete for the non-hardware baseline —
  `docs/THIRD_PARTY_LICENSE_AUDIT.md` — but should be re-confirmed
  current at release time).
- Safety audit (already complete for the non-hardware baseline —
  `docs/SAFETY_CAPABILITY_AUDIT.md` — but should be re-confirmed
  current at release time).
- Known-issue review (`docs/KNOWN_ISSUES.md` — confirm zero open items
  block release, or that any open item is explicitly accepted as a
  known limitation).

None of these six items is satisfied by this hardware-gate pack alone.
This document does not start, and does not authorize starting, a
release-readiness audit — it only defines the gate that would need to
pass first.

## Explicit boundaries carried forward

- No hardware has been flashed by this phase.
- No release-ready claim is made.
- No release-readiness audit is started by this phase.
- Release status remains **TEST-READY ONLY / NOT RELEASE-READY**.

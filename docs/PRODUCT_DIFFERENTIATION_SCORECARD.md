# Product Differentiation Scorecard

## Purpose

Answers, honestly, the question this phase's mission opened with: is
Custom-Flipper on track to be "measurably better than merely combining
existing firmware," or is it still just another app collection? This
scorecard tracks concrete, falsifiable differentiators — not marketing
claims — against their real implementation status.

## Scoring key

- **Designed**: an RFC or architecture document exists.
- **Prototyped**: a proof-of-concept exists (code, schema, or data),
  not yet hardware-validated.
- **Hardware-validated**: actually run on real hardware with recorded
  evidence.
- **Shipped**: part of an accepted, released build.

No differentiator in this phase has reached "Hardware-validated" or
"Shipped" — this is a foundation phase, not an implementation phase.

## Scorecard

| Differentiator | Status | Evidence |
|---|---|---|
| Automated hardware test platform (vs. manual smoke testing only) | Prototyped | `tools/hardware_app_tester/` — 20/20 unit tests passing against synthetic data; zero real hardware runs (see `docs/AUTOMATED_HARDWARE_TEST_RESULTS.md`) |
| Per-app health tracking (Custom App Health Center) | Designed | `docs/architecture/rfc-1-custom-app-health-center.md` |
| Installable, versioned app packs with rollback (Smart App Packs) | Designed | `docs/architecture/rfc-2-smart-app-packs.md` |
| Unified cross-category search | Designed | `docs/architecture/rfc-3-unified-search-command-palette.md` |
| Honest hardware/module compatibility tracking (never claim support before testing) | Designed | `docs/architecture/rfc-4-hardware-module-compatibility-hub.md` |
| Non-destructive crash isolation (vs. full-recovery-only) | Designed | `docs/architecture/rfc-5-safe-mode-crash-isolation.md` |
| Automated upstream tracking (vs. one-time manual census) | Designed | `docs/architecture/rfc-6-upstream-intelligence-sync-automation.md`; this phase's own manual census in `docs/ecosystem/` is the real precedent it would automate |
| Modular firmware profiles (vs. one unbounded build) | Designed | `docs/architecture/MODULAR_FIRMWARE_PROFILES.md` |
| Resource-budget discipline before every import wave | Designed, partially groundable | `docs/RESOURCE_BUDGETS.md` — only 2 of 8 budget categories have any real number behind them yet |
| Source-pinned, license-audited ecosystem awareness (vs. ad hoc copying) | Prototyped | `docs/ecosystem/` — real commit pins and license hashes for 7 repositories, 34 individually catalogued candidates out of ~1,330 discovered |

## Where this project is genuinely ahead of "just combining firmware," already

- **License/provenance discipline**: this phase confirmed, for real,
  that every one of the 4 primary upstream firmware repositories (plus
  this project's own) ships the byte-identical GPL-3.0 license text —
  and, separately, found 3 of this project's own 20 apps are missing a
  per-app `LICENSE` file, a real gap most casual "combine everything"
  forks would not have surfaced at all (see
  `docs/ecosystem/LICENSE_COMPATIBILITY_MATRIX.md`).
- **Explicit rejection of unsafe app families**: this phase's census
  explicitly catalogued and rejected an entire family of RogueMaster
  apps matching this project's forbidden-automation scope (deauth,
  jamming, HID injection, sniffing — see
  `docs/ecosystem/REJECTED_CANDIDATES.md`), rather than silently
  re-bundling "whatever RogueMaster has" the way a naive combination
  approach would.
- **Duplicate-awareness, not blind accumulation**: this phase's
  cross-reference found that RogueMaster alone carries duplicate
  "original" variants of two of this project's own apps
  (`2048`/`game2048`, `minesweeper_redux`/`minesweeper_og`) and
  explicitly recommends rejecting the redundant originals rather than
  importing both (see `docs/ecosystem/DUPLICATE_AND_SUPERSESSION_MATRIX.md`).

## Where this project is NOT yet ahead, honestly

- No real hardware test has ever run through the new automated tester —
  this project's actual hardware-validation rigor is currently no
  better than "a human manually clicked through a smoke-test checklist"
  (which is what the Controlled Installation phase actually did).
- None of the six RFCs have moved past the design stage — a user
  running this firmware today gets no different experience than any
  other Unleashed-derived fork.
- Resource budgets are mostly unmeasured placeholders, not enforced
  gates yet.

## Next milestone that would move the needle

The single highest-value next step, per this scorecard, is **running
the hardware app tester against a real device for the first time** —
every other differentiator (Health Center test-status data, real
resource numbers, a real Gate A/B pass) depends on that first real
execution existing at all.

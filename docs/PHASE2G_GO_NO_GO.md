# Phase 2G — Go / No-Go

Docs only. Planning only. No code is imported by this document.

## Final classification: **NO-GO / CLEAN CANDIDATE POOL EXHAUSTED**

The audited Top-25 candidate pool (`docs/PHASE1_5_TOP_25_CANDIDATES.md`,
individually source-audited in `docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`) —
the only pool this project has ever applied real per-app source
verification to before recommending an import — is fully accounted for:
19 apps imported across Phase 2A through Phase 2F, 6 apps hard-deferred
for specific, documented, unresolved reasons. No app in that pool
remains available. The broader ~170-app remainder of the original
195-app pool has never received individual source-level verification,
and this phase's own scope (existing documentation only, no new source
fetch) does not permit responsibly promoting any of it to candidate
status. See `docs/PHASE2G_CANDIDATE_REVIEW.md` for the full analysis.

**This is a valid, evidence-based outcome, not a failure to find
candidates** — the pool was deliberately curated small and safety-first
from the start (`docs/PHASE1_5_TOP_25_CANDIDATES.md`: "A stricter,
cleaner 25 was preferred over a longer list with asterisks"), and this
project has now drawn it down completely and correctly.

## Exact tiny batch: none

No batch is recommended. See `docs/PHASE2G_RECOMMENDED_BATCH.md`.

## Apps explicitly deferred

| App | Deferred reason | Deferred since |
|---|---|---|
| `fcc_id_lookup` | Missing `LICENSE`/SPDX/copyright header in vendored revision | Phase 2C.1 |
| `upython` | Undisclosed GPIO write/read + IR-transmit capability exposed to user scripts | Phase 1.6 |
| `iconedit` | HID keystroke injection via optional "send to PC" feature | Phase 1.6 |
| `c_book` | Unresolved copyright status of bundled K&R text | Phase 2B planning |
| `animation_switcher` | Shared `/ext/dolphin/` writes, not app-private | Phase 1.6 |
| `theme_manager` | Shared `/ext/dolphin/` writes, not app-private (with confirmed backup step) | Phase 1.6 |

None is resolved, weakened, or reopened for re-review by this phase.

## Conditions before any future implementation

If a future Phase 2G-equivalent is to responsibly recommend a real
batch, at least one of the following must first happen:

1. A dedicated, fresh Phase 1-style bulk-triage-and-source-audit pass
   over the remaining ~170-app pool, matching the exact rigor
   `docs/PHASE1_6_TOP25_SOURCE_AUDIT.md` applied to the Top 25 — not a
   metadata-only skim.
2. Resolution of one or more of the 6 hard-deferred apps' specific,
   individual concerns (see `docs/PHASE2G_RISK_REGISTER.md`'s stop
   conditions per app) — most tractably, `fcc_id_lookup`'s narrow
   license-resolution path.

Neither condition is satisfied by this document.

## Prompt canaries for any future implementation attempt

- If any candidate app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/
  GPIO/IR, stop and mark DEFER unless already proven harmless and
  explicitly approved.
- If any candidate app has an unclear license or bundled third-party
  code/data/assets/text without provenance, stop and mark DEFER.
- If any candidate app requires hardware testing before basic CI
  confidence, stop and mark DEFER.
- If any candidate app requires source changes outside its own app
  directory, stop and mark NEEDS REVIEW.
- If any candidate app handles credentials, tokens, passwords, seed
  phrases, private keys, wallets, exfiltration, bypass, cloning, brute
  force, scanner-emulation, access-control, or HID injection, mark
  DEFER.
- If evidence is missing, write NEEDS REVIEW instead of guessing.
- If no clean candidates remain, say so directly instead of forcing
  another batch — exactly the outcome this document itself reaches.
- Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free.

## Statement

**PHASE 2G PLANNING ONLY / NO CODE IMPORT PERFORMED.** No application
directory was created or modified, no build was attempted, and no
firmware or app source changed as a result of this phase.

# Phase 2C.1 — Go / No-Go

Docs only. Pre-import verification only. This is the closing decision
document for Phase 2C.1 — it recommends a path, it does not take it.

## Final Phase 2C.1 classification: **PHASE 2C.1 NEEDS REVIEW**

This is not a full stop and not an unqualified pass. Of the 3 apps in the
Phase 2C recommended tiny batch, **2 are cleared for import** (`sd_info`,
`docviewlite`) and **1 is deferred** (`fcc_id_lookup`) on a specific,
low-severity license-evidence gap. Per this phase's own instructions ("If
1 or 2 apps are cleared: recommend a reduced batch; do not substitute new
apps automatically"), this is exactly that situation, and the
classification reflects it honestly rather than rounding up to a clean
pass or down to a full no-go.

## Apps cleared for implementation

1. **`sd_info`** (Tools) — GPLv3 license confirmed directly in the vendored
   source (full, unmodified text). Zero real safety/API-capability hits.
   **One material correction from the planning phase**: this app is not
   zero-storage/read-only as previously assumed — it performs a real,
   transient, self-cleaning, explicitly user-initiated SD-card
   read/write/delete benchmark at `/ext/sdtest.tmp*` (not app-private, not
   persistent, not automatic, not on the safety-exclusion list). Cleared
   with this corrected risk understanding, not despite it being hidden.
2. **`docviewlite`** (Tools) — MIT license confirmed directly in the
   vendored source (full, unmodified text). Zero real safety/API-capability
   hits. Read-only storage only, confirming rather than correcting the
   planning-phase assumption. One build-risk note (a manifest field
   referencing a non-existent `images/` asset directory) flagged for
   observation at Static/Build validation time, not blocking readiness.

## Apps deferred and why

- **`fcc_id_lookup`** — **DEFER (license-evidence gap)**. The
  RogueMaster-vendored copy of this app — the exact artifact that would be
  imported — contains no `LICENSE` file, no SPDX identifier, and no
  copyright header anywhere in its source. Strong corroborating evidence
  (a real, confirmed MIT license, same author, same project, found at the
  exact upstream repository this app's own manifest links to) exists, but
  is not commit-pinned to the specific historical revision RogueMaster
  vendored, and this project's standing rule is not to guess a license
  into existence. This is a **materially lower-severity DEFER** than
  `c_book`'s (no unresolved copyright question, no commercial content, no
  capability concern) — it has a clear, low-effort resolution path: fetch
  and include the confirmed upstream `LICENSE` file at actual import time.
  Also worth recording as a positive clarification: the 8.9MB reference
  database Phase 1.5/1.6 described as "bundled" is not actually present in
  the vendored source tree at all — it is a separate, optional, user-supplied
  asset, so this DEFER is about the ~48KB wrapper code's own license only,
  not a database-provenance question.

## Whether the original 3-app batch remains valid

**No — it must shrink to 2 apps for now.** `sd_info` and `docviewlite`
remain valid, cleared candidates for Phase 2C.2. `fcc_id_lookup` is not
part of the batch that may proceed until its license gap is resolved in a
dedicated follow-up pass. Per this phase's explicit instruction, no
substitute app is proposed to replace it — the batch simply becomes 2
apps rather than 3, exactly as instructed ("do not substitute new apps
automatically").

## Exact next allowed gate

- **For `sd_info` and `docviewlite`**: the next gate is **Phase 2C.2 —
  implementation/import of this exact 2-app cleared batch**
  (`sd_info` first, `docviewlite` second — the same conservative-first
  ordering `PHASE2C_INTEGRATION_PLAN.md` already established, with
  `fcc_id_lookup` simply removed from the sequence for now), following
  `docs/PHASE2C_INTEGRATION_PLAN.md`'s one-app-at-a-time,
  commit-per-app, validate-after-each discipline — and only on the project
  owner's own separate, explicit request to begin.
- **For `fcc_id_lookup`**: no import gate is open. The next allowed step
  for this specific app is a **dedicated follow-up license-confirmation
  pass** (fetch the real upstream `LICENSE`, confirm no relicensing
  occurred between the vendored revision and current `main`, then include
  the confirmed license text at import time) — not a re-run of this
  entire Phase 2C.1 verification, just this one specific, narrow gap.
  Until that happens, `fcc_id_lookup` stays out of any batch.

## Prompt canaries applied in this phase

- "If any app license cannot be proven, mark that app DEFER." — **Applied
  to `fcc_id_lookup`.**
- "If bundled data lacks clear redistribution rights, mark NEEDS REVIEW or
  DEFER." — Not triggered; the one app with a data-provenance question in
  planning (`fcc_id_lookup`'s database) turned out not to bundle that data
  at all in the artifact actually reviewed.
- "If any app includes copied commercial text/code/data without
  distribution rights, mark BLOCKED." — Not triggered for any of the 3.
- "If any app touches RF/Sub-GHz/NFC/RFID/iButton/BadUSB/BLE/GPIO/IR
  behavior, mark DEFER..." — Not triggered; all 3 confirmed clean against
  the full 18-keyword safety scan of real source.
- "If any app needs source changes outside its own app directory, mark
  NEEDS REVIEW." — Not triggered; all 3 are fully self-contained.
- "If any evidence is missing, write NEEDS REVIEW instead of guessing." —
  Applied in spirit to `fcc_id_lookup` (escalated to DEFER per the more
  specific license canary above, since evidence was not just incomplete
  but entirely absent from the artifact itself).
- "If the workflow tries to import code in this phase, stop immediately."
  — No import was attempted; this phase is verification only.
- "Never claim hardware-tested, release-ready, safe-to-flash, or
  bug-free." — Not claimed anywhere in this phase's output.

## Statement

**PHASE 2C.1 PRE-IMPORT VERIFICATION: NEEDS REVIEW (2 of 3 apps cleared,
1 deferred). NO CODE IMPORT PERFORMED.**

No files were added to `applications/` or `applications_user/`. No
firmware or app source was modified. No build was attempted. No hardware
was touched, no hardware-connected validation mode was run. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**, unchanged from the Phase 2B
baseline this work builds on. Phase 2C implementation/import has **not**
started — that requires the project owner's own separate, explicit
request, specifically scoped to the 2-app cleared batch
(`sd_info`, `docviewlite`).

# Phase 2G — Recommended Batch

Docs only. Planning only. No code is imported by this document.

## NO PHASE 2G IMPORT BATCH RECOMMENDED

Per `docs/PHASE2G_CANDIDATE_REVIEW.md`, the audited Top-25 candidate pool
(`docs/PHASE1_5_TOP_25_CANDIDATES.md`, individually source-audited in
`docs/PHASE1_6_TOP25_SOURCE_AUDIT.md`) is fully exhausted: 19 apps
imported across Phase 2A-2F, 6 apps hard-deferred for specific,
documented, unresolved reasons (`fcc_id_lookup`, `upython`, `iconedit`,
`c_book`, `animation_switcher`, `theme_manager`). No app from that pool
remains available for a new batch.

## Why continuing app imports right now would reduce quality/safety

- **Padding the batch with a hard-deferred app** would mean either
  importing an app with a real, unresolved license gap (`fcc_id_lookup`),
  a real unresolved copyright question (`c_book`), a real
  hardware/control capability this project has never accepted for a
  general-audience default (`upython`'s GPIO/IR access, `iconedit`'s HID
  keystroke injection), or a real shared-system-directory write class
  this project has deliberately kept out of every batch so far
  (`animation_switcher`/`theme_manager`). None of these concerns is
  resolved by simply deciding to import anyway — doing so would be
  exactly the "pad a batch with questionable apps just to continue
  importing" outcome this phase's own instructions forbid.
- **Reaching into the un-audited ~170-app pool** (the remainder of the
  original 195-app shortlist beyond the Top 25) would mean recommending
  an app based on README/`.fam`-metadata description alone — the exact
  depth of review that, for the Top 25 itself, already proved
  insufficient on its own for `upython` (hidden GPIO/IR capability),
  `iconedit` (hidden HID capability), `sd_info` (hidden SD-benchmark
  writes, found only in Phase 2C.1's real source read), and
  `hex_viewer`/`barcode_gen` (exact storage behavior only confirmed in
  Phase 2F.1's real source read). Recommending a new app on metadata
  alone, having already learned that lesson four separate times in this
  project's own history, would be a regression in rigor, not a
  continuation of it.
- **This phase's own scope** is limited to existing planning/audit
  documentation — it does not authorize fetching or reading new upstream
  source. A responsible recommendation from the un-audited pool would
  require exactly that kind of fresh, dedicated source-read pass, which
  is out of scope here by design.

## Recommended alternative work instead

In order of likely value:

1. **Phase 2F hardware-assisted validation on real hardware.**
   `tools/phase2f_hardware_gate.ps1` and
   `docs/PHASE2F_HARDWARE_SMOKE_TEST_CHECKLIST.md` are complete and ready
   to run the moment a Windows machine and a physical Flipper Zero are
   available — this is the single highest-value non-import action
   available, since it is the actual gate blocking any future
   release-readiness consideration for the entire accepted 19-app
   baseline, not just a hypothetical Phase 2G addition.
2. **A narrow `fcc_id_lookup` license-resolution phase.** A
   low-effort, well-scoped follow-up: obtain the confirmed upstream
   `LICENSE` (`github.com/lrehmann/fcc-id-lookup-flipper`) and confirm it
   applied to the specific historical revision RogueMaster vendored
   (per `docs/KNOWN_ISSUES.md` item 6) — this alone could clear one of
   the 6 hard-deferred apps for a future, genuinely small batch, without
   touching any of the other 5.
3. **A dedicated, fresh Phase 1-style bulk triage of the remaining
   ~170-app pool**, if the project owner wants app expansion to continue
   at all beyond the Top 25 — this is a distinct, larger undertaking
   (full per-app source reads, not a metadata skim) and would need to be
   explicitly commissioned as its own phase, not folded into a normal
   Phase 2G-scale batch-planning pass.
4. **Documentation consolidation / validator / CI tooling hardening** —
   lower-value maintenance work, available at any time, not gated on
   hardware or new source access.
5. **A release-readiness gap audit without a release claim** — a survey
   of exactly what remains before any real release-ready determination
   could be made (hardware validation completion being the largest single
   gap), without itself claiming release-ready.

**Phase 2G implementation/import is not recommended.**

# Phase 1 — Recommended Integration Plan (proposal only; no code changes made)

This is a recommendation for how Phase 2 (base architecture) and later integration
work should sequence, based on what Phase 1's real inspection found. Nothing in this
document has been executed. Per instruction, integration work stops here pending
explicit approval to proceed into actual code/tree changes.

## 1. What's already true (no work needed)

Unleashed, our built and verified base, already includes the three community-standard
core patches (`input_settings_app`, `find_my_flipper`, plus its own `clock_app` /
`subghz_remote` / `mfkey`). No import work is required for these — they exist and
already built cleanly in the confirmed local Windows build.

## 2. Recommended near-term sequencing (each step is its own gated pass, build after each)

1. **Individual review pass on the remaining ~650 RogueMaster external apps** that
   weren't safety-keyword-flagged. Fast per-app check: read `application.fam` +
   README, confirm license is compatible (GPLv3-compatible or permissive), confirm no
   embedded network calls/credentials/obfuscated code, confirm it matches its stated
   category. This is a real, if shallow, security-relevant pass — not a rubber stamp —
   and should itself produce a per-app decision log, not just a bulk "Tier 4, done."
2. **Resolve "needs review" items from the Risk Register** (`can_bus_attack`,
   `subghz_bruteforcer`, `badge_audit`, `access_audit`, `rolling_flaws`,
   `uid_brute_smarter`, `ulc_brute_optimized`, `combocracker`) with a full source read
   (not just the README) before any of them get even a Tier 5 (lab-only) flag. Each
   needs its own short decision note: confirmed safe framing / needs modification to
   be safe (e.g. add explicit ownership-confirmation prompts) / reject.
3. **Only after 1 and 2**: start actual integration, one small atomic group at a time
   (per the project's Phase 5 rule — one feature group per branch/patch, build after
   each, no mixing unrelated changes). Suggested order, safest-first:
   a. Tier 1/2 core patches (if any are independently designed, not copied from
      Momentum) — lowest risk, touches shared UI/settings code.
   b. Tier 3 apps with zero dual-use concern (pure games, calculators, viewers,
      passive scanners) — highest volume, lowest risk, good for validating the
      import pipeline itself before touching anything riskier.
   c. Tier 4 optional pack — same risk profile as 3b, just not default-enabled.
   d. Tier 5 lab-only items — only after 1 and 2 above are actually done, each
      individually, each behind an explicit expert-only build flag with on-screen
      warnings, never default-enabled.
   e. Tier 6 items are not integrated at any point.

## 3. Build discipline for the integration phase

- One feature/app (or small related group) per commit, with a rebuild after each,
  matching the discipline already established in Phase 0/4 (we now have a confirmed
  local Windows build baseline to diff against for every subsequent change).
- Any C-level changes must build cleanly under the **real, official pinned
  toolchain** (per `LOCAL_WINDOWS_BUILD_HANDOFF.md`) — the cloud sandbox's substitute
  toolchain must never again be used to validate or justify a source change; it's
  fine only for cloud-side sanity-checks that get re-verified locally before being
  trusted.
- Attribution: every imported app keeps its original author credit and license
  header untouched; `CREDITS.md`/`THIRD_PARTY_NOTICES.md` get an entry per import,
  not a bulk "RogueMaster apps" line.

## 4. What is explicitly NOT recommended

- Bulk-copying `applications/external/` wholesale from RogueMaster. Even setting the
  safety concerns aside, several of the excluded items above are exactly the kind of
  thing a wholesale copy would silently ship as default-available.
- Copying any code or design directly from Momentum, per its AI-contribution policy
  (Phase 0) — Momentum stays a read-only reference for feature ideas, re-implemented
  independently if wanted.
- Enabling any Tier 5 item by default under any circumstance, including "just for
  testing" — lab-only means an explicit build flag every time.

## 5. Stop point

This plan stops here. The next action requiring approval is starting step 1 above
(the remaining-650-apps review pass) or, if preferred, narrowing scope further (e.g.
"just review the ~30 highest-value games/tools by download popularity" instead of all
650) — happy to take direction on which before spending the time on either.

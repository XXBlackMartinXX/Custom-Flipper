# Ultimate vNext Roadmap

## What this phase actually delivered

This phase (`feature/ultimate-vnext-test-census-architecture`) was
scoped as infrastructure, audit, and architecture work — explicitly not
another firmware installation, and explicitly not permission to begin
broad application import. See this phase's final report for the exact
classification; this document is the forward-looking roadmap.

## Gate status (honest, per this phase's own mission structure)

| Gate | Requirement | Status |
|---|---|---|
| **A — Test platform proof** | Automated discovery works; 20-app inventory reconciles; ≥5 low-risk apps automatically launch/navigate/exit/produce evidence on real hardware; no flashing capability in the tester | **Partially met.** Discovery/evidence/schema logic real and unit-tested (20/20 pytest assertions passing); inventory reconciles exactly against the 20-app baseline; zero real hardware runs exist (no hardware in this session); no flashing capability confirmed by source-grep test. |
| **B — Current 20-app automated qualification** | All 20 classified; every `SAFE_AUTOMATION` app tested; fixture/manual apps separated; no unsupported blanket PASS | **Partially met.** All 20 classified (10 `SAFE_AUTOMATION`, 5 `FIXTURE_REQUIRED`, 5 `MANUAL_VISUAL_REQUIRED`); zero apps actually hardware-tested; fixture/manual apps clearly separated; zero blanket PASS claims anywhere. |
| **C — Ecosystem census** | Source pins complete; licenses complete; duplicate matrix complete; recommended import waves approved; no code imported yet | **Met**, at the scope this phase defined honestly: all 7 repositories real-pinned with commit hash + license hash; firmware-core license confirmed identical (GPL-3.0) across all of them; the 20-app cross-reference against all three community-app collections is complete and real; 34 individual candidates catalogued with real dispositions out of ~1,330 discovered (the remainder explicitly disclosed as not yet individually reviewed, not silently treated as approved); import waves proposed but **not approved** (that requires a human decision this document does not make on its own); zero code imported. |
| **D — Product architecture** | Six RFCs; resource budgets; modular profile design; accepted differentiation roadmap | **Partially met.** All six RFCs written (`docs/architecture/rfc-1` through `rfc-6`); modular profile design written (`MODULAR_FIRMWARE_PROFILES.md`); resource budget categories defined with 2 of 8 having any real number behind them (`RESOURCE_BUDGETS.md`); this roadmap is the differentiation roadmap, but "accepted" requires the project owner's sign-off, not a self-declaration by this phase. |

**No Gate above is claimed as fully, unconditionally passed.** The
common blocker across Gates A and B is identical and structural: **no
Windows machine and no physical Flipper Zero exist in this development
session.** Gates C and D's remaining gaps are scope/approval gaps, not
access gaps, and are more tractable without new infrastructure.

## What must happen before Gate E (first vNext import wave)

1. A human operator (or a session with real hardware access) must run
   `tools/hardware_app_tester` against a real, normally booted Flipper
   Zero at least once, and record real evidence — this is the single
   highest-leverage next action (see
   `docs/PRODUCT_DIFFERENTIATION_SCORECARD.md`'s closing
   recommendation).
2. At least 5 of the 10 `SAFE_AUTOMATION` apps must actually pass a
   real automated launch/navigate/exit cycle with real evidence, to
   satisfy Gate A's explicit requirement.
3. The project owner must review and explicitly approve (or amend)
   `docs/ecosystem/RECOMMENDED_IMPORT_WAVES.md` — this phase proposes
   sequencing, it does not self-approve it.
4. The project owner must review and accept (or amend) the six RFCs and
   the modular profile design — "accepted differentiation roadmap" is a
   human decision.
5. Only after 1-4 above, Gate E's own per-wave requirements apply
   (source review, license review, build, unit tests, automated
   hardware smoke, resource comparison, regression report), with no
   more than five logically related apps/features per wave.

## Recommended next wave, once Gate E opens (already scoped, not yet approved)

See `docs/ecosystem/RECOMMENDED_IMPORT_WAVES.md` for the full detail.
In summary: Wave 1 (`momentum/asset_packs_engine`, a genuinely
low-risk, high-differentiation cosmetic feature) is the strongest
immediate candidate once Gates A-D are actually closed out.

## What this roadmap explicitly does not authorize

This document does not authorize flashing, firmware installation, code
import, or a release claim. It is a plan, cross-referenced against real
evidence gathered in this phase, for what should happen next — subject
to the project owner's own review and explicit approval at each
decision point named above.

# Recommended Import Waves

**No code has been imported as a result of this document.** Per Gate C
(Ecosystem Census) and Gate E (First vNext Import Wave) in this phase's
own mission, import waves require Gates A–D to pass first (test
platform, current 20-app qualification, census, product architecture),
and each wave itself requires source review, license review, build,
unit tests, automated hardware smoke, resource comparison, and a
regression report — none of which has been performed for any candidate
below. This document only proposes a *sequencing*, grounded in the real
candidates this phase's census actually identified.

## Wave sequencing principle

Per this phase's mission: **no more than five logically related
apps/features per wave.** Waves are proposed in order of (a) lowest
risk/complexity first, (b) highest differentiation value, and (c)
fewest open review items.

## Proposed Wave 1 — Low-risk cosmetic/UX differentiation

| Candidate | Type | Disposition | Why this wave |
|---|---|---|---|
| `momentum/asset_packs_engine` | feature | `INCLUDE_AFTER_PORT` | Zero radio/security surface, high differentiation value, philosophically aligned with RFC 2 |

**Only one item recommended for this wave** — the census did not
identify four more equally low-risk, high-confidence cosmetic
candidates in this phase's curated sample. Expanding this wave requires
either a deeper census pass (more candidates reviewed) or accepting a
smaller first wave. Recommendation: do not pad the wave with a lower-
confidence candidate merely to reach five.

## Proposed Wave 2 — Hardware/module foundation

| Candidate | Type | Disposition | Why this wave |
|---|---|---|---|
| `official/expansion_protocol` | feature | `INCLUDE` | Already part of the shared firmware core (inherited via the Unleashed base) — this "wave" is really a formal acknowledgement + RFC 4 wiring, not a new source import |

This is deliberately a small, mostly-documentation "wave" — the real
work is RFC 4 (Hardware and Module Compatibility Hub) implementation,
which is out of scope for this phase.

## Deferred / needs further review before any wave assignment

| Candidate | Disposition | Why deferred |
|---|---|---|
| `official/js_app` | `EXPERIMENTAL` | Requires dedicated security review (arbitrary local scripting) before any wave |
| `official/dolphin_passport` | `DEFER` | Already inherited, not a new import; no action needed |
| `unleashed_plugins/flipper_i2ctools` | `NEEDS_REVIEW` | GPIO output review required; exact source path not yet individually confirmed |
| `unleashed_plugins/lightmeter` | `OPTIONAL_PACK` | License and exact source path need individual confirmation |
| `momentum/momentum_app_settings` | `NEEDS_REVIEW` | Large, invasive UX change; relevant prior art for RFC 3 but not a simple import |
| `momentum/disk_image_mounting` | `NEEDS_REVIEW` | Storage/USB-mode safety review required |
| `roguemaster/servotester` | `NEEDS_REVIEW` | GPIO output to unverified hardware; needs RFC 4 driver-entry discipline first |

## Rejected — never assigned to any wave

See `REJECTED_CANDIDATES.md` for the full list and reasoning
(`REJECT_DUPLICATE`, `REJECT_UNSAFE` individual and category-level
rejections).

## What this phase does NOT recommend

This phase does **not** recommend beginning any import wave yet. Gates
A, B, and D (test platform hardware proof, current 20-app automated
qualification, and product architecture acceptance) have real,
disclosed gaps — see this phase's final report and
`docs/ULTIMATE_VNEXT_ROADMAP.md`. Import waves are appropriately
sequenced *content* for a future phase, not an authorization to begin
importing now.

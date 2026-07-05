# Phase 1 — Curation Matrix

Tiers as defined for this project:

- **Tier 1** — safe core stability improvements
- **Tier 2** — polished UX/customization improvements
- **Tier 3** — stable, useful apps/plugins (default-optional)
- **Tier 4** — optional extra app pack (not default-enabled, but shipped)
- **Tier 5** — lab-only, disabled-by-default, expert-flag-gated
- **Tier 6** — excluded (unsafe/broken/duplicated/unlawful)

This matrix records **proposed** tiering only. Nothing here has been implemented —
no code has been changed, no app has been copied into this project's tree. This is
the curation decision layer that Phase 2/3 architecture work and eventual integration
would execute against, pending separate approval.

## Core patches (already present in our Unleashed base — no import needed)

| Feature | Source | Tier | Status |
|---|---|---|---|
| `clock_app` | Unleashed (already in base) | 2 | Already shipping |
| `subghz_remote` | Unleashed (already in base) | 3 | Already shipping |
| `input_settings_app` | Unleashed (already in base) | 2 | Already shipping |
| `find_my_flipper` | Unleashed (already in base) | 2 | Already shipping |
| `mfkey` | Unleashed (already in base) | 3 | Already shipping |

## UX/design patterns (Momentum reference only — not copied, per AI policy)

| Feature | Source | Tier (if independently implemented later) | Notes |
|---|---|---|---|
| Central settings hub (`momentum_app` pattern) | Momentum (design reference only) | 2 | Unleashed and RogueMaster already have their own equivalents (no `momentum_app`-style hub currently in Unleashed base — worth an independent, non-copied implementation later if desired) |
| `findmy` variant | Momentum (design reference only) | — | Functionally duplicated by Unleashed's own `find_my_flipper` already in base; no action needed |

## RogueMaster external app catalog — proposed tiering by category

Based on the category counts and individual inspections in
`PHASE1_FEATURE_INVENTORY.md` / `PHASE1_RISK_REGISTER.md`. **Category-level tiering
is a starting proposal, not a final per-app decision** — every app needs at least a
fast individual check (license, single-purpose sanity check, no bundled secrets)
before actually being copied in, per the recommended plan.

| Category | Proposed default tier | Rationale |
|---|---|---|
| Games (~35) | Tier 4 (optional pack) | Low risk, no safety/legal concern, but bulky — don't default-enable to keep the default menu clean |
| GPIO/sensors/hardware I/O (~29) | Tier 3/4 mixed | Read-only sensor tools → Tier 3; anything that writes/transmits to external hardware → Tier 4 with a hardware-risk warning, case-by-case |
| NFC/RFID/iButton (~32) | Tier 3/4/5 mixed | Passive read/analyze tools → Tier 3/4; audit/brute-force-style tools (see Risk Register) → Tier 5 |
| Sub-GHz/RF (~18) | Tier 3/4/5 mixed | Passive/own-remote replay → Tier 3/4; bruteforce/jammer-detect → Tier 5 per Risk Register; actual jammers → **Tier 6, excluded, not "lab-only"** |
| nRF24/ESP/Wi-Fi (~15) | Tier 3/4/5/6 mixed | Passive scanners → Tier 3; deauth tools → **Tier 6, excluded** |
| USB/HID (~10) | Needs review | BadUSB-adjacent tools need individual review for payload-delivery risk before any tiering; default posture is Tier 5 (lab-only) until reviewed, not Tier 3/4 |
| BLE (~9) | Tier 3/5/6 mixed | Passive scanners → Tier 3; `ble_spam` → **Tier 6, excluded**; `ble_killer` → **Tier 6, excluded as default, needs-review if ever proposed lab-only** |
| Crypto/wallet/password (~6) | Needs review | Anything handling credentials/keys needs individual security review before any tier assignment, even Tier 5 |
| CAN/automotive (~6) | Tier 5 (mostly) | Diagnostic tools (`can_commander`, `can_tools`, `can_transceiver`) → Tier 5; `can_bus_attack` → needs-review before any tier; `carjacker` → **Tier 6, excluded** |
| Everything else (~500+, clocks/viewers/calculators/misc) | Tier 4, presumptively | Lowest-risk bucket by nature of category, but still needs the fast individual pass described above before actual import — presumptive tiering only |

## Explicitly Tier 6 (excluded) from this pass's individual review

- `ble_spam` — nuisance/harassment BLE packet spam
- `ble_killer` — controls a specific commercial BLE lock product, no ownership check
- `carjacker` — unauthorized vehicle access, no stated lawful purpose
- `fz_nrf24_jammer`, `nrfjammer` — RF jammers
- `esp8266_deauth`/`deauther`, `wifi_deauther`/`wifi_deauther_v2` — Wi-Fi DoS tools

## Explicitly Tier 5 (lab-only, needs further review before even that) from this pass

- `can_bus_attack`, `subghz_bruteforcer`, `badge_audit`, `access_audit`,
  `rolling_flaws`, `uid_brute_smarter`, `ulc_brute_optimized`, `combocracker`

## Momentum-sourced Sub-GHz protocol breadth (reference only, not copied)

If equivalent Sub-GHz protocol decode support is independently sourced later (not
copied from Momentum), plain decode/replay-your-own-remote entries → Tier 3/4;
counter-manipulation/bypass-capable entries (as explicitly self-described in
Momentum's own changelog) → Tier 5 at most, likely Tier 6 depending on individual
review.

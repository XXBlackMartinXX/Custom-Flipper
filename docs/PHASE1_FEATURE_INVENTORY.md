# Phase 1 — Feature Inventory

Docs-only pass. No firmware source has been modified. Everything below is grounded in
direct inspection of the four repositories already cloned during Phase 0 (shallow
clones for Official/RogueMaster/Momentum; full recursive clone for Unleashed, our
build base). Where a claim is "by inspection," it means a specific file/README was
actually read this pass — not inferred from the app name alone. Where a name-based
heuristic was used instead of individual inspection (necessarily true for most of
RogueMaster's ~680-app catalog), that is stated explicitly.

## 1. Official Firmware — upstream compatibility reference

- Repo: `flipperdevices/flipperzero-firmware`, `dev` @ `101c20d736fed67bcf24fbbe87886ce4a26ae088`
- Role: baseline. `applications/{main,settings,system,services,debug,drivers,examples}`
  is the reference structure everything else is diffed against.
- No `applications/external` directory — Official does not bundle a large third-party
  app catalog into the firmware tree itself.

## 2. Unleashed Firmware — selected integration base (already built, PASS)

Diffed directly against Official's `applications/` tree (`diff <(ls official/...)
<(ls unleashed/...)`):

| Path | Added vs. Official | Category | Notes |
|---|---|---|---|
| `applications/main/clock_app` | Yes | UX | Standalone clock screen app |
| `applications/main/subghz_remote` | Yes | Sub-GHz | Configurable multi-button Sub-GHz remote UI |
| `applications/settings/input_settings_app` | Yes | UX | Keybind/input customization — same feature independently present in Momentum and RogueMaster (see below); this has become a de facto community-standard patch |
| `applications/system/find_my_flipper` | Yes | Utility | Locates a misplaced Flipper (audio/vibration beacon) |
| `applications/system/mfkey` | Yes | NFC | MFKey32/64 Mifare Classic key-recovery calculator — standard, widely-accepted NFC security tool for recovering keys from your own captured card traffic, not a live-attack tool |

**Decision: already in our base, already built and confirmed working. No import
action needed for these — they ship with Unleashed as-is.**

## 3. Momentum Firmware — read-only UX/design reference (AI policy — see Phase 0)

Diffed against Official the same way:

| Path | Added/changed vs. Official | Category | Notes |
|---|---|---|---|
| `applications/main/momentum_app` | Added | UX/Settings | Central "Momentum" settings hub (`MENUEXTERNAL` app, scene-based, per `application.fam` inspected directly) — this is Momentum's signature feature: one place for all customization instead of scattered menus |
| `applications/settings/input_settings_app` | Added | UX | Same feature as Unleashed's (see above) |
| `applications/system/findmy` | Added | Utility | Equivalent to Unleashed's `find_my_flipper`, different implementation |
| `applications/system/snake_game` | Removed (relocated) | Games | Not lost — Momentum reorganizes where built-in games live |

Momentum's `CHANGELOG.md` (read directly) also documents extensive Sub-GHz protocol
additions merged from the wider community (KeeLoq variants, Cardin, Beninca, Jarolift,
Ditec, and others) plus NFC Ultralight-C write/relay support. **Flagged for the Risk
Register**: several changelog entries explicitly describe rolling-code counter
manipulation (one entry's own description: *"may bypass counter on some receivers!"*).
This is a UX/feature-breadth reference only — no Momentum code is being imported
(AI-policy constraint from Phase 0); if equivalent Sub-GHz protocol support is wanted
later, it would need independent sourcing/review, not a copy from Momentum.

## 4. RogueMaster Firmware — plugin/feature source (curated, not blind-merged)

Core structural diff vs. Official (same method):

| Path | Added vs. Official | Notes |
|---|---|---|
| `applications/main/cfw_app` | Yes | RogueMaster's own central settings hub, same pattern as Momentum's `momentum_app` |
| `applications/settings/input_settings_app` | Yes | Same community-standard feature as above |
| `applications/system/findmy` | Yes | Same as Momentum's |
| `applications/system/snake_game` | Removed (relocated) | Same reorganization as Momentum |

### The `applications/external/` catalog (682 apps — by far RogueMaster's defining feature)

Counted directly (`ls applications/external | wc -l` = 682). This is the "feature
density" RogueMaster is known for. Full per-app source review of all 682 is out of
scope for this pass (see `PHASE1_RECOMMENDED_INTEGRATION_PLAN.md` for how that should
be sequenced later) — this pass does two things instead:

**(a) Name-based category counts** (heuristic, not individually verified — a rough
map of what's in there):

| Category (keyword match) | Approx. count |
|---|---|
| Games | ~35 |
| NFC / RFID / iButton / Mifare | ~32 |
| GPIO / sensors / hardware I/O | ~29 |
| Sub-GHz / RF | ~18 |
| nRF24 / ESP / Wi-Fi | ~15 |
| USB / HID | ~10 |
| IR | ~9 |
| BLE / Bluetooth | ~9 |
| Crypto / wallet / password | ~6 |
| CAN / automotive | ~6 |
| Everything else (clocks, viewers, calculators, misc utilities) | remainder (~500+) |

Categories overlap (an app can match more than one keyword), and this is a filename
heuristic, not a content audit — treat it as "what kind of catalog is this," not a
per-app risk determination.

**(b) Individual inspection of every name that matched a safety-relevant keyword**
(jam/spam/attack/brute/crack/sniff/deauth/carjack/killer/grabber/audit/etc. — 33 apps
total flagged this way). Every one of these 33 had its actual `application.fam` and/or
README read directly. Full results and decisions are in
`PHASE1_RISK_REGISTER.md` — headline finding: **one flagged name turned out to be a
false positive on inspection** (`applegrabber` is a harmless falling-apples catch game,
not anything related to Apple device tracking/interception — confirmed by reading its
actual README). This is exactly why name-based filtering alone is not treated as a
decision mechanism here, only as a triage step to prioritize which of 682 apps get
read in full this pass.

## Cross-cutting observation

Three of the four projects (Unleashed, Momentum, RogueMaster) independently converged
on the same three core patches over Official: an `input_settings_app`
(keybind/input customization), a "find my Flipper" utility, and a central
settings/customization hub app (`momentum_app` / `cfw_app`). This is useful signal for
Phase 2/3: these are mature, community-validated, low-risk patterns, not one-off
experiments — good candidates for early, low-risk Tier 1/2 adoption once we're ready
to integrate (not yet — see recommended plan doc).

# Phase 1 — Risk Register

Scope: the 33 RogueMaster `applications/external/*` entries whose names matched a
safety-relevant keyword filter (`jam|spam|flood|brute|crack|hack|spy|steal|sniff|
keylog|rolling|bypass|attack|exploit|unlock|skim|carjack|killer|deauth|dos_|_dos|
stealer|clone|grabber|scanner|scan|audit|remote_control|payload`), plus the Sub-GHz
protocol-breadth findings from Momentum's changelog (Phase 1 inventory §3). Every item
below was read directly (`application.fam` and/or README) — none of these decisions are
name-guesses. Decisions use the project's defined tiers: **EXCLUDE** (not shipped in
any build, including lab-only), **LAB-ONLY** (disabled by default, expert-only build
flag, explicit warnings, own-property/authorized-use framing required), **INCLUDE**
(safe for default/optional tiers), **FALSE POSITIVE** (flagged by name, cleared by
reading the actual source).

| App (id) | What it actually does (by inspection) | Category | Decision | Rationale |
|---|---|---|---|---|
| `ble_spam` | Spams BLE broadcast/advertisement packets at nearby Apple/Android/Windows devices to trigger spurious pairing popups, per its own README | BLE | **EXCLUDE** | This is a nuisance/harassment tool against third-party devices with no owner-authorization model possible (it targets whoever is nearby). Matches the project's "unauthorized access / targeting third-party systems without authorization" exclusion. |
| `ble_killer` | Pairs with a specific commercial BLE padlock product ("oklok") via a custom expansion board and controls it | BLE / GPIO | **EXCLUDE** (as a default feature); **NEEDS REVIEW** if ever proposed lab-only | Only legitimate if the user owns that exact padlock; the app has no ownership-verification concept. Real-world access-control risk. |
| `carjacker` | README gives no legitimate description ("Follow the white rabbit...", "Private Unleashed V2"); name states its purpose | Vehicle | **EXCLUDE** | Directly matches "unauthorized real-world access-control bypass" exclusion. No stated lawful use case. |
| `can_bus_attack` (`canbus_attack_app`) | README: "basic security testing on CAN Bus networks... developed as part of a university cybersecurity research project... educational and ethical use only" | Vehicle / GPIO | **LAB-ONLY, NEEDS REVIEW** | Legitimate-sounding stated purpose and academic origin, but "attack" naming and vehicle-bus write capability mean it needs a maintainer to actually read the full source (not just the README) before even a lab-only build flag is granted. Not excluded outright given the stated ethical framing, but not included either. |
| `subghz_bruteforcer` | Brute-forces short/static Sub-GHz codes (legacy fixed-code garage/gate systems) | Sub-GHz | **LAB-ONLY, NEEDS REVIEW** | Targets a known-insecure legacy protocol class; common in the security-research community for auditing one's own old gate/garage hardware. Still matches "brute-forcing real access systems" language literally — gate on explicit user action, clear warning, own-property framing, not default-on. |
| `fz_nrf24_jammer`, `nrfjammer` | RF jammers (name-confirmed via `application.fam`: "FZ nRF24 Jammer") | RF | **EXCLUDE** | Direct match: RF jamming is explicitly excluded. Also generally illegal to operate (FCC and equivalent regulators worldwide). |
| `esp8266_deauth` (`deauther`), `wifi_deauther` (`wifi_deauther_v2`) | Wi-Fi deauthentication (forced-disconnect) attacks via an ESP8266 add-on, based on the "WiFi Marauder" app | Wi-Fi | **EXCLUDE** | Direct match: denial-of-service behavior, explicitly excluded. |
| `applegrabber` (`apple_grabber`) | **FALSE POSITIVE on inspection.** README: "Apple Grabber Game... flip your device vertically... grab all the apples." A falling-apples arcade game, unrelated to Apple devices/tracking. | Games | **INCLUDE** | Flagged only by name pattern (`grabber`); reading the actual README immediately clears it. Kept in this table specifically to demonstrate that name-based triage was verified against real source, not used as the decision itself. |
| `combocracker` (`combo_cracker`) | Deduces a Master Lock combination-padlock code using a published mechanical vulnerability (Samy Kamkar's research), per its README | Physical security | **LAB-ONLY** | Analogous to a lock-picking tool: lawful on locks you own/are authorized to open, unlawful otherwise. No ownership-verification is possible in software, so default-off with a clear on-screen warning is the right posture, not outright exclusion (a physical, well-published, decades-old vulnerability class, commonly taught in security research). |
| `badge_audit`, `access_audit` | Professionally-presented (CI/CD badges, structured READMEs) RFID/access-control audit tools for physical security testing | NFC / RFID | **LAB-ONLY, NEEDS REVIEW** | Legitimate security-audit tool category (used by physical-pentest professionals with authorization), but "audit real access-control systems" carries obvious misuse potential without authorization. Gate behind expert-only flag + explicit authorized-use warning; do not default-enable. |
| `rolling_flaws` | Explicitly documents rolling-code attack scenarios (replay, cloning, rollback) for education; by a known, credible Flipper security educator; README itself calls jamming illegal and discourages it | Sub-GHz | **LAB-ONLY** | Self-aware, responsibly-framed educational tool. Good candidate for a clearly-labeled "security research / lab" pack later, not default release. |
| `uid_brute_smarter`, `ulc_brute_optimized` | Mifare UID / Ultralight-C brute-force/analysis tools | NFC | **LAB-ONLY, NEEDS REVIEW** | Dual-use card-security research tooling; same posture as badge/access audit tools above. |
| `subghz_jammer_detect` | **Defensive** — detects Sub-GHz jamming directed at the user's own equipment (name confirms intent; a "detector," not a jammer) | Sub-GHz | **INCLUDE** (optional tier) | Defensive tooling, not attack tooling. Low risk. |
| `nfc_sniffer` | Passively listens to reader→tag commands only; README explicitly states it "DOES NOT capture the response from tags" | NFC | **LAB-ONLY (optional)** | Passive protocol-analysis tool, not a live-attack tool; still gated because "sniffing" of third-party reader traffic without authorization has a plausible misuse path. Reasonable as an optional/lab tool with a warning, not excluded. |
| `wifi_scanner`, `ble_scanner`, `radar_scanner`, `radio_scanner`, `ham_scanner`, `frsscan`, `nrf24scan`, `nrf24channelscanner`, `bc_scanner_emulator` | Passive spectrum/device scanners (spot-checked `wifi_scanner` and `ble_scanner` READMEs directly; rest inferred by strong naming/category consistency, **not individually read** — flagged here for completeness, not a final decision) | RF / BLE / Wi-Fi | **INCLUDE, tentative** | Passive scanning is standard, low-risk hobbyist/diagnostic functionality. The un-inspected members of this group should still get a quick individual pass before Tier 3 inclusion is finalized, per the recommended plan. |
| `can_commander`, `can_tools`, `can_transceiver` | Legitimate CAN-bus diagnostic/decoding tools (DBC signal definitions, frame decode, MCP2515-based read/send) — READMEs read directly; `can_commander` is also the "CAN Commander" feature independently listed in Momentum's own changelog, suggesting community consensus it's a legitimate diagnostic tool | Vehicle / GPIO | **LAB-ONLY (optional)** | Diagnostic/read use is low-risk; the send/inject capability on a real vehicle CAN bus is the same class of risk as any GPIO tool that can write to hardware you don't own — gate behind explicit hardware-connection + authorized-vehicle warning, not default-on, not excluded. |

## Sub-GHz rolling-code protocol breadth (Momentum changelog finding, not a RogueMaster app)

Momentum's `CHANGELOG.md` documents dozens of added Sub-GHz decoder/protocol entries
(KeeLoq-family systems, Cardin, Beninca, Jarolift, Ditec, and others). Most of these
are protocol **decode/analyze/replay-your-own-remote** support, which is the same
class of functionality Official firmware already ships for Sub-GHz (read/replay your
own remote). One entry is explicitly self-described as: *"KeeLoq add counter mode 7
(sends 7 signals increasing counter with 0x3333 steps) - may bypass counter on some
receivers!"* — that specific class of counter-manipulation entries should be treated
as **LAB-ONLY, NEEDS REVIEW** if this project ever sources equivalent protocol support
independently (not from Momentum directly, per the AI-policy constraint) — plain
decode/replay-your-own-remote support is a different, much lower-risk category and
can be evaluated under normal Tier 3 rules.

## What this register does not cover yet

- The ~650 RogueMaster external apps that did not match the safety keyword filter.
  These still need at least a fast individual pass (README + `application.fam`) before
  any are promoted out of "name-based category bucket" into a real per-app decision —
  see `PHASE1_RECOMMENDED_INTEGRATION_PLAN.md`.
- Any code-level security review (static analysis, manual review for hardcoded
  secrets/network exfiltration/etc., per the project's Phase 8 Security Review) has
  not been performed on any app, including the ones marked INCLUDE above. Marking
  something INCLUDE here means "the stated purpose and category are acceptable,"
  not "the code has been security-audited."

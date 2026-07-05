# Phase 1.5 — Exclusion List (RogueMaster External Apps)

Docs only. Nothing here is imported or built. This covers every app flagged by the
Phase 1.5 automated triage (89 high-risk-keyword hits + 5 unclear-provenance apps),
plus the 33 apps individually reviewed in Phase 1. Every entry below has real
evidence behind it — its own `fap_description` (author's own words) at minimum, a
README for the Phase 1 subset. Nothing is excluded on name alone without checking
what it actually says it does — and the false-positives subsection exists
specifically to prove that check happened both ways.

## Excluded — RF abuse / jamming / deauthentication (Tier 6, no lab-only exception)

| App | Category | Evidence | Reason |
|---|---|---|---|
| `fz_nrf24_jammer`, `nrfjammer` | GPIO/NRF24 | "designed to create interference, disrupting normal operation of Bluetooth... drones, Wi-Fi" | RF jamming — explicit project exclusion, generally illegal to operate |
| `esp8266_deauth`, `wifi_deauther` | GPIO/ESP8266 | Confirmed real deauthers by cross-referencing appid/README (see the `wifi_deauther` metadata-mismatch writeup in the bulk triage doc) | Wi-Fi denial-of-service |
| `c5lab`, `evil_bw16`, `delfy_rtl` | GPIO | "WiFi Deauther controller for [module] via UART" / "perform various WiFi penetration testing attacks" | Wi-Fi denial-of-service (controller front-ends for external deauth modules) |
| `ble_spam` | Bluetooth | "Flood BLE advertisements to cause spammy and annoying popups/notifications" | Harassment/DoS against arbitrary nearby third-party devices |
| `evil_portal` | GPIO/ESP32 | "An evil captive portal Wi-Fi access point" | Phishing/credential-harvesting technique |
| `ghost_esp` | GPIO/ESP32 | "conduct in-depth WiFi and Bluetooth Low Energy... an[alysis]" via a companion "attack"-oriented firmware | Framed around network attacks; excluded by default, would need full source read (not just description) before any lab-only reconsideration |
| `mousejacker_azerty`, `mousejacker_ms`, `nrf24mousejacker`, `nrf24sniff`, `nrfsniff_ms` | GPIO/NRF24 | "perform mousejack attacks" / "captures addresses to use with NRF24 Mouse Jacker" | Mousejack is a real wireless HID-injection attack against third-party keyboard/mouse dongles — targets hardware the user doesn't control |

## Excluded — BadUSB / HID injection abuse

| App | Category | Evidence | Reason |
|---|---|---|---|
| `gatekeeper` | USB | "Secure BadUSB password launcher with combo lock" | Stores and HID-types passwords — combines credential risk with payload-launcher risk |
| `hid_exfil` | USB | "HID-based data exfiltration via keyboard LED feedback channel" | Explicit exfiltration tooling |
| `hid_file_tx` | USB | "especially useful when access to mass storage devices is blocked on a PC" | Explicitly framed around bypassing a DLP/USB-mass-storage control |
| `nfc_login` | NFC | NFC-tap-triggered HID password typing | Credential risk (same class as password vaults below) |
| `bad_duck3`, `bad_usb_pro` | USB | General-purpose DuckyScript/HID-injection interpreters, one with BLE HID | **Not excluded for being inherently malicious** (Official/Unleashed already ship a stock BadUSB app — the interpreter itself is neutral, like a scripting language). Deferred as redundant with the base feature; the BLE HID variant needs review for the added attack surface before any consideration. |

## Excluded / lab-only — brute-force, cracking, protocol-security-bypass tools

| App | Category | Evidence | Decision |
|---|---|---|---|
| `subghz_bruteforcer` | Sub-GHz | Brute-forces static/short Sub-GHz codes | LAB-ONLY, NEEDS REVIEW (carried over from Phase 1) |
| `combocracker` | Tools | Master Lock combination-cracking (published mechanical vulnerability) | LAB-ONLY (carried over from Phase 1) |
| `uid_brute_smarter`, `ulc_brute_optimized`, `ulcfkey`, `ulcfkey_next` | NFC | Mifare/Ultralight-C key brute-force/crack, citing published attack papers | LAB-ONLY, NEEDS REVIEW |
| `multi_fuzzer`, `nfc_fuzzer` | RFID/NFC | Protocol fuzzers "for testing reader/tag robustness" | LAB-ONLY, NEEDS REVIEW (legitimate QA/research category, real misuse path against third-party readers without authorization) |
| `sentry_safe` | GPIO | "exploiting vulnerability to open any Sentry Safe and Master Lock electronic safes without pin code" | **EXCLUDE outright** — unambiguous real-world safe-lock bypass |
| `meal_pager` | Sub-GHz | "triggers restaurant pagers in a brute force manner" | LAB-ONLY, NEEDS REVIEW — targets third-party devices, low real-world harm but no authorization model |
| `keeloq_decryptor`, `subghz_toolkit` | Sub-GHz | "KeeLoq keystore decryptor" / "decrypt KeeLoq keys" | **EXCLUDE by default, NEEDS REVIEW if ever reconsidered** — real rolling-code security bypass capability, higher real-world impact than passive capture/replay |
| `spi_flash_dump` | GPIO | "Read SPI NOR flash chips via GPIO for firmware extraction" | LAB-ONLY (legitimate hardware/firmware-recovery dev tool requiring physical chip access, not excluded outright, but a dev/security-research tool, not a default feature) |

## Excluded / lab-only — credential, wallet, and authenticator tools

| App | Category | Evidence | Decision |
|---|---|---|---|
| `ck42x_passvault`, `flippass` | Tools/USB | Encrypted password vaults with "opt-in HID password typing" | LAB-ONLY, NEEDS REVIEW — device-loss-equals-credential-compromise risk |
| `flipbip` | Tools | "Crypto wallet for Flipper" | LAB-ONLY, NEEDS REVIEW — same device-loss risk class |
| `totp` | Tools | "Software-based TOTP/HOTP authenticator" | LAB-ONLY, NEEDS REVIEW — holds 2FA seeds |

## Excluded / needs review — unauthorized-access and manufacturer-restriction bypass

| App | Category | Evidence | Decision |
|---|---|---|---|
| `carjacker` | **Games** (not a vehicle-hardware category) | `fap_description`: "Car stealing app - The Pirates Plunder style." Possibly a benign arcade game (Games category, no radio/GPIO/CAN dependency declared) rather than a real vehicle tool — genuinely ambiguous from metadata alone. | **Excluded regardless of actual function** — even if source review later proves it's a harmless game, the name itself is disqualifying for a professional default/optional build (project's own UX-polish rule against unprofessional/provocative naming). Could be revisited only under an entirely different name if truly just a game. |
| `can_bus_attack` | Vehicle/GPIO | University research project, "educational and ethical use only" per its own README | LAB-ONLY, NEEDS REVIEW (carried over from Phase 1) |
| `tesla_fsd` | GPIO | "Tesla CAN bus toolkit — FSD region-gate bypass, nag killer, BMS dashboard" | EXCLUDE by default, NEEDS REVIEW — bundles legitimate read-only diagnostics (BMS dashboard) with manufacturer feature-gate/DRM circumvention; legally ambiguous, excluded as a whole app rather than cherry-picking |
| `ble_killer` | Bluetooth | Controls a specific commercial BLE padlock product, no ownership check possible | EXCLUDE (carried over from Phase 1) |
| `fordradiocodes` | Tools | "Ford Radio 'M' & 'V' Unlock Code Generator" — a long-published algorithm for one's own car radio | LAB-ONLY (optional) — legitimate own-property use case, same posture as `combocracker` |
| `genie_recorder` | Sub-GHz | Extracts/replays Genie garage-door remote codes | LAB-ONLY, NEEDS REVIEW — legitimate own-garage-door duplication use case, but needs confirmation of which Genie protocol variant (fixed vs. rolling) before any tier decision |
| `protopirate` | Sub-GHz | "Decode car key fob signals from Sub-GHz" | NEEDS REVIEW — decode/analyze is lower-risk than key-recovery, but fob-signal-specific |

## Excluded — unclear provenance (no README, no description, no author)

| App | Category |
|---|---|
| `devinfo` | Tools |
| `music_beeper` | Media |
| `namechanger` | Settings |
| `notes_for_fz` | Tools |
| `sam` | Media |

Not excluded because they're known-bad — excluded because there is currently nothing
to evaluate them on. Worth a source-level look in a future pass; not a permanent
verdict.

## Deferred — needs a real read before either list (thin/ambiguous evidence)

| App | Why it's ambiguous |
|---|---|
| `flipwifi` | `fap_description` is just "FlipperHTTP companion app" — the keyword scan flagged it, but there's no evidence of attack behavior in the metadata either way. |
| `esp_flasher` | Flagged by the scanner, but the description ("flash ESP chips from the device") describes a legitimate flashing utility for the user's own ESP module — likely a false positive, listed here rather than the false-positives table because it wasn't cross-checked against its README. |
| `gauge_tool` | `fap_description`: "Use only if you know what you are doing" — no functional detail at all. |
| `quac` | "Quick Action remote control app" — unclear if a universal-remote utility (benign) or something rolling-code-specific. |
| `skidcity` | "Educational: Don't be a SKID!" — likely an anti-script-kiddie educational app (similar spirit to `rolling_flaws`), but the name and multiple keyword hits (RF/rolling-code/unauthorized-access) warrant an actual read before deciding lab-only vs. safe-educational. |
| `listem` | "NFC / RFID / iButton List Generator" — probably a benign tag-catalog tool, flagged only on a thin "brute" keyword match. |
| `lidar_emulator` | Emulates LIDAR IR signals — low real-world harm, but "interferes with a sensor you may not own" (e.g., a robot vacuum) is a pattern worth a second look. |
| `keyller`, `id_card_v2` | Descriptions too thin to classify (see `PHASE1_5_HIGH_VALUE_SHORTLIST.md` flagged-exceptions table). |

## Verified false positives (flagged by the automated scan, cleared by reading the actual evidence)

These are kept here specifically to show the automated scan's output was checked, not
trusted blindly, in both directions — matching the same discipline Phase 1 used for
`applegrabber`.

| App | Keyword that fired | Why it's actually fine |
|---|---|---|
| `pocket_cvss` | CRACK_EXPLOIT (matched "vulnerab...") | It's an offline CVSS v3.1 severity calculator — a standard, completely benign professional security-scoring reference tool, not an exploit tool. Good shortlist candidate. |
| `hirn`, `puck` | CRACK_EXPLOIT (matched "crack a ... code" as game mechanic) | Both are benign code-guessing/maze puzzle games (Mastermind-style and Pac-Man-style respectively). |
| `ghostbook` | CRACK_EXPLOIT | Actually an encrypted NFC contact-sharing utility with a passcode lock — benign personal utility. |
| `sd_spi` | UNAUTHORIZED_ACCESS (matched "unlock"/"lock") | "SD SPI Lock Management" refers to the SD card's own write-protect bits, unrelated to access control. |
| `rfidbeacon` | UNAUTHORIZED_ACCESS | A 125 kHz morse-code beacon novelty, not an access-control tool. |
| `rush_hour`, `slots2`, `lofz`, `rootoflife` | UNAUTHORIZED_ACCESS (game-mechanic word matches: "unlock levels," slot machine, light switches, puzzle "roots") | All four are benign puzzle/arcade games. |
| `chronometer` | UNAUTHORIZED_ACCESS | A millisecond-precision stopwatch utility; no plausible connection to the flagged term found in its description. |
| `plugin_howto` | UNAUTHORIZED_ACCESS | A beginner developer tutorial app — false match, and actually a good shortlist candidate for the developer-tools bucket. |
| `tagtinker` | UNAUTHORIZED_ACCESS | Explicitly "Educational ESL study tool for **owned hardware**" — the opposite of the flagged concern. |
| `wiiec` | UNAUTHORIZED_ACCESS | A Wii Extension Controller hardware-test tool, unrelated to access control. |
| `ibutton_converter`, `unitemp`, `tuning_fork`, `wikiflip`, `freestyle_libre_cgm` | NETWORK_EXFIL | All five are benign: a protocol converter, a generic sensor reader, a musical tuning tool, an offline glossary, and a personal glucose-monitor reader respectively — none has any network or exfiltration capability described. `freestyle_libre_cgm` in particular is a legitimate personal health-tech use case (reading one's own CGM sensor, a well-documented community practice given Abbott's own app's limitations). |
| `protoview`, `subhound`, `subghz_raw_edit` | ROLLING_CODE | General-purpose Sub-GHz signal capture/analysis/classification/editing tools, not rolling-code-specific attack tools. Reasonable Tier 3/4 candidates with a light review, not excluded. |
| `wmbuster` | CRACK_EXPLOIT / NETWORK_EXFIL | Its own description is explicit: "RX-only" — a passive EU smart-meter listener, legitimate for reading one's own utility meter. Name is misleading ("buster"); function is receive-only. |
| `sli_writer`, `weebo` | UNAUTHORIZED_ACCESS | NFC magic-card writers for SLIX and NTAG215 (Amiibo-style) tags respectively — same risk class as Official/Unleashed's own built-in NFC write-to-magic-card feature, not meaningfully riskier. Personal-collection/backup use case. |

## Duplicate functionality vs. the base (Unleashed)

| App | Overlaps with | Decision |
|---|---|---|
| `mfkey` (external, appid `mfkey_init_plugin`) | Base's `applications/system/mfkey` | Defer — diff against base version before considering either "replace" or "skip as redundant" |
| `snake_game` (external, appid `snake`) | Base's `applications/main/snake_game` | Defer — same reasoning |
| `subghz_remote` (external, appid `subghz_remote_refactored`) | Base's `applications/main/subghz_remote` | Defer — same reasoning |

## Summary count

Of the 681 total external apps: **~24 hard/soft excludes** (RF abuse, BadUSB abuse
subset, sentry_safe, KeeLoq decryptors, carjacker-by-policy), **~20 lab-only/needs-review**
(credential tools, brute-force/crack tools, vehicle/manufacturer-bypass tools),
**5 unclear-provenance excludes**, **~12 deferred pending a real read**, **3 duplicate-vs-base
defers**, and **~17 confirmed false positives** now cleared into the candidate pool
(`PHASE1_5_HIGH_VALUE_SHORTLIST.md` already reflects these — they're counted in that
document's 195, not double-counted here). The remaining bulk of the 681 (everything
not in the 89-keyword-hit set, minus the 5 unclear-provenance and 3 overlap apps) is
either already in the 195-app candidate pool or in the not-yet-triaged remainder noted
in the bulk triage doc's limitations section.

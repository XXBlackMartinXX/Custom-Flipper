# Rejected Candidates

This document explains the rejections already recorded in
`APP_CENSUS.json`/`FEATURE_CENSUS.json`, plus category-level rejections
that apply to large swaths of upstream apps this phase did not
individually catalogue one-by-one (see `SOURCE_PROVENANCE.md` for why
exhaustive per-app cataloguing of 1,330 upstream apps was out of scope
for this foundation phase).

## Individually rejected candidates

| Candidate | Repository | Disposition | Reason |
|---|---|---|---|
| `momentum_apps/quadrastic` | Momentum-Apps | `REJECT_DUPLICATE` | Functional overlap with our own `quadratic_solver` |
| `roguemaster/game2048_original` | RogueMaster | `REJECT_DUPLICATE` | Our own `2048` (`2048_improved`) already supersedes it |
| `roguemaster/minesweeper_og` | RogueMaster | `REJECT_DUPLICATE` | Our own `minesweeper_redux` already supersedes it |
| `unleashed/subghz_remote` | Unleashed | `REJECT_UNSAFE` | Sub-GHz transmission app - matches this project's forbidden-test list |
| `momentum_apps/metroflip` | Momentum-Apps | `REJECT_UNSAFE` | NFC interaction with third-party transit/access systems |
| `roguemaster/mousejacker_family` | RogueMaster | `REJECT_UNSAFE` | Wireless HID-injection-adjacent attack tooling |
| `roguemaster/wifi_marauder_companion` | RogueMaster | `REJECT_UNSAFE` | Companion app for external deauth/jamming-capable hardware |
| `unleashed/mifare_plus_sl3` (feature) | Unleashed | `REJECT_UNSAFE` | NFC card emulation/attack feature |
| `unleashed/dangerous_settings` (feature) | Unleashed | `REJECT_UNSAFE` | Unlocks out-of-band Sub-GHz transmission |
| `momentum/extended_subghz_subdriving` (feature) | Momentum | `REJECT_UNSAFE` | Sub-GHz transmission/capture extension |

## Category-level rejection: RogueMaster's radio/security-testing app family

This phase's RogueMaster census agent identified, by directory name
alone (not individually opened/read), a substantial family of apps that
match this project's forbidden-automation and forbidden-import scope on
their face:

`ble_killer`, `ble_spam`, `evil_ble`, `evil_bw16`, `evil_portal`,
`esp8266_deauth`, `wifi_deauther`, `wifi_marauder_companion`,
`mayhem_marauder`, `mousejacker_azerty`, `mousejacker_ms`,
`nrf24mousejacker`, `nrfjammer`, `fz_nrf24_jammer`, `nrfsniff_ms`,
`nrf24sniff`, `nfc_sniffer`, `uart_sniff`, `subghz_bruteforcer`,
`subghz_jammer_detect`, `rogue_ap_detector`, `carjacker`,
`combocracker`, `fliprogue`, `flipwifi`.

**Category-level disposition: `REJECT_UNSAFE`, blanket, for the entire
family above.** These names directly match this project's explicit
forbidden-operations list (jamming, deauthentication, HID injection,
brute force, sniffing/interception, "carjacker"-branded tooling) closely
enough that individual per-app source review would not change the
outcome — the category itself is out of scope for a project whose
mission is a safer, better-tested custom firmware, not a security-
testing/attack-tooling distribution. This is a scope decision, not a
judgment about whether these apps are well-written.

## Category-level caution: binary blobs in RogueMaster

The RogueMaster census found 210 files matching `*.bin`/`*.so`/`*.elf`
under `applications/external/` — mostly game asset data
(e.g. `golf/package/lib/fxdata*.bin`, `wolfenduino/game/Generated/Data_*.bin`)
plus a small number of prebuilt debug `.elf` binaries. **No individual
candidate from this repository is given an `INCLUDE`/`INCLUDE_AFTER_PORT`
disposition in this phase's census without a specific, individual note
confirming its own assets/binaries were checked** — this phase's rule
against "unexplained binary blobs" applies at the per-candidate level,
not as a blanket rejection of the whole repository (many of its 688
apps likely contain no blobs at all), but it does mean no blanket
"import from RogueMaster" recommendation should ever be made without
per-app blob review.

## Apps not individually catalogued (disclosed scope limit, not a rejection)

The bulk of the 1,330 apps found across the four upstream sources
(1,330 minus the ~34 individually catalogued in `APP_CENSUS.json`) were
**not individually reviewed** in this phase. This is an honest scope
limit, not a rejection — an uncatalogued app has no disposition at all
yet, and must not be imported on the basis of "it wasn't rejected." Only
candidates explicitly listed in `APP_CENSUS.json` have a disposition;
everything else is simply not yet assessed.

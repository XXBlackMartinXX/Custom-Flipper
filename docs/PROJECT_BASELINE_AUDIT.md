# Project Baseline Audit — Full Non-Hardware Consolidation

Docs-only consolidation and QA audit performed after the 20-app baseline
(Phase 2A through Phase 2F, plus the dedicated `fcc_id_lookup` one-app
import and its own baseline finalization). This document is the
top-level summary; the companion audit documents listed at the bottom
provide full per-topic detail. No app was imported, no source was
modified, and no hardware was touched to produce this audit — it is a
read-only synthesis of already-accepted, already-CI-validated work.

## Overall project status

**NON-HARDWARE CI BASELINE ACCEPTED.** All 20 custom apps are imported,
statically safety-scanned, and CI-build-validated on real GitHub-hosted
Windows runners across 7 accepted milestones (Phase 2A–2F plus
`fcc_id_lookup`). No hardware flashing or on-device testing has been
performed at any point in the project's history. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**.

## Current accepted branch

`integration/fcc-id-lookup-one-app-import` (documentation mirrored to
`claude/flipper-custom-firmware-cxrcer`, the repository's default
branch).

## Final accepted baseline

| Field | Value |
|---|---|
| Accepted commit | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` (`8626572`) |
| Accepted CI run | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) |
| Finalization run | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) |
| Static validation | `PASS_WITH_REVIEWED_FALSE_POSITIVES` (475 total reviewed matches, zero unreviewed, zero high-confidence-unsafe) |
| Build validation | `PASS` (firmware, `updater_package`, all 20 `.fap` outputs) |
| `firmware.dfu` | 862,833 bytes, SHA-256 `e8c11b62429677e727a42682b2e7f2bf8eaf8e5a84e8887f2d3db6b137328f1d` |
| `flipper-z-f7-update-local.tgz` | 2,891,859 bytes, SHA-256 `eec5b148892a3d89c724006bd082f1ca083e05990aa7b8cad43868bf8347cc55` |
| Custom app count | 20 |
| Hardware flashing/testing | **NOT PERFORMED** |
| Release status | **TEST-READY ONLY / NOT RELEASE-READY** |

## 20-app inventory summary

1. `network_subnet` — Phase 2A
2. `programmer_calc` (appid `programmercalc`) — Phase 2A
3. `vin_decoder` — Phase 2A
4. `flipper95` — Phase 2A
5. `chess` — Phase 2A (SAM speech component removed for licensing, see below)
6. `flipfetch` — Phase 2B
7. `quadratic_solver` — Phase 2B
8. `sudoku` — Phase 2B
9. `sd_info` — Phase 2C
10. `docviewlite` — Phase 2C
11. `resistors` — Phase 2D
12. `crypto_dictionary` — Phase 2D
13. `2048` — Phase 2D
14. `image_viewer` — Phase 2E (`example_images/` excluded, see below)
15. `boilerplate` (appid `fap_boilerplate`) — Phase 2E
16. `minesweeper` (appid `minesweeper_redux`) — Phase 2E
17. `qrcode` — Phase 2F
18. `hex_viewer` — Phase 2F
19. `barcode_gen` (appid `barcode_app`) — Phase 2F (source fix applied, see below)
20. `fcc_id_lookup` — dedicated one-app import (upstream LICENSE added, see below)

Full per-app detail (appid, source repo/commit, license, storage, safety,
CI status) is in `docs/CUSTOM_APP_INVENTORY.md`.

## All completed phases

| Phase | Apps added | Cumulative apps | Accepted CI run | Finalization run | Accepted commit | Tags |
|---|---|---|---|---|---|---|
| 2A | network_subnet, programmer_calc, vin_decoder, flipper95, chess | 5 | [`28814008347`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347) | [`28859929957`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28859929957) | `718eec5fe115c9e0467a8d07d974947a85b27cf6` | `phase2a-ci-baseline-20260707`, `phase2a-acceptance-record-20260707` |
| 2B | flipfetch, quadratic_solver, sudoku | 8 | [`28877810474`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28877810474) | [`28879790603`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28879790603) | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` | `phase2b-ci-baseline-20260707`, `phase2b-acceptance-record-20260707` |
| 2C | sd_info, docviewlite | 10 | [`28897702247`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28897702247) | [`28899393035`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28899393035) | `969054ee9f802f72be1064a62052c4be82a91783` | `phase2c-ci-baseline-20260707`, `phase2c-acceptance-record-20260707` |
| 2D | resistors, crypto_dictionary, 2048 | 13 | [`28941093859`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28941093859) | [`28943002724`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28943002724) | `d0812638a02c50389b9e713ad98f2c8215b75dd5` | `phase2d-ci-baseline-20260708`, `phase2d-acceptance-record-20260708` |
| 2E | image_viewer, boilerplate, minesweeper | 16 | [`28968511276`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28968511276) | [`28972160432`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28972160432) | `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` | `phase2e-ci-baseline-20260708`, `phase2e-acceptance-record-20260708` |
| 2F | qrcode, hex_viewer, barcode_gen | 19 | [`29017861599`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29017861599) | [`29027115867`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29027115867) | `37d11cada5a83afdeb752c6b2106216d7fc09b9f` | `phase2f-ci-baseline-20260709`, `phase2f-acceptance-record-20260709` |
| fcc_id_lookup | fcc_id_lookup | 20 | [`29068148596`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29068148596) | [`29096377711`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/29096377711) | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` | `fcc-id-lookup-ci-baseline-20260710`, `fcc-id-lookup-acceptance-record-20260710` |

Phase 2G was a planning-only phase (no import) that concluded **NO-GO /
clean candidate pool exhausted**: of the 25 project-vetted Top-25
candidates, 19 were imported (Phase 2A–2F) and 6 were hard-deferred with
documented reasons (see below). `fcc_id_lookup`, one of the 6, was later
resolved and imported through its own dedicated license-resolution,
pre-import verification, import, and baseline-finalization phases —
bringing the total to 20 without reopening Phase 2G's NO-GO conclusion.

Full CI detail (hashes, FAP counts, updater_package history) is in
`docs/CI_BASELINE_SUMMARY.md`.

## All accepted baseline tags

All 12 tags below were independently re-verified via `git ls-remote
--tags origin` during this audit; every target commit matches its
phase's accepted-commit value above, and no tag was found altered from
its original target.

| Tag | Target commit |
|---|---|
| `phase2a-ci-baseline-20260707` | `718eec5fe115c9e0467a8d07d974947a85b27cf6` |
| `phase2a-acceptance-record-20260707` | `80f429bc7385975e9c1f30bf0e116dc5653b236a` |
| `phase2b-ci-baseline-20260707` | `50dfe2fadb2e587f4e8ed67edbf7f60e42b90159` |
| `phase2b-acceptance-record-20260707` | `ff44e82d5139717315960273917db064c9deeff1` |
| `phase2c-ci-baseline-20260707` | `969054ee9f802f72be1064a62052c4be82a91783` |
| `phase2c-acceptance-record-20260707` | `dbd7c56a596dd63dd2b790fe3dd1bb52de384762` |
| `phase2d-ci-baseline-20260708` | `d0812638a02c50389b9e713ad98f2c8215b75dd5` |
| `phase2d-acceptance-record-20260708` | `f8edb1c9c0cac5cf947df7aa96de2450aaedc14b` |
| `phase2e-ci-baseline-20260708` | `dcdfbb4c262c585d7d4126dc21b40dc3b948fc93` |
| `phase2e-acceptance-record-20260708` | `2910536cc131d2d23feba635ab5d3e806cfdc47d` |
| `phase2f-ci-baseline-20260709` | `37d11cada5a83afdeb752c6b2106216d7fc09b9f` |
| `phase2f-acceptance-record-20260709` | `51df041ed0dc9f49df23305b5f1966cd3294239d` |
| `fcc-id-lookup-ci-baseline-20260710` | `86265727b5b8cfce5086eb88f8bb93d0169ab9a9` |
| `fcc-id-lookup-acceptance-record-20260710` | `1c0232b4137c366c5b79f651136b3097abf69a69` |

(14 tags total: 2 per milestone × 7 milestones.)

## Deferred/excluded apps and why

Six candidates from the project's audited Top-25 shortlist were
considered and never imported:

| App | Reason | Status |
|---|---|---|
| `upython` | Real `furi_hal_gpio_write`/`furi_hal_gpio_read` and `furi_hal_infrared_async_tx_start` (IR transmit) exposed to arbitrary user scripts, undisclosed in the app's own description | Excluded — hardware/control capability risk |
| `iconedit` | `furi_hal_hid_kb_press`/`furi_hal_hid_kb_release` used to type edited-icon data as keystrokes — mechanically a BadUSB injection pattern | Excluded — BadUSB/HID capability risk |
| `c_book` | Bundles verbatim text of a commercially published, copyrighted book ("The C Programming Language," Kernighan & Ritchie); no confirmed redistribution right | Deferred — unresolved copyright question |
| `animation_switcher` | Writes to shared `/ext/dolphin/manifest.txt`, not app-private storage | Excluded — shared/root-level storage write risk |
| `theme_manager` | Writes to shared `/ext/dolphin/` (with backup-before-write) | Excluded — shared/root-level storage write risk |
| `fcc_id_lookup` | *(originally deferred for a license-evidence gap — no LICENSE file in the vendored source)* | **Resolved and imported** via a dedicated narrow license-resolution phase; no longer deferred |

Full detail, quotes, and source citations are in
`docs/THIRD_PARTY_LICENSE_AUDIT.md`. The remaining ~170 apps in the
project's broader candidate pool never received individual per-app
source-level verification and were not promoted to candidate status by
Phase 2G, which explicitly declined to do so without a dedicated
bulk-triage/source-audit pass.

## Known source modifications

Three real source-level changes were made across the whole project,
each documented, reviewed, and CI-confirmed:

1. **`chess` — SAM text-to-speech component removed** (Phase 2A, commit
   `6359f87`). The bundled `sam/stm32_sam.{h,cpp}` and
   `helpers/flipchess_voice.{cpp,h}` files were deleted entirely — not
   merely excluded from the build — because the upstream SAM port
   (`s-macke/SAM`) is self-described "abandonware" with no valid
   open-source license (only a speculative Fair Use claim). This was a
   licensing/distribution-compliance issue, never a safety or
   hardware-capability issue (the component had no radio/GPIO/HID
   access). The start-screen's Sound/Silent toggle was relabeled
   Haptic/No Haptic, reusing the app's pre-existing haptic feature
   rather than adding new behavior. Confirmed absent via a full grep
   sweep of `applications_user/chess/` for `sam`, `stm32_sam`,
   `flipchess_voice`, `speech`, `voice` — zero matches.
2. **`fcc_id_lookup` — upstream MIT LICENSE added** (dedicated one-app
   import, commit `579b355`). The RogueMaster-vendored copy shipped
   with no LICENSE file, SPDX identifier, or copyright header. The
   confirmed upstream MIT license (Copyright (c) 2026 lsr) was added
   byte-verbatim after being independently fetched live and tied to the
   exact vendored revision via a source-content evidence chain (three
   implementation features in the vendored code map to upstream commits
   chronologically newer than the upstream LICENSE-adding commit). No
   app source code itself was modified — only the LICENSE file was
   added alongside it.
3. **`barcode_gen` — 5 dead function calls removed** (Phase 2F.2A,
   commit `b6445ed`). `views/create_view.c` called
   `text_input_show_illegal_symbols()`, a function belonging only to
   the app's own bundled, never-wired-in custom keyboard fork; the
   app's real `TextInput` widget is the system module, which has no
   such function, causing a real CI compile failure
   (`-Werror=implicit-function-declaration`). The fix was presented to
   and explicitly approved by the project owner before any source was
   touched; only the 5 dead call sites were removed (2 were accidental
   upstream duplicate calls), 7 lines net, nothing else changed.

Additionally, one asset-level exclusion was made without touching any
source logic:

- **`image_viewer/example_images/` excluded** (Phase 2E.1). The
  upstream `example_images/` directory contained 3 demo `.bm` bitmaps —
  `cat.bm`, `dolphin.bm`, `spongebob.bm`. Direct decoding of the bitmap
  data showed `spongebob.bm` clearly depicts a recognizable likeness of
  SpongeBob SquarePants, a trademarked/copyrighted character, with no
  license or fair-use rationale documented anywhere in the app's own
  LICENSE, README, or CHANGELOG. All three images were excluded on this
  basis (the other two lack confirmed provenance as well); the
  `fap_file_assets = "example_images"` line was removed from the
  imported `application.fam` — the only textual edit made to any
  upstream file across the whole Phase 2E batch. Confirmed on disk:
  `applications_user/image_viewer/example_images/` does not exist. The
  app was confirmed to build and run without it (it opens whatever file
  the user selects at runtime; no hardcoded reference to the excluded
  directory exists).

## Safety status

**CLEAR, source/CI-based only.** 475 cumulative substring matches across
all 20 apps against a 24-keyword safety scan, every one individually
reviewed and confirmed benign (recorded with file/line/keyword/SHA-256
hash in each phase's validator config). Zero unreviewed matches. Zero
matches against the full 15-keyword high-confidence-unsafe API list
(Sub-GHz, NFC, RFID, iButton, BadUSB, HID, GPIO write, IR transmit,
deauth, jam, brute-force) in any of the 7 phases, with no exception.
Zero real credential/token/password/seed/private-key/wallet handling.
Zero real network/HTTP behavior. Full detail in
`docs/SAFETY_CAPABILITY_AUDIT.md`.

## License/provenance status

19 of 20 apps carry a formal license (MIT or GPLv3) with in-repo
evidence; `boilerplate` carries only an informal README permissive
statement ("This code is open-source and may be used for whatever you
want to do with it"), not a formal SPDX-recognized license — a real,
disclosed, lower-tier evidence case, not an unresolved gap. One
third-party bundled library (`qrcode`'s QR-encoding code, MIT,
ricmoo/Nayuki) and one third-party bundled data-table set
(`barcode_gen`'s symbology encoding tables, non-copyrightable technical
specification data) are documented. `fcc_id_lookup`'s upstream LICENSE
gap was resolved via a source-content evidence chain, not date-matching
alone. **No unresolved license gap exists for any of the 20 imported
apps.** Full detail in `docs/THIRD_PARTY_LICENSE_AUDIT.md`.

## CI status

**NON-HARDWARE CI BASELINE ACCEPTED** at all 7 milestones, each on a
real GitHub-hosted `windows-latest` runner, each independently
re-verified (not trusted on claim) via the GitHub Actions API during
this and prior audits. Two real CI-tooling defects were found,
root-caused, and fixed during the project (Phase 2D.2A intermittent
`updater_package` launch failure; Phase 2F.2A stderr-escalation
tooling defect, which also uncovered the real `barcode_gen` source
defect above). Full detail in `docs/CI_BASELINE_SUMMARY.md`.

## Hardware status

**NOT PERFORMED at any point in this project's history.** No physical
Flipper Zero device and no Windows machine exist in this AI session's
environment. No `-Mode HardwareAssisted` workflow invocation has ever
run past a preflight/report-only/detect-device check. See
`docs/REMAINING_GAPS_AND_NEXT_ACTIONS.md` and
`docs/FINAL_NON_HARDWARE_GO_NO_GO.md`.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.** No release has been tagged,
published, or claimed at any point. This audit does not change that
status and is not itself a release approval.

## Companion audit documents

- `docs/CUSTOM_APP_INVENTORY.md`
- `docs/THIRD_PARTY_LICENSE_AUDIT.md`
- `docs/SAFETY_CAPABILITY_AUDIT.md`
- `docs/STORAGE_AND_DATA_BEHAVIOR_AUDIT.md`
- `docs/CI_BASELINE_SUMMARY.md`
- `docs/REMAINING_GAPS_AND_NEXT_ACTIONS.md`
- `docs/FINAL_NON_HARDWARE_GO_NO_GO.md`

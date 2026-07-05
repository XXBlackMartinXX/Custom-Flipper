# Phase 1.5 — Top 25 Candidates (Final Shortlist)

Docs only — nothing here is imported, merged, or built. These 25 are drawn from the
195-app candidate pool in `PHASE1_5_HIGH_VALUE_SHORTLIST.md`, picked to prioritize:
low risk, high user value, low integration complexity, zero radio-transmit
involvement, zero unauthorized-access implication, no unusual dependencies, and a
good fit alongside Unleashed's existing app set. Deliberately excludes every app that
needed a footnote in the shortlist doc (RF-transmit games, the HID-wedge tool, the
locksmith-adjacent tools, the thin-description ones) — this list has none of that
ambiguity by design. Picked for category breadth (games, calculators, viewers,
developer tools, diagnostics, UI/UX helpers, educational references), not just
raw popularity.

All 25 pass the same baseline: safe `fap_category`, zero safety-keyword hits, real
author/README/`fap_weburl`/version on file (i.e., these are maintained, attributable,
single-purpose projects, not anonymous drops), and no declared unusual dependencies.

| # | App | Source path | Category | Purpose / why useful | Est. difficulty | Safety/legal risk | Hardware risk | Dependencies | Overlap/conflict risk | Action |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `chess` | `applications/external/chess/` | Games | Full chess implementation (v1.12, maintained, xtruan/flipper-chess) — a genuinely popular, well-known game missing from base | Low-Med (807KB incl. piece graphics) | None identified | None (on-device only) | None declared | None found vs. base | candidate |
| 2 | `2048` | `applications/external/2048/` | Games | Well-known puzzle game port (v1.6) | Low-Med | None identified | None | None declared | None found | candidate |
| 3 | `minesweeper` | `applications/external/minesweeper/` | Games | Classic Minesweeper (v1.7) | Med-High (1MB, likely tile assets) | None identified | None | None declared | None found | candidate |
| 4 | `sudoku` | `applications/external/sudoku/` | Games | Sudoku (v1.2) | Low-Med | None identified | None | None declared | None found | candidate |
| 5 | `programmer_calc` | `applications/external/programmer_calc/` | Tools | Base-conversion/bitwise calculator for developers (v0.9.2) | Medium | None identified | None | None declared | None found | candidate |
| 6 | `resistors` | `applications/external/resistors/` | Tools | Resistor color-code calculator (v1.4) — genuinely useful for anyone doing electronics with the Flipper's GPIO | Med-High (2.3MB, likely icon/reference assets) | None identified | None | None declared | None found | candidate |
| 7 | `network_subnet` | `applications/external/network_subnet/` | Tools | IPv4 subnet calculator (v0.1) — useful for network/IT work | Low-Med | None identified | None | None declared | None found | candidate |
| 8 | `quadratic_solver` | `applications/external/quadratic_solver/` | Tools | Quadratic equation solver (v0.1) | Low-Med | None identified | None | None declared | None found | candidate |
| 9 | `hex_viewer` | `applications/external/hex_viewer/` | Tools | Views arbitrary files as hex — a genuine developer/diagnostic gap filler | Low-Med | None identified | None | None declared | None found | candidate |
| 10 | `docviewlite` | `applications/external/docviewlite/` | Tools | Simple document viewer (v0.1) | Low | None identified | None | None declared | None found | candidate |
| 11 | `image_viewer` | `applications/external/image_viewer/` | Media | Image viewer (v0.1) | Low | None identified | None | None declared | None found | candidate |
| 12 | `boilerplate` | `applications/external/boilerplate/` | Tools/Educational | FAP starter-project template (v1.3) — directly useful for this project's own future app development, not just an end-user feature | Low-Med | None identified | None | None declared | None found | candidate |
| 13 | `upython` | `applications/external/upython/` | Tools | Compile/execute MicroPython scripts on-device (v1.8) — highest-value single entry on this list, enables user-scriptable automation without a firmware rebuild | Med-High (4.2MB — largest here; bundles a scripting runtime, expect the longest real integration/build-verification effort of the 25) | None identified | None | None declared | None found | candidate |
| 14 | `iconedit` | `applications/external/iconedit/` | Tools | Icon editor (v0.7.1) — developer/asset tool | Medium | None identified | None | None declared | None found | candidate |
| 15 | `sd_info` | `applications/external/sd_info/` | Tools | Displays SD card information (v0.1) — diagnostic | Low-Med | None identified | None | None declared | None found | candidate |
| 16 | `flipfetch` | `applications/external/flipfetch/` | Tools | Device-info display, "neofetch"-style (v0.1) — diagnostic/fun | Low | None identified | None | None declared | None found | candidate |
| 17 | `flipper95` | `applications/external/flipper95/` | Tools | Prime-number stress test (v1.1) — genuine diagnostic tool for verifying CPU/build health post-flash | Low | None identified | None | None declared | None found | candidate |
| 18 | `animation_switcher` | `applications/external/animation_switcher/` | Settings | Switch dolphin background animations on the fly (v1.1) — UI/UX helper | Low-Med | None identified | None | None declared | None found | candidate |
| 19 | `theme_manager` | `applications/external/theme_manager/` | Settings | Manage dolphin animation themes from SD card (v1.6) — UI/UX helper, pairs naturally with #18 | Low-Med | None identified | None | None declared | None found | candidate |
| 20 | `qrcode` | `applications/external/qrcode/` | Tools | Displays QR codes (v2.1, mature/maintained) — broadly useful utility | Low-Med | None identified | None | None declared | None found | candidate |
| 21 | `barcode_gen` | `applications/external/barcode_gen/` | Tools | Displays various barcode formats (v1.4) | Low-Med | None identified | None | None declared | None found | candidate |
| 22 | `vin_decoder` | `applications/external/vin_decoder/` | Tools | Decodes Vehicle Identification Numbers (v0.2) — a pure decode/lookup reference tool, no vehicle interaction/hardware access at all despite the automotive subject | Low-Med | None identified | None | None declared | None found | candidate |
| 23 | `fcc_id_lookup` | `applications/external/fcc_id_lookup/` | Tools | Offline FCC ID applicant/frequency lookup (v0.1) — genuinely useful reference for RF hobbyists, itself has no transmit capability | Low-Med | None identified | None | None declared | None found | candidate |
| 24 | `crypto_dictionary` | `applications/external/crypto_dictionary/` | Tools/Educational | Cryptography glossary/reference (v0.1) — educational, not a crypto-operations tool | Low-Med | None identified | None | None declared | None found | candidate |
| 25 | `c_book` | `applications/external/c_book/` | Tools/Educational | On-device copy of "The C Programming Language" (K&R), Flipper Edition (v0.2) | Low-Med | None identified | None | None declared | None found | candidate |

## Notes on this list

- **Category spread by design**: 4 games, 8 calculators/utilities, 3 viewers/readers,
  3 developer tools, 3 diagnostics, 2 UI/UX helpers, 2 educational references. This
  matches the categories the task asked to prioritize rather than defaulting to "most
  popular games."
- **Highest-value single pick**: `upython` (#13) — it's also the largest/most complex
  of the 25, so budget real build-verification time for it specifically; don't treat
  it as equivalent effort to, say, `flipfetch`.
- **Deliberately excluded from this Top 25** even though they're in the broader
  195-app pool: anything needing a footnote in `PHASE1_5_HIGH_VALUE_SHORTLIST.md`
  (`bomberfox`, `rock_paper_scissors` — Sub-GHz transmit; `flipper_wedge` — HID
  keystroke output; `keycopier`, `lishi_hu66`, `disn3y_toolbox` — physical/third-party
  hardware caveats; `id_card_v2`, `keyller` — unclear purpose). A stricter, cleaner 25
  was preferred over a longer list with asterisks.
- **None of these 25 have been individually source-read yet** (README + `.fam`
  metadata only, per this pass's stated depth) — a fast per-app source skim is still
  the right next step before any of them are actually copied into a build, per
  `PHASE1_RECOMMENDED_INTEGRATION_PLAN.md`. "Candidate" here means "cleared automated
  triage and worth that next step," not "approved for import."
- **None of these 25 have been build-tested** against the Unleashed base. First real
  integration attempt (if approved) should build one at a time, per the existing
  Phase 1 integration-plan discipline (one app per commit, rebuild after each).

## Stop point

This completes the requested Phase 1.5 deliverables: bulk triage, high-value
shortlist, exclusion list, and this Top 25. No code integration has started. Next
action requiring approval: either (a) do the fast individual source-read pass on
these 25 before any import, (b) pick a smaller first batch (e.g., 5) to actually
attempt building against Unleashed as a pipeline test, or (c) something else —
awaiting direction.

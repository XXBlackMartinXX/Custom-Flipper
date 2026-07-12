# Duplicate and Supersession Matrix

Real cross-reference of this project's own 20-app baseline against the
three community-app collections (`unleashed_plugins`, `momentum_apps`,
`roguemaster`), by directory name **and** by each app's real,
`application.fam`-declared `appid`. "Present" below means a research
agent directly confirmed the directory and its `appid` in that
repository's actual clone — not inferred from a name match alone.

| Our app_id | Our appid | Unleashed (`all-the-plugins`) | Momentum (`Momentum-Apps`) | RogueMaster | Notes |
|---|---|---|---|---|---|
| `network_subnet` | `network_subnet` | not found | not found | `applications/external/network_subnet` | Only RogueMaster carries an equivalent |
| `programmer_calc` | `programmercalc` | `non_catalog_apps/prog_calculator` | `programmer_calculator` (appid `programmercalc`) | `applications/external/programmer_calc` | Present in all three |
| `vin_decoder` | `vin_decoder` | `non_catalog_apps/vin_decoder` | not found | `applications/external/vin_decoder` | Not in Momentum |
| `flipper95` | `flipper95` | not found | not found | `applications/external/flipper95` | Only RogueMaster carries an equivalent |
| `chess` | `chess` | `non_catalog_apps/chess` | `chess` | `applications/external/chess` | Present in all three |
| `flipfetch` | `flipfetch` | not found | not found | `applications/external/flipfetch` | Only RogueMaster carries an equivalent |
| `quadratic_solver` | `quadratic_solver` | not found | `quadrastic` (appid `quadrastic` — **different appid, likely a distinct implementation, not confirmed as the same app**) | `applications/external/quadratic_solver` | Momentum's is a near-match by concept, not a confirmed duplicate |
| `sudoku` | `sudoku` | `non_catalog_apps/sudoku` | not found | `applications/external/sudoku` | Not in Momentum |
| `sd_info` | `sd_info` | `non_catalog_apps/sd_info` | not found | `applications/external/sd_info` | Not in Momentum |
| `docviewlite` | `docviewlite` | not found | not found | `applications/external/docviewlite` | Only RogueMaster carries an equivalent |
| `resistors` | `resistance_calculator` | `apps_source_code/resistors` (appid `resistors`) | `resistance_calculator` (appid `resistors`) | `applications/external/resistors` | Present in all three; note appid is `resistors` upstream vs. our own `resistance_calculator` — see below |
| `crypto_dictionary` | `crypto_dict` | `non_catalog_apps/crypto_dictionary_book` | not found | `applications/external/crypto_dictionary` | Not in Momentum |
| `2048` | `2048_improved` | `base_pack/game_2048` (appid `game_2048`) | `2048` (appid `game_2048`) | two variants: `applications/external/2048` (appid `2048_improved`) and `applications/external/game2048` (appid `2048`, "original") | RogueMaster carries both an "improved" variant matching ours and a separate "original" |
| `image_viewer` | `image_viewer` | not found | `image_viewer` | `applications/external/image_viewer` | Not in Unleashed's plugin set |
| `fap_boilerplate` | `fap_boilerplate` | not found | not found | `applications/external/boilerplate` | Only RogueMaster carries an equivalent |
| `minesweeper_redux` | `minesweeper_redux` | `base_pack/minesweeper` (appid `minesweeper_redux`) | `minesweeper` (appid `minesweeper_redux`) | two variants: `applications/external/minesweeper` (appid `minesweeper_redux`) and `applications/external/minesweeper_og` (appid `minesweeper`) | RogueMaster carries both a "redux" variant matching ours and a separate "original" |
| `qrcode` | `qrcode` | `non_catalog_apps/flipperzero-qrcode` | `qrcode` | `applications/external/qrcode` | Present in all three |
| `hex_viewer` | `hex_viewer` | `base_pack/hex_viewer` | `hex_viewer` | `applications/external/hex_viewer` | Present in all three |
| `barcode_app` | `barcode_app` | `base_pack/barcode_gen` | `barcode_gen` (appid `barcode_app`) | `applications/external/barcode_gen` | Present in all three |
| `fcc_id_lookup` | `fcc_id_lookup` | not found | not found | `applications/external/fcc_id_lookup` | Only RogueMaster carries an equivalent — plausibly because RogueMaster vendors from the widest possible set of individually-submitted community apps, or because this project's own app (or its origin) was itself contributed there |

## Interpretation, not assumption

**"Present in another repository" is recorded as a provenance
observation, not automatically treated as evidence of code
duplication/plagiarism.** Community Flipper Zero apps are commonly
authored once and then vendored into multiple firmware distributions by
their own authors or by each fork's maintainers, with the author's
knowledge — the identical `appid` strings across repositories (e.g.
`minesweeper_redux`, `barcode_app`, `game_2048`) are consistent with
"same app, same author, vendored in several places," not with
independent reimplementation. This phase did not attempt to determine
authorship history for each app — that would require reading each
app's own commit history and any in-file attribution, which is future
work, not claimed as done here.

## Same appid, different name — one real naming discrepancy found

Our `resistors` directory declares `appid = "resistance_calculator"`
in its own `application.fam` (confirmed directly against this
repository), while every upstream match above uses `appid = "resistors"`
instead. This is worth flagging as a real, minor naming inconsistency
between our own repository and the upstream ecosystem — not a
functional problem, but worth a maintainer's attention if cross-firmware
appid consistency ever matters (e.g. for Smart App Pack manifests in
RFC 2, which pin exact appids).

## RogueMaster's two dual-variant cases

RogueMaster is the only repository found to carry **both** an
"improved"/"redux" variant matching our own app's appid, **and** a
separately named "original" variant with a different appid, for two of
our apps (`2048`/`game2048`, `minesweeper`/`minesweeper_og`). This is
recorded as a real finding, not a disposition decision — see
`APP_CENSUS.json` for how each of these four is individually
dispositioned (our own two apps are not candidates; RogueMaster's
"original" variants are catalogued as separate candidates with their
own disposition).

## Duplicate-related dispositions applied in the broader census

See `APP_CENSUS.json`/`APP_CENSUS.tsv` for the full candidate list
(our 20 apps plus a curated sample of other notable upstream apps).
Where a curated candidate is functionally equivalent to one of our own
20 apps (per this matrix), its disposition is `REJECT_DUPLICATE`
pointing back to the existing app, rather than being recommended for
import.

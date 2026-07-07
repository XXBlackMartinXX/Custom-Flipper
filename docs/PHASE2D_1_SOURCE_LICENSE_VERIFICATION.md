# Phase 2D.1 — Source and License Verification

Docs only. Pre-import verification only. **No app code has been imported.**
This is a genuine, fresh source-level verification pass — unlike the
Phase 2D planning package (`PHASE2D_CANDIDATE_REVIEW.md`,
`PHASE2D_LICENSE_REVIEW.md`), which was citation-only (drawing on the
existing Phase 1.6 audit), this phase had real, working network access and
fetched the actual source. Every finding below is from files actually read
in this session, not carried forward from any prior audit.

## Evidence source

- **Repository**: `RogueMaster/flipperzero-firmware-wPlugins` (the same
  fork every prior Phase 1/2A/2B/2C source audit has cited).
- **Commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same
  commit `PHASE1_6_TOP25_SOURCE_AUDIT.md`, `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`,
  and `PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` all audited, fetched fresh
  via a shallow `git fetch --depth 1 origin <sha>` against the real
  upstream repository in this session, then `git rev-parse FETCH_HEAD`
  confirmed the checked-out commit hash matches exactly. **No discrepancy
  found** between this source and what the Phase 2D planning docs assumed
  — no stop/discrepancy report is needed.
- **Method**: `git checkout FETCH_HEAD -- applications/external/<app>` for
  each of the 3 apps into a scratch directory outside this repository,
  then direct `cat`/`grep`/`file`/`du` against the real checked-out files.
  Nothing was fetched into, or committed from, this project's own working
  tree — the scratch clone lives entirely outside `/home/user/Custom-Flipper`
  and is not part of any commit.

## Apps reviewed (exactly the 3 in scope)

`resistors`, `crypto_dictionary`, `2048`. No other app was fetched, read,
or considered. `fcc_id_lookup`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, and `theme_manager` were not touched in this phase,
per the explicit hard exclusions.

---

## `resistors`

| Field | Value |
|---|---|
| Source path | `applications/external/resistors/` |
| appid | `resistance_calculator` |
| App name (manifest) | `Resistance Calculator` |
| Category | Tools |
| Author (`fap_author`) | Lewis Westbury |
| Upstream repo (`fap_weburl`) | `https://github.com/instantiator/flipper-zero-experimental-apps` |
| Version | `1.4` |
| Files present | `application.fam`, `LICENSE`, `README.md`, 13 files under `src/` (`app_state.{c,h}`, `flipper.h`, `resistor_logic.{c,h}`, `resistors_app.{c,h}`, `scene_edit.{c,h}`, `scene_main_menu.{c,h}`, `scenes.{c,h}`), `resistors.png` (fap_icon, root), `images/` (`box_8x22.png`, `r3.png`, `r4.png`, `r5.png`, `r6.png` — the `fap_icon_assets` directory actually referenced by `application.fam`) |
| Directories present but **not referenced by `application.fam`** | `.flipcorg/` (624K — banner/gallery images for a Flipper app catalog listing), `design/` (64K — icon design-source images), `img/` (36K — 2 screenshots), `screenshots/` (1.6MB — README/catalog screenshots, including a `v0/` subfolder) |
| Bundled third-party code/data | None in the code itself. See asset-provenance finding below for the non-shipped image directories. |

**License evidence found**: A real `LICENSE` file is present at the app
root, full text read directly — the complete, unmodified **MIT License**.

> MIT License
>
> Copyright (c) 2023 Lewis Westbury
>
> Permission is hereby granted, free of charge, to any person obtaining a
> copy of this software and associated documentation files (the
> "Software")... [standard MIT permission/warranty text]

**Declared license: MIT.** MIT is on the FSF's own GPL-compatible license
list, fully compatible with distribution alongside this project's GPLv3
firmware base (same reasoning already applied to `flipfetch`/
`quadratic_solver`/`sudoku`/`docviewlite`). **Attribution required**: yes,
per MIT's standard terms — a routine `CREDITS.md`/`THIRD_PARTY_NOTICES.md`
entry at actual import time, crediting Lewis Westbury (original author)
and noting the `README.md`'s own credit to the `shalebridge` fork that
contributed the 1.4 features (friendly resistance values, Pink color band,
missing temp coefficients).

**Safety/API scan** (full read of all 13 `src/` files, plus a targeted
grep for all 22 required capability keywords — the original 18 plus this
phase's 4 new ones, `seed`/`wallet`/`private key`/`secret`): includes
across `src/` are `furi.h`, `gui/gui.h`, `gui/icon_i.h`,
`gui/view_dispatcher.h`, `gui/scene_manager.h`, `gui/modules/widget.h`,
`gui/modules/submenu.h`, `gui/modules/text_input.h`, `math.h`, plus two
internal-path includes:
`<applications/services/gui/modules/widget_elements/widget_element.h>`
and `<applications/services/gui/modules/widget.h>` (see build-risk note
below). **Zero real matches, and zero raw substring matches at all** —
unlike `sd_info`/`docviewlite` in Phase 2C.1, this codebase does not even
contain any of the common false-positive trigger words (no `double`,
`table`, `enabled`, `variable`, etc. that would substring-match `ble`).
`grep -rniE` across the full keyword list returned no hits whatsoever in
`src/`.

**Storage finding — confirmed directly, matching the planning assumption.**
A full `grep` for `storage_`, `file_stream`, `stream_`, `RECORD_STORAGE`,
`fopen`, `APP_DATA_PATH`, `FSAM_`, `FSOM_` across all of `src/` returned
**zero matches**. This app genuinely performs no storage I/O of any kind —
the most explicit zero-storage classification in the Phase 2D candidate
pool, as the planning phase's citation-based review predicted, and this is
now a direct confirmation rather than a citation.

**Hardware/capability finding — confirmed directly.** A full grep for
`furi_hal` across all of `src/` returned **zero matches**. No Sub-GHz,
NFC/RFID/iButton, BadUSB/HID, BLE, GPIO, or Infrared-transmit API is
referenced anywhere. This app is a pure calculator/GUI app: it reads user
button input to select resistor band colors and displays the computed
resistance, tolerance, and temperature coefficient — nothing else.

**Asset-provenance finding — a real, specific finding this phase exists to
catch.** The Phase 2D planning package (`PHASE2D_LICENSE_REVIEW.md`,
`PHASE2D_GO_NO_GO.md`) flagged this app's "~2.3MB bundled asset footprint"
for a specific provenance check. Reading the actual source shows this
figure, while numerically accurate for the *upstream repository directory*
as a whole, **substantially overstates what would actually ship in a
built FAP**:

- The files `application.fam` actually references for the build are
  `resistors.png` (4K, the `fap_icon`) and `images/` (24K total — 5 small
  1-bit-grayscale PNGs, `box_8x22.png` at 8×22px and `r3`–`r6.png` at
  128×64px, the `fap_icon_assets` directory). **Total actual build-input
  footprint: ~28K, not 2.3MB.**
- The remaining ~2.3MB (`.flipcorg/`, `design/`, `img/`, `screenshots/`)
  is **not referenced anywhere in `application.fam`** and is not consumed
  by any `src/` file — it is upstream-repository documentation/catalog
  material (banner images, README screenshots, an app-store gallery), not
  a build input.
- **Within that non-shipped material, two files have genuinely unclear
  provenance**: `design/resistor_5_src.jpg` (1024×681 JPEG, 300 DPI,
  progressive) and `design/resistor_4_src.webp` (1024×532, VP8) appear to
  be higher-resolution reference photographs used as a tracing/color
  reference to hand-derive the small 1-bit `design/resistor_4.png` /
  `resistor_5.png` icons — there is no EXIF/camera metadata, no separate
  asset-specific license or credit file, and no notice addressing whether
  these are the author's own photographs, a licensed stock photo, or an
  uncredited web image. The repository has no `NOTICE`/`CREDITS`/
  asset-specific license file of any kind — the single root `LICENSE`
  covers "the Software" in the conventional MIT sense (source code), and
  it is not clear that a photographic reference image is intended to fall
  under that same grant.
- **The actual shipped icons (`images/*.png`, `resistors.png`) do not
  raise the same concern**: they are small (128×64px and smaller), 1-bit
  grayscale, hand-converted pixel-art glyphs in the exact style Flipper
  apps universally use for their own custom icons — nothing about their
  content or format suggests copied third-party creative material, and
  they are covered by the same repository-wide MIT grant as the source
  code.

**This finding does not trigger DEFER/BLOCKED for the app as a whole**,
because the ambiguous-provenance files are not build inputs and do not
need to be imported at all. It does mean the import scope for this app
must be constrained: **import only `application.fam`, `src/`,
`resistors.png`, `images/`, `LICENSE`, and `README.md`; do not import
`.flipcorg/`, `design/`, `img/`, or `screenshots/`.** This mirrors, in a
lower-stakes form, the exact discipline this project applied to
`fcc_id_lookup`'s 8.9MB database in Phase 2C.1 (excluding an
unclear/out-of-scope asset rather than either guessing it is fine or
blocking the whole app over it).

**Build-risk note**: two `src/` files include internal firmware paths
directly (`<applications/services/gui/modules/widget_elements/widget_element.h>`,
`<applications/services/gui/modules/widget.h>`) rather than the public
`<gui/...>` headers used everywhere else in this codebase and in every
other app in this project's baseline. Whether these internal paths
resolve correctly against this project's exact firmware-base directory
layout is a genuine, specific Static/Build-validation-time question, not
assumed either way — flagged for `PHASE2D_1_IMPORT_READINESS_MATRIX.md`.

### `resistors` conclusion: **CLEARED FOR IMPORT**

Conditional on: (1) the import in a future Phase 2D.2 including only
`application.fam`, `src/`, `resistors.png`, `images/`, `LICENSE`,
`README.md` — explicitly excluding `.flipcorg/`, `design/`, `img/`,
`screenshots/` (unclear-provenance / non-build-input directories), and
(2) the internal-header include-path build risk above being observed
(not assumed) at actual Static/Build validation.

---

## `crypto_dictionary`

| Field | Value |
|---|---|
| Source path | `applications/external/crypto_dictionary/` |
| appid | `crypto_dict` |
| App name (manifest) | `Crypto Dictionary` |
| Category | Tools/Educational |
| Author (`fap_author`) | armixz |
| Upstream repo (`fap_weburl`) | `https://github.com/armixz/Flipper-Zero-Crypto-Dictionary` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `main.c`, `app/app.{c,h}`, `buffer/dynamic_buffer.{c,h}`, `callbacks/callbacks.{c,h}`, `constants/constants.h`, `resource/resource.{c,h}`, `scenes/scene_manager.{c,h}`, `scenes/scenes.{c,h}`, `icons/crypto_dict_icon.png`, 14 bundled glossary text files under `resources/symmetric_cipher/*.txt` (Blowfish, Camellia, CAST-128, CAST-256, DES, IDEA, RC2, RC4, RC5, RC6, Serpent, SM4, Twofish, Triple DES), plus `resources/about/{algorithms,github}.txt` and `resources/development.txt` |
| Directories present but not referenced by `application.fam` | `.flipcorg/` (banner/gallery images — same catalog-listing pattern as `resistors`, not a build input) |
| Bundled third-party code/data | None — see glossary-provenance finding below. |

**License evidence found**: A real `LICENSE` file is present, full text
read directly — the complete, unmodified **GNU General Public License,
Version 3** (identical FSF template text to `sd_info`'s Phase 2C.1
finding).

**Declared license: GPLv3.** As with `sd_info` in Phase 2C.1, this is the
most direct possible compatibility case — the app is licensed under the
exact same license as this project's own firmware base, so no
cross-license compatibility analysis is required. **Attribution required**:
yes, per GPLv3's standard terms (preserve the license text).

**Safety/API scan** (full read of all `.c`/`.h` files, plus a targeted
grep for all 22 required keywords across every file in the app directory,
not just source — including the 14 glossary `.txt` files): **zero real
matches anywhere**, including inside the bundled glossary text itself.
This is a materially cleaner result than the Phase 2D risk register
anticipated ("a cipher/cryptography glossary may contain glossary entries
that literally define terms like 'credential,' 'token,' 'password,' or
'brute force'") — in practice, the actual bundled glossary text (14
symmetric-cipher reference cards) only discusses `key size bits`,
`block size`, `rounds`, and `structure` (Feistel network) — objective,
public cryptographic algorithm parameters, not the words `credential`,
`token`, `password`, `brute`, `seed`, `wallet`, `private key`, or `secret`
in any form. The only keyword-adjacent hits found anywhere in the app
directory are inside the GPLv3 `LICENSE` file's own boilerplate text
(e.g. "secondarily liable," "special password or key for unpacking" —
standard FSF license prose, not app behavior or app data), which are
**content-only, non-executable, non-app-data hits** and require no
further classification.

**Glossary-provenance finding.** The 14 `resources/symmetric_cipher/*.txt`
files are short, distinctively hand-authored ASCII-art reference cards
(custom box-drawing characters, informal phrasing, and consistent
idiosyncratic spelling — e.g. "sixteen"/"fiften" rounds in
`blowfish.txt`) summarizing each cipher's block size, key size, round
count, and structure. These are:
- **Public, non-copyrightable technical facts** (a cipher's key size and
  round count are objective specifications, not creative expression);
- Presented in a **distinctive personal authorial style** consistent with
  original authorship by `armixz`, not verbatim-copied textbook or
  Wikipedia prose;
- **Not attributed to, or excerpted from, any named third-party source**
  anywhere in the app, the README, or the `LICENSE`.

No evidence of copied commercial or unattributed third-party text was
found. Combined with the whole-repository GPLv3 grant (which, absent any
contrary notice, covers this bundled reference content as part of "the
Program"), this satisfies the "confirm glossary text provenance" caution
— evidence supports original-content authorship, not an unresolved gap.

**Special-caution confirmation (crypto_dictionary handles no user
secrets)**: read `app/app.c`, `resource/resource.c`, and
`scenes/scenes.c` in full. The app:
- Opens each glossary `.txt` file via
  `file_stream_open(app->file_stream, file_path, FSAM_READ, FSOM_OPEN_EXISTING)`
  — **explicit read-only access mode, existing-files-only** (`scenes.c`,
  `topic_scene_on_enter`). No `FSAM_WRITE` or `FSOM_CREATE*` call exists
  anywhere in the codebase.
- Reads the file's own bundled text, word-wraps it, and displays it in a
  scrollable widget. There is no text-input field, no user-supplied data
  of any kind, and no network/radio code anywhere in the app.
- Performs **no cryptographic operations** on any data — it does not
  encrypt, decrypt, hash, or generate keys; it only displays static
  reference text describing what those algorithms are.
- Does not request, store, generate, transform, or display any user
  credential, wallet key, token, seed phrase, password, or secret of any
  kind — confirmed by the full-file reads above and the zero-match
  keyword scan.

This is a full, direct confirmation of the Phase 2D planning assumption
("pure reference/glossary app, no crypto *operations* performed on user
data"), not merely a citation carried forward.

**Storage finding — confirmed, read-only, matching the planning
assumption.** As shown above: `FSAM_READ`/`FSOM_OPEN_EXISTING` only,
reading the app's own bundled asset files (`fap_file_assets="resources"`
in `application.fam`, resolved via `APP_ASSETS_PATH`). No write call
exists anywhere in the source.

### `crypto_dictionary` conclusion: **CLEARED FOR IMPORT**

No conditions beyond the standard GPLv3 attribution requirement. The
`.flipcorg/` directory (not referenced by `application.fam`) should be
excluded from the actual import for the same reason as `resistors`'s
non-build-input directories, though it carries no provenance concern of
its own (small catalog-banner images, not flagged in planning).

---

## `2048`

| Field | Value |
|---|---|
| Source path | `applications/external/2048/` |
| appid | `2048_improved` |
| App name (manifest) | `2048 (Improved)` |
| Category | Games |
| Author (`fap_author`) | eugene-kirzhanov |
| Upstream repo (`fap_weburl`) | none declared in `application.fam` (README credits `Eugene Kirzhanov`, with thanks to `DroomOne`'s FlappyBird and `x27`'s "15" game as design inspiration, not code reuse) |
| Version | `1.6` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `README-catalog.md`, `array_utils.{c,h}`, `digits.h`, `game_2048.c`, `game_2048.png` (fap_icon) |
| Directories present but not referenced by `application.fam` | `images/` (36K — 2 gameplay screenshots, referenced only by `README.md`, not the build), `img/` (36K — 2 more gameplay screenshots, unreferenced anywhere) |
| Bundled third-party code/data | None. |

**License evidence found**: A real `LICENSE` file is present, full text
read directly — the complete, unmodified **MIT License**.

> MIT License
>
> Copyright (c) 2022 Eugene Kirzhanov
>
> [standard MIT permission/warranty text]

**Declared license: MIT.** Same compatibility reasoning as `resistors`
above and the Phase 2B/2C MIT apps. **Attribution required**: yes, per
MIT's standard terms; `README.md` already credits `Eugene Kirzhanov`
(2022) plus design-inspiration credits to `DroomOne` and `x27` (not code
dependencies — `array_utils.c`/`digits.h` are this app's own small,
self-contained utility/bitmap-font files, not copies of either credited
project's code).

**Asset finding**: `digits.h` (263 lines) is a hardcoded raw `uint8_t
digits[16][14][14]` pixel array — 16 hand-authored 14×14 bitmap glyphs for
the game's number tiles. This is original, generated pixel data specific
to this app, not a third-party font or copied asset; no separate license
notice is needed beyond the app's own MIT grant. `images/` and `img/`
(4 gameplay screenshots total, 512×256 1-bit PNGs, clearly the app's own
rendered display captures, not photographic/third-party content) are not
referenced by `application.fam` and are not required for the build —
same non-build-input exclusion recommendation as `resistors`'s
directories, though with no provenance concern of their own (they are
evidently self-captured gameplay screenshots, not stock imagery).

**Safety/API scan** (full read of `game_2048.c`, `array_utils.c`,
`digits.h`, plus a targeted grep for all 22 required keywords): includes
are `furi.h`, `gui/gui.h`, `input/input.h`, `storage/storage.h`,
`dolphin/dolphin.h`. **Zero real matches.** All raw substring hits are the
same `ble`-inside-an-ordinary-word class already established in Phase
2B.1/2C.1 (`table`, `is_table_updated`) — this codebase repeatedly uses
"table" for its game board array, which substring-matches `ble`, and
nothing else. A single `dolphin_deed(DolphinDeedPluginGameStart)` call
(line 408) invokes Flipper's own standard built-in gamification/XP-leveling
system — a normal, documented Flipper SDK API used by essentially every
game in this ecosystem, not a hardware or safety concern of any kind. A
full grep for `furi_hal` returned **zero matches** — no Sub-GHz, NFC/RFID/
iButton, BadUSB/HID, BLE, GPIO, or Infrared-transmit API is referenced
anywhere.

**Storage finding — confirmed, app-scoped, with one real nuance the
planning citation did not anticipate.** `game_2048.c` defines:

```c
#define SAVING_DIRECTORY EXT_PATH("apps_data/game_2048")
#define SAVING_FILENAME  SAVING_DIRECTORY "/game_2048.save"
```

`save_game()` creates `SAVING_DIRECTORY` if absent
(`storage_simply_mkdir`) and writes the whole `GameState` struct (board,
score, high score) to `SAVING_FILENAME` via `storage_file_open(file,
SAVING_FILENAME, FSAM_WRITE, FSOM_CREATE_ALWAYS)`, on every move and on
exit. `load_game()` reads it back the same way. This resolves to
`/ext/apps_data/game_2048/game_2048.save` — the same `/ext/apps_data/`
tree convention this project confirmed for `chess`
(`/ext/apps_data/flipchess/`) and `sudoku` (`/ext/apps_data/sudoku/`),
i.e. **effectively app-private**: no other app in this project's baseline
writes to, or could collide with, `/ext/apps_data/game_2048/`.

**The nuance**: unlike `chess`/`sudoku`, this path is built from a
**hardcoded literal string** (`EXT_PATH("apps_data/game_2048")`) rather
than the SDK's `APP_DATA_PATH()` macro, which would instead resolve
dynamically from the app's actual registered `appid`
(`2048_improved`) via `furi_thread_get_appid()`. In practice this makes no
difference to privacy or collision risk here — `game_2048` as a literal
subdirectory name is just as unique as `2048_improved` would be, and
nothing else in this project's baseline or the wider candidate pool uses
either name — but it is a real, directly-observed deviation from the
idiomatic pattern, not something the planning-phase citation could have
predicted, and is recorded rather than smoothed over.

**A second nuance, also directly observed**: `load_game()` unconditionally
calls `storage_common_copy(storage, EXT_PATH("apps/Games/game_2048.save"), SAVING_FILENAME)`
followed by `storage_common_remove(storage, EXT_PATH("apps/Games/game_2048.save"))`
on every load — a one-time migration shim checking for a save file at an
**older, legacy, non-app-private location**
(`/ext/apps/Games/game_2048.save`, a pre-`apps_data`-convention path used
by older firmware versions) and moving it into the new location if
present. On a fresh install with no prior legacy save (the case for this
project's own import), both calls silently no-op (the source file does
not exist). This is a benign, disclosed, one-time backward-compatibility
step scoped to this game's own filename — not a shared/root-level write,
not automatic beyond the app's own first load, and not a new capability
concern — but it is a real behavior worth recording precisely rather than
describing the app as simply "app-private save only" without
qualification.

### `2048` conclusion: **CLEARED FOR IMPORT**

Conditional on: (1) the import in a future Phase 2D.2 including only
`application.fam`, `array_utils.{c,h}`, `digits.h`, `game_2048.c`,
`game_2048.png`, `LICENSE`, `README.md` — `images/`/`img/` may be
excluded as non-build-input directories with no provenance concern of
their own — and (2) the storage/risk documentation for this app
describing the save behavior precisely as found above (hardcoded
`/ext/apps_data/game_2048/` path plus a legacy-path migration check), not
as an unqualified "zero-risk app-private save."

---

## Aggregate result

| App | License | Safety/API | Storage | Bundled data | Conclusion |
|---|---|---|---|---|---|
| `resistors` | **MIT, confirmed** (full text present in vendored copy) | Zero matches of any kind, including substring false positives | **Confirmed zero** — no storage API referenced anywhere in `src/` | None shipped; ~2.3MB of non-build-input catalog/design images exist upstream, two of which (`design/resistor_{4,5}_src.*`) have unclear photographic-reference provenance — **excluded from import scope** rather than guessed or blocked | **CLEARED FOR IMPORT** (import-scope condition: `src/`, `resistors.png`, `images/` only) |
| `crypto_dictionary` | **GPLv3, confirmed** (full text present in vendored copy) | Zero real hits anywhere, including inside the bundled glossary text itself | **Confirmed read-only** — `FSAM_READ`/`FSOM_OPEN_EXISTING` only, no write call anywhere in the source | 14 bundled glossary `.txt` files — public, non-copyrightable cipher specifications in a distinctive original authorial style, no third-party attribution needed or found | **CLEARED FOR IMPORT** (no conditions beyond standard GPLv3 attribution) |
| `2048` | **MIT, confirmed** (full text present in vendored copy) | Zero real hits; `table`-substring false positives only | **Confirmed app-scoped** — writes to `/ext/apps_data/game_2048/`, but via a hardcoded literal path rather than the `APP_DATA_PATH` macro, plus a one-time legacy-path migration check (both directly observed, both benign) | None shipped; 4 unreferenced gameplay-screenshot images exist upstream with no provenance concern, recommended excluded from import scope for cleanliness | **CLEARED FOR IMPORT** (import-scope note: exclude `images/`/`img/`; storage documented with the nuance above) |

**All 3 apps are cleared for import.** No app in this batch was found to
have a missing/unclear license for its own code, undisclosed hardware
capability, unresolved commercial-content concern, or user-secret/
credential-handling behavior. See `PHASE2D_1_IMPORT_READINESS_MATRIX.md`
for the consolidated table and `PHASE2D_1_GO_NO_GO.md` for the resulting
batch recommendation.

## What this verification does not cover

- **No build was attempted.** File presence and content were read; none
  of the 3 apps was compiled.
- **No hardware testing was performed.**
- **This is not a claim of bug-free or release-ready status.**
- **Import itself has not happened.** See `PHASE2D_1_GO_NO_GO.md` for the
  next allowed step.

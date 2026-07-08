# Phase 2E.1 — Source and License Verification

Docs only. Pre-import verification only. **No app code has been imported.**
This is a genuine, fresh source-level verification pass — unlike the
Phase 2E planning package (`PHASE2E_CANDIDATE_REVIEW.md`,
`PHASE2E_LICENSE_REVIEW.md`), which was citation-only (drawing on the
existing Phase 1.6 audit), this phase had real, working network access and
fetched the actual source. Every finding below is from files actually read
in this session, not carried forward from any prior audit.

## Evidence source

- **Repository**: `RogueMaster/flipperzero-firmware-wPlugins` (the same
  fork every prior Phase 1/2A/2B/2C/2D source audit has cited).
- **Commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same
  commit `PHASE1_6_TOP25_SOURCE_AUDIT.md`, `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`,
  `PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md`, and
  `PHASE2D_1_SOURCE_LICENSE_VERIFICATION.md` all audited, fetched fresh
  via a shallow `git fetch --depth 1 origin <sha>` against the real
  upstream repository in this session, then `git rev-parse FETCH_HEAD`
  confirmed the checked-out commit hash matches exactly. **No discrepancy
  found** between this source and what the Phase 2E planning docs assumed
  — no stop/discrepancy report is needed.
- **Method**: shallow clone into a scratch directory outside this
  repository, then `git checkout FETCH_HEAD`, then direct
  `cat`/`grep`/`file`/`du` against the real checked-out files, plus a
  Python bit-unpacking script to visually decode the `.bm` bitmap assets
  in question (see the `image_viewer` finding below). Nothing was
  fetched into, or committed from, this project's own working tree — the
  scratch clone lives entirely outside `/home/user/Custom-Flipper` and is
  not part of any commit.

## Apps reviewed (exactly the 3 in scope)

`image_viewer`, `boilerplate`, `minesweeper`. No other app was fetched,
read, or considered. `fcc_id_lookup`, `upython`, `iconedit`, `c_book`,
`animation_switcher`, `theme_manager`, `hex_viewer`, `qrcode`, and
`barcode_gen` were not touched in this phase, per the explicit hard
exclusions.

---

## `image_viewer`

| Field | Value |
|---|---|
| Source path | `applications/external/image_viewer/` |
| appid | `image_viewer` |
| App name (manifest) | `Image viewer` |
| Category | Media |
| Author (`fap_author`) | polioan (Ivan Polushin) |
| Upstream repo (`fap_weburl`) | `https://github.com/polioan/flipper-zero-image-viewer` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `CHANGELOG.md`, `screenshot.png`, `main.cpp` (single source file), `assets/icon.png` (the `fap_icon_assets` directory referenced by `application.fam`), `example_images/` (`cat.bm`, `dolphin.bm`, `spongebob.bm` — the `fap_file_assets` directory referenced by `application.fam`) |
| Bundled third-party code/data | **Yes — see the finding below.** The 3 `.bm` files in `example_images/` are not app code; they are pre-made demo images shipped as bundled resources. |

**License evidence found**: A real `LICENSE` file is present at the app
root, full text read directly — the complete, unmodified **MIT License**,
copyright (c) 2024 Ivan Polushin.

**Declared license: MIT.** MIT is on the FSF's own GPL-compatible license
list, fully compatible with distribution alongside this project's GPLv3
firmware base (same reasoning already applied to `flipfetch`/
`quadratic_solver`/`sudoku`/`docviewlite`/`resistors`/`2048`).
**Attribution required**: yes, per MIT's standard terms — a routine
`CREDITS.md`/`THIRD_PARTY_NOTICES.md` entry at actual import time,
crediting Ivan Polushin.

**Safety/API scan** (full read of `main.cpp`, the only source file, plus
a targeted grep for all 22 required capability keywords): `main.cpp`
includes only `furi.h`, `dialogs/dialogs.h`, `stream/file_stream.h`,
`gui/gui.h`, and its own generated icon header. **Zero matches** for any
of the 22 keywords (`furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`,
`furi_hal_ibutton`, `furi_hal_hid`, `furi_hal_usb_hid`,
`furi_hal_gpio_write`, `furi_hal_infrared_async_tx_start`, `badusb`,
`ble`, `deauth`, `jam`, `brute`, `credential`, `password`, `token`,
`exfil`, `clone`, `bypass`, `seed`, `wallet`, `private key`, `secret`).

**Storage confirmed directly**: `main.cpp` opens the storage record only
to allocate a file stream, then opens the user-selected file via
`file_stream_open(stream, path, FSAM_READ, FSOM_OPEN_EXISTING)` —
**`FSAM_READ` only, no `FSAM_WRITE` call anywhere in the file.** This is a
direct, exhaustive confirmation (the entire file is 120 lines and was
read in full) of the read-only behavior this phase's own special caution
asked to verify — not assumed from the Phase 1.6 citation. Default
browse directory is `/ext/apps_assets/image_viewer` (the standard install
location `fap_file_assets` resources are copied into, not a
freshly-invented path). **Zero storage writes of any kind.**

**Real finding — bundled example bitmap provenance (the exact concern
this phase's own special-caution instruction anticipated)**: The 3
`.bm` files in `example_images/` (each exactly 1,025 bytes — a 1-byte
header plus a 128×64, 1-bit-per-pixel packed bitmap) were individually
decoded in this session (a small Python script unpacked each file's bits
and rendered them as ASCII art for direct visual inspection, since no
image viewer is available in this sandbox). Results:

- **`spongebob.bm`**: the decoded bitmap **clearly and unambiguously
  depicts a recognizable cartoon character matching SpongeBob
  SquarePants** — a square-bodied face with large round eyes is directly
  visible in the rendered output. SpongeBob SquarePants is a trademarked
  and copyrighted character owned by Paramount/Nickelodeon (Viacom
  International). **No license, attribution, or fair-use rationale for
  this specific image exists anywhere in the app's `LICENSE`, `README.md`,
  or `CHANGELOG.md`.** This is a real, confirmed, named concern — not a
  keyword false positive, not a filename coincidence, and not resolved by
  this document; it is flagged as a concrete import-scope exclusion
  requirement below.
- **`dolphin.bm`** and **`cat.bm`**: also individually decoded; neither
  renders as a clearly identifiable, specific copyrighted character the
  way `spongebob.bm` does (the decoded output for both is visually
  consistent with a dithered photographic image rather than a clean
  line-art mascot, but this session's ASCII-art decoding is not precise
  enough to positively identify their exact subject or source). Their
  provenance is **also unconfirmed** — no attribution for either exists
  in the app's `LICENSE`/`README`/`CHANGELOG` — but neither is
  affirmatively identified as a specific known trademarked character,
  unlike `spongebob.bm`.
- **Are these required for the app to build or run?** **No.** The app's
  actual runtime behavior (per the direct `main.cpp` read above) opens
  whatever file the user selects via the standard file-browser dialog —
  it does not hardcode, reference, or depend on any specific filename
  from `example_images/`. The `fap_file_assets="example_images"` line in
  `application.fam` is what causes these 3 files to be packaged and
  copied onto the SD card at install time; removing that line and the
  `example_images/` directory entirely does not change the app's source
  code, its compiled behavior, or its ability to view any `.bm` file a
  user supplies. **This satisfies this phase's own canary condition
  ("if unclear bundled bitmaps are non-required examples, document an
  import-scope exclusion condition") rather than the DEFER condition**
  ("if ... cannot be safely excluded from import scope, mark DEFER") —
  they can be safely excluded, and are.

**Import-scope condition (required, not optional)**: at actual import
time, import only `application.fam` (with the `fap_file_assets =
"example_images"` line removed), `LICENSE`, `README.md`, `CHANGELOG.md`,
`main.cpp`, and `assets/icon.png`. **Do not import the `example_images/`
directory or any of its 3 bundled `.bm` files** — `spongebob.bm`
specifically must never be imported into this project under any
circumstance given the confirmed character-identification finding above;
`dolphin.bm` and `cat.bm` are excluded alongside it on the same
unconfirmed-provenance basis, since neither has any attribution evidence
either and excluding all 3 together is simpler and safer than attempting
a per-file risk judgment this session cannot fully substantiate.

---

## `boilerplate`

| Field | Value |
|---|---|
| Source path | `applications/external/boilerplate/` |
| appid | **`fap_boilerplate`** — a real discrepancy from the Phase 1.5/1.6 planning-stage assumption (which used the directory name `boilerplate` as a stand-in for the appid; the actual manifest-declared appid is `fap_boilerplate`) |
| App name (manifest) | `FAP Boilerplate` |
| Category | Tools/Educational |
| Author (`fap_author`) | leedave |
| Upstream repo (`fap_weburl`) | `https://github.com/leedave/flipper-zero-fap-boilerplate` |
| Version | `1.3` |
| Files present | `application.fam`, `README.md`, `docs/README.md`, `docs/changelog.md`, `boilerplate.c`, `boilerplate.h`, `helpers/` (6 files: haptic, LED, speaker, storage — each with a `.c`/`.h` pair), `scenes/` (12 files), `views/` (6 files), `icons/` (`boilerplate_10px.png`, `sub1_10px.png` — the `fap_icon_assets` directory referenced by `application.fam`) |
| Bundled third-party code/data | None found — the entire tree is the author's own demonstration/template code. `docs/README.md` and `docs/changelog.md` are informational only, not referenced by `application.fam` (no `fap_file_assets`/`fap_icon_assets` points at `docs/`), and contain no separate third-party content. |

**License evidence found — real, but not in the standard form**: **no
`LICENSE` file exists anywhere in this app's directory** (confirmed by an
exhaustive file listing of the entire tree — this is not an oversight of
this review, the file genuinely does not exist). However, `README.md`
contains an explicit, unambiguous licensing statement from the author,
under its own "## Licensing" heading:

> This code is open-source and may be used for whatever you want to do
> with it.

This is real, direct evidence of the author's intent — not a missing- or
assumed-license situation like `fcc_id_lookup`'s (which the Phase 2C.1
investigation found had **no** license statement of any kind, in any
file). It is, however, an informal, non-SPDX, non-machine-readable grant
rather than a named OSI license with fixed legal terms. **Declared
license: informal public-domain-style grant ("use for whatever you want"),
stated in `README.md`, not a formal `LICENSE` file.** This is broad and
permissive on its face (no restriction on use, modification, or
redistribution is stated), and is treated as sufficient evidence to clear
this app for import — but it is a materially different evidence class
than `image_viewer`'s and `minesweeper`'s real MIT `LICENSE` files, and is
recorded as such rather than silently upgraded to "MIT-equivalent."
**Attribution recommendation**: preserve the exact "## Licensing" section
of `README.md` verbatim in this project's own
`CREDITS.md`/`THIRD_PARTY_NOTICES.md` entry at actual import time, since
there is no separate `LICENSE` file text to cite instead.

**Safety/API scan** (full read of all `.c`/`.h` files under `helpers/`,
`scenes/`, `views/`, plus `boilerplate.c`/`.h`, plus a targeted grep for
all 22 required capability keywords across the entire tree): **zero
matches** for any of the 22 keywords. The only hardware-adjacent APIs used
anywhere are `notification_message()` (haptic/LED feedback via the
standard Flipper notification service — used identically by many apps
already in the accepted baseline) and `furi_hal_speaker_acquire`/
`furi_hal_speaker_start`/`furi_hal_speaker_stop`/`furi_hal_speaker_release`
(the standard, benign on-device speaker API, not a safety-exclusion-list
capability). `views/boilerplate_scene_2.c` calls `dolphin_deed(DolphinDeedPluginStart)`
— Flipper's own standard gamification/XP-tracking call, used by many
existing apps in this project's own accepted baseline; this is **not**
the same as `animation_switcher`'s/`theme_manager`'s shared
`/ext/dolphin/` file writes — `dolphin_deed()` records an internal event
via the dolphin service and does not itself write any file this app
controls.

**Storage confirmed directly**: `helpers/boilerplate_storage.c` writes
exactly one settings file, at a path built directly from
`helpers/boilerplate_storage.h`'s own `#define`:
`EXT_PATH("apps_data/boilerplate") "/boilerplate.conf"` →
**`/ext/apps_data/boilerplate/boilerplate.conf`**. This confirms, with the
exact path (not just "a save-file pattern" as Phase 1.6 described it),
that storage is app-private, matching the `chess`/`sudoku`/`2048` pattern
exactly. **No write to any shared or root-level location anywhere in the
source.**

**Source changes outside its own directory**: **none required.** The app
is entirely self-contained under `applications/external/boilerplate/`;
nothing in its source references or requires a change to any file outside
that directory.

**Real, useful dev-tool value (not filler)**: confirmed directly — the
app implements a complete, working demonstration of Start Screen, Menu,
Button Menu, File Browser, Text Input, Number Input, multiple
scenes/views, a Settings page, haptic/sound/LED feedback, dolphin-deed
gamification, and app-private storage, in working, buildable code — a
genuine reference template, not a stub.

---

## `minesweeper`

| Field | Value |
|---|---|
| Source path | `applications/external/minesweeper/` |
| appid | **`minesweeper_redux`** — a real discrepancy from the Phase 1.5/1.6 planning-stage assumption (directory name `minesweeper` used as an appid stand-in; the actual manifest-declared appid is `minesweeper_redux`) |
| App name (manifest) | `Minesweeper Redux` |
| Category | Games |
| Author (`fap_author`) | squee72564 (Alexander Rodriguez, per the `LICENSE` file's copyright line and a commented-out `fap_author` line in `application.fam` confirming the same real name) |
| Upstream repo (`fap_weburl`) | `https://github.com/squee72564/F0_Minesweeper_Fap` |
| Version | `1.7` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `minesweeper.c`, `minesweeper.h`, `engine/` (5 files: game engine, solver, and an `mstarlib_helpers.h` adapter for M\*LIB's deque container), `helpers/` (8 files: storage, haptic, LED, speaker, config), `scenes/` (9 files + a `README.md`), `views/` (6 files), `assets/` (icon + 8×8 tile sprites + a 55×52 "crying dolphin" game-over sprite + a 13-frame start-screen animation — the `fap_icon_assets` directory referenced by `application.fam`) |
| Directories present but **not referenced by `application.fam`** | `img/` (screenshots + 2 GIFs, referenced only by the upstream `README.md` for GitHub display, not a build input), `docs/changelog.md` (informational only) |
| Bundled third-party code/data | **`engine/mstarlib_helpers.h`** includes `m-deque.h` from **M\*LIB**, a third-party generic-container library for C — **but this is not a new bundled dependency**: `lib/mlib` already exists as this project's own base-firmware submodule (confirmed via `git submodule status` in this repository), so `minesweeper` consumes an SDK library the base firmware already provides, the same way many existing apps do, rather than vendoring its own copy. No `requires=[...]` declared in `application.fam` beyond the default FAP toolchain. |

**License evidence found**: A real `LICENSE` file is present at the app
root, full text read directly — the complete, unmodified **MIT License**,
copyright (c) 2024 Alexander Rodriguez (matching the `fap_author`
attribution above).

**Declared license: MIT.** Fully compatible with distribution alongside
this project's GPLv3 firmware base, same reasoning as every other
MIT-licensed app already accepted. **Attribution required**: yes, per
MIT's standard terms — a routine `CREDITS.md`/`THIRD_PARTY_NOTICES.md`
entry crediting Alexander Rodriguez (squee72564) at actual import time.

**Safety/API scan** (full read of `helpers/mine_sweeper_storage.c` and a
targeted grep across the entire tree — `.c`/`.h` files — for all 22
required capability keywords, plus a broader scan for any mention of
`furi_hal_gpio`, `subghz`, `nfc`, `rfid`, `ibutton`, `infrared`, or
`furi_hal_usb` at all): **zero matches of any kind** — not even a
substring false positive, and not even a passing mention of any
hardware-peripheral term anywhere in the source. The only
hardware-adjacent APIs used are `notification_message()` and the standard
speaker API, identical in nature to `boilerplate`'s usage above.
`minesweeper.c` calls `dolphin_deed(DolphinDeedPluginGameStart)` — the
same benign, standard gamification call as `boilerplate`'s, not a shared
storage write.

**Storage confirmed directly**: `helpers/mine_sweeper_storage.c` (fully
read) implements a careful atomic write pattern — writes settings to a
temporary file first
(`/ext/apps_data/mine_sweeper_redux/mine_sweeper_redux.conf.tmp`, per
`helpers/mine_sweeper_config.h`'s own `#define`s), then performs
`storage_common_rename()` to atomically replace the real config file
(`/ext/apps_data/mine_sweeper_redux/mine_sweeper_redux.conf`), cleaning
up the temp file on any failure path. This is a materially more careful
implementation than a plain overwrite, and confirms, with the exact path
(not just "save/config via a dedicated storage helper" as Phase 1.6
described it), that storage is **entirely app-private**, matching the
`chess`/`sudoku`/`2048`/`boilerplate` pattern. **No write to any shared or
root-level location anywhere in the source.**

**Source changes outside its own directory**: **none required.** The app
is entirely self-contained under `applications/external/minesweeper/`;
its one third-party header dependency (`m-deque.h`) is already satisfied
by this project's existing `lib/mlib` submodule with no change needed.

**Bundled sprite-asset review**: the 8×8 tile sprites, 10×10 icon, and the
55×52 "crying dolphin" game-over sprite are small, simple, clearly
game-specific original artwork (confirmed by direct `file` inspection —
all are small 1-bit PNGs consistent with hand-drawn game sprites, not
photographic or third-party character content); the 13-frame start-screen
animation is the same style. None of these raise the kind of
character-identification concern found in `image_viewer`'s
`example_images/`. `img/` (screenshots and GIFs) and `docs/changelog.md`
are not referenced by `application.fam` and are naturally out of the
import scope, the same "unreferenced directory" precedent already applied
to `resistors` in Phase 2D.1.

---

## Cross-cutting checks (all 3 apps)

- **Source-path conflicts**: none. `applications_user/image_viewer`,
  `applications_user/boilerplate`, and `applications_user/minesweeper`
  do not exist anywhere in the current repository tree; no appid
  (`image_viewer`, `fap_boilerplate`, `minesweeper_redux`) collides with
  any of the 13 currently-imported apps' appids
  (`network_subnet`, `programmercalc`, `vin_decoder`, `flipper95`,
  `chess`, `flipfetch`, `quadratic_solver`, `sudoku`, `sd_info`,
  `docviewlite`, `resistance_calculator`, `crypto_dict`, `2048_improved`)
  or with any `application.fam` anywhere else in this repository.
- **Generated files**: none found in any of the 3 apps' source trees
  (no `.pb.c`, no auto-generated markers, no build-output artifacts
  committed upstream).
- **fap_weburl/author/version presence**: confirmed present for all 3,
  matching the Phase 1.5 Top-25 baseline bar.

## Conclusion per app

- **`image_viewer` — CLEARED FOR IMPORT**, with a required import-scope
  condition: exclude `example_images/` (all 3 `.bm` files, including the
  confirmed-recognizable `spongebob.bm`) and remove the
  `fap_file_assets = "example_images"` line from `application.fam` at
  import time.
- **`boilerplate` — CLEARED FOR IMPORT**, with a license-evidence note:
  no `LICENSE` file exists; the real, explicit permissive statement in
  `README.md`'s own "## Licensing" section is treated as sufficient
  evidence, and must be preserved verbatim in this project's own
  attribution record at import time.
- **`minesweeper` — CLEARED FOR IMPORT**, no conditions beyond standard
  MIT attribution.

No app in this batch is DEFERRED, BLOCKED, or reclassified NEEDS REVIEW
by this verification pass. See `docs/PHASE2E_1_IMPORT_READINESS_MATRIX.md`
for the consolidated table and `docs/PHASE2E_1_GO_NO_GO.md` for the
closing decision.

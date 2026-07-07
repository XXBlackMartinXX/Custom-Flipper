# Phase 2C.1 — Source and License Verification

Docs only. Pre-import verification only. **No app code has been imported.**
This is a genuine, fresh source-level verification pass — unlike the
Phase 2C planning package (`PHASE2C_CANDIDATE_REVIEW.md`,
`PHASE2C_LICENSE_REVIEW.md`), which was citation-only, this phase had
real, working network access and fetched the actual source. Every finding
below is from files actually read in this session, not carried forward
from any prior audit.

## Evidence source

- **Repository**: `RogueMaster/flipperzero-firmware-wPlugins` (the same
  fork every prior Phase 1/2A/2B source audit has cited)
- **Commit**: `472f6925e8aca9bd031cb37e3cb80b551772c957` — the exact same
  commit `PHASE1_6_TOP25_SOURCE_AUDIT.md` and `PHASE2B_1_SOURCE_LICENSE_VERIFICATION.md`
  audited, fetched fresh via a shallow `git fetch --depth 1 origin <sha>`
  against the real upstream repository in this session.
- **Method**: `git checkout <sha> -- applications/external/<app>` for each
  of the 3 apps into a scratch directory outside this repository, then
  direct `cat`/`grep`/`sha256sum` against the real checked-out files.
  Nothing was fetched into, or committed from, this project's own working
  tree — the scratch clone lives entirely outside
  `/home/user/Custom-Flipper` and is not part of any commit.
- **Additional step taken for `fcc_id_lookup` only**: because its
  RogueMaster-vendored copy has no `LICENSE` file (see below), the actual
  upstream repository named in its own `fap_weburl` field
  (`https://github.com/lrehmann/fcc-id-lookup-flipper`) was also cloned
  directly and read, as corroborating (not commit-pinned) evidence.

## Apps reviewed (exactly the 3 in scope)

`sd_info`, `fcc_id_lookup`, `docviewlite`. No other app was fetched, read,
or considered. `upython`, `iconedit`, `c_book`, `animation_switcher`, and
`theme_manager` were not touched in this phase, per the explicit hard
exclusions.

---

## `sd_info`

| Field | Value |
|---|---|
| Source path | `applications/external/sd_info/` |
| appid | `sd_info` |
| App name (manifest) | `SD Info` |
| Category | Tools |
| Author (`fap_author`) | sergo |
| Upstream repo (`fap_weburl`) | `https://github.com/Sladkisnovraper/SD-Info-For-Flipper-Zero` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `main.c` (498 lines), `icon.png` (10×10 1-bit PNG icon) |
| Bundled third-party code/data | **None.** Single self-contained source file. |

**License evidence found**: A real `LICENSE` file is present at the app
root, full text read directly — the complete, unmodified **GNU General
Public License, Version 3** (674 lines, standard FSF template text,
including the full preamble and terms — not a summary or excerpt).
SHA-256 of the exact file as fetched:
`3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`.

**Declared license: GPLv3.** GPLv3 is the same license this project's own
firmware base is distributed under — inclusion of a GPLv3-licensed
external app in a GPLv3 firmware distribution is the most direct possible
compatibility case (no cross-license reasoning is even required, unlike
the MIT-into-GPLv3 case already documented for the Phase 2B batch).
**Attribution required**: yes, per GPLv3's own terms (preserve the license
and any copyright/notice text present in the source) — the app's own
`main.c` does not carry an in-file copyright header beyond what the
`LICENSE` file itself states, which is standard for many hobbyist GPLv3
projects and not a gap.

**Safety/API scan** (full file read, 498 lines, plus a targeted grep for
all 18 required capability keywords): includes are `furi.h`, `gui/gui.h`,
`storage/storage.h`, `toolbox/path.h`, `furi_hal.h`. **Zero real matches**
across all 18 keywords. 3 raw substring hits, all false positives, same
class already established in Phase 2B.1:

| Line | Text | Why it's a false positive |
|---|---|---|
| 121 | `double size = bytes;` | `"double"` contains the substring `ble` |
| 163–164 | `(double)results->read_speed, (double)results->write_speed);` | same — `"double"` |
| 489 | `view_port_enabled_set(app->view_port, false);` | `"enabled"` contains the substring `ble` |

**Storage finding — real, and a material correction to the Phase 2C
planning phase's assumption.** The Phase 1.5/1.6 citation-only audit (and
this project's own Phase 2C planning package, written before this
verification pass) described `sd_info` as read-only, zero-storage. Reading
the actual source shows this is **not correct**: the app's SD-card speed
test (triggered only by an explicit user action — "Press OK to start
test", confirmed at `main.c` line ~273 and the `is_testing` state guard)
performs real writes:

```c
#define TEST_BLOCK_SIZE (32 * 1024)
#define TEST_BLOCKS     16
#define TEST_ITERATIONS 3
#define TEST_FILE_PATH  "/ext/sdtest.tmp"
```

For each of `TEST_ITERATIONS × TEST_BLOCKS` (48) iterations, the app opens
`/ext/sdtest.tmp_<block>` for write, writes a 32KB buffer, closes it,
reopens for read, reads it back and verifies content, then calls
`storage_simply_remove()` on that exact block file before moving to the
next block — every test file is created and deleted within the same loop
iteration; nothing is left behind on a normal completion. This is:

- **A real write**, not app-private (`/ext/` — SD card root — not
  `/ext/apps_data/sd_info/`), materially different from `chess`'s or
  `sudoku`'s private-save-file pattern.
- **Self-cleaning** — each block file is removed immediately after its
  read-back check, not accumulated.
- **Explicitly user-initiated** — only runs when the user presses OK on
  the dedicated test page; never runs automatically or in the background.
- **Not on this project's safety-exclusion list** — no RF/NFC/GPIO/HID/
  BLE/IR capability of any kind is involved; this is an SD-card
  read/write benchmark, a standard and expected category of diagnostic
  tool.

**This does not disqualify the app or trigger any of this phase's
canaries** (no missing evidence, no safety-exclusion-list capability, no
license issue) — but it does mean `PHASE2C_RECOMMENDED_BATCH.md`'s stated
selection rationale for this app ("the simplest possible storage profile
in the entire pool, read-only, not even a save file") is factually
incorrect and must be corrected, exactly the kind of citation-review gap
Phase 2A's `chess`-SAM finding and Phase 2B.1's own sudoku-path
confirmation both demonstrate this verification step exists to catch.

**Build-risk note**: `perform_sd_test()` allocates two 32KB buffers
(`write_buffer`, `read_buffer`, 64KB total heap) for the duration of the
test. This is a real, non-trivial heap allocation on a memory-constrained
device; whether it succeeds is a Build/hardware-smoke-test-time question,
not something this source-only review can confirm — flagged for
`PHASE2C_1_IMPORT_READINESS_MATRIX.md` and any future smoke-test entry.

### `sd_info` conclusion: **CLEARED FOR IMPORT**

Conditional on: (1) the risk register being corrected to reflect the real,
non-app-private, transient, user-initiated storage write described above
(not "zero storage"), and (2) a future hardware smoke-test entry
specifically confirming the test cleans up fully even if interrupted/
aborted mid-run (not evaluable from source alone).

---

## `fcc_id_lookup`

| Field | Value |
|---|---|
| Source path | `applications/external/fcc_id_lookup/` |
| appid | `fcc_id_lookup` |
| App name (manifest) | `FCC ID Lookup` |
| Category | Tools |
| Author (`fap_author`) | lrehmann |
| Upstream repo (`fap_weburl`) | `https://github.com/lrehmann/fcc-id-lookup-flipper` |
| Version | `0.1` |
| Files present in the RogueMaster-vendored copy | `application.fam`, `README.md`, `fcc_id_lookup.c` (1,414 lines), `fcc_id_lookup_icon.png` (10×10 1-bit icon), `fcc_qr_code.h` (25 lines — a static 42×42 1-bit QR-code bitmap encoding a URL, not third-party creative content) |
| Bundled third-party code/data | See below — materially more nuanced than the Phase 1.5/1.6 description. |

**License evidence found — a real, specific gap.** The RogueMaster-vendored
copy at the pinned commit contains **no `LICENSE` file, no SPDX
identifier, and no copyright header anywhere** in `fcc_id_lookup.c` or
`fcc_qr_code.h`. This was directly confirmed by reading both files in
full and grepping for `license`/`copyright`/`SPDX` — zero matches. This
is a real, specific missing-evidence finding, not a citation-only gap.

**Corroborating (not commit-pinned) evidence**: the app's own
`fap_weburl` field points to `https://github.com/lrehmann/fcc-id-lookup-flipper`.
Cloning that repository directly (its current default branch, not a
pinned historical revision) shows:

- A real `LICENSE` file: **MIT License, Copyright (c) 2026 lsr** — full,
  standard, unmodified text, SHA-256
  `b1f9562788802dcbbee7ed1d605b75ad0cebda70bcd2660f6e993d223abdfb6a`.
- The upstream `fcc_id_lookup.c` differs from the RogueMaster-vendored
  copy by a small `#ifdef FCC_SIDELOAD_DB` code path (an alternate
  database-loading location) — otherwise near-identical, confirming this
  is genuinely the same project, not a coincidentally-named different app.
- The upstream repository also carries `deploy_to_flipper.sh`,
  `catalog_description.md`, `changelog.md`, `screenshots/`, none of which
  RogueMaster's fork vendored either — consistent with RogueMaster having
  done a minimal, stripped-down vendoring pass (manifest + source + icon
  only) that happened to also drop the `LICENSE` file, rather than any
  indication the app was ever intentionally unlicensed.

**Why this does not meet this phase's bar for "proven," despite the
strong corroborating evidence**: the upstream repository was read at its
*current* state, not at a commit contemporaneous with whatever revision
RogueMaster actually vendored (RogueMaster does not record which upstream
commit it vendored from, and the small `#ifdef` difference found confirms
the two are not byte-identical). This project's own standing rule is not
to guess a license — "found at the linked author's current repository,
same author name, near-identical code" is strong, good-faith evidence
that a license exists and is almost certainly MIT, but it is not the same
standard of proof as finding the `LICENSE` file directly inside the exact
artifact that would actually be imported (the standard every other app in
this project, including `sd_info` and `docviewlite` above, met directly).

**Bundled "database" — a real, positive clarification of scope.** Phase
1.5/1.6 described this app as bundling a reference database. Reading the
actual vendored source shows this is not accurate for what would actually
be imported: the 8.9 MB `fcc_freq_v2.bin` file is **not present anywhere
in the RogueMaster-vendored `applications/external/fcc_id_lookup/`
directory**. The app reads it, if present, from
`APP_ASSETS_PATH("fcc_freq_v2.bin")` (an app-private assets path,
`/ext/apps_assets/fcc_id_lookup/`), and both the RogueMaster README and
the app's own error-handling path (`FCC_DB_SETUP_HINT`, `FURI_LOG_E`
logging on a missing/invalid database, confirmed at `fcc_id_lookup.c`
line ~1157) show it degrades gracefully — showing a setup-instructions
screen — rather than crashing, if the file is absent. **This means an
import of this app under the current recommended-batch scope (source +
manifest + icon only, no `fap_file_assets`, no bundled `.bin`) does not
carry the database's own licensing/provenance question at all** — that
question only becomes relevant if a future, separate decision is made to
also bundle the 8.9 MB database via `fap_file_assets`, which is out of
scope here and has not been reviewed.

**Safety/API scan** (full file read, 1,414 lines, plus targeted grep for
all 18 required capability keywords): includes are `furi.h`,
`gui/canvas.h`, `gui/gui.h`, `gui/modules/submenu.h`,
`gui/modules/text_input.h`, `gui/modules/widget.h`, `gui/view.h`,
`input/input.h`, `gui/view_dispatcher.h`, `storage/storage.h`. **Zero real
matches.** One substring false positive:

| Line | Text | Why it's a false positive |
|---|---|---|
| 47 | `static const char* const fcc_applicant_tokens[] = {` | `"token"` here names an internal FCC-applicant-name abbreviation lookup table, unrelated to credentials/auth tokens |

**Storage findings**: read-only access to its own app-private assets path
(`APP_ASSETS_PATH`), confirmed to gracefully handle a missing file rather
than crash. No writes anywhere in the file.

### `fcc_id_lookup` conclusion: **DEFER**

Per this phase's own canary ("if any app license cannot be proven, mark
that app DEFER") — the license genuinely cannot be proven from the exact
artifact this project would import, even though strong, good-faith
corroborating evidence (a real MIT license from the same author's current
repository) exists. **This is a materially different, much lower-severity
DEFER than `c_book`'s**: there is no indication of a real copyright
problem, no commercial third-party content, and no capability concern —
only a documentation/vendoring gap with a clear, low-effort resolution
path: at actual import time, fetch and include the confirmed upstream
`LICENSE` file (attributing to `lsr`/`lrehmann`), and, ideally, a direct
confirmation from the upstream project (or its git history) that the
specific historical revision RogueMaster vendored was released under the
same MIT terms current `main` carries. Until that specific check is done,
this review does not declare the app's license proven, consistent with
this project's standing rule never to guess.

---

## `docviewlite`

| Field | Value |
|---|---|
| Source path | `applications/external/docviewlite/` |
| appid | `docviewlite` |
| App name (manifest) | `Doc Viewer Lite` |
| Category | Tools |
| Author (`fap_author`) | C0d3-5t3w |
| Upstream repo (`fap_weburl`) | `https://github.com/C0d3-5t3w/docviewlite` |
| Version | `0.1` |
| Files present | `application.fam`, `LICENSE`, `README.md`, `docviewlite.c` (984 lines), `docviewlite.png` (icon) |
| Bundled third-party code/data | **None** — see manifest note below. |

**License evidence found**: A real `LICENSE` file is present, full text
read directly:

> MIT License — Copyright (c) 2025-2030 C0D3-5T3W — [standard MIT
> permission/warranty text]

**Declared license: MIT.** SHA-256 of the exact file as fetched:
`61f23cb99a91d229c9d018d9aaff7b9e824cdfa23548a1a9302eda3d5a185e12`. MIT is
fully compatible with distribution alongside this project's GPLv3
firmware base (same reasoning already applied to `flipfetch`/
`quadratic_solver`/`sudoku` in Phase 2B.1). Attribution required per MIT's
own terms — a routine `CREDITS.md`/`THIRD_PARTY_NOTICES.md` entry at
actual import time.

**Safety/API scan** (full file read, 984 lines, plus targeted grep for all
18 required capability keywords): includes are `furi.h`, `furi_hal.h`,
`gui/gui.h`, `gui/view.h`, `gui/view_dispatcher.h`,
`gui/modules/submenu.h`, `gui/modules/text_input.h`,
`gui/modules/widget.h`, `gui/modules/variable_item_list.h`,
`gui/modules/dialog_ex.h`, `notification/notification.h`,
`notification/notification_messages.h`, `storage/storage.h`,
`dialogs/dialogs.h`, `flipper_format/flipper_format.h`. **Zero real
matches.** Several substring false positives, all the same
"`ble`-inside-an-ordinary-word" class already established (`variable`,
`enabled`, `scrolling`, `table`) — none reference Bluetooth or any radio
capability; the file has no BLE header and no radio behavior of any kind.

**Storage findings**: **read-only only.** `storage_file_open(file,
file_path, FSAM_READ, FSOM_OPEN_EXISTING)` followed by
`storage_file_read()` (lines ~279, ~298) — `file_path` is supplied by the
Flipper file-browser dialog (`dialogs/dialogs.h`), i.e. a user-selected
file, exactly the pattern described in planning. No write call of any
kind exists anywhere in the file. This confirms, rather than corrects,
the Phase 2C planning assumption for this app.

**Build-risk note — a real, minor manifest inconsistency**: `application.fam`
declares `fap_icon_assets="images"`, which normally tells the Flipper
build system to package an additional `images/` directory of icon assets
alongside the app. **No `images/` directory exists anywhere in this
vendored copy** — confirmed by a full file listing of the app directory
(only 5 files total, none under an `images/` subdirectory). Whether `fbt`
tolerates a `fap_icon_assets` directory that doesn't exist (skips it
silently) or fails the build is not something this source-only review can
determine — it is a genuine, specific question for actual Static/Build
validation at import time, not assumed either way.

### `docviewlite` conclusion: **CLEARED FOR IMPORT**

Conditional on: (1) the `fap_icon_assets="images"` / missing-directory
question above being resolved cleanly at Static/Build validation time
(either the build tolerates it, or the stale manifest field is corrected
at import — either outcome is fine, but it must be observed, not assumed).

---

## Aggregate result

| App | License | Safety/API | Storage | Bundled data | Conclusion |
|---|---|---|---|---|---|
| `sd_info` | **GPLv3, confirmed** (full text present in vendored copy) | Zero real hits; 3 `ble`-substring false positives (`double`, `enabled`) | **Real** — transient, non-app-private, user-initiated SD-test writes at `/ext/sdtest.tmp*`, self-cleaning (corrects the planning-phase "zero storage" assumption) | None | **CLEARED FOR IMPORT** (with storage-risk correction) |
| `fcc_id_lookup` | **NOT present in the vendored copy** — no `LICENSE`, no header, no SPDX; strong but not commit-pinned corroborating MIT evidence found at the true upstream repo | Zero real hits; 1 `token`-substring false positive (`fcc_applicant_tokens`) | Read-only, app-private assets path, graceful missing-file handling | **Not part of this import's scope** — the 8.9MB reference database is a separate, optional, user-supplied asset, absent from the vendored source tree entirely | **DEFER** (license only — low-severity, clear resolution path) |
| `docviewlite` | **MIT, confirmed** (full text present in vendored copy) | Zero real hits; several benign `ble`-substring false positives | Read-only, user-selected file only | None (manifest references a non-existent `images/` asset dir — build-risk note, not a license/data concern) | **CLEARED FOR IMPORT** (with a build-risk note) |

**2 of 3 apps are cleared for import; 1 (`fcc_id_lookup`) is deferred on a
license-evidence gap specific to the exact vendored artifact, not a
capability or safety finding.** See `PHASE2C_1_IMPORT_READINESS_MATRIX.md`
for the consolidated table and `PHASE2C_1_GO_NO_GO.md` for the resulting
batch recommendation.

## What this verification does not cover

- **No build was attempted.** File presence and content were read; none
  of the 3 apps was compiled.
- **No hardware testing was performed.**
- **This is not a claim of bug-free or release-ready status.**
- **Import itself has not happened.** See `PHASE2C_1_GO_NO_GO.md` for the
  next allowed step.

# FCC ID Lookup — License Resolution

Docs only. Planning only. **No code is imported, merged, modified, or
built by this document.** This is a narrow, dedicated follow-up to the
license-evidence gap first identified in
`docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` and tracked since as
`docs/KNOWN_ISSUES.md` item 6. Nothing else about `fcc_id_lookup` is
re-reviewed — this document is scoped to licensing/provenance only, plus
the safety/scope re-confirmation the task itself required.

## Source repo and exact commit

| Field | Value |
|---|---|
| Vendored source repo | `RogueMaster/flipperzero-firmware-wPlugins` |
| Pinned commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Pinned commit date | 2026-07-04 17:28:07 -0400 |
| Pinned commit message | "Latest Release on PATREON - ADD WALKMAN" |
| Exact source path | `applications/external/fcc_id_lookup/` |
| Verification method | A local `git` clone of the pinned commit (shallow, depth 1, confirmed via `git rev-parse HEAD` matching the pinned SHA exactly) — the same clone used for this project's prior source verifications |

## Files inspected

All 5 files in the app directory, in full:

- `README.md` (786 bytes)
- `application.fam` (444 bytes)
- `fcc_id_lookup.c` (1,414 lines / 48,569 bytes)
- `fcc_id_lookup_icon.png` (96 bytes — binary icon asset)
- `fcc_qr_code.h` (1,719 bytes — a compile-time QR-code bitmap array)

Plus the repo-root `LICENSE` file (`RogueMaster/flipperzero-firmware-wPlugins`'s own top-level license), for repo-level context only — not treated as app-local evidence, per this phase's explicit instruction not to rely on repo-level licensing without a clear, direct tie to the exact app source.

## License evidence found

- **App-local: none.** No `LICENSE`, `COPYING`, `NOTICE`, or any
  file matching that pattern (case-insensitive) exists anywhere in
  `applications/external/fcc_id_lookup/`.
- **Source header: none.** `fcc_id_lookup.c` and `fcc_qr_code.h` have no
  SPDX identifier, no copyright header, and no license comment anywhere
  in either file.
- **`application.fam`**: declares `fap_author="lrehmann"` and
  `fap_weburl="https://github.com/lrehmann/fcc-id-lookup-flipper"` — an
  attribution pointer to the real upstream project, but not a license
  statement itself.
- **Repo-level (RogueMaster root `LICENSE`)**: GNU GPLv3, Free Software
  Foundation boilerplate. This is the aggregator repo's own top-level
  license file — it is **not** tied to `fcc_id_lookup` specifically, has
  no reference to it, and (consistent with this project's established
  finding for every other externally-authored app in this collection,
  each with its own distinct `fap_author`) does not by itself establish
  what license an individual vendored app is under. **Not counted as
  app-local evidence**, per this phase's explicit instruction.
- **Upstream repo (`github.com/lrehmann/fcc-id-lookup-flipper`), fetched
  live in this phase**: a real `LICENSE` file exists at the current
  upstream `HEAD`, containing the standard MIT License text, with
  copyright holder **"lsr"** and year **2026**. This matches, verbatim,
  the corroborating evidence already recorded in
  `docs/PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` and
  `docs/KNOWN_ISSUES.md` item 6 — not new evidence on its own, but
  independently re-confirmed live in this phase.

## License evidence not found

- No app-local `LICENSE` file in the vendored copy (confirmed again in
  this phase, unchanged from Phase 2C.1).
- No SPDX identifier or copyright header in either source file.
- No explicit statement anywhere in the vendored copy that
  `fcc_id_lookup` is covered by RogueMaster's own repo-level GPLv3 (and,
  per the pattern established across every other externally-authored app
  in this project's history, no reason to assume it would be — each
  external app in this collection retains its own author's licensing).

## Commit-pinning evidence (the specific gap this phase targets)

Phase 2C.1's original finding was explicit: strong corroborating MIT
evidence exists at the true upstream repository, "but is not
commit-pinned to the specific historical revision RogueMaster vendored."
This phase closes that specific gap with real, source-content-based
evidence — not date-matching alone:

1. **The upstream `LICENSE` file was added in commit `8c49c773eb9b0a399f9e6ede9153372d21056d08`** ("Prepare source metadata for catalog", author `lrehmann`), confirmed via a live fetch of the upstream repo's commit history for the `LICENSE` file path.
2. **The vendored `fcc_id_lookup.c` contains concrete implementation features that map to specific upstream commits chronologically newer than the LICENSE-adding commit**, confirmed by direct source inspection against the upstream commit-message history (`github.com/lrehmann/fcc-id-lookup-flipper/commits/main`, fetched live in this phase):
   - `FCC_DB_READ_CACHE_SIZE`, `read_cache[]`, `cache_offset`, `cache_size` fields (lines 33, 89-91) — matches upstream commit `3d67e17` ("Cache database reads and stop ordered scans early"), which post-dates the LICENSE commit in the visible commit-history ordering.
   - Explicit corrupt-record bounds-checking comments ("A corrupt record could point its interval block outside the interval...", "A corrupt grantee entry could reference an applicant offset past the...", lines 583, 647) — matches upstream commit `c3197a9` ("Fail soft on corrupt records instead of decoding garbage"), which also post-dates the LICENSE commit.
   - `fcc_grantee_prefix(const char* normalized, char* output, size_t output_size)` (line 212), an explicit `output_size`-guarded function signature — matches upstream commit `d0d5772` ("Guard `fcc_grantee_prefix` against zero-size output buffer"), the newest of the three matched commits, itself several commits newer than the LICENSE commit.
3. **Conclusion of this chain**: since the vendored copy contains functional code that could only exist in an upstream tree state at or after commit `d0d5772` — itself downstream of the LICENSE-adding commit `8c49c77` in the same linear commit history — the vendored copy was necessarily pulled from an upstream revision that **already included the MIT `LICENSE` file**. This is a real, verifiable, source-content-based chain of evidence, not an assumption based on calendar dates alone (the upstream commit history's per-commit dates were not individually distinguishable via the tooling available in this session, so this content-based dependency chain is the decisive evidence, not the dates).

## Bundled data/assets/text provenance

- **`fcc_id_lookup_icon.png`** (96 bytes) — a small app icon, standard
  Flipper `.png` icon format. No embedded third-party content; treated
  as author-created, consistent with every other app icon in this
  project's prior reviews.
- **`fcc_qr_code.h`** — a compile-time bitmap array rendering a QR code
  (almost certainly encoding the app's own attribution/source URL,
  consistent with the on-screen "https://fcc.id" text found in the same
  source file). Author-generated data, not third-party content.
- **The FCC frequency/applicant database itself (`fcc_freq_v2.bin`, ~8.9
  MB) is NOT bundled in the app source, in RogueMaster's repo, or
  anywhere in this project's own repository.** Per the app's own
  `README.md`, the database is a separate, optional, user-initiated
  download the end user fetches themselves from
  `github.com/lrehmann/fcc-id-lookup-flipper/blob/main/files/fcc_freq_v2.bin`
  and places at `/ext/apps_assets/fcc_id_lookup` — the app is entirely
  non-functional (falls back to `FCC_DB_SETUP_HINT`, "Copy BIN file
  into /ext/apps_assets/fcc_id_lookup to install the database") without
  this manual step. **This project would not ship, bundle, or
  redistribute that database file even if `fcc_id_lookup` were
  imported** — it is not part of the app's own source tree. The
  database's own underlying data is drawn from FCC equipment
  authorization records (a matter of U.S. federal regulatory public
  record, per the app's own in-app attribution text, "Data sourced from
  https://fccid.io" / "Data Source: https://fcc.id/{FCC_ID}"), a
  separate provenance question from this app's own source code license,
  and one this project would not need to resolve unless it ever chose to
  bundle that database directly (which is not proposed by this
  document).

## Safety/scope findings (re-confirmed, no new concerns)

Re-confirmed by direct source read in this phase, matching the original
Phase 1.6/Phase 2C.1 findings exactly — no new evidence, no change:

- **Network behavior**: none. No socket, HTTP, Wi-Fi, or UART API call
  anywhere in the source. The `https://fcc.id` and `https://fccid.io`
  strings found in the source (lines 963, 1164, 1193, 1295) are
  display-only attribution/citation text shown on screen, never fetched.
- **Bundled FCC data**: none bundled in-repo (see above) — the database
  is an optional, separately-sourced, user-supplied asset file.
- **External lookup behavior**: none. All lookups are against the
  locally-installed database file only, opened read-only.
- **Credential/token/API-key handling**: none. The only "token" match in
  the source (`fcc_applicant_tokens`, line 47) is a static array of
  company-name-suffix strings (" Inc.", " LLC", " Ltd.", etc.) used to
  decompress abbreviated applicant names from the offline database — not
  an authentication token of any kind.
- **Storage writes**: none. The single storage call in the entire
  source (`storage_file_open(db->file, FCC_DB_PATH, FSAM_READ,
  FSOM_OPEN_EXISTING)`, line 444) is read-only, opening the
  pre-installed database file. No `storage_file_write`,
  `storage_simply_*`, or any other write-capable call exists anywhere in
  the source.
- **Unsafe hardware/API behavior**: none. Zero references to
  `furi_hal_subghz`, `furi_hal_nfc`, `furi_hal_rfid`, `furi_hal_ibutton`,
  `furi_hal_hid`, `furi_hal_gpio_write`, or
  `furi_hal_infrared_async_tx_start` anywhere in the source.

## Final conclusion: **LICENSE GAP RESOLVED**

The app-local evidence remains unchanged from Phase 2C.1 (no in-repo
`LICENSE`, SPDX header, or copyright notice) — that has not changed and
is not claimed to have changed. What this phase resolves is the specific
open question Phase 2C.1 left explicit: whether the strong corroborating
upstream MIT evidence could be tied to the exact vendored revision. This
phase establishes that tie through a real, source-content-based
dependency chain (three independently matched implementation features,
each traceable to a specific upstream commit newer than the
LICENSE-adding commit in the same linear history) — not a guess, not a
repo-level assumption, and not calendar-date correlation alone.

**Classification: LICENSE GAP RESOLVED**, on the condition (restated in
`docs/FCC_ID_LOOKUP_IMPORT_ELIGIBILITY.md`) that the confirmed upstream
`LICENSE` file (MIT, Copyright (c) 2026 lsr) is included alongside the
app's own source at actual import time, exactly as Phase 2C.1's own
original "clear, low-effort resolution path" already specified.

This resolution is licensing/provenance only. It does not itself
constitute an import approval, a safety sign-off beyond what is
re-confirmed above, or a build/CI clearance — see
`docs/FCC_ID_LOOKUP_IMPORT_ELIGIBILITY.md` for what remains before any
future import.

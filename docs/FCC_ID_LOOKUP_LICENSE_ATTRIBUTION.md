# FCC ID Lookup — License Attribution

Records the license-attribution steps actually taken during this one-app
import, mirroring the format of this project's existing per-batch
`PHASEX_2_LICENSE_ATTRIBUTION.md` documents.

## Upstream MIT LICENSE evidence

Full evidence chain restated from `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`
(not re-derived in this phase):

- Upstream repository: `github.com/lrehmann/fcc-id-lookup-flipper`.
- Real MIT `LICENSE` confirmed at upstream `HEAD`, live-fetched and
  independently confirmed to match the canonical MIT License template
  exactly, with copyright line "Copyright (c) 2026 lsr".
- Added in upstream commit `8c49c773eb9b0a399f9e6ede9153372d21056d08`
  ("Prepare source metadata for catalog").
- Three concrete implementation features in the vendored
  `fcc_id_lookup.c` map to upstream commits chronologically newer than
  the LICENSE-adding commit — establishing that the vendored source
  (RogueMaster commit `472f6925e8aca9bd031cb37e3cb80b551772c957`) was
  necessarily pulled from a post-LICENSE upstream state.

## Source repository and commit

| Field | Value |
|---|---|
| Vendored source repo | `RogueMaster/flipperzero-firmware-wPlugins` |
| Vendored source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |
| Vendored source path | `applications/external/fcc_id_lookup/` |
| Imported path (this repo) | `applications_user/fcc_id_lookup/` |

## Attribution steps taken

1. **License text preserved verbatim.** The confirmed upstream MIT
   `LICENSE` text (fetched live and independently confirmed to match the
   canonical MIT template exactly) was written to
   `applications_user/fcc_id_lookup/LICENSE`, alongside the app's own
   source, as part of the import commit (`fcc: import fcc_id_lookup`).
2. **`application.fam` attribution fields preserved unchanged.**
   `fap_author="lrehmann"` and
   `fap_weburl="https://github.com/lrehmann/fcc-id-lookup-flipper"` are
   byte-identical to the vendored source — not modified, not removed.
3. **`README.md` preserved unchanged**, including its own citation of
   the data source (`https://fccid.io`, `https://fcc.id/{FCC_ID}`) and
   the RogueMaster build notes describing the optional database.
4. **A dedicated third-party notice document created**:
   `docs/FCC_ID_LOOKUP_THIRD_PARTY_NOTICES.md`, naming the upstream
   project, reproducing the full license text, and explicitly stating
   the optional database is not bundled.
5. **Source comments and provenance notes preserved unchanged.** No
   comment, string, or attribution text anywhere in `fcc_id_lookup.c` or
   `fcc_qr_code.h` was altered.

## Optional database not bundled — note

Restated: the ~8.9 MB FCC frequency/applicant database is not part of
this import, not committed anywhere in this repository, and remains a
separate, optional, end-user-sourced download per the app's own
`README.md`. This import ships only the app's own source (~72 KB total
across 6 files including the new `LICENSE`).

## Import-time license preservation result

**Preserved cleanly.** The confirmed upstream `LICENSE` was added
byte-verbatim alongside the app's source in the same commit that
imported the app, with no modification to the app's own attribution
fields, comments, or provenance text. No license text was invented or
reconstructed from memory alone — the exact upstream text was
independently fetched and confirmed to match the canonical MIT template
before use, per `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`.

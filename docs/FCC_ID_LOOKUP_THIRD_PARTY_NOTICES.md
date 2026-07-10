# FCC ID Lookup — Third-Party Notices

Third-party attribution notice for `fcc_id_lookup`, imported on branch
`integration/fcc-id-lookup-one-app-import`. Mirrors the format of this
project's existing per-batch `THIRD_PARTY_NOTICES.md` documents.

## App

| Field | Value |
|---|---|
| App name | FCC ID Lookup |
| appid | `fcc_id_lookup` |
| Imported path | `applications_user/fcc_id_lookup/` |

## Upstream author / source

| Field | Value |
|---|---|
| Upstream author | lrehmann |
| Upstream source repository | `https://github.com/lrehmann/fcc-id-lookup-flipper` |
| Vendored via | `RogueMaster/flipperzero-firmware-wPlugins` |
| Vendored source path | `applications/external/fcc_id_lookup/` |
| Vendored source commit | `472f6925e8aca9bd031cb37e3cb80b551772c957` |

## Declared license

**MIT License.**

```
MIT License

Copyright (c) 2026 lsr

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

This text was fetched live from the upstream repository
(`raw.githubusercontent.com/lrehmann/fcc-id-lookup-flipper/main/LICENSE`)
and independently confirmed to match the canonical MIT License template
exactly (word-for-word, clause-for-clause), with copyright line
"Copyright (c) 2026 lsr" — not paraphrased, not reconstructed from
memory alone. The full evidence chain tying this license to the exact
vendored revision is documented in
`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`.

## Upstream LICENSE evidence

The upstream `LICENSE` file was added in upstream commit
`8c49c773eb9b0a399f9e6ede9153372d21056d08` ("Prepare source metadata for
catalog"). Three concrete implementation features present in the
vendored `fcc_id_lookup.c` (a `FCC_DB_READ_CACHE_SIZE` read-cache,
explicit corrupt-record bounds-check comments, and the
zero-size-output-guarded `fcc_grantee_prefix()` signature) each map to
upstream commits chronologically newer than the LICENSE-adding commit in
the same linear history — establishing that the vendored copy was
necessarily pulled from an upstream revision that already included the
`LICENSE` file. See `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md` for the
full chain.

## Optional FCC database — not bundled

**The optional FCC frequency/applicant database (`fcc_freq_v2.bin`, ~8.9
MB) is NOT bundled with this app, is NOT committed anywhere in this
repository, and was NOT added as part of this import.** Per the app's
own `README.md`, the database is a separate, optional, end-user-sourced
download from
`https://github.com/lrehmann/fcc-id-lookup-flipper/blob/main/files/fcc_freq_v2.bin`,
which the end user must manually place at `/ext/apps_assets/fcc_id_lookup/`
themselves. Without it, the app displays a setup-hint message rather
than crashing. The database's own underlying data is drawn from FCC
equipment-authorization records (a matter of U.S. federal regulatory
public record, per the app's own in-app attribution text, "Data sourced
from https://fccid.io"), a provenance question entirely separate from
this app's own source code license and not resolved or touched by this
import.

## Attribution requirements

1. This `LICENSE` file (`applications_user/fcc_id_lookup/LICENSE`) is
   preserved alongside the app's own source, unmodified, as part of the
   import commit.
2. `application.fam`'s existing `fap_author="lrehmann"` and
   `fap_weburl="https://github.com/lrehmann/fcc-id-lookup-flipper"`
   fields are preserved unchanged.
3. This document (`docs/FCC_ID_LOOKUP_THIRD_PARTY_NOTICES.md`) itself
   serves as the project-level third-party notice, matching the pattern
   used for every prior batch's `PHASEX_THIRD_PARTY_NOTICES.md`.

## Full license evidence preservation

The full license evidence — both the app-local `LICENSE` file copied
verbatim into the imported app directory, and the complete resolution
chain of evidence tying it to the exact vendored revision — is preserved
in this repository:

- `applications_user/fcc_id_lookup/LICENSE` (the license text itself,
  alongside the app's source)
- `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md` (the full resolution
  evidence chain)
- `docs/FCC_ID_LOOKUP_PREIMPORT_VERIFICATION.md`,
  `docs/FCC_ID_LOOKUP_IMPORT_READINESS_MATRIX.md` (the pre-import
  verification pass)
- This document (the consolidated third-party notice)

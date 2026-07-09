# FCC ID Lookup — Import Eligibility

Docs only. Planning only. **NO CODE IMPORT PERFORMED.** This document
states what the license resolution in
`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md` does and does not unlock. It
does not itself start, authorize, or perform any import.

## May `fcc_id_lookup` be considered in a future import-planning phase?

**Yes, conditionally.** The specific license-evidence gap that kept it
out of every batch since Phase 2C is now resolved (see
`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`), on the condition that the
confirmed upstream `LICENSE` (MIT, Copyright (c) 2026 lsr) is included
at actual import time. This clears `fcc_id_lookup` to be re-added to a
candidate pool for a **future**, separately-requested import-planning
phase — it does **not** retroactively make it part of any currently
recommended batch, since `docs/PHASE2G_GO_NO_GO.md`'s own conclusion
(NO-GO / clean candidate pool exhausted) was reached independently of
this app's license status and is not reopened by this document.

## Is direct import allowed now?

**No.** This phase is licensing/provenance resolution only, per its own
explicit scope. No import-readiness matrix, no risk register entry, no
CI build attempt, and no hardware/storage smoke-test plan has been
produced for `fcc_id_lookup` in this phase — all of that is exactly the
per-app work every other imported app in this project received
(`PHASE2X_1_IMPORT_READINESS_MATRIX.md`,
`PHASE2X_1_SOURCE_LICENSE_VERIFICATION.md`, a static safety scan via
`tools/phase2a_validate.ps1`, a real CI build, a safety review) before
its own import. None of that has happened for `fcc_id_lookup` yet.

## Remaining conditions before any import

1. **A dedicated Phase 2X.1-equivalent pre-import verification pass**,
   the same rigor every other app in this project received: real static
   safety-keyword scan via `tools/phase2a_validate.ps1` against the
   pinned commit's actual source, individually reviewing every match.
2. **Inclusion of the confirmed upstream `LICENSE` file** (MIT,
   Copyright (c) 2026 lsr, fetched from
   `github.com/lrehmann/fcc-id-lookup-flipper`) alongside the app's own
   source at the moment it is actually imported — not merely cited in a
   planning document.
3. **A real CI build attempt** (Windows validation workflow) confirming
   the app compiles cleanly as part of the current 19-app baseline, with
   no `updater_package`/`.fap`-output regression, following this
   project's now-established one-app-at-a-time, commit-per-app,
   validate-after-each discipline.
4. **A storage/safety review** matching the depth every other app
   received — this phase's own re-confirmation (read-only, no network,
   no credential handling, no unsafe hardware API) is a reasonable
   starting point but is not a substitute for the dedicated
   `PHASE2X_2_SAFETY_REVIEW.md`-equivalent document every prior batch
   produced at actual import time.
5. **Project owner's own explicit request** to begin that import-planning
   phase — nothing in this document, or in
   `docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`, starts it automatically.

## Attribution requirements

At actual import time, the app's own `application.fam`
(`fap_author="lrehmann"`, `fap_weburl="..."`) already provides
attribution; a `THIRD_PARTY_NOTICES.md`-equivalent entry (matching this
project's pattern for every other batch) would additionally need to:

- Name the upstream project (`lrehmann/fcc-id-lookup-flipper`) and its
  MIT license explicitly.
- Note that the bundled FCC frequency/applicant database is **not**
  shipped with the app — it remains a separate, optional, user-sourced
  download, and this project would not need to (and does not propose to)
  resolve the database's own data-provenance question unless it later
  chose to bundle that file directly.

## Storage/safety review requirement

This phase's own re-confirmation (see
`docs/FCC_ID_LOOKUP_LICENSE_RESOLUTION.md`'s "Safety/scope findings"
section: read-only, no network, no credential handling, no write calls,
no unsafe hardware/radio API) found no new concern and is consistent
with the original Phase 1.6 `APPROVE` finding and Phase 2C.1's own
storage characterization. A future import-planning phase should still
produce its own dedicated safety-review document, per this project's
standing per-app discipline, rather than citing this document as a
substitute.

## CI/build review requirement

No build attempt of any kind was made in this phase. A future
import-planning phase would need to add `fcc_id_lookup` to a real
Windows CI validation run (matching every prior phase's
`.github/workflows/phaseXX-windows-validation.yml` pattern) and confirm
a clean pass — firmware build, `updater_package`, and the new `.fap`
output — before any CI-baseline acceptance could be considered.

## Explicit statement

**NO CODE IMPORT PERFORMED.** No application directory was created or
modified, no build was attempted, and no firmware or app source changed
as a result of this phase or this document.

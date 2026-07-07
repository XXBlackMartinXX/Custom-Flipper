# Phase 2D — Risk Register

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2D_RECOMMENDED_BATCH.md`. Risk classes and terminology follow
`PHASE1_RISK_REGISTER.md` and the reviewed-false-positive/hard-fail
keyword tiers already established in `tools/phase2c_validate_config.json`,
so that the existing validation tooling can be reused unmodified against
this batch when an actual import is separately approved.

## `resistors`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 source audit found zero matches across all 8 HAL capability classes (storage, GPIO, Sub-GHz, IR, NFC/RFID/iButton, BLE, USB/HID) in this app's source. |
| Build risks | Medium — 13 files, and Phase 1.5 separately flagged a disproportionately large ~2.3MB on-disk footprint (likely icon/reference assets); budget extra build-verification time, the same discipline already applied to `chess`/`upython`. |
| Dependency risks | None declared beyond the default FAP toolchain. |
| Storage risks | None — explicitly "**None**" in the Phase 1.6 audit, the most confident zero-storage classification in this pool. |
| Licensing risks | Not confirmed in this phase (see `docs/PHASE2D_LICENSE_REVIEW.md`) — Medium confidence, not a specific finding of a problem. |
| UI/runtime risks | Unverified — this is a planning phase; no GUI behavior has been observed. Standard `REQUIRES_HUMAN_OBSERVATION` treatment would apply at a future hardware-gate stage. |
| Likely false-positive keywords | None expected — a resistor color-code calculator has no obvious reason to reference any risky-keyword tier; if any appear, they get the same per-line reviewed-false-positive treatment already used for 139 prior matches. |
| Exact mitigation | Standard pipeline only: source diff review at import, Static then Build validation, per-app FAP output check, plus explicit attention to build time/asset size given the flagged 2.3MB footprint. |
| Stop conditions | Any unreviewed high-confidence-unsafe-keyword hit; any FAIL from Static or Build validation; any source content at actual import time that contradicts this review (e.g. a storage write this planning phase's citation-only review could not have caught). |

## `crypto_dictionary`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits, confirmed "no crypto *operations* performed on user data" — a glossary, not a cryptographic tool. |
| Build risks | Medium — 13 files plus bundled reference text resources; no unusual build complexity expected. |
| Dependency risks | None declared. |
| Storage risks | None — reads bundled text resources only, per Phase 1.6. No user-data write of any kind. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `docs/PHASE2D_LICENSE_REVIEW.md`). The bundled glossary's own content provenance (cipher terminology definitions) is a lower-severity question than `c_book`'s verbatim commercial-book text, but has not been confirmed against an actual license/attribution file. |
| UI/runtime risks | Unverified in this phase; standard `REQUIRES_HUMAN_OBSERVATION` treatment applies at a future hardware-gate stage. |
| Likely false-positive keywords | Possible — a cipher/cryptography glossary may contain glossary *entries* that literally define terms like "credential," "token," "password," or "brute force" as reference text (e.g. defining "brute-force attack" as a dictionary entry), which would trigger this project's risky-keyword scan as expected, benign false positives, not real capability. This must be reviewed per-line at actual import time with the same reviewed-false-positive discipline as every other match in this project's history — flagged explicitly here so it is not a surprise. |
| Exact mitigation | Standard pipeline, plus: expect and individually review keyword-scan hits from the glossary's own defined terms (this is a *foreseeable* false-positive category for this specific app, not a generic warning) before treating any as reviewed. |
| Stop conditions | Same baseline stop conditions as `resistors`, plus: if any risky-keyword match in this app's bundled text is found to be something other than a glossary definition (i.e. actual functional code referencing that capability), stop and re-classify immediately. |

## `2048`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits, single well-understood save-file pattern. |
| Build risks | Low — 4 files, the simplest file count of any app exercising the private-save pattern in this project's history. |
| Dependency risks | None declared. |
| Storage risks | **Local/private only** — a high-score save file under this app's own app-private data path (the same `chess`/`sudoku`-precedent pattern). The exact private path for `2048` is not yet confirmed in this phase and should be recorded at actual import time, the same way `chess`'s and `sudoku`'s paths were recorded before either existed in this project's own tooling config. Not a shared-directory write — unlike `animation_switcher`/`theme_manager`. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `docs/PHASE2D_LICENSE_REVIEW.md`). |
| UI/runtime risks | Unverified in this phase. The save/load path specifically should get its own smoke-test-checklist entry (visibility, launch, save, reload, confirm state persists, confirm no write outside the app-private path) when an actual hardware smoke test is eventually performed — same discipline as `chess`'s and `sudoku`'s save-path checks. |
| Likely false-positive keywords | None expected from a 2048 puzzle implementation; same per-line reviewed-false-positive process as every prior app applies to anything unexpected. |
| Exact mitigation | Standard pipeline, plus: confirm the app-private save path explicitly at import time (do not assume it matches any existing app's path), and add a save/load check to the smoke-test checklist mirroring `chess`'s/`sudoku`'s. |
| Stop conditions | Same baseline stop conditions, plus: if the save file is found to write outside an app-private path (i.e. behaves like `animation_switcher`/`theme_manager`, or like `sd_info`'s SD-root writes, rather than like `chess`/`sudoku`), stop and re-classify this app's storage risk before proceeding — this is exactly the class of surprise Phase 2C.1 found for `sd_info`, so this app's actual save path must be verified directly, not assumed from the citation alone. |

## Batch-wide stop conditions (apply to all 3)

- If any of the 3 apps' actual source (read at real import time, not this
  citation-only planning review) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability that this planning phase's review did not
  catch, **stop immediately and mark that app DEFER** — do not import it
  even if the other two are otherwise ready.
- If any of the 3 apps is found to have unclear license or bundled
  third-party code/data without provenance at actual import time, **stop
  and mark that app DEFER**, per the same canary already applied
  throughout this project (`c_book`, and now `fcc_id_lookup`).
- If any of the 3 requires source changes outside its own app directory,
  **stop and mark NEEDS REVIEW** before proceeding with that app.
- If any of the 3 handles credentials, tokens, passwords, seed phrases,
  keys, exfiltration, bypass, cloning, brute force, or HID injection —
  **stop and mark DEFER**. (Not expected for any of these 3 per the
  existing audit, but stated explicitly per this phase's own canary.)
- If Static or Build validation FAILs for any of the 3, root-cause it
  per this project's standing rule (fix the underlying cause, don't patch
  around it) before re-attempting.
- **Hardware testing is not a precondition evaluated here.** CI (Static +
  Build) validation is the gate before any hardware-connected step is even
  considered; none of this batch has reached CI, let alone hardware, in
  this planning phase.
- **This phase does not run `HardwareAssisted` mode and does not flash
  hardware.** Nothing in this register changes that.

## What this register does not cover

This register evaluates the 3 recommended apps only, based entirely on
the existing Phase 1.6 source audit's findings — it is not a fresh source
read in this phase. Any risk characterization here should be re-confirmed
against the actual file contents at Phase 2D.1 (pre-import source/license
verification), exactly as Phase 2C.1 did for `sd_info`/`docviewlite`
(finding a real, previously-unassumed storage-write behavior in
`sd_info`), and exactly as Phase 2A's own chess SAM-license finding
demonstrates a prior audit pass can miss something a dedicated later pass
catches.

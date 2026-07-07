# Phase 2C — Risk Register

Docs only. Planning only. Covers the 3 apps recommended in
`PHASE2C_RECOMMENDED_BATCH.md`. Risk classes and terminology follow
`PHASE1_RISK_REGISTER.md` and `PHASE2B_RISK_REGISTER.md`, and the
reviewed-false-positive/hard-fail keyword tiers already established in
`tools/phase2b_validate_config.json`, so that the existing validation
tooling can be reused unmodified against this batch when an actual import
is separately approved.

## `sd_info`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 source audit found zero matches across all 8 HAL capability classes (storage-write, GPIO, Sub-GHz, IR, NFC/RFID/iButton, BLE, USB/HID) in this app's single file. |
| Build risks | Very low — 1 file, read-only card-info query using standard storage-info APIs already exercised elsewhere in the accepted baseline. |
| Dependency risks | None declared beyond the default FAP toolchain. |
| Storage risks | None — read-only access to card metadata; no writes of any kind. |
| Licensing risks | Not confirmed in this phase (see `PHASE2C_LICENSE_REVIEW.md`) — Medium confidence, not a specific finding of a problem. |
| UI/runtime risks | Unverified — this is a planning phase; no GUI behavior has been observed. Standard `REQUIRES_HUMAN_OBSERVATION` treatment would apply at a future hardware-gate stage, same as every prior app. |
| Likely false-positive keywords | None expected — a read-only diagnostic display has no obvious reason to reference any risky-keyword tier; if any appear, they get the same per-line reviewed-false-positive treatment already used for 110 prior matches. |
| Exact mitigation | Standard pipeline only: source diff review at import, Static then Build validation, per-app FAP output check. |
| Stop conditions | Any unreviewed high-confidence-unsafe-keyword hit; any FAIL from Static or Build validation; any source content at actual import time that contradicts this review. |

## `fcc_id_lookup`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits beyond a read of bundled reference data, 2 files. |
| Build risks | Very low — 2 files, lookup logic against a bundled static database, no scene-manager/view-split complexity. |
| Dependency risks | None declared. |
| Storage risks | None beyond reading its own bundled database file — no user data written. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `PHASE2C_LICENSE_REVIEW.md`). The bundled database's content (US FCC ID/frequency public records) is likely not independently copyrightable, but this has not been confirmed against an actual license/attribution file. |
| UI/runtime risks | Unverified in this phase; standard `REQUIRES_HUMAN_OBSERVATION` treatment applies at a future hardware-gate stage. |
| Likely false-positive keywords | None expected. If any appear (e.g. a comment mentioning "frequency" or "lookup" triggering an unrelated keyword tier), same per-line reviewed-false-positive process applies. |
| Exact mitigation | Standard pipeline only: source diff review at import, Static then Build validation, per-app FAP output check, plus a specific check that the bundled database is in fact public-record data as described (not a third-party compiled dataset with its own separate rights). |
| Stop conditions | Same as `sd_info` above, plus: if the bundled database turns out to be sourced from a rights-encumbered third party rather than direct public FCC records, stop and re-classify licensing risk before proceeding. |

## `docviewlite`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits (no GPIO/Sub-GHz/IR/NFC/BLE/USB) in this app's single file. |
| Build risks | Low — 1 file, but this is the one app in the batch whose behavior depends on a user-selected file at runtime, so its file-open/parse path is the most scrutiny-worthy step in this specific batch (analogous to why `sudoku`'s save/load path was sequenced last in Phase 2B). |
| Dependency risks | None declared. |
| Storage risks | **Read-only only** — opens a user-selected document; does not write, modify, or persist any new state. Not a private-save-file pattern (like `chess`/`sudoku`) and not a shared-directory write (like `animation_switcher`/`theme_manager`) — a third, even more conservative pattern: read a file the user explicitly opened, write nothing. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `PHASE2C_LICENSE_REVIEW.md`). |
| UI/runtime risks | Unverified in this phase. The file-open path specifically should get its own smoke-test-checklist entry (open a valid document, open an edge-case/malformed document, confirm no crash, confirm no write outside expected behavior) when an actual hardware smoke test is eventually performed. |
| Likely false-positive keywords | None expected from a document viewer; same per-line reviewed-false-positive process as prior batches applies to anything unexpected. |
| Exact mitigation | Standard pipeline, plus: confirm at import time that the file-open path has no unbounded-read or unchecked-format-parsing behavior that could crash on a malformed file (a normal robustness check, not a security-boundary concern, since this app has no elevated privilege or network exposure). |
| Stop conditions | Same baseline stop conditions as the other two apps, plus: if the file-open path is found to write anything (contradicting the Phase 1.6 audit's "reads a user-selected document" finding), stop and re-classify this app's storage risk before proceeding. |

## Batch-wide stop conditions (apply to all 3)

- If any of the 3 apps' actual source (read at real import time, not this
  citation-only planning review) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability that this planning phase's review did not
  catch, **stop immediately and mark that app DEFER** — do not import it
  even if the other two are otherwise ready.
- If any of the 3 apps is found to have unclear license or bundled
  third-party code without provenance at actual import time, **stop and
  mark that app DEFER**, per the same canary already applied to `c_book`
  in Phase 2B and restated in this phase's instructions.
- If any of the 3 requires source changes outside its own app directory,
  **stop and mark NEEDS REVIEW** before proceeding with that app.
- If Static or Build validation FAILs for any of the 3, root-cause it per
  this project's standing rule (fix the underlying cause, don't patch
  around it) before re-attempting.
- **Hardware testing is not a precondition evaluated here.** CI (Static +
  Build) validation is the gate before any hardware-connected step is even
  considered; none of this batch has reached CI, let alone hardware, in
  this planning phase.
- **This phase does not run `HardwareAssisted` mode and does not flash
  hardware.** Nothing in this register changes that.

## What this register does not cover

This register evaluates the 3 recommended apps only, based entirely on the
existing Phase 1.6 source audit's findings — it is not a fresh source read
in this phase. Any risk characterization here should be re-confirmed
against the actual file contents at Phase 2C.1 (pre-import source/license
verification), exactly as Phase 2B.1 did for `flipfetch`/`quadratic_solver`/
`sudoku`, and exactly as Phase 2A's own chess SAM-license finding
demonstrates a prior audit pass can miss something a dedicated later pass
catches.

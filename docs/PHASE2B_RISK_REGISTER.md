# Phase 2B — Risk Register

Docs only. Planning only. Covers the 3 apps recommended in
`PHASE2B_RECOMMENDED_BATCH.md`. Risk classes and terminology follow
`PHASE1_RISK_REGISTER.md` and the reviewed-false-positive/hard-fail
keyword tiers already established in `tools/phase2a_validate_config.json`,
so that Phase 2A's existing validation tooling can be reused unmodified
against this batch when an actual import is separately approved.

## `flipfetch`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 source audit found zero matches across all 8 HAL capability classes (storage, GPIO, Sub-GHz, IR, NFC/RFID/iButton, BLE, USB/HID) in this app's single file. |
| Build risks | Very low — 1 file, no external API surface beyond standard display/input calls used throughout the existing app set. |
| Dependency risks | None declared beyond the default FAP toolchain (per Phase 1.6 audit). |
| Storage risks | None — confirmed zero storage API usage. |
| Licensing risks | Not confirmed in this phase (see `PHASE2B_LICENSE_REVIEW.md`) — Medium confidence, not a specific finding of a problem. |
| UI/runtime risks | Unverified — this is a planning phase; no GUI behavior has been observed. Standard `REQUIRES_HUMAN_OBSERVATION` treatment would apply at the hardware-gate stage, same as every Phase 2A app. |
| Likely false-positive keywords | None expected — a device-info display app has no obvious reason to reference any of the risky-keyword tiers (`ble`, `jam`, etc.) in `tools/phase2a_validate_config.json`; if any appear, they would need the same per-line reviewed-false-positive treatment already used for Phase 2A's 104 matches. |
| Exact mitigation | None needed beyond the standard pipeline: source diff review at import, `tools/phase2a_validate.ps1 -Mode Static` then `-Mode Build` after the commit, per-app FAP output check. |
| Stop conditions | Any unreviewed high-confidence-unsafe-keyword hit (per `highConfidenceUnsafeKeywords`); any FAIL from Static or Build validation; any source content at actual import time that contradicts this review (e.g. an API call this planning phase's citation-only review could not have caught). |

## `quadratic_solver`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits, single file, pure computation. |
| Build risks | Very low — 1 file, pure math/string logic, no scene-manager/view-split complexity to get wrong. |
| Dependency risks | None declared. |
| Storage risks | None — confirmed zero storage API usage. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `PHASE2B_LICENSE_REVIEW.md`). |
| UI/runtime risks | Unverified in this phase; standard `REQUIRES_HUMAN_OBSERVATION` treatment applies at the hardware-gate stage. |
| Likely false-positive keywords | None expected. A math-only app has no structural reason to trigger `ble`/`jam`/other risky substrings; if any do appear (e.g. a comment or variable name coincidence), same per-line reviewed-false-positive process as Phase 2A. |
| Exact mitigation | Standard pipeline only: source diff review at import, Static then Build validation, per-app FAP output check. |
| Stop conditions | Same as `flipfetch` above: any unreviewed high-confidence-unsafe-keyword hit, any FAIL from Static/Build, any actual-source finding that contradicts this review. |

## `sudoku`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits (no GPIO/Sub-GHz/IR/NFC/BLE/USB) in this app's single file. |
| Build risks | Low — 1 file, but this is the one app in the batch with a save/load path to verify compiles and links against the expected storage APIs (the same class of check already exercised for `chess` in Phase 2A). |
| Dependency risks | None declared. |
| Storage risks | **Local/private only** — a single save-game file under this app's own app-private data path (analogous to `chess`'s `/ext/apps_data/flipchess/` pattern confirmed in Phase 2A; the exact private path for `sudoku` is not yet confirmed in this phase and should be recorded at actual import time, the same way `chess`'s path was recorded in `tools/phase2a_hardware_gate_config.json`). Not a shared-directory write — unlike `animation_switcher`/`theme_manager`, which is exactly why this app was preferred over those two for a first tiny batch. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `PHASE2B_LICENSE_REVIEW.md`). |
| UI/runtime risks | Unverified in this phase. The save/load path specifically should get its own smoke-test-checklist entry (visibility, launch, save, reload, confirm state persists, confirm no write outside the app-private path) when an actual hardware smoke test is eventually performed — same discipline as `chess`'s save-path check in `docs/PHASE2A_HARDWARE_SMOKE_TEST_CHECKLIST.md`. |
| Likely false-positive keywords | None expected from a Sudoku implementation; same per-line reviewed-false-positive process as Phase 2A applies to anything unexpected. |
| Exact mitigation | Standard pipeline, plus: confirm the app-private save path explicitly at import time (do not assume it matches any existing app's path), and add a save/load check to the smoke-test checklist mirroring `chess`'s. |
| Stop conditions | Same baseline stop conditions as the other two apps, plus: if the save file is found to write outside an app-private path (i.e. behaves like `animation_switcher`/`theme_manager` rather than like `chess`), stop and re-classify this app's storage risk before proceeding. |

## Batch-wide stop conditions (apply to all 3)

- If any of the 3 apps' actual source (read at real import time, not this
  citation-only planning review) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability that this planning phase's review did not
  catch, **stop immediately and mark that app DEFER** — do not import it
  even if the other two are otherwise ready.
- If any of the 3 apps is found to have unclear license or bundled
  third-party code without provenance at actual import time, **stop and
  mark that app DEFER**, per the same canary already applied to `c_book`
  in this phase.
- If any of the 3 requires source changes outside its own app directory
  (e.g. touching shared registration files in a way that isn't a simple,
  additive one-line `App()` entry), **stop and mark NEEDS REVIEW** before
  proceeding with that app.
- If Static or Build validation FAILs for any of the 3, root-cause it
  per this project's standing rule (fix the underlying cause, don't patch
  around it) before re-attempting — the same discipline applied throughout
  Phase 2A (e.g. the `protobuf_version.h` and reviewed-false-positive
  fixes).
- **Hardware testing is not a precondition evaluated here.** Per the Phase
  2A precedent, CI (Static + Build) validation is the gate before any
  hardware-connected step is even considered; none of this batch has
  reached CI, let alone hardware, in this planning phase.

## What this register does not cover

This register evaluates the 3 recommended apps only, based entirely on the
existing Phase 1.6 source audit's findings — it is not a fresh source read
in this phase (no local source clone exists in this environment to perform
one). Any risk characterization here should be re-confirmed against the
actual file contents at the moment each app is really imported, exactly as
Phase 2A's own chess SAM-license finding demonstrates a prior audit pass
can miss something a dedicated later pass catches.

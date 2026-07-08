# Phase 2E — Risk Register

Docs only. Planning only. Covers the 3 apps recommended in
`docs/PHASE2E_RECOMMENDED_BATCH.md`. Risk classes and terminology follow
`PHASE1_RISK_REGISTER.md` and the reviewed-false-positive/hard-fail
keyword tiers already established in `tools/phase2d_validate_config.json`,
so that the existing validation tooling can be reused unmodified against
this batch when an actual import is separately approved.

## `image_viewer`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 source audit found zero matches across all 8 HAL capability classes (storage, GPIO, Sub-GHz, IR, NFC/RFID/iButton, BLE, USB/HID) in this app's source. |
| Build risks | Low — 1 file (`main.cpp`), the simplest build surface of any app recommended in this project's history. |
| Dependency risks | None declared beyond the default FAP toolchain. |
| Storage risks | Described as "reads user-selected image" (read-only) in the Phase 1.6 audit, but **not exhaustively confirmed against the actual source in this citation-only phase** — must be directly re-read at Phase 2E.1, per this phase's own special-caution instruction for this exact app. |
| Licensing risks | Not confirmed in this phase (see `docs/PHASE2E_LICENSE_REVIEW.md`) — Medium confidence, plus a specific open question on the 3 bundled example `.bm` bitmap files' own provenance (original artwork vs. freely reproducible). |
| UI/runtime risks | Unverified — this is a planning phase; no GUI behavior has been observed. Standard `REQUIRES_HUMAN_OBSERVATION` treatment would apply at a future hardware-gate stage. |
| Likely false-positive keywords | None expected — an image viewer has no obvious reason to reference any risky-keyword tier; if any appear, they get the same per-line reviewed-false-positive treatment already used for 189 prior matches. |
| Exact mitigation | Standard pipeline only: source diff review at import, Static then Build validation, per-app FAP output check, plus an explicit read-only confirmation for the file-open call(s) given this phase's own caution instruction. |
| Stop conditions | Any unreviewed high-confidence-unsafe-keyword hit; any FAIL from Static or Build validation; any storage-write call found at actual import time that contradicts this review's read-only characterization (the exact class of surprise Phase 2C.1 found for `sd_info`). |

## `boilerplate`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 audit: zero HAL capability hits across all 8 classes. |
| Build risks | Medium — 21 files across `helpers/`, `views/`, `scenes/`, the largest file count in this specific batch, though structurally a template app rather than a feature-dense one. |
| Dependency risks | None declared. |
| Storage risks | **App-private only** — explicitly "demonstrates a save-file pattern" per Phase 1.6, the same well-understood pattern already proven safe by `chess`/`sudoku`/`2048`. The exact private path is not yet confirmed in this phase and should be recorded at Phase 2E.1, the same discipline already applied to every prior app's own path before it existed in this project's tooling config. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `docs/PHASE2E_LICENSE_REVIEW.md`). No bundled third-party content identified beyond the template's own demonstration code. |
| UI/runtime risks | Unverified in this phase. As a template/demonstration app, its "normal" UI behavior is inherently minimal — the save/load demonstration path specifically should get its own smoke-test-checklist entry when an actual hardware smoke test is eventually performed. |
| Likely false-positive keywords | None expected from a FAP starter template; same per-line reviewed-false-positive process as every prior app applies to anything unexpected. |
| Exact mitigation | Standard pipeline, plus: confirm the app-private save path explicitly at import time (do not assume it matches any existing app's path), and add a save/load check to the smoke-test checklist mirroring `chess`'s/`sudoku`'s/`2048`'s. |
| Stop conditions | Same baseline stop conditions as `image_viewer`, plus: if the demonstrated save file is found to write outside an app-private path (i.e. behaves like `animation_switcher`/`theme_manager`, or like `sd_info`'s SD-root writes, rather than like `chess`/`sudoku`/`2048`), stop and re-classify this app's storage risk before proceeding. |

## `minesweeper`

| Field | Value |
|---|---|
| **Risk class** | **LOW** |
| Safety risks | None identified. Phase 1.6 source audit: zero HAL capability hits across all 8 classes, confirmed "full Minesweeper with a solver/hint engine" — no capability beyond the game itself. |
| Build risks | Medium — 20 files across `helpers/`, `views/`, `engine/`, `scenes/`, "the largest file count of the pure games" per Phase 1.6's own note; budget extra build-verification time, the same discipline already applied to `chess`/`hex_viewer`/`upython`. |
| Dependency risks | None declared beyond the default FAP toolchain. |
| Storage risks | **App-private only** — explicitly confirmed via a dedicated storage helper (`helpers/mine_sweeper_storage.c`) for save/config, per Phase 1.6. The exact private path is not yet confirmed in this phase and should be recorded at Phase 2E.1, same discipline as `boilerplate` above. |
| Licensing risks | Not confirmed in this phase — Medium confidence (see `docs/PHASE2E_LICENSE_REVIEW.md`). No bundled third-party content identified beyond the game's own assets. |
| UI/runtime risks | Unverified in this phase. The save/load path and the solver/hint engine specifically should each get their own smoke-test-checklist entries (visibility, launch, board interaction, save, reload, confirm state persists, confirm no write outside the app-private path) when an actual hardware smoke test is eventually performed — same discipline as `chess`'s/`sudoku`'s/`2048`'s save-path checks. |
| Likely false-positive keywords | Low — a Minesweeper implementation with a solver/hint engine could plausibly reference words like "flag," "reveal," or "mine" that have no overlap with this project's risky-keyword tiers; no specific false-positive category is anticipated, but any hit gets the standard per-line review. |
| Exact mitigation | Standard pipeline, plus: confirm the app-private save/config path explicitly at import time, and add save/load plus solver/hint-engine checks to the smoke-test checklist. |
| Stop conditions | Same baseline stop conditions as the other 2, plus: if the save/config file is found to write outside an app-private path, stop and re-classify this app's storage risk before proceeding — this is exactly the class of surprise Phase 2C.1 found for `sd_info`, so this app's actual save path must be verified directly, not assumed from the citation alone. |

## Batch-wide stop conditions (apply to all 3)

- If any of the 3 apps' actual source (read at real import time, not this
  citation-only planning review) shows RF/Sub-GHz/NFC/RFID/iButton/
  BadUSB/BLE/GPIO/IR capability that this planning phase's review did not
  catch, **stop immediately and mark that app DEFER** — do not import it
  even if the other two are otherwise ready.
- If any of the 3 apps is found to have unclear license or bundled
  third-party code/data without provenance at actual import time, **stop
  and mark that app DEFER**, per the same canary already applied
  throughout this project (`c_book`, `fcc_id_lookup`).
- If any of the 3 requires source changes outside its own app directory,
  **stop and mark NEEDS REVIEW** before proceeding with that app.
- If any of the 3 handles credentials, tokens, passwords, seed phrases,
  keys, exfiltration, bypass, cloning, brute force, or HID injection —
  **stop and mark DEFER**. (Not expected for any of these 3 per the
  existing audit, but stated explicitly per this phase's own canary.)
- If any of the 3 is found on fresh source read to actually write
  storage outside an app-private path (the `sd_info` precedent), **stop
  and re-classify that app's storage risk** before proceeding — do not
  silently treat it as still LOW risk.
- If Static or Build validation FAILs for any of the 3, root-cause it per
  this project's standing rule (fix the underlying cause, don't patch
  around it) before re-attempting.
- **Hardware testing is not a precondition evaluated here.** CI (Static +
  Build) validation is the gate before any hardware-connected step is
  even considered; none of this batch has reached CI, let alone
  hardware, in this planning phase.
- **This phase does not run `HardwareAssisted` mode and does not flash
  hardware.** Nothing in this register changes that.

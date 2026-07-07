# Phase 2C.1 — Import Readiness Matrix

Docs only. Pre-import verification only. **No app code has been
imported.** Consolidated table drawn from the full findings in
`PHASE2C_1_SOURCE_LICENSE_VERIFICATION.md` — read that document for full
evidence (file listings, exact grep results, SHA-256 hashes); this matrix
is a summary view, not a substitute.

| App | Source path | appid | Declared license | License confidence | Bundled data/code status | Safety status | Dependency status | Storage status | Build risk | Import readiness | Required attribution | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `sd_info` | `applications/external/sd_info/` | `sd_info` | GPLv3 (full text confirmed in vendored copy, SHA-256 `3972dc97...`) | **High** — real, unmodified, full license text present directly in the artifact that would be imported | None bundled | **Clean** — zero real API-safety hits across 18 required keywords; 3 benign `ble`-substring false positives (`double`×2, `enabled`) | None declared beyond default FAP toolchain | **Real, corrected** — transient, self-cleaning, user-initiated write/read/delete of test blocks at `/ext/sdtest.tmp*` during an explicit SD speed test (not app-private, not persistent, not automatic) | Medium-low — 64KB heap allocation (two 32KB buffers) during the test path; untested for allocation failure on real hardware | **CLEARED FOR IMPORT** | GPLv3 notice/license preservation (standard) | Storage-risk classification must be corrected from the planning phase's "zero/read-only" assumption before any future risk register update |
| `fcc_id_lookup` | `applications/external/fcc_id_lookup/` | `fcc_id_lookup` | **Not present in vendored copy.** Strong corroborating MIT evidence (Copyright lsr, 2026) found at true upstream repo (`github.com/lrehmann/fcc-id-lookup-flipper`, current `main`), not commit-pinned to the exact vendored revision | **Low-Medium** — real license text exists and was read, but not from the artifact itself; same author/URL/near-identical code corroborates it, but this project's own bar (license found directly in the vendored commit) is not met | **Out of scope for this import** — the 8.9MB reference database is not present anywhere in the vendored source tree; it is a separate, optional, user-supplied asset per the app's own design (`APP_ASSETS_PATH`, graceful missing-file handling) | **Clean** — zero real API-safety hits; 1 benign `token`-substring false positive (`fcc_applicant_tokens` array name, unrelated to credentials) | None declared | Read-only, app-private assets path only; graceful degradation if the optional database file is absent | Low — single ~48KB source file, no unusual build inputs in the recommended (code-only) import scope | **DEFER** (license-evidence gap, low severity, clear resolution path) | MIT notice/attribution to `lrehmann`/`lsr`, once the confirmed upstream `LICENSE` is included at import time | Not blocked or rejected — resolvable by fetching the real upstream `LICENSE` file and confirming it applied to the vendored revision (or simply accepting current upstream terms with an explicit note, at the project owner's discretion) |
| `docviewlite` | `applications/external/docviewlite/` | `docviewlite` | MIT (full text confirmed in vendored copy, SHA-256 `61f23cb9...`) | **High** — real, unmodified, full license text present directly in the artifact that would be imported | None bundled (manifest references a non-existent `images/` icon-assets directory — see Build risk) | **Clean** — zero real API-safety hits; several benign `ble`-substring false positives (`variable`, `enabled`, `scrolling`, `table`) | None declared beyond default FAP toolchain | Read-only only — opens and reads a user-selected `.txt` file via the standard file-browser dialog; no writes anywhere in the source | Low-Medium — `application.fam` declares `fap_icon_assets="images"` but no `images/` directory exists in the vendored copy; whether `fbt` tolerates this is unconfirmed, a genuine Static/Build-validation-time question | **CLEARED FOR IMPORT** | MIT notice/license preservation (standard) | The `fap_icon_assets` / missing-directory question must be observed (not assumed) at actual Static/Build validation |

## Reading this matrix

- **"Import readiness" is the authoritative field** — everything else is
  supporting evidence for that conclusion. `CLEARED FOR IMPORT` here means
  ready for the next gate (Phase 2C.2 implementation), not built, not
  hardware-tested, not release-ready.
- **`fcc_id_lookup`'s DEFER is not equivalent to `c_book`'s or `upython`'s/
  `iconedit`'s** DEFER status from prior phases. Those were real,
  substantive, hard-to-resolve concerns (unresolved book copyright, real
  hardware-capability exposure). This is a documentation/vendoring gap
  with a specific, low-effort, well-evidenced resolution path. It is kept
  as DEFER rather than a soft pass because this project's standing rule is
  not to guess a license into existence, not because there is genuine
  doubt about the app's good faith or actual licensing intent.
- **No app in this matrix touches Sub-GHz, NFC/RFID/iButton, GPIO,
  Infrared transmit, BLE, or HID** — all three were re-confirmed clean
  against the full 18-keyword safety scan, this time against real source,
  not a citation.

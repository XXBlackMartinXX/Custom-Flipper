# Phase 2C.2 — Go / No-Go

Docs only. This is the closing decision document for Phase 2C.2 —
implementation/import of the cleared, reduced Phase 2C tiny batch.

## Final classification: **PHASE 2C.2 IMPORT PASS**

Both cleared apps (`sd_info`, `docviewlite`) were imported one at a time,
each preserving full provenance and license text, each statically clean,
and the resulting 10-app batch was confirmed to build successfully on a
real Windows CI runner — verified via the GitHub API, not claimed on
trust.

## Imported apps

| App | License | Import commit | Static scan | Storage behavior |
|---|---|---|---|---|
| `sd_info` | GPLv3 (confirmed, full text) | `4e17278` | Clean — zero real unsafe/capability matches, 4 benign `ble`-substring false positives | Real, but controlled: transient, self-cleaning, user-initiated SD-card benchmark writes at `/ext/sdtest.tmp*` (SD-card root, not app-private, not persistent) |
| `docviewlite` | MIT (confirmed, full text) | `4fab909` | Clean — zero real unsafe/capability matches, 25 benign `ble`-substring false positives | Confirmed read-only — opens/reads a user-selected `.txt` file only |

Plus one infrastructure commit, `8cc20e2` — validator config
(`tools/phase2c_validate_config.json`) and CI workflow
(`.github/workflows/phase2c-windows-validation.yml`) — and one docs
commit, `969054e`, which is the actual commit CI validated.

## Skipped/deferred apps

- **`fcc_id_lookup`** — **not imported.** Deferred per
  `docs/PHASE2C_1_GO_NO_GO.md` on a license-evidence gap (no `LICENSE`
  file in the RogueMaster-vendored copy). Not substituted with any other
  app, per this phase's explicit instruction. Its status is unchanged by
  this phase.
- **`upython`, `iconedit`, `c_book`, `animation_switcher`,
  `theme_manager`** — hard-excluded per this phase's explicit
  instructions, not touched.

## Code changed summary

- **Added**: `applications_user/sd_info/` (5 files: `LICENSE`,
  `README.md`, `application.fam`, `icon.png`, `main.c`),
  `applications_user/docviewlite/` (5 files: `LICENSE`, `README.md`,
  `application.fam`, `docviewlite.c`, `docviewlite.png`), 2 exception
  lines in `applications_user/.gitignore`, `tools/phase2c_validate_config.json`,
  `.github/workflows/phase2c-windows-validation.yml`.
- **Not touched**: `applications/` (base firmware source), `build/`,
  `dist/`, `toolchain/`, any Phase 2A/2B app directory, any firmware
  binary, any updater package. No core firmware modification was made or
  needed.
- **Not imported**: `applications_user/fcc_id_lookup/` does not exist on
  this branch.

## Build/CI status

- **Local build**: BUILD BLOCKED / ENVIRONMENT (same structural
  limitation as every prior phase — `fbt.cmd` is a Windows batch file,
  this sandbox is Linux).
- **Local Static validation**: real, run via `pwsh` in this session —
  **PASS_WITH_REVIEWED_FALSE_POSITIVES**.
- **CI (Static + Build)**: real, verified via the GitHub API — run
  `28897702247`, conclusion **success**. `firmware.dfu` 862,825 bytes,
  updater `.tgz` 2,757,340 bytes, all 10 `.fap` outputs present including
  `sd_info` and `docviewlite`. See `docs/PHASE2C_2_BUILD_REPORT.md` for
  full detail.

## Hardware status

**NOT PERFORMED.** No `-Mode HardwareAssisted` invocation exists anywhere
in this phase's workflow or docs. No device, no flash. This phase's own
strict boundaries explicitly prohibited running `HardwareAssisted` mode
or flashing hardware, and neither was attempted.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.**

## Next recommended gate

Per the standing rule this project has followed at every prior phase
transition, the next allowed steps are:

1. **A Phase 2C.3 CI-baseline acceptance / artifact-hash finalization
   pass** — mirroring exactly what Phase 2A.9–2A.11 and Phase 2B.3 did:
   a formal acceptance record for this real CI PASS, and (if the project
   owner wants immutable baseline tags for this specific 10-app batch) a
   finalize-baseline workflow producing real SHA-256 hashes and pushing
   `phase2c-ci-baseline-...`/`phase2c-acceptance-record-...` tags — only
   on the project owner's own explicit further request.
2. **A Phase 2C hardware-assisted validation gate** (`tools/
   phase2c_hardware_gate.ps1`, modeled on the existing Phase 2A/2B
   hardware gates), only if/when a device and Windows machine become
   available, and only on explicit request. Given this AI session's
   sandbox has no Windows machine and no physical device, any such gate
   run in this environment would classify identically to every prior
   phase's own gate: `HARDWARE VALIDATION BLOCKED - DEVICE NOT AVAILABLE`.
3. **A dedicated follow-up pass on `fcc_id_lookup`'s license gap**,
   separate from any of the above — fetching the confirmed upstream
   `LICENSE` and re-verifying it against the specific vendored revision,
   before that app can be reconsidered for any future batch.

This phase does **not** authorize any of the above on its own — each
requires the project owner's own separate, explicit request, exactly as
every phase transition in this project has required so far.

## Statement

**PHASE 2C.2 IMPORT PASS.** Exactly 2 apps imported
(`sd_info`, `docviewlite`); `fcc_id_lookup` correctly not imported; no
other app touched; no core firmware modification; no hardware touched;
no hardware-connected validation mode run; no release published. Hardware
flashing/testing remains **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**.

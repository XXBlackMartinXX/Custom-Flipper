# Phase 2E.2 — Build Report

Docs only. Records the real local and CI build results for the Phase 2E
tiny batch (`image_viewer`, `boilerplate`, `minesweeper`) alongside the 13
already-accepted Phase 2A/2B/2C/2D apps — 16 apps total. `fcc_id_lookup`
is not part of this batch or this report.

**This report's bottom line is a genuine, clean pass**: the real CI
Windows Build run succeeded on its first attempt, with the firmware,
`updater_package`, and all 16 apps' `.fap` outputs (including all 3 newly
imported apps) building correctly.

## Local build status: BUILD BLOCKED / ENVIRONMENT

This session's sandbox is Linux, so `./fbt` (the cross-platform entry
point, unlike Windows-only `fbt.cmd`) could actually be invoked directly
— but it failed at the toolchain-download step, the same root cause every
prior phase's cloud-sandbox build attempt has hit:

```
Checking for tar..yes
Checking if downloaded toolchain tgz exists..no
Checking curl..yes
Downloading toolchain:
curl: (56) CONNECT tunnel failed, response 403
Failed to download https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz
```

Confirmed directly with a plain `curl` against the same host
immediately afterward — `CONNECT tunnel failed, response 403` — this is
an environment/egress-policy limitation, not a build failure or firmware
defect. Not faked as a pass, not worked around with an unofficial
substitute toolchain.

## Local static validation: PASS (real, run via `pwsh` in this session)

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    NOT_RUN
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

All 16 app directories present, all 16 `application.fam` files parse and
appid-match, all 16 appids unique with no collision against base
`applications/`, `chess`'s SAM removal still confirmed clean, submodules
initialized (16/16, after `git submodule update --init --recursive`
succeeded over real network access in this session), 373 risky-keyword
substring matches found, all 373 individually reviewed, zero unreviewed,
zero high-confidence-unsafe.

## CI build status: PASS (real, GitHub Actions, `windows-latest`)

- **Workflow**: `.github/workflows/phase2e-windows-validation.yml`
- **Run**: [`28966234832`](https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28966234832) (`workflow_dispatch`, triggered manually)
- **Commit**: `59b5132e58489e08609c92cd6b4ca3f10cdd998c`
- **Conclusion**: `success` — every step completed successfully
- **Duration**: `18:34:10Z`–`18:42:25Z` (~8 minutes)
- **Note**: an earlier automatic `push`-triggered run (`28966192440`,
  same commit) was cancelled by the workflow's own concurrency group
  (`cancel-in-progress: true`) in favor of this manual dispatch run — this
  is expected, intentional behavior, not a failure.

```
=== Classification ===
Static:   PASS_WITH_REVIEWED_FALSE_POSITIVES
Build:    PASS
Hardware: NOT_RUN
Overall:  AUTOMATED VALIDATION PASS
```

Exact evidence from the real, unedited job log:

- **Static validation**: completed `18:35:25Z`–`18:35:31Z`. 373 substring
  matches, all reviewed, zero unreviewed, zero high-confidence-unsafe.
- **Firmware build** (`.\fbt.cmd COMPACT=1 DEBUG=0`): **PASS**.
- **Pre-updater_package diagnostics** (Phase 2D.2A remediation, inherited
  unchanged): `firmware.dfu` confirmed present before the updater step;
  145.14GB free disk; Windows Defender real-time protection disabled.
- **Updater package build** (`.\fbt.cmd COMPACT=1 DEBUG=0
  updater_package`, via the `cmd /c` launch-mechanism fix): **PASS**, exit
  code 0.
- **Artifact verification**:
  - `build\f7-firmware-C\firmware.dfu`: **862,825 bytes** (identical to
    the Phase 2A-baseline reference size recorded in the config).
  - `dist\f7-C\flipper-z-f7-update-local.tgz`: **2,831,632 bytes**.
  - **Per-app FAP output verification: PASS — "All 16 expected .fap
    files found"** in `build\f7-firmware-C\.extapps`. This is a per-appid
    existence check driven by `tools/phase2e_validate_config.json`'s
    `expectedApps` list, not a bare count — it directly confirms
    `image_viewer.fap`, `fap_boilerplate.fap`, and
    `minesweeper_redux.fap` (the 3 new apps' real manifest-declared
    appid-based filenames) are present, alongside the 13 already-accepted
    apps' own `.fap` files.
- **Hardware-assisted validation**: `NOT_RUN` — Build mode never invokes
  `-Mode HardwareAssisted`; no device, no flash, at any point in this CI
  run.

## Artifact paths and sizes (workflow artifacts, not committed to the repository)

| Artifact | Size | Expires |
|---|---|---|
| `phase2e-firmware-artifacts` (`firmware.dfu` + updater `.tgz`) | 3,427,443 bytes | 2026-10-06 |
| `phase2e-validation-reports` (JSON + Markdown reports) | 46,748 bytes | 2026-10-06 |
| `phase2e-fap-artifacts` (all `.fap` files, including hidden `.extapps` path) | 626,079 bytes | 2026-10-06 |

Attempting to download these artifacts directly in this session's sandbox
hit the same, already-documented Azure Blob Storage egress block
(`403`) every prior phase's artifact-download attempt has hit — real
signed download URLs were obtained via the GitHub API, confirming the
artifacts genuinely exist, but their contents were not independently
re-verified byte-for-byte in this session beyond what the CI job's own
log already confirms (sizes and per-appid `.fap` presence, both quoted
directly above from the real job log, not inferred).

## Failures/blocks

**None in CI.** The only block in this report is the pre-existing,
already-documented local sandbox limitation (toolchain download blocked
by egress policy) — not a code defect, not a CI failure, and not a
regression introduced by this batch.

## Conclusion

**Real CI Build PASS**, first attempt, no compile fixes required, no
core firmware or existing app source touched. Local build remains
`BUILD BLOCKED / ENVIRONMENT` for the same reason as every prior phase.
Hardware flashing/testing: **NOT PERFORMED**. Release status remains
**TEST-READY ONLY / NOT RELEASE-READY**.

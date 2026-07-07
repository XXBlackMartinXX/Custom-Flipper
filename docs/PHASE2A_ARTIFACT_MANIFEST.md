# Phase 2A — CI Artifact Manifest

Docs only. This records exactly which GitHub Actions artifacts back the
Phase 2A acceptance record (`docs/PHASE2A_ACCEPTANCE_RECORD.md`), where to
find them, and how to independently verify them by hashing the actual files
after downloading — none of these binaries are committed to this
repository.

## Source run

| Field | Value |
|---|---|
| CI run ID | `28814008347` |
| CI run URL | https://github.com/XXBlackMartinXX/Custom-Flipper/actions/runs/28814008347 |
| Head SHA | `718eec5fe115c9e0467a8d07d974947a85b27cf6` |
| Branch | `integration/phase2a-first-batch` |
| Workflow | Phase 2A Windows Validation |

## Artifacts (as reported by the GitHub Actions API for this run)

| Artifact name | Artifact ID | Archive (zip) size | Archive digest (GitHub-computed) | Expires |
|---|---|---|---|---|
| `phase2a-firmware-artifacts` | `8118169559` | 3,328,855 bytes | `sha256:483a87c22ebd2720cd9a0048e697e79d7863026721182b28331959c5ecca2acb` | 2026-10-04 |
| `phase2a-validation-reports` | `8118168823` | 36,844 bytes | `sha256:9da01f6ae571f466c1d3171b0a887212982b90bff982c63871be9181c7020beb` | 2026-10-04 |

**Important**: the digests above are GitHub's own hash of the **zip archive**
it generated for artifact download — they are not, and should not be treated
as, hashes of the individual files inside. To get a hash of `firmware.dfu` or
the updater `.tgz` themselves, download and extract the artifact, then hash
each file directly (see "Verifying artifacts locally" below,
`tools/phase2a_artifact_manifest.ps1` automates exactly this).

## Contents of `phase2a-firmware-artifacts`

| File | Path inside artifact | Size |
|---|---|---|
| Firmware | `build/f7-firmware-C/firmware.dfu` | 862,825 bytes |
| Updater package | `dist/f7-C/flipper-z-f7-update-local.tgz` | 2,733,074 bytes |

## Contents of `phase2a-validation-reports`

Per `.github/workflows/phase2a-windows-validation.yml`'s upload step, this
artifact contains everything written under `reports\phase2a\` during the
run: the timestamped Static-mode JSON + Markdown reports, the timestamped
Build-mode JSON + Markdown reports, and the raw `fbt.cmd` build/updater log
files captured during the Build step. Exact filenames are timestamp-based
(`phase2a_validation_<UTC-timestamp>.json`/`.md`,
`build_firmware_<UTC-timestamp>.log`, `build_updater_<UTC-timestamp>.log`)
and were not individually enumerated for this manifest — download the
artifact from the run page to see the exact set for run `28814008347`.

## Where these artifacts live

**These artifacts are stored only as GitHub Actions workflow artifacts tied
to run `28814008347` — they are not, and will not be, committed as binaries
to this repository**, consistent with this project's standing policy against
committing `build/`, `dist/`, or `toolchain/` output. GitHub retains workflow
artifacts for a limited window (90 days, per the workflow's own
`retention-days: 90` setting; the API reports an explicit expiry of
2026-10-04 for both artifacts above) — after that, they are deleted by
GitHub automatically and this manifest becomes the only remaining record of
their existence and sizes.

## Verifying artifacts locally

If you download either artifact `.zip` from the run's **Artifacts** section
(Actions tab → this run → scroll to Artifacts) and extract it locally, you
can generate real, independently-computed SHA-256 hashes of the actual files
using the companion script:

```powershell
.\tools\phase2a_artifact_manifest.ps1 -ArtifactDir "C:\path\to\extracted\phase2a-firmware-artifacts" -OutFile .\phase2a_artifact_hashes.md
```

This produces a Markdown manifest with real file sizes and SHA-256 hashes
for whichever of `firmware.dfu`, the updater `.tgz`, and any validation
JSON/Markdown reports it finds in the directory you point it at. **No such
per-file hashes are recorded in this document** — they have not been
independently computed by any AI session (no artifact has been downloaded
here), and this document does not fabricate them. If you run the script,
consider appending its output to this file (or keeping it alongside) as the
first real, independently-verified hash record for these binaries.

## Final local hash manifest

See **`docs/PHASE2A_ARTIFACT_HASHES.md`** — the dedicated document for
recording real, downloaded-and-hashed SHA-256 values for this run's
artifacts (Phase 2A.10 attempted this and hit a genuine environment
blocker: the cloud sandbox's network policy blocks the Azure Blob Storage
host GitHub Actions artifact downloads always redirect to, confirmed via a
direct `403` and this session's own proxy status endpoint — the same class
of block as this project's Flipper-toolchain-host restriction). That
document previously stated hashes were not yet generated. They have since been finalized (see docs/PHASE2A_ARTIFACT_HASHES.md) rather than
fabricating values, and gives the exact steps to generate them (download +
run `tools/phase2a_artifact_manifest.ps1` on any machine with real network
access to GitHub).

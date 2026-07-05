# Local Windows Build Handoff

This document hands off the **first real, official, reproducible build** of the
Custom-Flipper base firmware to a local Windows 11 machine, because that build could
not be completed in the cloud session (see reasons below). Nothing has been merged,
patched, or released yet. This is a build-verification handoff only.

## 1. Exact source selected

| Field | Value |
|---|---|
| Repository | `https://github.com/DarkFlippers/unleashed-firmware` |
| Branch | `dev` (default branch at time of verification) |
| Commit | `5cdf9b33745f41f1a0405a6da44821128c233f5c` |
| Commit date | 2026-07-04 19:01:47 +0300 |
| Commit subject | "ci: post Build & analyze report on fork PRs via workflow_run (#1027)" |
| License | GPLv3 |
| Target hardware | `f7` only |

This is the exact commit verified in `docs/PHASE0_SOURCE_VERIFICATION.md` and
`docs/BUILD_LOG.md`. **Do not build a different commit** without updating those docs
first — the point of this handoff is a like-for-like verification of the commit
already inspected, not a moving target.

## 2. Exact reason the cloud build is blocked

1. `fbt` downloads a pinned, patched ARM GCC 12.3 toolchain from
   `https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz`.
   This cloud session's network egress policy returns **HTTP 403** for
   `update.flipperzero.one:443` — a policy denial, confirmed via the sandbox's own
   proxy status endpoint (`"kind": "connect_rejected", "detail": "gateway answered 403
   to CONNECT (policy denial or upstream failure)"`).
2. There is no official FBT vendor toolchain available anywhere in this sandbox, and
   it cannot be fetched from within it.
3. A hand-built substitute toolchain (system `apt` ARM GCC 13.2 + pip-installed
   Python/SCons) was tried purely to sanity-check the *source*, not as a release
   path. It reached 267 real compile steps and then hit a substitute-libc packaging
   quirk unrelated to Unleashed's own code. **That substitute build is explicitly not
   acceptable as proof of a working build** — full detail in `docs/BUILD_LOG.md`. No
   patches from that experiment were kept or committed (see confirmation below).

### Confirmation: no substitute-toolchain patches are in this repository

The two local `-Wno-error=` flag changes made during the substitute-toolchain
experiment (`site_scons/cc.scons`, to silence two GCC-12-vs-13 compiler-version false
positives) were made only inside a throwaway clone in the cloud sandbox's temporary
workspace (outside this git repository, never `git add`ed here). This repository's
git history (`git log`) contains exactly one commit, touching only `docs/` — no
firmware source has ever been added, modified, or committed here. There is nothing to
revert or isolate into an experimental branch; the official build path in this repo
is, and has always been, clean of any toolchain-substitution patch.

## 3. Local Windows 11 setup instructions

### Required tools

- **Git for Windows** — https://git-scm.com/downloads — installs both a Windows `git`
  and Git Bash. Either Git Bash or plain PowerShell works for the steps below.
- Nothing else needs to be preinstalled. `fbt` downloads its own pinned toolchain
  (ARM GCC, Python, SCons, and supporting tools) on first run and does **not** touch
  your system-wide Python/PATH. (Per Unleashed's own `documentation/fbt.md`: "To use
  `fbt`, you only need `git` installed in your system.")
- Optional, only if you want IDE integration: VS Code (`./fbt vscode_dist` after
  cloning). Not required for a build-only pass.

### Clone command (with submodules)

PowerShell or Git Bash:

```powershell
git clone --recursive https://github.com/DarkFlippers/unleashed-firmware.git unleashed-firmware
cd unleashed-firmware
git checkout 5cdf9b33745f41f1a0405a6da44821128c233f5c
git submodule update --init --recursive
```

Checking out the exact commit above (rather than just building whatever `dev` has
moved to) keeps this build directly comparable to the Phase 0 verification already
done. If you deliberately want current `dev` instead, that's fine — just say so in the
next session so the docs get updated to match.

### Official build command (Windows)

```powershell
.\fbt.cmd COMPACT=1 DEBUG=0
```

This performs a plain firmware build. If it fails, per Unleashed's own troubleshooting
note: make sure submodules are fully initialized (`git submodule update --init
--recursive`).

### Updater package command (if you want a flashable bundle staged, without flashing)

```powershell
.\fbt.cmd COMPACT=1 DEBUG=0 updater_package
```

**You may need to change `/` to `\` in front of the fbt command on Windows** (per
Unleashed's own docs) if you invoke it any other way than shown above.

### Expected artifact paths

- Plain firmware build: `build\f7-firmware-C\firmware.elf`, `firmware.bin`,
  `firmware.dfu` (folder suffix is `-D` instead of `-C` if you omit `DEBUG=0`; `fbt`
  also maintains a `built\latest` symlink/junction to the most recent firmware build
  variant).
- Updater package: `dist\` — specifically
  `dist\f7-update-<suffix>\flipper-z-f7-update-<suffix>.tgz` (an OTA/microSD update
  bundle), per Unleashed's `documentation/HowToBuild.md` and `documentation/OTA.md`.

### Where to find build logs

`fbt` prints everything to the console; it does not write a persistent log file on
its own. Capture it yourself, e.g. in PowerShell:

```powershell
.\fbt.cmd COMPACT=1 DEBUG=0 updater_package 2>&1 | Tee-Object -FilePath build_log_windows.txt
```

### What to send back to the next AI session

1. `build_log_windows.txt` (the full captured log above) — or at minimum the tail
   showing success/failure and any warnings.
2. The exact `fbt`/toolchain version line it prints on first run (confirms which
   pinned toolchain version was actually used).
3. Confirmation of the artifact path(s) that were actually produced, and their file
   sizes (a quick way to sanity-check nothing silently truncated).
4. Any error output verbatim, if the build fails — do not summarize/paraphrase errors,
   paste them as-is.
5. Whether you built the exact pinned commit above or a different one (say which, if
   different).

## 4. Safety notes

- **Do not flash yet.** This handoff is build-only. No `flash_usb`, `flash_usb_full`,
  or `updater_minpackage`-then-flash step should be run this round.
- **Build only** — do not start integrating RogueMaster/Momentum/Official features
  into this tree yet. That is a later, separate phase.
- **No feature integration yet** — this is purely to get one clean, official,
  reproducible build confirmed before anything else proceeds.
- **No hardware-test claims** unless you actually connect a physical Flipper Zero and
  test it yourself. If you do connect and test hardware, report exactly what you did
  (boot, menu navigation, app loader, etc.) so that — and only that — gets recorded as
  hardware-tested. Nothing hardware-related should be assumed or inferred by the next
  AI session from a successful compile alone.

## 5. Next-session prompt

Copy/paste this into the next session once you've run the official local build:

```
I ran the official local Windows build for Custom-Flipper per
docs/LOCAL_WINDOWS_BUILD_HANDOFF.md.

Commit built: <paste commit hash you actually built, confirm if it matches
5cdf9b33745f41f1a0405a6da44821128c233f5c>

Build command used: <paste exact command>

Result: <SUCCESS / FAILURE>

Build log:
<paste build_log_windows.txt content, or attach the file>

Artifacts produced (path + size):
<paste from build\ or dist\>

Toolchain version fbt reported: <paste the "FBT: using toolchain version ..." line>

Please update docs/BUILD_LOG.md and the Phase 0/4 status with this result, and do not
proceed to feature integration until we've confirmed this is a genuinely clean
official build.
```

## 6. Final verdict (this session)

| Item | Status |
|---|---|
| Phase 0 source verification | **PASS** |
| Base selected | **Unleashed** (`dev` @ `5cdf9b33745f41f1a0405a6da44821128c233f5c`) |
| Clean official build | **BLOCKED IN CLOUD / PENDING LOCAL BUILD** |
| Release status | **NOT RELEASE-READY** |
| Feature integration | **NOT STARTED** |

## 7. Result — local Windows build (reported by project owner)

The official local Windows build was run and reported back. Recorded here as-reported
(this AI session did not and cannot independently execute or observe a Windows build —
see `BUILD_LOG.md` for the same caveat applied consistently).

| Field | Value |
|---|---|
| Machine | Windows 11, repo at `C:\Github\flipper-unleashed-build` |
| Commit built | `5cdf9b33745f41f1a0405a6da44821128c233f5c` (matches Phase 0 selection) |
| `git status` before build | clean |
| `.\fbt.cmd COMPACT=1 DEBUG=0` | **PASS** |
| `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` | **PASS** |
| Firmware artifact | `build\f7-firmware-C\firmware.dfu` (exists) |
| Updater package artifact | `dist\f7-C\flipper-z-f7-update-local.tgz` (exists) |
| `git status` after build | clean |
| Real hardware flashing/testing | **NOT PERFORMED** |

This resolves the cloud-side blocker described in Section 2 and in `BUILD_LOG.md`:
the real pinned vendor toolchain was used (not the cloud session's substitute), and a
genuine firmware + updater artifact now exists. See `BUILD_LOG.md` for the updated
overall verdict.

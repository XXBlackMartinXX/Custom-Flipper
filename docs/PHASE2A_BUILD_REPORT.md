# Phase 2A — Build Report

**This is v3 of this document.** v2 covered the real local Windows build failure
against v1 of this branch (flattened submodules breaking protobuf-version
generation) and the fix applied (real git submodules). **This v3 records that the
corrected branch was rebuilt and the local Windows build now PASSES.** See
`PHASE2A_INTEGRATION_LOG.md` for the full explanation of what was wrong and what
changed.

## Real build attempt #2 (v2/current branch, commit `6b5cc53`) — PASS, reported by the project owner

| Field | Value |
|---|---|
| Machine | Windows 11, repo at `C:\Github\Custom-Flipper-phase2a-build` |
| Branch / commit tested | `integration/phase2a-first-batch` @ `6b5cc53fa1bcaca9e3dc9f497d479c33b0d63956` |
| Fresh clone | **PASS** |
| Recursive submodule checkout | **PASS** |
| `assets/protobuf` `git describe --tags --abbrev=0` | `0.29` — confirms the exact fix from v2 works on a real independent clone, not just in this cloud sandbox |
| `git status` before build | clean |
| `.\fbt.cmd COMPACT=1 DEBUG=0` | **PASS** |
| `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` | **PASS** |
| Firmware artifact | `build\f7-firmware-C\firmware.dfu` (exists) |
| Updater package | `dist\f7-C\flipper-z-f7-update-local.tgz` (exists) |
| `git status` after build | clean |
| Hardware flashing/testing | **NOT PERFORMED** (none claimed) |

**This confirms the protobuf/versioning failure from v1 is RESOLVED.** The fix
(restoring real git submodule structure, verified in the previous session only
inside this cloud sandbox) has now been independently confirmed on a fresh clone on
real hardware-adjacent tooling (a real Windows machine, the real official toolchain)
— this is a stronger confirmation than the sandbox-only check could provide, since
it rules out any sandbox-specific quirk in how the submodules were verified.

This also means, for the first time in this project, that **all 5 imported apps
have been compiled**, not just statically validated — the plain `.\fbt.cmd` build
target compiles everything under `applications_user/` as part of a full firmware
build. (Whether each app's specific `.fap` target was individually confirmed loadable
was not part of this report; see "What's still open" below.)

## Historical record: build attempt #1 (v1 of this branch) — FAILED

| Field | Value |
|---|---|
| Machine | Windows 11, repo at `C:\Github\Custom-Flipper-phase2a-build` |
| Branch / commit tested | `integration/phase2a-first-batch` @ `2f2e208a1fb26a8be53f23e4013b6db4db22653b` (v1, no longer exists — branch was force-pushed) |
| `git status` before build | clean |
| `.\fbt.cmd COMPACT=1 DEBUG=0` | **FAILED** |
| `.\fbt.cmd COMPACT=1 DEBUG=0 updater_package` | **FAILED** |
| `firmware.dfu` | missing |
| updater `.tgz` | missing |
| `git status` after build | clean |

Reported error:

```
Git: fetch failed
scons: *** [build\f7-firmware-C\assets\compiled\protobuf_version.h]
    Failed to process git tags for protobuf versioning
```

This is a real, informative failure — it happened **before any of the 5 imported
apps' code was ever reached by the build**, at asset/version generation for the
base firmware itself. Diagnosed and fixed this session; full root-cause explanation
in `PHASE2A_INTEGRATION_LOG.md`. Per instruction, this was not patched around by
hardcoding a protobuf version — the actual structural cause (flattened submodules
lacking git metadata) was fixed instead.

## What changed between v1 and v2

Only the base commit's construction method: submodules are now real `git submodule`
entries instead of flattened plain files. No firmware source was modified, no app
was changed, `site_scons/cc.scons` and every other build-system file remain
byte-for-byte upstream Unleashed. The 5 imported apps' own content is unchanged.

## Diagnostics performed in this cloud sandbox after the failure report

- Located and read the exact failing code path:
  `scripts/fbt_tools/fbt_assets.py`'s `_proto_ver_generator`, which runs
  `git fetch --tags` then `git describe --tags --abbrev=0` inside `assets/protobuf`.
- Reproduced the missing precondition directly: confirmed v1's `assets/protobuf`
  had no `.git` metadata (flattened), so those commands had nothing valid to run
  against.
- Rebuilt the base with `assets/protobuf` (and all 11 other submodules) as real git
  submodules pinned to the exact commit Unleashed itself uses.
- **Directly verified the fix**, on this rebuilt tree, in this cloud sandbox:
  ```
  $ cd assets/protobuf && git describe --tags --abbrev=0
  0.29
  ```
  This is the exact command the build step runs and the exact output format it
  expects (`MAJOR.MINOR`) — confirms the specific failure is resolved.
- Also checked the *other* git-dependent version-generation path
  (`scripts/fbt/version.py`, used for the main firmware's own version banner) for a
  similar risk. It uses `git describe --always --dirty --all --long` (note
  `--always`, which falls back to a plain commit hash if no tag matches) and
  `git show -s --format=%ct` (just the current commit's timestamp) — **neither
  requires network access or pre-existing tag history**, so this path was not at
  risk and needed no fix.
- Re-attempted the real, unmodified `./fbt` once more in this cloud sandbox (not to
  claim a build pass — this environment still can't reach the toolchain host — but
  to reconfirm the *same* blocker as before, unrelated to this fix):
  ```
  Failed to download https://update.flipperzero.one/builds/toolchain/...
  ```
  Still policy-blocked (`403`, confirmed fresh against the proxy status endpoint),
  exactly as documented throughout this project. This cloud sandbox cannot verify a
  full compile either way — only the local Windows path can.

## Build status: **PASS**

Confirmed by the project owner's real local Windows build (see "Real build attempt
#2" above): fresh clone, recursive submodule checkout, plain firmware build, and
`updater_package` all passed, with both artifacts present and `git status` clean
before and after. The protobuf/versioning failure from v1 is resolved.

## What's still open (not yet confirmed, not claimed)

- **Individual `.fap` targets for each of the 5 apps were not separately confirmed
  built/loadable** — the plain build compiles everything under `applications_user/`
  as part of the firmware image, which is good evidence but isn't the same as
  confirming each app's own `.fap` output exists and is well-formed. Not blocking,
  just not yet explicitly checked.
- **Real hardware flashing/testing: NOT PERFORMED.** No device has been flashed,
  booted, or used to launch any of the 5 apps. Nothing here should be read as
  implying otherwise.
- **`chess`'s bundled SAM text-to-speech component has an unresolved license
  question** — investigated separately in
  `docs/PHASE2A_CHESS_SAM_LICENSE_REVIEW.md`. This does not affect whether the code
  *compiles* (it does, per this report), only whether it's appropriate to
  *distribute*. Build status and license status are reported independently and
  should not be conflated — a clean build is not the same as a release-ready or
  legally-clear build.

## Release status

**TEST-READY ONLY / NOT RELEASE-READY.** A passing local build on one machine is a
real, meaningful milestone, but release-readiness additionally requires: the SAM
license question resolved, hardware testing, the remaining Top-25/broader-catalog
review, and the project's full release-gate checklist — none of which are done.

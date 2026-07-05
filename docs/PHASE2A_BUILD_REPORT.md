# Phase 2A — Build Report

**This is v2 of this document**, covering both the real local Windows build failure
against v1 of this branch and the fix applied in v2. See
`PHASE2A_INTEGRATION_LOG.md` for the full explanation of what was wrong and what
changed.

## Real build attempt #1 (v1 of this branch) — FAILED, reported by the project owner

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

## Build status: **PENDING LOCAL BUILD (rebuild required — please re-run)**

This is explicitly **not** claimed as fixed until you rebuild and it actually
passes. What's confirmed here is that the specific reported error's root cause has
a verified fix for the exact failing command — not that the rest of the build
(actual app compilation, linking, `updater_package`) will succeed. Static
verification has limits; only your local build can confirm the rest.

### To re-run

```powershell
cd C:\Github\Custom-Flipper-phase2a-build
git fetch origin
git checkout integration/phase2a-first-batch
git reset --hard origin/integration/phase2a-first-batch
git submodule update --init --recursive
.\fbt.cmd COMPACT=1 DEBUG=0
.\fbt.cmd COMPACT=1 DEBUG=0 updater_package
```

The `git reset --hard` + fresh `git submodule update --init --recursive` matters
this time — the branch was force-pushed with different history, and the new commits
require the submodules to actually be initialized (they weren't present as
submodules in v1 at all).

### What to send back

Same as before: exact commands used, full result (PASS/FAIL) for both the plain
build and `updater_package`, artifact paths + sizes if produced, the toolchain
version line, and — if it fails again — the exact, unparaphrased error, plus
confirmation of which step it failed at this time (asset generation again, or
somewhere in actual app compilation, which would be a new and different class of
issue specific to one of the 5 apps rather than the base).

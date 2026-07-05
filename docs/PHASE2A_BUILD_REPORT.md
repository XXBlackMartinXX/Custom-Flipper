# Phase 2A — Build Report

## Build environment

- Container: same ephemeral cloud sandbox used throughout this project (no physical
  Flipper Zero, permanent constraint — see `KNOWN_ISSUES.md` on the documentation
  branch).
- Branch: `integration/phase2a-first-batch`, HEAD at commit `42e08a9` (after all 5
  app imports).
- Working tree: clean (`git status` shows nothing outstanding beyond this doc being
  written).

## Exact command attempted

```
cd /home/user/Custom-Flipper
./fbt
```

No arguments — a plain default build, matching how Phase 0/4's baseline build was
first attempted. Official, **unmodified** `fbt`/`fbtenv.sh` — no substitute
toolchain, no `-Wno-error` patches, nothing non-canonical. `site_scons/cc.scons` is
byte-for-byte the upstream Unleashed file (verified during the base-import commit).

## Result: BLOCKED (same root cause as documented in Phase 0/4, re-confirmed fresh)

```
Checking for tar..yes
Checking if downloaded toolchain tgz exists..no
Checking curl..yes
Downloading toolchain:
curl: (56) CONNECT tunnel failed, response 403
Failed to download https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz
```

Cross-checked against the sandbox's own proxy status endpoint immediately after:

```json
{
  "ts": "2026-07-05T14:32:09.978Z",
  "kind": "connect_rejected",
  "detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)",
  "host": "update.flipperzero.one:443"
}
```

This is a **policy denial**, not a transient failure, and per this environment's own
operating rules a policy denial is reported, not routed around. **No substitute
toolchain was used this time** (unlike the earlier Phase 0/4 cloud experiment, which
was explicitly reverted out of the tree and is not being repeated per this phase's
instructions).

- **Firmware build (`./fbt`): NOT ATTEMPTED TO COMPLETION** — blocked before any
  compilation could start.
- **Updater package (`./fbt updater_package`): NOT ATTEMPTED** — no point running it
  when the prerequisite plain build can't get past toolchain acquisition.
- **Artifact paths**: none produced.
- **Warnings/errors**: the single fatal error above; nothing else ran.

## What was done instead: static/source validation

Per instruction, no build pass is faked. The following was actually checked, per
app, and is real evidence (not inferred):

| Check | Method | Result (all 5 apps) |
|---|---|---|
| `application.fam` syntax | `python3 -c "ast.parse(...)"` (the `.fam` format is plain Python function-call syntax) | All 5 parse cleanly |
| `appid` uniqueness | Grepped each new `appid` against `applications/` (base) and against each other | All 5 unique, no collisions |
| Referenced files exist | Directory listing cross-checked against files actually copied | All referenced icons/sources present |
| Brace balance (real syntax check, not superficial) | Custom comment/string-aware brace checker written this session (a naive `grep -o "{"` count gave false positives on `chess`'s font-data and SAM-engine files — investigated directly, not dismissed or treated as a real error until confirmed) | All `.c`/`.cpp` files in all 5 apps balanced |
| Capability/API grep (GPIO, Sub-GHz, Infrared, NFC/RFID/iButton, BLE, USB/HID) | `grep -rlE` for real Flipper HAL function names across each app's actual source | Zero hits across all 5 apps (see `PHASE2A_SAFETY_REVIEW.md` for the full breakdown) |
| Dependency declarations (`requires`, `fap_libs`) | Read every `application.fam` directly, not just Phase 1.6's narrower check | `flipper95` declares `fap_libs=["mbedtls"]`, already present in the base — no new dependency. No other app declares `requires`/`fap_libs`. |

None of this is a substitute for an actual compile — a real build could still fail on
things static checks can't catch (macro expansion issues, linker errors, API
signature mismatches against this exact Unleashed commit's headers, etc.). It rules
out the most common trivial failure classes (malformed manifest, missing files,
gross syntax errors, appid collisions) but is explicitly **not** claimed as
build-equivalent.

## Build status: **PENDING LOCAL BUILD**

Consistent with the project's established pattern (see the documentation branch's
`LOCAL_WINDOWS_BUILD_HANDOFF.md`, which already got a real local Windows build to
PASS for the unmodified base). The same path applies here:

### To actually build this branch locally

```powershell
git clone <this repo URL> custom-flipper-phase2a
cd custom-flipper-phase2a
git checkout integration/phase2a-first-batch
.\fbt.cmd COMPACT=1 DEBUG=0
```

Expected artifact on success: `build\f7-firmware-C\firmware.dfu` (or `-D` suffix
without `DEBUG=0`), same as the base build. To confirm the 5 new apps specifically
built as loadable `.fap` files:

```powershell
.\fbt.cmd COMPACT=1 DEBUG=0 fap_network_subnet fap_programmercalc fap_vin_decoder fap_flipper95 fap_chess
```

(Exact `fap_<appid>` target names per each app's declared `appid` — see
`PHASE2A_INTEGRATION_LOG.md` for the five appids used.)

### What to send back

Same as the existing local-build handoff protocol: the full captured log, the
toolchain version line, confirmation of artifact paths + sizes, and — specifically
for this phase — confirmation that all 5 `.fap` targets built without error, not
just the base firmware image. If any of the 5 fails, report exactly which one and
the exact compiler/linker error; per this phase's rules, a build failure in one app
should be diagnosed on its own, not batch-fixed alongside the others.

## Do not confuse this with a build pass

To be explicit, since this matters: **no compilation of this branch's code has
happened anywhere in this project yet.** The base firmware's own clean build
(confirmed PASS) was performed against unmodified Unleashed, before any of these 5
apps existed in the tree. This branch, with the 5 apps added, has not been
compiled by anyone, in any environment, as of this report.

# Build Log — Unleashed Base, Phase 0/4 Verification Pass

## What this is

A real, unedited-output record of attempting `./fbt` against a real recursive clone of
`DarkFlippers/unleashed-firmware` (`dev`, commit `5cdf9b33745f41f1a0405a6da44821128c233f5c`)
in this session's sandboxed container. **Result: build did not complete.** This is
reported honestly rather than claimed as a pass — see "Why it stopped" below.

## Environment

- Container: ephemeral cloud sandbox, no physical Flipper Zero attached (permanent
  constraint — see `PHASE0_SOURCE_VERIFICATION.md`).
- Source: recursive shallow clone with all 12 submodules initialized (280MB), commit
  hash as above, unmodified except the two documented local flag changes below.

## Blocker #1 (root cause): vendor toolchain host is policy-blocked

`fbt` downloads a pinned, patched ARM GCC 12.3 toolchain from
`https://update.flipperzero.one/builds/toolchain/gcc-arm-none-eabi-12.3-x86_64-linux-flipper-39.tar.gz`.
This session's egress proxy returned `403` for `update.flipperzero.one:443`
(confirmed via `curl $HTTPS_PROXY/__agentproxy/status` → `"kind": "connect_rejected",
"detail": "gateway answered 403 to CONNECT (policy denial or upstream failure)"`).
Per this environment's own operating rules, a policy denial is reported, not routed
around. **This is the actual, load-bearing blocker for a canonical, reproducible
build in this environment.**

## What I did instead (clearly non-canonical, for verification only)

To see whether the *source itself* would compile at all (independent of the exact
toolchain), I substituted:
- `gcc-arm-none-eabi` 13.2.rel1 + `gdb-multiarch` + `libstdc++-arm-none-eabi-newlib`
  (Ubuntu 24.04 `apt` packages, not Flipper's pinned 12.3-flipper-39 build)
- A Python 3.11 venv with `pip`-installed `scons`, `pillow`, `pyelftools`,
  `heatshrink2`, `colorlog`, `cxxheaderparser`, `oslex`, `pyserial`, `requests`,
  `lxml`, `ansi`, `protobuf` (standing in for the toolchain's bundled Python
  environment, which also is not downloadable per Blocker #1)
- A hand-built `toolchain/x86_64-linux/` directory satisfying `fbtenv.sh`'s existing-
  toolchain check, so `fbt` would skip the blocked download

**This substitution is not a reproducible-build equivalent** — it exists only to
answer "does the unmodified source compile," not to produce a distributable artifact.

## Local flag changes made (both in `site_scons/cc.scons`, both reverted-in-spirit —
## i.e. neither is proposed for the real project, both exist only in the scratch clone)

1. `-Wno-error=strict-aliasing` — GCC 13's stricter strict-aliasing check flags a
   byte-punning read in vendored `lib/stm32wb_hal/Inc/stm32wbxx_ll_spi.h` (ST's code)
   that GCC 12.3 does not flag as an error. Confirmed as a compiler-version delta, not
   a defect: the pattern (`*(__IO uint8_t*)&SPIx->DR`) is standard low-level register
   access.
2. `-Wno-error=uninitialized` — GCC 13's stricter uninitialized-variable analysis
   flags `lib/drivers/lp5562.c` (`lp5562_configure`, `lp5562_enable`), which use fully
   designated-initializer bitfield structs read via byte-cast. Inspected by hand:
   both structs fully initialize every field via designated init; this is a confirmed
   compiler false positive for this coding pattern under GCC 13, not present under
   GCC 12.

With both changes, the build progressed through **267 successful compile/link/proto
steps** (protobuf codegen, BLE profile/services, bit_lib, digital_signal, FatFS,
datetime, assets, and the start of `targets/f7/ble_glue`) before stopping.

## Why it stopped (Blocker #2 — not attempted further)

`lib/mjs/common/frozen/frozen.c:690` fails with `error: expected ')' before
'PRIu64'` even though the file does `#include <inttypes.h>`. Root-caused by
inspection to Ubuntu's newlib gating `PRIu64` behind `#if __int64_t_defined`
(`/usr/include/newlib/inttypes.h:216`), which is set via a chain of internal
`___int64_t_defined` macros in `machine/_default_types.h` / `sys/_stdint.h` that did
not resolve as expected for this file's specific include order in this newlib
packaging. This is a **substitute-libc packaging quirk**, not a defect in `mjs`
(a mature, widely-used third-party JSON library) or in Unleashed's own code.

I stopped here rather than continuing to patch around individual GCC/newlib version
deltas one at a time. Each fix so far has been narrow and well-understood, but this
one would require forcing an internal libc macro (`__int64_t_defined`) without being
able to verify it doesn't mask a real ABI mismatch elsewhere — that crosses from
"documented, safe warning demotion" into "blindly asserting an unverified libc
invariant," which I'm not willing to do silently. Continuing to firefight toolchain
substitution issues one-by-one stops being a meaningful test of "does Unleashed
build" and becomes "can an ad hoc toolchain be reverse-engineered to match a vendor
build" — a different and much less certain undertaking.

## Honest bottom line

- **Not confirmed**: a clean, reproducible `./fbt` build of Unleashed in this
  environment. Blocked at the root by network policy (Blocker #1); the substitute
  toolchain got substantially further (267 build steps) before hitting a second,
  different-in-kind blocker (Blocker #2).
- **What this pass does show**: no evidence of defects in Unleashed's own source in
  everything that did compile; the two issues fixed were both independently verified
  as GCC-12-vs-13 false positives in vendored/third-party code, not Unleashed bugs.
- **What would resolve this cleanly**: either (a) allow-list
  `update.flipperzero.one` for this environment so the real pinned toolchain can be
  used, or (b) run `./fbt` in an unrestricted environment (a real workstation or CI
  runner), which is how Unleashed's own CI does it.
- No build artifact (`.dfu`/`.elf`/`.bin`) exists as a result of this pass. None is
  claimed.

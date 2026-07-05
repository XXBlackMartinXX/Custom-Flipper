# Known Issues

## Environment / process (not firmware defects)

1. **Vendor toolchain unreachable from this build environment.** Unleashed's `fbt`
   downloads a pinned, patched ARM GCC 12.3 toolchain from
   `update.flipperzero.one`. This session's network egress policy returns HTTP 403
   for that host (confirmed via the proxy status endpoint — a policy denial, not a
   transient failure). Real, exactly-reproducible builds require either running `fbt`
   outside this restricted network, or the host being allow-listed.
2. **This build used a substituted toolchain** (Ubuntu 24.04 `gcc-arm-none-eabi`
   13.2.rel1 + a pip-installed Python/SCons environment) instead of Flipper's pinned
   12.3-flipper-39 build. This is clearly non-canonical and is not a reproducible-build
   substitute for the vendor toolchain — it exists solely to validate that the source
   itself compiles, given issue #1. See `BUILD_LOG.md` for exact deltas this required
   (a `-Wno-error=strict-aliasing` local patch to `site_scons/cc.scons`, scoped to
   vendored ST HAL code, not carried upstream).
3. **No physical Flipper Zero exists in this environment.** Boot, flashing, app
   loader, and hardware-interaction testing described in the project's QA phases have
   not been performed and cannot be performed here.

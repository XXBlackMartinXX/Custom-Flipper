# RFC 5: Safe Mode and Crash Isolation

Status: **PROPOSED** (design only — nothing in this RFC has been
implemented or hardware-tested in this phase).

## Problem

A firmware with many optional apps (even external FAPs) has more
surface area for a single misbehaving app to affect the user's overall
experience — a hung loader, a corrupted setting, or a crash loop
associated with a specific app should not require a full recovery
(`docs/ROLLBACK_READINESS_AFTER_INSTALL.md`'s official/stable-firmware
path) to resolve. This RFC proposes a lighter-weight, app-scoped
isolation mechanism that sits above full firmware recovery, not a
replacement for it.

## Crash attribution

When a crash or hang is detected (by the same signals
`tools/hardware_app_tester/hardware_app_tester/crash_detection.py`
already defines: uptime reset, USB disappearance, loader timeout, panic
log markers, heap regression), the system should attribute it to the
most recently launched app, recorded via the RFC 1 Health Center's
`crash_count_since_last_reset` field. Attribution is best-effort — a
crash that occurs with no app recently launched is attributed to
firmware core itself, not silently discarded.

## Optional-app quarantine

After a configurable number of attributed crashes for the same
`app_id` within a short window (exact threshold TBD at implementation
time), that app is marked `blocked` in the Health Center (RFC 1's state
machine) and removed from the normal app menu — not deleted, not
erased, just hidden from the default launch path. This is a metadata
change only, fully reversible, and never touches internal flash beyond
updating the Health Center record itself.

## Reduced boot profile

If firmware core itself appears to be crash-looping (not attributable
to any specific app), the device should be able to boot into a reduced
profile: core services only, no optional apps loaded, desktop
available, Settings available — enough to inspect logs, view the
Health Center, and un-quarantine or further diagnose, without any data
loss. This mirrors `CUSTOM_CORE`'s own "independently stable and
bootable" invariant from `MODULAR_FIRMWARE_PROFILES.md` — the reduced
boot profile *is* effectively a runtime fallback to `CUSTOM_CORE`
behavior, not a separate firmware image.

## Preserved logs

Any crash/hang detection event preserves the relevant log lines (the
same `expected_log_patterns`/`forbidden_log_patterns` concept already
defined in the hardware app tester's YAML test profile schema) to a
persistent location on microSD, not just volatile RAM, so they survive
the reduced-boot-profile reboot that likely follows a real crash.

## Non-destructive recovery

Quarantine and reduced-boot-profile entry are both explicitly
non-destructive: no factory reset, no storage format, no firmware
reflash. This is a hard invariant, not a soft preference — it is the
entire reason this RFC exists as something *lighter* than full recovery.

## User-controlled re-enable

A quarantined app is never automatically re-enabled. The user (or, in
an automated test context, a human reviewing test evidence) must
explicitly choose to re-enable it, at which point its Health Center
state resets to `experimental` (per RFC 1's state machine — a
previously blocked app does not jump straight back to `stable`).

## No automatic erasure

Nothing in this RFC ever erases user data, settings, or files as part
of crash handling. If recovery beyond quarantine/reduced-boot is ever
needed, that is explicitly the domain of the existing
`docs/ROLLBACK_READINESS_AFTER_INSTALL.md` official-firmware recovery
path, with its own separate, already-designed human-authorization
phrase requirement — this RFC does not redefine or weaken that.

## Relationship to other RFCs

- RFC 1 (Health Center) is the state store this RFC reads/writes
  (`state`, `crash_count_since_last_reset`).
- RFC 2 (Smart App Packs): a quarantined app's pack membership is
  unaffected by quarantine — quarantine is an app-level state, not a
  pack-level one.

## Proof-of-concept plan (not built in this phase)

1. Define the exact crash-attribution heuristic and quarantine
   threshold as a pure, unit-testable function (following the same
   pattern as `crash_detection.py`), before any on-device
   implementation.
2. Real reduced-boot-profile behavior requires firmware-level changes
   this phase's boundaries explicitly exclude (no firmware/app source
   modification) — this RFC is architecture only until a dedicated,
   explicitly-scoped implementation phase.

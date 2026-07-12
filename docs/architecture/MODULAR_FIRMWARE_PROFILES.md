# Modular Firmware Profiles

Design document. No profile below has been built or hardware-tested in
this phase — this defines the target architecture and the resource
discipline required before any of them are populated with real apps.

## Why profiles, not one monolithic build

The current 20-app integration baseline (accepted build
`86265727b5b8cfce5086eb88f8bb93d0169ab9a9`) already demonstrates the
risk of unbounded growth: every app added to a single firmware image
grows flash usage, boot time, and menu load time for every user,
regardless of whether they want that app. A genuinely differentiated
Custom-Flipper cannot simply keep concatenating every interesting app
from every upstream fork into one ever-larger image — that is
"combining existing firmware," not improving on it.

Instead, Custom-Flipper defines a small set of named profiles, each a
distinct, independently buildable firmware target sharing one common
core.

## Profiles

| Profile | Purpose | Contains |
|---|---|---|
| `CUSTOM_CORE` | The stable, minimal, always-bootable base | Firmware core, official built-in apps, no optional custom apps built in |
| `CUSTOM_FULL` | The "everything reasonable" convenience build | `CUSTOM_CORE` + every app that has passed Gate B qualification, built in |
| `CUSTOM_GAMES` | Games-focused build | `CUSTOM_CORE` + games category apps only |
| `CUSTOM_DEVELOPER` | Development/debugging-focused build | `CUSTOM_CORE` + debug tools, `fap_boilerplate`, developer-oriented apps |
| `CUSTOM_MODULES` | Hardware/module-accessory-focused build | `CUSTOM_CORE` + apps requiring the Hardware and Module Compatibility Hub (RFC 4) |
| `CUSTOM_EXPERIMENTAL` | Bleeding-edge, unstable candidate build | `CUSTOM_CORE` + `EXPERIMENTAL`-disposition candidates from the ecosystem census |

### `CUSTOM_CORE` invariant

`CUSTOM_CORE` must remain independently stable and bootable with **zero**
optional custom apps built in. It is the regression baseline every other
profile is measured against, and the profile every resource budget in
this document is defined relative to. If `CUSTOM_CORE` itself grows
unstable, no other profile can be trusted.

## Built-in vs. external FAP default

**Default: external FAP.** An application only becomes a built-in,
firmware-image-resident app in a non-`CUSTOM_CORE` profile if there is a
documented, specific technical reason it cannot work well as an external
`.fap` — for example, a genuine boot-time system service, not merely
"this app is popular" or "this app is small." This default exists
because external FAPs:

- Do not grow the base firmware image or updater package size.
- Can be installed/removed per-device without a firmware rebuild.
- Are the natural fit for RFC 2's Smart App Packs (per-pack install/
  remove/version-lock without touching the firmware image at all).

Every app currently in the 20-app integration baseline is already an
external FAP (confirmed via each app's `application.fam` — all 20
declare `apptype = FlipperAppType.EXTERNAL`), which is consistent with
this default and requires no rework to continue.

## Resource budgets

See `docs/RESOURCE_BUDGETS.md` for the full budget table and
measurement methodology. In summary, hard thresholds must be set and
checked in CI **before** importing any new batch of apps in a future
wave — this document defines the categories; the actual numeric
thresholds live in the budgets document so they can be revised without
re-litigating the profile architecture itself.

## Profile promotion rule

An app may only be built into a non-`CUSTOM_CORE` profile's firmware
image after:

1. Passing Gate B (current 20-app) or the equivalent per-wave
   qualification gate (Gate E) for a newly imported app.
2. A documented resource-budget check showing the addition does not
   exceed that profile's thresholds.
3. An explicit decision recorded in that profile's own manifest,
   naming the technical reason it is built-in rather than external
   (only relevant for non-`CUSTOM_CORE`/`CUSTOM_FULL` cases where
   built-in status is the exception, not the rule).

No profile is populated by this phase. This document defines the rule
set; Gate E (first vNext import wave) is the first point at which any
app is actually assigned to a profile.

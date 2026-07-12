# License Compatibility Matrix

## Firmware-core level: all GPL-3.0, byte-identical

All four primary repositories and this project's own repository ship
the exact same GPL-3.0 `LICENSE` text at the root
(SHA256 `3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`
— see `SOURCE_PROVENANCE.md`). GPL-3.0 is compatible with itself:
combining GPL-3.0-licensed firmware core across these projects raises
no new obligation this project doesn't already carry from its own
Unleashed-derived base.

## App-level licensing is where the real work is

Firmware-core license compatibility does not automatically extend to
every individual bundled app — community apps in all three companion
repositories (`unleashed_plugins`, `momentum_apps`, `roguemaster`) are
contributed by many different authors and may carry their own,
individually-scoped licenses (or none at all). This phase's research
agents were not tasked with opening and reading every one of the
1,330 apps' own license files — that is out of scope for a foundation
phase and is exactly the kind of recurring work RFC 6 (Upstream
Intelligence and Sync Automation) proposes automating.

**Rule enforced in this phase's own recommendations (`APP_CENSUS.json`,
`RECOMMENDED_IMPORT_WAVES.md`)**: no candidate is given an `INCLUDE` or
`INCLUDE_AFTER_PORT` disposition without an individually confirmed
license. Every candidate this phase actually recommends for import
waves has a license status of `CONFIRMED` in the census; every
candidate whose license was not individually checked in this phase is
marked `NOT_YET_VERIFIED` and given a `NEEDS_REVIEW` or `DEFER`
disposition — never `INCLUDE`.

## Our own repository's existing license gap (pre-existing, not new)

A direct check of this repository's own `applications_user/` (not an
upstream repo — our own tree) found that **3 of our own 20 apps ship
with no per-app `LICENSE` file at all**: `boilerplate`
(`fap_boilerplate`), `flipper95`, and `network_subnet`. This is a
pre-existing condition in this repository, not something introduced or
newly discovered as a defect by this phase — it is recorded here
because a complete license-compatibility matrix must include our own
apps, not only candidate imports. Whether this warrants closing the gap
by adding an explicit license (matching the firmware-core GPL-3.0, if
that is what the author intended) is a decision for the project owner,
not made by this phase.

## Compatibility disposition guidance used by this census

| Situation | Disposition guidance |
|---|---|
| App has an explicit, permissive-and-GPL-3.0-compatible license (e.g. MIT, BSD, Apache-2.0, GPL-family) | Eligible for `INCLUDE`/`INCLUDE_AFTER_PORT`, pending the rest of the census's other checks (duplicate, safety, maintenance) |
| App has an explicit license this phase did not individually confirm | `NEEDS_REVIEW` — never `INCLUDE` |
| App has no license file and no clear attribution | `REJECT_LICENSE` if import is being considered; not applicable to apps already in our own tree (see gap above, which is a remediation question, not an import decision) |
| App's license has unresolved attribution requirements this phase could not confirm satisfied | `REJECT_LICENSE` or `NEEDS_REVIEW`, per the specific obligation |

## What this phase does NOT claim

This phase does not claim to have exhaustively verified license
compatibility for all 1,330 candidate apps discovered in the census. It
claims, accurately: the firmware-core license is uniformly GPL-3.0
across every source examined, and every app this phase itself
recommends for a future import wave has had its license individually
confirmed (see `APP_CENSUS.json`'s `license_compatibility` field per
candidate, and `RECOMMENDED_IMPORT_WAVES.md`).

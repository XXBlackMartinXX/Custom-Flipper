# RFC 6: Upstream Intelligence and Sync Automation

Status: **PROPOSED** (design only — nothing in this RFC has been
implemented in this phase; the real, manual census performed in
`docs/ecosystem/` during this same phase is the closest existing
approximation of what this RFC would eventually automate).

## Problem

This phase's ecosystem census (Part II) was performed manually, once,
by real repository clones and human/agent-directed inspection. That is
the right way to do a first census, but it does not scale as a
recurring process — official firmware, Unleashed, Momentum, and
RogueMaster all continue to change. This RFC proposes automating the
*recurring* parts of what this phase's census did by hand.

## Source update detection

Periodically (frequency TBD at implementation time — not a live
service in this phase), re-resolve each pinned source repository's
current tip commit and compare it to the last-recorded pin in
`docs/ecosystem/SOURCE_PROVENANCE.md`. A changed tip commit is a
detection event, not an automatic re-pin — re-pinning is a reviewed,
human-approved action (consistent with "agents may propose findings but
may not silently merge code").

## API-diff reports

When a source update is detected, diff the firmware API version
declared in that repository (the same `firmware_api` field this
phase's census records per candidate) against the previously recorded
value. A version bump is reported as a candidate compatibility risk for
every already-imported app whose own `application.fam` declares
`requires` against the affected API — this reuses the RFC 1 Health
Center's `api_compatibility` field as the place these findings land.

## Security/bug-fix reports

Where a source repository's commit messages or release notes mention
security fixes or notable bug fixes (best-effort text matching, not a
guaranteed-complete scan), surface these as review candidates rather
than silently ignoring them. This phase's own official-firmware census
already surfaced one concrete example worth this kind of tracking: the
real commit found at HEAD (`7432d21a...`) documents CCID USB support
being relocated out of firmware core into a debug FAP specifically to
recover ~1.7KB of flash, alongside an API version bump from 87.3 to
88.0 — exactly the kind of upstream change this RFC's automation should
flag for review, not just the security-fix case.

## New-app discovery

Re-run the same directory-enumeration technique this phase's manual
census used (`applications_user/`/`applications/external/` listings)
and diff the app-id set against `docs/ecosystem/APP_CENSUS.json`. Newly
appearing app IDs are reported as new candidates for triage, not
auto-imported.

## License-change detection

Re-hash each tracked source's LICENSE file (the same SHA256-pinning
discipline this phase's real census already applies) and flag any
mismatch as a license-change event requiring a fresh
`LICENSE_COMPATIBILITY_MATRIX.md` review for every candidate sourced
from that repository — a license change is never silently absorbed into
an existing "approved" disposition.

## Conflict forecasting

Before any future import wave, forecast app-ID collisions and
destination-path collisions against the current 20-app baseline plus
anything already imported in prior waves (reusing the exact duplicate-
detection logic already required by Part V's quality system) —
"forecasting" here means running the same checks pre-emptively against
a *candidate* set, not inventing new detection logic.

## Candidate update PRs

When a source update passes triage (human-reviewed, not automatic),
this RFC proposes generating a draft PR bumping that one candidate's
pinned commit/hash in `docs/ecosystem/`. Consistent with this project's
whole-project discipline: **agents may propose findings and draft PRs,
but may not merge them**, and no import PR bypasses the existing
per-wave review gates (source review, license review, build, unit
tests, automated hardware smoke, resource comparison, regression
report — Part VIII Gate E's own requirements).

## Reproducible source pinning

Every fact this RFC's automation would produce must be re-derivable
from a real, timestamped clone/commit-hash pair, exactly like this
phase's own manual census (`docs/ecosystem/SOURCE_PROVENANCE.md`) — no
"trust me" summarization without a reproducible source pin backing it.

## Relationship to other RFCs

- RFC 1 (Health Center): receives API-compatibility findings.
- RFC 2 (Smart App Packs): a license-change or security-fix finding on
  an app that's part of a pack should surface a pack-level warning too.

## Proof-of-concept plan (not built in this phase)

1. This phase's own `docs/ecosystem/` deliverables are the manual,
   one-time version of what this RFC would automate — treat them as the
   baseline this RFC's first real automated run should diff against.
2. A minimal first automation milestone: a script that re-resolves the
   4 pinned repositories' tip commits and reports whether each has
   changed since this phase's recorded pin, with no other logic yet —
   deliberately small, not attempted in this phase.

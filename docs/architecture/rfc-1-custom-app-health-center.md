# RFC 1: Custom App Health Center

Status: **PROPOSED** (architecture only — nothing in this RFC has been
implemented or hardware-tested in this phase).

## Problem

As Custom-Flipper grows past a hand-tracked 20-app baseline into a
multi-wave import pipeline (Part V/VI of this phase's mission) with
multiple firmware profiles (`MODULAR_FIRMWARE_PROFILES.md`), there is no
single place that answers, for any given app: is it still healthy? Has
it been tested? Against what firmware API version? When did it last
crash? This RFC proposes a Health Center — a structured record, not
(initially) a live on-device UI — that every other system in this
project (CI, the hardware app tester, the RFC 2 Smart App Packs system)
reads from and writes to.

## Data model

One record per app, keyed by `app_id`, persisted as a structured file
(JSON or SQLite — TBD at implementation time, JSON is sufficient at
current scale and keeps the record diffable in git):

```json
{
  "app_id": "resistance_calculator",
  "inventory": {
    "source_path": "applications_user/resistors",
    "display_name": "Resistor Color Code Calculator",
    "category": "Tools"
  },
  "provenance": {
    "source_repository": "<this repo, or upstream origin if imported>",
    "source_commit": "<pinned commit>",
    "license": "<SPDX identifier>"
  },
  "version": "<app version string, from application.fam if present>",
  "api_compatibility": {
    "declared_api_version": "<from application.fam>",
    "last_verified_against": "<firmware API version last confirmed compatible>"
  },
  "test_status": {
    "automation_class": "SAFE_AUTOMATION | FIXTURE_REQUIRED | MANUAL_VISUAL_REQUIRED | PROHIBITED_AUTOMATION | NOT_SUPPORTED",
    "last_test_date": "<ISO 8601, or null if never tested>",
    "last_test_result": "PASS | FAIL | BLOCKED | NOT_SUPPORTED | NEEDS_REVIEW | null",
    "crash_count_since_last_reset": 0
  },
  "memory_profile": {
    "last_measured_heap_delta_bytes": null,
    "last_measured_flash_size_bytes": null
  },
  "missing_assets": [],
  "known_issues": [],
  "state": "stable | experimental | blocked"
}
```

## State machine

```
        (import + Gate B/E pass)
                 |
                 v
           experimental
          /              \
  (N consecutive        (a real, reproduced
   clean test runs)      crash/regression)
        |                        |
        v                        v
      stable                  blocked
        |                        |
  (a real crash/                 |
   regression is found)          |
        `------------------------'
                 (root-caused and fixed,
                  re-enters experimental)
```

- **experimental**: newly imported or recently changed; requires more
  clean automated/manual test runs before promotion to `stable`.
- **stable**: consistently passing its declared test profile across
  multiple runs, eligible for `CUSTOM_FULL` and other non-experimental
  profiles.
- **blocked**: a real, reproduced crash, hang, or regression exists.
  Blocked apps are excluded from every firmware profile build until
  root-caused and fixed — this is a hard gate, not a warning.

## What updates the record

- The hardware app tester (`tools/hardware_app_tester/`) writes
  `test_status` and `memory_profile` after each real run.
- CI writes `provenance`, `api_compatibility.last_verified_against`,
  and `known_issues` (from static analysis / build warnings) on every
  build.
- A human reviewer writes `state` transitions explicitly — state never
  silently changes based on a single test run; promotion/demotion
  rules require a minimum run count (exact count TBD at
  implementation time, not fabricated here).

## Explicitly out of scope for this RFC

- A live on-device "Health Center" app/UI. This RFC defines the record;
  a future RFC or implementation phase may propose an on-device viewer.
- Automatic remediation. The Health Center reports state; it never
  modifies, disables, or reinstalls an app on its own.

## Relationship to other RFCs

- RFC 2 (Smart App Packs) reads `state` to decide what may be offered
  in a pack.
- RFC 5 (Safe Mode and Crash Isolation) reads `crash_count_since_last_reset`
  to decide quarantine candidates.
- RFC 6 (Upstream Intelligence) writes `api_compatibility` findings when
  it detects an upstream API diff affecting a given app.

## Proof-of-concept plan (not built in this phase)

1. Hand-author Health Center records for the current 20-app baseline
   from real, already-collected data (provenance from
   `docs/CUSTOM_APP_INVENTORY.md`, licenses from
   `docs/THIRD_PARTY_LICENSE_AUDIT.md` — both already exist in this
   repository from an earlier phase).
2. Wire `tools/hardware_app_tester/` to write `test_status` after a
   real run, once real hardware execution is possible.
3. Only after step 2 has run for real at least once, consider a
   simple CLI or CI-report view before any on-device UI work.
